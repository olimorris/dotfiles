-- Restart tab numbering on every config load (including config check).
-- Never wait here: config loading must finish before the server can answer.
local home = assert(os.getenv("HOME"), "HOME is not set")
local config_home = os.getenv("XDG_CONFIG_HOME") or (home .. "/.config")
local state_home = os.getenv("XDG_STATE_HOME") or (home .. "/.local/state")
local watcher, watcher_error = rex.exec.start({
    "/bin/sh", "-c", [[
        unset REX_SERVER REX_SESSION REX_BLOCK REX_CLIENT
        mkdir -p "$2" || exit 1
        exec >>"$2/tab-numbers.log" 2>&1
        # The parent is whichever rex loaded this config, so this follows Rex's binary wherever it moves
        rex="${REX_TAB_NUMBERS_BIN:-$(ps -o comm= -p "$PPID")}"
        case "$rex" in */rex) ;; *) rex="$(command -v rex)" ;; esac
        attempt=0
        until "$rex" --autostart=false --timeout 1s server status >/dev/null 2>&1; do
            attempt=$((attempt + 1))
            if [ "$attempt" -ge 30 ]; then
                echo 'tab-numbers: server not ready; reload config to retry'
                exit 1
            fi
            sleep 0.2
        done
        # Replace the shell so takeover signals reach rex, not a retry wrapper.
        exec "$rex" --autostart=false do "$1" --all
    ]],
    "rex-tab-numbers",
    config_home .. "/rex/extensions/tab-numbers/watcher.lua", state_home .. "/rex",
}, {
    detach = true,
    stdout = false,
    stderr = false,
    -- Watch the local server, not an inherited terminal/session target.
    env = { REX_SERVER = false, REX_SESSION = false, REX_BLOCK = false, REX_CLIENT = false },
})
if not watcher then
    rex.log("error", "Unable to start tab numbering: " .. tostring(watcher_error))
end
