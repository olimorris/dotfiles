# rclone backup and restore to an encrypted remote.
#
# Commands
#   rake cloud:push            local -> cloud
#   rake cloud:pull            cloud -> local
#   rake cloud:push[true]      either one, with progress output
#   GIT=1 rake cloud:push      also carry .git folders
#   FORCE=1 rake cloud:push    overwrite cloud files that are newer than the local ones
#
#   cloud:push and cloud:pull live in the Rakefile and wrap the two tasks below with the
#   mackup and dotbot steps. cloud:backup:files and cloud:restore:files skip those.
#
# What happens
#   push   rclone copy --update. Adds and overwrites, never deletes, and skips any file
#          the cloud has a newer copy of. Clearing stale files from the cloud is manual.
#   pull   rclone sync --delete-before. Mirrors the cloud onto the machine. Local files
#          the cloud doesn't have are deleted.
#
#   So deleting a file locally leaves it in the cloud, and the next pull brings it back.
#
# What syncs
#   .dotfiles                       whitelist: misc/{mackup,ui,sounds}, .config/prompts,
#                                   .config/obs-sidecar. The rest of .dotfiles is in git.
#   Code                            all but AAI, Java, Ruby/Blog, Ruby/hledger-forecast
#   OliDocs, Downloads, Documents   personal Mac only, both directions
#
#   base_filter.txt excludes .DS_Store, node_modules, .git, caches and build output from
#   all of them. Filters apply to both sides, so an excluded file is never deleted either
#   - a pull cannot touch your local node_modules or .git.
#
# Notes
#   --size-only    fast, but a file edited without changing size is not re-uploaded
#   .git pass      separate and opt-in, omits --size-only: refs are fixed length, so a
#                  size comparison would never notice a branch moving to a new commit
#   --fast-list    unusable, the remote reports ListR: false, so every directory costs
#                  its own API call - ~4,900 for Code, which is why a run takes ~50s
#   check: true    a restore that failed silently would leave install:app_config running
#                  mackup against an empty misc/mackup
#   worktrees      restore rewrites git worktree pointers, which hold absolute paths and
#                  arrive pointing at the other machine's home directory

RCLONE = "/opt/homebrew/bin/rclone"

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
RCLONE_DIR = File.expand_path("../.config/rclone", __dir__)
RCLONE_CONFIG = " --config #{RCLONE_DIR}/rclone.conf"

def storage_remote
  remote = ENV["STORAGE_ENCRYPTED_FOLDER"]
  return remote unless remote.nil? || remote.empty?

  raise "STORAGE_ENCRYPTED_FOLDER is not set - copy .env from 1Password to .config/env/.env"
end

# Synced on every machine. These two have to stay in step across both Macs.
def shared_dirs
  {
    ".dotfiles" => {remote: "#{storage_remote}:dotfiles", filter: "dotfiles_filter.txt"},
    "Code" => {remote: "#{storage_remote}:Code", filter: "code_filter.txt"}
  }
end

# Personal machine only, in *both* directions. The work Mac has no business holding
# these, and it must not push them either: rclone sync mirrors, so a push from a Mac
# that doesn't have them would delete the backup made by the one that does.
#
# Gating on personal_machine? fails safe. A personal Mac misread as work skips these
# dirs; the reverse - a work Mac misread as personal - is the one that destroys data,
# and that only happens if ComputerName is set wrong by hand.
def personal_dirs
  unless personal_machine?
    puts("~> Skipping OliDocs, Downloads and Documents (not the personal machine)")
    return {}
  end

  {
    "OliDocs" => {remote: "#{storage_remote}:Documents"},
    "Downloads" => {remote: "#{storage_remote}:Downloads"},
    "Documents" => {remote: "#{storage_remote}:ICloud_Docs"}
  }
end

def rclone_dirs
  shared_dirs.merge(personal_dirs)
end

# compact drops the nil from a dir with no filter of its own - base_filter is enough
# for the document folders, which need exclusions but no whitelist.
def rclone_filters(*names)
  names.compact.map { |name| " --filter-from #{RCLONE_DIR}/#{name}" }.join
end

# --update makes a push skip any file the remote holds a newer copy of. Without it, a
# machine that hasn't pulled in a while quietly pushes its stale versions over newer
# cloud data: copy with --size-only has no notion of newer or older, it just makes the
# destination match the source wherever the sizes differ. The remote stores modtimes to
# 1ms precision, so the comparison is real rather than a silent no-op.
#
# FORCE=1 drops the flag, for the one thing it blocks: deliberately rolling the cloud
# back to an older copy held on this machine. Announce it, because it re-enables exactly
# the overwrite the rest of the time we're trying to prevent.
def update_flag
  return " --update" unless ENV["FORCE"]

  puts("~> FORCE set - this push will overwrite newer files in the cloud")
  ""
end

# The .git pass is opt-in. Announce the skip so a sync that quietly left history
# behind doesn't look like one that moved it.
def sync_git?
  return true if ENV["GIT"]

  puts("~> Skipping .git folders (set GIT=1 to include them)")
  false
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

    # The worktree checkout itself is synced by the main pass; skip if it isn't here.
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

namespace(:cloud) do
  namespace(:restore) do
    desc("Restore files")
    task(:files, [:progress]) do |_t, args|
      section("Using rclone to restore files")
      run(" /bin/date -u ")

      flag = args[:progress] ? " -P -v" : ""
      other_flags = " --delete-before"
      speed_flags = " --use-mmap --size-only#{PACING}"

      rclone_dirs.each do |local, config|
        filters = rclone_filters("base_filter.txt", config[:filter])
        run(
          " #{RCLONE}#{RCLONE_CONFIG} sync #{config[:remote]} ~/#{local}#{filters}#{speed_flags}#{other_flags}#{flag} ",
          check: true
        )
      end

      next unless sync_git?

      git_remote = "#{storage_remote}:Code"
      git_filters = rclone_filters("git_filter.txt")
      git_flags = " --use-mmap#{PACING}"
      run(
        " #{RCLONE}#{RCLONE_CONFIG} sync #{git_remote} ~/Code#{git_filters}#{git_flags}#{other_flags}#{flag} ",
        check: true
      )

      repair_worktree_pointers(File.expand_path("~/Code"))
    end
  end

  namespace(:backup) do
    desc("Backup files")
    task(:files, [:progress]) do |_t, args|
      section("Using rclone to backup files")
      run(" /bin/date -u ")

      flag = args[:progress] ? " -P -v" : ""
      update = update_flag
      speed_flags = " --use-mmap --size-only#{PACING}#{update}"

      # copy, not sync. sync mirrors, so with two Macs pushing to one remote each push
      # deleted whatever the other machine didn't have - a push from here proposed
      # removing 1,724 files, including git worktrees that only exist on the other Mac.
      # copy writes new and changed files and never removes anything, so the remote only
      # ever grows. Clearing out stale files there is a deliberate, manual job.
      rclone_dirs.each do |local, config|
        filters = rclone_filters("base_filter.txt", config[:filter])
        run(
          " #{RCLONE}#{RCLONE_CONFIG} copy ~/#{local} #{config[:remote]}#{filters}#{speed_flags}#{flag} ",
          check: true
        )
      end

      next unless sync_git?

      git_filters = rclone_filters("git_filter.txt")
      git_flags = " --use-mmap#{PACING}#{update}"
      run(
        " #{RCLONE}#{RCLONE_CONFIG} copy ~/Code #{storage_remote}:Code#{git_filters}#{git_flags}#{flag} ",
        check: true
      )
    end
  end
end
