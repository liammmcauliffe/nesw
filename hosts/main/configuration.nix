{ config, pkgs, hyprland, ... }:

let
  settings = import ../../settings.nix;
in
{
  imports = [ ./hardware-configuration.nix ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Host basics
  networking.hostName = settings.hostname;
  networking.networkmanager.enable = true;
  time.timeZone = settings.timezone;
  i18n.defaultLocale = settings.locale;

  # Enable flakes on the installed system
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Wayland + Hyprland
  programs.hyprland = {
    enable = true;
    package = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  };

  programs.fish.enable = true;

  # Basic packages
  environment.systemPackages = with pkgs; [
    git
  ];

  users.users.${settings.username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.fish;
  };

  # Needed if you want to use sudo
  security.sudo.enable = true;

  system.stateVersion = "24.11";
}
