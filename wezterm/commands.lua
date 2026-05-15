local wezterm = require("wezterm")
local backdrops = require("utils.backdrops")
local act = wezterm.action

local SUPER, SUPER_REV
if wezterm.target_triple:find("apple") then
    SUPER = "SUPER"
    SUPER_REV = "SUPER|CTRL"
else
    SUPER = "ALT"
    SUPER_REV = "ALT|CTRL"
end

local M = {}

function M.apply(config)
    config.keys = config.keys or {}

    table.insert(config.keys, {
        key = "q",
        mods = "CTRL",
        action = act.QuitApplication,
    })

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

    -- Backdrops (same shortcuts as github.com/KevinSilvester/wezterm-config )
    -- Alt+/       random backdrop   Alt+, / Alt+.  previous / next
    -- Alt+Ctrl+/ fuzzy picker       Alt+b         toggle focus (image off/on)
    table.insert(config.keys, {
        key = "/",
        mods = SUPER,
        action = wezterm.action_callback(function(window, _pane)
            backdrops:random(window)
        end),
    })
    table.insert(config.keys, {
        key = ",",
        mods = SUPER,
        action = wezterm.action_callback(function(window, _pane)
            backdrops:cycle_back(window)
        end),
    })
    table.insert(config.keys, {
        key = ".",
        mods = SUPER,
        action = wezterm.action_callback(function(window, _pane)
            backdrops:cycle_forward(window)
        end),
    })
    table.insert(config.keys, {
        key = "/",
        mods = SUPER_REV,
        action = wezterm.action_callback(function(window, pane)
            local choices = backdrops:choices()
            if #choices == 0 then
                window:toast_notification("WezTerm", "No images in backdrops folder", nil, 4000)
                return
            end
            window:perform_action(
                act.InputSelector({
                    title = "Select background",
                    choices = choices,
                    fuzzy = true,
                    fuzzy_description = "Background: ",
                    action = wezterm.action_callback(function(win, _pane, id, _label)
                        if not id and not _label then
                            return
                        end
                        local n = tonumber(id)
                        if n then
                            backdrops:set_img(win, n)
                        end
                    end),
                }),
                pane
            )
        end),
    })
    table.insert(config.keys, {
        key = "b",
        mods = SUPER,
        action = wezterm.action_callback(function(window, _pane)
            backdrops:toggle_focus(window)
        end),
    })
end

return M
