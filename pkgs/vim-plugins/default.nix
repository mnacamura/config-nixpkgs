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
    version = "2020-10-14";
    src = fetchFromGitHub {
      owner = "svermeulen";
      repo = "vim-yoink";
      rev = "b973fce71d45fe7c290119448651da7a1b9943a1";
      sha256 = "1cjrv55x340i5c87pd8z3l27f2jl98p0v20hr77is8f9fi3ja40d";
    };
  };

  vim-wordmotion = buildVimPlugin {
    pname = "vim-wordmotion";
    version = "2021-03-14";

    src = fetchFromGitHub {
      owner = "chaoren";
      repo = "vim-wordmotion";
      rev = "e1638ba4fb357e1c5ec0230806851371ffb89cb0";
      sha256 = "00k95nkwwm857vmpfixpp5qlmzmnscpz6c9vvb5idxknx4wbnzlx";
    };
  };
}
