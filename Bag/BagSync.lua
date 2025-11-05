BagSync = {}

function BagSync.SaveInventory()
    local name, _ = UnitName("player")

    if BCB_Sync[name] then
        table.wipe(BCB_Sync[name])
    else
        BCB_Sync[name] = {}
    end

    for i = 0, 5 do
        for j = 1, BagCache.GetBagSize(i) do
            local loc = ItemLocation:CreateFromBagAndSlot(i, j)
            if C_Item.DoesItemExist(loc) then
                if C_Item.IsBound(loc) == false then
                    local info = C_Container.GetContainerItemInfo(i, j)

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
end