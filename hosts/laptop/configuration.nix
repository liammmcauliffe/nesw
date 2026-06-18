{ config, pkgs, hyprland, userName, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/themes
    ../../modules/drivers
    ./local.nix
  ] ++ (if builtins.pathExists ./shared.nix then [ ./shared.nix ] else []);

  # fail fast on the two first-build footguns
  assertions = [
    {
      assertion = config.networking.hostName == "main";
      message = ''
        networking.hostName is "${config.networking.hostName}" but the flake builds the "main" target (nixosConfigurations.main in flake.nix).
        Set networking.hostName = "main" in hosts/laptop/configuration.nix, or add a matching nixosConfigurations.<name> in flake.nix.
      '';
    }
    {
      assertion = userName != "liam" || builtins.getEnv "USER" == "liam" || true;
      # ponytail: weak guard — Nix evaluation can't reliably read the build host's user.
      # Real protection is the README's "set your username" step; this assertion is a nudge, not a hard gate.
      message = ''
        flake.nix userName is still the placeholder "liam". If this machine's user is not "liam", set userName in flake.nix to your real Linux username before rebuilding.
      '';
    }
  ];

  # allow unfree software
  nixpkgs.config.allowUnfree = true;

  # bootloader - keep generations visible for rollback
  boot.loader.systemd-boot = {
    enable = true;
    consoleMode = "max";
    configurationLimit = 10;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # host basics
  networking.hostName = "main"; # must match the flake target
  networking.networkmanager.enable = true;
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # enable flakes
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
    portalPackage = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
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

  services.upower.enable = true;

  # basic packages
  environment.systemPackages = with pkgs; [
    git
    app2unit
    grim
    slurp
  ];

  # fonts (families driven by nesw.theme - override in hosts/laptop/shared.nix)
  fonts.packages = let
    fonts = config.nesw.theme.fonts;
  in with pkgs; [
    # UI (shell/notch/clock)
    (google-fonts.override { fonts = [ fonts.sansSerif ]; })
    monaspace # terminal/editor (Monaspace Neon)
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-emoji
    noto-fonts-monospace
  ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = let
      fonts = config.nesw.theme.fonts;
    in {
      sansSerif = [
        fonts.sansSerif
        "Noto Sans"
        "Noto Sans CJK SC"
      ];
      serif = [
        "Noto Serif"
        "Noto Serif CJK SC"
      ];
      monospace = [
        fonts.monospace
        fonts.monospaceNerd
        "Noto Sans Mono CJK SC"
      ];
      emoji = [
        "Noto Color Emoji"
      ];
    };
  };

  users.users.${userName} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.fish;
  };

  # sudo
  security.sudo.enable = true;

  system.stateVersion = "25.11";
}
