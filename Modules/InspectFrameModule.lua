local _, addon = ...
InspectFrameModule = {}

local slotData = {
    ["Head"] = { anchor = "LEFT", parentAnchor = "RIGHT" },
    ["Neck"] = { anchor = "LEFT", parentAnchor = "RIGHT" },
    ["Shoulder"] = { anchor = "LEFT", parentAnchor = "RIGHT" },
    ["Shirt"] = { anchor = "LEFT", parentAnchor = "RIGHT" },
    ["Chest"] = { anchor = "LEFT", parentAnchor = "RIGHT" },
    ["Waist"] = { anchor = "RIGHT", parentAnchor = "LEFT" },
    ["Legs"] = { anchor = "RIGHT", parentAnchor = "LEFT" },
    ["Feet"] = { anchor = "RIGHT", parentAnchor = "LEFT" },
    ["Wrist"] = { anchor = "LEFT", parentAnchor = "RIGHT" },
    ["Hands"] = { anchor = "RIGHT", parentAnchor = "LEFT" },
    ["Finger0"] = { anchor = "RIGHT", parentAnchor = "LEFT" },
    ["Finger1"] = { anchor = "RIGHT", parentAnchor = "LEFT" },
    ["Trinket0"] = { anchor = "RIGHT", parentAnchor = "LEFT" },
    ["Trinket1"] = { anchor = "RIGHT", parentAnchor = "LEFT" },
    ["Back"] = { anchor = "LEFT", parentAnchor = "RIGHT" },
    ["MainHand"] = { anchor = "RIGHT", parentAnchor = "LEFT" },
    ["SecondaryHand"] = { anchor = "LEFT", parentAnchor = "RIGHT" },
    ["Tabard"] = { anchor = "LEFT", parentAnchor = "RIGHT" }
}

function InspectFrameModule:SetupInspectFrame()
    local paperDoll = InspectPaperDollFrame
    if paperDoll ~= nil then
        paperDoll.AverageItemLevelComponent = paperDoll:CreateFontString(nil, "OVERLAY", "GameFontNormalOutline")
        paperDoll.AverageItemLevelComponent:SetPoint("BOTTOMLEFT", paperDoll, "BOTTOMLEFT", 7, 9)
        paperDoll.AverageItemLevelComponent:SetTextColor(1, 1, 1, 1)
        paperDoll.AverageItemLevelComponent:SetScale(1.3)
    end
end

function InspectFrameModule:UpdateAverageItemLevel()
    local paperDoll = InspectPaperDollFrame
    local inspect = InspectFrame

    if paperDoll ~= nil and inspect ~= nil then
        local unit = inspect.unit
        local level = C_PaperDollInfo.GetInspectItemLevel(unit)
        paperDoll.AverageItemLevelComponent:SetText("Avg: "..level)
        paperDoll.AverageItemLevelComponent:Show()
    end
end

function InspectFrameModule:SetupItemButtons()
    for slotName, data in pairs(slotData) do
        local btn = _G["Inspect"..slotName.."Slot"]
        local xPos = data.anchor == "LEFT" and 8 or -8
        addon.AddItemLevelComponent(btn)

        local eIcon = btn:CreateTexture(nil, "OVERLAY")
        eIcon:SetPoint("BOTTOM"..data.anchor, btn, "BOTTOM"..data.parentAnchor, xPos, 2)
        eIcon:SetTexture(7548964)
        eIcon:SetSize(15, 15)
        eIcon:Hide()

        btn.EnchantedIcon = eIcon

        btn.GemIcon1 = btn:CreateTexture(nil, "OVERLAY")
        btn.GemIcon1:SetPoint("TOP"..data.anchor, btn, "TOP"..data.parentAnchor, xPos, -2)
        btn.GemIcon1:SetSize(15, 15)
        btn.GemIcon1:Hide()

        btn.GemIcon2 = btn:CreateTexture(nil, "OVERLAY")
        btn.GemIcon2:SetPoint("TOP"..data.anchor, btn, "TOP"..data.parentAnchor, xPos * 3.1, -2)
        btn.GemIcon2:SetSize(15, 15)
        btn.GemIcon2:Hide()

        btn.GemIcon3 = btn:CreateTexture(nil, "OVERLAY")
        btn.GemIcon3:SetPoint("TOP"..data.anchor, btn, "TOP"..data.parentAnchor, xPos * 5.2, -2)
        btn.GemIcon3:SetSize(15, 15)
        btn.GemIcon3:Hide()
    end
end

function InspectFrameModule:UpdateItemButton()
    local inspect = InspectFrame

    for slotName, _ in pairs(slotData) do
        local btn = _G["Inspect"..slotName.."Slot"]
        local link = GetInventoryItemLink(inspect.unit, btn:GetID())

        -- Update Enchantment Icon
        if addon.IsItemEnchanted(link) then
            btn.EnchantedIcon:Show()
        else
            btn.EnchantedIcon:Hide()
        end

        -- Update Gems and show the correct gem Texture
        local gemData = addon.GetGemsFromItemLink(link)
        for i = 1, 3 do
            local gemIconID = gemData[i]
            local icon = btn["GemIcon"..i]
            if gemIconID ~= nil then
                icon:SetTexture(gemIconID)
                icon:Show()
            else
                icon:Hide()
            end
        end

        if BCB_Settings.showFor.inspect and link ~= nil then
            local level = addon.GetItemLevelFromItemLink(link)
            local item = Item:CreateFromItemLink(link)

            addon.UpdateItemLevelComponent(btn, level, item:GetItemQuality())
        else
            btn.ItemLevelComponent:Hide()
        end
    end
end

function InspectFrameModule:Init()
    self:SetupInspectFrame()
    self:SetupItemButtons()

    hooksecurefunc('InspectPaperDollFrame_UpdateButtons', function()
        self:UpdateAverageItemLevel()
        self:UpdateItemButton()
    end)
end

addon.AddModule(InspectFrameModule)