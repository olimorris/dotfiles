local M = {}
------------------------------DEFAULT COMMANDS------------------------------ {{{
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
      name = "Terminal mappings",
      { "TermOpen" },
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
    {
      name = "Remove whitespace on save",
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
  }

  -- Reload bufferline when the theme has been changed
  if om.safe_require("cokeline", { silent = true }) then
    table.insert(autocmds, {
      name = "RefreshBufferlineColors",
      {
        "ColorScheme",
        function()
          require(config_namespace .. ".plugins.bufferline").setup()
        end,
        opts = { pattern = "*" },
      },
    })
  end

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

---------------------------------------------------------------------------- }}}
-------------------------------------LSP------------------------------------ {{{
function M.lsp_autocmds(client, bufnr)
  local autocmds = {}
  if client.name ~= "null-ls" then
    autocmds = {
      {
        name = "LspOnAttachAutocmds",
        clear = true,
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
  end

  if client.name ~= "null-ls" and client.server_capabilities.code_lens then
    table.insert(autocmds, {
      { "BufEnter", "CursorHold", "CursorHoldI" },
      ":silent! lua vim.lsp.codelens.refresh()",
      opts = { buffer = bufnr },
    })
  end

  -- if client.name == "null-ls" then
  --   table.insert(autocmds, {
  --     { "BufWritePost" },
  --     function()
  --       vim.b.format_changedtick = vim.b.changedtick
  --       vim.lsp.buf.formatting()
  --     end,
  --     opts = { buffer = bufnr },
  --   })
  -- end

  if client.name ~= "null-ls" then
    local ok, lightbulb = om.safe_require("nvim-lightbulb")
    if ok then
      lightbulb.setup({
        sign = {
          enabled = false,
        },
        float = {
          enabled = true,
        },
      })
    end
    table.insert(autocmds, {
      { "CursorHold", "CursorHoldI" },
      function()
        lightbulb.update_lightbulb()
      end,
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
      name = "AlphaDashboard",
      {
        "FileType",
        ":setlocal showtabline=0",
        opts = { pattern = "alpha" },
      },
    },
  }
  return autocmds
end
---------------------------------------------------------------------------- }}}
return M
