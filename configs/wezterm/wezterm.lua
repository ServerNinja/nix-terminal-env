-- Pull in the wezterm API
local wezterm = require("wezterm")
--

-- Empty override_config
local config_override = {}

-- Function to load the override file, if it exists
function load_overrides()
  local overrides_path = wezterm.config_dir .. "/.wezterm_overrides.lua"
  local f = io.open(overrides_path, "r")
  if f then
    -- Safely load the override config
    local overrides = dofile(overrides_path)
    -- Apply overrides to the main config
    for k, v in pairs(overrides) do
      config_override[k] = v
    end
    f:close()
  end
end

-- Load override file
load_overrides()

-- dynamic color scheme switching
local function mode_overrides(appearance)
  if appearance:find("Dark") then
    return {
      -- Themes: https://wezfurlong.org/wezterm/colorschemes/index.html
      --color_scheme = "Neon (terminal.sexy)",
      --color_scheme = "Heetch Dark (base16)",
      --color_scheme = "Hemisu Dark (Gogh)",
      --color_scheme = "Bananna Blueberry",
      --color_scheme = "Bim (Gogh)",
      --color_scheme = "Purpledream (base16)",
      color_scheme = "Lavandula (Gogh)",
      -- background = "#1e1e1e",
      window_background_opacity = 0.9,
      macos_window_background_blur = 10,
    }
  else
    return {
      -- Themes: https://wezfurlong.org/wezterm/colorschemes/index.html
      --color_scheme = "catppuccin-latte",
      --color_scheme = "Heetch Light (base16)",
      --color_scheme = "Hemisu Light (Gogh)",
      --color_scheme = "Humanoid light (base16)",
      --color_scheme = "Fruit Soda (base16)",
      color_scheme = "Summerfruit Light (base16)",
      -- background = "#d1d1d1",
      window_background_opacity = 1.0,
      macos_window_background_blur = 0,
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
config.font_size = config_override["font_size"] or 12

-- Enable / disable the tab bar
config.enable_tab_bar = true
config.use_fancy_tab_bar = false

config.enable_scroll_bar = true
config.scrollback_lines = 50000

config.initial_rows = 25
config.initial_cols = 120


return config
