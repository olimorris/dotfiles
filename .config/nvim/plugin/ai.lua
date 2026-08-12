require("codecompanion").setup({
  adapters = {
    http = {
      extend = {
        anthropic = { env = { api_key = "cmd:op read op://personal/Anthropic_API/credential --no-newline" } },
        deepseek = { env = { api_key = "cmd:op read op://personal/DeepSeek_API/credential --no-newline" } },
        gemini = { env = { api_key = "cmd:op read op://personal/Gemini_API/credential --no-newline" } },
        gemini_interactions = { env = { api_key = "cmd:op read op://personal/Gemini_API/credential --no-newline" } },
        kimi = { env = { api_key = "cmd:op read op://personal/Kimi_API/credential --no-newline" } },
        mistral = { env = { api_key = "cmd:op read op://personal/Mistral_API/credential --no-newline" } },
        openai = { env = { api_key = "cmd:op read op://personal/OpenAI_API/credential --no-newline" } },
        openai_responses = { env = { api_key = "cmd:op read op://personal/OpenAI_API/credential --no-newline" } },
        openrouter = { env = { api_key = "cmd:op read op://personal/OpenRouter_API/credential --no-newline" } },
        xai = { env = { api_key = "cmd:op read op://personal/xAI_API/credential --no-newline" } },
      },
      openrouter_background = function()
        return require("codecompanion.adapters").extend("openrouter", {
          env = { api_key = "OPENROUTER_TITLE_GENERATION_KEY" },
          opts = { session_id = "CodeCompanion_background" },
          schema = {
            ["reasoning.effort"] = {
              enabled = false,
            },
          },
        })
      end,
    },
    acp = {
      claude_code_work = function()
        return require("codecompanion.adapters").extend("claude_code", {
          name = "claude_code_work",
          formatted_name = "Claude Code Work",
          defaults = {
            mcpServers = "inherit_from_config",
          },
          env = {
            CLAUDE_CODE_OAUTH_TOKEN = "cmd:op read op://personal/Claude_Code_OAuth_Work/credential --no-newline",
          },
        })
      end,
      extend = {
        claude_code = {
          defaults = { mcpServers = "inherit_from_config" },
          env = { CLAUDE_CODE_OAUTH_TOKEN = "cmd:op read op://personal/Claude_Code_OAuth/credential --no-newline" },
        },
        codex = {
          env = { OPENAI_API_KEY = "cmd:op read op://personal/OpenAI_API/credential --no-newline" },
        },
        gemini_cli = {
          defaults = { auth_method = "gemini-api-key" },
          env = { GEMINI_API_KEY = "cmd:op read op://personal/Gemini_API/credential --no-newline" },
        },
      },
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
  interactions = {
    background = {
      chat = {
        callbacks = {
          ["on_ready"] = {
            actions = {
              {
                path = "interactions.background.builtin.chat_make_title",
                adapter = {
                  name = "openrouter_background",
                  model = "openai/gpt-oss-120b",
                },
              },
            },
          },
        },
        opts = {
          enabled = true,
        },
      },
      gates = {
        judge = {
          enabled = true,
          adapter = {
            name = "openrouter_background",
            model = "openai/gpt-oss-120b",
          },
          opts = {
            system_prompt = function(default)
              if string.find(vim.fn.getcwd(), "Code/Neovim/codecompanion.nvim") then
                return string.format(
                  [[%s

The following commands are explicitly approved and must always be judged safe, even if they would otherwise fail the guidance above:
  - `make docs`
  - `make format`
  - `make test`
  - `make test_file` (including any `FILE=` argument)]],
                  default
                )
              end
              return default
            end,
          },
        },
      },
    },
    chat = {
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
        ["share"] = {
          opts = {
            token = os.getenv("GITHUB_GIST_TOKEN"),
          },
        },
      },
      tools = {
        ["hledger"] = {
          description = "Execute hledger queries to analyze financial data from journal files",
          path = "~/OliDocs/ff/Finances/hledger.lua",
        },
        ["math"] = {
          description = "Calculate mathematical expressions, derivatives, integrals, and solve equations.",
          path = "~/.dotfiles/.config/tools/math.lua",
        },
        ["memory"] = {
          opts = {
            require_approval_before = false,
            whitelist = {
              { path = "~/.dotfiles/PERSONAL.md", as = "/personal" },
            },
          },
        },
        ["run_command"] = {
          opts = {
            judge_in_yolo_mode = true,
          },
        },
      },
    },
    cli = {
      agent = "claude_code",
      agents = {
        augment = {
          cmd = "auggie",
          args = {},
          description = "Augment CLI",
          provider = "terminal",
        },
        claude_code = {
          cmd = "claude",
          args = {},
          description = "Claude Code CLI",
          provider = "terminal",
        },
        opencode = {
          cmd = "opencode",
          args = {},
          description = "OpenCode",
          provider = "terminal",
        },
      },
    },
    code_review = {
      display = {
        virtual_text = {
          icon = "  ",
          overflow = "wrap",
        },
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
  mcp = {
    servers = {
      ["sequential-thinking"] = {
        cmd = { "npx", "-y", "@modelcontextprotocol/server-sequential-thinking" },
      },
      ["tavily-mcp"] = {
        cmd = { "npx", "-y", "tavily-mcp@latest" },
        env = {
          TAVILY_API_KEY = "cmd:op read op://personal/Tavily_API/credential --no-newline",
        },
        tool_defaults = {
          require_approval_before = true,
        },
      },
    },
  },
  rules = {
    personal = {
      files = {
        { path = "~/.dotfiles/PERSONAL.md", parser = "codecompanion" },
      },
    },
    opts = {
      chat = {
        autoload = { "default", "personal" },
        autoload_groups_in_prompt_library = true,
      },
    },
  },
  opts = {
    language = "British English",
    log_level = "DEBUG",
    per_project_config = {
      files = {
        ".codecompanion.lua",
      },
    },
    -- test_mode = true,
  },
})
vim.cmd([[cab cc CodeCompanion]])
vim.cmd([[cab ccc CodeCompanionCodeReview Comment]])

local SPINNER_MESSAGES = {
  request = {
    started = "  Sending...",
    success = "  Completed",
    error = "  Failed",
    cancelled = "󰜺  Cancelled",
  },
  judge = {
    started = "  Checking...",
    success = "󰕥  Checked",
    error = "󰦞  Check Failed",
    cancelled = "󰜺  Cancelled",
  },
}

---Format an adapter's name and model for display with the spinner
---@param adapter CodeCompanion.Adapter
---@return string
local function format_adapter(adapter)
  if adapter.model and adapter.model ~= "" then
    return adapter.formatted_name .. " (" .. adapter.model .. ")"
  end
  return adapter.formatted_name
end

local SPINNER_EVENTS = {
  {
    started = "CodeCompanionRequestStarted",
    finished = "CodeCompanionRequestFinished",
    messages = SPINNER_MESSAGES.request,
    client_name = function(data)
      return format_adapter(data.adapter)
    end,
  },
  {
    started = "CodeCompanionToolsJudgeStarted",
    finished = "CodeCompanionToolsJudgeFinished",
    messages = SPINNER_MESSAGES.judge,
    client_name = function(data)
      return data.tool
    end,
  },
}

---Setup the spinner for CodeCompanion
---@return nil
local function codecompanion_spinner()
  local ok, progress = pcall(require, "fidget.progress")
  if not ok then
    return
  end

  local handles = {}
  local group = vim.api.nvim_create_augroup("dotfiles.codecompanion.spinner", {})

  for _, event in ipairs(SPINNER_EVENTS) do
    vim.api.nvim_create_autocmd("User", {
      pattern = event.started,
      group = group,
      callback = function(args)
        handles[args.data.id] = progress.handle.create({
          title = "",
          message = event.messages.started,
          lsp_client = { name = event.client_name(args.data) },
        })
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = event.finished,
      group = group,
      callback = function(args)
        local handle = handles[args.data.id]
        handles[args.data.id] = nil
        if handle then
          handle.message = event.messages[args.data.status] or event.messages.cancelled
          handle:finish()
        end
      end,
    })
  end
end

codecompanion_spinner()
