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

function addon.ShowInspectAverageLevel()

end

function addon.ShowInspectItemLevel()
    local unit = InspectFrame.unit
    if unit == nil then return end

    local itemLevel = C_PaperDollInfo.GetInspectItemLevel(unit)
    addon.UpdateInspectItemLevelComponent(itemLevel)

    for _, slotName in ipairs(slots) do
        local btn = _G["Inspect"..slotName.."Slot"]
        addon.AddItemLevelComponent(btn)

        if BCB_Settings.showFor.character and btn ~= nil then
            local link = GetInventoryItemLink(unit, btn:GetID())

            if link ~= nil then
                local item = Item:CreateFromItemLink(link)

                if item ~= nil then
                    addon.UpdateItemLevelComponent(btn, item:GetCurrentItemLevel(), item:GetItemQuality())
                end
            else
                btn.ItemLevelComponent:Hide()
            end
        end
    end
end

hooksecurefunc(CharacterFrame, "Show", function()
    addon.ShowCharacterItemLevel()
end)