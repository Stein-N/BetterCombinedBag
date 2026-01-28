local _, addon = ...
BagModule = {}

function BagModule:LoadSettings()
    self.borderPadding = BCB_Settings.bagBorderPadding + 7
    self.itemPadding = BCB_Settings.bagItemPadding + 4
    self.splitBags = BCB_Settings.bagSplitBags
    self.reagentsPadding = BCB_Settings.bagReagentsPadding
    self.addReagentsBag = BCB_Settings.addReagentsBag

    self.btnSize = 0
    self.counter = 0
    self.xPos = self.borderPadding
    self.yPos = -60
end

-- Cache the Retail Button to reduce for loops
-- Will be Cached again when Player changes Equipment
function BagModule:CacheRetailButton(container)
    if self.itemButtons == nil then
        self.itemButtons = { [0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {} }
    end

    -- after opening the bag 10 times the buttons get cached again
    if self.timesOpened ~= nil and self.timesOpened <= 10 then
        self.timesOpened = self.timesOpened + 1
        return
    end

    self.timesOpened = 0
    for _, btn in container:EnumerateValidItems() do
        if btn ~= nil then
            if self.btnSize == 0 then self.btnSize = btn:GetWidth() end
            self.itemButtons[btn.bagID][btn:GetID()] = btn
        end
    end
end

-- Sets the max Columns based on the biggest Bag.
-- If the biggest bag is smaller then the Columns setting(max 38).
-- Only applies when Split Bags Setting is set to true.
function BagModule:SetColumns()
    if self.splitBags == true then
        for bagId = 0, 5 do
            if bagId < 5 or self.addReagentsBag then
                local slots = #self.itemButtons[bagId]
                if slots < BCB_Settings.columns then
                    self.columns = slots
                end
            end
        end
    else
        self.columns = BCB_Settings.columns
    end
end

-- Count all Slots for the Base ItemButtons of the Combined Bag
function BagModule:GetFullSize()
    local slots = 0
    for i = 0, 4 do
        slots = slots + #self.itemButton[i]
    end

    return slots
end

-- Calculate the needed Rows for all ItemButtons
function BagModule:GetRows()
    local rows = 0
    -- Base ItemButtons
    if self.splitBags == false then
        rows = math.ceil(self:GetFullSize() / self.columns)
    else
        for i = 0, 4 do
            rows = rows + math.ceil(#self.itemButtons[i] / self.columns)
        end
    end

    -- Extra Buttons for Reagents Bag
    if self.addReagentsBag == true then
        rows = rows + math.ceil(C_Container.GetContainerNumSlots(5) / self.columns)
    end

    return rows
end

-- Calculate the new width for the Combined Bag Frame
function BagModule:CalculateWidth()
    local itemRowWidth = self.columns * (self.btnSize + self.itemPadding)
    local paddingWidth =  (2 * self.borderPadding) - self.itemPadding
    return itemRowWidth + paddingWidth
end

-- Calculate the new width for the Combined Bag Frame
function BagModule:CalculateHeight()
    local neededRows = self:GetRows()
    local itemColumnHeight = neededRows * (self.btnSize + self.itemPadding)
    local extraHeight = 90 - self.itemPadding

    -- Checks if the player tracks extra currency
    if C_CurrencyInfo.GetBackpackCurrencyInfo(1) ~= nil then
        extraHeight = extraHeight + 20
    end

    return itemColumnHeight + extraHeight
end

-- Update the Size of Combined Bag Frame
function BagModule:UpdateFrameSize(container)
    local width = self:CalculateWidth()
    local height = self:CalculateHeight()

    container:SetSize(width, height)
end


























local borderPad, itemPad, columns, splitBags, reagPad, addReag, btnSize
local cButton = { [0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {} }

local function UpdateSettings()
    borderPad = BCB_Settings.bagBorderPadding + 7
    itemPad = BCB_Settings.bagItemPadding + 4
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
    local width = columns * (btnSize + itemPad) - itemPad + (2 * borderPad)

    local rows, height = 0, 0
    if splitBags then
        for i = 0, 4 do
            rows = rows + math.ceil(C_Container.GetContainerNumSlots(i) / columns)
            height = height
        end
    else
       rows = math.ceil(FullBagSize() / columns)
    end

    if addReag then
        rows = rows + math.ceil(C_Container.GetContainerNumSlots(5) / columns)
        height = height + reagPad
    end

    height = height + rows * (btnSize + itemPad) - itemPad + 90

    if C_CurrencyInfo.GetBackpackCurrencyInfo(1) then
        height = height + 20
    end

    container:SetSize(width, height)
end

function BagModule.UpdateItemLayout(container)
    local x, y, counter = borderPad, -60, 0
    local step = btnSize + itemPad

    function UpdateCounter()
        counter = counter + 1
        if counter < columns then
            x = x + step
        else
            x = borderPad
            y = y - step
            counter = 0
        end
    end

    --- ######################### ---
    --- Adding normal Bag Buttons ---
    --- ######################### ---
    for i = 0, 4 do
        if C_Container.GetContainerNumSlots(i) ~= 0 then
            for _, btn in ipairs(cButton[i]) do
                btn:ClearAllPoints()
                btn:SetPoint("TOPLEFT", container, "TOPLEFT", x, y)
                UpdateCounter()
            end

            if counter ~= 0 and splitBags then
                x = borderPad
                y = y - step - bagPad
                counter = 0
            elseif splitBags then
                y = y - bagPad
            end
        end
    end

    --- ########################### ---
    --- Adding reagents Bag Buttons ---
    --- ########################### ---
    if addReag and counter ~= 0 then
        y = y - reagPad - step
        counter = 0
        x = borderPad
    else
        y = y - reagPad
    end

    for i = 1, C_Container.GetContainerNumSlots(Enum.BagIndex.ReagentBag) do
        local btn = addon.CustomBagButtons[Enum.BagIndex.ReagentBag][i]
        btn:ClearAllPoints()
        btn:SetParent(container)
        btn:SetPoint("TOPLEFT", container, "TOPLEFT", x, y)

        if addReag == true then
            btn:Show()
            UpdateCounter()
        else
            btn:Hide()
        end
    end
end

-----------------------------------

hooksecurefunc(ContainerFrame6, "SetPoint", function(self)
    if addReag == false then return end

    self:ClearAllPoints()
end)

hooksecurefunc(ContainerFrameCombinedBags, "UpdateItemLayout", function(self)
    BagModule:LoadSettings()
    BagModule:CacheRetailButton(self)

    BagModule:UpdateFrameSize(self)

    -- ################################# --
    -- \/           Old Code          \/ --

    if self.Items then
        for _, item in ipairs(self.Items) do
            if btnSize == nil then btnSize = item:GetWidth() end
            cButton[item.bagID][item:GetID()] = item
        end
    end

    UpdateSettings()
    --BagModule.UpdateFrameSize(self)
    BagModule.UpdateItemLayout(self)
end)

hooksecurefunc(ContainerFrameCombinedBags, "Update", function(self)
    for _, btn in self:EnumerateValidItems() do
        local info = addon.GetItemInfo(btn.bagID, btn:GetID())
        BagButtons.UpdateItemLevel(btn, info)
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