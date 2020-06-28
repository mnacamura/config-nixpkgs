{ vimUtils, fetchFromGitHub }:

vimUtils.buildVimPlugin {
  pname = "vim-wordmotion";
  version = "2020-01-06";

  src = fetchFromGitHub {
    owner = "chaoren";
    repo = "vim-wordmotion";
    rev = "d4a1db684ec0a0e49f626c8cf5d7e7c518f613a6";
    sha256 = "0p0x56cxvw96284w45nc11sv41986jqqxpfc3kyjaxhcqzlq4lkm";
  };
}
