local wezterm = require("wezterm")
local colors = require("colors.custom")

local function backdrop_tint_color()
    local c = colors and colors.background
    if type(c) == "string" and c ~= "" then
        return c
    end
    return "#1f1f28"
end

local BACKDROP_TINT = backdrop_tint_color()

local BACKDROP_TINT_OPACITY_SMALL = 0.93
local BACKDROP_TINT_OPACITY_LARGE = 0.96
local LARGE_WINDOW_MIN_PIXEL_WIDTH = 1600

local DEFAULT_WINDOW_PIXEL_WIDTH_FOR_CONFIG = 1400
local DEFAULT_WINDOW_PIXEL_HEIGHT_FOR_CONFIG = 800

local BACKDROP_IMAGE_HSB = { brightness = 1.1 }


---- Taken from https://github.com/KevinSilvester/wezterm-config/blob/master/utils/backdrops.lua
-- Seeding random numbers before generating for use
-- Known issue with lua math library
-- see: https://stackoverflow.com/questions/20154991/generating-uniform-random-numbers-in-lua
math.randomseed(os.time())
math.random()
math.random()
math.random()

local GLOB_PATTERN = "*.{jpg,jpeg,png,gif,bmp,ico,tiff,pnm,dds,tga}"

---@class BackDrops
---@field current_idx number index of current image
---@field images string[] background images
---@field images_dir string directory of background images. Default is `wezterm.config_dir .. '/backdrops/'`
---@field no_img boolean focus mode on or off
local BackDrops = {}
BackDrops.__index = BackDrops

--- Initialise backdrop controller
---@private
function BackDrops:init()
    local backdrops = {
        current_idx = 1,
        images = {},
        images_dir = wezterm.config_dir .. "/backdrops/",
    }
    return setmetatable(backdrops, self)
end

---Override the default `images_dir`
---Default `images_dir` is `wezterm.config_dir .. '/backdrops/'`
---
--- INFO:
---  This function must be invoked before `scan_images_dir()`
---
---@param path string directory of background images
function BackDrops:set_images_dir(path)
    self.images_dir = path
    if not path:match("/$") then
        self.images_dir = path .. "/"
    end
    return self
end

---**MUST BE RUN BEFORE ALL OTHER `BackDrops` methods**
---Sets the `images` after instantiating `BackDrops`.
---
--- INFO:
---   During the initial load of the config, this function can only invoked in `wezterm.lua`.
---   WezTerm's fs utility `glob` (used in this function) works by running on a spawned child process.
---   This throws a coroutine error if the function is invoked outside of `wezterm.lua` during the
---   initial load of the terminal config.
function BackDrops:scan_images_dir()
    self.images = wezterm.glob(self.images_dir .. GLOB_PATTERN)
    return self
end

---@param tint_opacity number|nil overlay opacity; nil → small-window preset
---@private
---@return BackgroundLayer[]
function BackDrops:_gen_opts(tint_opacity)
    local opacity = tint_opacity or BACKDROP_TINT_OPACITY_SMALL
    local bg_opts = {}

    if #self.images > 0 then
        local path = self.images[self.current_idx]
        if type(path) == "string" and path ~= "" then
            table.insert(bg_opts, {
                source = { File = path },
                attachment = "Fixed",
                width = "Cover",
                height = "Cover",
                horizontal_align = "Center",
                vertical_align = "Middle",
                repeat_x = "NoRepeat",
                repeat_y = "NoRepeat",
                hsb = BACKDROP_IMAGE_HSB,
            })
        end
    end

    table.insert(bg_opts, {
        source = { Color = BACKDROP_TINT },
        height = "120%",
        width = "120%",
        vertical_offset = "-10%",
        horizontal_offset = "-10%",
        opacity = opacity,
    })

    return bg_opts
end

---Tint depth from pixel size (width breakpoint).
---@param pixel_width number?
---@param pixel_height number?
---@return number
function BackDrops:tint_opacity_for_pixels(pixel_width, pixel_height)
    _ = pixel_height
    if pixel_width and pixel_width >= LARGE_WINDOW_MIN_PIXEL_WIDTH then
        return BACKDROP_TINT_OPACITY_LARGE
    end
    return BACKDROP_TINT_OPACITY_SMALL
end

---@param window Window?
---@return number
function BackDrops:tint_opacity_for_window(window)
    if not window then
        return BACKDROP_TINT_OPACITY_SMALL
    end
    local dims = window:get_dimensions()
    if not dims then
        return BACKDROP_TINT_OPACITY_SMALL
    end
    return self:tint_opacity_for_pixels(dims.pixel_width, dims.pixel_height)
end

---Apply tint tier for current window size (focus/image mode only when wallpaper visible).
---@param window Window
function BackDrops:sync_backdrop_tint_for_window(window)
    if self.no_img then
        return
    end
    local dims = window:get_dimensions()
    if not dims then
        return
    end
    local tint = self:tint_opacity_for_pixels(dims.pixel_width, dims.pixel_height)
    self:_set_opt(window, self:_gen_opts(tint))
end

---Create the `background` options for focus mode
---@private
---@return BackgroundLayer[]
function BackDrops:_gen_no_img_opts()
    return {
        {
            source = { Color = BACKDROP_TINT },
            height = "120%",
            width = "120%",
            vertical_offset = "-10%",
            horizontal_offset = "-10%",
            opacity = 1,
        },
    }
end

---Set the initial options for `background`
---@param opts {no_img?: boolean} initial options for `background`
function BackDrops:initial_options(opts)
    opts.no_img = opts.no_img or false
    assert(type(opts.no_img) == "boolean", "BackDrops:initial_options - Expected a boolean")

    self.no_img = opts.no_img
    if opts.no_img then
        return self:_gen_no_img_opts()
    end

    return self:_gen_opts(
        self:tint_opacity_for_pixels(DEFAULT_WINDOW_PIXEL_WIDTH_FOR_CONFIG, DEFAULT_WINDOW_PIXEL_HEIGHT_FOR_CONFIG)
    )
end

---Override the current window options for background
---@private
---@param window Window WezTerm Window see: https://wezfurlong.org/wezterm/config/lua/window/index.html
---@param background_opts BackgroundLayer[] background option
function BackDrops:_set_opt(window, background_opts)
    window:set_config_overrides({
        background = background_opts,
        enable_tab_bar = window:effective_config().enable_tab_bar,
    })
end

---Convert the `images` array to a table of `InputSelector` choices
---see: https://wezfurlong.org/wezterm/config/lua/keyassignment/InputSelector.html
function BackDrops:choices()
    local choices = {}
    for idx, file in ipairs(self.images) do
        table.insert(choices, {
            id = tostring(idx),
            label = file:match("([^/\\]+)$"),
        })
    end
    return choices
end

---Select a random background from the loaded `files`
---Pass in `Window` object to override the current window options
---@param window Window? WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
function BackDrops:random(window)
    if #self.images == 0 then
        return
    end
    self.current_idx = math.random(#self.images)

    if window ~= nil then
        self:_set_opt(window, self:_gen_opts(self:tint_opacity_for_window(window)))
    end
end

---Cycle the loaded `files` and select the next background
---@param window Window WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
function BackDrops:cycle_forward(window)
    if #self.images == 0 then
        return
    end
    if self.current_idx == #self.images then
        self.current_idx = 1
    else
        self.current_idx = self.current_idx + 1
    end
    self:_set_opt(window, self:_gen_opts(self:tint_opacity_for_window(window)))
end

---Cycle the loaded `files` and select the previous background
---@param window Window WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
function BackDrops:cycle_back(window)
    if #self.images == 0 then
        return
    end
    if self.current_idx == 1 then
        self.current_idx = #self.images
    else
        self.current_idx = self.current_idx - 1
    end
    self:_set_opt(window, self:_gen_opts(self:tint_opacity_for_window(window)))
end

---Set a specific background from the `files` array
---@param window Window WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
---@param idx number index of the `files` array
function BackDrops:set_img(window, idx)
    if idx < 1 or idx > #self.images then
        wezterm.log_error("Index out of range")
        return
    end

    self.current_idx = idx
    self:_set_opt(window, self:_gen_opts(self:tint_opacity_for_window(window)))
end

---Toggle the focus mode
---@param window Window WezTerm `Window` see: https://wezfurlong.org/wezterm/config/lua/window/index.html
function BackDrops:toggle_focus(window)
    local background_opts = self.no_img and self:_gen_opts(self:tint_opacity_for_window(window))
        or self:_gen_no_img_opts()
    self.no_img = not self.no_img

    self:_set_opt(window, background_opts)
end

local backdrops = BackDrops:init()

wezterm.on("window-resized", function(window, _pane)
    backdrops:sync_backdrop_tint_for_window(window)
end)

return backdrops
