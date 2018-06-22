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

    jupyter = super.callPackage ./pkgs/jupyter {
      inherit (super.nodePackages_8_x) mathjax;
    };

    neovim = with super;
    neovim.override {
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

    pandoc-crossref_0_3_0_2 = with super;
    haskell.lib.overrideCabal haskellPackages.pandoc-crossref (_: {
      version = "0.3.0.2";
      sha256 = "1igxa3pmb66gw5jgpdpx5gb7b4pi1w1r1ny0jpbfz4drbnblh320";
      editedCabalFile = "15qr0r5753whzdh92c9kpdpddwqhvaah0yl1i0a29363h5whgk4a";
    });

    # }}}
    # Environments {{{

    adminEnv = with self;
    let version = "2018-06-18"; in
    buildEnv {
      name = "admin-${version}-env";
      paths = [
        gptfdisk
        nvme-cli
        pciutils
        powertop
        usbutils
        xorg.xev
        xorg.xdpyinfo
      ];
    };

    consoleEnv = with self;
    let version = "2018-06-18"; in
    buildEnv {
      name = "console-${version}-env";
      paths = [
        (aspellWithDicts (dicts: with dicts; [ en ]))
        fd
        file
        fortune
        git
        gnumake
        htop
        jq
        lf
        neovim
        p7zip
        parallel-rust
        # patdiff
        rclone
        ripgrep
        rlwrap
        scim
        skim
        sl
        stow
        tree
        tty-clock
        universal-ctags
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

    desktopEnv = with self;
    let version = "2018-06-18"; in
    buildEnv {
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

    juliaEnv = self.callPackage ./pkgs/julia/env.nix {};

    nodejsEnv = with self;
    let
      nodejs = super.nodejs-8_x;
      yarn = super.yarn.override { inherit nodejs; };
    in
    buildEnv {
      name = "${nodejs.name}-env";
      paths = [
        nodejs
        yarn
      ];
    };

    rEnv = self.callPackage ./pkgs/R/env.nix {};

    rustEnv = with self;
    let
      inherit (rustChannelOf {
        date = "2018-06-20";
        channel = "nightly";
      }) rust;
    in
    buildEnv {
      name = "${rust.name}-env";
      paths = [
        carnix
        rust
        rustracer
      ];
    };

    statsEnv = with self;
    let version = "2018-06-18"; in
    buildEnv {
      name = "stats-${version}-env";
      buildInputs = [ makeWrapper ];
      paths = [ jupyter rEnv ];
      postBuild = ''
        for script in "$out"/bin/jupyter*; do
          wrapProgram $script --set JUPYTER_PATH "$out/share/jupyter"
        done
      '';
    };

    texliveEnv = with self;
    let
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
    in
    buildEnv {
      name = "texlive-${version}-env";
      paths = [
        ghostscript  # required by LaTeXiT
        myTexlive
      ] ++ (with haskellPackages; [
        pandoc
        pandoc-citeproc
        pandoc-crossref_0_3_0_2  # compatible with the current pandoc (2.1.2)
      ]);
    };

  #}}}
  };
}

# vim: fdm=marker
