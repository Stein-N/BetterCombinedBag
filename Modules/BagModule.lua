local _, addon = ...
BagModule = {}

function BagModule:LoadSettings()
    self.borderPadding = BCB_Settings.bagBorderPadding + 7
    self.itemPadding = BCB_Settings.bagItemPadding + 4
    self.splitBags = BCB_Settings.bagSplitBags
    self.reagentsPadding = BCB_Settings.bagReagentsPadding
    self.addReagentsBag = BCB_Settings.addReagentsBag
    self:SetColumns()

    self.counter = 0
    self.xPos = self.borderPadding
    self.yPos = -60

    self.yStep = self.itemPadding + self.btnSize
    self.xStep = self.yStep
end

-- Cache the Retail Button to reduce for loops
-- Will be Cached again when Player changes Equipment
function BagModule:CacheRetailButton(container)
    if self.itemButtons == nil then
        self.itemButtons = { [0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {} }
    end

    for _, btn in container:EnumerateValidItems() do
        if btn ~= nil then
            -- Save button Size
            if self.btnSize == nil then
                self.btnSize = btn:GetWidth()
            end

            -- Add ItemLevelComponent
            addon.AddItemLevelComponent(btn)

            -- save button in cache
            self.itemButtons[btn.bagID][btn:GetID()] = btn
        end
    end
end

-- Gets the max Columns based on the biggest Bag.
-- If the biggest bag is smaller then the Columns setting(max 38).
-- Only applies when Split Bags Setting is set to true.
function BagModule:SetColumns()
    local slots = BCB_Settings.bagColumns
    local maxSlots = 0

    for bagId = 0, 5 do
        if bagId < 5 or self.addReagentsBag then
            local bagSlots = C_Container.GetContainerNumSlots(bagId)
            if slots > maxSlots then maxSlots = bagSlots end
        end
    end
    print(maxSlots)

    if self.splitBags == true and maxSlots < slots then
        self.columns = maxSlots
    else
        self.columns = slots
    end

    print(self.columns)
end

-- Count all Slots for the Base ItemButtons of the Combined Bag
function BagModule:GetFullSize()
    local slots = 0
    for i = 0, 4 do
        slots = slots + C_Container.GetContainerNumSlots(i)
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
            rows = rows + math.ceil(C_Container.GetContainerNumSlots(i) / self.columns)
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

    if self.addReagentsBag == true then
        extraHeight = extraHeight + self.reagentsPadding
    end

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

-- Sets the point for the given button
function BagModule:SetButtonPoint(btn)
    if btn ~= nil then
        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", self.xPos, self.yPos)
    end
end

-- Calculates the next button position
function BagModule:NextButtonPosition()
    self.counter = self.counter + 1
    if self.counter < self.columns then
        self.xPos = self.xPos + self.xStep
    else
        self.xPos = self.borderPadding
        self.yPos = self.yPos - self.yStep
        self.counter = 0
    end
end

-- Resets the position to the left when the counter is not 0
function BagModule:FirstReagentsButtonPosition()
    if self.addReagentsBag and self.counter ~= 0 then
        self.yPos = self.yPos - self.yStep - self.reagentsPadding
        self.xPos = self.borderPadding
        self.counter = 0
    else
        self.yPos = self.yPos - self.reagentsPadding
    end
end

-- Updates the Position for the cached retail buttons
function BagModule:UpdateRetailButtons()
    for i = 0, 4 do
        local buttons = self.itemButtons[i]
        for j = 1, C_Container.GetContainerNumSlots(i) do
            local button = buttons[j]
            self:SetButtonPoint(button)
            self:NextButtonPosition()
        end

        if self.counter ~= 0 and self.splitBags then
            self.xPos = self.borderPadding
            self.yPos = self.yPos - self.yStep
            self.counter = 0
        end
    end
end

-- Updates the position for the custom Reagents Buttons
function BagModule:UpdateReagentsButtons()
    self:FirstReagentsButtonPosition()
    for i = 1, C_Container.GetContainerNumSlots(5) do
        local button = addon.CustomBagButtons[5][i]
        if self.addReagentsBag then
            button:SetParent(ContainerFrameCombinedBags) -- TODO: remove when BagButtons was reworked
            self:SetButtonPoint(button)
            self:NextButtonPosition()
            button:Show()
        else
            button:Hide()
        end
    end
end

function BagModule:HideReagentsBag(frame)
    if frame ~= nil and self.addReagentsBag then
        frame:ClearAllPoints()
    end
end

-- ############################################################# --
--       Secure Hook for the Combined and Reagents Frame         --
-- ############################################################# --

hooksecurefunc(ContainerFrame6, "SetPoint", function(self)
    BagModule:HideReagentsBag(self)
end)

hooksecurefunc(ContainerFrameCombinedBags, "UpdateItemLayout", function(self)
    BagModule:CacheRetailButton(self)
    BagModule:LoadSettings()

    BagModule:UpdateFrameSize(self)

    BagModule:UpdateRetailButtons()
    BagModule:UpdateReagentsButtons()
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