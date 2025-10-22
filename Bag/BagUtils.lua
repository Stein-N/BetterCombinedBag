BagUtils = {}

local columns;
local borderPadding;
local itemPadding;
local splitBackpack;

function BagUtils:UpdateSettings()
    local db = BetterCombinedBagDB
    borderPadding = db["Bag_Border_Padding"]
    itemPadding = db["Bag_Item_Padding"]
    columns = db["Bag_Backpack_Columns"]
    splitBackpack = db["Bag_Toogle_Backpack_Split"]
end

-- Calculate the width and height for the CombinedBagContainerFrame
---comment
---@param itemSize integer
---@return integer width
---@return integer height
function BagUtils:CalcFrameSize(itemSize)
    local width = columns * (itemSize + itemPadding) - itemPadding + (2 * borderPadding)

    -- calc the amount of rows
    local rows = 0
    if splitBackpack then
        for bagId = 0, 4 do
            local slots = BagCache:GetBagSize(bagId)
            rows = rows + math.ceil(slots / columns)
        end
    else
        local slots = BagCache:GetFullBagSize()
        rows = math.ceil(slots / columns)
    end

    local height = rows * (itemSize + itemPadding) - itemPadding + 90

    -- Add an Height Offset if the Player trackes extra Currencies
    if C_CurrencyInfo.GetBackpackCurrencyInfo(1) then
        height = height + 20
    end

    return width, height
end

-- Add the ItemLevel to the itemButton
function BagUtils:AddItemLevelComponent(itemButton)
    -- add String Component if it isn't present
    if not itemButton.BagItemLevel then
        local text = itemButton:CreateFontString(nil, "OVERLAY", "GameFontNormalOutline")
        text:SetPoint("BOTTOMRIGHT", itemButton, "BOTTOMRIGHT", 0, 0)
        text:SetTextColor(1, 1, 1, 1)
        text:SetScale(1.25)

        itemButton.BagItemLevel = text
    end
end

-- updates the ItemLevelComponent if the item is equipable
function BagUtils:UpdateItemLevel(itemButton)
    local text = itemButton.BagItemLevel
    local bagId = itemButton.bagID
    local slot = itemButton:GetID()
    local itemInfo = BagCache:GetItemInfo(bagId, slot)

    if itemInfo and BagCache:IsEquipable(itemInfo.itemID) then
        local itemLevel = BagCache:GetItemLevel(bagId, slot)
        text:SetText(itemLevel)
        itemButton.BagItemLevel:Show()
    else
        itemButton.BagItemLevel:Hide()
    end
end

-- collect the itemButtons in the correct order
function BagUtils:CollectButtons(container)
    local buttons = {[0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {}}
    for _, itemButton in container:EnumerateValidItems() do
        buttons[itemButton.bagID][itemButton:GetID()] = itemButton
    end

    return buttons
end

-- update the Bag Layout based in the Settings
function BagUtils:UpdateLayout(container)
    local buttons = BagUtils:CollectButtons(container)
    local yPos = -60
    local xPos = borderPadding
    local offset = itemPadding + buttons[0][1]:GetSize()

    -- only to track the current columns
    local counter = 0

    for bagId = 0, 4 do
        local maxSlots = BagCache:GetBagSize(bagId)
        local bagItems = buttons[bagId]
        for slot = 1, maxSlots do
            local itemButton = bagItems[slot]
            if itemButton then
                itemButton:ClearAllPoints()
                itemButton:SetPoint("TOPLEFT", container, "TOPLEFT", xPos, yPos)

                counter = counter + 1
                if counter < columns then
                    xPos = xPos + offset
                else
                    xPos = borderPadding
                    yPos = yPos - offset
                    counter = 0
                end
            end
        end

        -- start a new row when backpack sould be splitted and reset counter
        if counter ~= 0 and splitBackpack then
            yPos = yPos - offset
            xPos = borderPadding
            counter = 0
        end
    end
end

function BagUtils:UpdateFrameSize(container)
    if not container then return end
    local buttons = BagUtils:CollectButtons(container)
    local size = buttons[0][1]:GetSize()
    local width, height = BagUtils:CalcFrameSize(size)

    container:SetSize(width, height)
end