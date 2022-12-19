local M = {}
------------------------------DEFAULT AUTOCMDS------------------------------ {{{
function M.default_autocmds()
  return {
    {
      name = "GitTrackRemoteBranch",
      {
        { "TermLeave" },
        function() om.GitRemoteSync() end,
        opts = {
          pattern = { "*" },
        },
      },
      {
        { "VimEnter" },
        function()
          local timer = vim.loop.new_timer()
          timer:start(0, 120000, function() om.GitRemoteSync() end)
        end,
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
    {
      name = "Telescope",
      {
        "User",
        ":setlocal wrap",
        opts = { pattern = "TelescopePreviewerLoaded" },
      },
    },
    {
      name = "ColorschemeAutocmds",
      {
        "ColorScheme",
        function() require(config_namespace .. ".plugins.statusline").setup() end,
        opts = { pattern = "*" },
      },
    },
    {
      name = "netrw_mappings",
      {
        "Filetype",
        function()
          -- Source: https://gist.github.com/VonHeikemen/fa6f7c7f114bc36326cda2c964cb52c7
          vim.api.nvim_exec([[
            " Go to file and close Netrw window
            nmap <buffer> L <CR>:Lexplore<CR>
            " Go back in history
            nmap <buffer> H u
            " Go up a directory
            nmap <buffer> h -^
            " Go down a directory / open file
            nmap <buffer> l <CR>
            " Toggle dotfiles
            nmap <buffer> . gh
            " Create a file
            nmap <buffer> ff %:w<CR>:buffer #<CR>
            " Rename a file
            nmap <buffer> fe R
          ]], true)
        end,
        opts = { pattern = "netrw" },
      },
    },
  }
end

---------------------------------------------------------------------------- }}}
--------------------------------LSP AUTOCMDS-------------------------------- {{{
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

  return autocmds
end

---------------------------------------------------------------------------- }}}
return M
