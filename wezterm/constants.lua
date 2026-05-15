local M = {}

M.bg_image = os.getenv("USERPROFILE") .. "\\.config\\assets\\bg-blurred-darker.png"

M.font = "JetBrainsMono Nerd Font Mono"
M.font_size = 18
M.line_height = 1.2

M.colors = {
    cursor_bg = "white",
    cursor_border = "white",
}

return M
