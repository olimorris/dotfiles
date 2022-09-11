local toggle_spotify_playpause = [[
tell application "Spotify"
  playpause
end tell
]]
-- no, Apple, I didn't mean to open Apple Music instead of Spotify
local function open_spotify_instead_of_apple_music(app_name, event_type, app_obj)
  if event_type == hs.application.watcher.launched and app_name == 'Music' then
    -- kill Apple Music
    app_obj:kill()
    -- open Spotify instead
    hs.application.open('Spotify')
    hs.osascript.applescript(toggle_spotify_playpause)
  end
end

local apple_music_spotify_redirector = hs.application.watcher.new(open_spotify_instead_of_apple_music)
apple_music_spotify_redirector:start()
