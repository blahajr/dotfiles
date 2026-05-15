local wezterm = require("wezterm")
local config = wezterm.config_builder()

local sessions = require("sessions.default")

require("commands").apply(config)

wezterm.on("gui-startup", function(cmd)
    local tab, pane, window = wezterm.mux.spawn_window(cmd or {})

    for i, session in ipairs(sessions) do
        local t = window:spawn_tab({
            cwd = session.cwd,
            args = session.args,
        })

        if i == 1 then
            tab = t
        end
    end
end)

return config
