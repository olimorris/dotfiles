---@brief
---
--- https://github.com/swiftlang/sourcekit-lsp
---
--- Language server for Swift and C/C++/Objective-C.

local function xcode_project(name)
  return name:match("%.xcodeproj$") ~= nil or name:match("%.xcworkspace$") ~= nil
end

---@type vim.lsp.Config
return {
  cmd = { "sourcekit-lsp" },
  filetypes = { "swift", "objc", "objcpp", "c", "cpp" },
  root_dir = function(bufnr, on_dir)
    on_dir(vim.fs.root(bufnr, {
      { "buildServer.json", ".bsp" },
      xcode_project,
      -- better to keep it at the end, because some modularized apps contain multiple Package.swift files
      { "compile_commands.json", "Package.swift" },
      ".git",
    }))
  end,
  get_language_id = function(_, ftype)
    local t = { objc = "objective-c", objcpp = "objective-cpp" }
    return t[ftype] or ftype
  end,
  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
    textDocument = {
      diagnostic = {
        dynamicRegistration = true,
        relatedDocumentSupport = true,
      },
    },
  },
}
