function fish_prompt
  set -l last_status $status

  set -l todo 0
  set -l prompt_login
  set -l prompt_nix_shell
  set -l prompt_umask

  if status is-login; and [ -z "$TMUX" ]
    set prompt_login true
    set todo (math $todo + 1)
  end

  if [ -n "$IN_NIX_SHELL" ]
    set prompt_nix_shell true
    set todo (math $todo + 1)
  end

  if [ (umask) != 0077 ]
    set prompt_umask true
    set todo (math $todo + 1)
  end

  if [ $todo -gt 0 ]
    set_color reset; set_color $fish_color_comment
    echo -n "["

    if [ -n "$prompt_login" ]
      set_color reset; set_color $fish_color_user
      echo -n (whoami)

      set_color reset; set_color $fish_color_comment
      echo -n @

      set_color reset; set_color $fish_color_host
      echo -n (hostname -s)

      set todo (math $todo - 1)

      if [ $todo -gt 0 ]
        set_color reset; set_color $fish_color_comment
        echo -n "|"
      end
    end

    if [ -n "$prompt_nix_shell" ]
      set_color reset; set_color brgreen --bold
      echo -n nix-shell

      set todo (math $todo - 1)

      if [ $todo -gt 0 ]
        set_color reset; set_color $fish_color_comment
        echo -n "|"
      end
    end

    if [ -n "$prompt_umask" ]
      set_color reset; set_color brred --bold
      echo -n (umask)

      set todo (math $todo - 1)

      if [ $todo -gt 0 ]
        set_color reset; set_color $fish_color_comment
        echo -n "|"
      end
    end

    set_color reset; set_color $fish_color_comment
    echo -n "]"
  end

  set_color reset
  if [ $last_status -eq 0 ]
    set_color $fish_status_color_good
  else
    set_color $fish_status_color_bad
  end
  echo -n '% '

  set_color reset; set_color $fish_color_normal
end
