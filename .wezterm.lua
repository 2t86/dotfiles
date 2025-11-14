local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.automatically_reload_config = true

config.color_scheme = 'Adventure Time (Gogh)'

config.colors = {
   tab_bar = {
      background = '#1f1d45',

      active_tab = {
         bg_color = '#1f1d45',
         fg_color = '#f8dcc0',
         underline = 'Single',
         italic = true,
      },

      inactive_tab = {
         bg_color = '#1f1d45',
         fg_color = '#f8dcc0',
         italic = true,
      },
   },
}

config.initial_cols = 90
config.initial_rows = 30

config.font = wezterm.font 'Iosevka Term'
config.font_size = 14

config.default_cursor_style = 'SteadyUnderline'

config.scrollback_lines = 100000

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.show_new_tab_button_in_tab_bar = false

-- option as alt
config.send_composed_key_when_left_alt_is_pressed = false
config.send_composed_key_when_right_alt_is_pressed = false

config.leader = { key = 'x', mods = 'CMD', timeout_millisconds = 1000 }

local act = wezterm.action

config.keys = {
   {
      key = 'F',
      mods = 'CMD|SHIFT',
      action = act.ToggleFullScreen,
   },
   {
      key = 'F',
      mods = 'CMD|CTRL',
      action = act.ToggleFullScreen,
   },
   {
      key = 'Enter',
      mods = 'CMD',
      action = act.SplitVertical { domain = 'CurrentPaneDomain' },
   },
   {
      key = 'Enter',
      mods = 'CMD|SHIFT',
      action = act.SplitHorizontal { domain = 'CurrentPaneDomain' },
   },
   {
      key = 'H',
      mods = 'CMD|SHIFT',
      action = act.ActivatePaneDirection 'Left',
   },
   {
      key = 'J',
      mods = 'CMD|SHIFT',
      action = act.ActivatePaneDirection 'Down',
   },
   {
      key = 'K',
      mods = 'CMD|SHIFT',
      action = act.ActivatePaneDirection 'Up',
   },
   {
      key = 'L',
      mods = 'CMD|SHIFT',
      action = act.ActivatePaneDirection 'Right',
   },
   {
      key = 'H',
      mods = 'CMD|CTRL',
      action = act.AdjustPaneSize { 'Left', 5 },
   },
   {
      key = 'J',
      mods = 'CMD|CTRL',
      action = act.AdjustPaneSize { 'Down', 5 },
   },
   {
      key = 'K',
      mods = 'CMD|CTRL',
      action = act.AdjustPaneSize { 'Up', 5 },
   },
   {
      key = 'L',
      mods = 'CMD|CTRL',
      action = act.AdjustPaneSize { 'Right', 5 },
   },
}

return config
