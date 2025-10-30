BagUtils = {}

local _borderPadding, _itemPadding, _columns, _splitBags, _addReagentsBag, _reagBagPadding
local _buttonCache = {[0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}}
local _itemSize = 36

function BagUtils.UpdateSettings()
    local db = BetterCombinedBagDB
    _borderPadding = db["Bag_Border_Padding"]
    _itemPadding = db["Bag_Item_Padding"]
    _columns = db["Bag_Backpack_Columns"]
    _splitBags = db["Bag_Toggle_Backpack_Split"]
    _addReagentsBag = db["Bag_Toggle_Reagents_Bag"]
    _reagBagPadding = db["Bag_Reagents_Padding"]
end

local function AddBagItemLevelComponent(button)
    if not button.BagItemLevel then
        local comp = button:CreateFontString(nil, "OVERLAY", "GameFontNormalOutline")
        comp:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
        comp:SetTextColor(1, 1, 1, 1)
        comp:SetScale(1.25)
        button.BagItemLevel = comp
    end
end

local function CacheButtons(container)
    for _, btn in container:EnumerateValidItems() do
        if btn then
            AddBagItemLevelComponent(btn)
            _buttonCache[btn.bagID][btn:GetID()] = btn
        end
    end
end

local function UpdateFrameSize(container)
    if not container then return end

    _columns = BagCache.GetMaxItemPerRow(_columns, _addReagentsBag)
    local width = _columns * (_itemSize + _itemPadding) - _itemPadding + (2 * _borderPadding)

    local rows, height = 0, 0
    if _splitBags then
        for i = 0, 4 do
            rows = rows + math.ceil(BagCache.GetBagSize(i) / _columns)
        end
    else
        rows = math.ceil(BagCache.GetFullBagSize() / _columns)
    end

    if _addReagentsBag then
        rows = rows + math.ceil(BagCache.GetBagSize(5) / _columns)
        height = _reagBagPadding
    end

    height = height + rows * (_itemSize + _itemPadding) - _itemPadding + 90

    if C_CurrencyInfo.GetBackpackCurrencyInfo(1) then
        height = height + 20
    end

    container:SetSize(width, height)
end

local function UpdateButtonLayout(container)
    local x, y, counter = _borderPadding, -60, 0
    local step = _itemSize + _itemPadding

    for i = 0, 5 do
        if i < 5 or _addReagentsBag then

            if i == 5 then
                y = y - _reagBagPadding
                if counter ~= 0 then
                    x = _borderPadding
                    y = y - step
                    counter = 0
                end
            end
            
            for _, btn in ipairs(_buttonCache[i]) do
                if btn then
                    btn:ClearAllPoints()
                    btn:SetPoint("TOPLEFT", container, "TOPLEFT", x, y)
                    btn:Show()

                    counter = counter + 1
                    if counter < _columns then
                        x = x + step
                    else
                        x = _borderPadding
                        y = y - step
                        counter = 0
                    end
                end
            end

            if counter ~= 0 and _splitBags then
                x = _borderPadding
                y = y - step
                counter = 0
            end
        end
    end
end

function BagUtils.UpdateCombinedBagsFrame(container)
    CacheButtons(container)
    UpdateFrameSize(container)
    UpdateButtonLayout(container)
end

function BagUtils.UpdateItemLevel()
    for i = 0, 4 do
        for _, btn in ipairs(_buttonCache[i]) do
            if btn then
                local info = BagCache.GetItemInfo(btn.bagID, btn:GetID())
                if info and C_Item.IsEquippableItem(info.itemID) then
                    local loc = ItemLocation:CreateFromBagAndSlot(btn.bagID, btn:GetID())
                    local lvl = C_Item.GetCurrentItemLevel(loc)
                    btn.BagItemLevel:SetText(lvl)
                    btn.BagItemLevel:Show()
                else
                    btn.BagItemLevel:Hide()
                end
            end
        end
    end
end