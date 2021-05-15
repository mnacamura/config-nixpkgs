function __my_prompt_pipestatus -d "Prompt a series of pipe status by colorized ❱s"
    set_color normal
    for s in $argv
        if [ $s -eq 0 ]
            set_color $my_status_color_ok
        else
            set_color $my_status_color_error
        end
        echo -n '❱'
    end
    set_color normal
end
