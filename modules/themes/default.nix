/*
  Theme Module

  Centralizes nesw font families and baseline colors so users can override them
  in hosts/<host>/local.nix without editing individual app modules.

  Exposes:
    - nesw.theme.fonts.sansSerif, monospace, monospaceNerd
    - nesw.theme.colors.primary, onSurfaceVariant, surface, surfaceContainer
  Depends: (none - imported by NixOS configuration.nix and Home Manager)
*/
{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.nesw.theme = {
    fonts = {
      sansSerif = mkOption {
        type = types.str;
        default = "DM Sans";
        description = "UI font family (shell, notch, clock). Installed via google-fonts.";
      };

      monospace = mkOption {
        type = types.str;
        default = "Monaspace Neon";
        description = "Terminal and editor monospace font family.";
      };

      monospaceNerd = mkOption {
        type = types.str;
        default = "JetBrainsMono Nerd Font";
        description = "Nerd Font variant for terminal/editor icons.";
      };
    };

    colors = {
      primary = mkOption {
        type = types.str;
        default = "e4e4e7";
        description = "Primary accent color (hex without #).";
      };

      onSurfaceVariant = mkOption {
        type = types.str;
        default = "a1a1aa";
        description = "Muted on-surface variant color (hex without #).";
      };

      surface = mkOption {
        type = types.str;
        default = "09090b";
        description = "Base surface/background color (hex without #).";
      };

      surfaceContainer = mkOption {
        type = types.str;
        default = "1c1c1f";
        description = "Elevated surface container color (hex without #).";
      };
    };
  };
}
