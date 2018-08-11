set -q __fish_config_local_sourced
or begin
  set -l local "$HOME/.local"

  [ -d "$local/bin" ]
  and set PATH "$local/bin" $PATH

  if status is-interactive
    set -l _INFOPATH "$local/info:$local/share/info"
    set -q INFOPATH
    and set INFOPATH "$_INFOPATH:$INFOPATH"
    or set -gx INFOPATH "$_INFOPATH"

    # Paths in MANPATH are not joined by : like INFOPATH
    set -l _MANPATH "$local/man" "$local/share/man"
    set -q MANPATH
    and set MANPATH $_MANPATH $MANPATH
    or set -gx MANPATH $_MANPATH
  end
end

set -g __fish_config_local_sourced 1
