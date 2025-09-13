BetterCombinedBagDB = {}

local frame = CreateFrame("Frame")
local handler = {}

function handler.ADDON_LOADED(name)
    if name == BetterCombinedBagData.addonName then
        BetterCombinedBagSettings:BuildOptionsMenu()
    end
end

frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, ...)
    local func = handler[event]
    if func then return func(...) end
end)

hooksecurefunc(ContainerFrameCombinedBags, "UpdateFrameSize", function(self)
    BetterCombinedBag:ResizeCombinedFrame(self)
end)

hooksecurefunc(ContainerFrameCombinedBags, "UpdateItemLayout", function(self)
    if BetterCombinedBagDB["Bag_Toogle_Backpack_Split"] then
        BetterCombinedBag:UpdateSplittedItemLayout(self)
    else
        BetterCombinedBag:UpdateItemLayout(self)
    end
end)