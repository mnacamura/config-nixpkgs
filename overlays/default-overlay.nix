self: super:

{
  #{{{ Custom packages

  aspellWith = { lang, dicts }:
  with super; let
    conf = writeText "aspell-conf-${lang}" ''
      dict-dir ${dicts'}/lib/aspell
      lang ${lang}
    '';
    dicts' = symlinkJoin {
      name = "aspell-dicts-${lang}";
      paths = dicts;
    };
  in buildEnv {
    name = "${aspell.name}-${lang}";
    paths = [ aspell ];
    pathsToLink = [ "/share" ];
    buildInputs = [ makeWrapper ];
    postBuild = ''
      mkdir $out/bin
      makeWrapper ${aspell}/bin/aspell $out/bin/aspell --add-flags "--per-conf ${conf}"
      for path in ${aspell}/bin/*; do
        name="$(basename "$path")"
        [ "$name" != aspell ] && ln -s "$path" "$out/bin/$name"
      done
    '';
  };

  ccacheWrapper = super.ccacheWrapper.override {
    extraConfig = ''
      export CCACHE_COMPRESS=1
      export CCACHE_DIR=/var/cache/ccache
      export CCACHE_UMASK=007
      if [ ! -d "$CCACHE_DIR" ]; then
        echo "====="
        echo "Directory '$CCACHE_DIR' does not exist"
        echo "Please create it with:"
        echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
        echo "  sudo chown root:nixbld '$CCACHE_DIR'"
        echo "====="
        exit 1
      fi
      if [ ! -w "$CCACHE_DIR" ]; then
        echo "====="
        echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
        echo "Please verify its access permissions"
        echo "====="
        exit 1
      fi
    '';
  };

  ctagsOptions = {
    html = ''
      --regex-HTML=/id=\"([a-zA-Z0-9-]+)\"/\1/i,identifiers/
      --regex-HTML=/class=\"([a-zA-Z0-9-]+)\"/\1/c,classes/
    '';
    julia = ''
      --langdef=Julia
      --langmap=Julia:.jl
      --regex-Julia=/^[ \t]*(abstract)[ \t]+([^ \t({[]+).*$/\2/a,abstract/
      --regex-Julia=/^[ \t]*(@with_kw[ \t]+)?(immutable)[ \t]+([^ \t({[]+).*$/\3/i,immutable/
      --regex-Julia=/^[ \t]*(@with_kw[ \t]+)?(type|typealias)[ \t]+([^ \t({[]+).*$/\3/t,type/
      --regex-Julia=/^[ \t]*(macro)[ \t]+([^ \t({[]+).*$/\2/m,macro/
      --regex-Julia=/^[ \t]*(@inline[ \t]+|@noinline[ \t]+)?(function)[ \t]+([^ \t({[]+)[^(]*\([ \t]*([^ \t;,=)({]+).*$/\3 (\4, …)/f,function/
      --regex-Julia=/^[ \t]*(@inline[ \t]+|@noinline[ \t]+)?(function)[ \t]+([^ \t({[]+)[^(]*(\([ \t]*\).*|\([ \t]*)$/\3/f,function/
      --regex-Julia=/^[ \t]*(@inline[ \t]+|@noinline[ \t]+)?(([^@#$ \t({[]+)|\(([^@#$ \t({[]+)\)|\((\$)\))[ \t]*(\{.*\})?[ \t]*\([ \t]*\)[ \t]*=([^=].*$|$)/\3\4\5/f,function/
      --regex-Julia=/^[ \t]*(@inline[ \t]+|@noinline[ \t]+)?(([^@#$ \t({[]+)|\(([^@#$ \t({[]+)\)|\((\$)\))[ \t]*(\{.*\})?[ \t]*\([ \t]*([^ \t;,=)({]+).*\)[ \t]*=([^=].*$|$)/\3\4\5 (\7, …)/f,function/
      --regex-Julia=/^[ \t]*(@defstruct)[ \t]+([^ \t({[]+).*$/\2/t,type/
      --regex-Julia=/^[ \t]*(@defimmutable)[ \t]+([^ \t({[]+).*$/\2/i,immutable/
    '';
    scheme = ''
      --langdef=Scheme
      --langmap=Scheme:.scm
      --regex-Scheme=/^[[:space:]]*(\(|[[])define[^[:space:]]*[[:space:]]+(\(|[[])?([^][[:space:]()]+)/\3/d,definition/i
    '';
  };

  ctagsWith = { options ? [] }:
  with super; let
    ctags = universal-ctags;
    conf = writeText "ctags-conf" (lib.strings.concatStringsSep "\n" options);
  in buildEnv {
    name = "${ctags.name}-env";
    paths = [ ctags ];
    pathsToLink = [ "/share" ];
    buildInputs = [ makeWrapper ];
    postBuild = ''
      mkdir $out/bin
      makeWrapper ${ctags}/bin/ctags $out/bin/ctags --add-flags "--options ${conf}"
      for path in ${ctags}/bin/*; do
        name="$(basename "$path")"
        [ "$name" != ctags ] && ln -s "$path" "$out/bin/$name"
      done
    '';
  };

  fishConfig = super.callPackage ../pkgs/fish/config.nix {};

  fishExtraConfig = with self; let
    name = "fish-extra-config";
    cfg = {
      direnv = writeText "${name}-direnv" ''
        set -q __fish_config_direnv_sourced
        or if type -q direnv
          eval (direnv hook fish)
        end
        set -g __fish_config_direnv_sourced 1
      '';
      git = writeText "${name}-git" ''
        set -q __fish_config_git_sourced
        or if status is-interactive; and type -q git
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
        set -g __fish_config_git_sourced 1
      '';
      less = writeText "${name}-less" ''
        set -q __fish_config_less_sourced
        or if status is-login
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
        set -g __fish_config_less_sourced 1
      '';
      lsColors = writeText "${name}-ls-colors" ''
        set -q __fish_config_ls_colors_sourced
        or if status is-login
          eval (dircolors -c ${ls-colors}/share/LS_COLORS/LS_COLORS | sed 's|setenv|set -Ux|')
        end
        set -g __fish_config_ls_colors_sourced 1
      '';
      nix = writeText "${name}-nix" (''
        set -q __fish_config_nix_sourced
        or begin
          [ -d $HOME/repos/nixpkgs ]
          and set NIX_PATH "nixpkgs=$HOME/repos/nixpkgs:$NIX_PATH"
      '' + lib.optionalString stdenv.isDarwin ''
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
        end
        set -g __fish_config_nix_sourced 1
      '');
      misc = writeText "${name}-misc" ''
        set -q __fish_config_misc_sourced
        or if status is-interactive
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
        set -g __fish_config_misc_sourced 1
      '';
    };
  in runCommand name {} ''
    confd="$out/etc/fish/conf.d"
    install -D -m 444 ${cfg.direnv} "$confd"/direnv.fish
    install -D -m 444 ${cfg.git} "$confd"/git.fish
    install -D -m 444 ${cfg.less} "$confd"/less.fish
    install -D -m 444 ${cfg.lsColors} "$confd"/ls-colors.fish
    install -D -m 444 ${cfg.nix} "$confd"/nix.fish
    install -D -m 444 ${cfg.misc} "$confd"/misc.fish
  '';

  jupyter = super.callPackage ../pkgs/jupyter {
    inherit (super.nodePackages_8_x) mathjax;
  };

  ls-colors = super.callPackage ../pkgs/ls-colors {};

  neovim = super.neovim.override {
    withRuby = false;
    configure = {
      customRC = ''
          let $MYVIMRC = $HOME . '/.config/nvim/init.vim'
          if filereadable($MYVIMRC)
          source $MYVIMRC
          else
          echomsg 'Warning: ' . $MYVIMRC . ' is not readable'
          endif
      '';
      packages.default = with super.vimPlugins; {
        start = [ skim vim-nix ];
        opt = [];
      };
    };
  };

  nixify = super.callPackage ../pkgs/nixify {};

  #}}}
  #{{{ Environments

  adminEnv = with self; let
    version = "2018-06-18";
  in buildEnv {
    name = "admin-${version}-env";
    paths = [
      gptfdisk
      nvme-cli
      pciutils
      powertop
      usbutils
      xorg.xdpyinfo
      xorg.xev
    ];
  };

  consoleEnv = with self; let
    version = "2018-07-08";
  in buildEnv {
    name = "console-${version}-env";
    paths = [
      fishConfig
      fishExtraConfig
      (aspellWith {
        lang = "en_US";
        dicts = with aspellDicts; [ en en-computers en-science ];
      })
      (ctagsWith {
        options = with ctagsOptions; [ scheme julia html ];
      })
      direnv
      fd
      feedgnuplot
      file
      fortune
      git
      gnumake
      htop
      jo
      jq
      lf
      neovim
      nixify
      p7zip
      parallel-rust
      rclone
      ripgrep
      rlwrap
      scim
      skim
      sl
      stow
      tree
      tty-clock
      unrar
      unzip
      vim-vint
      wget
    ] ++ lib.optionals stdenv.isLinux [
      patdiff
      trash-cli
      xsel
    ] ++ lib.optionals stdenv.isDarwin [
      darwin.trash
      reattach-to-user-namespace
    ];
  };

  desktopEnv = with self; let
    version = "2018-06-18";
  in buildEnv {
    name = "desktop-${version}-env";
    paths = lib.optionals stdenv.isLinux [
      dropbox-cli
      firefox-devedition-bin
      gimp
      gnucash
      inkscape
      libnotify
      rounded-mgenplus
      slack
      tdesktop
      zathura
    ] ++ lib.optionals stdenv.isDarwin [
      gnome-breeze  # used by GNU Cash
    ];
  };

  juliaEnv = self.callPackage ../pkgs/julia/env.nix {};

  nodejsEnv = with self; let
    nodejs = super.nodejs-8_x;
    yarn = super.yarn.override { inherit nodejs; };
  in buildEnv {
    name = "${nodejs.name}-env";
    paths = [
      nodejs
      yarn
    ];
  };

  rEnv = self.callPackage ../pkgs/R/env.nix {};

  rustEnv = with self; let
    rust-src = stdenv.mkDerivation {
      inherit (rustc.src) name;
      inherit (rustc) src;
      phases = [ "unpackPhase" "installPhase" ];
      installPhase = "cp -r src $out";
    };
    fishConf = writeText "rust-fish-conf" ''
      if status is-interactive
        [ -d "$HOME/.cargo/bin" ]
        and set PATH "$HOME/.cargo/bin" $PATH
        set -q RUST_SRC_PATH
        or set -gx RUST_SRC_PATH "${rust-src}"
      end
    '';
  in buildEnv {
    name = "rust-${rustc.version}-env";
    paths = [
      (runCommand "install-rust-fish-conf" {} ''
        install -D -m 444 ${fishConf} $out/etc/fish/conf.d/rust.fish
      '')
      cargo
      cargo-edit
      cargo-tree
      rustc
      rustracer
    ];
  };

  statsEnv = with self; let
    version = "2018-06-18";
  in buildEnv {
    name = "stats-${version}-env";
    buildInputs = [ makeWrapper ];
    paths = [ jupyter rEnv ];
    postBuild = ''
      for script in "$out"/bin/jupyter*; do
        wrapProgram $script --set JUPYTER_PATH "$out/share/jupyter"
      done
    '';
  };

  texliveEnv = with self; let
    myTexlive = texlive.combine {
      inherit (texlive)
      scheme-basic  # installs collection-{basic,latex}
      collection-luatex
      collection-latexrecommended
      collection-latexextra
      collection-bibtexextra
      collection-fontsrecommended
      collection-fontsextra
      collection-fontutils
      collection-langjapanese
      latexmk
      latexdiff
      revtex;
    };
    version = lib.getVersion myTexlive;
  in buildEnv {
    name = "texlive-${version}-env";
    paths = [
      ghostscript  # required by LaTeXiT
      myTexlive
    ] ++ (with haskellPackages; [
      pandoc
      pandoc-citeproc
      pandoc-crossref
    ]);
  };

  #}}}
}

# vim: fdm=marker
