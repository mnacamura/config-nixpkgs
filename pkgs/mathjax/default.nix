{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "mathjax-${version}";
  version = "2.7.4";

  src = fetchFromGitHub {
    owner = "mathjax";
    repo = "MathJax";
    rev = "${version}";
    sha256 = "0c39vabjxc59yr2m26ygchy7ya21j25lh6dgqfrfn43hsi75k7cl";
  };

  installPhase = ''
    mkdir -p $out/share/MathJax
    cp -R . $out/share/MathJax/
  '';

  meta = with stdenv.lib; {
    homepage = https://www.mathjax.org;
    description = "A JavaScript display engine for mathematics that works in all browsers";
    license = licenses.asl20;
    platforms = platforms.all;
    maintainers = with maintainers; [ ];
  };
}
