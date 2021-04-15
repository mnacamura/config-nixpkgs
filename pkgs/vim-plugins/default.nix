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
    version = "2020-06-04";
    src = fetchFromGitHub {
      owner = "hkupty";
      repo = "iron.nvim";
      rev = "16c52eaf18f2b4ffd986d5a4b36fcab47a4a9f90";
      sha256 = "0319j7gf6wz271imazyav0vzf15a98qbyp4mrnng06hxf5x7sxyj";
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
