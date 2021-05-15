function fish_prompt
  set -l last_pipestatus $pipestatus

  echo (string join " " (__my_prompt_userhost) \
                        (__my_prompt_pwd) \
                        (__my_prompt_git))

  echo -n (string join " " (__my_prompt_nixshell) \
                           (__my_prompt_venv) \
                           (__my_prompt_umask))
  __my_prompt_pipestatus $last_pipestatus
  echo -n " "
end
