BetterCombinedBagDB = {}

local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("BAG_UPDATE_DELAYED")
frame:RegisterEvent("ITEM_LOCK_CHANGED")
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
frame:RegisterEvent("INVENTORY_SEARCH_UPDATE")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == BagData.addonName then
            BagMenu.BuildOptionsMenu()
            BagUtils.UpdateSettings()
        end
    end

    if event == "PLAYER_EQUIPMENT_CHANGED" then
        BagCache.UpdateBagSlots()
    end

    if event == "PLAYER_ENTERING_WORLD" then
        BagCache.UpdateBagSlots()
        BagCache.CacheBagItems()
    end

    if event == "BAG_UPDATE_DELAYED" then
        BagCache.CacheBagItems()
        BagUtils.UpdateItemLevel()
        BagButtons.UpdateBaseInformation()
    end

    if event == "ITEM_LOCK_CHANGED" then
        local bagId, slot = ...
        if bagId == Enum.BagIndex.ReagentBag then
            if bagId == nil or slot == nil then return end
            local info = C_Container.GetContainerItemInfo(bagId, slot)
            if info then
                local btn = _G["BetterCombinedBagsSlot"..slot]
                if btn then btn.icon:SetDesaturated(info.isLocked) end
            end
        end
    end

    if event == "INVENTORY_SEARCH_UPDATE" then
        local box = _G["BagItemSearchBox"]
        if not box then return end
        local s = string.lower(box:GetText())

        for i = 1, BagCache.GetBagSize(5) do
            local btn = _G["BetterCombinedBagsSlot"..i]
            if not btn then return end

            local info = BagCache.GetItemInfo(5, i)
            if not info then return end

            local name = string.lower(info.itemName)
            if string.find(name, s) then
                btn.SearchOverlay:Hide()
            else
                btn.SearchOverlay:Show()
            end
        end
    end
end)

---##################################---
---##     Secure function Hooks    ##---
---##################################---

hooksecurefunc(ContainerFrameCombinedBags, "UpdateItemLayout", function(self)
    BagUtils.UpdateCombinedBagsFrame(self)
    BagButtons.UpdateBaseInformation()
end)

hooksecurefunc(ContainerFrame6, "SetPoint", function(self) self:ClearAllPoints() end)