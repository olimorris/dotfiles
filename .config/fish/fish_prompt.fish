# -----------------------------------------------------------------------------
# Fish Prompt
# -----------------------------------------------------------------------------
function fish_prompt
    set -l arrow_color (test $status -eq 0; and echo $fish_color_prefix ; or echo $fish_color_error)

    set -l branch (git rev-parse --abbrev-ref HEAD 2>/dev/null)
    set -l dirty  (git status --porcelain --ignore-submodules=dirty 2>/dev/null)

    set -l repo_name (basename $PWD)

    printf "%s%s%s" (set_color --bold $fish_color_keyword) $repo_name (set_color $fish_color_normal)

    if test -n "$branch"
        printf " on %s %s" (set_color $fish_color_valid_path) $branch
        if test -n "$dirty"
            printf " %s✘" (set_color $fish_color_option)
        end
        printf "%s" (set_color normal)
    end

    printf " %s󰁔 " (set_color $arrow_color)
end
