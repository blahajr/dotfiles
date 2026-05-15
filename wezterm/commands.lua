local wezterm = require("wezterm")

local M = {}

function M.apply(config)
    config.keys = config.keys or {}

    table.insert(config.keys, {
        key = "T",
        mods = "CTRL|SHIFT",
        action = wezterm.action_callback(function(win, pane)
            local cwd_uri = pane:get_current_working_dir()
            local cwd = cwd_uri and cwd_uri.file_path or nil

            win:perform_action(
                wezterm.action.SpawnCommandInNewTab({
                    cwd = cwd,
                    args = { "pwsh.exe", "-NoLogo" },
                }),
                pane
            )
        end),
    })
end

return M
