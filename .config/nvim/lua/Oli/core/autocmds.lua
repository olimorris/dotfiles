local M = {}
------------------------------DEFAULT COMMANDS------------------------------ {{{
function M.default_autocmds()
  return {
    {
      name = "GitTrackRemoteBranch",
      {
        { "VimEnter", "TermLeave" },
        function() om.GitRemoteSync() end,
        opts = {
          pattern = { "*" },
        },
      },
    },
    {
      name = "FiletypeOptions",
      {
        "FileType",
        ":setlocal shiftwidth=2 tabstop=2",
        opts = {
          pattern = { "css", "eruby", "html", "lua", "javascript", "json", "ruby", "vue" },
        },
      },
      {
        "FileType",
        ":setlocal wrap linebreak",
        opts = { pattern = "markdown" },
      },
      {
        "FileType",
        ":setlocal showtabline=0",
        opts = { pattern = "alpha" },
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
      name = "AddRubyFiletypes",
      {
        { "BufNewFile", "BufRead" },
        ":set ft=ruby",
        opts = {
          pattern = { "*.json.jbuilder", "*.jbuilder", "*.rake" },
        },
      },
    },
    {
      name = "ChangeMappingsInTerminal",
      {
        "TermOpen",
        function()
          if vim.bo.filetype == "" or vim.bo.filetype == "toggleterm" then
            local opts = { silent = false, buffer = 0 }
            vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
            vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
          end
        end,
        opts = {
          pattern = "term://*",
        },
      },
    },
    {
      name = "RemoveWhitespaceOnSave",
      {
        { "BufWritePre" },
        [[%s/\s\+$//e]],
        opts = {
          pattern = { "*" },
        },
      },
    },
    --   {
    --     { "User" },
    --     function()
    --       vim.notify("Packer compile complete", nil, { title = "Packer" })
    --     end,
    --     opts = {
    --       pattern = { "PackerCompileDone" },
    --     },
    --   },
    -- },
    -- Highlight text when yanked
    {
      name = "HighlightYankedText",
      {
        "TextYankPost",
        function() vim.highlight.on_yank() end,
        opts = { pattern = "*" },
      },
    },
  }
end

---------------------------------------------------------------------------- }}}
-------------------------------------LSP------------------------------------ {{{
function M.lsp_autocmds(client, bufnr)
  local autocmds = {}

  autocmds = {
    {
      name = "LspOnAttachAutocmds",
      clear = false,
      {
        { "CursorHold", "CursorHoldI" },
        ":silent! lua vim.lsp.buf.document_highlight()",
        opts = { buffer = bufnr },
      },
      {
        "CursorMoved",
        ":silent! lua vim.lsp.buf.clear_references()",
        opts = { buffer = bufnr },
      },
    },
  }

  local ok, lightbulb = om.safe_require("nvim-lightbulb")
  if ok then
    lightbulb.setup({
      ignore = { "null-ls" },
      autocmd = { enabled = true },
      sign = { enabled = false },
      float = { enabled = true },
    })
    table.insert(autocmds, {
      { "CursorHold", "CursorHoldI" },
      function() lightbulb.update_lightbulb() end,
      opts = { buffer = bufnr },
    })
  end

  return autocmds
end

---------------------------------------------------------------------------- }}}
-----------------------------------PLUGINS---------------------------------- {{{
function M.plugin_autocmds()
  local autocmds = {
    {
      name = "Telescope",
      {
        "User",
        ":setlocal wrap",
        opts = { pattern = "TelescopePreviewerLoaded" },
      },
    },
    {
      name = "RefreshStatuslineColors",
      {
        "ColorScheme",
        function() require(config_namespace .. ".plugins.statusline").setup() end,
        opts = { pattern = "*" },
      },
    },
  }
  return autocmds
end

---------------------------------------------------------------------------- }}}
return M
