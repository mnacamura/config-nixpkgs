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
        jp-format-vim
        lightline-ale
        lightline-vim
        skim
        srcery-vim
        tagbar
        vim-commentary
        vim-easy-align
        vim-nix
        vim-pandoc
        vim-pandoc-syntax
        vim-sensible
        vim-sandwich
        vim-textobj-comment
        vim-textobj-indent
        vim-textobj-user
        vim-unimpaired
        vim-visualstar
        vim-yoink
        vim-wordmotion
      ];

      opt = [
      ];
    };
  };
}
