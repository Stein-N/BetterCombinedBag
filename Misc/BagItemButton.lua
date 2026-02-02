local name, addon = ...
BetterCombinedBagsItemButtonMixin = {}

-- Initialize the ItemButton based on bagId, slot and bankType.
-- Background Texture is based on bankType can be normal or warbank texture
function BetterCombinedBagsItemButtonMixin:Init(bagId, slot, bankType)
    self:SetBagID(bagId)
    self:SetID(slot)

    -- Apply Scripts
    self:SetScript("OnShow", self.OnShow)
    self:SetScript("OnHide", self.OnHide)
    self:SetScript("OnEvent", self.OnEvent)

    -- Add ItemLevelComponent
    addon.AddItemLevelComponent(self)

    -- Add Background for IconTexture
    self:SetBackgroundTexture(bankType)

    -- Initial Update to apply correct icon/count/item level
    self:Update()
end

-- Register Events when the Button is shown
function BetterCombinedBagsItemButtonMixin:OnShow()
    self:RegisterEvent("ITEM_LOCK_CHANGED")
    self:RegisterEvent("BAG_UPDATE_DELAYED")
    self:RegisterEvent("INVENTORY_SEARCH_UPDATE")

    -- Refresh Button Data if the Bag/Bank is opened
    self:Update()
end

-- Unregister all Events when closing the Bag/Bank
function BetterCombinedBagsItemButtonMixin:OnHide()
    self:UnregisterAllEvents()
end

-- Add all functionality for the different Events
function BetterCombinedBagsItemButtonMixin:OnEvent(event, ...)
    if event == "BAG_UPDATE_DELAYED" then
        self:Update()
    end

    if event == "ITEM_LOCK_CHANGED" then
        local bagId, slot = ...
        if bagId == self:GetBagID() and slot == self:GetID() then
            local info = addon.GetItemInfo(self:GetBagID(), self:GetID())
            SetItemButtonDesaturated(self, info and info.isLocked)
        end
    end

    if event == "INVENTORY_SEARCH_UPDATE" then
        self:UpdateSearchOverlay()
    end
end

-- Set the Background texture based on bankType
-- Code is basically Blizzards code
-- what a fuckup that the Warbank texture isn't the same size as the normal texture
function BetterCombinedBagsItemButtonMixin:SetBackgroundTexture(bankType)
    local bg = self:CreateTexture(nil, "BACKGROUND")

    if bankType == Enum.BankType.Account then
        bg:SetPoint("TOPLEFT", -6, 5);
        bg:SetPoint("BOTTOMRIGHT", 6, -5);
        bg:SetAtlas("warband-bank-slot", TextureKitConstants.IgnoreAtlasSize)
    else
        bg:SetAllPoints(self)
        bg:SetAtlas("bags-item-slot64", TextureKitConstants.IgnoreAtlasSize)
    end

    self.Background = bg
end

function BetterCombinedBagsItemButtonMixin:RemoveItemIconTexture()
    local icon = self.Icon or self.icon
    if icon ~= nil then
        icon:SetTexture(nil)
    end
end

-- General Update functionality for the Button
-- Updates the Icon, Count, Item Level, Quality border and new item glow animation
function BetterCombinedBagsItemButtonMixin:Update()
    local info = addon.GetItemInfo(self:GetBagID(), self:GetID())

    if info ~= nil then
        self:SetItemButtonTexture(info.iconFileID)
        self:SetItemButtonCount(info.stackCount)
        self:SetItemButtonQuality(info.quality, info.itemID)
        self:UpdateNewItem(info.quality)

        SetItemCraftingQualityOverlay(self, info.itemID)

        self:UpdateItemLevel(info)
    else
        self:RemoveItemIconTexture()
        self:SetItemButtonCount(nil)
        self:SetItemButtonQuality(0, 0)
        self:UpdateNewItem()

        ClearItemCraftingQualityOverlay(self)

        self:UpdateItemLevel()
    end
end

-- Shows the search overlay if the item name fits the search box input
function BetterCombinedBagsItemButtonMixin:UpdateSearchOverlay()
    local box = _G["BagItemSearchBox"]
    if box == nil or box:GetText() == "" then
        self.searchOverlay:Hide()
        return
    end

    local search = string.lower(box:GetText())
    local info = addon.GetItemInfo(btn.bagID, btn:GetID())

    if info ~= nil then
        local itemName = string.lower(info.itemName)
        if string.find(itemName, search) then
            btn.searchOverlay:Hide()
        else
            btn.searchOverlay:Show()
        end
    end
end

-- Updates the ItemLevelComponent based on the item link
function BetterCombinedBagsItemButtonMixin:UpdateItemLevel(info)
    if info ~= nil and addon.CanShowItemLevel(self:GetBagID()) then
        local level = addon.GetItemLevelFromItemLink(info.hyperlink)
        addon.UpdateItemLevelComponent(self, level, info.quality)
    elseif self.ItemLevelComponent ~= nil then
        self.ItemLevelComponent:Hide()
    end
end

-- General Function to create a new ItemButton
function addon.GenerateTestBagButton(bagId, slot, parent, bankType)
    local btn = CreateFrame("ItemButton", name.."Bag"..bagId.."Slot"..slot, parent or UIParent, "ContainerFrameItemButtonTemplate")
    Mixin(btn, BetterCombinedBagsItemButtonMixin)

    btn:Init(bagId, slot, bankType or 0)

    return btn
end