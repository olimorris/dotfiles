# rclone copy --update to the dotfiles-only channel: misc/mackup, .config/ssh,
# .config/prompts and the rest of dotfiles_filter.txt's whitelist. This is for moving an
# edit between the two Macs, not backing everything up - see cloud.rb for that, which
# also owns the shared rclone constants and helpers this file reuses.
#
# Commands
#   rake work:push            local -> cloud
#   rake work:pull            cloud -> local
#   rake work:push[true]      either one, with progress output
#   FORCE=1 rake work:push    overwrite cloud files that are newer than the local ones
#
#   work:push and work:pull live in the Rakefile and wrap the two tasks below with the
#   mackup and dotbot steps. work:backup:files and work:restore:files skip those.
#
# What happens
#   Both directions are copy --update: newer mtime wins, the older side is left alone,
#   and nothing is ever deleted. cloud.rb's restore uses sync --delete-before instead
#   because rebuilding a fresh Mac needs a mirror - here an un-pushed edit surviving a
#   pull matters more than the two machines matching exactly. See cloud.rb's --update
#   comment for why mtime, not --size-only: an app config toggle can flip a boolean
#   without changing the file's byte count, so a size-only comparison would miss it.
#
#   Deleting a file for good is a manual job - remove it from Koofr directly, same as
#   cloud.rb's push side.

namespace(:work) do
  namespace(:restore) do
    desc("Restore dotfiles from the cloud")
    task(:files, [:progress]) do |_t, args|
      section("Using rclone to restore dotfiles")
      run(" /bin/date -u ")

      flag = args[:progress] ? " -P -v" : ""
      filters = rclone_filters("base_filter.txt", "dotfiles_filter.txt")
      speed_flags = " --use-mmap#{PACING}#{update_flag}"

      run(
        " #{RCLONE}#{RCLONE_CONFIG} copy #{storage_remote}:dotfiles ~/.dotfiles#{filters}#{speed_flags}#{flag} ",
        check: true
      )
    end
  end

  namespace(:backup) do
    desc("Backup dotfiles to the cloud")
    task(:files, [:progress]) do |_t, args|
      section("Using rclone to backup dotfiles")
      run(" /bin/date -u ")

      flag = args[:progress] ? " -P -v" : ""
      filters = rclone_filters("base_filter.txt", "dotfiles_filter.txt")
      speed_flags = " --use-mmap#{PACING}#{update_flag}"

      run(
        " #{RCLONE}#{RCLONE_CONFIG} copy ~/.dotfiles #{storage_remote}:dotfiles#{filters}#{speed_flags}#{flag} ",
        check: true
      )
    end
  end
end
