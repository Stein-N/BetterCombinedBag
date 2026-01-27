local name, addon = ...
BCB_Settings = {}

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("BANKFRAME_OPENED")
f:RegisterEvent("BAG_UPDATE_DELAYED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

f:SetScript("OnEvent", function(_, event, ...)
    local n = ...
    if event == "ADDON_LOADED" and n == name then
        addon.BuildSettingsPage()
        addon.GenerateBankButtons()
        addon.GenerateReagentsButtons()
    end

    if event == "ADDON_LOADED" and n == "Blizzard_InspectUI" then
        hooksecurefunc('InspectPaperDollFrame_UpdateButtons', function()
            addon.ShowInspectItemLevel()
            addon.ShowInspectAverageLevel()
        end)
    end

    if event == "PLAYER_ENTERING_WORLD"
            or event == "BAG_UPDATE_DELAYED"
            or event == "BANKFRAME_OPENED"
    then
        addon.CacheAllItems()
    end

    if event == "PLAYER_EQUIPMENT_CHANGED" then
        addon.ShowCharacterItemLevel()
    end
end)