-- Pull in the wezterm API
local wezterm = require("wezterm")
--

-- dynamic color scheme switching
local function mode_overrides(appearance)
  if appearance:find("Dark") then
    return {
      -- Themes: https://wezfurlong.org/wezterm/colorschemes/index.html
      --color_scheme = "Neon (terminal.sexy)",
      color_scheme = "Heetch Dark (base16)",
      --color_scheme = "Hemisu Dark (Gogh)",
      -- background = "#1e1e1e",
    }
  else
    return {
      -- Themes: https://wezfurlong.org/wezterm/colorschemes/index.html
      --color_scheme = "catppuccin-latte",
      --color_scheme = "Heetch Light (base16)",
      --color_scheme = "Hemisu Light (Gogh)",
      color_scheme = "Humanoid light (base16)",
      -- background = "#d1d1d1",
    }
  end
end
wezterm.on("window-config-reloaded", function(window, _)
  local overrides = window:get_config_overrides() or {}
  local appearance = window:get_appearance()
  local overrides_appearance = mode_overrides(appearance)
  local scheme = overrides_appearance.color_scheme
  if overrides.color_scheme ~= scheme then
    overrides.color_scheme = scheme
    -- overrides.colors = {
    -- 	background = overrides_appearance.background,
    -- }
    window:set_config_overrides(overrides)
  end
end)
--/ dynamic color scheme switching


-- This will hold the configuration
local config = wezterm.config_builder()

-- Font config
config.font = wezterm.font("Hack Nerd Font Mono")
config.font_size = 12

-- Enable / disable the tab bar
config.enable_tab_bar = true
config.use_fancy_tab_bar = false

-- Window Configuration
-- config.window_decorations = "RESIZE"
config.window_background_opacity = 0.9
config.macos_window_background_blur = 10

config.enable_scroll_bar = true
config.scrollback_lines = 50000

config.initial_rows = 25
config.initial_cols = 120


return config
