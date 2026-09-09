require "fileutils"

# Mackup replacement. `mackup backup --force` copies unconditionally and
# stamps a fresh mtime on every run, which defeats rclone's --update
# comparison in cloud.rb - the freshly-copied file always looks newer than
# the cloud, regardless of whether its content actually changed. This copies
# only in the direction the source is newer, and preserves mtimes so that
# signal survives into the push/pull that follows.
module Mackup
  ROOT = File.dirname(__dir__)
  STORAGE = File.join(ROOT, "misc/mackup")
  FILES_LIST = File.join(ROOT, ".config/mackup/files.cfg")

  module_function

  def backup
    each_path { |live, stored| sync_if_newer(live, stored) }
  end

  def restore
    each_path { |live, stored| sync_if_newer(stored, live) }
  end

  def each_path
    paths.each { |relative| yield(File.expand_path("~/#{relative}"), File.join(STORAGE, relative)) }
  end

  def paths
    File.readlines(FILES_LIST).map(&:strip).reject { |line| line.empty? || line.start_with?("#") }
  end

  def sync_if_newer(src, dest)
    return unless File.exist?(src)
    return sync_dir(src, dest) if File.directory?(src)

    sync_file(src, dest)
  end

  def sync_dir(src, dest)
    Dir.glob("**/*", File::FNM_DOTMATCH, base: src).each do |relative|
      next if %w[. ..].include?(File.basename(relative))
      next if File.basename(relative) == ".DS_Store"

      full_src = File.join(src, relative)
      sync_file(full_src, File.join(dest, relative)) unless File.directory?(full_src)
    end
  end

  def sync_file(src, dest)
    return if File.exist?(dest) && File.mtime(dest) >= File.mtime(src)

    puts("~> #{ENV['DRY_RUN'] ? '[dry-run] would copy' : 'syncing'} #{src.sub(Dir.home, '~')}")
    return if ENV["DRY_RUN"]

    FileUtils.mkdir_p(File.dirname(dest))
    FileUtils.cp(src, dest, preserve: true)
  end
end
