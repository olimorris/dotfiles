local M = {}
local has_plugin = pcall(cmd, 'packadd nvim-treesitter')

function M.config()
    if not has_plugin then
        do
            return
        end
    end

    cmd 'packadd nvim-treesitter'

    require('nvim-treesitter.configs').setup {
        ensure_installed = 'maintained',
        ignore_install = { "comment" },
        highlight = {enable = true},
        indent = {enable = true},
        incremental_selection = {
            enable = true,
            disable = {},
            keymaps = { -- mappings for incremental selection (visual mappings)
                init_selection = "gnn", -- maps in normal mode to init the node/scope selection
                node_incremental = "grn", -- increment to the upper named parent
                scope_incremental = "grc", -- increment to the upper scope (as defined in locals.scm)
                node_decremental = "grm" -- decrement to the previous node
            }
        },
        -- nvim-autopairs plugin
        autopairs = {enable = true},

        -- nvim-ts-autotag plugin
        autotag = {enable = true},

        -- nvim-ts-context-commentstring plugin
        context_commentstring = {enable = true},

        refactor = {
            highlight_definitions = {
                enable = false
            },
            highlight_current_scope = {
                enable = false
            },
            navigation = {
                enable = true,
                keymaps = {
                    goto_definition = "gnd", -- mapping to go to definition of symbol under cursor
                    list_definitions = "gnD", -- mapping to list all definitions in current file
                    list_definitions_toc = "gO",
                    goto_next_usage = "<a-*>",
                    goto_previous_usage = "<a-#>",
                }
            }
        },
        textobjects = { -- syntax-aware textobjects
            select = {
                enable = true,
                disable = {},
                keymaps = {
                    -- You can use the capture groups defined in textobjects.scm
                    ["af"] = "@function.outer",
                    ["if"] = "@function.inner",
                    ["aC"] = "@class.outer",
                    ["iC"] = "@class.inner",
                    ["ac"] = "@conditional.outer",
                    ["ic"] = "@conditional.inner",
                    ["ae"] = "@block.outer",
                    ["ie"] = "@block.inner",
                    ["al"] = "@loop.outer",
                    ["il"] = "@loop.inner",
                    ["is"] = "@statement.inner",
                    ["as"] = "@statement.outer",
                    ["am"] = "@call.outer",
                    ["im"] = "@call.inner",
                    ["ad"] = "@comment.outer",
                    ["id"] = "@comment.inner",
                    -- Or you can define your own textobjects like this
                    -- [[
                    ["iF"] = {
                        python = "(function_definition) @function",
                        cpp = "(function_definition) @function",
                        c = "(function_definition) @function",
                        java = "(method_declaration) @function"
                    }
                    -- ]]
                }
            },
            swap = {
                enable = true,
                swap_next = {
                    ["<Leader>s"] = "@parameter.inner"
                },
                swap_previous = {
                    ["<Leader>S"] = "@parameter.inner"
                }
            }
        }
    }

end

return M
