local _, addon = ...

local slots = {
    "Head", "Neck", "Shoulder", "Back", "Chest", "Shirt", "Tabard", "Wrist",
    "Hands", "Waist", "Legs", "Feet", "Finger0", "Finger1", "Trinket0", "Trinket1",
    "MainHand", "SecondaryHand"
}

function addon.ShowCharacterItemLevel()
    for _, slotName in ipairs(slots) do
        local button = _G["Character"..slotName.."Slot"]
        addon.AddItemLevelComponent(button)

        local itemLoc = ItemLocation:CreateFromEquipmentSlot(button:GetID())

        if BCB_Settings.showFor.character and C_Item.DoesItemExist(itemLoc) then
            local level = C_Item.GetCurrentItemLevel(itemLoc)
            local quality = C_Item.GetItemQuality(itemLoc)

            addon.UpdateItemLevelComponent(button, level, quality)
            button.ItemLevelComponent:Show()
        else
            button.ItemLevelComponent:Hide()
        end
    end
end