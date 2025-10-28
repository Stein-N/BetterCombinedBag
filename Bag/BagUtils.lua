BagUtils = {}

local columns = 0
local borderPadding = 0
local itemPadding = 0
local splitBackpack = false
local addReagentsBag = false
local reagBagMargin = 10

local _buttons = {[0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {}}
local _reagButtons = {}

function BagUtils:UpdateSettings()
    local db = BetterCombinedBagDB
    borderPadding = db["Bag_Border_Padding"]
    itemPadding = db["Bag_Item_Padding"]
    columns = db["Bag_Backpack_Columns"]
    splitBackpack = db["Bag_Toogle_Backpack_Split"]
    addReagentsBag = db["Bag_Toogle_Reagents_Bag"]
end

function BagUtils:CreateReagItemButtons(container)
    if next(_reagButtons) == nil then
        local slots = BagCache:GetBagSize(5)
        for slot = 1, slots do
            local itemButton = CreateFrame("ItemButton", "BetterCombinedBagReagButton"..slot, container, "ContainerFrameItemButtonTemplate")
            itemButton:SetItemButtonTexture(4701874)
            itemButton:SetBagID(5)
            itemButton:SetID(slot)
            itemButton:ClearAllPoints()
            itemButton:UpdateNewItem()
            itemButton:Show()

            _reagButtons[slot] = itemButton
        end
    end
end

function BagUtils:UpdateReagItemButtons()
    for slot = 1, BagCache:GetBagSize(5) do
        local itemButton = _reagButtons[slot]
        if itemButton then
            local itemInfo = BagCache:GetItemInfo(itemButton.bagID, itemButton:GetID())
            local r, g, b = BagCache:GetItemQualityColor(itemButton.bagID, itemButton:GetID())
            itemButton.IconBorder:SetVertexColor(r, g, b)

            if itemInfo then
                itemButton:SetItemButtonTexture(itemInfo.iconFileID)
                itemButton:SetItemButtonCount(itemInfo.stackCount)
                itemButton.IconBorder:Show()
            else
                itemButton:SetItemButtonTexture(4701874)
                itemButton:SetItemButtonCount(nil)
                itemButton.IconBorder:Hide()
            end
        end
    end
end

-- Calculate the width and height for the CombinedBagContainerFrame
---@param itemSize integer
---@return integer width
---@return integer height
function BagUtils:CalcFrameSize(itemSize)
    local width = columns * (itemSize + itemPadding) - itemPadding + (2 * borderPadding)

    -- calc the amount of rows
    local rows = 0
    local reagSlots = BagCache:GetBagSize(5)
    if splitBackpack then
        for bagId = 0, 4 do
            local slots = BagCache:GetBagSize(bagId)
            rows = rows + math.ceil(slots / columns)
        end
    else
        local slots = BagCache:GetFullBagSize()
        rows = math.ceil(slots / columns)
    end

    if addReagentsBag then
        rows = rows + math.ceil(reagSlots / columns)
    end

    local height = rows * (itemSize + itemPadding) - itemPadding + 90

    -- Add an Height Offset if the Player trackes extra Currencies
    if C_CurrencyInfo.GetBackpackCurrencyInfo(1) then
        height = height + 20
    end

    if addReagentsBag then
        height = height + reagBagMargin
    end

    return width, height
end

-- Add the ItemLevel to the itemButton
---@param itemButton any
function BagUtils:AddItemLevelComponent(itemButton)
    local text = itemButton:CreateFontString(nil, "OVERLAY", "GameFontNormalOutline")
    text:SetPoint("BOTTOMRIGHT", itemButton, "BOTTOMRIGHT", 0, 0)
    text:SetTextColor(1, 1, 1, 1)
    text:SetScale(1.25)

    itemButton.BagItemLevel = text
end

-- Updates the ItemLevelComponent if the item is equipable
function BagUtils:UpdateItemLevel()
    for bagId = 0, 4 do
        local maxSlots = BagCache:GetBagSize(bagId)
        local bagItems = _buttons[bagId]
        for slot = 1, maxSlots do
            local itemButton = bagItems[slot]

            if not itemButton.BagItemLevel then
                BagUtils:AddItemLevelComponent(itemButton)
            end

            local text = itemButton.BagItemLevel
            local itemInfo = BagCache:GetItemInfo(bagId, slot)

            if itemInfo and BagCache:IsEquipable(itemInfo.itemID) then
                local itemLevel = BagCache:GetItemLevel(bagId, slot)
                text:SetText(itemLevel)
                itemButton.BagItemLevel:Show()
            else
                itemButton.BagItemLevel:Hide()
            end
        end
    end
end

-- collect ItemButtons in the correct order
---@param container any
function BagUtils:CollectButtons(container)
    for _, itemButton in container:EnumerateValidItems() do
        _buttons[itemButton.bagID][itemButton:GetID()] = itemButton
    end
end

-- update the Bag Layout based in the Settings
---@param container any
function BagUtils:UpdateLayout(container)
    local yPos = -60
    local xPos = borderPadding
    local offset = itemPadding + _buttons[0][1]:GetSize()

    -- only to track the current columns
    local counter = 0
    local bags
    if addReagentsBag then bags = 5
    else bags = 4 end

    for bagId = 0, bags do
        local maxSlots = BagCache:GetBagSize(bagId)
        local bagItems
        if bagId < 5 then bagItems = _buttons[bagId]
        else
            bagItems = _reagButtons
            yPos = yPos - reagBagMargin
            if counter ~= 0 then
                counter = 0
                yPos = yPos - offset
                xPos = borderPadding
            end
        end

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

-- Update the frame size based on the amount of bag slots
---@param self ContainerFrameCombinedBags
function BagUtils:UpdateFrameSize(container)
    if not container then return end
    local size = _buttons[0][1]:GetSize()
    local width, height = BagUtils:CalcFrameSize(size)

    container:SetSize(width, height)
end