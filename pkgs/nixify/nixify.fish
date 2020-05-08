#!@fish@/bin/fish

set -l grep @gnugrep@/bin/grep
set -l file @file@/bin/file

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

set -l ignored_files "\
# Nix and direnv stuff
.direnv
result
"
if [ ! -e .gitignore ]; or $file .gitignore | $grep empty &>-
    echo -n $ignored_files > .gitignore
else
    if not $grep '# Nix and direnv stuff' .gitignore &>-
        echo >> .gitignore
        echo -n $ignored_files >> .gitignore
    end
end

if [ -n "$EDITOR" ]
    eval $EDITOR default.nix
else
    set_color yellow
    echo (status -f): Please set EDITOR environment variable to edit nix files >&2 
    set_color normal
end
