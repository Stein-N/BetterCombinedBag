local name, addon = ...
BCB_Settings = {}

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("BAG_UPDATE_DELAYED")
f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

-- TODO: extract to extra class only for events
f:SetScript("OnEvent", function(_, event, ...)
    local n = ...
    if event == "ADDON_LOADED" and n == name then
        addon.BuildSettingsPage()

        addon.CacheItemInfos()
    end

    if event == "BAG_UPDATE_DELAYED" then
        addon.CacheItemInfos()
    end

    if event == "PLAYER_EQUIPMENT_CHANGED" then
        addon.ShowCharacterItemLevel()

        addon.GenerateBagButtons()
    end
end)

hooksecurefunc(CharacterFrame, "Show", function()
    addon.ShowCharacterItemLevel()
end)


local btn = addon.GenerateBagButton(5, 1, "Reagent")
hooksecurefunc(ContainerFrameCombinedBags, "UpdateItemLayout", function(self)
    btn:ClearAllPoints()
    btn:SetPoint("TOPLEFT", self, "TOPLEFT", -80, -50)
    btn:UpdateNewItem()
end)