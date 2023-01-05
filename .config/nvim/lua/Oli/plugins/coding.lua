return {
  "tpope/vim-sleuth", -- Automatically detects which indents should be used in the current buffer
  {
    "kylechui/nvim-surround", -- Use vim commands to surround text, tags with brackets, parenthesis etc
    config = true,
  },
  {
    "numToStr/Comment.nvim", -- Comment out lines with gcc
    keys = { "gcc", { "gc", mode = "v" } },
    init = function()
      require("legendary").keymaps({
        {
          ":Comment",
          {
            n = "gcc",
            v = "gc",
          },
          description = "Toggle comment",
        },
      })
    end,
    config = true,
  },
  {
    "ThePrimeagen/refactoring.nvim", -- Refactor code like Martin Fowler
    lazy = true,
    init = function()
      require("legendary").keymaps({
        {
          itemgroup = "Refactoring",
          icon = "",
          description = "Refactor code",
          keymaps = {
            {
              "<LocalLeader>re",
              function() require("telescope").extensions.refactoring.refactors() end,
              description = "Open Refactoring.nvim",
              mode = { "n", "v", "x" },
            },
            {
              "<LocalLeader>rd",
              function() require("refactoring").debug.printf({ below = false }) end,
              description = "Insert Printf statement for debugging",
            },
            {
              "<LocalLeader>rv",
              {
                n = function() require("refactoring").debug.print_var({ normal = true }) end,
                x = function() require("refactoring").debug.print_var({}) end,
              },
              description = "Insert Print_Var statement for debugging",
              mode = { "n", "v" },
            },
            {
              "<LocalLeader>rc",
              function() require("refactoring").debug.cleanup() end,
              description = "Cleanup debug statements",
            },
          },
        },
      })
    end,
    config = true,
  },
  {
    "jackmort/chatgpt.nvim", -- AI programming
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    cmd = { "ChatGPT", "ChatGPTActAs", "ChatGPTEditWithInstructions" },
    init = function()
      require("legendary").keymaps({
        {
          itemgroup = "ChatGPT",
          icon = "ﮧ",
          description = "Use ChatGPT to generate code",
          keymaps = {
            { "<C-a>", "<cmd>ChatGPT<CR>", description = "Ask a question..." },
          },
        },
      })
      require("legendary").commands({
        {
          itemgroup = "ChatGPT",
          commands = {
            {
              ":ChatGPTActAs",
              description = "Ask a question, acting as...",
            },
            {
              ":ChatGPTEditWithInstructions",
              description = "Open an interactive window",
            },
          },
        },
      })
    end,
    config = {
      welcome_message = "",
      answer_sign = "",
      question_sign = "",
      chat_layout = {
        size = {
          height = "85%",
          width = "85%",
        },
      },
      chat_window = {
        win_options = {
          winblend = 0,
          winhighlight = "Normal:ChatGPTWindow,FloatBorder:FloatBorder",
        },
      },
      chat_input = {
        prompt = "   ",
        win_options = {
          winblend = 0,
          winhighlight = "Normal:ChatGPTPrompt,ChatGPTPrompt:FloatBorder",
        },
      },
      keymaps = {
        close = { "<C-c>", "<Esc>" },
        yank_last = "<C-y>",
        scroll_up = "<C-k>",
        scroll_down = "<C-j>",
        toggle_settings = "<C-o>",
        new_session = "<C-n>",
        cycle_windows = "<Tab>",
      },
    },
    {
      "zbirenbaum/copilot.lua", -- AI programming
      event = "InsertEnter",
      init = function()
        require("legendary").keymaps({
          {
            itemgroup = "Copilot",
            description = "AI programming",
            icon = "",
            keymaps = {
              {
                "<C-a>",
                function() require("copilot.suggestion").accept() end,
                description = "Accept suggestion",
                mode = { "i" },
                opts = { silent = true },
              },
              {
                "<C-x>",
                function() require("copilot.suggestion").dismiss() end,
                description = "Dismiss suggestion",
                mode = { "i" },
                opts = { silent = true },
              },
              {
                "<C-n>",
                function() require("copilot.suggestion").next() end,
                description = "Next suggestion",
                mode = { "i" },
                opts = { silent = true },
              },
              {
                "<C-\\>",
                function() require("copilot.panel").open() end,
                description = "Show Copilot panel",
                mode = { "n", "i" },
              },
            },
          },
        })

        require("legendary").commands({
          {
            ":CopilotToggle",
            function() require("copilot.suggestion").toggle_auto_trigger() end,
            description = "Toggle on/off for buffer",
          },
        })
      end,
      config = {
        panel = {
          auto_refresh = true,
        },
        suggestion = {
          auto_trigger = true, -- Suggest as we start typing
          keymap = {
            accept_word = "<C-l>",
            accept_line = "<C-j>",
          },
        },
      },
    },
  },
  {
    "mfussenegger/nvim-dap", -- Debug Adapter Protocol for Neovim
    lazy = true,
    dependencies = {
      "theHamsta/nvim-dap-virtual-text", -- help to find variable definitions in debug mode
      "rcarriga/nvim-dap-ui", -- Nice UI for nvim-dap
    },
    init = function()
      require("legendary").keymaps({
        {
          itemgroup = "Debug",
          description = "Debugging functionality",
          icon = "",
          keymaps = {
            {
              "<F1>",
              "<cmd>lua require('dap').toggle_breakpoint()<CR>",
              description = "Set breakpoint",
            },
            { "<F2>", "<cmd>lua require('dap').continue()<CR>", description = "Continue" },
            { "<F3>", "<cmd>lua require('dap').step_into()<CR>", description = "Step into" },
            { "<F4>", "<cmd>lua require('dap').step_over()<CR>", description = "Step over" },
            {
              "<F5>",
              "<cmd>lua require('dap').repl.toggle({height = 6})<CR>",
              description = "Toggle REPL",
            },
            { "<F6>", "<cmd>lua require('dap').repl.run_last()<CR>", description = "Run last" },
            {
              "<F9>",
              function()
                local _, dap = om.safe_require("dap")
                dap.disconnect()
                require("dapui").close()
              end,
              description = "Stop",
            },
          },
        },
      })
    end,
    config = function()
      local dap = require("dap")

      ---Show the nice virtual text when debugging
      ---@return nil|function
      local function virtual_text_setup()
        local ok, virtual_text = om.safe_require("nvim-dap-virtual-text")
        if not ok then return end

        return virtual_text.setup()
      end

      ---Show custom virtual text when debugging
      ---@return nil
      local function signs_setup()
        vim.fn.sign_define("DapBreakpoint", {
          text = "",
          texthl = "DebugBreakpoint",
          linehl = "",
          numhl = "DebugBreakpoint",
        })
        vim.fn.sign_define("DapStopped", {
          text = "",
          texthl = "DebugHighlight",
          linehl = "",
          numhl = "DebugHighlight",
        })
      end

      ---Custom Ruby debugging config
      ---@param dap table
      ---@return nil
      local function ruby_setup(dap)
        dap.adapters.ruby = function(callback, config)
          local script

          if config.current_line then
            script = config.script .. ":" .. vim.fn.line(".")
          else
            script = config.script
          end

          callback({
            type = "server",
            host = "127.0.0.1",
            port = "${port}",
            executable = {
              command = "bundle",
              args = { "exec", "rdbg", "--open", "--port", "${port}", "-c", "--", config.command, script },
            },
          })
        end

        dap.configurations.ruby = {
          {
            type = "ruby",
            name = "debug rspec current_line",
            request = "attach",
            localfs = true,
            command = "rspec",
            script = "${file}",
            current_line = true,
          },
          {
            type = "ruby",
            name = "debug current file",
            request = "attach",
            localfs = true,
            command = "ruby",
            script = "${file}",
          },
        }
      end

      ---Slick UI which is automatically triggered when debugging
      ---@param dap table
      ---@return nil
      local function ui_setup(dap)
        local ok, dapui = om.safe_require("dapui")
        if not ok then return end

        dapui.setup({
          layouts = {
            {
              elements = {
                "scopes",
                "breakpoints",
                "stacks",
              },
              size = 35,
              position = "left",
            },
            {
              elements = {
                "repl",
              },
              size = 0.30,
              position = "bottom",
            },
          },
        })
        dap.listeners.after.event_initialized["dapui_config"] = dapui.open
        dap.listeners.before.event_terminated["dapui_config"] = dapui.close
        dap.listeners.before.event_exited["dapui_config"] = dapui.close
      end

      dap.set_log_level("TRACE")

      virtual_text_setup()
      signs_setup()
      ruby_setup(dap)
      ui_setup(dap)
    end,
  },
  {
    "stevearc/overseer.nvim", -- Task runner and job management
    lazy = true,
    config = {
      component_aliases = {
        default_neotest = {
          "on_output_summarize",
          "on_exit_set_status",
          "on_complete_dispose",
        },
      },
    },
  },
  {
    "nvim-neotest/neotest",
    lazy = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",

      "nvim-neotest/neotest-plenary",
      "olimorris/neotest-rspec",
      "olimorris/neotest-phpunit",
    },
    init = function()
      require("legendary").keymaps({
        {
          itemgroup = "Neotest",
          icon = "省",
          description = "Testing functionality",
          keymaps = {
            -- Neotest plugin
            { "<LocalLeader>t", '<cmd>lua require("neotest").run.run()<CR>', description = "Neotest: Test nearest" },
            {
              "<LocalLeader>tf",
              '<cmd>lua require("neotest").run.run(vim.fn.expand("%"))<CR>',
              description = "Neotest: Test file",
            },
            {
              "<LocalLeader>tl",
              '<cmd>lua require("neotest").run.run_last()<CR>',
              description = "Neotest: Run last test",
            },
            {
              "<LocalLeader>ts",
              function()
                local neotest = require("neotest")
                for _, adapter_id in ipairs(neotest.run.adapters()) do
                  neotest.run.run({ suite = true, adapter = adapter_id })
                end
              end,
              description = "Neotest: Test suite",
            },
            { "`", '<cmd>lua require("neotest").summary.toggle()<CR>', description = "Neotest: Toggle test summary" },
          },
        },
      })
    end,
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-plenary"),
          require("neotest-rspec"),
          require("neotest-phpunit"),
        },
        consumers = {
          overseer = require("neotest.consumers.overseer"),
        },
        diagnostic = {
          enabled = false,
        },
        log_level = 1,
        icons = {
          expanded = "",
          child_prefix = "",
          child_indent = "",
          final_child_prefix = "",
          non_collapsible = "",
          collapsed = "",

          passed = "",
          running = "",
          failed = "",
          unknown = "",
          skipped = "",
        },
        floating = {
          border = "single",
          max_height = 0.8,
          max_width = 0.9,
        },
        summary = {
          mappings = {
            attach = "a",
            expand = { "<CR>", "<2-LeftMouse>" },
            expand_all = "e",
            jumpto = "i",
            output = "o",
            run = "r",
            short = "O",
            stop = "u",
          },
        },
      })
    end,
  },
}
