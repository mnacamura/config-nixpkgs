#!@fish@/bin/fish

if [ ! -e ./.envrc ]
    echo "use nix" > .envrc
    direnv allow
end

if [ ! -e default.nix ]
    cp @default_template@ default.nix
    chmod +w default.nix
end

if [ ! -e shell.nix ]
    cp @shell_template@ shell.nix
    chmod +w shell.nix
end

set -l ignore "\
# Nix and direnv stuff
.direnv
result
"
if [ ! -e ./.gitignore ]
    echo -n "$ignore" > .gitignore
else
    echo -n "$ignore" >> .gitignore
end

if [ -n "$EDITOR" ]
    eval $EDITOR default.nix
else
    set_color yellow
    echo (status -f): Please set EDITOR environment variable to edit nix files >&2 
    set_color normal
end
