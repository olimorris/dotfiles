require("config.util")
require("config.options")

vim.pack.add({
  -- Dependencies
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },

  -- Colorscheme
  { src = "file:///Users/Oli/Code/Neovim/onedarkpro.nvim" },

  -- Coding plugins
  { src = "file:///Users/Oli/Code/Neovim/codecompanion.nvim" },
  { src = "https://github.com/j-hui/fidget.nvim" },
  { src = "https://github.com/echasnovski/mini.test" },
  { src = "https://github.com/echasnovski/mini.diff" },
  { src = "https://github.com/folke/ts-comments.nvim" },
  { src = "https://github.com/kylechui/nvim-surround" },
  { src = "https://github.com/zbirenbaum/copilot.lua" },
})

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

-- Copilot.lua
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
vim.cmd([[!OneDarkProExtras]])

require("config.functions")
require("config.autocmds")
require("config.commands")
require("config.keymaps")
require("util")
