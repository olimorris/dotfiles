# -----------------------------------------------------------------------------
# Fish Prompt
# -----------------------------------------------------------------------------
function fish_prompt
    set -l last_status $status

    set -l git_info (git status --branch --porcelain 2>/dev/null)
    set -l branch ""
    set -l dirty ""
    set -l ahead ""
    set -l behind ""

    if test (count $git_info) -gt 0
        set branch (string match -r '^## (\S+?)(?:\.\.\.|\s|$)' -- $git_info[1])[2]
        test (count $git_info) -gt 1; and set dirty 1
        set ahead (string match -r 'ahead (\d+)' -- $git_info[1])[2]
        set behind (string match -r 'behind (\d+)' -- $git_info[1])[2]
    end

    set -l duration ""
    if test $CMD_DURATION -gt 3000
        set -l secs (math --scale=0 "$CMD_DURATION / 1000")
        if test $secs -ge 60
            set duration (printf "took %sm %ss" (math --scale=0 "$secs / 60") (math --scale=0 "$secs % 60"))
        else
            set duration (printf "took %ss" $secs)
        end
    end

    set -l arrow_color (test $last_status -eq 0; and echo $fish_color_prefix; or echo $fish_color_error)

    printf "%s%s%s" (set_color --bold $fish_color_keyword) (basename $PWD) (set_color normal)

    if test -n "$branch"
        printf " on %s%s" (set_color $fish_color_valid_path) $branch
        if test -n "$ahead"
            printf " %s↑%s" (set_color $fish_color_option) $ahead
        end
        if test -n "$behind"
            printf " %s↓%s" (set_color $fish_color_option) $behind
        end
        if test -n "$dirty"
            printf " %s✘" (set_color $fish_color_option)
        end
        printf "%s" (set_color normal)
    end

    if test -n "$duration"
        printf " %s%s%s" (set_color $fish_color_comment) $duration (set_color normal)
    end

    printf " %s󰁔 " (set_color $arrow_color)
end
