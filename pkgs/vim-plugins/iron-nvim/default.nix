{ vimUtils, fetchFromGitHub }:

vimUtils.buildVimPlugin {
  pname = "iron-nvim";
  version = "2020-06-04";

  src = fetchFromGitHub {
    owner = "hkupty";
    repo = "iron.nvim";
    rev = "16c52eaf18f2b4ffd986d5a4b36fcab47a4a9f90";
    sha256 = "0319j7gf6wz271imazyav0vzf15a98qbyp4mrnng06hxf5x7sxyj";
  };
}
