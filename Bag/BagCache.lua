BagCache = {}

local _bagCount = 5
local _bagSlots = {[0] = 0, [1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0}
local _itemInfoCache = {[0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}}

function BagCache.UpdateBagSlots()
    for i = 0, _bagCount do
        _bagSlots[i] = C_Container.GetContainerNumSlots(i)
    end
end

function BagCache.CacheBagItems()
    for i = 0, _bagCount do
        table.wipe(_itemInfoCache[i])

        for j = 1, _bagSlots[i] do
            local itemInfo = C_Container.GetContainerItemInfo(i, j)
            if itemInfo then
                _itemInfoCache[i][j] = itemInfo
            end
        end
    end
end

function BagCache.GetItemInfo(bagId, slot)
    if _itemInfoCache[bagId] then
        return _itemInfoCache[bagId][slot]
    else return nil end
end

function BagCache.GetBagCount()
    return _bagCount
end

function BagCache.GetBagSize(bagId)
    return _bagSlots[bagId]
end

function BagCache.GetFullBagSize()
    local slots = 0
    for i = 0, _bagCount - 1 do
        slots = slots + _bagSlots[i]
    end
    return slots
end

function BagCache.GetMaxItemPerRow(columns, reagentsBag)
    local max = 0
    for i = 0, _bagCount do
        if i < 5 or reagentsBag then
            if max < _bagSlots[i] then
                max = _bagSlots[i]
            end
        end
    end

    return max < columns and max or columns
end