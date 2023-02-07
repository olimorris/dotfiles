-- Taken from: https://github.com/mfussenegger/nvim-jdtls#configuration-quickstart
-- May need the verbose configuration at some point
local config = {
  cmd = { "/Users/Oli/.local/share/nvim/mason/bin/jdtls" },
  root_dir = vim.fs.dirname(vim.fs.find({ ".gradlew", ".git", "mvnw" }, { upward = true })[1]),
}

require("jdtls").start_or_attach(config)
