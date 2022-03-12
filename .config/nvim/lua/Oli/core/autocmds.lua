---------------------------------BUFFERLINE--------------------------------- {{{
-- Reload Cokeline when the theme has been changed
if om.safe_require("cokeline", { silent = true }) then
  om.augroup("RefreshBufferlineColors", {
    {
      events = { "ColorScheme" },
      targets = { "*" },
      command = function()
        require(config_namespace .. ".plugins.bufferline").setup()
      end,
    },
  })
end
--------------------------------------------------------------------------- }}}
------------------------------CLEAR COMMANDLINE----------------------------- {{{
--- automatically clear commandline messages after a few seconds delay
--- source: http://unix.stackexchange.com/a/613645
---@return function
local function clear_commandline()
  --- Track the timer object and stop any previous timers before setting
  --- a new one so that each change waits for 5 secs and that 5 secs is
  --- deferred each time
  local timer
  return function()
    if timer then
      timer:stop()
    end
    timer = vim.defer_fn(function()
      if vim.fn.mode() == "n" then
        vim.cmd([[echon '']])
      end
    end, 5000)
  end
end

om.augroup("ClearCommandMessages", {
  {
    events = { "BufWritePost", "CmdlineLeave", "CmdlineChanged" },
    targets = { ":" },
    command = clear_commandline(),
  },
})
--------------------------------------------------------------------------- }}}
----------------------------------DASHBOARD--------------------------------- {{{
-- Do not show folds and hide the tabline when Alpha is present
if om.safe_require("alpha", { silent = true }) then
  om.augroup("AlphaTabline", {
    {
      events = { "Filetype" },
      targets = { "alpha" },
      command = "set showtabline=0 | setlocal nofoldenable",
    },
    {
      events = { "BufUnload" },
      targets = { "<buffer>" },
      command = "set showtabline=2",
    },
  })
end
--------------------------------------------------------------------------- }}}
----------------------------HIGHLIGHT YANKED TEXT--------------------------- {{{
-- Highlight text is yanked
om.augroup("YankHighlight", {
  {
    events = { "TextYankPost" },
    targets = { "*" },
    command = vim.highlight.on_yank,
  },
})
--------------------------------------------------------------------------- }}}
---------------------------------INDENTATION-------------------------------- {{{
om.augroup("FileTypeIndentation", {
  {
    events = { "Filetype" },
    targets = { "css", "eruby", "html", "lua", "javascript", "json", "ruby", "vue" },
    command = "setlocal shiftwidth=2 tabstop=2",
  },
})
--------------------------------------------------------------------------- }}}
----------------------------------QUICKFIX---------------------------------- {{{
-- Show actual line numbers, not releative ones
om.augroup("QuickfixFormatting", {
  {
    events = { "BufEnter", "WinEnter" },
    targets = { "*" },
    command = "if &buftype == 'quickfix' | setlocal nocursorline | setlocal number | endif",
  },
})
--------------------------------------------------------------------------- }}}
-------------------------------RELOAD PLUGINS------------------------------- {{{
om.augroup("ReloadPlugins", {
  {
    events = "BufWritePost",
    targets = {
      "$DOTFILES/.config/nvim/lua/Oli/core/*.lua",
      "$DOTFILES/.config/nvim/lua/Oli/plugins/*.lua",
      "$MYVIMRC",
    },
    modifiers = { "++nested" },
    command = function()
      print("Updating Plugins")
      -- require("nvim").ex.source("<afile>")
      -- require("nvim").ex.PackerSync()
    end,
  },
})
--------------------------------------------------------------------------- }}}
---------------------------------STATUSLINE--------------------------------- {{{
-- Reload Feline when the theme has been changed
if om.safe_require("feline", { silent = true }) then
  om.augroup("RefreshStatuslineColors", {
    {
      events = { "ColorScheme" },
      targets = { "*" },
      command = function()
        require(config_namespace .. ".plugins.statusline").setup()
        -- require("feline").reset_highlights()
      end,
    },
  })
end

--------------------------------------------------------------------------- }}}
-----------------------------------SYNTAX----------------------------------- {{{
om.augroup("AdditionalRubyFiletypes", {
  {
    events = { "BufNewFile", "BufRead" },
    targets = { "*.json.jbuilder", "*.jbuilder", "*.rake" },
    command = "set ft=ruby",
  },
})
--------------------------------------------------------------------------- }}}
------------------------------------THEME----------------------------------- {{{
om.augroup("ReloadTheme", {
  {
    events = { "ColorScheme" },
    targets = { "*" },
    command = function()
      require(config_namespace .. ".core.theme").init()
    end,
  },
})
--------------------------------------------------------------------------- }}}
----------------------------------WRAPPING---------------------------------- {{{
-- Wrapping
om.augroup("LineWrapping", {
  {
    events = { "FileType" },
    targets = { "markdown" },
    command = "setlocal wrap",
  },
})
--------------------------------------------------------------------------- }}}
