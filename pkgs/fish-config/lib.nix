{ lib, writeText, runCommand }:

let
  inherit (lib) replaceStrings;

  writeFishScriptTo = path: name: body:
  let
    # Shell variable name may contain letters, digits, and underscores
    name_ = replaceStrings ["-" "."] ["_" "_"] name;
    path_ = replaceStrings ["/" "-" "."] ["_" "_" "_"] path;

    path' = replaceStrings ["/"] ["-"] path;

    configFile = writeText "${name}.fish" ''
      set -q __fish${path_}_${name_}_sourced; or begin
      ${body}
      end
      set -g __fish${path_}_${name_}_sourced 1
    '';
  in
  runCommand "fish${path'}-${name}" {} ''
    install -D -m 444 "${configFile}" "$out${path}/${name}.fish"
  '';
in

{
  writeFishConfig = writeFishScriptTo "/etc/fish/conf.d";

  writeFishVendorConfig = writeFishScriptTo "/share/fish/vendor_conf.d";
}
