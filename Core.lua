local name, addon = ...
BCB_Settings = {}

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")

f:SetScript("OnEvent", function(_, event, ...)
    local n = ...
    if event == "ADDON_LOADED" and n == name then
        addon.BuildSettingsPage()
    end
end)