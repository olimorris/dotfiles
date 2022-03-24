-- no, Zoom, I don't want you to spy on my mic in the background
local function kill_zoom(app_name, event_type, app)
  if
    (
      event_type == hs.application.watcher.hidden
      or event_type == hs.application.watcher.terminated
      or event_type == hs.application.watcher.deactivated
    )
    and app_name == 'zoom.us'
    and #app:allWindows() == 0
  then
    -- make Zoom kill itself when I leave a meeting
    app:kill()
  end
end

local zoom_killer = hs.application.watcher.new(kill_zoom)
zoom_killer:start()
