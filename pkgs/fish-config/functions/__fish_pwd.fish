function __fish_pwd --description 'Print the current working directory, shortened to fit the prompt'
  set_color reset; set_color $fish_color_cwd

  set -l wd (echo "$PWD" | command sed -e "s|^$HOME|~|" -e 's|^/private||')

  ## shorten the PWD only if it is longer than 55 chars
  if [ (echo "$wd" | command wc -c) -le 55 ]
    echo "$wd"
  else
    echo "$wd" | command sed -e 's-\([^/.]\)[^/]*/-\1/-g'
  end

  set_color reset; set_color $fish_color_normal
end
