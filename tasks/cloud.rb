# Backup and restore ~/.dotfiles and ~/Code to/from an encrypted remote via rclone.
#
# Usage:
#   rake cloud:backup:files            # backup, quiet
#   rake cloud:backup:files[true]      # backup, with progress output
#   rake cloud:restore:files           # restore, quiet
#   rake cloud:restore:files[true]     # restore, with progress output
#
#   GIT=1 rake cloud:backup:files      # also sync .git folders (off by default)
#
# How it's structured:
#   Each dir gets its own filter file (dotfiles_filter.txt, code_filter.txt) layered
#   on top of base_filter.txt (common exclusions like .DS_Store, node_modules/, etc).
#
#   base_filter.txt excludes .git everywhere, so Code/**/.git gets a separate pass via
#   git_filter.txt. That pass is opt-in via GIT=1 - git history is heavy and rarely
#   needs moving, so the default sync carries working trees only. It also deliberately
#   omits --size-only, unlike the main sync: refs are fixed length (refs/heads/<branch>
#   is always 41 bytes), so comparing on size alone would silently never propagate a
#   branch moving to a new commit.
#
#   --size-only is used for the main sync for speed, trading off exact content
#   verification for fewer/faster checks.
#
#   --fast-list is deliberately absent: the Koofr backend reports ListR: false, so the
#   flag does nothing on this remote.
#
#   The rclone calls are check: true. A restore that fails silently is worse than one
#   that stops: cloud:pull goes on to run install:app_config, which does a
#   `mackup restore --force` against whatever misc/mackup holds - nothing, if the
#   sync never ran.
#
#   Restore finishes by repairing git worktree pointer files, which hold absolute paths
#   and so arrive pointing at the source machine's home directory.

RCLONE = "/opt/homebrew/bin/rclone"

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

def rclone_dirs
  {
    ".dotfiles" => {remote: "#{storage_remote}:dotfiles", filter: "dotfiles_filter.txt"},
    "Code" => {remote: "#{storage_remote}:Code", filter: "code_filter.txt"}
  }
end

def rclone_filters(*names)
  names.map { |name| " --filter-from #{RCLONE_DIR}/#{name}" }.join
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
      run(" /bin/date -u ")

      flag = args[:progress] ? " -P -v" : ""
      other_flags = " --delete-before"
      speed_flags = " --use-mmap --transfers=16 --checkers=16 --size-only"

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
      git_flags = " --use-mmap --transfers=32 --checkers=32"
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
      run(" /bin/date -u ")

      flag = args[:progress] ? " -P -v" : ""
      speed_flags = " --use-mmap --transfers=16 --checkers=16 --size-only"

      rclone_dirs.each do |local, config|
        filters = rclone_filters("base_filter.txt", config[:filter])
        run(
          " #{RCLONE}#{RCLONE_CONFIG} sync ~/#{local} #{config[:remote]}#{filters}#{speed_flags}#{flag} ",
          check: true
        )
      end

      next unless sync_git?

      git_filters = rclone_filters("git_filter.txt")
      git_flags = " --use-mmap --transfers=32 --checkers=32"
      run(
        " #{RCLONE}#{RCLONE_CONFIG} sync ~/Code #{storage_remote}:Code#{git_filters}#{git_flags}#{flag} ",
        check: true
      )
    end
  end
end
