local _, addon = ...

local slots = {
    "Head", "Neck", "Shoulder", "Back", "Chest", "Shirt", "Tabard", "Wrist",
    "Hands", "Waist", "Legs", "Feet", "Finger0", "Finger1", "Trinket0", "Trinket1",
    "MainHand", "SecondaryHand"
}

local function AddInspectItemLevelComponent(frame)
    if frame ~= nil and frame.AverageItemLevelComponent == nil then
        local c = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalOutline")
        c:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 7, 9)
        c:SetTextColor(1, 1, 1, 1)
        c:SetScale(1.3)

        frame.AverageItemLevelComponent = c
    end
end

local function UpdateInspectItemLevelComponent(level)
    local frame = InspectPaperDollFrame
    AddInspectItemLevelComponent(frame)

    if frame ~= nil and level ~= nil then
        local text = "Avg: " .. level
        frame.AverageItemLevelComponent:SetText(text)
        frame.AverageItemLevelComponent:Show()
    end
end

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
    local unit = InspectFrame.unit
    if unit == nil then return end

    local itemLevel = C_PaperDollInfo.GetInspectItemLevel(unit)
    UpdateInspectItemLevelComponent(itemLevel)
end

function addon.ShowInspectItemLevel()
    local unit = InspectFrame.unit
    if unit == nil then return end

    for _, slotName in ipairs(slots) do
        local btn = _G["Inspect"..slotName.."Slot"]
        addon.AddItemLevelComponent(btn)

        if BCB_Settings.showFor.inspect and btn ~= nil then
            local link = GetInventoryItemLink(unit, btn:GetID())

            if link ~= nil then
                local level = addon.GetItemLevelFromItemLink(link)
                local item = Item:CreateFromItemLink(link)

                if level ~= nil and item ~= nil then
                    addon.UpdateItemLevelComponent(btn, level, item:GetItemQuality())
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