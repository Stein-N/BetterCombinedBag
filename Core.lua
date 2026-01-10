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
        addon.GenerateBankButtons()
        addon.GenerateReagentsButtons()
    end

    if event == "BAG_UPDATE_DELAYED" then
        addon.CacheItemInfos()
    end

    if event == "PLAYER_EQUIPMENT_CHANGED" then
        addon.ShowCharacterItemLevel()
    end
end)