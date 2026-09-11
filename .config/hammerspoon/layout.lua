local layout = require("lib.layout")

if OnPersonal then
  layout.define("Coding", 1, {
    { "Ghostty", "0,0 3x4", { focus = true, moveToScreen = "monitor" } },
    { "Chrome", "3,0 3x4", { moveToScreen = "monitor" } },
  })

  layout.define("Study", 2, {
    { "Spotify", "0,0 1.75x4", { onlyIfOpen = true, moveToScreen = "monitor" } },
    { "Typora", "0,0 1.75x4", { onlyIfOpen = true, moveToScreen = "monitor" } },
    { "Chrome", "1.75,0 2.5x4", { moveToScreen = "monitor" } },
    { "Ghostty", "0,0 1.75x4", { moveToScreen = "monitor" } },
    -- { "UPDF", "4.25,0 1.75x4", { moveToScreen = "monitor" } },
    { "Notion", "4.25,0 1.75x4", { moveToScreen = "monitor" } },
    -- { "Notion", "0,0 6x4", { moveToScreen = "laptop" } },
  })

  layout.define("Assignment", 3, {
    { "Ghostty", "0,0 2.5x4", { focus = true, moveToScreen = "monitor" } },
    { "Chrome", "2.5,0 3.5x4", { moveToScreen = "monitor" } },
    { "Notion", "0,0 6x4", { moveToScreen = "laptop" } },
    { "Spotify", "0,0 6x4", { onlyIfOpen = true, moveToScreen = "laptop" } },
  })
else
  layout.define("Default", 1, {
    { "Slack", "0,0 2x2", { moveToScreen = "monitor" } },
    { "Notion", "0,2 2x2", { moveToScreen = "monitor" } },
    { "Chrome", "2,0 4x4", { focus = true, moveToScreen = "monitor" } },
    { "Ghostty", "0,0 6x4", { moveToScreen = "laptop" } },
  })

  layout.define("Standup", 2, {
    { "Chrome", "0,0 6x4", { focus = true, moveToScreen = "laptop", url = "https://meet.google.com" } },
    { "Notion", "0,0 6x4", { moveToScreen = "monitor" } },
  })

  layout.define("Deep Work", 3, {
    { "Ghostty", "0,0 3x4", { focus = true, moveToScreen = "monitor" } },
    { "Chrome", "3,0 3x4", { moveToScreen = "monitor" } },
  })
end
