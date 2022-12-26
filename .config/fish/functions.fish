function mkd -d "Create a directory and set CWD"
    command mkdir $argv
    if test $status = 0
        switch $argv[(count $argv)]
            case '-*'

            case '*'
                cd $argv[(count $argv)]
                return
        end
    end
end

function load_env_vars -d "Load variables in a .env file"
    for i in (cat $argv)
        set arr (echo $i |tr = \n)
        set -gx $arr[1] $arr[2]
    end
end

function now -d "Print the current date and time"
    date "+%Y-%m-%d %H:%M:%S"
end

function nv -d "Launch Neovim"
    if count $argv >/dev/null
        nvim $argv
    else
        nvim
    end
end

function o -d Open
    if count $argv >/dev/null
        open $argv
    else
        open .
    end
end

function ta -d "Attach to previous Tmux session"
    tmux new-session -t $argv
end

function tn -d "Create a new Tmux session (or attach to one) based on the current directory"
    set selected (pwd | sed 's/.*\///g')
    # Replace a '.' in any file names with an underscore This matches the tmux-
    # sessionizer bin script
    set selected_name $(basename "$selected" | tr . _)
    tmux new -s $selected_name
end

function italic -d "Test if italic text is working"
    echo -e "\e[3mThis text should be in italics\e[23m"
end

function col -d "Test if color is working"
    curl -s https://gist.githubusercontent.com/HaleTom/89ffe32783f89f403bba96bd7bcd1263/raw/e50a28ec54188d2413518788de6c6367ffcea4f7/print256colours.sh | bash
end
