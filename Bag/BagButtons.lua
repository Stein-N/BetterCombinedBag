BagButtons = {}

local _emptySlot = 4701874

function BagButtons.CreateReagentsButtons(buttonCache)
    if next(buttonCache) then return end

    for i = 1, BagCache.GetBagSize(5) do
        local b = CreateFrame("ItemButton", "BetterCombinedBagsSlot"..i, ContainerFrameCombinedBags, "ContainerFrameItemButtonTemplate")
        b:SetSize(36, 36)
        b:SetBagID(5)
        b:SetID(i)
        b:UpdateNewItem()
        b:Show()

        buttonCache[i] = b
    end
end

