{ callPackage }:

{
  srcery-vim = callPackage ./srcery-vim {};

  iron-nvim = callPackage ./iron-nvim {};

  vim-yoink = callPackage ./vim-yoink {};
}
