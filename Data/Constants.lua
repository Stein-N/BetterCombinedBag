local _, addon = ...

addon.Settings = {
    -- General Settings
    addReagentsBag = { key = "addReagentsBag", default = false },
    itemLevel = { key = "itemLevel", default = 0 },
    itemLevelColor = { key = "itemLevelColor", default = false },
    itemLevelScale = { key = "itemLevelScale", default = 125 },

    -- Bag Frame Settings
    bagSplitBags = { key = "bagSplitBags", default = true },
    bagColumns = { key = "bagColumns", default = 10 },
    bagBorderPadding = { key = "bagBorderPadding", default = 0 },
    bagItemPadding = { key = "bagItemPadding", default = 0 },
    bagReagentsPadding = { key = "bagReagentsPadding", default = 10 },

    -- Bank Frame Settings
    bankBorderPadding = { key = "bankBorderPadding", default = 0 },
    bankItemPadding = { key = "bankItemPadding", default = 0 }
}

addon.ItemLevelLabels = { "bag", "bank" }

addon.Locale = {
    enUS = {
        header = {
            general = { label = "General", tooltip = "General Quality of Life settings" },
            bagFrame = { label = "Bag Settings", tooltip = "Adjust the Settings for Bag Frame" },
            bankFrame = { label = "Bank Settings", tooltip = "Adjust the Settings for Bank Frame" }
        },

        -- General Settings
        addReagentsBag = { label = "Add Reagents Bag", tooltip = "Adds the reagents bag to the combined bag frame instead of having an extra frame." },
        itemLevel = { label = "Show Item Level", tooltip = "Choose whether the item level is shown in the selected frames." },
        itemLevelColor = { label = "Color Item Level", tooltip = "Color the item level in the rarity color of the item." },
        itemLevelScale = { label = "Item Level Scale", tooltip = "Adjust the scale of the item level text." },

        -- Bag Frame Settings
        bagSplitBags = { label = "Split Bags", tooltip = "Each bag starts on a new row, even if the previous row has empty space." },
        bagColumns = { label = "Columns", tooltip = "Maximum number of items per row. When 'Split Bags' is enabled, this value will be overridden by the size of the largest bag if it is smaller." },
        bagBorderPadding = { label = "Border Padding", tooltip = "Adjust the space between items and the frame border." },
        bagItemPadding = { label = "Item Padding", tooltip = "Adjust the space between items." },
        bagReagentsPadding = { label = "Reagents Bag Padding", tooltip = "Add extra space between the item bag and the reagent bag." },

        -- Bank Frame Settings
        bankBorderPadding = { label = "Border Padding", tooltip = "Adjust the space between items and the frame border." },
        bankItemPadding = { label = "Item Padding", tooltip = "Adjust the space between items." },

        -- Checkbox Dropdown Labels/Tooltips
        bag = { label = "Bag Frame", tooltip = "Show item levels for bag items" },
        bank = { label = "Bank Frame", tooltip = "Show item levels for bank items." }
    }
}
