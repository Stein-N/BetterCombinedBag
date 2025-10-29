BetterCombinedBagDB = {}

local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("BAG_UPDATE_DELAYED")

frame:SetScript("OnEvent", function(self, event, name)
    if event == "PLAYER_ENTERING_WORLD" then
        BagCache:RefreshCache()
    end

    if event == "BAG_UPDATE_DELAYED" then
        BagCache:RefreshCache()
    end

    if event == "ADDON_LOADED" then
        if name == BagData.addonName then
            BagMenu:BuildOptionsMenu()
            BagUtils:UpdateSettings()
        end
    end
end)

---##################################---
---##     Secure function Hooks    ##---
---##################################---

-- Apply the Correct Layout to the Bag
---@param self ContainerFrameCombinedBags
hooksecurefunc(ContainerFrameCombinedBags, "UpdateItemLayout", function(self)
    if not BetterCombinedBagDB["Bag_Toggle"] then return end

    BagUtils:CacheButtons(self)
    BagUtils:UpdateFrameSize(self)

    if BetterCombinedBagDB["Bag_Toggle_Reagents_Bag"] then return end
    BagUtils:UpdateLayout(self)
end)

-- Add ItemLevelConponent and update the ItemLevel when anything is changed inside the Bag
---@param self ContainerFrameCombinedBags
hooksecurefunc(ContainerFrameCombinedBags, "Update", function(self)
    if not BetterCombinedBagDB["Bag_Toggle"] then return end

    BagUtils:UpdateItemLevel()
end)

hooksecurefunc(ContainerFrame6, "UpdateItemLayout", function(self)
    if not BetterCombinedBagDB["Bag_Toggle"] then return end

    BagUtils:CacheButtons(self)

    if BetterCombinedBagDB["Bag_Toggle_Reagents_Bag"] then
        local bag = _G["ContainerFrameCombinedBags"]
        if bag then
            BagUtils:UpdateLayout(bag)
        end
    end
end)

hooksecurefunc(ContainerFrame6, "SetPoint", function(self)
    if not BetterCombinedBagDB["Bag_Toggle"] then return end
    if BetterCombinedBagDB["Bag_Toggle_Reagents_Bag"] then
        self:ClearAllPoints()
    end
end)