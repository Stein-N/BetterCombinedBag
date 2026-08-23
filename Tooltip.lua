local _, ns = ...

local LAST_BAG = Enum.BagIndex.ReagentBag -- backpack (0) through reagent bag (5)

local GetNumSlots = C_Container.GetContainerNumSlots
local GetSlotInfo = C_Container.GetContainerItemInfo

local db, me, realm

-- Reused, so building a tooltip does not allocate a table every time.
local others = {}

-- Recording -----------------------------------------------------------------

-- Item IDs are numbers and "class" is a string, so both live in one flat table
-- without colliding, which keeps the saved file small.
local function Store()
    -- Reuse the stored table instead of building a new one: this now runs on
    -- every bag update, and dropping a few hundred keys on the collector each
    -- time would be the most expensive thing the addon does.
    local entry = BCB_Inventory[me] or {}
    wipe(entry)
    entry.class = select(2, UnitClass("player"))

    -- Bags only. The bank is outside this addon's scope, so its contents are
    -- deliberately not counted.
    for bag = 0, LAST_BAG do
        for slot = 1, GetNumSlots(bag) do
            local info = GetSlotInfo(bag, slot)
            if info then
                entry[info.itemID] = (entry[info.itemID] or 0) + info.stackCount
            end
        end
    end

    BCB_Inventory[me] = entry
end

-- Display -------------------------------------------------------------------

local function AddCharacter(tooltip, key, count)
    -- Character names never contain a hyphen, but realm names do (Azjol-Nerub),
    -- so only split once.
    local name, charRealm = strsplit("-", key, 2)
    local entry = BCB_Inventory[key]
    local color = entry and RAID_CLASS_COLORS[entry.class]

    tooltip:AddDoubleLine(
            charRealm == realm and name or key, tostring(count),
            color and color.r or 1, color and color.g or 1, color and color.b or 1,
            1, 1, 1)
end

local function AddItemCounts(tooltip, data)
    if not db.itemCounts then return end
    if tooltip ~= GameTooltip and tooltip ~= ItemRefTooltip then return end

    local itemID = data and data.id
    if not itemID then return end

    wipe(others)
    for key, entry in pairs(BCB_Inventory) do
        -- Skip our own recorded entry; the live count below says the same thing
        -- without depending on a scan having landed yet.
        if key ~= me and entry[itemID] then
            others[#others + 1] = key
        end
    end

    local mine = C_Item.GetItemCount(itemID)
    if mine == 0 and #others == 0 then return end

    table.sort(others)
    tooltip:AddLine(" ")

    if mine > 0 then
        AddCharacter(tooltip, me, mine)
    end
    for i = 1, #others do
        AddCharacter(tooltip, others[i], BCB_Inventory[others[i]][itemID])
    end
end

-- Setup ---------------------------------------------------------------------

function ns.InitTooltip()
    db = ns.db
    BCB_Inventory = BCB_Inventory or {}

    -- BAG_UPDATE_DELAYED is Blizzard's own coalesced "the bags have settled"
    -- event, so one rescan per batch of changes keeps the saved copy current
    -- without any throttle of our own. The login pass seeds it.
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_LOGIN")
    f:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_LOGIN" then
            realm = GetRealmName()
            me = UnitName("player") .. "-" .. realm

            self:UnregisterEvent("PLAYER_LOGIN")
            self:RegisterEvent("BAG_UPDATE_DELAYED")
        end

        Store()
    end)

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, AddItemCounts)
end
