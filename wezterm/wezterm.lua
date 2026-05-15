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

    ---@param s { cwd?: string, args?: string[], label?: string }
    local function spawn_opts(s)
        local opts = {}
        if s.cwd and s.cwd ~= "" then
            opts.cwd = s.cwd
        end
        if s.args and #s.args > 0 then
            opts.args = s.args
        end
        return opts
    end

    if #sessions > 0 then
        local first = sessions[1]

        local first_tab, _, w = wezterm.mux.spawn_window(spawn_opts(first))
        if first.label then
            first_tab:set_title(first.label)
        end

        window = w
        size_gui(window)

        for i = 2, #sessions do
            local s = sessions[i]
            local tab = window:spawn_tab(spawn_opts(s))
            if tab and s.label then
                tab:set_title(s.label)
            end
        end

        backdrops:sync_backdrop_tint_for_window(window:gui_window())
    else
        local _, _, w = wezterm.mux.spawn_window(cmd or {})
        window = w
        size_gui(window)
        backdrops:sync_backdrop_tint_for_window(window:gui_window())
    end
end)

return config
