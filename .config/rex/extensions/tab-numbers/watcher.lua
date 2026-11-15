-- Run: rex do ~/.config/rex/extensions/tab-numbers/watcher.lua --all
-- Restore owned titles and exit: same command with mode=remove
-- Requires macOS's /usr/bin/shlock. No polling or init.lua changes needed.
-- A new invocation replaces the watcher for the same server and local user.
-- Ctrl+C stops updates but leaves numbers; restarting safely resumes them.
-- mode=remove also replaces the watcher. State lives in ~/.local/state/rex/
-- (or $XDG_STATE_HOME/rex/). Keep it to recognize plugin-owned prefixes.
-- Title ownership survives native restores; watcher locks remain per-instance.

local function checked(value, err)
    if value == nil then error(err or "Rex call failed", 0) end
    return value
end

local mode = (rex.args or {}).mode or "watch"
if mode ~= "watch" and mode ~= "remove" then
    error("tab-numbers: mode must be watch or remove", 0)
end

local server = checked(rex.call("server.status", {}))
local function safe_id(value)
    assert(type(value) == "string" and value:match("^[%w_-]+$"), "Invalid server identity")
    return value
end

local home = assert(os.getenv("HOME"), "HOME is not set")
local root = (os.getenv("XDG_STATE_HOME") or (home .. "/.local/state")) .. "/rex/tab-numbers"
local function command(argv)
    local result = checked(rex.exec(argv))
    if not result.ok then error("tab-numbers: " .. (result.stderr or "command failed"), 0) end
    return result.stdout
end
command({ "/bin/mkdir", "-p", root })

-- exec's child shell reports its parent: the rex do process, not the server.
-- shlock atomically claims the file and reclaims locks whose PID has exited.
-- We deliberately leave the lock file behind: even SIGKILL is recoverable.
local pid = command({ "/bin/sh", "-c", "echo \"$PPID\"" }):match("^%s*(%d+)%s*$")
assert(pid, "Could not determine the rex do PID")
local lock = root .. "/" .. safe_id(server.instance_id) .. ".lock"
local owner_path = lock .. ".owner.json"
local function read_text(path)
    local input = io.open(path, "r")
    if not input then return nil end
    local text = input:read("*a")
    input:close()
    return text
end

local function process_identity(process_pid)
    local result = checked(rex.exec({
        "/bin/ps", "-ww", "-p", process_pid, "-o", "uid=,lstart=,command=",
    }))
    if not result.ok or not result.stdout:match("%S") then return nil end
    return result.stdout
end

local function claim(path)
    return checked(rex.exec({ "/usr/bin/shlock", "-p", pid, "-f", path })).ok
end

-- Serialize takeovers too: two simultaneous replacements must not both signal
-- the old owner or load its state while it is still writing. This short-lived
-- guard is separate from the watcher lock; stale guards are reclaimed by PID.
local guard = lock .. ".takeover"
if not claim(guard) then
    error("tab-numbers: another takeover is in progress (or lock unavailable); retry shortly", 0)
end
local acquired, acquire_error = pcall(function()
    if not claim(lock) then
        local old_pid = (read_text(lock) or ""):match("^%s*(%d+)%s*$")
        local owner_text = read_text(owner_path)
        local owner = owner_text and rex.json.decode(owner_text)
        -- PID alone is unsafe: it may belong to an unrelated process now.
        -- Compare UID, process start time, and full command with the identity
        -- recorded by the owner. Never signal an unverified/legacy watcher.
        if not old_pid or old_pid == pid or type(owner) ~= "table"
            or owner.pid ~= old_pid or type(owner.identity) ~= "string"
            or process_identity(old_pid) ~= owner.identity then
            error("tab-numbers: cannot verify existing watcher; stop it manually once, then retry", 0)
        end
        -- Recheck both the lock and identity immediately before signalling.
        -- As with any POSIX PID-based signal, a tiny exit/PID-reuse race remains.
        if (read_text(lock) or ""):match("^%s*(%d+)%s*$") ~= old_pid
            or process_identity(old_pid) ~= owner.identity then
            error("tab-numbers: watcher changed during takeover; retry", 0)
        end
        local stopped = checked(rex.exec({ "/bin/kill", "-TERM", old_pid }))
        if not stopped.ok and process_identity(old_pid) == owner.identity then
            error("tab-numbers: could not stop existing watcher: " .. (stopped.stderr or ""), 0)
        end
        local claimed = false
        for _ = 1, 50 do
            if claim(lock) then claimed = true; break end
            rex.sleep(0.1)
        end
        if not claimed then
            error("tab-numbers: existing watcher did not release its lock within 5 seconds", 0)
        end
        rex.log("info", "tab-numbers: replaced watcher " .. old_pid)
    end
    local identity = assert(process_identity(pid), "Cannot determine watcher process identity")
    local output = checked(io.open(owner_path .. ".tmp", "w"))
    checked(output:write(checked(rex.json.encode({ pid = pid, identity = identity }))))
    checked(output:close())
    checked(os.rename(owner_path .. ".tmp", owner_path))
end)
local released, release_error = os.remove(guard)
if not acquired then error(acquire_error, 0) end
checked(released, release_error)

-- Native restore retains session/window IDs and their displayed labels. Keep
-- ownership across instances, scoped by host and explicit local-server scope.
local scope = safe_id(os.getenv("REX_TAB_NUMBERS_SCOPE") or "local")
local path = root .. "/" .. safe_id(server.host_id) .. "-" .. scope .. ".json"
local state = { sessions = {} }
local file, open_error = io.open(path, "r")
if file then
    local text = file:read("*a")
    file:close()
    state = checked(rex.json.decode(text))
    assert(type(state) == "table" and type(state.sessions) == "table", "Invalid tab-numbers state")
else
    -- Rex's Lua returns a generic status (1), not POSIX errno (2 for ENOENT).
    -- Check absence explicitly, preserving errors for unreadable existing files
    -- and dangling symlinks. Paths are positional arguments, never shell code.
    local missing = checked(rex.exec({
        "/bin/sh", "-c",
        'test -r "$2" && test -x "$2" && ! { test -e "$1" || test -L "$1"; }',
        "tab-numbers", path, root,
    }))
    if not missing.ok then error(open_error or "Cannot read tab-numbers state", 0) end
end

state.panes = state.panes or {}

-- Import legacy per-instance ownership without modifying its recovery files.
-- Exact session/window IDs AND applied labels are required; numeric syntax is
-- never evidence of ownership. Multiple generations may contain stacked labels.
local history = { state.sessions }
local listing = command({ "/usr/bin/find", root, "-maxdepth", "1", "-type", "f", "-name", "*.json" })
for legacy_path in listing:gmatch("[^\r\n]+") do
    local name = legacy_path:match("/([^/]+)%.json$")
    if name and (name == server.instance_id or (#name == 36 and name:match("^[%x-]+$"))) then
        local text = assert(read_text(legacy_path), "Cannot read legacy ownership")
        local legacy = checked(rex.json.decode(text))
        assert(type(legacy.sessions) == "table", "Invalid legacy tab-numbers state")
        history[#history + 1] = legacy.sessions
    end
end

local function original_title(session_id, window_id, label)
    local seen = {}
    while not seen[label] do
        seen[label] = true
        local original
        for _, sessions in ipairs(history) do
            local record = (sessions[session_id] or {})[window_id]
            if record and record.applied == label and record.original ~= label then
                assert(type(record.original) == "string", "Invalid original title")
                if original and original ~= record.original then
                    error("tab-numbers: conflicting title ownership; state preserved", 0)
                end
                original = record.original
            end
        end
        if not original then return label end
        label = original
    end
    error("tab-numbers: cyclic title ownership; state preserved", 0)
end

local function save()
    local output = checked(io.open(path .. ".tmp", "w"))
    checked(output:write(checked(rex.json.encode(state)) .. "\n"))
    checked(output:close())
    checked(os.rename(path .. ".tmp", path))
end

-- Rex limits labels to 128 Unicode characters, not 128 bytes. Keep the full
-- original in state even if adding a prefix requires truncating its display.
local function shorten(text, limit)
    local count = 0
    for index = 1, #text do
        local byte = text:byte(index)
        if byte < 128 or byte >= 192 then
            count = count + 1
            if count > limit then return text:sub(1, index - 1) end
        end
    end
    return text
end

local shells = { fish = true, zsh = true, bash = true, sh = true }
local pretty_names = { claude = "Claude", codex = "Codex" }

-- Fish-style: ~/.dotfiles/.config/rex becomes ~/.d/.c/rex
local function short_path(dir)
    dir = dir:gsub("^" .. home:gsub("%p", "%%%0"), "~")
    local parts = {}
    for part in dir:gmatch("[^/]+") do parts[#parts + 1] = part end
    for index = 1, #parts - 1 do
        if parts[index] ~= "~" then parts[index] = parts[index]:match("^%.?[^.]") end
    end
    return (dir:sub(1, 1) == "/" and "/" or "") .. table.concat(parts, "/")
end

-- Without this, opening a floater such as lazygit retitles the tab to "rex"
local function title_block(window)
    local first_tiled
    for _, layer in ipairs(window.layers or {}) do
        if layer.kind == "tiled" then
            for _, block in ipairs(layer.blocks or {}) do
                if block.block_id == window.focused_block_id then return block.block_id end
                first_tiled = first_tiled or block.block_id
            end
        end
    end
    return first_tiled or window.focused_block_id
end

-- A custom label hides the app's own "program + directory" title, so rebuild that title here
local function block_title(session_id, block_id)
    local result = block_id and rex.call("com.superlogical.terminal.process", {
        session_id = session_id, block_id = block_id, args = {},
    })
    local process = result and result.foreground
    if not process then return nil end
    local program = ((process.argv0 or process.name or ""):match("([^/]+)$") or ""):gsub("^%-", "")
    local dir = process.cwd and short_path(process.cwd)
    if shells[program] or program == "" then return dir end
    program = pretty_names[program] or program
    return dir and (program .. " " .. dir) or program
end

local function is_default_label(window_id, label)
    return label == "" or label == "Window " .. window_id:sub(-8)
end

local default_pane_labels = { [""] = true, shell = true }

-- Without this, the sidebar lists every pane as "shell"; a pane you rename yourself is left alone
local function sync_panes(session_id, windows)
    local records = state.panes[session_id] or {}
    state.panes[session_id] = records
    local live = {}
    for _, window in ipairs(windows) do
        for _, layer in ipairs(window.layers or {}) do
            for _, block in ipairs(layer.blocks or {}) do
                local id, label = block.block_id, block.label or ""
                live[id] = true
                local previous = records[id]
                local original = previous and previous.applied == label and previous.original or label
                local desired = original
                if mode ~= "remove" and default_pane_labels[original] then
                    desired = block_title(session_id, id) or original
                end
                desired = shorten(desired, 128):gsub("%s+$", "")
                if desired ~= label then
                    records[id] = { original = original, applied = desired }
                    save()
                    local result, err = rex.session.set_block_label{
                        session_id = session_id, block_id = id, label = desired,
                    }
                    if not result then
                        records[id] = previous
                        save()
                        error(err, 0)
                    end
                end
                records[id] = mode ~= "remove" and { original = original, applied = desired } or nil
            end
        end
    end
    for id in pairs(records) do
        if not live[id] then records[id] = nil end
    end
    if mode == "remove" then state.panes[session_id] = nil end
end

local attached = {}
local function sync(session_id, offset)
    -- --all receives server events, but some Rex versions still require an
    -- explicit attachment before session-scoped API calls are accepted.
    if not attached[session_id] then
        checked(rex.session.attach{ session_id = session_id })
        attached[session_id] = true
    end
    local view = checked(rex.session.view{ session_id = session_id })
    local records = state.sessions[session_id] or {}
    state.sessions[session_id] = records
    local live = {}
    for index, window in ipairs(view.windows or {}) do
        local id, label = window.window_id, window.label or ""
        live[id] = true
        local previous = records[id]
        -- Never strip arbitrary numeric text or an unrecognized manual rename.
        local original = original_title(session_id, id, label)
        if is_default_label(id, original) then original = "" end
        local title = original ~= "" and original or block_title(session_id, title_block(window)) or ("Window " .. id:sub(-8))
        local prefix = tostring(offset + index) .. ": "
        local desired = mode == "remove" and original or prefix .. shorten(title, 128 - #prefix)
        -- Rex trims labels; record the exact value it will store, including
        -- when truncation lands on whitespace in the middle of a long title.
        desired = desired:gsub("%s+$", "")
        if desired ~= label then
            -- Write intent first. If interrupted after the rename, a restart
            -- still recognizes it; if it never happened, the old label wins.
            records[id] = { original = original, applied = desired }
            save()
            local result, err = rex.session.set_window_label{
                session_id = session_id, window_id = id, label = desired,
            }
            if not result then
                records[id] = previous
                save()
                error(err, 0)
            end
        end
        records[id] = mode ~= "remove" and { original = original, applied = desired } or nil
    end
    for id in pairs(records) do
        if not live[id] then records[id] = nil end
    end
    if mode == "remove" then state.sessions[session_id] = nil end
    sync_panes(session_id, view.windows or {})
    save()
    return #(view.windows or {})
end

-- Numbers run on across sessions in session.list order, so a change in one session renumbers the ones after it
local function sync_all()
    local sessions = checked(rex.call("session.list", {})).sessions or {}
    local live = {}
    local offset = 0
    for _, session in ipairs(sessions) do
        live[session.session_id] = true
        offset = offset + sync(session.session_id, offset)
    end
    for id in pairs(state.sessions) do
        if not live[id] then state.sessions[id] = nil end
    end
    for id in pairs(state.panes) do
        if not live[id] then state.panes[id] = nil end
    end
    save()
end

if mode == "watch" then
    -- Register before the initial snapshot so startup cannot miss a change.
    -- Layout changes include creates, closes (including shell exits), moves,
    -- and renames. Our own renames emit this too, but unchanged labels are no-ops.
    rex.on("session_view_changed", sync_all)
    rex.on("session_created", sync_all)
    rex.on("terminal.title_changed", sync_all)
    rex.on("session_destroyed", function(_, ev)
        attached[ev.session_id] = nil
        state.sessions[ev.session_id] = nil
        state.panes[ev.session_id] = nil
        sync_all()
    end)
end

sync_all()
rex.log("info", mode == "remove" and "tab-numbers: original titles restored"
    or "tab-numbers: watching; Ctrl+C stops updates (leaves numbered titles)")
