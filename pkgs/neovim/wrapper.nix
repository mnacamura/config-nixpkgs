{ neovim, vimPlugins, configFile }:


neovim.override {
  configure = {
    customRC = ''
      let $MYVIMRC = '${configFile}'
      source $MYVIMRC
    '';

    packages.default = with vimPlugins; {
      start = [
        ale
        bullets-vim
        clever-f-vim
        iron-nvim
        jp-format-vim
        lightline-ale
        lightline-vim
        nvim-treesitter
        requirements-txt-vim
        skim
        skim-vim
        srcery-vim
        tagbar
        vim-commentary
        vim-easy-align
        vim-emacscommandline
        vim-fish
        vim-nix
        vim-pandoc
        vim-pandoc-syntax
        vim-repeat
        vim-sensible
        vim-sandwich
        vim-speeddating
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
