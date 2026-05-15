local wezterm = require("wezterm")
local config = wezterm.config_builder()

local sessions = require("sessions.default")

require("commands").apply(config)


wezterm.on("gui-startup", function(cmd)
    if #sessions > 0 then
        local first = sessions[1]
        local tab, pane, window = wezterm.mux.spawn_window({
            cwd = first.cwd,
            args = first.args,
        })

        window:gui_window():set_inner_size(1400, 800)

        for i = 2, #sessions do
            local session = sessions[i]
            window:spawn_tab({
                cwd = session.cwd,
                args = session.args,
            })
        end
    else
        local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
        window:gui_window():set_inner_size(1400, 800)
    end
end)

return config
