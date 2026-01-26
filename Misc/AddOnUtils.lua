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

function addon.AddInspectItemLevelComponent(frame)
    if frame ~= nil and frame.AverageItemLevelComponent == nil then
        local c = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalOutline")
        c:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 14, 9)
        c:SetTextColor(1, 1, 1, 1)
        c:SetScale(1.3)

        frame.AverageItemLevelComponent = c
    end
end

function addon.UpdateInspectItemLevelComponent(level)
    local frame = InspectPaperDollFrame
    addon.AddInspectItemLevelComponent(frame)

    if frame ~= nil and level ~= nil then
        local text = "Average: " .. level
        frame.AverageItemLevelComponent:SetText(text)
        frame.AverageItemLevelComponent:Show()
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
            addon.ItemInfoCache[i][j] = info
        end
    end
end

-- Decide which Atlas to use, since Midnight reduces reagents tiers from 5 to 3
function addon.GetMaterialQualityAtlas(itemId, tier)
    local itemInfo = { GetItemInfo(itemId) }
    if itemInfo ~= nil then
        if itemInfo[15] < 11 then
            return "professions-icon-quality-tier"..tier.."-inv"
        else
            return "professions-icon-quality-12-tier"..tier.."-inv"
        end
    end
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