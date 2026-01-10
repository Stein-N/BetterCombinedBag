local name, addon = ...

addon.CustomBagButtons = {}

BagButtons = {}
local handler = {}

function addon.GenerateReagentsButtons()
    local bagId = Enum.BagIndex.ReagentBag

    if addon.CustomBagButtons[bagId] == nil then
        addon.CustomBagButtons[bagId] = {}
    end

    for i = 1, C_Container.GetContainerNumSlots(bagId) do
        local btn = addon.GenerateBagButton(bagId, i, ContainerFrameCombinedBags)
        addon.CustomBagButtons[bagId][i] = btn
    end
end

function addon.GenerateBankButtons()
    for bagId = 7, 17 do
        if addon.CustomBagButtons[bagId] == nil then
            addon.CustomBagButtons[bagId] = {}
        end

        for slot = 1, 98 do
            local btn addon.GenerateBagButton(bagId, slot, BankFrame)
            addon.CustomBagButtons[bagId][slot] = btn
        end
    end
end

function addon.GenerateBagButton(bagId, slot, parent)
    local btn = CreateFrame("ItemButton", name.."Bag"..bagId.."Slot"..slot, parent, "ContainerFrameItemButtonTemplate")
    btn:SetBagID(bagId)
    btn:SetID(slot)

    addon.AddItemLevelComponent(btn)

    local matOverlay = btn:CreateTexture(nil, "OVERLAY", nil, 7)
    matOverlay:SetSize(33, 28)
    matOverlay:SetPoint("TOPLEFT", btn, "TOPLEFT", -4, 3)

    btn.MaterialOverlay = matOverlay

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
    end
end

function BagButtons.UpdateIconBorder(btn, info)
    if info ~= nil then
        local r, g, b = C_Item.GetItemQualityColor(info.quality)
        btn.IconBorder:SetVertexColor(r, g, b)
        btn.IconBorder:Show()
    else
        btn.IconBorder:Hide()
    end
end

function BagButtons.UpdateProfessionQuality(btn, info)
    if info ~= nil then
        local tier = C_TradeSkillUI.GetItemReagentQualityByItemInfo(info.itemID)

        if tier ~= nil and tier > 0 then
            local atlas = addon.GetMaterialQualityAtlas(info.itemID, tier)
            btn.MaterialOverlay:SetAtlas(atlas)
            btn.MaterialOverlay:Show()
        else
            btn.MaterialOverlay:Hide()
        end
    else
        btn.MaterialOverlay:Hide()
    end
end

function BagButtons.UpdateItemLevel(btn, info)
    if not btn.ItemLevelComponent then
        addon.AddItemLevelComponent(btn)
    end

    if addon.CanShowItemLevel(btn.bagID) then
        local itemLoc = ItemLocation:CreateFromBagAndSlot(btn.bagID, btn:GetID())
        if C_Item.DoesItemExist(itemLoc) and C_Item.IsEquippableItem(info.itemID) then
            local level = C_Item.GetCurrentItemLevel(itemLoc)
            local quality = C_Item.GetItemQuality(itemLoc)

            addon.UpdateItemLevelComponent(btn, level, quality)
        else
            btn.ItemLevelComponent:Hide()
        end
    else
        btn.ItemLevelComponent:Hide()
    end
end

function handler.BAG_UPDATE_DELAYED(btn)
    local info = addon.ItemInfoCache[btn.bagID][btn:GetID()]

    BagButtons.UpdateIconAndCount(btn, info)
    BagButtons.UpdateIconBorder(btn, info)
    BagButtons.UpdateProfessionQuality(btn, info)
    BagButtons.UpdateItemLevel(btn, info)
end

function handler.ITEM_LOCK_CHANGED(btn, bagId, slot)
    if bagId ~= nil and slot ~= nil then
        local info = C_Container.GetContainerItemInfo(bagId, slot)
        if info ~= nil then
            SetItemButtonDesaturated(btn, info.isLocked)
        end
    end
end

function handler.INVENTORY_SEARCH_UPDATE(btn)
    local box = _G["BagItemSearchBox"]
    if not box then return end

    local s = string.lower(box:GetText())

    local info = addon.ItemInfoCache[btn.bagID][btn:GetID()]
    local itemName = string.lower(info.itemName)
    if string.find(itemName, s) then
        btn.searchOverlay:Hide()
    else
        btn.searchOverlay:Show()
    end
end