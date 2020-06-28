{ neovim, vimPlugins, configFile }:


neovim.override {
  configure = {
    customRC = ''
      let $MYVIMRC = '${configFile}'
      source $MYVIMRC
    '';

    packages.default = with vimPlugins; {
      start = [
        clever-f-vim
        iron-nvim
        lightline-ale
        lightline-vim
        skim
        srcery-vim
        vim-nix
        vim-sensible
        vim-sandwich
        vim-unimpaired
        vim-yoink
        vim-wordmotion
      ];

      opt = [
      ];
    };
  };
}
