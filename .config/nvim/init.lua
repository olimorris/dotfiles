--=============================================================================
-- Set the stuff that must come before anything else
--=============================================================================
require("config.utils")
require("config.options")

--=============================================================================
-- Plugins
--=============================================================================
vim.pack.add({
  -- Dependencies
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/kevinhwang91/promise-async" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },

  -- Tree-sitter should come high up

  -- Followed by LSP and completion

  -- Colorscheme
  { src = "file:///Users/Oli/Code/Neovim/onedarkpro.nvim" },

  -- Coding plugins
  { src = "https://github.com/j-hui/fidget.nvim" },
  { src = "https://github.com/echasnovski/mini.test" },
  { src = "https://github.com/echasnovski/mini.diff" },
  { src = "https://github.com/kylechui/nvim-surround" },
  { src = "https://github.com/zbirenbaum/copilot.lua" },
  { src = "file:///Users/Oli/Code/Neovim/codecompanion.nvim" },

  -- Editor functionality
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/kevinhwang91/nvim-bqf" },
  { src = "https://github.com/kevinhwang91/nvim-ufo" },
  { src = "https://github.com/stevearc/aerial.nvim" },
  { src = "https://github.com/bassamsdata/namu.nvim" },
  { src = "https://github.com/folke/todo-comments.nvim" },
  { src = "file:///Users/Oli/Code/Neovim/persisted.nvim" },

  -- UI
  { src = "https://github.com/folke/edgy.nvim" },
  { src = "https://github.com/folke/snacks.nvim" },
  { src = "https://github.com/rebelot/heirline.nvim" },
  { src = "https://github.com/lewis6991/gitsigns.nvim" },
  { src = "https://github.com/nmac427/guess-indent.nvim" },
  { src = "https://github.com/lukas-reineke/virt-column.nvim" },
  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
})

--=============================================================================
-- Plugin Configuration
--=============================================================================

local opts = { noremap = true, silent = true }

-- CodeCompanion.nvim
require("codecompanion").setup({
  adapters = {
    anthropic = function()
      return require("codecompanion.adapters").extend("anthropic", {
        env = {
          api_key = "cmd:op read op://personal/Anthropic_API/credential --no-newline",
        },
        schema = {
          extended_thinking = {
            default = true,
          },
        },
      })
    end,
    deepseek = function()
      return require("codecompanion.adapters").extend("deepseek", {
        env = {
          api_key = "cmd:op read op://personal/DeepSeek_API/credential --no-newline",
        },
      })
    end,
    gemini = function()
      return require("codecompanion.adapters").extend("gemini", {
        env = {
          api_key = "cmd:op read op://personal/Gemini_API/credential --no-newline",
        },
      })
    end,
    mistral = function()
      return require("codecompanion.adapters").extend("mistral", {
        env = {
          api_key = "cmd:op read op://personal/Mistral_API/credential --no-newline",
        },
      })
    end,
    novita = function()
      return require("codecompanion.adapters").extend("novita", {
        env = {
          api_key = "cmd:op read op://personal/Novita_API/credential --no-newline",
        },
        schema = {
          model = {
            default = function()
              return "qwen/qwen3-coder-480b-a35b-instruct"
            end,
          },
        },
      })
    end,
    ollama = function()
      return require("codecompanion.adapters").extend("ollama", {
        schema = {
          model = {
            default = "qwen3:latest",
          },
          num_ctx = {
            default = 20000,
          },
        },
      })
    end,
    openai = function()
      return require("codecompanion.adapters").extend("openai", {
        opts = {
          stream = true,
        },
        env = {
          api_key = "cmd:op read op://personal/OpenAI_API/credential --no-newline",
        },
        schema = {
          model = {
            default = function()
              return "gpt-4.1"
            end,
          },
        },
      })
    end,
    xai = function()
      return require("codecompanion.adapters").extend("xai", {
        env = {
          api_key = "cmd:op read op://personal/xAI_API/credential --no-newline",
        },
      })
    end,
    tavily = function()
      return require("codecompanion.adapters").extend("tavily", {
        env = {
          api_key = "cmd:op read op://personal/Tavily_API/credential --no-newline",
        },
      })
    end,
    acp = {
      codex = function()
        return require("codecompanion.adapters").extend("codex", {
          command = {
            "cargo",
            "run",
            "--bin",
            "codex",
            "--manifest-path",
            "${manifest_path}",
            "mcp",
          },
          env = {
            -- api_key = "cmd:op read op://personal/OpenAI_API/credential --no-newline",
            manifest_path = "/Users/Oli/Code/Neovim/codex/codex-rs/Cargo.toml",
          },
        })
      end,
      gemini_cli = function()
        return require("codecompanion.adapters").extend("gemini_cli", {
          command = {
            "node",
            "/Users/Oli/Code/Neovim/gemini-cli/packages/cli",
            "--experimental-acp",
          },
          env = {
            GEMINI_API_KEY = "cmd:op read op://personal/Gemini_API/credential --no-newline",
          },
        })
      end,
    },
  },
  prompt_library = {
    ["Maths tutor"] = {
      strategy = "chat",
      description = "Chat with your personal maths tutor",
      opts = {
        index = 4,
        ignore_system_prompt = true,
        intro_message = "Welcome to your lesson! How may I help you today? ",
      },
      prompts = {
        {
          role = "system",
          content = [[You are a helpful maths tutor.
You can explain concepts, solve problems, and provide step-by-step solutions for maths.
The user asking the questions has an MPhys in Physics, is knowledgeable in maths, but is out of practice.
The user is an experienced programmer, so you can relate maths concepts to programming ones.
If the user asks you about a topic respond with:
1. A brief explanation of the topic
2. A definition
3. A simple example and a more complex example
4. A programming analogy or example
5. A summary of the topic
6. A question to the user to check their understanding

You must:
- Not use H1 or H2 headings. Only H3 headings and above
- Always show your work and explain each step clearly
- Relate Math concepts to programming terms where applicable
- Use KaTeX for any mathematical notation (as the user works with the Notion app and Anki for flashcards)
- Ensure that any inline KaTeX is within $$ delimiters (e.g. $x^2 + y^2 = z^2$) so it can be pasted into Notion or Anki
- For any math blocks, do NOT use $$ delimiters, just use the math block syntax (e.g. \[ x^2 + y^2 = z^2 \])
- Use Python for coding examples]],
        },
      },
    },
    ["Test workflow"] = {
      strategy = "workflow",
      description = "Use a workflow to test the plugin",
      opts = {
        index = 4,
      },
      prompts = {
        {
          {
            role = "user",
            content = "Generate a Python class for managing a book library with methods for adding, removing, and searching books",
            opts = {
              auto_submit = false,
            },
          },
        },
        {
          {
            role = "user",
            content = "Write unit tests for the library class you just created",
            opts = {
              auto_submit = true,
            },
          },
        },
        {
          {
            role = "user",
            content = "Create a TypeScript interface for a complex e-commerce shopping cart system",
            opts = {
              auto_submit = true,
            },
          },
        },
        {
          {
            role = "user",
            content = "Write a recursive algorithm to balance a binary search tree in Java",
            opts = {
              auto_submit = true,
            },
          },
        },
        {
          {
            role = "user",
            content = "Generate a comprehensive regex pattern to validate email addresses with explanations",
            opts = {
              auto_submit = true,
            },
          },
        },
        {
          {
            role = "user",
            content = "Create a Rust struct and implementation for a thread-safe message queue",
            opts = {
              auto_submit = true,
            },
          },
        },
        {
          {
            role = "user",
            content = "Write a GitHub Actions workflow file for CI/CD with multiple stages",
            opts = {
              auto_submit = true,
            },
          },
        },
        {
          {
            role = "user",
            content = "Create SQL queries for a complex database schema with joins across 4 tables",
            opts = {
              auto_submit = true,
            },
          },
        },
        {
          {
            role = "user",
            content = "Write a Lua configuration for Neovim with custom keybindings and plugins",
            opts = {
              auto_submit = true,
            },
          },
        },
        {
          {
            role = "user",
            content = "Generate documentation in JSDoc format for a complex JavaScript API client",
            opts = {
              auto_submit = true,
            },
          },
        },
      },
    },
  },
  strategies = {
    chat = {
      adapter = {
        name = "copilot",
        model = "gpt-4.1",
      },
      roles = {
        user = "olimorris",
      },
      keymaps = {
        send = {
          modes = {
            i = { "<C-CR>", "<C-s>" },
          },
        },
        completion = {
          modes = {
            i = "<C-x>",
          },
        },
      },
      slash_commands = {
        ["buffer"] = {
          keymaps = {
            modes = {
              i = "<C-b>",
            },
          },
        },
        ["fetch"] = {
          keymaps = {
            modes = {
              i = "<C-f>",
            },
          },
        },
        ["help"] = {
          opts = {
            max_lines = 1000,
          },
        },
        ["image"] = {
          keymaps = {
            modes = {
              i = "<C-i>",
            },
          },
          opts = {
            dirs = { "~/Documents/Screenshots" },
          },
        },
      },
    },
    inline = {
      adapter = {
        name = "copilot",
        model = "gpt-4.1",
      },
    },
  },
  display = {
    action_palette = {
      provider = "default",
    },
    chat = {
      -- show_references = true,
      -- show_header_separator = false,
      -- show_settings = false,
      icons = {
        tool_success = "󰸞 ",
      },
      fold_context = true,
    },
    diff = {
      provider = "mini_diff",
    },
  },
  opts = {
    log_level = "DEBUG",
  },
})
require("plugins.custom.spinner"):init()
om.set_keymaps("<C-a>", "<cmd>CodeCompanionActions<CR>", { "n", "v" }, opts)
om.set_keymaps("<Leader>a", "<cmd>CodeCompanionChat Toggle<CR>", { "n", "v" }, opts)
om.set_keymaps("<LocalLeader>a", "<cmd>CodeCompanionChat Add<CR>", { "v" }, opts)
vim.cmd([[cab cc CodeCompanion]])

require("copilot").setup({
  panel = { enabled = false },
  suggestion = {
    auto_trigger = true, -- Suggest as we start typing
    keymap = {
      accept_word = "<C-l>",
      accept_line = "<C-j>",
    },
  },
})
om.set_keymaps("<C-a>", function()
  require("copilot.suggestion").accept()
end, "i", opts)
om.set_keymaps("<C-x>", function()
  require("copilot.suggestion").dismiss()
end, "i", opts)

-- Mini.diff
local diff = require("mini.diff")
diff.setup({
  -- Disabled by default
  source = diff.gen_source.none(),
})

require("nvim-surround").setup()

-- Heirline.nvim
require("heirline").setup({
  winbar = require("plugins.heirline.winbar"),
  statusline = require("plugins.heirline.statusline"),
  statuscolumn = require("plugins.heirline.statuscolumn"),
  opts = {
    disable_winbar_cb = function(args)
      local conditions = require("heirline.conditions")

      return conditions.buffer_matches({
        buftype = { "nofile", "prompt", "help", "quickfix", "terminal" },
        filetype = { "alpha", "codecompanion", "oil", "lspinfo", "snacks_dashboard", "toggleterm" },
      }, args.buf)
    end,
  },
})

-- OneDarkPro.nvim
require("onedarkpro").setup({
  colors = {
    vaporwave = {
      codeblock = "require('onedarkpro.helpers').lighten('bg', 2, 'vaporwave')",
      statusline_bg = "require('onedarkpro.helpers').lighten('bg', 4, 'vaporwave')", -- gray
      statuscolumn_border = "require('onedarkpro.helpers').lighten('bg', 4, 'vaporwave')", -- gray
      ellipsis = "require('onedarkpro.helpers').lighten('bg', 4, 'vaporwave')", -- gray
      picker_results = "require('onedarkpro.helpers').darken('bg', 4, 'vaporwave')",
      picker_selection = "require('onedarkpro.helpers').darken('bg', 8, 'vaporwave')",
      copilot = "require('onedarkpro.helpers').darken('gray', 8, 'vaporwave')",
      breadcrumbs = "require('onedarkpro.helpers').darken('gray', 10, 'vaporwave')",
      light_gray = "require('onedarkpro.helpers').darken('gray', 7, 'vaporwave')",
    },
    onedark = {
      codeblock = "require('onedarkpro.helpers').lighten('bg', 2, 'onedark')",
      statusline_bg = "#2e323b", -- gray
      statuscolumn_border = "#4b5160", -- gray
      ellipsis = "#808080", -- gray
      picker_results = "require('onedarkpro.helpers').darken('bg', 4, 'onedark')",
      picker_selection = "require('onedarkpro.helpers').darken('bg', 8, 'onedark')",
      copilot = "require('onedarkpro.helpers').darken('gray', 8, 'onedark')",
      breadcrumbs = "require('onedarkpro.helpers').darken('gray', 10, 'onedark')",
      light_gray = "require('onedarkpro.helpers').darken('gray', 7, 'onedark')",
    },
    light = {
      codeblock = "require('onedarkpro.helpers').darken('bg', 3, 'onelight')",
      comment = "#bebebe", -- Revert back to original comment colors
      statusline_bg = "#f0f0f0", -- gray
      statuscolumn_border = "#e7e7e7", -- gray
      ellipsis = "#808080", -- gray
      git_add = "require('onedarkpro.helpers').get_preloaded_colors('onelight').green",
      git_change = "require('onedarkpro.helpers').get_preloaded_colors('onelight').yellow",
      git_delete = "require('onedarkpro.helpers').get_preloaded_colors('onelight').red",
      picker_results = "require('onedarkpro.helpers').darken('bg', 5, 'onelight')",
      picker_selection = "require('onedarkpro.helpers').darken('bg', 9, 'onelight')",
      copilot = "require('onedarkpro.helpers').lighten('gray', 8, 'onelight')",
      breadcrumbs = "require('onedarkpro.helpers').lighten('gray', 8, 'onelight')",
      light_gray = "require('onedarkpro.helpers').lighten('gray', 10, 'onelight')",
    },
    rainbow = {
      "${green}",
      "${blue}",
      "${purple}",
      "${red}",
      "${orange}",
      "${yellow}",
      "${cyan}",
    },
  },
  highlights = {
    CodeCompanionChatIcon = { fg = "${green}" },
    CodeCompanionChatToolFailure = { fg = "${gray}", italic = true },
    CodeCompanionChatToolSuccess = { fg = "${gray}", bg = "NONE", italic = true },
    CodeCompanionTokens = { fg = "${gray}", italic = true },
    CodeCompanionVirtualText = { fg = "${gray}", italic = true },

    ["@markup.raw.block.markdown"] = { bg = "${codeblock}" },
    ["@markup.quote.markdown"] = { italic = true, extend = true },

    EdgyNormal = { bg = "${bg}" },
    EdgyTitle = { fg = "${purple}", bold = true },

    EyelinerPrimary = { fg = "${green}" },
    EyelinerSecondary = { fg = "${blue}" },

    NormalFloat = { bg = "${bg}" }, -- Set the terminal background to be the same as the editor
    FloatBorder = { fg = "${gray}", bg = "${bg}" },

    CursorLineNr = { bg = "${bg}", fg = "${fg}", italic = true },
    MatchParen = { fg = "${cyan}" },
    ModeMsg = { fg = "${gray}" }, -- Make command line text lighter
    Search = { bg = "${selection}", fg = "${yellow}", underline = true },
    VimLogo = { fg = { dark = "#81b766", light = "#029632" } },

    -- Dashboard
    SnacksDashboardDesc = { fg = "${blue}", bold = true },
    SnacksDashboardKey = { fg = "${orange}", bold = true, italic = true },
    SnacksDashboardIcon = { fg = "${blue}" },

    -- Copilot
    CopilotSuggestion = { fg = "${copilot}", italic = true },

    -- DAP
    DebugBreakpoint = { fg = "${red}", italic = true },
    DebugHighlightLine = { fg = "${purple}", italic = true },
    NvimDapVirtualText = { fg = "${cyan}", italic = true },

    -- DAP UI
    DapUIBreakpointsCurrentLine = { fg = "${yellow}", bold = true },

    -- Heirline
    Heirline = { bg = "${statusline_bg}" },
    HeirlineStatusColumn = { fg = "${statuscolumn_border}" },
    HeirlineBufferline = { fg = { dark = "#939aa3", light = "#6a6a6a" } },
    HeirlineWinbar = { fg = "${breadcrumbs}", italic = true },
    HeirlineWinbarEmphasis = { fg = "${fg}", italic = true },

    -- Luasnip
    LuaSnipChoiceNode = { fg = "${yellow}" },
    LuaSnipInsertNode = { fg = "${yellow}" },

    -- Neotest
    NeotestAdapterName = { fg = "${purple}", bold = true },
    NeotestFocused = { bold = true },
    NeotestNamespace = { fg = "${blue}", bold = true },

    -- Nvim UFO
    UfoFoldedEllipsis = { fg = "${yellow}" },

    -- Snacks
    SnacksPicker = { bg = "${picker_results}" },
    SnacksPickerDir = { fg = "${gray}", italic = true },
    SnacksPickerBorder = { fg = "${picker_results}", bg = "${picker_results}" },
    SnacksPickerListCursorLine = { bg = "${picker_selection}" },
    SnacksPickerPrompt = { bg = "${picker_results}", fg = "${purple}", bold = true },
    SnacksPickerSelected = { bg = "${picker_results}", fg = "${orange}" },
    SnacksPickerTitle = { bg = "${purple}", fg = "${picker_results}", bold = true },
    SnacksPickerToggle = { bg = "${purple}", fg = "${picker_results}", italic = true },
    SnacksPickerTotals = { bg = "${picker_results}", fg = "${purple}", bold = true },
    SnacksPickerUnselected = { bg = "${picker_results}" },

    SnacksPickerPreview = { bg = "${bg}" },
    SnacksPickerPreviewBorder = { fg = "${bg}", bg = "${bg}" },
    SnacksPickerPreviewTitle = { bg = "${green}", fg = "${bg}", bold = true },

    -- Virt Column
    VirtColumn = { fg = "${indentline}" },
  },

  caching = false,
  cache_path = vim.fn.expand(vim.fn.stdpath("cache") .. "/onedarkpro_dotfiles"),

  plugins = {
    barbar = false,
    lsp_saga = false,
    marks = false,
    polygot = false,
    startify = false,
    telescope = false,
    trouble = false,
    vim_ultest = false,
    which_key = false,
  },
  styles = {
    tags = "italic",
    methods = "bold",
    functions = "bold",
    keywords = "italic",
    comments = "italic",
    parameters = "italic",
    conditionals = "italic",
    virtual_text = "italic",
  },
  options = {
    cursorline = true,
    -- transparency = true,
    -- highlight_inactive_windows = true,
  },
})
local function change_theme(mode, theme)
  vim.cmd("set background=" .. mode)
  vim.cmd("colorscheme " .. theme)
end
function om.ToggleTheme(mode)
  local themes = {
    dark = "vaporwave",
    light = "onelight",
  }

  if mode then
    change_theme(mode, themes[mode])
  else
    if vim.o.background == "dark" then
      change_theme("light", themes.light)
    else
      change_theme("dark", themes.dark)
    end
  end

  local utils = require("heirline.utils")
  utils.on_colorscheme(require("onedarkpro.helpers").get_colors())
end

require("oil").setup({
  default_file_explorer = false,
  delete_to_trash = true,
  skip_confirm_for_simple_edits = true,
  float = {
    border = "none",
  },
  is_always_hidden = function(name, bufnr)
    return name == ".."
  end,
  keymaps = {
    ["<C-c>"] = false,
    ["q"] = "actions.close",
    [">"] = "actions.toggle_hidden",
    ["<C-y>"] = "actions.copy_entry_path",
    ["gd"] = {
      desc = "Toggle detail view",
      callback = function()
        local oil = require("oil")
        local config = require("oil.config")
        if #config.columns == 1 then
          oil.set_columns({ "icon", "permissions", "size", "mtime" })
        else
          oil.set_columns({ "icon" })
        end
      end,
    },
  },
  buf_options = {
    buflisted = false,
  },
})
om.set_keymaps("_", function()
  require("oil").toggle_float(vim.fn.getcwd())
end, "n", opts)
om.set_keymaps("-", function()
  require("oil").toggle_float()
end, "n", opts)

require("namu").setup({
  namu_symbols = {
    enable = true,
    options = {}, -- here you can configure namu
  },
  ui_select = { enable = false }, -- vim.ui.select() wrapper
})
om.set_keymaps("<C-t>", function()
  require("namu.namu_symbols").show()
end, { "n", "x", "o" }, opts)
om.set_keymaps("<C-e>", function()
  require("namu.namu_workspace").show()
end, { "n", "x", "o" }, opts)

require("todo-comments").setup({
  signs = false,
  highlight = {
    keyword = "bg",
  },
  keywords = {
    FIX = { icon = " " }, -- Custom fix icon
  },
})
om.set_keymaps("<Leader>t", function()
  require("snacks").picker.todo_comments()
end, "n", opts)

require("guess-indent").setup({})
require("render-markdown").setup({
  render_modes = true,
  sign = {
    enabled = false,
  },
  completions = { blink = { enabled = true } },
  overrides = {
    filetype = {
      codecompanion = {
        html = {
          tag = {
            buf = { icon = " ", highlight = "CodeCompanionChatIcon" },
            file = { icon = " ", highlight = "CodeCompanionChatIcon" },
            group = { icon = " ", highlight = "CodeCompanionChatIcon" },
            help = { icon = "󰘥 ", highlight = "CodeCompanionChatIcon" },
            image = { icon = " ", highlight = "CodeCompanionChatIcon" },
            symbols = { icon = " ", highlight = "CodeCompanionChatIcon" },
            tool = { icon = "󰯠 ", highlight = "CodeCompanionChatIcon" },
            url = { icon = "󰌹 ", highlight = "CodeCompanionChatIcon" },
          },
        },
      },
    },
  },
})
require("edgy").setup({
  animate = { enabled = false },
  options = {
    top = { size = 10 },
  },
  bottom = {
    {
      ft = "snacks_terminal",
      size = { height = om.on_big_screen() and 20 or 0.2 },
      title = "Terminal %{b:snacks_terminal.id}",
      filter = function(_buf, win)
        return vim.w[win].snacks_win
          and vim.w[win].snacks_win.position == "bottom"
          and vim.w[win].snacks_win.relative == "editor"
          and not vim.w[win].trouble_preview
      end,
    },
    { ft = "qf", title = "QuickFix" },
    {
      ft = "help",
      size = { height = 20 },
      -- only show help buffers
      filter = function(buf)
        return vim.bo[buf].buftype == "help"
      end,
    },
    { title = "Neotest Output", ft = "neotest-output-panel", size = { height = 15 } },
  },
  right = {
    { ft = "aerial", title = "Symbols", size = { width = 0.3 } },
    { ft = "neotest-summary", title = "Neotest Summary", size = { width = 0.3 } },
    { ft = "oil", title = "File Explorer", size = { width = 0.3 } },
  },
})
require("virt-column").setup({
  char = "│",
  highlight = "VirtColumn",
})
require("gitsigns").setup({
  signs = {
    add = { text = "│" },
    change = { text = "│" },
    delete = { text = "│" },
    topdelete = { text = "│" },
    changedelete = { text = "│" },
    untracked = { text = "│" },
  },
  signs_staged_enable = false,
  numhl = false,
  linehl = false,
})
require("snacks").setup({
  styles = {
    lazygit = {
      width = 0,
      height = 0,
    },
    notification = {
      wo = { wrap = true }, -- Wrap notifications
    },
  },
  bigfile = { enabled = true },
  bufdelete = { enabled = true },
  dashboard = {
    enabled = true,
    preset = {
      keys = {
        { icon = " ", key = "l", desc = "Load Session", action = ":lua require('persisted').load()" },
        { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
        { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
        { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
        { icon = "󱘣 ", key = "s", desc = "Search Files", action = ":lua Snacks.dashboard.pick('live_grep')" },
        { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      },
    },
    sections = {
      {
        section = "terminal",
        cmd = "lolcat --seed=24 ~/.config/nvim/static/neovim.cat",
        indent = -5,
        height = 9,
        width = 69,
        padding = 1,
      },
      {
        section = "keys",
        indent = 1,
        padding = 1,
      },
      -- { section = "startup" },
    },
  },
  image = {
    enabled = true,
    img_dirs = {
      "~/Documents/Screenshots/",
    },
  },
  indent = {
    enabled = true,
    scope = { enabled = false },
  },
  input = { enabled = true },
  lazygit = {
    theme = {
      [241] = { fg = "Special" },
      activeBorderColor = { fg = "String", bold = true },
      cherryPickedCommitBgColor = { fg = "Identifier" },
      cherryPickedCommitFgColor = { fg = "Function" },
      defaultFgColor = { fg = "Normal" },
      inactiveBorderColor = { fg = "FloatBorder" },
      optionsTextColor = { fg = "Function" },
      searchingActiveBorderColor = { fg = "String", bold = true },
      selectedLineBgColor = { bg = "Visual" }, -- set to `default` to have no background colour
      unstagedChangesColor = { fg = "DiagnosticError" },
    },
  },
  picker = {
    prompt = "> ",
    enabled = true,
    win = {
      input = {
        wo = {
          foldcolumn = "0",
        },
        keys = {
          ["<C-q>"] = { "qflist_append", mode = { "n", "i" } },
        },
      },
      list = {
        wo = {
          foldcolumn = "0",
        },
      },
      preview = {
        wo = {
          foldcolumn = "0",
        },
      },
    },
    actions = {
      qflist_append = function(picker)
        picker:close()
        local sel = picker:selected()
        local items = #sel > 0 and sel or picker:items()
        local qf = {}
        for _, item in ipairs(items) do
          qf[#qf + 1] = {
            filename = Snacks.picker.util.path(item),
            bufnr = item.buf,
            lnum = item.pos and item.pos[1] or 1,
            col = item.pos and item.pos[2] + 1 or 1,
            end_lnum = item.end_pos and item.end_pos[1] or nil,
            end_col = item.end_pos and item.end_pos[2] + 1 or nil,
            text = item.line or item.comment or item.label or item.name or item.detail or item.text,
            pattern = item.search,
            valid = true,
          }
        end
        vim.fn.setqflist(qf, "a")
        vim.cmd("botright copen")
      end,
    },
  },
  notifier = { enabled = true },
  terminal = { enabled = true },
})

om.set_keymaps("<C-x>", function()
  Snacks.terminal.toggle()
end, { "n", "t" }, opts)
om.set_keymaps("<C-c>", function()
  Snacks.bufdelete()
end, "n", opts)
om.set_keymaps("<C-f>", function()
  Snacks.picker.files({ hidden = true })
end, "n", opts)
om.set_keymaps("<C-b>", function()
  Snacks.picker.buffers()
end, "n", opts)
om.set_keymaps("<C-g>", function()
  Snacks.picker.grep_buffers()
end, "n", opts)
om.set_keymaps("<Leader>g", function()
  Snacks.picker.grep()
end, "n", opts)
om.set_keymaps("<Leader><Leader>", function()
  Snacks.picker.recent()
end, "n", opts)
om.set_keymaps("<Leader>h", function()
  Snacks.picker.notifications()
end, "n", opts)
om.set_keymaps("<LocalLeader>gb", function()
  Snacks.gitbrowse()
end, "n", opts)
om.set_keymaps("<LocalLeader>u", function()
  Snacks.picker.undo()
end, "n", opts)
om.set_keymaps("<Leader>l", function()
  Snacks.lazygit()
end, "n", opts)
om.set_keymaps("<Esc>", "<C-\\><C-n>", "t", vim.list_extend(opts, { nowait = true }))

require("persisted").setup({
  save_dir = Sessiondir .. "/",
  use_git_branch = true,
  autosave = true,
  -- autoload = true,
  -- allowed_dirs = {
  --   "~/Code",
  -- },
  -- on_autoload_no_session = function()
  --   return vim.notify("No session found", vim.log.levels.WARN)
  -- end,
  should_save = function()
    local excluded_filetypes = {
      "alpha",
      "oil",
      "lazy",
      "",
    }

    for _, filetype in ipairs(excluded_filetypes) do
      if vim.bo.filetype == filetype then
        return false
      end
    end

    return true
  end,
})
om.create_user_command("Sessions", "List Sessions", function()
  require("persisted").select()
end)

--=============================================================================
-- Setup the rest of the config
--=============================================================================
require("utils")
require("config.keymaps")
require("config.autocmds")
require("config.commands")
require("config.functions")
