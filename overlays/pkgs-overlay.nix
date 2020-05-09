self: super:

{
  wrapped.aspell = self.aspellWith {
    lang = "en_US";
    dicts = with self.aspellDicts; [
      en
      en-computers
      en-science
    ];
  };

  aspellWith = self.callPackage ../pkgs/aspell/with.nix {};

  wrapped.ctags = self.ctagsWith {
    options = with self.ctagsOptions; [
    ];
  };

  ctagsWith = self.callPackage ../pkgs/ctags/with.nix {
    ctags = super.universal-ctags;
  };

  ctagsOptions = import ../pkgs/ctags/options.nix;

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

  wrapped.direnv = self.callPackage ../pkgs/direnv/wrapper.nix {};

  configFiles.fish = self.callPackage ../pkgs/fish/config.nix {
    config-core = self.callPackage ../pkgs/fish/config-core.nix {};
  };

  inherit (self.callPackage ../pkgs/fish/lib.nix {})
  writeFishConfig
  writeFishVendorConfig;

  ls-colors = self.callPackage ../pkgs/ls-colors {};

  mgenplus = self.callPackage ../pkgs/mgenplus {};

  neovim = super.neovim.override {
    withRuby = false;
  };

  configFiles.neovim = self.callPackage ../pkgs/neovim/config.nix {};

  wrapped.neovim = self.callPackage ../pkgs/neovim/wrapper.nix {
    configFile = self.configFiles.neovim;
  };

  vimPlugins = with super; vimPlugins // {
     srcery-vim = self.callPackage ../pkgs/vim/srcery-vim {};
  };

  python3 = super.python3.override ({
    packageOverrides = pyself: pysuper:
    {
      colorthief = pyself.callPackage ../pkgs/python/colorthief {};

      colorz = pyself.callPackage ../pkgs/python/colorz {};

      haishoku = pyself.callPackage ../pkgs/python/haishoku {};
    };
  });

  rounded-sgenplus = super.callPackage ../pkgs/rounded-sgenplus {};

  SDL2 = super.SDL2.override {
    fcitxSupport = self.stdenv.isLinux;
  };

  themix-gui = self.callPackage ../pkgs/themix/gui {
    unwrapped = self.callPackage ../pkgs/themix/gui/unwrapped.nix {};
    plugins = with self.themixPlugins; [
      (import-images.override {
        enableColorthief = true;
        enableColorz = true;
        enableHaishoku = true;
      })
      theme-oomox
      icons-papirus
    ];
  };

  themixPlugins = {
    import-images = self.callPackage ../pkgs/themix/import-images {};

    theme-oomox = self.callPackage ../pkgs/themix/theme-oomox {};

    icons-papirus = self.callPackage ../pkgs/themix/icons-papirus {};
  };

  xtermcolor = self.callPackage ../pkgs/xtermcolor {};

  configFiles.zathura = self.callPackage ../pkgs/zathura/config.nix {};

  wrapped.zathura = self.callPackage ../pkgs/zathura/wrapper.nix {
    configFile = self.configFiles.zathura;
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
    version = "2020-04-22";
  in buildEnv {
    name = "console-${version}-env";
    paths = [
      configFiles.fish
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
      wrapped.neovim
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
    version = "2020-04-30";
  in buildEnv {
    name = "desktop-${version}-env";
    paths = lib.optionals stdenv.isLinux [
      latest.firefox-nightly-bin
      wrapped.zathura
      # mgenplus
      # rounded-mgenplus
      # slack
      tdesktop
    ] ++ lib.optionals stdenv.isDarwin [
    ];
  };
}
