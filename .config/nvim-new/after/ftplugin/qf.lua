local ol = vim.opt_local

-- Wrap quickfix window
ol.wrap = true
ol.linebreak = true

vim.cmd.packadd("cfilter")

vim.keymap.set("n", "<CR>", "<Cmd>cc<CR>", { buffer = 0, desc = "Jump to quickfix entry" })
