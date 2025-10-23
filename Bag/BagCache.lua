BagCache = {}

-- Cache Bag Sizes per Id
BagCache._bagSlots = {[0] = 0, [1] = 0, [2] = 0, [3] = 0, [4] = 0}

-- Cache ItemData by bagId and slot
BagCache._itemBagCache = {[0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {}}
BagCache._itemLevelCache = {[0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {}}

-- Cache if Item is equipable
BagCache._equipableCache = {}

-- Refresh the complete Player Bag Cache
function BagCache:RefreshCache()
    BagCache:UpdateBagSlots()
    BagCache:UpdateBagItems()
    BagCache:UpdateItemLevels()
end

-- Refresh the sizes of all Bags
function BagCache:UpdateBagSlots()
    for bagId = 0, 4 do
        -- if there is no Bag in the id the size is 0
        self._bagSlots[bagId] = C_Container.GetContainerNumSlots(bagId)
    end
end

-- Collect ItemInfos
function BagCache:UpdateBagItems()
    table.wipe(self._equipableCache)

    for bagId = 0, 4 do
        -- Wipe old data
        table.wipe(self._itemBagCache[bagId])
        local slots = self._bagSlots[bagId]

        -- Collect all ItemInfos for the BagId
        if slots > 0 then
            for slot = 1, slots do
                -- GetContainerItemInfo gives a nil value
                local itemInfo = C_Container.GetContainerItemInfo(bagId, slot)

                if itemInfo and itemInfo.itemID then
                    -- Request Data
                    local itemId, _, _, equipLoc = C_Item.GetItemInfoInstant(itemInfo.itemID)

                    -- Save ItemInfo
                    self._itemBagCache[bagId][slot] = itemInfo

                    -- Cache if item is equipable
                    if self._equipableCache[itemId] == nil then
                        local equipable = equipLoc ~= nil and equipLoc ~= "" and equipLoc ~= "INVTYPE_NON_EQUIP_IGNORE"
                        self._equipableCache[itemId] = equipable
                    end
                end
            end
        end
    end
end

-- cache ItemLevel for equipable items
function BagCache:UpdateItemLevels()
    for bagId = 0, 4 do
        for slot = 1, self._bagSlots[bagId] do
            local itemInfo = self._itemBagCache[bagId][slot]
            if itemInfo and BagCache:IsEquipable(itemInfo.itemID) then
                local itemLoc = ItemLocation:CreateFromBagAndSlot(bagId, slot)
                local itemLevel = C_Item.GetCurrentItemLevel(itemLoc)
                self._itemLevelCache[bagId][slot] = itemLevel
            end
        end
    end
end

-- return ItemInfo
---@return ContainerItemInfo? containerInfo
function BagCache:GetItemInfo(bagId, slot)
    if self._itemBagCache[bagId] then
        return self._itemBagCache[bagId][slot]
    else return nil end
end

-- return ItemLevel
---@param bagId integer
---@param slot integer
---@return integer
function BagCache:GetItemLevel(bagId, slot)
    if self._itemLevelCache[bagId] then
        return self._itemLevelCache[bagId][slot]
    else return 0 end
end

-- return BagSize
---@param bagId integer
---@return integer
function BagCache:GetBagSize(bagId)
    if self._bagSlots[bagId] then
        return self._bagSlots[bagId]
    else return 0 end
end

-- get the size of all Player Bags excluding the reagents bag
---@return integer
function BagCache:GetFullBagSize()
    local slots = 0
    for bagId = 0, 4 do
        slots = slots + BagCache:GetBagSize(bagId)
    end

    return slots
end

-- check if ItemId is equipable
---@param itemId number
---@return boolean
function BagCache:IsEquipable(itemId)
    return self._equipableCache[itemId] or false
end