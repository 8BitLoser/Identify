local Item = require("BeefStranger.Identify.items")
local bs = require("BeefStranger.Identify.common")
local cfg = require("BeefStranger.Identify.config")


---TODO: 
---1: Scroll Options|Auto Learn when purchased
---2: Add Quill to Merchants/Leveled Lists
---3: Alternate Menu for people not using my UI mod
---4: Consider Obfuscating the Item name aswell (configurable)
---



---HelpMenu
---@class bsIdentifyHelpMenu
local Help = {}
function Help:get() return tes3ui.findHelpLayerMenu(tes3ui.registerID("HelpMenu")) end
function Help:child(child) if not self:get() then return end return self:get():findChild(child) end
function Help:Main() return self:child("PartHelpMenu_main") end
function Help:Enchant() return self:child("HelpMenu_enchantmentContainer") end
function Help:Effect() return self:child("effect") end
function Help:EnchantLabel() return self:child("HelpMenu_enchantEffectLabel") end
function Help:Charge() return self:child("HelpMenu_chargeBlock") end
Help.labelId = "HelpMenu_enchantEffectLabel"
Help.imageID = "image"

---@class bsIdentifyMenu
local Identify = {}
Identify.ID = tes3ui.registerID("BS_IdentifyMenu")
Identify.unknownIcon = "Icons\\bs\\s_UnknownIcon.tga"
Identify.obj = "BS_Identify_Object"
Identify.itemData = "BS_Identify_itemData"

function Identify:get() return tes3ui.findMenu(Identify.ID) end
function Identify:child(child) return self:get() and self:get():findChild(child) end
function Identify:QuillIcon() return self:child("Quill Icon") end
function Identify:Uses() return self:child("Uses") end

---Set element properties
---@param object tes3misc
---@param itemData tes3itemData
function Identify.setProps(object, itemData)
    Identify:get():setPropertyObject(Identify.obj, object)
    Identify:get():setPropertyObject(Identify.itemData, itemData)
end

---Get object property
---@return tes3misc
function Identify:getObj() return self:get():getPropertyObject(self.obj) end

---Get itemData
---@return tes3itemData
function Identify:getData() return self:get():getPropertyObject(self.itemData, "tes3itemData") end

---Get Quills Condition
---@return number
function Identify.quillCondition() return Identify:getData().condition end

---Add itemData to Quill
---@param item tes3misc
---@return tes3itemData
function Identify.addItemData(item)
    local itemData = tes3.addItemData({ to = tes3.mobilePlayer, item = item })
    itemData.condition = cfg.quillCondition
    return itemData
end

---Gets player.data.bsIdentify
---@return table
function Identify:knownList()
    local bsIdentify = tes3.player.data.bsIdentify or {}
    return bsIdentify
end

---Handle the breaking of the Quill
function Identify:quillBreak()
    if self:QuillIcon().visible then
        self:QuillIcon().visible = false
        self:Uses().visible = false
        tes3.removeItem{reference = tes3.player, item = self:getObj(), itemData = self:getData(), playSound = false}
        tes3.playSound{sound = bs.sounds.Pack}
        self:get():updateLayout()
    end
end

---Add Effect to knownList
---@param effectID number
function Identify:learn(effectID)
    self:knownList()[effectID] = true
end

---comments
---@param effect tes3effect
---@return boolean Known
function Identify:isKnown(effect)
    if self:knownList()[effect.id] then
        return true
    else
        return false
    end
end

---comments
---@param object tes3weapon|tes3armor|tes3book|tes3clothing
---@param itemList tes3uiElement
---@param counter number
---@return tes3uiElement item
---@return tes3uiElement icon
---@return tes3uiElement label
function Identify:createItemList(object, itemList, counter)
    ---@diagnostic disable-next-line: undefined-field
    local width = tes3ui.textLayout.getTextExtent({ text = object.name })
    local item = itemList:createImage { id = tes3ui.registerID("item " .. counter), path = "Textures\\menu_icon_equip.tga" }
    item.borderTop = 5
    item.borderBottom = 5
    item.height = 40
    item.width = width + 80
    item.color = { 0, 0, 0 }

    local border = item:createImage { id = tes3ui.registerID("border"), path = "Textures\\menu_icon_equip.tga" }
    border.color = { 0, 0, 0 }

    local icon = border:createImage({ id = tes3ui.registerID("icon"), path = "Icons\\" .. object.icon })
    icon.borderAllSides = 6
    icon.color = { .35, .35, .35 } ---Unsure about adding color tint

    local label = item:createLabel({ id = tes3ui.registerID("label"), text = object.name })
    label.borderTop = 10
    label.color = { 0, 0, 0 }
    return item, icon, label
end


function Identify:Menu(equipped)
    -- local bsIdentify = self:knownList()
    local main = tes3ui.createMenu{id = Identify.ID, fixedFrame = true}
    tes3ui.enterMenuMode(Identify.ID)
    main.autoHeight = false
    main.autoWidth = false
    main.width = 500
    main.height = 550
    main.alpha = 0

    local header = main:createBlock{id = "Header"}
    header.autoHeight = true
    header.autoWidth = true
    header.widthProportional = 1

    local quillBlock = header:createBlock({id = "Quill Block"})
    quillBlock.autoHeight = true
    quillBlock.autoWidth = true
    quillBlock.borderLeft = 16
    quillBlock.borderTop = 20

    local quillSelect = quillBlock:createImage({id = "Quill Select", path = "Textures\\menu_icon_equip.tga"})
    quillSelect.color = {0,0,0}
    self.setProps(equipped.item, equipped.itemData)

    quillSelect:register("mouseOver", function (e)
        if self:QuillIcon() and self:QuillIcon().visible then
            tes3ui.createTooltipMenu { item = self:getObj(), itemData = self:getData() }
        end
    end)

    local quillIcon = quillSelect:createImage{id = "Quill Icon", path = "Icons\\"..self:getObj().icon}
    quillIcon.borderAllSides = 6

    local uses = quillBlock:createLabel{id = "Uses", text = "Uses: "..self.quillCondition()}
    uses.color = {0,0,0}

    quillSelect:register("mouseClick", function()
        tes3ui.showInventorySelectMenu {
            title = "Magic Quills",
            filter = function(e)
                if e.item.id == Item.ID then
                    return true
                else
                    return false
                end
            end,
            callback = function(e)
                if e.item then
                    if not e.itemData then
                        e.itemData = self.addItemData(e.item)
                    end
                    self.setProps(e.item, e.itemData)
                    uses.text = "Uses: " .. e.itemData.condition
                end
                uses.visible = true
                quillIcon.visible = true
                main:updateLayout()
            end
        }
    end)
    local headerLabel = header:createLabel{id = "HeaderLabel", text = "Identify"}
    headerLabel.absolutePosAlignX = 0.45
    headerLabel.borderTop = 35
    headerLabel.color = {0,0,0}

    local itemList = main:createVerticalScrollPane({id = tes3ui.registerID("itemList")})
    itemList.parent.contentPath = "Menu_Scroll.NIF"
    itemList.parent.height = 512
    itemList.parent.width = 512
    itemList.parent.scaleMode = true
    itemList.contentPath = ""
    itemList.paddingBottom = 15
    itemList.paddingLeft = 40
    itemList.paddingRight = 40

    local counter = 0
    local iter = 1
    for _, stack in pairs(tes3.player.object.inventory) do
        local enchant = stack.object.enchantment
        local objType = stack.object.objectType
        if enchant --[[ and not data.bsIdentify[enchant.id] ]] and objType ~= tes3.objectType.book then
            for i, effect in ipairs(enchant.effects) do
                if effect.id > -1 then
                    if not self:isKnown(effect) then
                        local item, icon, label = self:createItemList(stack.object, itemList, counter)

                        item:register(tes3.uiEvent.mouseOver, function(e)
                            tes3ui.createTooltipMenu { item = stack.object, itemData = stack.variables }
                            label.color = tes3ui.getPalette(tes3.palette.normalColor)
                            e.source:getTopLevelMenu():updateLayout()
                        end)

                        item:register(tes3.uiEvent.mouseLeave, function(e)
                            label.color = { 0, 0, 0 }
                            e.source:getTopLevelMenu():updateLayout()
                        end)

                        item:register("mouseClick", function(e)
                            if self.quillCondition() > 0 then
                                self:getData().condition = self:getData().condition - 1
                                uses.text = "Uses: " .. self.quillCondition() ---Update Uses Text
                                if self:isKnown(effect) then
                                    if enchant.effects[i + iter].id ~= -1 then
                                        ---If the first effect is known move to the next
                                        self:learn(enchant.effects[i+iter].id)
                                        iter = iter + 1
                                    end
                                else
                                    self:learn(effect.id)
                                end
                                local destroy = true ---Track if all effects are known to destroy item element
                                for _, effect in ipairs(enchant.effects) do
                                    if effect.id ~= -1 then
                                        destroy = true
                                        if not self:isKnown(effect) then destroy = false end
                                    end
                                end
                                if destroy then e.source:destroy() iter = 1 end
                                tes3.playSound { sound = bs.sounds.book_page2}

                                ---Make uses update aswell
                                if self.quillCondition() == 0 then Identify:quillBreak() end
                            else
                                tes3.playSound{sound = bs.sounds.enchant_fail}
                            end
                            itemList.widget:contentsChanged()
                            main:updateLayout()
                            tes3.updateMagicGUI({reference = tes3.player})
                        end)

                        counter = counter + 1
                        break
                    end
                end
            end
        end
    end

    local close = main:createButton({ id = "close", text = "Cancel" })
    close.borderLeft = 20
    close.borderBottom = 10
    close:register(tes3.uiEvent.mouseClick, function (e)
        e.source:getTopLevelMenu():destroy()
        tes3ui.leaveMenuMode()
    end)

    main:updateLayout()
    headerLabel.sceneNode.scale = 2 ---wacky hacky
    main:updateLayout()
end


--- @param e equipEventData
function Identify.equip(e)
    if e.item.id == Item.ID then
        if not e.itemData then
            local itemData
            itemData = tes3.addItemData({to = tes3.mobilePlayer, item = e.item})
            itemData.condition = cfg.quillCondition
            e.itemData = itemData
        end
        Identify:Menu(e)
    end
end
event.register(tes3.event.equip, Identify.equip)


---@param e uiObjectTooltipEventData
function Identify.tooltips(e)
    local bsIdentify = Identify:knownList()
    if e.object.id == Item.ID then
        if e.itemData then e.tooltip:createLabel{text = "Uses: "..e.itemData.condition} end
    end

    local enchant = e.object.enchantment
    --- and cfg.visibleScroll
    if e.object.objectType == tes3.objectType.book then return end

    if enchant then
        if enchant.modified then bsIdentify[enchant.id] = true end

        for index, effect in ipairs(enchant.effects) do
            if effect.id > -1 then
                if not bsIdentify[effect.id] then
                    if Help:Charge() then Help:Charge():findChild("PartFillbar_text_ptr").text = "???/???" end
                    if Help:child("ChargeCost") then Help:child("ChargeCost").font = 2 end
                end

                for child, enchantTip in pairs(e.tooltip:findChild("HelpMenu_enchantmentContainer").children) do
                    if index == child then
                        if not bsIdentify[effect.id] then
                            enchantTip:findChild(Help.labelId).font = 2
                            enchantTip:findChild(Help.labelId).parent:createBlock{id = "effectMarker"}
                            enchantTip:findChild("image").contentPath = Identify.unknownIcon
                        end
                    end
                end
            end
        end
    end
end
event.register("uiObjectTooltip", Identify.tooltips)

--- @param e itemTileUpdatedEventData
function Identify.tileUpdate(e)
    local bsIdentify = Identify:knownList()
    local enchant = e.item.enchantment
    if enchant and enchant.modified and not bsIdentify[enchant.id] then bsIdentify[enchant.id] = true end
end
event.register(tes3.event.itemTileUpdated, Identify.tileUpdate)

---Hide UI Expansion Icons: why do they have to be destroyed and rebuilt every update...
---@param e uiActivatedEventData
function Identify.hideIcons(e)
    if not tes3.isLuaModActive("UI Expansion") then return end
    e.element:registerAfter(tes3.uiEvent.preUpdate, function (e)
        local icons = e.source:findChild("UIEXP:MagicMenu:SpellsList:Items:Icons")
        if not icons then return end
        for _, magicIcon in ipairs(icons.children) do
            if not magicIcon then return end
            local obj = magicIcon:getPropertyObject("MagicMenu_object") ---@type tes3clothing|tes3weapon|tes3armor|tes3book
            if obj and obj.enchantment then
                for _, effect in ipairs(obj.enchantment.effects) do
                    if effect.id ~= -1 then
                        if not Identify:knownList()[effect.id] then
                            magicIcon.contentPath = Identify.unknownIcon
                        else
                            magicIcon.contentPath = "Icons\\" .. effect.object.icon
                        end
                    end
                end
            end
        end
    end, -10)
end
event.register(tes3.event.uiActivated, Identify.hideIcons, {filter = "MenuMagic", --[[ priority = -10000 ]]})



return Identify