set -q __fish_config_symbols_sourced
or if status is-login
    set -U my_fish_symbol_prompt ❯
    set -U my_fish_symbol_git ""
    set -U my_fish_symbol_nix " "
    set -U my_fish_symbol_python " "
end
set -g __fish_config_symbols_sourced
