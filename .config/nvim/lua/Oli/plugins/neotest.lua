local M = {}

function M.setup()
  local ok, neotest = om.safe_require("neotest")
  if not ok then
    return
  end

  neotest.setup({
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
end

return M
