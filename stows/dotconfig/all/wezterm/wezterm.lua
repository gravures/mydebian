local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.default_prog = { 'zsh' }

config.font_size = 16
config.line_height = 1.05
config.font = wezterm.font 'JetBrains Mono'

-- config.term = 'wezterm'
config.term = "xterm-256color"
config.color_scheme = 'Catppuccin Mocha'
config.colors = {
  foreground = '#d1d1d1',
}

config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 500

config.window_decorations = 'RESIZE'
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true
config.window_padding = {
  left = 4,
  right = 4,
  top = 4,
  bottom = 0,
}
config.window_background_opacity = 1.0
-- config.kde_window_background_blur = true

config.max_fps = 120

return config
