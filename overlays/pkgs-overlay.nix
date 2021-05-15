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
    base = self.callPackage ../pkgs/fish/config-base.nix {};
  };

  inherit (self.callPackage ../pkgs/fish/lib.nix {})
  writeFishConfig
  writeFishVendorConfig;

  fishtape = self.callPackage ../pkgs/fishtape {};

  neovim = super.neovim.override {
    withRuby = false;
  };

  neovim-unwrapped = super.neovim-unwrapped.overrideAttrs (old: {
    version = "2021-04-24";
    src = super.fetchFromGitHub {
      owner = "neovim";
      repo = "neovim";
      rev = "bb7d3790bf08b5519623d261d8235bad77b5c0dd";
      sha256 = "1d3a53fp8grv477nqz7ik21r3bzrm8mdgx9c7mfzs6i1xyh1wldf";
    };
    buildInputs = old.buildInputs ++ [ super.tree-sitter ];
  });

  configFiles.neovim = self.callPackage ../pkgs/neovim/config.nix {};

  wrapped.neovim = self.callPackage ../pkgs/neovim/wrapper.nix {
    configFile = self.configFiles.neovim;
  };

  vimPlugins = super.vimPlugins // (self.callPackage ../pkgs/vim-plugins {});

  SDL2 = super.SDL2.override {
    fcitxSupport = self.stdenv.isLinux;
  };

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
    version = "2021-04-23";
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
      lsd
      wrapped.neovim
      tree-sitter   # required to compile tree-sitter parsers
      stdenv.cc.cc  # required to compile tree-sitter parsers
      nodejs        # required to compile tree-sitter parsers
      # nixify-unstable
      libarchive
      # parallel-rust
      p7zip
      patdiff
      pubs
      rclone
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
    version = "2020-06-01";
  in buildEnv {
    name = "desktop-${version}-env";
    paths = lib.optionals stdenv.isLinux [
      # latest.firefox-nightly-bin
      wrapped.zathura
      # mgenplus
      # rounded-mgenplus
      # slack
      # tdesktop
    ] ++ lib.optionals stdenv.isDarwin [
    ];
  };
}
