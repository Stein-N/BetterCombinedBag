BagCache = {}

-- Cache Items by BagsIds
local _itemsByBag = {[0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {}}

-- Cache if Item is equipable
local _equipableCache = setmetatable({}, {_mode = "k"})

-- Cache Bag Sizes per Id
local _bagSlots = {[0] = 0, [1] = 0, [2] = 0, [3] = 0, [4] = 0}

-- Refresh the complete Player Bag Cache
function BagCache:RefreshCache(container)
    -- only refresh Cache if the Bag is actually combined
    if not container == ContainerFrameCombinedBags then return end

    BagCache:UpdateBagSlots()
    BagCache:UpdateBagItems(container)
end

-- Refresh the sizes of all Bags
function BagCache:UpdateBagSlots()
    for bagId = 0, 4 do
        -- if there is no Bag in the id the size is 0
        _bagSlots[bagId] = C_Container.GetContainerNumSlots(bagId)
    end
end

-- Collect all ItemButtons of the given Container
function BagCache:UpdateBagItems(container)
    -- Wipe all ItemButtons from the Cache
    for bagId = 0, 4 do table.wipe(_itemsByBag[bagId]) end

    for _, itemButton in container:EnumerateValidItems() do
        local slot = itemButton:GetID()
        _itemsByBag[itemButton.bagID][slot] = itemButton
    end
end

function BagCache:UpdaetEquipable()
    
end