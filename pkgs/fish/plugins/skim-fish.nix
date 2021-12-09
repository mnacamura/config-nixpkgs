{ lib, fzf-fish, fetchFromGitHub }:

let
  pname = "skim.fish";
  version = "2021-12-05";
in

fzf-fish.overrideAttrs (old: {
  name = "${pname}-${version}";
  src = fetchFromGitHub {
    owner = "mnacamura";
    repo = "skim.fish";
    rev = "655171dcebbc0ada0a57076aef5fbc524584f69b";
    sha256 = "sha256-OoHZXyukVc2JW09GwfjgQn/sppP1eS3wfO5tKebEbcM=";
  };

  doCheck = false;

  meta = with lib; {
    description = "Augment your fish command line with skim key bindings";
    homepage = "https://github.com/mnacamura/skim.fish";
    license = licenses.mit;
    maintainers = with maintainers; [ mnacamura ];
  };
})
