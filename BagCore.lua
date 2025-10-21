BetterCombinedBagDB = {}

local frame = CreateFrame("Frame")
local handler = {}

function handler.ADDON_LOADED(name)
    if name == BagData.addonName then
        BagMenu:BuildOptionsMenu()
    end
end

function handler.PLAYER_ENTERING_WORLD()
    -- refresh BagCache
    print("Player joined")
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(self, event, ...)
    local func = handler[event]
    if func then return func(...) end
end)

-- hooksecurefunc(ContainerFrameCombinedBags, "UpdateFrameSize", function(self)
--     if not BetterCombinedBagDB["Bag_Toggle"] then return end

--     BetterCombinedBag:UpdateFrameSize(self)
-- end)

-- hooksecurefunc(ContainerFrameCombinedBags, "UpdateItemLayout", function(self)
--     if not BetterCombinedBagDB["Bag_Toggle"] then return end

--     BetterCombinedBag:UpdateItemLayout(self)
-- end)

-- hooksecurefunc(ContainerFrameCombinedBags, "Update", function(self)
--     BetterCombinedBag:UpdateItemLevels(self)
-- end)