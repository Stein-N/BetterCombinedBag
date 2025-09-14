BetterCombinedBag = {}

local _items = {}
local _itemsByBag = { [0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {} }

-- Caches ItemsIDs and if they are equipable
local _eqipmentCache = setmetatable({}, { __mode = "k"})
-- Caches Back Slot count
local _bagSlots = { [0]=0, [1]=0, [2]=0, [3]=0, [4]=0 }

function BetterCombinedBag:RefreshBagSlots()
    for bagId = 0, 4 do
        _bagSlots[bagId] = C_Container.GetContainerNumSlots(bagId)
    end
end

local function WipeItems()
    table.wipe(_items)
    for bagId = 0, 4 do
        table.wipe(_itemsByBag[bagId])
    end
end

local function CollectItems(container)
    WipeItems()

    local itemSize = 0
    local index = 0

    for _, itemButton in container:EnumerateValidItems() do
        index = index + 1
        _items[index] = itemButton

        local slot = itemButton:GetID()
        _itemsByBag[itemButton.bagID][slot] = itemButton

        if itemSize == 0 then itemSize = itemButton:GetSize() end
    end

    return _items, itemSize, _itemsByBag
end

local function CalculateFrameSize(itemSize, numItems)
    local db = BetterCombinedBagDB
    local columns = db["Bag_Backpack_Columns"]
    local borderPadding = db["Bag_Border_Padding"]
    local itemPadding = db["Bag_Item_Padding"]

    local width = (columns * itemSize) + ((columns - 1) * itemPadding) + (2 * borderPadding)

    local rows = 0
    if db["Bag_Toogle_Backpack_Split"] then
        for bagId = 0, 4 do
            local slots = (_bagSlots[bagId] or 0)
            rows = rows + math.ceil(slots / columns)
        end
    else
        rows = math.ceil(numItems / columns)
    end

    local height = 90 + (rows * itemSize) + ((rows - 1) * itemPadding)

    return width, height
end

local function IsItemEquipableByItemID(itemId)
    local cached = _eqipmentCache[itemId]
    if cached ~= nil then return cached end

    local _, _, _, equipLoc = C_Item.GetItemInfoInstant(itemId)
    local equip = (equipLoc ~= nil and equipLoc ~= "" and equipLoc ~= "INVTYPE_NON_EQUIP_IGNORE") or false
    _eqipmentCache[itemId] = equip

    return equip
end

local function IsItemEquipable(itemButton)
    local itemLoc = ItemLocation:CreateFromBagAndSlot(itemButton.bagID, itemButton:GetID())
    if C_Item.DoesItemExist(itemLoc) then
        local itemId = C_Item.GetItemID(itemLoc)
        if itemId then
            return IsItemEquipableByItemID(itemId)
        end
    end

    return false
end

local function GetItemLevel(itemButton)
    local itemLoc = ItemLocation:CreateFromBagAndSlot(itemButton.bagID, itemButton:GetID())
    if C_Item.DoesItemExist(itemLoc) then
        return C_Item.GetCurrentItemLevel(itemLoc)
    end

    return nil
end

local function HideItemLevel(itemButton)
    local text = itemButton.BagItemLevel
    if text then text:Hide() end
end

local function UpdateItemLevel(itemButton, itemLevel)
    local text = itemButton.BagItemLevel
    if text then
        text:SetText(itemLevel)
        text:Show()
    end
end

local function AddItemLevel(itemButton)
    local itemLevel = GetItemLevel(itemButton)
    if not itemLevel then return end

    if itemButton.BagItemLevel then
        if itemButton.__lastItemLevel ~= itemLevel then
            UpdateItemLevel(itemButton, itemLevel)
            itemButton.__lastItemLevel = itemLevel
        else
            itemButton.BagItemLevel:Show()
        end

        return
    end

    local text = itemButton:CreateFontString(nil, "OVERLAY", "GameFontNormalOutline")
    text:SetPoint("BOTTOMRIGHT", itemButton, "BOTTOMRIGHT", 0, 0)
    text:SetTextColor(1, 1, 1, 1)
    text:SetScale(1.3)
    itemButton.BagItemLevel = text

    UpdateItemLevel(itemButton, itemLevel)
    itemButton.__lastItemLevel = itemLevel
end

local function RenderItemLevel(itemButton)
    if IsItemEquipable(itemButton) then
        AddItemLevel(itemButton)
    else HideItemLevel(itemButton) end
end

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
            RenderItemLevel(itemButton)

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
                    RenderItemLevel(itemButton)

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
