local _, addon = ...

BankModule = {}

-- Loading the necessary settings, those get refreshed when a new tab is opened
function BankModule:LoadSettings()
    self.borderPadding = BCB_Settings.bankBorderPadding + 7
    self.itemPadding = BCB_Settings.bankItemPadding + 4
    self.tabButtons = {}
    self.btnSize = 37
end

-- Cache the tab buttons on the right side of the bank frame
-- Needed to place the everything tab button on top and still have the others in the correct order
function BankModule:CacheTabButtons(panel)
    for _, btn in ipairs({ panel:GetChildren() }) do
        if btn ~= nil and btn.IsPurchaseTab ~= nil then
            self.tabButtons[btn.tabData.ID] = btn
        end
    end
end

-- Calculate the width based on the columns
function BankModule:CalculateWidth(columns)
    return columns * (self.itemPadding + self.btnSize) - self.itemPadding + (2 * self.borderPadding)
end

-- Calculate the height based on the rows
function BankModule:CalculateHeight(rows)
    return rows * (self.btnSize + self.itemPadding) - self.itemPadding + 130
end

-- Resizes the BankFrame and the BankPanel to the given width and height
-- Also relocated the auto deposit frame to the bottom left side
function BankModule:ResizeBankFrame(panel, width, height)
    panel.AutoDepositFrame:ClearAllPoints()
    panel.AutoDepositFrame:SetPoint("BOTTOMLEFT", panel.NineSlice, "BOTTOMLEFT", -10, 10)

    BankFrame:SetSize(width, height)
    panel:SetSize(width, height)
end

-- Updates the ItemButton positions on the base frame to use lesser space
function BankModule:UpdateBaseLayout(panel)
    local x, y, counter = -self.borderPadding, 70, 0
    for btn in panel:EnumerateValidItems() do
        addon.AddItemLevelComponent(btn)

        btn:ClearAllPoints()
        btn:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", x, y)

        self:Update(panel:GetSelectedTabID(), btn:GetContainerSlotID(), btn)

        counter = counter + 1
        if counter < 14 then
            x = x - self.btnSize - self.itemPadding
        else
            x = -self.borderPadding
            y = y + self.btnSize + self.itemPadding
            counter = 0
        end
    end

    local width = self:CalculateWidth(14)
    local height = self:CalculateHeight(7)

    self:ResizeBankFrame(panel, width, height)
end

-- Updates the ItemButton position for the everything tab
function BankModule:UpdateEverythingTabLayout(panel, first, last)
    local x, y, counter = self.borderPadding, -60, 0
    local columns, rows = 33, 0

    for bagId = first, last do
        if C_Container.GetContainerNumSlots(bagId) ~= nil and self.tabButtons[bagId] ~= nil then
            local buttons = self.everythingButtons[bagId]
            rows = rows + 3

            for slot = 1, 98 do
                local btn = buttons[slot]
                btn:ClearAllPoints()
                btn:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y)
                btn:Show()

                counter = counter + 1
                if counter < columns then
                    x = x + self.btnSize + self.itemPadding
                else
                    x = self.borderPadding
                    y = y - self.btnSize - self.itemPadding
                    counter = 0
                end
            end

            counter = 0
            x = self.borderPadding
            y = y - self.btnSize - self.itemPadding
        end
    end

    local width = self:CalculateWidth(columns)
    local height = self:CalculateHeight(rows)
    self:ResizeBankFrame(panel, width, height)
end

-- Updates the position of the tab buttons on the right side of the bank frame
-- puts the everything tab button on top and the others down below in the correct order
function BankModule:UpdateTabButtonPosition(panel, first, last)
    local x, y = 3, -30

    self.everythingTabButton:ClearAllPoints()
    self.everythingTabButton:SetPoint("TOPLEFT", panel, "TOPRIGHT", x, y)
    y = y - 47

    for i = first, last do
        local btn = self.tabButtons[i]
        if btn ~= nil then
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", panel, "TOPRIGHT", x, y)
            y = y - 47
        end
    end
end

-- Updates the Item Level Component for the Item Level Component for the base Item Buttons
-- is ignored when everything tab is opened
function BankModule:Update(tabId, slot, btn)
    local info = addon.GetItemInfo(tabId, slot)

    if info ~= nil and addon.CanShowItemLevel(tabId) then
        local level = addon.GetItemLevelFromItemLink(info.hyperlink)
        addon.UpdateItemLevelComponent(btn, level, info.quality)
    else
        btn.ItemLevelComponent:Hide()
    end
end

-- Hides the Everything tab buttons when another tab is opened
function BankModule:HideCustomButtons()
    for i = 6, 16 do
        local buttons = self.everythingButtons[i]
        for j = 1, 98 do
            buttons[j]:Hide()
        end
    end
end

-- initializes the BankModule and generates the item buttons for the everything tab
function BankModule:Init()
    self:LoadSettings()

    self.everythingTabButton = addon.CreateEverythingTabButton()
    self.everythingButtons = {}

    for i = 6, 16 do
        local bankType = i <= 11 and 0 or 2
        self.everythingButtons[i] = {}
        for j = 1, 98 do
            self.everythingButtons[i][j] = addon.GenerateTestBagButton(i, j, BankFrame.BankPanel, bankType)
        end
    end
end

-- add the module to get loaded correctly
addon.AddModule(BankModule)

------------------------------------------
hooksecurefunc(BankFrame.BankPanel, "GenerateItemSlotsForSelectedTab", function(panel)
    BankModule:LoadSettings()
    BankModule:CacheTabButtons(panel)

    local tabId = panel:GetSelectedTabID()

    local config = {
        [0] = { first = 6,  last = 11 },
        [2] = { first = 12, last = 16 }
    }

    local settings = config[panel.bankType]

    if settings ~= nil then
        if tabId == 99 then
            BankModule:UpdateEverythingTabLayout(panel, settings.first, settings.last)
            BankModule:UpdateTabButtonPosition(panel, settings.first, settings.last)
        else
            BankModule:HideCustomButtons()
            BankModule:UpdateBaseLayout(panel)
            BankModule:UpdateTabButtonPosition(panel, settings.first, settings.last)
        end
    end
end)

hooksecurefunc(BankFrame.BankPanel, "MarkDirty", function(panel)
    addon.CacheAllItems()

    if panel:GetSelectedTabID() ~= 99 then
        for btn in panel:EnumerateValidItems() do
            BankModule:Update(panel:GetSelectedTabID(), btn:GetContainerSlotID(), btn)
        end
    end
end)

hooksecurefunc(BankFrame.BankPanel, "ShowPurchasePrompt", function(self)
    BankModule:HideCustomButtons()
end)