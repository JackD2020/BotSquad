--------------------------------------------------------------------------
-- Minimap toggle button
--------------------------------------------------------------------------
local mm = CreateFrame("Button", "BotSquadMinimapButton", Minimap)
mm:SetFrameStrata("MEDIUM")
mm:SetFrameLevel(8)
mm:SetWidth(31)
mm:SetHeight(31)
mm:RegisterForDrag("LeftButton")
mm:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

local ring = mm:CreateTexture(nil, "OVERLAY")
ring:SetWidth(53)
ring:SetHeight(53)
ring:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
ring:SetPoint("TOPLEFT")

local icon = mm:CreateTexture(nil, "BACKGROUND")
icon:SetWidth(20)
icon:SetHeight(20)
icon:SetTexture("Interface\\Icons\\Ability_Tracking")
icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
icon:SetPoint("TOPLEFT", 7, -5)

local function Round()
  icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
end

local function Position(angle)
  local rad = math.rad(angle)
  local cos, sin = math.cos(rad), math.sin(rad)
  local shape = GetMinimapShape and GetMinimapShape() or "ROUND"
  local x, y
  if shape == "ROUND" or shape == "SQUARE" then
    x, y = cos * 80, sin * 80
  elseif shape == "SIDE-LEFT" then
    x, y = math.max(-82, math.min(110 * cos, 84)), math.max(-86, math.min(110 * sin, 82))
  elseif shape == "SIDE-RIGHT" then
    x, y = math.max(-82, math.min(110 * cos, 84)), math.max(-86, math.min(110 * sin, 82))
  elseif shape == "SIDE-TOP" then
    x, y = math.max(-82, math.min(110 * cos, 84)), math.max(-86, math.min(110 * sin, 82))
  elseif shape == "SIDE-BOTTOM" then
    x, y = math.max(-82, math.min(110 * cos, 84)), math.max(-86, math.min(110 * sin, 82))
  else
    x, y = cos * 80, sin * 80
  end
  mm:ClearAllPoints()
  mm:SetPoint("CENTER", x, y)
end

local function CursorAngle()
  local mx, my = Minimap:GetCenter()
  local px, py = GetCursorPosition()
  local scale = Minimap:GetEffectiveScale()
  px, py = px / scale, py / scale
  return math.deg(math.atan2(py - my, px - mx))
end

mm:SetScript("OnDragStart", function()
  mm:SetScript("OnUpdate", function()
    Position(CursorAngle())
  end)
end)

mm:SetScript("OnDragStop", function()
  mm:SetScript("OnUpdate", nil)
  BotSquadDB.minimapAngle = CursorAngle()
  Position(BotSquadDB.minimapAngle)
end)

mm:SetScript("OnClick", function()
  BotSquad.ToggleMain()
end)

mm:SetScript("OnMouseDown", function()
  icon:SetTexCoord(0, 1, 0, 1)
end)

mm:SetScript("OnMouseUp", function()
  Round()
end)

mm:SetScript("OnEnter", function()
  GameTooltip:SetOwner(mm, "ANCHOR_TOPRIGHT")
  GameTooltip:SetText("BotSquad", 1, 1, 1)
  GameTooltip:AddLine("Click: toggle panel", 1, 1, 1)
  GameTooltip:AddLine("Drag: move around minimap", 1, 1, 1)
  GameTooltip:Show()
end)

mm:SetScript("OnLeave", function()
  GameTooltip:Hide()
end)

Position(BotSquadDB and BotSquadDB.minimapAngle or 135)