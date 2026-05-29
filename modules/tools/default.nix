{ pkgs, ... }:
{
    home.packages = with pkgs; [
        eza
    ];

    programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
    };

    programs.broot = {
        enable = true;
        enableFishIntegration = true;
    };
}
