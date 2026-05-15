local constants = require("constants")

local M = {}

function M.apply(config)
    config.colors = constants.colors

    config.font = require("wezterm").font(constants.font)
    config.font_size = constants.font_size
    config.line_height = constants.line_height



    config.window_decorations = "RESIZE"

    config.window_background_image = constants.bg_image

    config.window_padding = {
        right = 0,
        top = 0,
        bottom = 0,
    }


    config.max_fps = 165
end

return M
