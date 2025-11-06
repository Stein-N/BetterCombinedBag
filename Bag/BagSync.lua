BagSync = {}
local langCode = GetLocale()

function BagSync.SaveInventory()
    local name, _ = UnitName("player")

    if BCB_Sync[name] then
        table.wipe(BCB_Sync[name])
    else
        BCB_Sync[name] = {}
    end

    for i = 0, 5 do
        for j = 1, BagCache.GetBagSize(i) do
            local info = BagCache.GetItemInfo(i, j)
            if info then
                local amount = BCB_Sync[name][info.itemID]
                if amount ~= nil then
                    BCB_Sync[name][info.itemID] = amount + info.stackCount
                else
                    BCB_Sync[name][info.itemID] = info.stackCount
                end
            end
        end
    end
end

function BagSync.AddLocalizedHint(tooltip)
    local translation = BagData.bagSync[langCode] or BagData.bagSync["enEN"]
    tooltip:AddLine("|cff00ff00" .. translation.tooltipHint)
    tooltip:Show()
end