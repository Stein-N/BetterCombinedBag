BagMenu = {}
local langCode = GetLocale()

-- ====================== --
-- ==  Helper Methods  == --
-- ====================== --

-- Set the default value for an Option inside the SavedVariables
local function SetDefault(option)
    local key = option.key
    if BetterCombinedBagDB[key] then return end

    BetterCombinedBagDB[key] = option.default
end

-- Basic function to update the Option Value
local function UpdateSetting(setting, value)
    BetterCombinedBagDB[setting:GetVariable()] = value
    BagUtils:UpdateSettings()
end

-- Register the given Option inside the Category
local function RegisterSetting(category, option, lang)
    return Settings.RegisterAddOnSetting(
        category, option.key, option.key,
        BetterCombinedBagDB, type(option.default),
        lang.name, option.default)
end

-- Loads the Option and Lang Object from the Database
local function GetOption(optionKey)
    local option = BagSettings[optionKey]
    local lang = option[langCode] or option["enEN"]
    return option, lang
end

-- Load all PlayerInfo Header
local function GetHeader()
    local header = BagData["optionHeader"]
    return header[langCode] or header["enEN"]
end

-- =========================== --
-- ==  UI Element Creation  == --
-- =========================== --

-- Create a new Checkbox inside the given Category
local function RegisterCheckbox(category, optionKey)
    local option, lang = GetOption(optionKey)
    local setting = RegisterSetting(category, option, lang)
    setting:SetValueChangedCallback(UpdateSetting)

    Settings.CreateCheckbox(category, setting, lang["tooltip"])
end

-- Create a new SLider inside the given Category
local function RegisterSlider(category, optionKey, min, max, steps, suffix)
    local option, lang = GetOption(optionKey)
    local setting = RegisterSetting(category, option, lang)
    setting:SetValueChangedCallback(UpdateSetting)

    local sliderValues = Settings.CreateSliderOptions(min, max, steps)
    sliderValues:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
        return value .. (suffix or "")
    end)
    Settings.CreateSlider(category, setting, sliderValues, lang["tooltip"])
end

-- =========================== --
-- ==  Option Menu Builder  == --
-- =========================== --

function BagMenu:BuildOptionsMenu()
    local general, generalLayout = Settings.RegisterVerticalLayoutCategory(BagData.addonName)

    for _, key in ipairs(BagSettings) do
        SetDefault(BagSettings[key])
    end

    local headers = GetHeader()

    generalLayout:AddInitializer(CreateSettingsListSectionHeaderInitializer(headers.general))
    RegisterCheckbox(general, "toggleBetterBag")
    RegisterCheckbox(general, "toogleBackpackSplit")
    RegisterCheckbox(general, "toggleReagentsBag")

    generalLayout:AddInitializer(CreateSettingsListSectionHeaderInitializer(headers.frameOptions))
    RegisterSlider(general, "backpackColumns", 10, 36, 1)
    RegisterSlider(general, "borderPadding", 2, 50, 1, "px")
    RegisterSlider(general, "itemPadding", 0, 50, 1, "px")
    RegisterSlider(general, "reagentsBagPadding", 0, 20, 1, "px")

    Settings.RegisterAddOnCategory(general)
end