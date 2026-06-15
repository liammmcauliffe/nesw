set fish_greeting ""

# nixos commands
function nswitch --description "Stage changes and rebuild NixOS from the nesw repo"
	set -l prev (pwd)
	cd ~/nesw || return 1
	git add -A
	set -l staged (git diff --cached --stat)
	if test -n "$staged"
		echo $staged
	end
	set -l t0 (date +%s)
	echo "→ rebuilding..."
	if sudo nixos-rebuild switch --flake .#main
		echo "✓ done in "(math (date +%s) - $t0)"s"
	else
		echo "✗ rebuild failed"
	end
	cd $prev
end

function ntest --description "Stage changes and test NixOS build without switching permanently"
	set -l prev (pwd)
	cd ~/nesw || return 1
	git add -A
	set -l staged (git diff --cached --stat)
	if test -n "$staged"
		echo $staged
	end
	set -l t0 (date +%s)
	echo "→ testing (revert on reboot)..."
	if sudo nixos-rebuild test --flake .#main
		echo "✓ done in "(math (date +%s) - $t0)"s — reboot to revert"
	else
		echo "✗ test build failed"
	end
	cd $prev
end

# eza commands
function ls; eza --icons $argv; end
function ll; eza -la --icons --git $argv; end
function lt; eza --tree --icons $argv; end
