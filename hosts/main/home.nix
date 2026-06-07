{ ... }:
{
  imports = [
    ../../modules/fish
    ../../modules/ghostty
    ../../modules/hyprland
    ../../modules/nvim
    ../../modules/starship
    ../../modules/zen
    ../../modules/tools
    ../../modules/quickshell
  ] ++ ( if builtins.pathExists ./local.nix then [ ./local.nix ] else []);
  # ^ for developmental purposes ^
}
