local constants = require("constants")

local M = {}

function M.apply(config)
    config.colors = constants.colors

    config.font = require("wezterm").font(constants.font)
    config.font_size = constants.font_size
    config.line_height = constants.line_height

    config.window_decorations = "RESIZE"
    config.enable_scroll_bar = true

    config.window_padding = {
        right = 0,
        top = 0,
        bottom = 5.0,
    }
    config.window_frame = {
        active_titlebar_bg = "#090909",
    }
    config.max_fps = 120
end

function M.apply_window(window, opts)
    if opts and opts.background then
        window:set_config_overrides({
            background = opts.background,
        })
    end
end

return M
