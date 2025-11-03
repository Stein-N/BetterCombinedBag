BagEvents = {}
local handler = {}

function BagEvents.OnEvent(event, ...)
    local func = handler[event]
    if func then return func(...) end
end

function handler.ADDON_LOADED(name)
    if name == BagData.addonName then
        BagMenu.BuildOptionsMenu()
        BagUtils.UpdateSettings()
    end
end

function handler.PLAYER_EQUIPMENT_CHANGED()
    BagCache.UpdateBagSlots()
end

function handler.PLAYER_ENTERING_WORLD()
    BagCache.UpdateBagSlots()
    BagCache.CacheBagItems()
end

function handler.BAG_UPDATE_DELAYED()
    if BCB_Settings["Bag_Toggle"] then
        BagCache.CacheBagItems()
        BagUtils.UpdateItemLevel()
        BagButtons.UpdateBaseInformation()
    end
end

function handler.ITEM_LOCK_CHANGED(bagId, slot)
    if BCB_Settings["Bag_Toggle_Reagents_Bag"] then
        if bagId == Enum.BagIndex.ReagentBag then
            local info = C_Container.GetContainerItemInfo(bagId, slot)
            if info then
                local btn = _G["BetterCombinedBagsSlot"..slot]
                if btn then btn.icon:SetDesaturated(info.isLocked) end
            end
        end
    end
end

function handler.INVENTORY_SEARCH_UPDATE()
    if BCB_Settings["Bag_Toggle_Reagents_Bag"] then
        local box = _G["BagItemSearchBox"]
        if not box then return end

        local s = string.lower(box:GetText())
        for i = 1, BagCache.GetBagSize(5) do
            local btn = _G["BetterCombinedBagsSlot"..i]
            if not btn then return end

            local info = BagCache.GetItemInfo(5, i)
            if not info then return end

            local name = string.lower(info.itemName)
            if string.find(name, s) then
                btn.SearchOverlay:Hide()
            else
                btn.SearchOverlay:Show()
            end
        end
    end
end