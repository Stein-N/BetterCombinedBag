local name, addon = ...
BCB_Settings = {}

local f = CreateFrame("Frame")
f:RegisterEvent("CVAR_UPDATE")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("BANKFRAME_OPENED")
f:RegisterEvent("BAG_UPDATE_DELAYED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

local blocked = true
f:SetScript("OnEvent", function(_, event, ...)
    local n = ...
    if event == "ADDON_LOADED" and n == name then
        addon.BuildSettingsPage()

        for _, module in pairs(addon.Modules) do
            if module.Init ~= nil then
                module:Init()
            end
        end

        SetCVar("combinedBags", 1) -- Force CombinedBags to be enabled
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

    -- TODO: have to be in BagModule
    if event == "CVAR_UPDATE" then
        local cvar = ...
        if cvar == 'combinedBags' and blocked == false then
            blocked = true
            SetCVar(cvar, 1)
            print("BetterCombinedBags blocks the change to separate Bags, disable it in the AddOns settings to switch bag to single bags.")
        else blocked = false end
    end
end)