---@type Wezterm
local wezterm = require("wezterm")
---@type Config
local config = wezterm.config_builder()

-- define user settings
---@type Config
local settings = {
	font = wezterm.font("FiraCode Nerd Font Mono"),
	color_scheme = "OneDark (base16)",
	animation_fps = 144,
	enable_tab_bar = false,
	window_background_opacity = 0.7,
	kde_window_background_blur = true,
	detect_password_input = true,
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
}

-- Merge table into config
for key, value in pairs(settings) do
	config[key] = value
end

return config
