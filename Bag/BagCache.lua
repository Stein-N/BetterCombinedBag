BagCache = {}

local _bagCount = 4

-- Cache Bag Sizes per Id
local _bagSlots = {[0] = 0, [1] = 0, [2] = 0, [3] = 0, [4] = 0}

-- Cache ItemData by bagId and slot
local _itemBagCache = {[0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {}}
local _itemLevelCache = {[0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {}}

-- Cache if Item is equipable
local _equipableCache = {}

-- Refresh the complete Player Bag Cache
function BagCache:RefreshCache()
    BagCache:UpdateBagSlots()
    BagCache:UpdateBagItems()
    BagCache:UpdateItemLevels()
end

-- Refresh the sizes of all Bags
function BagCache:UpdateBagSlots()
    for bagId = 0, _bagCount do
        -- if there is no Bag in the id the size is 0
        _bagSlots[bagId] = C_Container.GetContainerNumSlots(bagId)
    end
end

-- Collect ItemInfos excluding reagents bag
function BagCache:UpdateBagItems()
    table.wipe(_equipableCache)

    for bagId = 0, _bagCount do
        -- Wipe old data
        table.wipe(_itemBagCache[bagId])
        local slots = _bagSlots[bagId]

        -- Collect all ItemInfos for the BagId
        if slots > 0 then
            for slot = 1, slots do
                -- GetContainerItemInfo gives a nil value
                local itemInfo = C_Container.GetContainerItemInfo(bagId, slot)

                if itemInfo and itemInfo.itemID then
                    -- Request Data
                    local itemId, _, _, equipLoc = C_Item.GetItemInfoInstant(itemInfo.itemID)

                    -- Save ItemInfo
                    _itemBagCache[bagId][slot] = itemInfo

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

-- Cache ItemLevel for equipable items
function BagCache:UpdateItemLevels()
    for bagId = 0, _bagCount do
        for slot = 1, _bagSlots[bagId] do
            local itemInfo = _itemBagCache[bagId][slot]
            if itemInfo and BagCache:IsEquipable(itemInfo.itemID) then
                local itemLoc = ItemLocation:CreateFromBagAndSlot(bagId, slot)
                local itemLevel = C_Item.GetCurrentItemLevel(itemLoc)
                _itemLevelCache[bagId][slot] = itemLevel
            end
        end
    end
end

-- Return the ItemInfo of specifc Bag
---@return ContainerItemInfo? containerInfo
function BagCache:GetItemInfo(bagId, slot)
    if _itemBagCache[bagId] then
        return _itemBagCache[bagId][slot]
    else return nil end
end

-- Return ItemLevel for a specific Item
---@param bagId integer
---@param slot integer
---@return integer
function BagCache:GetItemLevel(bagId, slot)
    if _itemLevelCache[bagId] then
        return _itemLevelCache[bagId][slot]
    else return 0 end
end

-- Return the amount of Bags
---@return integer
function BagCache:GetBagAmount()
    return _bagCount
end

-- Return the size of a specific Bag
---@param bagId integer
---@return integer
function BagCache:GetBagSize(bagId)
    if _bagSlots[bagId] then
        return _bagSlots[bagId]
    else return 0 end
end

-- Get the size of all Player Bags excluding the reagents bag
---@return integer
function BagCache:GetFullBagSize()
    local slots = 0
    for bagId = 0, _bagCount do
        slots = slots + BagCache:GetBagSize(bagId)
    end

    return slots
end

-- check if ItemId is equipable
---@param itemId number
---@return boolean
function BagCache:IsEquipable(itemId)
    return _equipableCache[itemId] or false
end