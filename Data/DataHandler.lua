local addonName, addon = ...

local DataHandler = {}

-- Recursively copies values from source onto target, keeping any
-- default key in target that source does not provide.
local function DeepMerge(target, source)
    for k, v in pairs(source) do
        if type(v) == "table" and type(target[k]) == "table" then
            DeepMerge(target[k], v)
        else
            target[k] = v
        end
    end
end

-- Merges the saved data over the defaults for every declared SavedVariable,
-- then points the global back at the merged table so it keeps saving correctly.
function DataHandler.OnLoad()
    for key, _ in pairs(addon.db) do
        local saved = _G[key]
        if saved ~= nil then
            DeepMerge(addon.db[key], saved)
        end
        _G[key] = addon.db[key]
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" and name == addonName then
        DataHandler.OnLoad()
        f:UnregisterEvent("ADDON_LOADED")
    end
end)

-- Default values for every declared SavedVariable, keyed by global name.
addon.db = {
    Settings = {
        -- General Settings
        addReagentsBag = false,
        itemLevel = 0,
        itemLevelColor = false,
        itemLevelScale = 125,
        showFor = { bag = false, bank = false },

        -- Bag Frame Settings
        bagSplitBags = true,
        bagColumns = 10,
        bagBorderPadding = 0,
        bagItemPadding = 0,
        bagReagentsPadding = 10,

        -- Bank Frame Settings
        bankBorderPadding = 0,
        bankItemPadding = 0
    }
}
