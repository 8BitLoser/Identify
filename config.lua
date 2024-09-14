local configPath = "Identify"
---@class bsIdentifyConfig<K, V>: { [K]: V }
local defaults = {
    quillCondition = 10,
    key = { --Keycode to trigger menu
        keyCode = tes3.scanCode.p,
        isShiftDown = false,
        isAltDown = false,
        isControlDown = false,
    },
}


---@class bsIdentifyConfig
local config = mwse.loadConfig(configPath, defaults)

local function registerModConfig()
    local template = mwse.mcm.createTemplate({ name = configPath, defaultConfig = defaults, config = config })
        template:saveOnClose(configPath, config)

    local settings = template:createPage({ label = "Settings" })
    settings.showReset = true

    settings:createSlider({
        label = "Example Slider",
        configKey = "exampleSlider",
        min = 0, max = 10, step = 0.01, jump = 0.10, decimalPlaces = 2,
    })
    template:register()
end
event.register(tes3.event.modConfigReady, registerModConfig)

return config