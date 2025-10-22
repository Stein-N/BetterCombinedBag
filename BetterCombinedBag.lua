BetterCombinedBag = {}

local _items = {}
local _itemsByBag = { [0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {} }

-- Caches ItemsIDs and if they are equipable
local _eqipmentCache = setmetatable({}, { __mode = "k"})
-- Caches Back Slot count
local _bagSlots = { [0]=0, [1]=0, [2]=0, [3]=0, [4]=0 }





local function UpdateCombinedLayout(container, items, itemSize)
    local db = BetterCombinedBagDB
    local borderPadding = db["Bag_Border_Padding"]
    local itemPadding = db["Bag_Item_Padding"]
    local columns = db["Bag_Backpack_Columns"]

    local xPos = borderPadding
    local yPos = -65
    local counter = 0
    local stepX = itemSize + itemPadding
    local stepY = itemSize + itemPadding

    for index = #items, 1, -1 do
        local itemButton = items[index]
        if itemButton then
            itemButton:ClearAllPoints()
            itemButton:SetPoint("TOPLEFT", container, "TOPLEFT", xPos, yPos)

            counter = counter + 1
            if counter < columns then
                xPos = xPos + stepX
            else
                yPos = yPos - stepY
                xPos = borderPadding
                counter = 0
            end
        end
    end
end






local function UpdateSplittedLayout(container, itemsByBag, itemSize)
        local db = BetterCombinedBagDB
    local borderPadding = db["Bag_Border_Padding"]
    local itemPadding = db["Bag_Item_Padding"]
    local columns = db["Bag_Backpack_Columns"]

    local yPos = -65
    local stepX = itemSize + itemPadding
    local stepY = itemSize + itemPadding

    for bagId = 0, 4 do
        local bagItems = itemsByBag[bagId]
        if bagItems then
            local xPos = borderPadding
            local counter = 0

            local maxSlot = _bagSlots[bagId] or 0
            for slot = 1, maxSlot do
                local itemButton = bagItems[slot]
                if itemButton then
                    itemButton:ClearAllPoints()
                    itemButton:SetPoint("TOPLEFT", container, "TOPLEFT", xPos, yPos)

                    counter = counter + 1
                    if counter < columns then
                        xPos = xPos + stepX
                    else
                        yPos = yPos - stepY
                        xPos = borderPadding
                        counter = 0
                    end
                end
            end

            if counter ~= 0 then
                yPos = yPos - stepY
            end
        end
    end
end

















function BetterCombinedBag:UpdateFrameSize(container)
    if not container then return end
    local items, itemSize, _ = CollectItems(container)
    local width, height = CalculateFrameSize(itemSize, #items)
    container:SetSize(width, height)
end

function BetterCombinedBag:UpdateItemLayout(container)
    if not container then return end
    local items, itemSize, itemsByBag = CollectItems(container)

    if BetterCombinedBagDB["Bag_Toogle_Backpack_Split"] then
        UpdateSplittedLayout(container, itemsByBag, itemSize)
    else
        UpdateCombinedLayout(container, items, itemSize)
    end
end

function BetterCombinedBag:UpdateItemLevels(container)
    if not container then return end
    for _, itemButton in container:EnumerateValidItems() do
        if itemButton ~= nil then
            RenderItemLevel(itemButton)
        end
    end
end
