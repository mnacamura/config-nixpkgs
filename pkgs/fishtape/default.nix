{ lib, stdenv, fetchFromGitHub, fetchpatch, fish }:

stdenv.mkDerivation rec {
  pname = "fishtape";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "jorgebucaran";
    repo = pname;
    rev = version;
    sha256 = "0ni7b9kgv7zif72p21vf4816p2nsj14m853p1kdvbsrhlzhlyanh";
  };

  patches = [
    # Bug fix: return correct status code after tests
    (fetchpatch {
      url = "https://github.com/jorgebucaran/fishtape/commit/c5e9690054765a4dad1fba7fed6c846d38b5dcc2.patch";
      sha256 = "1csqcxx1kmidig7al67a7jy35nm32x5gb9vk1ajqi8pz26y7cr2i";
    })
  ];

  installPhase = ''
    runHook preInstall

    # fishtape is a fish function and not available if it is not in
    # fish_function_path. This is inconvenient for using fishtape in
    # nix-shell. Wrapping fishtape as an executable enables it anyway.
    mkdir -p $out/bin
    cat > $out/bin/fishtape <<EOF
    #!${fish}/bin/fish
    EOF
    sed '/^complete /d' fishtape.fish >> $out/bin/fishtape
    echo 'fishtape $argv' >> $out/bin/fishtape
    chmod +x "$out/bin/fishtape"

    # Install shell completion
    d=$out/share/fish/vendor_completions.d
    mkdir -p "$d"
    sed '/^\(set -g fishtape_version\|complete \)/!d' fishtape.fish > "$d/fishtape.fish"

    runHook postInstall
  '';

  meta = with lib; {
    description = "TAP-based test runner for the fish shell";
    homepage = "https://github.com/jorgebucaran/fishtape/";
    license = licenses.mit;
    maintainers = with maintainers; [ mnacamura ];
    platforms = platforms.unix;
  };
}
