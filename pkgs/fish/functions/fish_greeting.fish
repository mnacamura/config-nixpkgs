function fish_greeting
  if status is-login
    type -q fortune; and fortune -s
  end
end
