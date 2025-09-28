---@type Wezterm
local wezterm = require("wezterm")
---@type Config
local config = wezterm.config_builder()

-- define user settings
---@type Config
local settings = {
	font = wezterm.font({
		family = "FiraCode Nerd Font Mono",
		harfbuzz_features = {
			"zero",
			"ss01",
			"ss03",
			"cv05",
			"cv20",
			"cv22",
			"ss09",
			"cv25",
			"cv26",
			"cv28",
			"cv32",
			"ss07",
		},
	}),
	color_scheme = "OneDark (base16)",
	animation_fps = 144,
	enable_tab_bar = false,
	adjust_window_size_when_changing_font_size = false,
	warn_about_missing_glyphs = false,
	-- exit_behavior = "",
	window_background_opacity = 0.7,
	-- kde_window_background_blur = true,
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
