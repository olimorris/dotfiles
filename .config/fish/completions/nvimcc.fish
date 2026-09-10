function __nvimcc_worktrees
    set -l dir /Users/Oli/Code/Neovim/codecompanion.nvim
    if test -d $dir
        for entry in $dir/*/
            set -l name (basename $entry)
            test $name = main; or echo $name
        end
    end
end

complete -c nvimcc -f -n "not __fish_seen_subcommand_from (__nvimcc_worktrees)" -a "(__nvimcc_worktrees)" -d "CodeCompanion worktree"
