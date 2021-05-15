function __my_prompt_pwd -d "Prompt current working directory"
    set_color normal
    set_color $fish_color_cwd
    echo -n $PWD | command sed -e "s|^$HOME|~|" -e 's|^/private||'
    set_color normal
end
