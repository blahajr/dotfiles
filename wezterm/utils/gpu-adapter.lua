-- Adapted from https://github.com/KevinSilvester/wezterm-config/blob/master/utils/gpu-adapter.lua
local wezterm = require("wezterm")
local platform = require("utils.platform")

---@type { Dx12?: number, Vulkan?: number, Gl?: number, Metal?: number }
local AVAILABLE_BACKENDS = {
    windows = { Dx12 = 3, Vulkan = 2, Gl = 1 },
    linux = { Vulkan = 2, Gl = 1 },
    mac = { Metal = 1 },
}

---@type { DiscreteGpu?: number, IntegratedGpu?: number, Other?: number, Cpu?: number }
local AVAILABLE_DEVICE_TYPES = {
    DiscreteGpu = 4 * 100,
    IntegratedGpu = 3 * 100,
    Other = 2 * 100,
    Cpu = 1 * 100,
}

---@type GpuInfo[]
local ENUMERATED_GPUS = wezterm.gui.enumerate_gpus()

---@class GpuAdapters
---@field scoreboard {[number]: GpuInfo}
---@field best number
local GpuAdapters = {}
GpuAdapters.__index = GpuAdapters
GpuAdapters.backends = AVAILABLE_BACKENDS[platform.os]
GpuAdapters.device_types = AVAILABLE_DEVICE_TYPES

---@return GpuAdapters
---@private
function GpuAdapters:init()
    local initial = {
        scoreboard = {},
        best = 0,
    }

    for _, adapter in ipairs(ENUMERATED_GPUS) do
        local backend_score = self.backends[adapter.backend]
        local device_score = self.device_types[adapter.device_type]
        if backend_score and device_score then
            local score = backend_score | device_score
            if score > initial.best then
                initial.best = score
            end
            initial.scoreboard[score] = adapter
        end
    end

    return setmetatable(initial, self)
end

---Discrete > Integrated > Other > Cpu; backend order per platform (see repo README).
---@return GpuInfo|nil
function GpuAdapters:pick_best()
    return self.best > 0 and self.scoreboard[self.best] or nil
end

---@param backend GpuInfo.Backend
---@param device_type GpuInfo.DeviceType
---@return GpuInfo|nil
function GpuAdapters:pick_manual(backend, device_type)
    local backend_score = self.backends[backend]
    local device_type_score = self.device_types[device_type]

    assert(backend_score, "Invalid backend provided")
    assert(device_type_score, "Invalid device type provided")

    local score = backend_score | device_type_score
    local adapter_choice = self.scoreboard[score]

    if not adapter_choice then
        wezterm.log_error("Preferred backend not available. Using default adapter.")
        return nil
    end

    return adapter_choice
end

return GpuAdapters:init()
