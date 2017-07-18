{ config, lib, pkgs, ... }:
{
  nix.nixPath = [
    "nixpkgs=$HOME/.nix-defexpr/channels/nixpkgs"
    "darwin=$HOME/.nix-defexpr/channels/darwin"
    "darwin-config=$HOME/.config/nixpkgs/darwin-configuration.nix"
    "$HOME/.nix-defexpr/channels"
  ];
  nix.maxJobs = 4;
  # nix.useSandbox = "relaxed";


  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    nix-repl
  ];

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.fish.enable = true;

  services.activate-system.enable = true;
  services.nix-daemon.enable = true;
}
