BetterCombinedBagDB = {}

local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("BAG_UPDATE_DELAYED")

frame:SetScript("OnEvent", function(self, event, name)
    if event == "PLAYER_ENTERING_WORLD" then
        BagCache:RefreshCache()

        -- quick and very dirty fix for caching reagent ItemButtons
        ToggleAllBags()
        ToggleAllBags()
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

hooksecurefunc("ToggleAllBags", function()
    if BetterCombinedBagDB["Bag_Toggle"] then
        local reags, bags = _G["ContainerFrame6"], _G["ContainerFrameCombinedBags"]
        if reags then BagUtils:CacheButtons(reags) end
        if bags then bags:UpdateItemLayout() end

        if BetterCombinedBagDB["Bag_Toggle_Reagents_Bag"] then
            reags:ClearAllPoints()
        end
    end
end)


-- quick and dirty fix for missing itemButtons when only Combined Bag is opened 
hooksecurefunc(ContainerFrameCombinedBags, "Show", function(self)
    local reagsFrame = _G["ContainerFrame6"]
    if reagsFrame then
        reagsFrame:Show()
        self:UpdateLayout()
    end
end)

-- Apply the Correct Layout to the Bag
---@param self ContainerFrameCombinedBags
hooksecurefunc(ContainerFrameCombinedBags, "UpdateItemLayout", function(self)
    if BetterCombinedBagDB["Bag_Toggle"] then
        BagUtils:CacheButtons(self)
        BagUtils:UpdateFrameSize(self)
        BagUtils:UpdateLayout(self)
    end
end)

-- Add ItemLevelConponent and update the ItemLevel when anything is changed inside the Bag
---@param self ContainerFrameCombinedBags
hooksecurefunc(ContainerFrameCombinedBags, "Update", function(self)
    if BetterCombinedBagDB["Bag_Toggle"] then
        BagUtils:UpdateItemLevel()
    end
end)

hooksecurefunc(ContainerFrame6, "SetPoint", function(self)
    if BetterCombinedBagDB["Bag_Toggle_Reagents_Bag"] then
        self:ClearAllPoints()
    end
end)