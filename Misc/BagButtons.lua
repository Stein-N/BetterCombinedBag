local name, addon = ...

-- TODO: Needs rewrite or cleanup
addon.CustomBagButtons = {}

BagButtons = {}
local handler = {}

function addon.GenerateReagentsButtons()
    local bagId = Enum.BagIndex.ReagentBag

    if addon.CustomBagButtons[bagId] == nil then
        addon.CustomBagButtons[bagId] = {}
    end

    for i = 1, 50 do
        local btn = addon.GenerateBagButton(bagId, i)
        addon.CustomBagButtons[bagId][i] = btn
    end
end

function addon.GenerateBankButtons()
    for bagId = 6, 17 do
        if addon.CustomBagButtons[bagId] == nil then
            addon.CustomBagButtons[bagId] = {}
        end

        for slot = 1, 98 do
            local btn = addon.GenerateBagButton(bagId, slot)
            addon.CustomBagButtons[bagId][slot] = btn
        end
    end
end

function addon.GenerateBagButton(bagId, slot, parent)
    local btn = CreateFrame("ItemButton", name..bagId.."Slot"..slot, parent or UIParent, "ContainerFrameItemButtonTemplate")
    btn:SetBagID(bagId)
    btn:SetID(slot)
    btn:UpdateNewItem()

    addon.AddItemLevelComponent(btn)

    btn:HookScript("OnShow", function(self)
        self:RegisterEvent("ITEM_LOCK_CHANGED")
        self:RegisterEvent("BAG_UPDATE_DELAYED")
        self:RegisterEvent("INVENTORY_SEARCH_UPDATE")

        self.searchOverlay:Hide()

        handler.BAG_UPDATE_DELAYED(self)
    end)

    btn:HookScript("OnHide", function(self)
        self:UnregisterEvent("ITEM_LOCK_CHANGED")
        self:UnregisterEvent("BAG_UPDATE_DELAYED")
        self:UnregisterEvent("INVENTORY_SEARCH_UPDATE")
    end)

    btn:SetScript("OnEvent", function(self, event, ...)
        local func = handler[event]
        if func then func(self, ...) end
    end)

    return btn
end

function BagButtons.UpdateIconAndCount(btn, info)
    if info ~= nil then
        btn:SetItemButtonTexture(info.iconFileID)
        btn:SetItemButtonCount(info.stackCount)
        btn:UpdateNewItem(info.quality)
    else
        btn:SetItemButtonTexture(4701874)
        btn:SetItemButtonCount(nil)
        btn:UpdateNewItem()
    end
end

function BagButtons.UpdateIconBorder(btn, info)
    if info ~= nil then
        btn:SetItemButtonQuality(info.quality, info.itemID)
    else
        btn:SetItemButtonQuality(0, 0)
    end
end

function BagButtons.UpdateProfessionQuality(btn, info)
    if info ~= nil then
        SetItemCraftingQualityOverlay(btn, info.itemID)
    else
        ClearItemCraftingQualityOverlay(btn)
    end
end

function BagButtons.UpdateItemLevel(btn, info)
    if not btn.ItemLevelComponent then
        addon.AddItemLevelComponent(btn)
    end

    if info ~= nil and addon.CanShowItemLevel(btn.bagID) then
        local level = addon.GetItemLevelFromItemLink(info.hyperlink)
        addon.UpdateItemLevelComponent(btn, level, info.quality)
    else
        btn.ItemLevelComponent:Hide()
    end
end

function handler.BAG_UPDATE_DELAYED(btn)
    local info = addon.GetItemInfo(btn.bagID, btn:GetID())

    BagButtons.UpdateIconAndCount(btn, info)
    BagButtons.UpdateIconBorder(btn, info)
    BagButtons.UpdateProfessionQuality(btn, info)
    BagButtons.UpdateItemLevel(btn, info)
end

function handler.ITEM_LOCK_CHANGED(btn, bagId, slot)
    if bagId ~= nil and slot ~= nil then
        local info = addon.GetItemInfo(bagId, slot)
        if info ~= nil and bagId == btn.bagID and slot == btn:GetID() then
            SetItemButtonDesaturated(btn, info.isLocked)
        end
    end
end

function handler.INVENTORY_SEARCH_UPDATE(btn)
    local box = _G["BagItemSearchBox"]
    if not box then return end

    local s = string.lower(box:GetText())

    local info = addon.GetItemInfo(btn.bagID, btn:GetID())

    if info ~= nil then
        local itemName = string.lower(info.itemName)
        if string.find(itemName, s) then
            btn.searchOverlay:Hide()
        else
            btn.searchOverlay:Show()
        end
    end
end