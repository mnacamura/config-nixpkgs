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

function direnv_allow
    if type -q direnv
        command direnv allow
    else
        warn "direnv not found; skipped executing 'direnv allow'"
    end
end

function add_envrc
    if [ ! -e ./.envrc ]
        echo "use nix" > .envrc
        msg "added .envrc"
        direnv_allow
    else if not $grep 'use nix' .envrc &>-
        echo "use nix" >> .envrc
        msg "appended 'use nix' to .envrc"
    end
end

function add_nix_file -a name template
    msg "editing $name"
    if [ ! -e $name ]
        cp $template $name
        chmod +w $name
    end
    edit $name
end

function add_gitignore
    set -l ignored_files "# Nix and direnv stuff"\n".direnv"\n"result"

    if [ ! -e .gitignore ]; or [ ! -s .gitignore ] &>-
        echo -n $ignored_files > .gitignore
        msg "added .gitignore"
    else
        if not $grep '# Nix and direnv stuff' .gitignore &>-
            echo >> .gitignore
            echo -n $ignored_files >> .gitignore
            msg "appended lines to .gitignore"
        end
    end
end

add_envrc
add_nix_file default.nix @default_template@
add_nix_file shell.nix @shell_template@
add_gitignore
