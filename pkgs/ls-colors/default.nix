{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "LS_COLORS";
  version = "2020-04-01";

  src = fetchFromGitHub {
    owner = "trapd00r";
    repo = pname;
    rev = "da2f061feb4977bc5e3dfdb16ab65d93b3eca1ca";
    sha256 = "1yw4qz152r9jsg4v4n592gngfvwkcrkj68hrhm6n6d0qj6f6qf68";
  };

  buildCommand = ''
    install -D -m 444 $src/LS_COLORS -t $out/share/${pname};
  '';
}
