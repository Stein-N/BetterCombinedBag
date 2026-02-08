local name, addon = ...

local _category, _layout = Settings.RegisterVerticalLayoutCategory(name)
local _lang = GetLocale()

local function InitSettings()
    for _, value in pairs(addon.Settings) do
        if value and value.key then
            local key = value.key

            if BCB_Settings[key] == nil then
                BCB_Settings[key] = value.default
            end
        end
    end

    if BCB_Settings.showFor == nil then
        BCB_Settings.showFor = {}
        for _, value in pairs(addon.ItemLevelLabels) do
            BCB_Settings.showFor[value] = false
        end
    end
end

local function GetLang()
    return addon.Locale[_lang] or addon.Locale.enUS
end

local function CreateSetting(key)
    local option = addon.Settings[key]
    local lang = GetLang()[key]

    if option and lang then
        local setting = Settings.RegisterAddOnSetting(_category, option.key, option.key,
                BCB_Settings, type(option.default), lang.label, option.default)
        setting:SetValueChangedCallback(function(s, v) BCB_Settings[s:GetVariable()] = v end)
        return setting, lang
    end
end

local function CreateCheckbox(key)
    local s, l = CreateSetting(key)
    if s and l then
        Settings.CreateCheckbox(_category, s, l.tooltip)
    end
end

local function CreateSlider(key, min, max, steps, suffix)
    local s, l = CreateSetting(key)
    if s and l then
        local option = Settings.CreateSliderOptions(min, max, steps)
        option:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right,
        function(v) return v .. (suffix or "") end)

        Settings.CreateSlider(_category, s, option, l.tooltip)
    end
end

local function CreateCheckboxDropdown(option, getter, setter, optionBuilder)
    local lang = GetLang()[option.key]
    local proxy = Settings.RegisterProxySetting(_category, option.key, Settings.VarType.Number, lang.label, option.default, getter, setter)
    local init = Settings.CreateDropdown(_category, proxy, optionBuilder, lang.tooltip)
    init.getSelectionTextFunc = function(s) if #s == 0 then return 'None' else return nil end end
end

local function CreateHeader(header)
    local init = CreateSettingsListSectionHeaderInitializer(header.label, header.tooltip)

    _layout:AddInitializer(init)
end

local function BuildCheckboxOptions(table)
    local c = Settings.CreateControlTextContainer()
    local l = GetLang()

    for index, value in ipairs(table) do
        c:AddCheckbox(index, l[value].label, l[value].tooltip)
    end

    return c:GetData()
end

local function Getter(key)
    return BCB_Settings[key] or 0
end

local function Setter(key, active, table, value)
    BCB_Settings[key] = value

    if not BCB_Settings[active] then BCB_Settings[active] = {} end

    for i = #table, 1, -1 do
        if (value - (2^(i-1))) >= 0 then
            BCB_Settings[active][table[i]] = true
            value = value - 2^(i-1)
        else
            BCB_Settings[active][table[i]] = false
        end
    end
end

function addon.BuildSettingsPage()
    InitSettings()

    local header = GetLang()["header"]

    CreateHeader(header.general)
    --CreateCheckbox("itemSync")
    CreateCheckbox("addReagentsBag")
    CreateCheckbox("itemGemsEnchantment")
    CreateCheckboxDropdown(
            addon.Settings.itemLevel,
            function() return Getter("itemLevel") end,
            function(value) Setter("itemLevel", "showFor", addon.ItemLevelLabels, value) end,
            function() return BuildCheckboxOptions(addon.ItemLevelLabels) end
    )
    CreateCheckbox("itemLevelColor")
    CreateSlider("itemLevelScale", 50, 200, 5, "%")
    CreateCheckbox("separateFrame")

    CreateHeader(header.bagFrame)
    CreateCheckbox("bagSplitBags")
    CreateSlider("bagColumns", 10, 38, 1, "")
    CreateSlider("bagBorderPadding", 0, 50, 1, "px")
    CreateSlider("bagItemPadding", 0, 50, 1, "px")
    CreateSlider("bagBagPadding", 0, 50, 1, "px")
    CreateSlider("bagReagentsPadding", 0, 50, 1, "px")

    CreateHeader(header.bankFrame)
    CreateSlider("bankBorderPadding", 0, 50, 1, "px")
    CreateSlider("bankItemPadding", 0, 50, 1, "px")

    Settings.RegisterAddOnCategory(_category)
end