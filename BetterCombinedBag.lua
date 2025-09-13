BetterCombinedBag = {}

local function CollectItems(container)
    local items = {}
    local itemsByBag = { [0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {}}
    local itemSize = 0

    for _, itemButton in container:EnumerateValidItems() do
        table.insert(items, itemButton)
        table.insert(itemsByBag[itemButton.bagID], itemButton)
        if itemSize == 0 then
            itemSize = itemButton:GetSize()
        end
    end

    for index = 0, 4 do
        table.sort(itemsByBag[index], function(a, b) return a:GetID() < b:GetID() end)
    end

    return items, itemSize, itemsByBag
end

local function CalculateFrameSize(itemSize, numItems)
    local db = BetterCombinedBagDB
    local columns = db["Bag_Backpack_Columns"]
    local borderPadding = db["Bag_Border_Padding"]
    local itemPadding = db["Bag_Item_Padding"]

    local width = math.floor((columns * itemSize) + ((columns - 1) * itemPadding) + (2 * borderPadding))

    local rows = 0
    if db["Bag_Toogle_Backpack_Split"] then
        for bagId = 0, 4 do
            local slots = C_Container.GetContainerNumSlots(bagId)
            rows = rows + math.ceil(slots / columns)
        end
    else
        rows = math.ceil(numItems / columns)
    end

    local height = math.floor(90 + (rows * itemSize) + ((rows - 1)* itemPadding))

    return width, height
end

local function RenderItemButton(itemButton, container, xPos, yPos)
    if not itemButton then return end

    itemButton:ClearAllPoints()
    itemButton:SetPoint("TOPLEFT", container, "TOPLEFT", xPos, yPos)
end

local function UpdateCombinedLayout(container, items, itemSize)
    local db = BetterCombinedBagDB
    local borderPadding = db["Bag_Border_Padding"]
    local itemPadding = db["Bag_Item_Padding"]
    local columns, counter = db["Bag_Backpack_Columns"], 0

    local xPos = borderPadding
    local yPos = -65

    for index = #items, 1, -1 do
        local itemButton = items[index]
        RenderItemButton(itemButton, container, xPos, yPos)

        counter = counter + 1
        if counter < columns then
            xPos = xPos + itemSize + itemPadding
        else
            yPos = yPos - itemSize - itemPadding
            xPos = borderPadding
            counter = 0
        end
    end
end

local function UpdateSplittedLayout(container, itemsByBag, itemSize)
    local db = BetterCombinedBagDB
    local borderPadding = db["Bag_Border_Padding"]
    local itemPadding = db["Bag_Item_Padding"]
    local columns = db["Bag_Backpack_Columns"]

    local yPos = -65

    for bagId = 0, 4 do
        local bagItems = itemsByBag[bagId]
        if #bagItems > 0 then
            local xPos = borderPadding
            local counter = 0

            for index = 1, #bagItems do
                local itemButton = bagItems[index]
                RenderItemButton(itemButton, container, xPos, yPos)

                counter = counter + 1
                if counter < columns then
                    xPos = xPos + itemSize + itemPadding
                else
                    yPos = yPos - itemSize - itemPadding
                    xPos = borderPadding
                    counter = 0
                end
            end
            if counter ~= 0 then
                yPos = yPos - itemSize - itemPadding
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