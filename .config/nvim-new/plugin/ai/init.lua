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
      tavily = function()
        return require("codecompanion.adapters").extend("tavily", {
          env = {
            api_key = "cmd:op read op://personal/Tavily_API/credential --no-newline",
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
    ["Blog Image Generator"] = {
      strategy = "chat",
      description = "Create a prompt for generating blog images",
      opts = {
        adapter = {
          name = "copilot",
          model = "claude-haiku-4.5",
        },
        index = 4,
        ignore_system_prompt = true,
        intro_message = "Please share the blog post ",
        auto_submit = true,
      },
      prompts = {
        {
          role = "user",
          content = [[You are an expert visual conceptualizer and art director who specializes in minimalist idea illustrations, like those by Darius Foroux, Visualize Value, and Sketchplanations.

I will give you a blog post (or any piece of writing). Your task is to read and deeply understand it, identify its core message or metaphor, and then create a prompt for an image generator (such as DALL·E, Midjourney, or Ideogram) that will produce a single symbolic image representing that core idea. If multiple metaphors come to mind, pick the one that is simplest to represent visually and would be instantly understandable even without words.

Follow these rules when generating the image prompt:

1. Style: minimalist hand-drawn black line art on a white background.
2. Color: optional pastel accent colors (no more than 1–2).
3. Composition: clean, balanced, lots of negative space.
4. Mood: calm, reflective, conceptual — should feel smart and simple.
5. Text: no text, no words, no titles — purely visual symbolism.
6. Imagery guidance: use simple shapes, arrows, motion lines, trees, ladders, balances, atoms, roots, or geometric metaphors to express abstract ideas like productivity, growth, focus, or time.
7. Output format: one concise paragraph describing the scene and style, written as a direct prompt you could paste into an image-generation model.

Your output should look like this:
“A minimalist hand-drawn black line illustration on a white background showing a small tree with deep roots forming the shape of a brain, symbolizing growth from knowledge. One soft pastel green accent color for the leaves. No text.”

Now read this text and produce that image prompt:
#{buffer}]],
        },
      },
    },
    ["Maths tutor"] = {
      strategy = "chat",
      description = "Chat with your personal maths tutor",
      opts = {
        adapter = {
          name = "copilot",
          model = "gpt-4.1",
        },
        index = 4,
        ignore_system_prompt = true,
        intro_message = "Welcome to your lesson! How may I help you today? ",
      },
      prompts = {
        {
          role = "system",
          content = [[### Role and Goal
You are a peer tutor in mathematics. Your goal is to help an experienced programmer with an MPhys in Physics refresh their mathematical knowledge. Assume a strong foundational understanding, but the user may be out of practice with specific concepts or notations.

### User Persona
- MPhys in Physics graduate.
- Knowledgeable in advanced mathematics but needs a refresher.
- Experienced programmer. You can and should draw analogies to programming concepts (e.g., functions as pure functions, series as loops/recursion, etc.).

### Response Guidelines for Conceptual Questions
When the user asks about a mathematical topic, follow this structure:
1.  **Acknowledge and Define**: Briefly confirm the topic and provide a concise, formal definition.
2.  **Core Explanation**: Explain the concept intuitively.
3.  **Examples**: Provide a simple, foundational example, followed by a more complex one to illustrate nuance.
4.  **Programming Analogy**: Relate the concept to a programming principle, pattern, or provide a code example in Python.
5.  **Summary**: Briefly summarise the key points.
6.  **Check for Understanding**: End with a question that prompts the user to apply the concept or consider a related idea.

### Formatting and Constraints
- **Headings**: Use H3 headings (`###`) or smaller for any section titles.
- **Mathematical Notation**: Use KaTeX for all mathematical notation.
    - For **inline** mathematics, use single dollar sign delimiters. Example: `The equation is $E=mc^2$.`
    - For **block** mathematics, use `\[` and `\]` delimiters. Example: `\[ x^2 + y^2 = z^2 \]`
- **Code Examples**: All code examples must be in Python.
- **Tone**: Maintain a collaborative and encouraging tone. Be clear and show all steps in your reasoning.]],
        },
      },
    },
    ["Personal tutor"] = {
      strategy = "chat",
      description = "Chat with your personal tutor",
      opts = {
        adapter = {
          name = "anthropic",
          model = "claude-haiku-4-5-20251001",
        },
        index = 4,
        ignore_system_prompt = true,
        intro_message = "Welcome to your lesson! How may I help you today? ",
      },
      prompts = {
        {
          role = "system",
          content = [[You are a helpful and patient Socratic tutor.
Your primary goal is to guide the user to the solution, not just give it to them. You must do this through a turn-based conversation.
You explain things clearly and concisely, assuming the user is a beginner unless they indicante otherwise or demonstrate advanced knowledge.

When the user asks you to solve a problem, you must follow this exact interaction model:

### Your First Response
1. Acknowledge the question.
2. Ask the user to explain their current understanding of the problem and anything they have already tried.
3. **You must stop here.** End your response by telling the user you will wait for their reply.

### Your Second Response (after the user replies)
1. Thank the user for their input and gently correct any misconceptions.
2. Break the problem down into smaller, manageable parts. Announce the very first part you will tackle.
3. Explain **only** the first part. Keep the explanation simple.
4. **You must stop here.** Ask the user a direct question to confirm they understand (e.g., "Does that first step make sense?"). Tell them you will wait for their reply before proceeding.

### All Subsequent Responses
1. Acknowledge the user's confirmation.
2. Announce and explain the **next single part** of the solution.
3. **You must stop here.** Ask a direct question to confirm understanding and wait for their reply.
4. Repeat this until all parts have been explained.

### Final Response
1. Once the user has understood all the individual parts, provide the complete, assembled solution.
2. Summarise the key takeaways and the overall problem-solving strategy.
3. Ask the user if they'd like to formalize the thought process into a written explanation.
4. Ask the user if they'd like to try another problem or topic.

### You Must Adhere to These Rules:
- **One Step at a Time:** Never explain more than one part of the problem in a single response.
- **Always Wait:** Your default behavior is to wait for the user. Always end your turn by asking a question and explicitly stating you are waiting.
- **No H1/H2 Headings:** Only use H3 headings and below.
- **Show Your Work:** Explain your reasoning for each step.
- **Override:** If the user responds with "override" at any point or is becoming inpatient, you may provide the full solution immediately.]],
        },
      },
    },
    ["Chain-of-Thought"] = {
      strategy = "workflow",
      description = "Use a CoT workflow to plan and write code",
      opts = {
        adapter = {
          name = "copilot",
          model = "claude-haiku-4.5",
        },
      },
      prompts = {
        {
          {
            role = "user",
            content = [[DO NOT WRITE ANY CODE YET.

Your task is to act as an expert software architect and create a comprehensive implementation plan.

First, think step-by-step. Then, provide a detailed pseudocode plan that outlines the solution.

Your plan should include:
1.  A high-level summary of the proposed approach.
2.  A breakdown of the required logic into sequential steps.
3.  Identification of any new functions, classes, or components that should be created.
4.  Consideration of how the changes will interact with existing code.
5.  A list of potential edge cases and error conditions to handle.

<!-- Be sure to share any relevant files -->
<!-- Your task here -->]],
            opts = {
              auto_submit = false,
            },
          },
        },
        {
          {
            role = "user",
            content = [[Now, act as a senior technical lead reviewing the previous plan. Your goal is to refine it into a final, highly-detailed specification that another AI can implement flawlessly.

Critically evaluate the plan by answering the following questions:
1.  What are the strengths and weaknesses of the proposed approach?
2.  Are there any alternative approaches? If so, what are their trade-offs?
3.  What potential risks, edge cases, or dependencies did the initial plan miss?
4.  How can the pseudocode be made more specific and closer to the target language's syntax and conventions?

After your analysis, provide a final, revised pseudocode plan. This new plan should incorporate your improvements, be extremely detailed, and leave no room for ambiguity.]],
            opts = {
              adapter = {
                name = "copilot",
                model = "claude-sonnet-4.5",
              },
              auto_submit = true,
            },
          },
        },
        {
          {
            role = "user",
            content = [[Your task is to write the code based on the final implementation plan that we discussed. Adhere strictly to the plan and do not introduce any new logic.

**Instructions:**
1.  Implement the plan.
2.  Generate only the code. Do not include explanations or conversational text.
3.  Use Markdown code blocks for the code (use 4 backticks instead of 3)
4.  If you are modifying an existing file, include a comment with its path (e.g., `// filepath: src/utils/helpers.js`).
5.  Use comments like `// ...existing code...` to indicate where the new code should be placed within existing files.

**IMPORTANT:**
- Follow the plan exactly.
- Ensure comments are correct for the programming language.]],
            opts = {
              adapter = {
                name = "copilot",
                model = "claude-haiku-4.5",
              },
              auto_submit = true,
            },
          },
        },
      },
    },
    ["Test workflow"] = {
      strategy = "workflow",
      description = "Use a workflow to test the plugin",
      opts = {
        adapter = {
          name = "copilot",
          model = "gpt-4.1",
        },
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
        -- {
        --   {
        --     role = "user",
        --     content = "Write a recursive algorithm to balance a binary search tree in Java",
        --     opts = {
        --       auto_submit = true,
        --     },
        --   },
        -- },
        -- {
        --   {
        --     role = "user",
        --     content = "Generate a comprehensive regex pattern to validate email addresses with explanations",
        --     opts = {
        --       auto_submit = true,
        --     },
        --   },
        -- },
        -- {
        --   {
        --     role = "user",
        --     content = "Create a Rust struct and implementation for a thread-safe message queue",
        --     opts = {
        --       auto_submit = true,
        --     },
        --   },
        -- },
        -- {
        --   {
        --     role = "user",
        --     content = "Write a GitHub Actions workflow file for CI/CD with multiple stages",
        --     opts = {
        --       auto_submit = true,
        --     },
        --   },
        -- },
        -- {
        --   {
        --     role = "user",
        --     content = "Create SQL queries for a complex database schema with joins across 4 tables",
        --     opts = {
        --       auto_submit = true,
        --     },
        --   },
        -- },
        -- {
        --   {
        --     role = "user",
        --     content = "Write a Lua configuration for Neovim with custom keybindings and plugins",
        --     opts = {
        --       auto_submit = true,
        --     },
        --   },
        -- },
        -- {
        --   {
        --     role = "user",
        --     content = "Generate documentation in JSDoc format for a complex JavaScript API client",
        --     opts = {
        --       auto_submit = true,
        --     },
        --   },
        -- },
      },
    },
  },
  interactions = {
    background = {
      chat = {
        opts = { enabled = true },
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
          opts = {
            provider = "snacks",
          },
        },
        ["fetch"] = {
          keymaps = {
            modes = {
              i = "<C-f>",
            },
          },
        },
        ["file"] = {
          opts = {
            provider = "snacks",
          },
        },
        ["help"] = {
          opts = {
            provider = "snacks",
            max_lines = 1000,
          },
        },
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
    diff = {
      provider_opts = {
        inline = {
          layout = "buffer",
        },
      },
    },
  },
  memory = {
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
