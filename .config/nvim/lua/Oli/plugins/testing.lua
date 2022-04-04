local M = {}
----------------------------------COVERAGE---------------------------------- {{{
M.coverage = function()
  local ok, coverage = om.safe_require("coverage")
  if not ok then
    return
  end

  local colors = require("onedarkpro").get_colors(vim.g.onedarkpro_style)

  coverage.setup({
    commands = false,
    highlights = {
      covered = { fg = colors.green },
      uncovered = { fg = colors.red },
    },
  })
end
---------------------------------------------------------------------------- }}}
----------------------------------VIM-TEST---------------------------------- {{{
M.vim_test = function()
  -- TermToggle strategy
  vim.cmd([[
        function! ToggleTermStrategy(cmd) abort
            call luaeval("require('toggleterm').exec(_A[1])", [a:cmd])
        endfunction

        let g:test#custom_strategies = {'toggleterm': function('ToggleTermStrategy')}
    ]])
  vim.g["test#strategy"] = "toggleterm"

  vim.g["test#echo_command"] = 0 -- Do not echo the test command before running
  vim.g["test#preserve_screen"] = 0 -- Always clear the screen when running

  -- Python - Pytest
  vim.g["test#python#runner"] = "pytest"
  vim.g["test#python#asyncrun"] = "pytest"
  vim.g["test#python#pytest#options"] = "--color=yes"
  -- vim.g['test#python#pytest#executable'] = 'docker-compose -f "./docker-compose.yml" exec -T -w /usr/src/app web pytest'

  -- Ruby - Rails
  vim.g["test#ruby#runner"] = "rails"
  vim.g["test#ruby#asyncrun"] = "rspec --require "
    .. os.getenv("HOME_DIR")
    .. "/Code/Ruby/helpers/quickfix_formatter.rb --format QuickfixFormatter"
  vim.g["test#ruby#rails#options"] = "-p"

  -- Javascript
  vim.g["test#javascript#runner"] = "jest"
  vim.g["test#javascript#asyncrun"] = "yarn test"
  vim.g["test#javascript#jest#options"] = "--color=always"
end
---------------------------------------------------------------------------- }}}
return M
