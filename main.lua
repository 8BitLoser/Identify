-- local cfg = require("BeefStranger.Identify.config")
local bs = require("BeefStranger.Identify.common")
local ui = require("BeefStranger.Identify.identifyMenu")
local Item = require("BeefStranger.Identify.items")


event.register("initialized", function()
    Item:createQuillObj()
    Item:distributeQuills()
    print("[MWSE:Identify] initialized")
end)

local function initPlayerData()
    local data = tes3.player.data
    data.bsIdentify = data.bsIdentify or {}
    bs.inspect(data.bsIdentify)
end


event.register(tes3.event.loaded, initPlayerData)