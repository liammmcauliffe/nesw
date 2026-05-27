set fish_greeting ""

function nswitch --description "Stage changes and rebuild NixOS from the nesw repo"
	set -l current_dir (pwd)
	cd ~/nesw; and git add -A; and sudo nixos-rebuild switch --flake .#main; and cd $current_dir
end

function ntest --description "Stage changes and test NixOS build without switching permanently"
	set -l current_dir (pwd)
	cd ~/nesw; and git add -A; and sudo nixos-rebuild test --flake .#main; and cd $current_dir
end
