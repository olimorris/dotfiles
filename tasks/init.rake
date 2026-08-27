desc("Bootstrap a brand new Mac: Homebrew, rclone, restore files, then run the full install")
task(:init) do
  section("Bootstrapping a new Mac")

  Rake::Task["install:sudo"].invoke
  Rake::Task["install:brew"].invoke
  run(" brew install rclone ", check: true)
  Rake::Task["cloud:pull"].invoke
  Rake::Task["install"].invoke
end
