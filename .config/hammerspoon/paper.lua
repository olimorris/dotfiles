spoon.SpoonInstall.repos.PaperWM = {
  url = "https://github.com/mogenson/PaperWM.spoon",
  desc = "PaperWM.spoon repository",
  branch = "release",
}

spoon.SpoonInstall:andUse("PaperWM", {
  repo = "PaperWM",
  config = {
    screen_margin = 16,
    window_gap = 2,
    window_ratios = { 1 / 3, 1 / 2, 2 / 3 },
  },
  fn = function(PaperWM)
    PaperWM.window_filter:rejectApp("Anki")
    PaperWM.window_filter:rejectApp("Bear")
    PaperWM.window_filter:rejectApp("Finder")
    PaperWM.window_filter:rejectApp("Reminders")
    PaperWM.window_filter:rejectApp("System Settings")
    PaperWM.window_filter:rejectApp("Picture in Picture")

    -- Only tile on the big monitor
    PaperWM.window_filter:setScreens({ "DELL U3818DW" })
  end,
  start = true,
  hotkeys = {
    -- Switch to a new focused window in tiled grid
    focus_left = { { "alt" }, "left" },
    focus_right = { { "alt" }, "right" },
    focus_up = { { "alt" }, "up" },
    focus_down = { { "alt" }, "down" },

    -- Move windows around in tiled grid
    swap_left = { { "alt", "shift" }, "left" },
    swap_right = { { "alt", "shift" }, "right" },
    swap_up = { { "alt", "shift" }, "up" },
    swap_down = { { "alt", "shift" }, "down" },

    cycle_width = { { "alt" }, "r" },
    reverse_cycle_width = { { "alt", "shift" }, "r" },
    increase_width = { { "alt" }, "l" },
    decrease_width = { { "alt" }, "h" },
  },
})
