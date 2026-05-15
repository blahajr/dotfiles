local constants = require("constants")
local gpu_adapters = require("utils.gpu-adapter")

local SCHEME_NAME = "Catppuccin Mocha"

local M = {}

function M.apply(config)

    config.color_schemes = config.color_schemes or {}
    local base = {}
    for k, v in pairs(require("colors.custom")) do
        base[k] = v
    end
    config.color_schemes[SCHEME_NAME] = base
    config.color_scheme = SCHEME_NAME

    config.colors = constants.colors or {}

    config.font = require("wezterm").font(constants.font)
    config.font_size = constants.font_size
    config.line_height = constants.line_height

    config.window_decorations = "RESIZE"
    config.enable_scroll_bar = true

    config.window_padding = {
        right = 0,
        top = 0,
        bottom = 3.0,
    }
    config.window_frame = {
        active_titlebar_bg = "#090909",
    }
    config.window_close_confirmation = "NeverPrompt"
    config.max_fps = 120

    -- GPU / renderer (see github.com/KevinSilvester/wezterm-config config/appearance.lua)
    config.front_end = "WebGpu"
    config.webgpu_power_preference = "HighPerformance"
    config.webgpu_preferred_adapter = gpu_adapters:pick_best()
    -- config.webgpu_preferred_adapter = gpu_adapters:pick_manual("Dx12", "DiscreteGpu")
    -- config.webgpu_preferred_adapter = gpu_adapters:pick_manual("Gl", "Other")
end

function M.apply_window(window, opts)
    if opts and opts.background then
        window:set_config_overrides({
            background = opts.background,
        })
    end
end

return M
