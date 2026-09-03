namespace(:tests) do
  desc("Setup tests")
  task(:setup) do
    section("Setting up the tests")

    stubs = File.expand_path("../tests/stubs", __dir__)

    # misc/packages is rclone-synced, not committed, so a CI checkout has no folder to
    # copy the stubs into.
    ensure_packages_folder

    {
      "app_store.txt" => MAS_COMMON_FILE,
      "python_pip.txt" => PIP_FILE,
      "ruby_gems.txt" => GEMS_FILE,
      "brew_taps.txt" => BREW_TAPS_FILE,
      "brew_packages.txt" => brew_packages_machine_file,
      "brew_cask.txt" => brew_cask_machine_file
    }.each do |stub, target|
      run(" cp #{File.join(stubs, stub)} #{target} ")
    end

    run(" cp #{File.join(stubs, ".mackup.cfg")} #{File.expand_path("../.config/mackup/.mackup.cfg", __dir__)} ")
  end
end
