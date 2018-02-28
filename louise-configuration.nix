# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  hardware.bluetooth.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use the latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Hibernation using swapfile.
  boot.resumeDevice = "/dev/nvme0n1p2";
  boot.kernelParams = [
    "resume_offset=16408576"
    "acpi_sleep=s4_nohwsig"  # ACPI: Hardware changed while hibernated, success doubtful!
  ];

  # Set the sound card driver.
  boot.extraModprobeConfig = ''
    options snd_hda_intel model=generic
  '';

  networking.hostName = "louise"; # Define your hostname.
  # networking.enableIPv6 = true;
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  i18n = {
    consoleFont = "latarcyrheb-sun32";  # for HiDPI
    consoleKeyMap = "us";
    defaultLocale = "ja_JP.UTF-8";
    inputMethod = {
      enabled = "fcitx";
      fcitx.engines = with pkgs.fcitx-engines; [ mozc ];
    };
  };

  # Fonts
  fonts = {
    fonts = with pkgs; [
      # Serif fonts
      source-serif-pro
      source-han-serif-japanese

      # Sans-serif fonts
      source-sans-pro
      source-han-sans-japanese
      cantarell_fonts

      # Monospace fonts
      source-code-pro
      fira-code

      # Emoji
      noto-fonts-emoji
    ];
  };

  # Set your time zone.
  time.timeZone = "Asia/Tokyo";

  # Nix options
  nix.trustedUsers = [ "@wheel" ];
  # nix.useSandbox = true;
  nix.package = pkgs.nixUnstable;
  nix.buildCores = 6;

  # Nixpkgs options
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    nix-repl
    vim
  ];
  programs.fish.enable = true;


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.bash.enableCompletion = true;
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.exportConfiguration = true;

  # Set the video card driver.
  services.xserver.videoDrivers = [ "i915" ];

  # Enable touchpad support.
  services.xserver.libinput.enable = true;
  services.xserver.libinput.accelSpeed = "1";
  services.xserver.libinput.naturalScrolling = true;

  # Set the fallback keyboard.
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "terminate:ctrl_alt_bksp,ctrl:swapcaps";
 
  # Extra devices.
  services.xserver.inputClassSections = [
    ''
      Identifier             "HHKB-BT"
      MatchIsKeyboard        "on"
      MatchDevicePath        "/dev/input/event*"
      MatchProduct           "HHKB-BT"
      Option "XkbModel"      "pc104"
      Option "XkbLayout"     "us"
      Option "XkbOptions"    "terminate:ctrl_alt_bksp"
      Option "XkbVariant"    ""
    ''
  ];

  # Enable the KDE Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.displayManager.sddm.extraConfig = ''
    [X11]
    # For HiDPI display
    ServerArguments=-nolisten tcp -dpi 192
  '';
  services.xserver.desktopManager.plasma5.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.mnacamura = {
    isNormalUser = true;
    uid = 1000;
    description = "Mitsuhiro Nakamura";
    extraGroups = [ "wheel" "networkmanager" ];
    createHome = true;
    shell = "/run/current-system/sw/bin/fish";
    openssh.authorizedKeys.keys = [
    ];
  };

  # Keep the NixOS system up-to-date.
  # system.autoUpgrade.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "17.09"; # Did you read the comment?

}
