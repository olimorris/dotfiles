local hyper = Hyper

------------------------------- APP LAUNCH/TOGGLE ------------------------------
--[[
  The list of keys and apps which enable launching and toggling
  Some apps have a different process name to their name on disk. To address
  this, a table can be passed which contains the app name followed by the filename
]]
local apps = {
  a = "Anki",
  b = "Google Chrome", -- Browser
  e = "Microsoft Excel",
  f = "Finder",
  n = "Bear", -- Notes
  o = "Notion", -- Life OS
  r = "Reminders",
  t = "Ghostty", -- Terminal
  --w = RESERVED
}

if OnPersonal then
  apps.c = "Visual Studio Code" -- VS Code
  apps.k = "Keynote"
  apps.p = "UPDF"
  apps["["] = "1Password" -- It's next to P...
else
  apps.c = "Teams" -- Chat
  apps.m = "Microsoft Outlook" -- Mail
  apps.p = "Microsoft PowerPoint"
  apps.r = "Microsoft To Do"
  apps.z = "Zoom"
end

local LaunchOrToggle = function(key, app_name, app_filename)
  hs.hotkey.bind(hyper, key, function()
    local app = hs.application.get(app_name)
    -- Toggle - show
    local awin = nil
    if app then
      awin = app:mainWindow()
    end
    -- Toggle - hide
    if awin and app and app:isFrontmost() then
      app:hide()
    else
      -- Launch
      if app_filename then
        return hs.application.launchOrFocus(app_filename)
      else
        app = hs.application.find(app_name)
        hs.application.launchOrFocus(app_name)
        app.setFrontmost(app)
        app.activate(app)
      end

      -- Move cursor to the application window
      local window = app:mainWindow()
      if window then
        local frame = window:frame()
        local centerPoint = hs.geometry.point(frame.x + frame.w / 2, frame.y + frame.h / 2)
        hs.mouse.absolutePosition(centerPoint)
      end
    end
  end)
end

for key, app_name in pairs(apps) do
  if type(app_name) == "table" then
    LaunchOrToggle(key, app_name[1], app_name[2])
  else
    LaunchOrToggle(key, app_name)
  end
end

--------------------------- APP-SPECIFIC KEYMAPS ------------------------------
local function ghosttySessionizer()
  local home = os.getenv("HOME")

  -- Get open Ghostty windows
  local windows = {}
  local ok, result = hs.osascript.applescript([[
    tell application "Ghostty"
      set output to ""
      repeat with w in (every window)
        set wid to id of w
        set t to focused terminal of selected tab of w
        set wdir to working directory of t
        set output to output & wid & "|||" & wdir & ":::"
      end repeat
      return output
    end tell
  ]])
  if ok and result then
    for entry in result:gmatch("([^:::]+):::") do
      local id, dir = entry:match("(.+)|||(.+)")
      if id and dir then
        windows[dir] = id
      end
    end
  end

  -- Get zoxide directories
  local zoxide_dirs = {}
  local handle = io.popen("/opt/homebrew/bin/zoxide query -l -s 2>/dev/null")
  if handle then
    local output = handle:read("*a")
    handle:close()
    for score, dir in output:gmatch("%s*([%d.]+)%s+([^\n]+)") do
      table.insert(zoxide_dirs, { dir = dir, score = tonumber(score) })
    end
  end
  table.sort(zoxide_dirs, function(a, b)
    return a.score > b.score
  end)

  -- Build choices: zoxide order, tagging open windows
  local choices = {}
  local seen = {}
  for _, entry in ipairs(zoxide_dirs) do
    seen[entry.dir] = true
    table.insert(choices, {
      text = entry.dir:gsub(home, "~"),
      subText = windows[entry.dir] and "open" or nil,
      dir = entry.dir,
      windowId = windows[entry.dir],
    })
  end
  for dir, id in pairs(windows) do
    if not seen[dir] then
      table.insert(choices, {
        text = dir:gsub(home, "~"),
        subText = "open",
        dir = dir,
        windowId = id,
      })
    end
  end

  local chooser = hs.chooser.new(function(choice)
    if not choice then
      return
    end

    if choice.windowId then
      hs.osascript.applescript(string.format(
        [[
        tell application "Ghostty"
          activate window (first window whose id is "%s")
        end tell
      ]],
        choice.windowId
      ))
    else
      hs.osascript.applescript(string.format(
        [[
        tell application "Ghostty"
          set cfg to new surface configuration
          set initial working directory of cfg to "%s"
          new window with configuration cfg
        end tell
      ]],
        choice.dir
      ))
    end

    -- Bump zoxide score
    hs.execute(string.format("/opt/homebrew/bin/zoxide add %q", choice.dir))
  end)

  chooser:choices(choices)
  chooser:show()
end

local ghosttyKeys = hs.hotkey.modal.new()
ghosttyKeys:bind({ "ctrl" }, "w", ghosttySessionizer)

local appWatcher = hs.application.watcher.new(function(name, event)
  if name == "Ghostty" then
    if event == hs.application.watcher.activated then
      ghosttyKeys:enter()
    elseif event == hs.application.watcher.deactivated then
      ghosttyKeys:exit()
    end
  end
end)
appWatcher:start()

if hs.application.frontmostApplication():name() == "Ghostty" then
  ghosttyKeys:enter()
end

-------------------------------------OTHERS-------------------------------------
hs.hotkey.bind(hyper, "H", function()
  hs.hints.windowHints()
end)

-- local function moveCursorToMonitor(direction)
--   return function()
--     local screen = hs.mouse.getCurrentScreen()
--     local nextScreen
--
--     if direction == "right" then
--       nextScreen = screen:next()
--     else
--       nextScreen = screen:previous()
--     end
--
--     local rect = nextScreen:fullFrame()
--     local center = hs.geometry.rect(rect).center
--     hs.mouse.setAbsolutePosition(center)
--   end
-- end
--
-- hs.hotkey.bind(hyper, ",", moveCursorToMonitor("left"))
-- hs.hotkey.bind(hyper, ".", moveCursorToMonitor("right"))
