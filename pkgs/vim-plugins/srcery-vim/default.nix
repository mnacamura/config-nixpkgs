{ config, substituteAll, vimUtils, fetchFromGitHub }:

let
  inherit (config.environment.colors) palette;

  themePatch = substituteAll (with palette; {
    src = ./theme.patch;

    black_hex   = black.hex;
    red_hex     = red.hex;
    green_hex   = green.hex;
    yellow_hex  = yellow.hex;
    blue_hex    = blue.hex;
    magenta_hex = magenta.hex;
    cyan_hex    = cyan.hex;
    white_hex   = white.hex;
    black_nr   = black.nr;
    red_nr     = red.nr;
    green_nr   = green.nr;
    yellow_nr  = yellow.nr;
    blue_nr    = blue.nr;
    magenta_nr = magenta.nr;
    cyan_nr    = cyan.nr;
    white_nr   = white.nr;
    brblack_hex   = brblack.hex;
    brred_hex     = brred.hex;
    brgreen_hex   = brgreen.hex;
    bryellow_hex  = bryellow.hex;
    brblue_hex    = brblue.hex;
    brmagenta_hex = brmagenta.hex;
    brcyan_hex    = brcyan.hex;
    brwhite_hex   = brwhite.hex;
    brblack_nr   = brblack.nr;
    brred_nr     = brred.nr;
    brgreen_nr   = brgreen.nr;
    bryellow_nr  = bryellow.nr;
    brblue_nr    = brblue.nr;
    brmagenta_nr = brmagenta.nr;
    brcyan_nr    = brcyan.nr;
    brwhite_nr   = brwhite.nr;
  });
in

vimUtils.buildVimPlugin {
  pname = "srcery-vim";
  version = "2021-04-14";

  src = fetchFromGitHub {
    owner = "srcery-colors";
    repo = "srcery-vim";
    rev = "9c692e3f17b3485969b55d76a708136e2ccaa5de";
    sha256 = "1cd4vxx0zb4xcn2yp7kl5xgl8crfr0fwifn4apkn878lqx6ni7gj";
  };

  patches = [ themePatch ];
}
