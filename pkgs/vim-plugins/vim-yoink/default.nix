{ vimUtils, fetchFromGitHub }:

vimUtils.buildVimPlugin {
  pname = "vim-yoink";
  version = "2020-05-23";

  src = fetchFromGitHub {
    owner = "svermeulen";
    repo = "vim-yoink";
    rev = "17b349d49156887d9203e3fac6fa072746f505c0";
    sha256 = "1whmgq368f7ppsmncz4nr9qc5wjjw5kjxizsadjm2zii1b3pifdc";
  };
}
