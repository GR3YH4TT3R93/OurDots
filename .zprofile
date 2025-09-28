# Sway-screenshot settings
export SWAY_SCREENSHOT_DIR="$HOME/Pictures/Screenshots"

# Set QT platform theme to KDE
export QT_QPA_PLATFORMTHEME=kde

# Check if browser is set to firefox and if so set to librewolf
if [ "$BROWSER" = "firefox" ]; then
  export BROWSER="librewolf"
fi
