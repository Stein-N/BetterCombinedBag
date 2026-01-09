local _, addon = ...

addon.Settings = {
    -- General Settings
    itemSync = { key = "itemSync", default = true },
    itemLevel = { key = "itemLevel", default = 0 },
    itemLevelShow = { key = "itemLevelShow", default = false },
    itemLevelColor = { key = "itemLevelColor", default = false },
    itemLevelScale = { key = "itemLevelScale", default = 1 },
    separateFrame = { key = "separateFrame", default = false },

    -- General Frame Settings
    splitBags = { key = "splitBags", default = true },
    columns = { key = "columns", default = 10 },
    borderPadding = { key = "borderPadding", default = 7 },
    itemPadding = { key = "itemPadding", default = 4 },
    bagPadding = { key = "bagPadding", default = 0 },
    addReagentsBag = { key = "addReagentsBag", default = false },
    reagentsPadding = { key = "reagentsPadding", default = 0 },

    -- Bag Frame Settings
    bagSplitBags = { key = "bagSplitBags", default = true },
    bagColumns = { key = "bagColumns", default = 10 },
    bagBorderPadding = { key = "bagBorderPadding", default = 7 },
    bagItemPadding = { key = "bagItemPadding", default = 4 },
    bagBagPadding = { key = "bagBagPadding", default = 0 },
    bagAddReagentsBag = { key = "bagAddReagentsBag", default = false },
    bagReagentsPadding = { key = "bagReagentsPadding", default = 0 },

    -- Bank Frame Settings -- Currently Unused
    bankSplitBags = { key = "bankSplitBags", default = true },
    bankColumns = { key = "bankColumns", default = 14 },
    bankBorderPadding = { key = "bankBorderPadding", default = 7 },
    bankItemPadding = { key = "bankItemPadding", default = 4 },
    bankBagPadding = { key = "bankBagPadding", default = 0 }
}

addon.ItemLevelLabels = { "bag", "bank", "character" }

addon.Locale = {
    enUS = {
        header = { general = "General", frame = "Frame Settings", bagFrame = "Bag Frame", bankFrame = "Bank Frame" },
        anchor = { tl = "Top Left", tr = "Top Right", bl = "Bottom Left", br = "Bottom Right" },

        -- General Settings
        itemSync = { label = "Item Sync", tooltip = "Enable to synchronize item data across characters and display it in item tooltips." },
        itemLevel = { label = "Show Item Level", tooltip = "Choose whether the item level is shown in the selected frames." },
        addReagentsBag = { label = "Add Reagents Bag", tooltip = "Adds the reagents bag to the combined bag frame instead of having an extra frame." },
        itemLevelShow = { label = "Show Item Level", tooltip = "Choose whether the item level is shown in the selected frames." },
        itemLevelColor = { label = "Color Item Level", tooltip = "Color the item level in the rarity color of the item." },
        itemLevelScale = { label = "Item Level Scale", tooltip = "Adjust the scale of the item level text." },
        separateFrame = { label = "Separate Frame Settings", tooltip = "Adjust Frame Settings for the Bag and Bank separately." },

        -- Combined Frame Settings
        splitBags = { label = "Split Bags", tooltip = "Each bag starts on a new row, even if the previous row has empty space." },
        columns = { label = "Columns", tooltip = "Maximum number of items per row. When 'Split Bags' is enabled, this value will be overridden by the size of the largest bag if it is smaller." },
        borderPadding = { label = "Border Padding", tooltip = "Adjust the space between items and the frame border." },
        itemPadding = { label = "Item Padding", tooltip = "Adjust the space between items." },
        bagPadding = { label = "Bag Padding", tooltip = "Add extra space between each bag when 'Split Bags' is enabled." },
        reagentsPadding = { label = "Reagents Bag Padding", tooltip = "Add extra space between the item bag and the reagent bag. Only affects the Combined Bag Frame." },

        -- Bag Frame Settings
        bagSplitBags = { label = "Split Bags", tooltip = "Each bag starts on a new row, even if the previous row has empty space." },
        bagColumns = { label = "Columns", tooltip = "Maximum number of items per row. When 'Split Bags' is enabled, this value will be overridden by the size of the largest bag if it is smaller." },
        bagBorderPadding = { label = "Border Padding", tooltip = "Adjust the space between items and the frame border." },
        bagItemPadding = { label = "Item Padding", tooltip = "Adjust the space between items." },
        bagBagPadding = { label = "Bag Padding", tooltip = "Add extra space between each bag when 'Split Bags' is enabled." },
        bagReagentsPadding = { label = "Reagents Bag Padding", tooltip = "Add extra space between the item bag and the reagent bag." },

        -- Bank Frame Settings -- Currently Unused
        bankSplitBags = { label = "Split Bags", tooltip = "Each bag starts on a new row, even if the previous row has empty space." },
        bankColumns = { label = "Columns", tooltip = "Maximum number of items per row. When 'Split Bags' is enabled, this value will be overridden by the size of the largest bag if it is smaller." },
        bankBorderPadding = { label = "Border Padding", tooltip = "Adjust the space between items and the frame border." },
        bankItemPadding = { label = "Item Padding", tooltip = "Adjust the space between items." },
        bankBagPadding = { label = "Bag Padding", tooltip = "Add extra space between each bag when 'Split Bags' is enabled." },

        -- Checkbox Dropdown Labels/Tooltips
        bag = { label = "Bag Frame", tooltip = "Show item levels for bag items" },
        bank = { label = "Bank Frame", tooltip = "Show item levels for bank items." },
        character = { label = "Character Frame", tooltip = "Show item levels for equipped items" }
    }
}
