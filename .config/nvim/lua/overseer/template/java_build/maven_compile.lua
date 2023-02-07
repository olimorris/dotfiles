local overseer = require("overseer")

return {
  name = "maven compile",
  builder = function(_)
    return {
      cmd = { "mvn" },
      args = { "compile" },
      components = { "on_output_quickfix", "default" },
      cwd = vim.fn.getcwd(),
    }
  end,
  desc = "compile a maven project",
  tags = { overseer.TAG.BUILD },
  condition = { filetype = { "java" } },
}
