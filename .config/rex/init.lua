local label = require("session-label")

require("rex-worktrunk").setup({ base = "@", force_delete = true, label = label })
require("rex-sessionizer").setup({ script = "~/.config/rex/zoxide-picker.sh", label = label })

rex.bind("ctrl+w", "sessionizer")

rex.bind("ctrl+v>ctrl+v", "pane.send_key", { key = "ctrl+v" })

rex.bind("ctrl+v>shift+g", "worktree")
rex.bind("ctrl+v>shift+x", "worktree_remove")
