function __my_prompt_nixshell -d "Prompt nix environment"
    if [ -n "$IN_NIX_SHELL" ]
        set_color normal
        set_color brblue --bold
        echo -n nix-shell
        set_color normal
        true
    else
        false
    end
end

