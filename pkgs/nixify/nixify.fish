#!@fish@/bin/fish

set -g program_name (basename (status filename))

set -g grep @gnugrep@/bin/grep
set -g file @file@/bin/file

function msg
    echo $program_name: $argv >&2 
end

function warn
    echo $program_name: (set_color yellow)$argv(set_color normal) >&2 
end

function edit
    if [ -n "$EDITOR" ]
        eval $EDITOR $argv
    else
        warn "Please set EDITOR environment variable to edit nix files."
    end
end

if [ ! -e ./.envrc ]
    echo "use nix" > .envrc
    msg "added .envrc"
    if type -q direnv
        command direnv allow
    else
        warn "direnv not found; skipped executing 'direnv allow'"
    end
else if not $grep 'use nix' .envrc &>-
    echo "use nix" >> .envrc
    msg "appended 'use nix' to .envrc"
end

if [ ! -e default.nix ]
    msg "editing default.nix"
    cp @default_template@ default.nix
    chmod +w default.nix
    edit default.nix
end

if [ ! -e shell.nix ]
    msg "editing shell.nix"
    cp @shell_template@ shell.nix
    chmod +w shell.nix
    edit shell.nix
end

set -l ignored_files "\
# Nix and direnv stuff
.direnv
result
"
if [ ! -e .gitignore ]; or $file .gitignore | $grep empty &>-
    echo -n $ignored_files > .gitignore
    msg "added .gitignore"
else
    if not $grep '# Nix and direnv stuff' .gitignore &>-
        echo >> .gitignore
        echo -n $ignored_files >> .gitignore
        msg "appended lines to .gitignore"
    end
end
