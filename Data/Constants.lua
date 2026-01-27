local _, addon = ...

addon.Settings = {
    -- General Settings
    itemSync = { key = "itemSync", default = true },
    addReagentsBag = { key = "addReagentsBag", default = false },
    itemLevel = { key = "itemLevel", default = 0 },
    itemLevelShow = { key = "itemLevelShow", default = false },
    itemLevelColor = { key = "itemLevelColor", default = false },
    itemLevelScale = { key = "itemLevelScale", default = 125 },

    -- Bag Frame Settings
    bagSplitBags = { key = "bagSplitBags", default = true },
    bagColumns = { key = "bagColumns", default = 10 },
    bagBorderPadding = { key = "bagBorderPadding", default = 0 },
    bagItemPadding = { key = "bagItemPadding", default = 0 },
    bagBagPadding = { key = "bagBagPadding", default = 0 },
    bagReagentsPadding = { key = "bagReagentsPadding", default = 10 },

    -- Bank Frame Settings
    bankBorderPadding = { key = "bankBorderPadding", default = 0 },
    bankItemPadding = { key = "bankItemPadding", default = 0 }
}

addon.ItemLevelLabels = { "bag", "bank", "character", "inspect" }

addon.Locale = {
    enUS = {
        header = {
            general = { label = "General", tooltip = "General Quality of Life settings" },
            frame = { label = "Frame Settings", tooltip = "Adjust the Settings for Bag and Bank Frames" },
            bagFrame = { label = "Bag Settings", tooltip = "Adjust the Settings for Bag Frame" },
            bankFrame = { label = "Bank Settings", tooltip = "Adjust the Settings for Bank Frame" }
        },
        anchor = { tl = "Top Left", tr = "Top Right", bl = "Bottom Left", br = "Bottom Right" },

        -- General Settings
        itemSync = { label = "Item Sync", tooltip = "Enable to synchronize item data across characters and display it in item tooltips." },
        itemLevel = { label = "Show Item Level", tooltip = "Choose whether the item level is shown in the selected frames." },
        addReagentsBag = { label = "Add Reagents Bag", tooltip = "Adds the reagents bag to the combined bag frame instead of having an extra frame." },
        itemLevelShow = { label = "Show Item Level", tooltip = "Choose whether the item level is shown in the selected frames." },
        itemLevelColor = { label = "Color Item Level", tooltip = "Color the item level in the rarity color of the item." },
        itemLevelScale = { label = "Item Level Scale", tooltip = "Adjust the scale of the item level text." },

        -- Bag Frame Settings
        bagSplitBags = { label = "Split Bags", tooltip = "Each bag starts on a new row, even if the previous row has empty space." },
        bagColumns = { label = "Columns", tooltip = "Maximum number of items per row. When 'Split Bags' is enabled, this value will be overridden by the size of the largest bag if it is smaller." },
        bagBorderPadding = { label = "Border Padding", tooltip = "Adjust the space between items and the frame border." },
        bagItemPadding = { label = "Item Padding", tooltip = "Adjust the space between items." },
        bagBagPadding = { label = "Bag Padding", tooltip = "Add extra space between each bag when 'Split Bags' is enabled." },
        bagReagentsPadding = { label = "Reagents Bag Padding", tooltip = "Add extra space between the item bag and the reagent bag." },

        -- Bank Frame Settings -- Currently Unused
        bankBorderPadding = { label = "Border Padding", tooltip = "Adjust the space between items and the frame border." },
        bankItemPadding = { label = "Item Padding", tooltip = "Adjust the space between items." },

        -- Checkbox Dropdown Labels/Tooltips
        bag = { label = "Bag Frame", tooltip = "Show item levels for bag items" },
        bank = { label = "Bank Frame", tooltip = "Show item levels for bank items." },
        character = { label = "Character Frame", tooltip = "Show item levels inside the character frame" },
        inspect = { label = "Inspect Frame", tooltip = "Show item levels inside inspected character frame" }
    }
}
