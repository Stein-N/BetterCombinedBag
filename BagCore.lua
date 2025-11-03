BCB_Settings = {}

local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("BAG_UPDATE_DELAYED")
frame:RegisterEvent("ITEM_LOCK_CHANGED")
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
frame:RegisterEvent("INVENTORY_SEARCH_UPDATE")

frame:SetScript("OnEvent", function(self, event, ...)
    BagEvents.OnEvent(event, ...)
end)

---##################################---
---##     Secure function Hooks    ##---
---##################################---

hooksecurefunc(ContainerFrameCombinedBags, "UpdateItemLayout", function(self)
    if not BCB_Settings["Bag_Toggle"] then
        BagUtils.HideItemLevelAndCustomButtons()
        return
    end

    BagUtils.UpdateCombinedBagsFrame(self)
    BagButtons.UpdateBaseInformation()
end)

hooksecurefunc(ContainerFrame6, "SetPoint", function(self)
    if not BCB_Settings["Bag_Toggle"] then return end
    if not BCB_Settings["Bag_Toggle_Reagents_Bag"] then return end

    self:ClearAllPoints()
end)

hooksecurefunc(ContainerFrameCombinedBags, "SetSearchBoxPoint", function(self)
    local box = _G["BagItemSearchBox"]

    if box then
        local cWidth, _ = self:GetSize()
        local bWidth, _ = box:GetSize()

        local x = (cWidth / 2) - (bWidth / 2)

        box:ClearAllPoints()
        box:SetPoint("TOPLEFT", self, "TOPLEFT", x, -35)
    end
end)