{ vimUtils, fetchFromGitHub }:

vimUtils.buildVimPlugin {
  pname = "clever-f-vim";
  version = "2020-04-15";

  src = fetchFromGitHub {
    owner = "rhysd";
    repo = "clever-f.vim";
    rev = "c9c444d36dc52b1989f769946435cf0541fab38b";
    sha256 = "1fy4prd5y544jw4qk9v732jwy4yj52632iq3nxl587cmwjlijxpa";
  };
}
