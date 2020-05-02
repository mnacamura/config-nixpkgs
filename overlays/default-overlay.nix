self: super:

{
  config = with self.lib; recursiveUpdate super.config {
    colortheme = let
      inherit (super.config.colortheme) palette;

      nr = mapAttrs (_: c: c.nr) (filterAttrs (_: c: c ? nr) palette);

      hex = mapAttrs (_: c: c.hex) palette;

      has16Colors = let
        definedNames = attrNames palette;
        expectedNames = [
          "black"   "red"   "green"   "yellow"   "blue"   "magenta"   "cyan"   "white"
          "brblack" "brred" "brgreen" "bryellow" "brblue" "brmagenta" "brcyan" "brwhite"
        ];
      in
      all (n: elem n definedNames) expectedNames;

      hasHexColors = all (b: b) (mapAttrsToList (_: c: c ? hex) palette);

      hasValidXTermColorNr = all isXTermColorNr (attrValues nr);

      hasValidHexColorCode = all isHexColorCode (attrValues hex);

      isXTermColorNr = n: isInt n && 0 <= n && n < 256;

      isHexColorCode = s:
      let
        prefix = substring 0 1 s;
        body = substring 1 7 s;
      in
      stringLength s == 7 && prefix == "#" && isHexString body; 

      isHexString = let
        hexChars = stringToCharacters "0123456789abcdef";
      in
      s: all (c: elem c hexChars) (stringToCharacters (toLower s));
    in
    assert assertMsg has16Colors "colortheme: at least 16 colors should be defined";
    assert assertMsg hasHexColors "colortheme: color(s) with no hex value found";
    assert assertMsg hasValidXTermColorNr "colortheme: invalid xterm color number found";
    assert assertMsg hasValidHexColorCode "colortheme: invalid hex color code found";
    {
      inherit nr hex;
    };
  };

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
