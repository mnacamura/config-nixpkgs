{ stdenv, fetchFromGitHub }:

let
  pname = "LS_COLORS";
  version = "2018-08-07";
in

stdenv.mkDerivation {
  name = "${pname}-${version}";

  src = fetchFromGitHub {
    owner = "trapd00r";
    repo = pname;
    rev = "0e974280d43cd235805727944dfdcb099d739e25";
    sha256 = "0d6a2r670ldys28agd5c6mrjjmm2c4000k2xh8aahc56ylgyx7cg";
  };

  buildCommand = ''
    install -D -m 444 $src/LS_COLORS -t $out/share/${pname};
  '';
}
