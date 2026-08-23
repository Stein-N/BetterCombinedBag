local addonName, addon = ...

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" and (...) == addonName then
        addon.BuildSettingsPage()

        -- Force CombinedBags to be enabled
        SetCVar("combinedBags", 1)

        -- Initialize all Modules. This is also where Modules register the
        -- Events they need via addon.AddEvent(event, func).
        if addon.Modules ~= nil then
            for _, module in pairs(addon.Modules) do
                if module.Init ~= nil then
                    module:Init()
                end
            end
        end

        -- Register every Event requested by Modules on this frame
        if addon.Events ~= nil then
            for eventName in pairs(addon.Events) do
                f:RegisterEvent(eventName)
            end
        end

        f:UnregisterEvent("ADDON_LOADED")
    end

    -- Trigger Event Code from Modules
    -- They need to be registered via addon.AddEvent(event, function)
    if addon.Events ~= nil and addon.Events[event] ~= nil then
        for _, func in ipairs(addon.Events[event]) do
            func(...)
        end
    end
end)