function __my_prompt_userhost
    if status is-login
        set_color normal
        if [ -n "$SSH_CONNECTION" ]
            set_color $fish_color_user
            echo -n (whoami)
            set_color $fish_color_comment
            echo -n @
            set_color $fish_color_host
            echo -n (hostname -s)
        else
            set_color $fish_color_comment
            echo -n @
        end
        set_color normal
        true
    else
        false
    end
end

