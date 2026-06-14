set fish_greeting ""

# nixos commands
function nswitch --description "Stage changes and rebuild NixOS from the nesw repo"
	set -l current_dir (pwd)
	if cd ~/nesw
		git add -A
		and sudo nixos-rebuild switch --flake .#main
	end
	cd $current_dir
end

function ntest --description "Stage changes and test NixOS build without switching permanently"
	set -l current_dir (pwd)
	if cd ~/nesw
		git add -A
		and sudo nixos-rebuild test --flake .#main
	end
	cd $current_dir
end

# eza commands
function ls; eza --icons $argv; end
function ll; eza -la --icons --git $argv; end
function lt; eza --tree --icons $argv; end
