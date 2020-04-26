{ lib, writeText, runCommand }:

let
  inherit (lib) genList length replaceStrings;

  replaceStrings1 = froms: to:
  replaceStrings froms (genList (_: to) (length froms));

  writeFishScriptTo = path: name: body:
  let
    # Shell variable name may contain letters, digits, and underscores
    _path = replaceStrings1 ["/" "-" "."] "_" path;
    _name = replaceStrings1 ["-" "."] "_" name;
    __var = "__fish${_path}_${_name}_sourced";

    path' = replaceStrings1 ["/"] "-" path;

    script = writeText "${name}.fish" ''
      set -q ${__var}; or begin

      ${body}
      end
      set -g ${__var} 1
    '';
  in
  runCommand "fish${path'}-${name}" {} ''
    install -D -m 444 "${script}" "$out${path}/${name}.fish"
  '';
in

{
  writeFishConfig = writeFishScriptTo "/etc/fish/conf.d";

  writeFishVendorConfig = writeFishScriptTo "/share/fish/vendor_conf.d";
}
