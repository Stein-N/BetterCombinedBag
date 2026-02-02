local name, addon = ...

BetterCombinedTabButtonMixin = {}

local iconTexture = "interface/icons/ability_bossashvane_icon03"
local tabData = {
    IsPurchaseTab = false,
    ID = 99
}

function BetterCombinedTabButtonMixin:OnClick(btn)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
    btn:GetBankPanel():TriggerEvent(BankPanelMixin.Event.BankTabClicked, btn.tabData.ID)
end

function BetterCombinedTabButtonMixin:ShowTooltip()
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip_SetTitle(GameTooltip, "Everything", NORMAL_FONT_COLOR)
    GameTooltip:Show()
end

function addon.CreateEverythingTabButton()
    local tabBtn = CreateFrame("Button", name.."EverythingTabButton", BankFrame.BankPanel, "BankPanelTabTemplate")
    tabBtn:Init(tabData)
    Mixin(tabBtn, BetterCombinedTabButtonMixin)
    tabBtn.Icon:SetTexture(iconTexture)

    return tabBtn
end