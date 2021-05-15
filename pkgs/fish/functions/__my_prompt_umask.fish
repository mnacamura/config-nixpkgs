function __my_prompt_umask -d "Prompt umask unless 0077"
    if [ (umask) != 0077 ]
        set_color normal
        set_color brred --bold
        echo -n (umask)
        set_color normal
        true
    else
        false
    end
end
