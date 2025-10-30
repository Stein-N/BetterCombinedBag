BagButtons = {}

local _emptySlot = 4701874
local _textureString = "interface/professions/professionsqualityicons"
local _textureCords = {
    [1] = {0.56, 0.82, 0.29, 0.50},
    [2] = {0.29, 0.54, 0.52, 0.74},
    [3] = {0.29, 0.54, 0.75, 0.97}
}

function BagButtons.CreateReagentsButtons(buttonCache)
    if next(buttonCache) then return end

    for i = 1, BagCache.GetBagSize(5) do
        local b = CreateFrame("ItemButton", "BetterCombinedBagsSlot"..i, ContainerFrameCombinedBags, "ContainerFrameItemButtonTemplate")
        b:SetSize(36, 36)
        b:SetBagID(5)
        b:SetID(i)
        b:UpdateNewItem()
        b:Hide()

        local matOverlay = b:CreateTexture(nil, "OVERLAY", nil, 7)
        matOverlay:SetSize(33, 28)
        matOverlay:SetPoint("TOPLEFT", b, "TOPLEFT", -4, 2)
        b.MatOverlay = matOverlay

        local searchOverlay = b:CreateTexture(nil, "OVERLAY", nil, 6)
        searchOverlay:SetAllPoints()
        searchOverlay:SetColorTexture(0, 0, 0, 0.8)
        searchOverlay:Hide()
        b.SearchOverlay = searchOverlay

        buttonCache[i] = b
    end
end

function BagButtons.UpdateBaseInformation()
    for i = 1, BagCache.GetBagSize(5) do
        local btn = _G["BetterCombinedBagsSlot"..i]
        if btn then
            local info = BagCache.GetItemInfo(5, i)
            if info then
                btn:SetItemButtonTexture(info.iconFileID)
                btn:SetItemButtonCount(info.stackCount)

                local r, g, b = C_Item.GetItemQualityColor(info.quality)
                btn.IconBorder:SetVertexColor(r, g, b)
                btn.IconBorder:Show()

                UpdateMatOverlay(btn)
            else
                btn:SetItemButtonTexture(_emptySlot)
                btn:SetItemButtonCount(nil)
                btn.IconBorder:Hide()
                btn.MatOverlay:Hide()
            end
        end
    end
end

function UpdateMatOverlay(button)
    local o = button.MatOverlay
    if o then
        local info = BagCache.GetItemInfo(button.bagID, button:GetID())
        if info then
            local tier = C_TradeSkillUI.GetItemReagentQualityByItemInfo(info.itemID)
            button.MatOverlay:SetTexture(_textureString)
            button.MatOverlay:SetTexCoord(GetTexCoord(tier))
            button.MatOverlay:Show()
        end
    end
end

function GetTexCoord(tier)
    local c = _textureCords[tier]
    return c[1], c[2], c[3], c[4]
end