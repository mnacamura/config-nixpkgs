{ neovim, vimPlugins, configFile }:

neovim.override {
  configure = {
    customRC = ''
      let $MYVIMRC = '${configFile}'
      source $MYVIMRC
    '';

    packages.default = with vimPlugins; {
      start = [
        lightline-ale
        lightline-vim
        skim
        srcery-vim
        iron-nvim
        vim-nix
      ];

      opt = [
      ];
    };
  };
}
