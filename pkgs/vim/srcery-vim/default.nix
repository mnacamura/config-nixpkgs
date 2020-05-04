{ vimUtils, fetchFromGitHub }:

vimUtils.buildVimPlugin {
  pname = "srcery-vim";
  version = "2020-03-15";

  src = fetchFromGitHub {
    owner = "srcery-colors";
    repo = "srcery-vim";
    rev = "099d871aa26df29e892acb5b8b3f1766a7199021";
    sha256 = "0wn82gib4ambvanb34hzj6nanpy2ybaw9dxj9d2fml4i3wfg2cps";
  };
}
