-- Taken from: https://github.com/mfussenegger/nvim-jdtls#configuration-quickstart
-- May need the verbose configuration at some point
local config = {
  cmd = { os.getenv("HOME_DIR") .. ".local/share/nvim/mason/bin/jdtls" },
  root_dir = vim.fs.dirname(vim.fs.find({ ".gradlew", ".git", "mvnw" }, { upward = true })[1]),
}

-- Add additional support for Java plugins (which we've installed with mason-null-ls)
-- TODO: Need to test if these work
local bundles = {
  os.getenv("HOME_DIR")
    .. ".local/share/nvim/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
}
vim.list_extend(
  bundles,
  vim.split(
    vim.fn.glob(os.getenv("HOME_DIR") .. ".local/share/nvim/mason/packages/java-test/extension/server/*.jar", 1),
    "\n"
  )
)
config["init_options"] = {
  bundles = bundles,
}

config["on_attach"] = function(client, bufnr)
  -- With `hotcodereplace = 'auto' the debug adapter will try to apply code changes
  -- you make during a debug session immediately.
  -- Remove the option if you do not want that.
  -- You can use the `JdtHotcodeReplace` command to trigger it manually
  -- require("jdtls").setup_dap({ hotcodereplace = "auto" })
  require('jdtls.setup').add_commands()
end

require("jdtls").start_or_attach(config)
