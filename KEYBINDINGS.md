# Keybindings

All modifier prefixes live in `modules/hyprland/variables.lua`. Bindings are registered in `modules/hyprland/config/keybinds.lua`. Change a prefix in `variables.lua` to remap a whole group at once.

## Workspaces

| Binding | Action |
|---------|--------|
| `SUPER + 1`–`0` | Focus workspace 1–10 |
| `SUPER + CTRL + 1`–`0` | Move window to workspace 1–10 |
| `SUPER + CTRL + ALT + 1`–`0` | Focus workspace group 1–10 |
| `SUPER + CTRL + SHIFT + ALT + 1`–`0` | Move window to workspace group 1–10 |
| `SUPER + mouse_down` | Focus next workspace |
| `SUPER + mouse_up` | Focus previous workspace |
| `CTRL + SUPER + Right` | Focus next workspace (repeat) |
| `CTRL + SUPER + Left` | Focus previous workspace (repeat) |
| `SUPER + Page_Down` | Focus next workspace (repeat) |
| `SUPER + Page_Up` | Focus previous workspace (repeat) |
| `CTRL + SUPER + mouse_down` | Focus workspace group +1 |
| `CTRL + SUPER + mouse_up` | Focus workspace group −1 |
| `SUPER + grave` | Jump workspace −10 |
| `SUPER + Minus` | Jump workspace +10 |
| `SUPER + S` | Toggle special workspace |

## Move window between workspaces

| Binding | Action |
|---------|--------|
| `SUPER + ALT + Page_Down` | Move window to next workspace (repeat) |
| `SUPER + ALT + Page_Up` | Move window to previous workspace (repeat) |
| `SUPER + ALT + mouse_down` | Move window to next workspace |
| `SUPER + ALT + mouse_up` | Move window to previous workspace |
| `CTRL + SUPER + SHIFT + right` | Move window to next workspace (repeat) |
| `CTRL + SUPER + SHIFT + left` | Move window to previous workspace (repeat) |
| `CTRL + SUPER + SHIFT + up` | Move window to special workspace |
| `CTRL + SUPER + SHIFT + down` | Move window out of special workspace |
| `SUPER + ALT + S` | Move window to special workspace |

## Window groups

| Binding | Action |
|---------|--------|
| `ALT + TAB` | Cycle next window in group (repeat) |
| `SHIFT + ALT + TAB` | Cycle previous window in group (repeat) |
| `CTRL + ALT + Tab` | Cycle next group (repeat) |
| `CTRL + SHIFT + ALT + Tab` | Cycle previous group (repeat) |
| `SUPER + Comma` | Toggle group on active window |
| `SUPER + U` | Ungroup active window |
| `SUPER + SHIFT + Comma` | Lock active group |

## Window focus and movement

| Binding | Action |
|---------|--------|
| `SUPER + left/right/up/down` | Focus window in direction |
| `SUPER + SHIFT + left/right/up/down` | Move window in direction |

## Window resize

| Binding | Action |
|---------|--------|
| `SUPER + Equal` | Grow window width (repeat) |
| `SUPER + SHIFT + Minus` | Shrink window height (repeat) |
| `SUPER + SHIFT + Equal` | Grow window height (repeat) |
| `SUPER + ALT + left/right/up/down` | Resize window (repeat) |

## Window actions

| Binding | Action |
|---------|--------|
| `SUPER + mouse:272` | Drag window (mouse) |
| `SUPER + Z` | Drag window |
| `SUPER + mouse:273` | Resize window (mouse) |
| `SUPER + X` | Resize window |
| `CTRL + SUPER + Backslash` | Center window |
| `CTRL + SUPER + ALT + Backslash` | Picture-in-picture resize + center |
| `SUPER + ALT + backslash` | Picture-in-picture |
| `SUPER + P` | Pin window |
| `SUPER + F` | Fullscreen |
| `SUPER + ALT + F` | Maximized (bordered fullscreen) |
| `SUPER + ALT + space` | Toggle floating |
| `SUPER + Q` | Close window |

## Apps

| Binding | Action |
|---------|--------|
| `SUPER + Return` | Terminal (`ghostty`) |
| `SUPER + W` | Browser (`zen-beta`) |
| `SUPER + space` | App launcher |

## Audio

| Binding | Action |
|---------|--------|
| `XF86AudioMicMute` | Toggle microphone mute |
| `XF86AudioMute` | Toggle output mute |
| `SUPER + SHIFT + M` | Toggle output mute |
| `XF86AudioRaiseVolume` | Raise volume (5% steps, repeat) |
| `XF86AudioLowerVolume` | Lower volume (5% steps, repeat) |

## System

| Binding | Action |
|---------|--------|
| `CTRL + ALT + Delete` | Session menu (defined in `variables.lua`, bind if used) |
| `SUPER + SHIFT + L` | Suspend |

## Variable reference

These keys from `variables.lua` control the prefixes above:

| Variable | Default |
|----------|---------|
| `kbGoToWs` | `SUPER` |
| `kbMoveWinToWs` | `SUPER + CTRL` |
| `kbGoToWsGroup` | `SUPER + CTRL + ALT` |
| `kbMoveWinToWsGroup` | `SUPER + CTRL + SHIFT + ALT` |
| `kbNextWs` | `CTRL + SUPER + Right` |
| `kbPrevWs` | `CTRL + SUPER + Left` |
| `kbNextWsMouse` | `SUPER + mouse_down` |
| `kbPrevWsMouse` | `SUPER + mouse_up` |
| `kbNextWsGroupMouse` | `CTRL + SUPER + mouse_down` |
| `kbPrevWsGroupMouse` | `CTRL + SUPER + mouse_up` |
| `kbMoveWinNextWsMouse` | `SUPER + ALT + mouse_down` |
| `kbMoveWinPrevWsMouse` | `SUPER + ALT + mouse_up` |
| `kbToggleSpecialWs` | `SUPER + S` |
| `kbWindowGroupCycleNext` | `ALT + TAB` |
| `kbWindowGroupCyclePrev` | `SHIFT + ALT + TAB` |
| `kbToggleGroup` | `SUPER + Comma` |
| `kbUngroup` | `SUPER + U` |
| `kbMoveWindow` | `SUPER + Z` |
| `kbResizeWindow` | `SUPER + X` |
| `kbWindowPip` | `SUPER + ALT + backslash` |
| `kbPinWindow` | `SUPER + P` |
| `kbWindowFullscreen` | `SUPER + F` |
| `kbWindowBorderedFullscreen` | `SUPER + ALT + F` |
| `kbToggleWindowFloating` | `SUPER + ALT + space` |
| `kbCloseWindow` | `SUPER + Q` |
| `kbTerminal` | `SUPER + Return` |
| `kbBrowser` | `SUPER + W` |
| `kbLauncher` | `SUPER + space` |
| `kbSession` | `CTRL + ALT + Delete` |
