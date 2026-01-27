local _, addon = ...
local itemInfoCache = {}

--- Adds the ItemLevelComponent to the given itemButton
function addon.AddItemLevelComponent(itemButton)
    if not itemButton.ItemLevelComponent then
        local c = itemButton:CreateFontString(nil, "OVERLAY", "GameFontNormalOutline")
        c:SetPoint("BOTTOMRIGHT", itemButton, "BOTTOMRIGHT", 0, 1)
        c:SetTextColor(1, 1, 1, 1)
        c:SetScale(1.0)

        itemButton.ItemLevelComponent = c
    end
end

-- Updates the ItemLevelComponent
function addon.UpdateItemLevelComponent(button, level, quality)
    if button then
        button.ItemLevelComponent:SetText(level)
        button.ItemLevelComponent:SetScale(BCB_Settings.itemLevelScale / 100)

        if BCB_Settings.itemLevelColor and quality ~= nil then
            local r, g, b = C_Item.GetItemQualityColor(quality)
            button.ItemLevelComponent:SetTextColor(r, g, b)
        else
            button.ItemLevelComponent:SetTextColor(1, 1, 1)
        end

        button.ItemLevelComponent:Show()
    end
end

-- Cache ItemInfo of all available Bags
function addon.CacheAllItems()
    for _, bagId in pairs(Enum.BagIndex) do
        local bagSize = C_Container.GetContainerNumSlots(bagId)
        itemInfoCache[bagId] = {}

        for slot = 1, bagSize do
            local itemInfo = C_Container.GetContainerItemInfo(bagId, slot)
            itemInfoCache[bagId][slot] = itemInfo
        end
    end
end

function addon.GetItemInfo(bagId, slot)
    if itemInfoCache[bagId] ~= nil and itemInfoCache[bagId][slot] ~= nil then
        return itemInfoCache[bagId][slot]
    end

    return nil
end

function addon.GetItemLevelFromItemLink(itemLink)
    if itemLink ~= nil then
        local tooltipData = C_TooltipInfo.GetHyperlink(itemLink)
        if tooltipData ~= nil and tooltipData.lines ~= nil then
            for _, data in ipairs(tooltipData.lines) do
                if data.type == Enum.TooltipDataLineType.ItemLevel then
                    return data.itemLevel
                end
            end
        end
    end

    return nil
end

function addon.GetFrameSetting(expected, fallback)
    if BCB_Settings.separateFrame then
        return BCB_Settings[expected]
    else
        return BCB_Settings[fallback]
    end
end

function addon.CanShowItemLevel(bagId)
    if bagId >= 0 and bagId <= 5 then
        return BCB_Settings.showFor.bag
    end

    if bagId >= 6 and bagId <= 17 then
        return BCB_Settings.showFor.bank
    end

    return false
end