BetterCombinedBagDB = {}

local frame = CreateFrame("Frame")
local handler = {}

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

hooksecurefunc(ContainerFrameCombinedBags, "UpdateFrameSize", function(self)
    if not BetterCombinedBagDB["Bag_Toggle"] then return end

    BagUtils:UpdateFrameSize(self)
end)

hooksecurefunc(ContainerFrameCombinedBags, "UpdateItemLayout", function(self)
    if not BetterCombinedBagDB["Bag_Toggle"] then return end

    BagUtils:UpdateLayout(self)
end)

hooksecurefunc(ContainerFrameCombinedBags, "Update", function(self)
    for _, itemButton in self:EnumerateValidItems() do
        if itemButton ~= nil then
            BagUtils:AddItemLevelComponent(itemButton)
            BagUtils:UpdateItemLevel(itemButton)
        end
    end
end)