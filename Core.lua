local addonName, addon = ...
BCB_Settings = {}

local f = CreateFrame("Frame")
f:RegisterAllEvents()

local blocked = true
f:SetScript("OnEvent", function(_, event, ...)
    local name = ...
    if event == "ADDON_LOADED" and name == addonName then
        addon.BuildSettingsPage()
        -- Force CombinedBags to be enabled
        SetCVar("combinedBags", 1)

        -- Initialize all Modules
        for _, module in pairs(addon.Modules) do
            if module.Init ~= nil then
                module:Init()
            end
        end
    end

    -- Trigger Event Code from Modules
    -- They need to be registered via addon.AddEvent(event, function)
    local events = addon[event]
    if events ~= nil then
        for func in pairs(events) do
            func()
        end
    end

    -----------------  Old Event Code ---------------
    -- TODO: rework with new Event System by moving events to corresponding Modules

    if event == "PLAYER_ENTERING_WORLD" then
        addon.CacheAllItems()
    end

    if event == "BAG_UPDATE_DELAYED" or event == "BANKFRAME_OPENED" then
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