function __nvimcc_worktrees
    echo main
    set -l dir ~/.herdr/worktrees/main
    test -d $dir; or return
    for entry in $dir/*/
        basename $entry
    end
end

complete -c nvimcc -f -n "not __fish_seen_subcommand_from (__nvimcc_worktrees)" -a "(__nvimcc_worktrees)" -d "CodeCompanion worktree"
