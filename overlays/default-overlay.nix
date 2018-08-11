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
    name = "${ctags.name}-wrapper";
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

  fishConfig = super.callPackage ../pkgs/fish-config {};

  fishConfigAll = self.callPackage ../pkgs/fish-config/all.nix {};

  writeFishConfig = name: body:
  with super; let
    name_ = lib.replaceStrings ["-"] ["_"] name;
    configFile = writeText "${name}.fish" ''
      set -q __fish_config_${name_}_sourced; or begin
      ${body}
      end
      set -g __fish_config_${name_}_sourced 1
    '';
  in runCommand "fish-config-${name}" {} ''
    install -D -m 444 ${configFile} $out/etc/fish/conf.d/${name}.fish
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
    version = "2018-08-08";
  in buildEnv {
    name = "console-${version}-env";
    paths = [
      fishConfigAll
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
