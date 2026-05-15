local M = {}

function M.apply(config)
    config.default_prog = {
        "pwsh.exe",
        "-NoLogo",
    }

    config.launch_menu = {
        {
            label = "Pwsh",
            args = {
                "pwsh.exe",
                "-NoLogo",
            },
        },
    }
end

return M
