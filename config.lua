local configPath = "Identify"
---@class bsIdentifyConfig<K, V>: { [K]: V }
local defaults = {
    quillCondition = 10,
    debug = false,
    scrollMenu = false,
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

    settings:createYesNoButton{configKey = "scrollMenu", label = "Scroll Menu"}
    settings:createYesNoButton{configKey = "debug"}

    settings:createSlider({
        label = "Magic Quill Condition",
        configKey = "quillCondition",
        min = 1, max = 10, step = 1, jump = 1
    })
    template:register()
end
event.register(tes3.event.modConfigReady, registerModConfig)

return config