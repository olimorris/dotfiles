local M = {
  "nvim-neotest/neotest",
  lazy = true,
  dependencies = {
    { dir = "~/Code/Projects/neotest-rspec" },
    { dir = "~/Code/Projects/neotest-phpunit" },
    "nvim-neotest/neotest-plenary",
    "nvim-neotest/neotest-python",
    "antoinemadec/FixCursorHold.nvim",
  },
}

function M.config()
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

  require("legendary").keymaps({
    {
      itemgroup = "Testing",
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
end

return M
