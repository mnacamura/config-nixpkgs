{
  allowUnfree = true;
  # allowBroken = true;

  packageOverrides = super: let self = super.pkgs; in {

    consoleEnv = with self; lib.lowPrio (buildEnv {
      name = "console-env";
      ignoreCollisions = true;
      paths = [
        (aspellWithDicts (ps: with ps; [ en ]))
        binutils.bintools
        bzip2
        ccache
        coreutils
        diffutils
        fd
        findutils
        fortune
        gawk
        git
        gnugrep
        gnumake
        gnused
        gnutar
        gzip
        neovim
        p7zip
        parallel-rust
        patch
        # patdiff
        ripgrep
        skim
        sl
        tmux
        tree
        universal-ctags
        unrar
        vim-vint
        xz
      ] ++ lib.optionals stdenv.isDarwin [
        reattach-to-user-namespace
      ] ++ lib.optionals stdenv.isLinux [
        patdiff
        trash-cli
        xsel
      ];
    });

    ccacheWrapper = with super; ccacheWrapper.override {
      extraConfig = ''
        export CCACHE_COMPRESS=1
        export CCACHE_DIR=/var/cache/ccache
        export CCACHE_UMASK=007
      '';
    };

    neovim = with super; neovim.override {
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
        packages.default = with vimPlugins; {
          start = [ skim ];
          opt = [];
        };
      };
    };

    desktopEnv = with self; buildEnv {
      name = "desktop-env";
      ignoreCollisions = true;
      paths = lib.optionals stdenv.isDarwin [
        gnome-breeze  # used by GNU Cash
      ] ++ lib.optionals stdenv.isLinux [
        dropbox-cli
        firefox-devedition-bin
        gimp
        inkscape
        kdeApplications.okular
        kdeApplications.spectacle
        mathematica
      ];
    };

    mathematica = super.mathematica.override { lang = "ja"; };

    texliveEnv = with self; let myTexlive = texlive.combine {
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
    version = lib.getVersion myTexlive; in buildEnv {
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

    statsEnv = with self; buildEnv {
      name = "stats-env";
      buildInputs = [ makeWrapper ];
      paths = [ jupyterEnv rEnv juliaEnv ];
      postBuild = ''
        wrapProgram $out/bin/jupyter --set JUPYTER_PATH $out/share/jupyter
      '';
    };

    jupyterEnv = with self; callPackage ./pkgs/jupyter {};

    rEnv = with self; callPackages ./pkgs/R {};

    juliaEnv = with self; callPackages ./pkgs/julia {};

    rustEnv = with self;
    let version = rustc.version; in buildEnv {
      name = "rust-${version}-env";
      paths = [
        cargo
        rustc
        # rustfmt
        # rustracer
      ];
    };

    nodejsEnv = with self;
    let version = nodejs.version; in buildEnv {
      name = "nodejs-${version}-env";
      paths = [
        nodejs
        yarn
      ];
    };
  };
}
