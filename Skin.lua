local _, ns = ...

-- Icon art has a rounded border baked into the image itself, so cropping the
-- outer edge is what actually makes a slot look square.
local ZOOM = 0.08
local EDGE = 1 -- thickness of the quality outline, in pixels

local FILL   = { 0.11, 0.11, 0.11, 0.90 } -- flat slot background
local BORDER = { 0.24, 0.24, 0.24, 1.00 } -- outline for an empty or Common slot

local db

-- Blizzard's beveled slot frame, its rounded quality ring, and the slot art we
-- add to our own reagent buttons. Faded as a group so the toggle can put the
-- whole vanilla look back without tracking what each piece was doing.
local function SetVanillaArtAlpha(button, alpha)
    -- The slot art is a parentKey texture rather than the button's registered
    -- normal texture, so GetNormalTexture() returns nil and misses it. The
    -- field is the one that actually resolves.
    if button.NormalTexture then button.NormalTexture:SetAlpha(alpha) end

    local normal = button.GetNormalTexture and button:GetNormalTexture()
    if normal then normal:SetAlpha(alpha) end

    if button.IconBorder then button.IconBorder:SetAlpha(alpha) end
    if button.IconOverlay then button.IconOverlay:SetAlpha(alpha) end
    if button.SlotBackground then button.SlotBackground:SetAlpha(alpha) end
    if button.BCBSlot then button.BCBSlot:SetAlpha(alpha) end
end

-- Retail masks item icons to round their corners, so cropping the texcoords is
-- not enough on its own. Tracked per button because the mask must only be added
-- back once, not on every bag update.
local function SetIconMasked(button, masked)
    local current = button.BCBMasked
    if current == nil then current = true end
    if current == masked then return end

    local icon, mask = button.icon or button.Icon, button.IconMask
    if not (mask and icon and icon.RemoveMaskTexture) then return end

    if masked then
        icon:AddMaskTexture(mask)
        mask:Show()
    else
        icon:RemoveMaskTexture(mask)
        mask:Hide()
    end

    button.BCBMasked = masked
end

-- Both live at the top of BACKGROUND rather than the bottom. Blizzard draws the
-- slot art in that same layer and does not expose it under any one reliable
-- name, so painting over it is far more dependable than hunting for the region
-- and hiding it. The icon sits in a layer above BACKGROUND, so a high sublevel
-- still leaves the item itself on top.
local function GetSkin(button)
    local edge = button.BCBEdge

    if not edge then
        -- Edge behind fill, so only the one pixel it sticks out by is visible.
        edge = button:CreateTexture(nil, "BACKGROUND", nil, 6)
        edge:SetPoint("TOPLEFT", -EDGE, EDGE)
        edge:SetPoint("BOTTOMRIGHT", EDGE, -EDGE)
        button.BCBEdge = edge

        local fill = button:CreateTexture(nil, "BACKGROUND", nil, 7)
        fill:SetAllPoints()
        fill:SetColorTexture(FILL[1], FILL[2], FILL[3], FILL[4])
        button.BCBFill = fill
    end

    return edge, button.BCBFill
end

function ns.SkinButton(button, quality)
    local icon = button.icon or button.Icon
    if not icon then return end

    if not db.flatButtons then
        if button.BCBEdge then
            button.BCBEdge:Hide()
            button.BCBFill:Hide()
        end

        icon:SetTexCoord(0, 1, 0, 1)
        SetIconMasked(button, true)
        SetVanillaArtAlpha(button, 1)
        return
    end

    icon:SetTexCoord(ZOOM, 1 - ZOOM, ZOOM, 1 - ZOOM)
    SetIconMasked(button, false)
    SetVanillaArtAlpha(button, 0)

    local edge, fill = GetSkin(button)
    if quality and quality > Enum.ItemQuality.Common then
        local r, g, b = C_Item.GetItemQualityColor(quality)
        edge:SetColorTexture(r, g, b, 1)
    else
        edge:SetColorTexture(BORDER[1], BORDER[2], BORDER[3], BORDER[4])
    end

    edge:Show()
    fill:Show()
end

function ns.InitSkin()
    db = ns.db
end
