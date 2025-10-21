BagCache = {}

-- Cache Items by BagsIds
local _itemsByBag = {[0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {}}
local _itemLevelCache = {[0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {}}

-- Cache if Item is equipable
local _equipableCache = {}

-- Cache Bag Sizes per Id
local _bagSlots = {[0] = 0, [1] = 0, [2] = 0, [3] = 0, [4] = 0}

-- Refresh the complete Player Bag Cache
function BagCache:RefreshCache()
    BagCache:UpdateBagSlots()
    BagCache:UpdateBagItems()
end

-- Refresh the sizes of all Bags
function BagCache:UpdateBagSlots()
    for bagId = 0, 4 do
        -- if there is no Bag in the id the size is 0
        _bagSlots[bagId] = C_Container.GetContainerNumSlots(bagId)
    end
end

-- Collect ItemInfos
function BagCache:UpdateBagItems()
    -- Wipe equipable cache
    table.wipe(_equipableCache)

    for bagId = 0, 4 do
        -- Wipe old data
        table.wipe(_itemsByBag[bagId])
        table.wipe(_itemLevelCache[bagId])
        local slots = _bagSlots[bagId]

        -- Collect all ItemInfos for the BagId
        if slots > 0 then
            for slot = 1, slots do
                local itemInfo = C_Container.GetContainerItemInfo(bagId, slot)
                if itemInfo and itemInfo.itemID then
                    -- Request Data
                    local itemId = itemInfo.itemID
                    local _, _, _, level, _, _, _, _, equipLoc = C_Item.GetItemInfo(itemInfo.hyperlink)

                    -- Save ItemInfo
                    _itemsByBag[bagId][slot] = itemInfo

                    -- Cache ItemLevel
                    _itemLevelCache[bagId][slot] = level or 0

                    -- Cache if item is equipable
                    if _equipableCache[itemId] == nil then
                        local equipable = equipLoc ~= nil and equipLoc ~= "" and equipLoc ~= "INVTYPE_NON_EQUIP_IGNORE"
                        _equipableCache[itemId] = equipable
                    end
                end
            end
        end
    end
end

-- return ItemInfo
function BagCache:GetItemInfo(bagId, slot)
    if _itemsByBag[bagId] then
        return _itemsByBag[bagId][slot]
    else return nil end
end

-- return ItemLevel
function BagCache:GetItemLevel(bagId, slot)
    if _itemLevelCache[bagId] then
        return _itemLevelCache[bagId][slot]
    else return 0 end
end

-- check if ItemId is equipable
function BagCache:IsEquipable(itemId)
    return _equipableCache[itemId] or false
end