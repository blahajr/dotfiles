local wezterm = require("wezterm")
local config = wezterm.config_builder()

local sessions = require("sessions.default")
local appearance = require("appearance")
local backdrops = require("utils.backdrops")

require("shell").apply(config)
require("commands").apply(config)
appearance.apply(config)

backdrops:scan_images_dir()
backdrops:random()

-- Set initial background from backdrops
config.background = backdrops:initial_options({ no_img = false })

wezterm.on("gui-startup", function(cmd)
    local window

    local function size_gui(w)
        w:gui_window():set_inner_size(1400, 800)
    end

    if #sessions > 0 then
        local first = sessions[1]

        local _, _, w = wezterm.mux.spawn_window({
            cwd = first.cwd,
            args = first.args,
        })

        window = w
        size_gui(window)

        for i = 2, #sessions do
            local s = sessions[i]
            window:spawn_tab({
                cwd = s.cwd,
                args = s.args,
            })
        end
    else
        local _, _, w = wezterm.mux.spawn_window(cmd or {})
        window = w
        size_gui(window)
    end
end)

return config
