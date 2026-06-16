{ ... }:
{
  imports = [
    ../../modules/nesw.nix
  ] ++ (if builtins.pathExists ./local.nix then [ ./local.nix ] else []);

  nesw.enable = true;
  programs.quickshell.nesw.enable = true;
}
