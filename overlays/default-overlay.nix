self: super:

{
  #{{{ Custom packages

  aspellWith = super.callPackage ../pkgs/aspell/with.nix {};

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

  ctagsWith = super.callPackage ../pkgs/ctags/with.nix {
    ctags = super.universal-ctags;
  };

  ctagsOptions = import ../pkgs/ctags/options.nix;

  direnvWrapped = self.callPackage ../pkgs/direnv/wrapped.nix {};

  inherit (super.callPackage ../pkgs/fish-config/lib.nix {})
  writeFishConfig
  writeFishVendorConfig;

  fishConfig = super.callPackage ../pkgs/fish-config {};

  fishConfigFull = self.callPackage ../pkgs/fish-config/full.nix {};

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

  rounded-sgenplus = super.callPackage ../pkgs/rounded-sgenplus {};

  SDL2 = super.SDL2.override {
    fcitxSupport = self.stdenv.isLinux;
  };

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
    version = "2019-05-11";
  in buildEnv {
    name = "console-${version}-env";
    paths = [
      fishConfigFull
      (aspellWith {
        lang = "en_US";
        dicts = with aspellDicts; [ en en-computers en-science ];
      })
      (ctagsWith {
        options = with ctagsOptions; [ ];
      })
      direnvWrapped
      fd
      file
      fortune
      git
      gnumake
      htop
      lf
      neovim
      nixify
      p7zip
      parallel-rust
      # ocamlPackages.cpdf
      # rclone
      ripgrep
      skim
      sl
      tree
      tty-clock
      unrar
      unzip
    ] ++ lib.optionals stdenv.isLinux [
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
      # gimp
      # gnucash
      # inkscape
      rounded-mgenplus
      slack
      tdesktop
    ] ++ lib.optionals stdenv.isDarwin [
      gnome-breeze  # used by GNU Cash
    ];
  };

  #}}}
}

# vim: fdm=marker
