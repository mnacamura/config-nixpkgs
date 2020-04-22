self: super:

{
  wrapped = {
    aspell = self.aspellWith {
      lang = "en_US";
      dicts = with super.aspellDicts; [
        en
        en-computers
        en-science
      ];
    };

    ctags = self.ctagsWith {
      options = with self.ctagsOptions; [
      ];
    };

    direnv = self.callPackage ../pkgs/direnv/wrapped.nix {};
  };

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

  inherit (super.callPackage ../pkgs/fish-config/lib.nix {})
  writeFishConfig
  writeFishVendorConfig;

  fishConfig = super.callPackage ../pkgs/fish-config {};

  fishConfigFull = self.callPackage ../pkgs/fish-config/full.nix {};

  ls-colors = super.callPackage ../pkgs/ls-colors {};

  mgenplus = super.callPackage ../pkgs/mgenplus {};

  neovim = super.neovim.override {
    withRuby = false;
    configure = {
      customRC = let
        vimrc = self.callPackage ../pkgs/vimrc {};
      in ''
        source ${vimrc}
        let $MYVIMRC = $HOME . '/.config/nvim/init.vim'
        if filereadable($MYVIMRC)
          source $MYVIMRC
        else
          echomsg 'Warning: ' . $MYVIMRC . ' is not readable'
        endif
      '';
      packages.default = with self.vimPlugins; {
        start = [
          lightline-ale
          lightline-vim
          skim
          srcery-vim
          vim-nix
        ];
        opt = [];
      };
    };
  };

  vimPlugins = with super; vimPlugins // {
    srcery-vim = vimUtils.buildVimPlugin {
      pname = "srcery-vim";
      version = "2020-03-15";
      src = fetchFromGitHub {
        owner = "srcery-colors";
        repo = "srcery-vim";
        rev = "099d871aa26df29e892acb5b8b3f1766a7199021";
        sha256 = "0wn82gib4ambvanb34hzj6nanpy2ybaw9dxj9d2fml4i3wfg2cps";
      };
    };
  };

  nixify = super.callPackage ../pkgs/nixify {};

  rounded-sgenplus = super.callPackage ../pkgs/rounded-sgenplus {};

  SDL2 = super.SDL2.override {
    fcitxSupport = self.stdenv.isLinux;
  };

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
    version = "2020-02-18";
  in buildEnv {
    name = "console-${version}-env";
    paths = [
      fishConfigFull
      wrapped.aspell
      wrapped.ctags
      wrapped.direnv
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
      # papis
      # parallel-rust
      # rclone
      ripgrep
      skim
      sl
      tree
      # tty-clock
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
    version = "2020-03-05";
  in buildEnv {
    name = "desktop-${version}-env";
    paths = lib.optionals stdenv.isLinux [
      latest.firefox-nightly-bin
      # mgenplus
      # rounded-mgenplus
      # slack
      tdesktop
    ] ++ lib.optionals stdenv.isDarwin [
    ];
  };
}
