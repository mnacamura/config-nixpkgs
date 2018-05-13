{
  allowUnfree = true;
  # allowBroken = true;

  packageOverrides = super: let self = super.pkgs; in {
    # Custom packages {{{

    ccacheWrapper = super.ccacheWrapper.override {
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

    mathjax = super.callPackage ./pkgs/mathjax {};

    jupyter = super.callPackage ./pkgs/jupyter {};

    # }}}
    # Environments {{{

    adminEnv = with self; buildEnv {
      name = "admin-env";
      paths = [
        gptfdisk
        htop
        nvme-cli
        pciutils
        powertop
        usbutils
        xorg.xev
        xorg.xdpyinfo
      ];
    };

    consoleEnv = with self; lib.lowPrio (buildEnv {
      name = "console-env";
      ignoreCollisions = true;
      paths = [
        (aspellWithDicts (dicts: with dicts; [ en ]))
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
        stow
        tmux
        tree
        universal-ctags
        unrar
        unzip
        vim-vint
        xz
      ] ++ lib.optionals stdenv.isDarwin [
        reattach-to-user-namespace
        binutils.bintools
      ] ++ lib.optionals stdenv.isLinux [
        patdiff
        trash-cli
        xsel
      ];
    });

    desktopEnv = with self; buildEnv {
      name = "desktop-env";
      ignoreCollisions = true;
      paths = lib.optionals stdenv.isDarwin [
        gnome-breeze  # used by GNU Cash
      ] ++ lib.optionals stdenv.isLinux [
        autorandr
        btops
        dropbox-cli
        firefox-devedition-bin
        gimp
        gnucash
        inkscape
        libnotify
        rounded-mgenplus
        slack
        zathura
      ];
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

    statsEnv = with self; buildEnv {
      name = "stats-env";
      buildInputs = [ makeWrapper ];
      paths = [ jupyter rEnv ];
      postBuild = ''
        for script in "$out"/bin/jupyter*; do
          wrapProgram $script --set JUPYTER_PATH "$out/share/jupyter"
        done
      '';
    };

    rEnv = self.callPackage ./pkgs/R/env.nix {};

    juliaEnv = with self; callPackage ./pkgs/julia/env.nix {};

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

  #}}}
}

# vim: fdm=marker
