local M = {}

function M.default_autocmds()
  local autocmds = {
    {
      name = "FiletypeIndentation",
      {
        "FileType",
        ":setlocal shiftwidth=2 tabstop=2",
        opts = {
          pattern = { "css", "eruby", "html", "lua", "javascript", "json", "ruby", "vue" },
        },
      },
    },
    {
      name = "MarkdownLineWrapping",
      {
        "FileType",
        ":setlocal wrap",
        opts = {
          pattern = { "markdown" },
        },
      },
    },
    {
      name = "QuickfixFormatting",
      {
        { "BufEnter", "WinEnter" },
        ":if &buftype == 'quickfix' | setlocal nocursorline | setlocal number | endif",
        opts = {
          pattern = { "*" },
        },
      },
    },
    {
      name = "ReloadTheme",
      {
        "ColorScheme",
        function()
          require(config_namespace .. ".core.theme").init()
        end,
        opts = {
          pattern = { "*" },
        },
      },
    },
    {
      name = "AddRubyFiletypes",
      {
        { "BufNewFile", "BufRead" },
        ":set ft=ruby",
        opts = {
          pattern = { "*.json.jbuilder", "*.jbuilder", "*.rake" },
        },
      },
    },
  }

  -- Reload bufferline when the theme has been changed
  if om.safe_require("cokeline", { silent = true }) then
    table.insert(autocmds, {
      name = "RefreshBufferlineColors",
      {
        "ColorScheme",
        function()
          return require(config_namespace .. ".plugins.bufferline").setup()
        end,
        opts = { pattern = "*" },
      },
    })
  end
  --
  -- Reload statusline when the theme has been changed
  if om.safe_require("feline", { silent = true }) then
    table.insert(autocmds, {
      name = "RefreshStatuslineColors",
      {
        "ColorScheme",
        function()
          require(config_namespace .. ".plugins.statusline").setup()
        end,
        opts = { pattern = "*" },
      },
    })
  end

  if om.safe_require("alpha", { silent = true }) then
    table.insert(autocmds, {
      name = "AlphaDashboardFormatting",
      {
        "FileType",
        ":set showtabline=0 | setlocal nofoldenable",
        opts = { pattern = "alpha" },
      },
      {
        "BufUnload",
        ":set showtabline=2",
        opts = { pattern = "<buffer>" },
      },
    })
  end

  -- Highlight text when yanked
  table.insert(autocmds, {
    name = "YankHighlight",
    {
      "TextYankPost",
      vim.highlight.on_yank,
      opts = { pattern = "*" },
    },
  })
  return autocmds
end

function M.lsp_autocmds(client)
  local autocmds = {
    {
      name = "LspOnAttachAutocmds",
      clear = true,
      {
        { "CursorHold", "CursorHoldI" },
        ":silent! lua vim.lsp.buf.document_highlight()",
        opts = { pattern = "<buffer>" },
      },
      {
        "CursorMoved",
        ":silent! lua vim.lsp.buf.clear_references()",
        opts = { pattern = "<buffer>" },
      },
    },
  }

  if client and client.resolved_capabilities.code_lens then
    table.insert(autocmds, {
      {
        name = "LspCodeLens",
        clear = true,
        {
          { "BufEnter", "CursorHold", "CursorHoldI" },
          ":silent! lua vim.lsp.codelens.refresh()",
          opts = { pattern = "<buffer>" },
        },
      },
    })
  end
  return autocmds
end

return M
