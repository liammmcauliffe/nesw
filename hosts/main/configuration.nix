{ config, pkgs, hyprland, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # host basics
  networking.hostName = "main"; # Must match the flake target
  networking.networkmanager.enable = true;
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # enable flakes
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # wayland + hyprland
  programs.hyprland = {
    enable = true;
    package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  };

  programs.fish.enable = true;

  # polkit + keyring
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # location for gammastep
  services.geoclue2.enable = true;
  services.geoclue2.appConfig.gammastep = {
    isAllowed = true;
    isSystem = false;
  };
  location.provider = "geoclue2";

  # bluetooth
  hardware.bluetooth.enable = true;

  # basic packages
  environment.systemPackages = with pkgs; [
    git
    tree-sitter
    app2unit
  ];

  # fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # HARDCODE YOUR USERNAME HERE (e.g. "liam")
  users.users."liam" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.fish;
  };

  # sudo
  security.sudo.enable = true;

  system.stateVersion = "25.11";
}
