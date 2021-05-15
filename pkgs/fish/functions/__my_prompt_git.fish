function __my_prompt_git -d "Prompt git branch in git repo"
    if __fish_is_git_repository
        fish_git_prompt | command sed 's|^ (\(.*\))$|\1|'
        true
    else
        false
    end
end

