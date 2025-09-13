BetterCombinedBag = {}
local yBase = -65

local function GetBackItemsList(container)
    local buttons = {}
    for _, itemButton in container:EnumerateValidItems() do
        table.insert(buttons, itemButton)
    end

    return buttons
end

local function GetItemSize(container)
    for _, itemButton in container:EnumerateValidItems() do
        return itemButton:GetSize()
    end
end

local function CalcRows(container)
    local columns = BetterCombinedBagDB["Bag_Backpack_Columns"]
    local items = #GetBackItemsList(container)

    return math.ceil(items / columns)
end

local function CalcSplittedRows()
    local columns = BetterCombinedBagDB["Bag_Backpack_Columns"]
    local rows = 0

    for bagId = 0, 4 do
        local slots = C_Container.GetContainerNumSlots(bagId)
        rows = rows + math.ceil(slots / columns)
    end

    return rows
end

local function CalcWidth(itemWidth)
    local columns = BetterCombinedBagDB["Bag_Backpack_Columns"]
    local borderPadding = BetterCombinedBagDB["Bag_Border_Padding"]
    local itemPadding = BetterCombinedBagDB["Bag_Item_Padding"]

    return math.floor((columns * itemWidth) + ((columns - 1) * itemPadding) + (2 * borderPadding))
end

local function CalcHeight(itemHeight, container)
    local itemPadding = BetterCombinedBagDB["Bag_Item_Padding"]

    local rows
    if BetterCombinedBagDB["Bag_Toogle_Backpack_Split"] then
        rows = CalcSplittedRows()
    else
        rows = CalcRows(container)
    end

    return math.floor(90 + (rows * itemHeight) + (rows * itemPadding))
end

local function RenderItemButton(itemButton, container, xPos, yPos)
    if not itemButton then return end

    itemButton:ClearAllPoints()
    itemButton:SetPoint("TOPLEFT", container, "TOPLEFT", xPos, yPos)
end

function BetterCombinedBag:ResizeCombinedFrame(container)
    local itemSize = GetItemSize(container)
    local frameWidth = CalcWidth(itemSize)
    local frameHeight = CalcHeight(itemSize, container)

    container:SetSize(frameWidth, frameHeight)
end

function BetterCombinedBag:UpdateItemLayout(container)
    local items = GetBackItemsList(container)
    local borderPadding = BetterCombinedBagDB["Bag_Border_Padding"]
    local itemPadding = BetterCombinedBagDB["Bag_Item_Padding"]
    local itemSize = GetItemSize(container)
    local containerWidth, _ = container:GetSize()

    local xPos, yPos = BetterCombinedBagDB["Bag_Border_Padding"], yBase

    for index = #items, 1, -1 do
        local itemButton = items[index]
        RenderItemButton(itemButton, container, xPos, yPos)

        if (xPos + itemPadding + borderPadding + itemSize) < containerWidth then
            xPos = xPos + itemSize + itemPadding
        else
            yPos = yPos - itemSize - itemPadding
            xPos = borderPadding
        end
    end
end

function BetterCombinedBag:UpdateSplittedItemLayout(container)
    local items = GetBackItemsList(container)
    local borderPadding = BetterCombinedBagDB["Bag_Border_Padding"]
    local itemPadding = BetterCombinedBagDB["Bag_Item_Padding"]
    local itemSize = GetItemSize(container)
    local containerWidth, _ = container:GetSize()
    local columns = BetterCombinedBagDB["Bag_Backpack_Columns"]

    local yPos = yBase
    for bagId = 0, 4 do
        local containerSlots = C_Container.GetContainerNumSlots(bagId)

        local xPos = borderPadding
        for _, itemButton in ipairs(items) do
            if itemButton.bagID == bagId then
                RenderItemButton(itemButton, container, xPos, yPos)

                if (xPos + itemPadding + borderPadding + itemSize) <= containerWidth then
                    xPos = xPos + itemSize + itemPadding
                else
                    yPos = yPos - itemSize - itemPadding
                    xPos = borderPadding
                end
            end
        end
        if (containerSlots / columns) ~= 2 then
            yPos = yPos - itemSize - itemPadding
        end
    end
end