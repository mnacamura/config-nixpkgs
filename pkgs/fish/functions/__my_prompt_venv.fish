function __my_prompt_venv -d "Prompt python venv"
    if [ -n "$VIRTUAL_ENV" ]
        set_color normal
        set_color bryellow --bold
        echo -n (command basename $VIRTUAL_ENV)
        set_color normal
        set -gx VIRTUAL_ENV_DISABLE_PROMPT true
        true
    else
        false
    end
end

