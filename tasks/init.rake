desc("Bootstrap a brand new Mac: Homebrew, rclone, restore files, then run the full install")
task(:init) do
  section("Bootstrapping a new Mac")

  Rake::Task["install:brew"].invoke

  # work:pull and cloud:pull need all three of these before anything else exists: rclone
  # to fetch the files, dotbot to symlink them, mackup to restore app config.
  # install:brew_packages installs them too, but that runs later, inside `install` - so
  # on a genuinely fresh Mac the dotbot and mackup steps used to fail with command not
  # found.
  run(" brew install rclone dotbot mackup ", check: true)

  # A fresh Mac has no ~/OliDocs at all, and the pull now leaves it alone unless asked.
  # init is the one place that restore is the whole point, so set it.
  ENV["DOCS"] = "1"
  Rake::Task["work:pull"].invoke
  Rake::Task["cloud:pull"].invoke
  Rake::Task["install"].invoke
end
