require("codecompanion").setup({
  adapters = {
    http = {
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
          env = {
            api_key = "cmd:op read op://personal/OpenAI_API/credential --no-newline",
          },
        })
      end,
      openai_responses = function()
        return require("codecompanion.adapters").extend("openai_responses", {
          env = {
            api_key = "cmd:op read op://personal/OpenAI_API/credential --no-newline",
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
    },
    acp = {
      gemini_cli = function()
        return require("codecompanion.adapters").extend("gemini_cli", {
          defaults = {
            auth_method = "gemini-api-key", -- One of: "gemini-api-key" | "oauth-personal" | | "vertex-ai"
          },
          env = {
            GEMINI_API_KEY = "cmd:op read op://personal/Gemini_API/credential --no-newline",
          },
        })
      end,
      codex = function()
        return require("codecompanion.adapters").extend("codex", {
          env = {
            OPENAI_API_KEY = "cmd:op read op://personal/OpenAI_API/credential --no-newline",
          },
        })
      end,
      claude_code = function()
        return require("codecompanion.adapters").extend("claude_code", {
          env = {
            CLAUDE_CODE_OAUTH_TOKEN = "cmd:op read op://personal/Claude_Code_OAuth/credential --no-newline",
          },
        })
      end,
    },
  },
  prompt_library = {
    markdown = {
      dirs = {
        vim.fn.getcwd() .. "/.prompts",
        "~/.dotfiles/.config/prompts",
      },
    },
  },
  strategies = {
    chat = {
      adapter = {
        name = "copilot",
        model = "claude-haiku-4.5",
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
      },
      slash_commands = {
        ["image"] = {
          opts = {
            dirs = { "~/Documents/Screenshots" },
          },
        },
      },
      tools = {
        ["math"] = {
          description = "Calculate mathematical expressions, derivatives, integrals, and solve equations.",
          callback = "~/.dotfiles/.config/nvim-new/plugin/ai/tools/math.lua",
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
      -- show_settings = true,
      show_reasoning = false,
      fold_context = true,
    },
  },
  rules = {
    opts = {
      chat = {
        enabled = true,
      },
    },
  },
  opts = {
    language = "British English",
    log_level = "DEBUG",
  },
})
vim.cmd([[cab cc CodeCompanion]])

local spinner = {
  completed = "󰗡 Completed",
  error = " Error",
  cancelled = "󰜺 Cancelled",
}

---Format the adapter name and model for display with the spinner
---@param adapter CodeCompanion.Adapter
---@return string
local function format_adapter(adapter)
  local parts = {}
  table.insert(parts, adapter.formatted_name)
  if adapter.model and adapter.model ~= "" then
    table.insert(parts, "(" .. adapter.model .. ")")
  end
  return table.concat(parts, " ")
end

---Setup the spinner for CodeCompanion
---@return nil
local function codecompanion_spinner()
  local ok, progress = pcall(require, "fidget.progress")
  if not ok then
    return
  end

  spinner.handles = {}

  local group = vim.api.nvim_create_augroup("dotfiles.codecompanion.spinner", {})

  vim.api.nvim_create_autocmd("User", {
    pattern = "CodeCompanionRequestStarted",
    group = group,
    callback = function(args)
      local handle = progress.handle.create({
        title = "",
        message = "  Sending...",
        lsp_client = {
          name = format_adapter(args.data.adapter),
        },
      })
      spinner.handles[args.data.id] = handle
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "CodeCompanionRequestFinished",
    group = group,
    callback = function(args)
      local handle = spinner.handles[args.data.id]
      spinner.handles[args.data.id] = nil
      if handle then
        if args.data.status == "success" then
          handle.message = spinner.completed
        elseif args.data.status == "error" then
          handle.message = spinner.error
        else
          handle.message = spinner.cancelled
        end
        handle:finish()
      end
    end,
  })
end

codecompanion_spinner()
