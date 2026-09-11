local util = require("lib.util")

local M = {}

---Select the first Chrome tab whose URL starts with prefix, raising its window
---@param prefix string
---@return {tabCount: integer, title: string}|nil nil when no tab matches
function M.selectChromeTab(prefix)
  local ok, result = hs.osascript.applescript(string.format(
    [[
    tell application "Google Chrome"
      repeat with w in windows
        set tabList to tabs of w
        repeat with i from 1 to (count of tabList)
          if (URL of item i of tabList) starts with "%s" then
            set index of w to 1
            set active tab index of w to i
            return ((count of tabList) as string) & "\n" & (title of w)
          end if
        end repeat
      end repeat
      return "none"
    end tell
  ]],
    prefix
  ))

  if not ok or not result or result == "none" then
    return nil
  end

  local tabCount, title = result:match("(%d+)\n(.*)")
  return { tabCount = tonumber(tabCount), title = title }
end

---Focus the app, hiding it instead when it's already frontmost
---@param app_name string The process name
---@param app_filename? string The name on disk, when it differs from the process name
---@return fun()
function M.toggle(app_name, app_filename)
  return function()
    local app = hs.application.get(app_name)
    if app and app:mainWindow() and app:isFrontmost() then
      app:hide()
      return
    end

    if app_filename then
      return hs.application.launchOrFocus(app_filename)
    end

    hs.application.launchOrFocus(app_name)
    app = hs.application.find(app_name)
    if not app then
      return
    end

    app:setFrontmost()
    app:activate()
    util.centerCursor(app:mainWindow())
  end
end

---Focus a Chrome tab by URL prefix, opening it when absent and hiding when already there
---@param url_prefix string
---@return fun()
function M.toggleChromeTab(url_prefix)
  return function()
    local app = hs.application.get("Google Chrome")
    if app and app:isFrontmost() then
      local ok, activeURL =
        hs.osascript.applescript('tell application "Google Chrome" to return URL of active tab of window 1')
      if ok and activeURL and activeURL:sub(1, #url_prefix) == url_prefix then
        app:hide()
        return
      end
    end

    if not M.selectChromeTab(url_prefix) then
      hs.osascript.applescript(string.format(
        [[
        tell application "Google Chrome"
          if (count of windows) = 0 then
            make new window
          end if
          tell window 1 to make new tab with properties {URL:"%s"}
        end tell
      ]],
        url_prefix
      ))
    end

    app = hs.application.get("Google Chrome")
    if not app then
      return
    end
    app:activate()
    util.centerCursor(app:mainWindow())
  end
end

return M
