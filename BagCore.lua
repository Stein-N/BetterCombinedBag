BetterCombinedBagDB = {}

local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("BAG_UPDATE_DELAYED")
frame:RegisterEvent("ITEM_LOCK_CHANGED")
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

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
    end
end)

---##################################---
---##     Secure function Hooks    ##---
---##################################---

hooksecurefunc(ContainerFrameCombinedBags, "UpdateItemLayout", function(self)
    BagUtils.UpdateCombinedBagsFrame(self)
end)

hooksecurefunc(ContainerFrameCombinedBags, "Update", function(self)
    BagUtils.UpdateItemLevel()
end)