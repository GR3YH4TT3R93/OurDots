# Sway-screenshot settings
export SWAY_SCREENSHOT_DIR="$HOME/Pictures/Screenshots"


# Check if browser is set to firefox and if so set to librewolf
if [ "$BROWSER" = "firefox" ]; then
  export BROWSER="librewolf"
fi
