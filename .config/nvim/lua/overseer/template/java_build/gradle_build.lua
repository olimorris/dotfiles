local overseer = require("overseer")

return {
  name = "gradle build",
  builder = function(_)
    return {
      cmd = { "gradle" },
      args = { "build" },
      components = { "on_output_quickfix", "default" },
      cwd = vim.fn.getcwd(),
    }
  end,
  desc = "build a gradle project",
  tags = { overseer.TAG.BUILD },
  condition = {
    filetype = { "java", "groovy" },
    callback = function()
      return vim.fs.find({ "gradlew", "build.gradle" }, { upward = true })[1] ~= nil
    end,
  },
}
