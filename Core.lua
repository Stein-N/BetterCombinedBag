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
    if addon.Events ~= nil and addon.Events[event] ~= nil then
        for _, func in ipairs(addon.Events[event]) do
            if func ~= nil then func() end
        end
    end

    -----------------  Old Event Code ---------------
    -- TODO: rework with new Event System by moving events to corresponding Modules



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