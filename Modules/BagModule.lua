local _, addon = ...
BagModule = {}

local borderPad, itemPad, bagPad, columns, splitBags, reagPad, addReag
local cButton = { [0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {} }

local function UpdateSettings()
    borderPad = BCB_Settings.bagBorderPadding + 7
    itemPad = BCB_Settings.bagItemPadding + 4
    bagPad = BCB_Settings.bagBagPadding
    columns = BCB_Settings.bagColumns
    splitBags = BCB_Settings.bagSplitBags
    reagPad = BCB_Settings.bagReagentsPadding
    addReag = BCB_Settings.addReagentsBag
end

local function FullBagSize()
    fullBagSize = 0
    for i = 0, 4 do
        fullBagSize = fullBagSize + C_Container.GetContainerNumSlots(i)
    end
    return fullBagSize
end

local function CollectButtons(container)
    for _, btn in container:EnumerateValidItems() do
        cButton[btn.bagID][btn:GetID()] = btn
    end
end

local function GetMaxColumns(col, addReagents)
    local max = 0
    for i = 0, 5 do
        if i < 5 or addReagents then
            local slots = C_Container.GetContainerNumSlots(i)
            if max < slots then max = slots end
        end
    end

    return max < col and max or col
end

function BagModule.UpdateFrameSize(container)
    if not container then return end

    columns = GetMaxColumns(columns, addReag)
    local width = columns * (36 + itemPad) - itemPad + (2 * borderPad)

    local rows, height = 0, 0
    if splitBags then
        for i = 0, 4 do
            rows = rows + math.ceil(C_Container.GetContainerNumSlots(i) / columns)
            height = height + bagPad
        end
    else
       rows = math.ceil(FullBagSize() / columns)
    end

    if addReag then
        rows = rows + math.ceil(C_Container.GetContainerNumSlots(5) / columns)
        height = height + reagPad
    end

    height = height + rows * (36 + itemPad) - itemPad + 90

    if C_CurrencyInfo.GetBackpackCurrencyInfo(1) then
        height = height + 20
    end

    container:SetSize(width, height)
end

function BagModule.UpdateItemLayout(container)

    local x, y, counter = borderPad, -60, 0
    local step = 36 + itemPad

    for i = 0, 4 do
        for _, btn in ipairs(cButton[i]) do
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", container, "TOPLEFT", x, y)

            counter = counter + 1
            if counter < columns then
                x = x + step
            else
                x = borderPad
                y = y - step
                counter = 0
            end
        end

        if counter ~= 0 and splitBags then
            x = borderPad
            y = y - step - bagPad
            counter = 0
        elseif splitBags then
            y = y - bagPad
        end
    end

    if addReag then
        y = y - reagPad
        for _, btn in ipairs(addon.CustomBagButtons[5]) do
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", container, "TOPLEFT", x, y)
            btn:Show()

            counter = counter + 1
            if counter < columns then
                x = x + step
            else
                x = borderPad
                y = y - step
                counter = 0
            end
        end
    else
        for _, btn in ipairs(addon.CustomBagButtons[5]) do
            btn:Hide()
        end
    end
end

------------------------------------
---
hooksecurefunc(ContainerFrameCombinedBags, "UpdateItemLayout", function(self)
    UpdateSettings()
    CollectButtons(self)
    BagModule.UpdateFrameSize(self)
    BagModule.UpdateItemLayout(self)
end)

hooksecurefunc(ContainerFrameCombinedBags, "Update", function(self)
    for _, value in self:EnumerateValidItems() do
        local info = addon.ItemInfoCache[value.bagID][value:GetID()]
        BagButtons.UpdateItemLevel(value, info)
    end
end)

hooksecurefunc(ContainerFrame6, "SetPoint", function(self)
    if BCB_Settings.addReagentsBag then
        self:ClearAllPoints()
    end
end)

hooksecurefunc(ContainerFrameCombinedBags, "SetSearchBoxPoint", function(self)
    local box = _G["BagItemSearchBox"]

    if box then
        local cWidth, _ = self:GetSize()
        local bWidth, _ = box:GetSize()

        local x = (cWidth / 2) - (bWidth / 2)

        box:ClearAllPoints()
        box:SetPoint("TOPLEFT", self, "TOPLEFT", x, -35)
    end
end)