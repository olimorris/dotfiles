local apps = require("lib.apps")
local meet = require("lib.meet")

--[[
  Launch/toggle by app name, bound to Hyper.
  Some apps have a different process name to their name on disk. To address
  this, a table can be passed which contains the app name followed by the filename
]]
local by_app = {
  a = "Anki",
  b = "Google Chrome", -- Browser
  f = "Finder",
  n = "Bear", -- Notes
  o = "Notion", -- Life OS
  t = "Ghostty", -- Terminal
  v = "OBS", -- Video
  --w = RESERVED
}

-- Focus (or open) the first Chrome tab matching this URL prefix
local by_chrome_tab = {}

-- Anything with its own behaviour
local by_action = {
  -- Wrapped, so a hotkey arg can never land in windowHints' optional first param
  H = function()
    hs.hints.windowHints()
  end,
}

if OnPersonal then
  by_app.c = "Visual Studio Code" -- VS Code
  by_app.e = "Microsoft Excel"
  by_chrome_tab.g = "https://github.com" -- GitHub
  by_chrome_tab.l = "https://claude.ai" -- LLM
  by_app.p = "UPDF"
  by_app.r = "Reminders"
  by_app["["] = "1Password" -- It's next to P...
else
  by_action["g"] = meet.sendToPrompter
  by_app.c = "Slack" -- Chat
  by_app.l = "Claude" -- LLM
  by_chrome_tab.d = "https://calendar.google.com/" -- Diary
  by_chrome_tab.m = "https://mail.google.com/"
end

-- [[ Bindings ]] -------------------------------------------------------------
for key, app in pairs(by_app) do
  local name, filename = app, nil
  if type(app) == "table" then
    name, filename = app[1], app[2]
  end
  hs.hotkey.bind(Hyper, key, apps.toggle(name, filename))
end

for key, url_prefix in pairs(by_chrome_tab) do
  hs.hotkey.bind(Hyper, key, apps.toggleChromeTab(url_prefix))
end

for key, action in pairs(by_action) do
  hs.hotkey.bind(Hyper, key, action)
end
