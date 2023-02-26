local overseer = require("overseer")

return {
  name = "maven package",
  builder = function(_)
    return {
      cmd = { "mvn" },
      args = { "package" },
      components = { "on_output_quickfix", "default" },
      cwd = vim.fn.getcwd(),
    }
  end,
  desc = "package a maven project",
  tags = { overseer.TAG.BUILD },
  condition = {
    filetype = { "java" },
    callback = function() return vim.fs.find({ "pom.xml" }, { upward = true })[1] ~= nil end,
  },
}
