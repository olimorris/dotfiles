local M = {
    -- "olimorris/persisted.nvim", -- Session management
    dir = "~/Code/Projects/persisted.nvim",
    lazy = true,
}

function M.config()
    require("persisted").setup({
        save_dir = Sessiondir .. "/",
        branch_separator = "@@",
        use_git_branch = true,
        silent = true,
        should_autosave = function()
            if vim.bo.filetype == "alpha" then return false end
            return true
        end,
        telescope = {
            before_source = function()
                vim.api.nvim_input("<ESC>:%bd!<CR>")
                persisted.stop()
            end,
        },
    })

    require("telescope").load_extension("persisted")
end

return M
