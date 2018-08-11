{ stdenv, fishConfig, writeFishConfig, buildEnv, ls-colors }:

let
  inherit (stdenv.lib) optionalString;

  direnv = writeFishConfig "direnv" ''
    type -q direnv; and eval (direnv hook fish)
  '';

  git = writeFishConfig "git" ''
    if status is-interactive; and type -q git
      set __fish_git_prompt_showdirtystate y
      set __fish_git_prompt_showcolorhints y
      set __fish_git_prompt_showstashstate y
      set __fish_git_prompt_showuntrackedfiles y
      set __fish_git_prompt_showupstream auto
      set __fish_git_prompt_char_untrackedfiles '?'
      set __fish_git_prompt_char_upstream_equal '''
      set __fish_git_prompt_char_upstream_behind '↓'
      set __fish_git_prompt_char_upstream_ahead '↑'
      set __fish_git_prompt_char_upstream_diverged '↓↑'
      set __fish_git_prompt_color_untrackedfiles $fish_status_color_warn
      abbr --add g   'git'
      abbr --add ga  'git add'
      abbr --add gb  'git branch'
      abbr --add gc  'git commit'
      abbr --add gcl 'git clone'
      abbr --add gco 'git checkout'
      abbr --add gd  'git diff'
      abbr --add gdc 'git diff --cached'
      abbr --add gdd 'git diff --no-ext-diff'
      abbr --add gl  'git log'
      abbr --add glg 'git log --graph --oneline'
      abbr --add gp  'git pull'
      abbr --add gs  'git status'
      abbr --add gss 'git show --ext-diff'
    end
  '';

  less = writeFishConfig "less" ''
    if status is-login
      # Set to fit Srcery color scheme
      set -Ux LESS_TERMCAP_mb (printf "\e[1m")                    # Begin blinking
      set -Ux LESS_TERMCAP_md (printf "\e[1;31m")                 # Begin bold
      set -Ux LESS_TERMCAP_me (printf "\e[0m")                    # End mode
      set -Ux LESS_TERMCAP_so (printf "\e[1;30;48;2;214;93;14m")  # Begin standout mode
      set -Ux LESS_TERMCAP_se (printf "\e[0m")                    # End standout mode
      set -Ux LESS_TERMCAP_us (printf "\e[3;33m")                 # Begin underline
      set -Ux LESS_TERMCAP_ue (printf "\e[0m")                    # End underline
    end
    if status is-interactive
      set -gx PAGER less
      set -gx LESS '-R -ig -j.5'
    end
  '';

  lsColors = writeFishConfig "ls-colors" ''
    if status is-login
      eval (dircolors -c ${ls-colors}/share/LS_COLORS/LS_COLORS | sed 's|setenv|set -Ux|')
    end
  '';

  nix = writeFishConfig "nix" (''
    [ -d $HOME/repos/nixpkgs ]
    and set NIX_PATH "nixpkgs=$HOME/repos/nixpkgs:$NIX_PATH"
  '' + optionalString stdenv.isDarwin ''
    [ -d $HOME/repos/nix-darwin ]
    and set NIX_PATH "darwin=$HOME/repos/nix-darwin:$NIX_PATH"
  '' + ''
    if status is-interactive
      abbr --add nb  "nix build"
      abbr --add nba "nix build -f '<nixpkgs>'"
      abbr --add ne  "nix-env"
      abbr --add nei "nix-env -f '<nixpkgs>' -iA"
      abbr --add neq "nix-env -f '<nixpkgs>' -qaP --description"
      abbr --add nel "nix-env --list-generations"
      # abbr --add ned "nix-env --delete-generations"
      # abbr --add ner "nix-env --rollback"
      abbr --add nc  "nix-channel"
      abbr --add ncu "nix-channel --update"
      abbr --add nsh "nix-shell"
      abbr --add ns  "nix-store"
      abbr --add nsg "nix-store --gc"
      abbr --add nr  "nix repl '<nixpkgs>'"
    end
  '');

  misc = writeFishConfig "misc" ''
    if status is-interactive
      if type -q lp
        abbr --add lp 'lp -o media=a4'
      end
      if type -q nvim
        set EDITOR nvim
        alias vim nvim
        abbr --add v nvim
        abbr --add vi nvim
      end
      if type -q rg
        abbr --add rg 'rg -S'
      end
      if type -q sk
        set -gx SKIM_DEFAULT_COMMAND 'fd -c never || find .'
        set -gx SKIM_DEFAULT_OPTIONS --color=light,matched_bg:153
      end
    end
  '';
in

buildEnv {
  name = "fish-config-all";
  paths = [
    fishConfig
    direnv
    git
    less
    lsColors
    nix
    misc
  ];
}
