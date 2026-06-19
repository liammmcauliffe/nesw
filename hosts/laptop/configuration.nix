{ config, pkgs, hyprland, userName, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/drivers
  ]
  ++ (if builtins.pathExists ./local.nix then [ ./local.nix ] else [])
  ++ (if builtins.pathExists ./shared.nix then [ ./shared.nix ] else []);

  # flake target is .#main, hostname must match
  assertions = [
    {
      assertion = config.networking.hostName == "main";
      message = ''
        networking.hostName is "${config.networking.hostName}" but the flake builds the "main" target.
        Set networking.hostName = "main" in hosts/laptop/configuration.nix, or add a matching nixosConfigurations.<name> in flake.nix.
      '';
    }
  ];

  nixpkgs.config.allowUnfree = true;

  boot.loader.systemd-boot = {
    enable = true;
    consoleMode = "max";
    configurationLimit = 10;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "main"; # must match the flake target
  networking.networkmanager.enable = true;
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;

    substituters = [
      "https://cache.nixos.org"
      "https://hyprland.cachix.org"
    ];
    trusted-substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
    trusted-users = [ "root" "@wheel" ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d --keep-outputs --keep-derivations";
  };

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
    portalPackage = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  programs.fish.enable = true;

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

  hardware.bluetooth.enable = true;

  services.upower.enable = true;

  # basic packages
  environment.systemPackages = with pkgs; [
    git
    app2unit
    grim
    slurp
  ];

  fonts.packages = with pkgs; [
    (google-fonts.override { fonts = [ "DM Sans" ]; })
    monaspace
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "DM Sans" "Noto Sans" "Noto Sans CJK SC" ];
      serif = [ "Noto Serif" "Noto Serif CJK SC" ];
      monospace = [ "Monaspace Neon NF" "Noto Sans Mono CJK SC" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  users.users.${userName} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.fish;
  };

  # sudo
  security.sudo.enable = true;

  system.stateVersion = "26.05";
}
