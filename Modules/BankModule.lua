local _, addon = ...

-- TODO: Need a complete rewrite

local borderPad, itemPad =  7, 4
local btnSize = nil

local tabButtons = {}

local tabButton = CreateFrame("Button", "BetterCombinedBagEverythingTabButton", BankFrame.BankPanel, "BankPanelTabTemplate")
tabButton:Init({ IsPurchaseTab = false, ID = 99 })
tabButton.Icon:SetTexture("interface/icons/ability_bossashvane_icon03")
tabButton:SetScript("OnClick", function(button)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION);
    tabButton:GetBankPanel():TriggerEvent(BankPanelMixin.Event.BankTabClicked, tabButton.tabData.ID);
end)
tabButton.ShowTooltip = function()
    GameTooltip:SetOwner(tabButton, "ANCHOR_RIGHT");
    GameTooltip_SetTitle(GameTooltip, "Everything", NORMAL_FONT_COLOR);
    GameTooltip:Show();
end

local function ResizeBankFrame(panel, width, height)
    panel.AutoDepositFrame:ClearAllPoints()
    panel.AutoDepositFrame:SetPoint("BOTTOMLEFT", panel.NineSlice, "BOTTOMLEFT", -10, 10)

    BankFrame:SetSize(width, height)
    panel:SetSize(width, height)
end

local function UpdateBankItemButton(tabId, slot, btn)
    local info = addon.GetItemInfo(tabId, slot)
    if info ~= nil and info.hyperlink ~= nil then
        local itemLevel = addon.GetItemLevelFromItemLink(info.hyperlink)
        local item = Item:CreateFromItemLink(info.hyperlink)

        if itemLevel ~= nil and item ~= nil then
            addon.UpdateItemLevelComponent(btn, itemLevel, item:GetItemQuality())
        else
            btn.ItemLevelComponent:Hide()
        end
    else
        btn.ItemLevelComponent:Hide()
    end
end

local function UpdateBaseLayout(panel)
    local x, y, counter = -borderPad, 70, 0
    for btn in panel:EnumerateValidItems() do
        if btnSize == nil then btnSize = btn:GetWidth() end
        addon.AddItemLevelComponent(btn)

        UpdateBankItemButton(panel:GetSelectedTabID(), btn:GetContainerSlotID(), btn)

        btn:ClearAllPoints()
        btn:SetParent(panel)
        btn:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", x, y)

        counter = counter + 1
        if counter < 14 then
            x = x - btn:GetWidth() - itemPad
        else
            x = -borderPad
            y = y + btn:GetHeight() + itemPad
            counter = 0
        end
    end

    local width = 14 * (btnSize + itemPad) - itemPad + (2 * borderPad)
    local height = 7 * (btnSize + itemPad) - itemPad + 130

    ResizeBankFrame(panel, width, height)
end

local function UpdateEverythingTab(panel, first, last)
    local x, y, counter = borderPad, -60, 0
    local columns = 33
    local rows = 0

    for bagId = first, last do
        if C_Container.GetContainerNumSlots(bagId) ~= 0 then
            local buttons = addon.CustomBagButtons[bagId]
            rows = rows + math.ceil(98 / columns)

            for slot = 1, 98 do
                local button = buttons[slot]
                button:ClearAllPoints()
                button:SetParent(panel)
                button:SetPoint("TOPLEFT", panel, "TOPLEFT", x, y)
                button:Show()

                counter = counter + 1
                if counter < columns then
                    x = x + btnSize + itemPad
                else
                    x = borderPad
                    y = y - btnSize - itemPad
                    counter = 0
                end
            end

            if counter ~= 0 then
                x = borderPad
                y = y - btnSize - itemPad
                counter = 0
            end
        end
    end

    local width = columns * (btnSize + itemPad) - itemPad + (2 * borderPad)
    local height = rows * (btnSize + itemPad) - itemPad + 130

    ResizeBankFrame(panel, width, height)
end

local function CollectTabButtons(panel)
    for _, btn in ipairs({ panel:GetChildren() }) do
        if btn.IsPurchaseTab ~= nil then
            tabButtons[btn.tabData.ID] = btn
        end
    end
end

local function UpdateTabButtonPosition(panel, first, last)
    if panel == nil then return end
    local x, y = 3, -30

    tabButton:ClearAllPoints()
    tabButton:SetPoint("TOPLEFT", panel, "TOPRIGHT", x, y)
    y = y - (tabButton:GetHeight() + 15)

    for i = first, last do
        local btn = tabButtons[i]
        if btn ~= nil then
            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", panel, "TOPRIGHT", x, y)
            y = y - (btn:GetHeight() + 15)
        end
    end
end

local function HideCustomButtons()
    for i = 6, 17 do
        local buttons = addon.CustomBagButtons[i]
        for j = 1, 98 do
            buttons[j]:Hide()
        end
    end
end

------------------------------------------
hooksecurefunc(BankFrame.BankPanel, "GenerateItemSlotsForSelectedTab", function(self)
    CollectTabButtons(self)

    local tabId = self:GetSelectedTabID()

    borderPad = BCB_Settings.bankBorderPadding + 7
    itemPad = BCB_Settings.bankItemPadding + 4

    local config = {
        [0] = { first = 6,  last = 11 },
        [2] = { first = 12, last = 16 }
    }

    local settings = config[self.bankType]

    if settings ~= nil then
        if tabId == 99 then
            UpdateEverythingTab(self, settings.first, settings.last)
            UpdateTabButtonPosition(self, settings.first, settings.last)
        else
            HideCustomButtons()
            UpdateBaseLayout(self)
            UpdateTabButtonPosition(self, settings.first, settings.last)
        end
    end
end)

hooksecurefunc(BankFrame.BankPanel, "MarkDirty", function(self)
    addon.CacheAllItems()
    for btn in self:EnumerateValidItems() do
        UpdateBankItemButton(self:GetSelectedTabID(), btn:GetContainerSlotID(), btn)
    end
end)

hooksecurefunc(BankFrame.BankPanel, "ShowPurchasePrompt", HideCustomButtons)