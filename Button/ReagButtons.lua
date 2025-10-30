ReagButtons = {}

local _buttons = {}
local baseTex = 4701874

function ReagButtons:CreateReagentsButtons()
    if next(_buttons) ~= nil then return end

    for slot = 1, 38 do
        local b = CreateFrame("ItemButton", "BetterCombinedBagReagSlot"..slot, ContainerFrameCombinedBags, "ContainerFrameItemButtonTemplate")
        b:SetSize(36, 36)
        b:SetBagID(5)
        b:SetID(slot)
        b:UpdateNewItem()
        --"interface/professions/professionsqualityicons/Professions-Icon-Quality-Tier3-Inv"

        local overlay = b:CreateTexture(nil, "OVERLAY")  -- Overlay ist oberste Ebene
        overlay:SetSize(33, 28)  -- Größe des Overlays
        overlay:SetPoint("TOPLEFT", b, "TOPLEFT", -4, 4)
        overlay:SetTexture("interface/professions/professionsqualityicons")
        overlay:SetTexCoord(0.28, 0.54, 0.75, 0.97)
        overlay:Show()

        _buttons[slot] = b
    end
end

function ReagButtons:GetReagButtons()
    return _buttons
end

function ReagButtons:GetReagButton(slot)
    return _buttons[slot]
end

function ReagButtons:UpdateButtons()
    for slot = 1, 38 do
        local button = _buttons[slot]
        local itemInfo = C_Container.GetContainerItemInfo(5, slot)

        ReagButtons:SetItemBorder(button, itemInfo)
        ReagButtons:SetIcon(button, itemInfo)
        ReagButtons:SetStackCount(button, itemInfo)
    end
end

function ReagButtons:SetMaterialQualityItem(slot) end
function ReagButtons:SetSearchState(slot) end

function ReagButtons:SetStackCount(button, info)
    if info then
        button:SetItemButtonCount(info.stackCount)
    else
        button:SetItemButtonCount(nil)
    end
end

function ReagButtons:SetIcon(button, info)
    if info then
        button:SetItemButtonTexture(info.iconFileID)
    else
        button:SetItemButtonTexture(baseTex)
    end
end

function ReagButtons:SetItemBorder(button, info)
    if info then
        local r, g, b = C_Item.GetItemQualityColor(info.quality)
        button.IconBorder:SetVertexColor(r, g, b)
        button.IconBorder:Show()
    else
        button.IconBorder:Hide()
    end
end