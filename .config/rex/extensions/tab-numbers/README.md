# Tab Numbers for Rex

A local Lua add-on for macOS. Numbers real tab titles (`1: editor`) in each
session's tab order, matching indexed tab shortcuts. This is not a native Rex
extension format: a config module launches a separate event-driven `rex do`
watcher. No tab polling or additional Lua packages are needed.

## Install

Place this directory at `~/.config/rex/extensions/tab-numbers/` (or under
`$XDG_CONFIG_HOME/rex/`) and add to your Rex `init.lua`:

```lua
require("extensions.tab-numbers")
```

Then run `rex config reload`. Every config load, including `rex config check`,
launches a replacement watcher. The launcher briefly waits for the local server
to become reachable at startup; it does not start a missing server itself.

The launcher defaults to Rex's macOS app-managed binary location. To override
it, set `REX_TAB_NUMBERS_BIN` to an executable path in the **server's environment**.
Requires macOS `/usr/bin/shlock`, `/bin/ps`, and `/bin/kill`.

## Manual use

```sh
rex do ~/.config/rex/extensions/tab-numbers/watcher.lua --all
```

A new invocation verifies the existing watcher's saved PID, UID, process start
time, and full command before sending SIGTERM. It waits up to five seconds to
claim the lock, then resumes from saved title ownership. Concurrent takeovers
are guarded; an overlapping attempt may exit with a request to retry. An
unverifiable owner is never signalled: stop it manually, then retry. PID-based
signalling still has an unavoidable small exit/PID-reuse race.

Ctrl+C stops a manually started watcher but leaves numbered titles. To restore
titles and stop the watcher:

```sh
rex do ~/.config/rex/extensions/tab-numbers/watcher.lua --all mode=remove
```

To disable permanently, remove the `require` line **before** invoking remove.
Otherwise the next config load starts numbering again.

## Behavior and state

- Handles tab creation, closure (including shell exits), reordering, renaming,
  and new sessions through Rex events.
- Changes real tab labels, including labels shown in the API and sidebar.
- Manual renames become new originals. Enter a plain title without the displayed
  prefix; literal numeric text is preserved rather than guessed away.
- Long titles are truncated for display to fit Rex's 128-character limit;
  their full originals remain saved for restoration.
- State: `$XDG_STATE_HOME/rex/tab-numbers/`, default `~/.local/state/rex/tab-numbers/`.
  Keep state files to avoid losing ownership of existing numeric prefixes.
- Ownership lives in `<host-id>-<scope>.json` and survives Rex native persistence
  restores. Locks remain per-instance. Restored tabs keep a single managed prefix;
  tab order changes update it without modifying the underlying title.
- Legacy per-instance JSON files are read, not changed. Existing doubled prefixes
  are repaired only when exact session/window IDs and saved applied labels prove
  ownership across generations. Literal numeric titles/manual renames remain
  intact. Without ownership records, the watcher does not guess what to strip.
- For multiple servers on one host, set a distinct `REX_TAB_NUMBERS_SCOPE` in each
  server environment (default `local`; letters, digits, underscores, hyphens).
- Launcher output: `~/.local/state/rex/tab-numbers.log` (respects `XDG_STATE_HOME`).
  This append-only log is not automatically rotated.
- The module assumes installation under the standard Rex config directory,
  even when loading a different config through `REX_CONFIG`.

## Tests

From the dotfiles repository root:

```sh
luajit .config/rex/extensions/tab-numbers/test.lua
```

Standard Lua works too. Tests mock Rex and the filesystem; they do not modify
live sessions.
