local addonName, addon = ...
BCB_Settings = {}

local f = CreateFrame("Frame")
f:RegisterAllEvents()

f:SetScript("OnEvent", function(_, event, ...)
    local name = ...
    if event == "ADDON_LOADED" and name == addonName then
        addon.BuildSettingsPage()
        -- Force CombinedBags to be enabled
        SetCVar("combinedBags", 1)

        -- Initialize all Modules
        if addon.Modules ~= nil then
            for _, module in pairs(addon.Modules) do
                if module.Init ~= nil then
                    module:Init()
                end
            end
        end
    end

    -- Trigger Event Code from Modules
    -- They need to be registered via addon.AddEvent(event, function)
    if addon.Events ~= nil and addon.Events[event] ~= nil then
        for _, func in ipairs(addon.Events[event]) do
            if func ~= nil then func(...) end
        end
    end
end)