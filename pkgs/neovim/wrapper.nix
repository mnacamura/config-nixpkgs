{ neovim, vimPlugins, substituteAll }:

let
  vimrc = substituteAll {
    src = ./init.vim;
  };
in

neovim.override {
  configure = {
    customRC = ''
      let $MYVIMRC = '${vimrc}'
      source $MYVIMRC
    '';

    packages.default = with vimPlugins; {
      start = [
        lightline-ale
        lightline-vim
        skim
        srcery-vim
        vim-nix
      ];

      opt = [
      ];
    };
  };
}
