# rclone push, pull and reset against an encrypted remote. bin/backup is the way in - it
# turns its flags into the env vars below and runs one of these tasks.
#
# Commands
#   rake cloud:push     Mac -> cloud. Newer file wins, nothing is deleted
#   rake cloud:pull     cloud -> Mac. Newer file wins, nothing is deleted
#   rake cloud:sync     push, then pull
#   rake cloud:reset    make this Mac match the cloud exactly. Local extras are deleted
#
# Env
#   CLOUD_GROUPS   required, comma separated: dotfiles, code, docs, git
#   FORCE=1        push and pull also overwrite files that are newer at the destination
#   PROGRESS=1     rclone progress output
#   YES=1          skip the confirmation, for the launch agent
#   DRY_RUN=true   print the commands, run nothing
#
# Groups
#   dotfiles    ~/.dotfiles, minus .git and the machine-local files in dotfiles_filter.txt.
#               A push refreshes the package lists and mackup first. A pull runs git pull
#               first, and a pull or reset runs dotbot, skills and mackup after
#   code        ~/Code
#   docs        ~/OliDocs, ~/Downloads, ~/Documents
#   git         the .git folders inside ~/Code. Needs code, as .git folders without their
#               working trees leave repos git can't open
#
#   base_filter.txt excludes .DS_Store, node_modules, .git, caches and build output from
#   all but git. Filters apply to both sides, so an excluded file is never deleted either
#   - a reset cannot touch your local node_modules, or .git unless git is asked for.
#
# Notes
#   --update       push and pull skip any file the destination holds a newer copy of.
#                  Without it a machine that hasn't pulled in a while pushes its stale
#                  versions over newer data. The remote stores modtimes to 1ms precision,
#                  so the comparison is real rather than a silent no-op
#   copy           push and pull never delete. With two Macs on one remote, sync deleted
#                  whatever the other machine didn't have - one push proposed removing
#                  1,724 files, including worktrees that only existed on the other Mac.
#                  Clearing stale files from the cloud is a manual job in Koofr
#   reset          sync --delete-before, comparing size and modtime. --size-only would
#                  leave a same-size edit in place: actuals.journal and .tool-versions were
#                  both once sitting stale at the right byte count
#   --fast-list    unusable, the remote reports ListR: false, so every directory costs
#                  its own API call - ~4,900 for Code, which is why a run takes ~50s. A
#                  reset lists twice, once for its preview
#   name length    143 chars is the longest a path segment can be. crypt pads to a 16
#                  byte block before base32, so 144 encrypts to 256 bytes and Koofr
#                  rejects anything over 255 with a 400
#   worktrees      a git pull or reset rewrites git worktree pointers, which hold absolute
#                  paths and arrive pointing at the other machine's home directory
#   --links        symlinks travel as .rclonelink files. Without it they're skipped, so a
#                  worktree's link to main/memories never reaches the other Mac

module Cloud
  RCLONE = "/opt/homebrew/bin/rclone"
  GROUPS = %w[dotfiles code docs git].freeze

  # Koofr answers 429 "you have sent too many requests in a given amount of time" when
  # rclone fans out hard, but it's the transfer phase that trips it, not the listing.
  # Measured: a full unthrottled recursive listing of the Code remote covered 9,994
  # directories in 48s at ~210 requests/sec with no 429 at all.
  #
  # That distinction decides the numbers below, because listing is what dominates an
  # ordinary run. The remote reports ListR: false, so --fast-list does nothing here and
  # every directory costs its own API call - ~4,900 of them for ~/Code once the filters
  # have pruned it. A --tpslimit of 10 therefore puts an 8 minute floor under a sync that
  # changed a single file. 100 keeps a real ceiling for the transfer phase while costing
  # the listing about 25 seconds over running uncapped.
  #
  # --transfers is the other half, and the one that was actually causing the 429s: 16
  # concurrent uploads of small files generate far more requests per second than listing
  # does. 8 is the cap on that storm; --checkers stays at 16 because listing can take it.
  PACING = " --transfers=8 --checkers=16 --tpslimit 100 --tpslimit-burst 100"

  # Read the filters and rclone.conf from the repo, not ~/.config/rclone. That path is a
  # symlink created by install:dotbot, which rake init only reaches *after* the restore
  # has run - so on a fresh Mac nothing is there yet. The repo is present from the git
  # clone, and the README already has rclone.conf copied into it by hand.
  DOTFILES_DIR = File.expand_path("..", __dir__)
  RCLONE_DIR = File.join(DOTFILES_DIR, ".config/rclone")
  RCLONE_CONFIG = " --config #{RCLONE_DIR}/rclone.conf"

  module_function

  def storage_remote
    remote = ENV["STORAGE_ENCRYPTED_FOLDER"]
    return remote unless remote.nil? || remote.empty?

    raise "STORAGE_ENCRYPTED_FOLDER is not set - copy .env from 1Password to .config/env/.env"
  end

  # Sorted into GROUPS order rather than the order given, because worktree repair
  # after a git restore needs the code checkouts to already be in place.
  def groups
    groups = ENV["CLOUD_GROUPS"].to_s.split(",").map(&:strip)
    unknown = groups - GROUPS

    raise "Set CLOUD_GROUPS to one or more of: #{GROUPS.join(", ")}" if groups.empty?
    raise "Unknown CLOUD_GROUPS: #{unknown.join(", ")}" if unknown.any?
    raise "git needs code - .git folders without their working trees break the repos" if groups.include?("git") && !groups.include?("code")

    GROUPS & groups
  end

  def transfers(groups)
    remote = storage_remote
    docs = {"OliDocs" => "Documents", "Downloads" => "Downloads", "Documents" => "ICloud_Docs"}

    available = {
      "dotfiles" => [{label: "~/.dotfiles", local: "~/.dotfiles", remote: "#{remote}:dotfiles", filters: %w[base_filter.txt dotfiles_filter.txt]}],
      "code" => [{label: "~/Code", local: "~/Code", remote: "#{remote}:Code", filters: %w[base_filter.txt code_filter.txt], links: true}],
      "docs" => docs.map do |local, cloud|
        {label: "~/#{local}", local: "~/#{local}", remote: "#{remote}:#{cloud}", filters: %w[base_filter.txt], links: true}
      end,
      "git" => [{label: "~/Code .git folders", local: "~/Code", remote: "#{remote}:Code", filters: %w[git_filter.txt]}]
    }

    groups.flat_map { |group| available[group] }
  end

  def rclone_filters(*names)
    names.map { |name| " --filter-from #{RCLONE_DIR}/#{name}" }.join
  end

  def rclone(command, from, to, transfer, flags = "")
    links = transfer[:links] ? " --links" : ""
    " #{RCLONE}#{RCLONE_CONFIG} #{command} #{from} #{to}#{rclone_filters(*transfer[:filters])} --use-mmap#{links}#{PACING}#{flags} "
  end

  def progress_flag
    ENV["PROGRESS"] ? " -P -v" : ""
  end

  def update_flag
    ENV["FORCE"] ? "" : " --update"
  end

  def push_warnings
    return [] unless ENV["FORCE"]

    ["--force: cloud files newer than your local copy will be overwritten"]
  end

  def pull_warnings(groups)
    warnings = []
    warnings << "--force: local files newer than the cloud copy will be overwritten" if ENV["FORCE"]
    warnings << "--git: a branch that moved on both Macs keeps whichever ref is newer, and the other Mac's commits drop off it" if groups.include?("git")
    warnings
  end

  # A dry run of the real sync, so the counts are exactly what the reset will do.
  def reset_warnings(groups)
    puts("~> Checking what the reset would change")

    transfers(groups).filter_map do |transfer|
      output = `#{rclone("sync", transfer[:remote], transfer[:local], transfer, " --delete-before --dry-run --combined - -q")}`
      raise "Couldn't compare #{transfer[:label]} with the cloud" unless $?.success?

      deleted = output.lines.count { |line| line.start_with?("- ") }
      overwritten = output.lines.count { |line| line.start_with?("* ") }
      next if deleted.zero? && overwritten.zero?

      "#{transfer[:label]}: #{deleted} local files deleted, #{overwritten} overwritten"
    end
  end

  # A closed stdin answers nil, so a launch agent run without YES=1 cancels rather than proceeds.
  def confirm(warnings)
    return if warnings.empty?

    puts("\nThis could lose data:")
    warnings.each { |warning| puts("  - #{warning}") }
    return if ENV["YES"] || ENV["DRY_RUN"]

    print("\nContinue? [y/N] ")
    abort("Cancelled") unless $stdin.gets.to_s.strip.downcase.start_with?("y")
  end

  def push(groups)
    if groups.include?("dotfiles")
      %w[brew app_store gems npm pip].each { |list| Rake::Task["backup:#{list}"].invoke }
      Rake::Task["backup:app_config"].invoke
    end

    # No check: true here. One transfer aborting the push cost every one after it its run -
    # a single over-long filename in Code stopped the docs from backing up at all, and
    # those have no git copy to fall back on. Collect the failures and raise once at the
    # end instead. run returns nil when DRY_RUN or TEST_ENV skip the command, so only an
    # explicit false is a failure.
    failed = transfers(groups).select do |transfer|
      run(rclone("copy", transfer[:local], transfer[:remote], transfer, "#{update_flag}#{progress_flag}")) == false
    end

    raise "Push failed for: #{failed.map { |transfer| transfer[:label] }.join(", ")}" if failed.any?
  end

  # check: true on every transfer. A restore that failed silently would leave
  # install:app_config running mackup against an empty misc/mackup.
  def pull(groups)
    # Before the copy, which would otherwise leave git-tracked files modified and block the
    # pull. Not fatal - a failed pull is reported at exit and the rest still runs.
    run(" git -C #{DOTFILES_DIR} pull ") if groups.include?("dotfiles")

    transfers(groups).each do |transfer|
      run(rclone("copy", transfer[:remote], transfer[:local], transfer, "#{update_flag}#{progress_flag}"), check: true)
    end

    after_restore(groups)
  end

  def reset(groups)
    transfers(groups).each do |transfer|
      run(rclone("sync", transfer[:remote], transfer[:local], transfer, " --delete-before#{progress_flag}"), check: true)
    end

    after_restore(groups)
  end

  def after_restore(groups)
    repair_worktree_pointers(File.expand_path("~/Code")) if groups.include?("git")
    return unless groups.include?("dotfiles")

    Rake::Task["setup:links"].invoke
    Rake::Task["setup:apps"].invoke
  end

  # Rewrite the two pointer files git keeps for each linked worktree. Both hold absolute
  # paths, so a tree synced from another machine points at a home dir that doesn't exist:
  #
  #   <repo>/.git/worktrees/<name>/gitdir  ->  <worktree>/.git
  #   <worktree>/.git                      ->  "gitdir: <repo>/.git/worktrees/<name>"
  #
  # The layout below ~/Code is identical on both machines, so swapping the /Users/<user>
  # prefix for this machine's home is an exact fix. commondir is already relative.
  def repair_worktree_pointers(root)
    Dir.glob("#{root}/**/.git/worktrees/*/gitdir").each do |admin_pointer|
      admin_dir = File.dirname(admin_pointer)
      worktree_git = File.read(admin_pointer).strip.sub(%r{\A/Users/[^/]+/}, "#{Dir.home}/")

      # The worktree checkout itself is synced by the code group; skip if it isn't here.
      next unless Dir.exist?(File.dirname(worktree_git))

      rewrite_pointer(admin_pointer, "#{worktree_git}\n")
      rewrite_pointer(worktree_git, "gitdir: #{admin_dir}\n")
    end
  end

  def rewrite_pointer(path, contents)
    return if File.exist?(path) && File.read(path) == contents

    puts("~> repairing worktree pointer #{path}")
    File.write(path, contents) unless ENV["DRY_RUN"]
  end
end

namespace(:cloud) do
  desc("Mac -> Cloud. Newer file wins, nothing deleted. CLOUD_GROUPS=dotfiles,code,docs,git")
  task(:push) do
    groups = Cloud.groups
    section("Mac -> Cloud")

    Cloud.confirm(Cloud.push_warnings)
    Cloud.push(groups)
  end

  desc("Cloud -> Mac. Newer file wins, nothing deleted. CLOUD_GROUPS=dotfiles,code,docs,git")
  task(:pull) do
    groups = Cloud.groups
    section("Cloud -> Mac")

    Cloud.confirm(Cloud.pull_warnings(groups))
    Cloud.pull(groups)
  end

  desc("Push, then pull. CLOUD_GROUPS=dotfiles,code,docs,git")
  task(:sync) do
    groups = Cloud.groups
    section("Mac <-> Cloud")

    Cloud.confirm(Cloud.push_warnings + Cloud.pull_warnings(groups))
    Cloud.push(groups)
    Cloud.pull(groups)
  end

  desc("Make this Mac match the cloud exactly, deleting local extras. CLOUD_GROUPS=dotfiles,code,docs,git")
  task(:reset) do
    groups = Cloud.groups
    section("Cloud -> Mac (reset)")

    Cloud.confirm(Cloud.reset_warnings(groups))
    Cloud.reset(groups)
  end
end
