{ callPackage, vimUtils, fetchFromGitHub }:

let
  inherit (vimUtils) buildVimPlugin;
in

{
  clever-f-vim = buildVimPlugin {
    pname = "clever-f-vim";
    version = "2021-03-05";
    src = fetchFromGitHub {
      owner = "rhysd";
      repo = "clever-f.vim";
      rev = "3e79731f81ce7fba641c5dd5803f0978238d6204";
      sha256 = "0py012wq78ikrxm1wsdk4p052l2bwz0hhnwig0601smcbni5ak86";
    };
  };

  iron-nvim = buildVimPlugin {
    pname = "iron-nvim";
    version = "2021-01-20";
    src = fetchFromGitHub {
      owner = "hkupty";
      repo = "iron.nvim";
      rev = "941bb06eadae1140925ad64a20fb31f405984edb";
      sha256 = "1xg8sfhlb8gaj3034j9iwdvm1brf18f68xngalpiymsq1253f7lk";
    };
  };

  srcery-vim = callPackage ./srcery-vim {};

  vim-yoink = buildVimPlugin {
    pname = "vim-yoink";
    version = "2020-05-23";
    src = fetchFromGitHub {
      owner = "svermeulen";
      repo = "vim-yoink";
      rev = "17b349d49156887d9203e3fac6fa072746f505c0";
      sha256 = "1whmgq368f7ppsmncz4nr9qc5wjjw5kjxizsadjm2zii1b3pifdc";
    };
  };

  vim-wordmotion = buildVimPlugin {
    pname = "vim-wordmotion";
    version = "2020-01-06";

    src = fetchFromGitHub {
      owner = "chaoren";
      repo = "vim-wordmotion";
      rev = "d4a1db684ec0a0e49f626c8cf5d7e7c518f613a6";
      sha256 = "0p0x56cxvw96284w45nc11sv41986jqqxpfc3kyjaxhcqzlq4lkm";
    };
  };
}
