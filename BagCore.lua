BetterCombinedBagDB = {}

local frame = CreateFrame("Frame")
local handler = {}

-- local testFrame = CreateFrame("Frame", "MyTestFrame", nil, "ButtonFrameTemplate")
-- testFrame:SetSize(200, 150)
-- testFrame:Show()

function handler.ADDON_LOADED(name)
    if name == BagData.addonName then
        BagMenu:BuildOptionsMenu()
        BagUtils:UpdateSettings()
    end
end

function handler.PLAYER_ENTERING_WORLD()
    -- refresh BagCache
    BagCache:RefreshCache()
end

function handler:BAG_UPDATE_DELAYED()
    BagCache:RefreshCache()
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("BAG_UPDATE_DELAYED")

frame:SetScript("OnEvent", function(self, event, ...)
    local func = handler[event]
    if func then return func(...) end
end)

-- Apply the correct Size to the BagFrame
hooksecurefunc(ContainerFrameCombinedBags, "UpdateFrameSize", function(self)
    if not BetterCombinedBagDB["Bag_Toggle"] then return end

    BagUtils:CollectButtons(self)
    BagUtils:UpdateFrameSize(self)
end)

-- Apply the Correct Layout to the Bag
hooksecurefunc(ContainerFrameCombinedBags, "UpdateItemLayout", function(self)
    if not BetterCombinedBagDB["Bag_Toggle"] then return end

    BagUtils:UpdateLayout(self)
end)

-- Add ItemLevelConponent and update the ItemLevel when anything is changed inside the Bag
hooksecurefunc(ContainerFrameCombinedBags, "Update", function(self)
    BagUtils:UpdateItemLevel()
end)