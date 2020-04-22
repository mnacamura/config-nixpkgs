function fish_right_prompt
  set_color reset; set_color $fish_color_comment
  echo -n '['

  __fish_pwd

  if __fish_is_git_repository
    set_color reset; set_color $fish_color_comment
    echo -n '|'

    __fish_git_prompt | command sed 's;^ (\(.*\))$;\1;'
  end

  set_color reset; set_color $fish_color_comment
  echo ']'

  set_color reset; set_color $fish_color_normal
end
