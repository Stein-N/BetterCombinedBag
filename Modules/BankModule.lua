local _, addon = ...

local borderPad, itemPad =  7, 4
local btnSize = nil

local tabButton = CreateFrame("Button", "TestButton", BankFrame.BankPanel, "BankPanelTabTemplate")
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

local function UpdateBaseLayout(panel)
    local x, y, counter = -borderPad, 70, 0
    for btn in panel:EnumerateValidItems() do
        if btnSize == nil then btnSize = btn:GetWidth() end

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

local function UpdateEverythingTab(panel, firstBag, lastBag)
    local x, y, counter = borderPad, -60, 0
    local columns = 33
    local rows = 0

    for bagId = firstBag, lastBag do
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
    addon.CacheItemInfos()

    local tabId = self:GetSelectedTabID()
    local bankType = self.bankType

    borderPad = BCB_Settings.bankBorderPadding + 7
    itemPad = BCB_Settings.bankItemPadding + 4

    if tabId ~= 99 then
        UpdateBaseLayout(self)
        HideCustomButtons()
    end

    if tabId == 99 then
        if bankType == 0 then
            UpdateEverythingTab(self, 6, 11)
        elseif bankType == 2 then
            UpdateEverythingTab(self, 12, 16)
        end
    end
end)

hooksecurefunc(BankFrame.BankPanel, "ShowPurchasePrompt", HideCustomButtons)

hooksecurefunc(BankFrame, "Show", function(self)
    tabButton:SetPoint("LEFT", self.BankPanel, "RIGHT", 2, -175)
    tabButton:Show()
end)