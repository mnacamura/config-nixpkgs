function __my_prompt_login -d "Prompt whether login shell or not"
    if status is-login
        set_color normal
        set_color $fish_color_comment
        echo -n 
        true
        set_color normal
    else
        false
    end
end

