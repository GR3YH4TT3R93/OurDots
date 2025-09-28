#!/usr/bin/env bash

# OneDark Rofi Power Menu
# A beautiful power menu with OneDark color scheme

# Define power menu options
shutdown="⏻  Shutdown"
suspend="⏾  Suspend"
reboot="󰤁  Reboot"
hibernate="󰒲  Hibernate"
lock="󰌾  Lock"
logout="⏻  Logout"
task_manager="  Task Manager"

# Format options for rofi
options="$shutdown\n$suspend\n$reboot\n$hibernate\n$lock\n$logout\n$task_manager"

# Define terminal
terminal="wezterm"

# Show rofi menu and capture selection using your default theme
chosen=$(echo -e "$options" | rofi -dmenu -i -p "" -no-show-icons)

# Execute based on selection
case $chosen in
    "$shutdown")
        systemctl poweroff
        ;;
    "$suspend")
        systemctl suspend
        ;;
    "$reboot")
        systemctl reboot
        ;;
    "$hibernate")
        systemctl hibernate
        ;;
    "$lock")
        # Adjust lock command based on your setup
        # Common options:
        # i3lock -c 282c34 # Simple lock with OneDark background
        # loginctl lock-session # For systemd
        # dm-tool lock # For lightdm
        swaylock -f -c 000000 # For Sway/SwayFX
        ;;
    "$logout")
        # Adjust logout command based on your window manager
        # Common options:
        # i3-msg exit # For i3wm
        swaymsg exit # For Sway/SwayFX
        # bspc quit # For bspwm
        # qtile cmd-obj -o cmd -f shutdown # For qtile
        # pkill -KILL -u $USER # Universal logout
        # loginctl terminate-user $USER
        ;;
    "$task_manager")
        $terminal start --class btop -- btop
        ;;
esac
