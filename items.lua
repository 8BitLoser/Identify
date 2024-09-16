local common = require("BeefStranger.Identify.common")

---@class bsMagicQuillItem
local Item = {}
Item.ID = "BS_Magic_Quill"
Item.mesh = "bs\\bs_magicquill.NIF"
Item.icon = "bs\\magicQuill.tga"

Item.levelLists = {
    "l_n_soul gem",
    "l_n_repair item",
}

---Create Magic Quill Object
function Item:createQuillObj()
    local magicQuill = tes3.createObject { id = self.ID, objectType = tes3.objectType.miscItem } --- @type tes3misc
    magicQuill.mesh = self.mesh
    magicQuill.icon = self.icon
    magicQuill.name = "Magic Quill"
    magicQuill.weight = 0.01
    magicQuill.value = 75
    Item.quillObj = magicQuill
end

---@param enchantment tes3enchantment
function Item.learnAll(enchantment)
    for _, effect in ipairs(enchantment.effects) do
        common:learn(effect)
    end
end

---Add Quill to Leveled list
function Item:addToLists()
    for index, list in ipairs(self.levelLists) do
        tes3.getObject(list):insert(self.quillObj, 3)
        
    end
end

---Distribute Quills to Enchanters/LeveledLists
function Item:distributeQuills()
    for actor in tes3.iterateObjects(tes3.objectType.npc) do
        ---@cast actor tes3npc
        if actor.class.bartersEnchantedItems then
            if not actor.inventory:contains(self.quillObj) then
                actor.inventory:addItem{item = self.quillObj, count = -math.random(1, 5)}
            end
        end
    end
    self:addToLists()
end

--- @param e barterOfferEventData
local function enchantPurchased(e)
    if e.buying then
        for _, tile in ipairs(e.buying) do
            if tile.item.enchantment then
                common.learnAll(tile.item.enchantment)
            end
        end
    end
end
event.register(tes3.event.barterOffer, enchantPurchased)

return Item