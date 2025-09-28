#!/bin/env bash

# Workspace 1: wezterm (default tmux session) + librewolf
swaymsg 'workspace 1'
swaymsg 'exec wezterm'
swaymsg 'exec librewolf'

# Workspace 2: wezterm (neovim session) + librewolf + wezterm (dev server monitoring session)
# swaymsg 'workspace 2'
# swaymsg 'exec wezterm start -- tmux new-session -s neovim'
# sleep 2
# swaymsg 'exec librewolf'
# sleep 2
# swaymsg 'exec wezterm start -- tmux new-session -s devserver'
# sleep 2
#
# # Workspace 3: Steam
# swaymsg 'workspace 3'
# swaymsg 'exec steam'
# sleep 2
#
# # Create scratchpad terminal (this won't be caught by assigns)
# swaymsg 'exec wezterm start -- tmux new-session -s scratchpad'
# sleep 2
# swaymsg '[app_id="org.wezfurlong.wezterm"] move scratchpad'
#
# # Return to workspace 1
# swaymsg 'workspace 1'
