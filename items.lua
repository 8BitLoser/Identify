---@class bsMagicQuillItem
local Item = {}
Item.ID = "BS_Magic_Quill"
Item.mesh = "bs\\bs_magicquill.NIF"
Item.icon = "bs\\magicQuill.tga"


function Item:createQuillObj()
    local magicQuill = tes3.createObject { id = self.ID, objectType = tes3.objectType.miscItem } --- @type tes3misc
    magicQuill.mesh = self.mesh
    magicQuill.icon = self.icon

    magicQuill.name = "Magic Quill"
    magicQuill.weight = 0.01
    magicQuill.value = 75

    Item.quillObj = magicQuill
end


function Item:purchasedEnchant(e)
    
end



return Item