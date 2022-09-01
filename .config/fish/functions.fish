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

function italic -d "Test if italic text is working"
    echo -e "\e[3mThis text should be in italics\e[23m"
end

function col -d "Test if color is working"
    echo -e 'Should be a smooth gradient:'
    awk 'BEGIN{
        s="/\\/\\/\\/\\/\\"; s=s s s s s s s s;
        for (colnum = 0; colnum<77; colnum++) {
            r = 255-(colnum*255/76);
            g = (colnum*510/76);
            b = (colnum*255/76);
            if (g>255) g = 510-g;
            printf "\033[48;2;%d;%d;%dm", r,g,b;
            printf "\033[38;2;%d;%d;%dm", 255-r,255-g,255-b;
            printf "%s\033[0m", substr(s,colnum+1,1);
        }
        printf "\n";
    }'
end
