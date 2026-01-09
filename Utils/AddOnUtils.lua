local _, addon = ...

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
        if not button.ItemLevelComponent then
            addon.AddItemLevelComponent(button)
        end

        button.ItemLevelComponent:SetText(level)
        button.ItemLevelComponent:SetScale(BCB_Settings.itemLevelScale / 100)

        if BCB_Settings.itemLevelColor and quality ~= nil then
            local r, g, b = C_Item.GetItemQualityColor(quality)
            button.ItemLevelComponent:SetTextColor(r, g, b)
        else
            button.ItemLevelComponent:SetTextColor(1, 1, 1)
        end
    end
end

-- Cache ItemInfo of all available Bags
function addon.CacheItemInfos()
    if addon.ItemInfoCache == nil then
        addon.ItemInfoCache = {}
    end

    for _, i in pairs(Enum.BagIndex) do
        local bagSize = C_Container.GetContainerNumSlots(i)
        for j = 1, bagSize do
            if addon.ItemInfoCache[i] == nil then
                addon.ItemInfoCache[i] = {}
            end

            local info = C_Container.GetContainerItemInfo(i, j)
            if info then
                addon.ItemInfoCache[i][j] = info
            end
        end
    end
end

-- TODO: really needed?
function addon.GetItemInfo(bagId, slot)
    return addon.ItemInfoCache[bagId][slot]
end