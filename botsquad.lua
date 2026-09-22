BotSquad.InitLocale()
local i18n = BotSquad.I18n

BotSquadDB = BotSquadDB or {}

---------------------------------------------------------------------------
-- Theme
---------------------------------------------------------------------------
local FONT     = "Fonts\\FRIZQT__.TTF"
local FONT_XS  = 8
local FONT_SM  = 9
local FONT_MD  = 10

local STYLE = {
  panelBg   = { 0.07, 0.09, 0.12, 0.80 },
  panelEdge = { 0.55, 0.62, 0.72, 0.90 },
  accent    = { 0.50, 0.66, 0.92, 1.00 },
  btnBg     = { 0.11, 0.14, 0.19, 0.88 },
  btnBgHi   = { 0.18, 0.22, 0.30, 0.92 },
  btnEdge   = { 0.42, 0.50, 0.62, 0.85 },
  btnEdgeHi = { 0.80, 0.87, 1.00, 1.00 },
  text      = { 0.86, 0.90, 0.98 },
  textDim   = { 0.62, 0.68, 0.78 },
  red       = { 0.88, 0.40, 0.40 },
  green     = { 0.45, 0.82, 0.50 },
  amber     = { 0.92, 0.78, 0.36 },
}

local BTN, GAP, PAD = 26, 2, 8

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------
local function SetPanelBackdrop(f, bg, edge)
  f:SetBackdrop({
    bgFile     = "Interface\\Buttons\\WHITE8X8",
    edgeFile   = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile       = true,
    tileSize   = 16,
    edgeSize   = 12,
    insets     = { left = 4, right = 4, top = 4, bottom = 4 },
  })
  f:SetBackdropColor(bg[1], bg[2], bg[3], bg[4])
  f:SetBackdropBorderColor(edge[1], edge[2], edge[3], edge[4])
end

local function SetBtnBackdrop(b, border)
  b:SetBackdrop({
    bgFile     = "Interface\\Buttons\\WHITE8X8",
    edgeFile   = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile       = true,
    tileSize   = 16,
    edgeSize   = 12,
    insets     = { left = 2, right = 2, top = 2, bottom = 2 },
  })
  b:SetBackdropColor(STYLE.btnBg[1], STYLE.btnBg[2], STYLE.btnBg[3], STYLE.btnBg[4])
  b:SetBackdropBorderColor(border[1], border[2], border[3], border[4])
end

local function MakeText(parent, size, color, centered)
  local t = parent:CreateFontString(nil, "OVERLAY")
  t:SetFont(FONT, size, "OUTLINE")
  t:SetTextColor(color[1], color[2], color[3])
  if centered then
    t:SetJustifyH("CENTER")
    t:SetJustifyV("CENTER")
  end
  return t
end

local function MakeButton(parent, label, opts)
  opts = opts or {}
  local w, h = opts.width or BTN, opts.height or BTN
  local border = opts.border or STYLE.btnEdge
  local color  = opts.color or STYLE.text

  local b = CreateFrame("Button", nil, parent)
  b:SetSize(w, h)

  if opts.icon then
    local tex = b:CreateTexture(nil, "BACKGROUND")
    tex:SetAllPoints()
    tex:SetTexture(opts.icon)
    local tint = opts.iconTint or { 0.75, 0.80, 0.90 }
    tex:SetVertexColor(tint[1], tint[2], tint[3], 0.45)
    b:SetNormalTexture(tex)
    b:SetHighlightTexture("Interface\\Buttons\\WHITE8X8", "ADD")
    b:GetHighlightTexture():SetVertexColor(0.55, 0.60, 0.70, 0.25)
  end

  local labelText = MakeText(b, opts.fontSize or FONT_SM, color, true)
  labelText:SetPoint("CENTER")
  labelText:SetText(label)

  SetBtnBackdrop(b, border)

  local hover = opts.hover or STYLE.btnEdgeHi
  b:SetScript("OnEnter", function(self)
    self:SetBackdropColor(STYLE.btnBgHi[1], STYLE.btnBgHi[2], STYLE.btnBgHi[3], STYLE.btnBgHi[4])
    self:SetBackdropBorderColor(hover[1], hover[2], hover[3], hover[4])
    if opts.tooltip then
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:SetText(opts.tooltip)
      GameTooltip:Show()
    end
  end)
  b:SetScript("OnLeave", function(self)
    self:SetBackdropColor(STYLE.btnBg[1], STYLE.btnBg[2], STYLE.btnBg[3], STYLE.btnBg[4])
    self:SetBackdropBorderColor(border[1], border[2], border[3], border[4])
    GameTooltip:Hide()
  end)

  if opts.onClick then
    b:SetScript("OnClick", opts.onClick)
  end
  return b
end

local function Command(cmd)
  return function()
    SendChatMessage(cmd, "SAY")
  end
end

local function Clamp(v, lo, hi)
  if v < lo then return lo elseif v > hi then return hi else return v end
end

---------------------------------------------------------------------------
-- Main frame
---------------------------------------------------------------------------
local frame = CreateFrame("Frame", nil, UIParent)
frame:SetSize(PAD * 2 + 4 * BTN + 3 * GAP, 144)
frame:SetPoint("CENTER", UIParent, "CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
SetPanelBackdrop(frame, STYLE.panelBg, STYLE.panelEdge)

local accentBar = frame:CreateTexture(nil, "ARTWORK")
accentBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -1)
accentBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -1)
accentBar:SetHeight(2)
accentBar:SetTexture(1, 1, 1)
accentBar:SetVertexColor(STYLE.accent[1], STYLE.accent[2], STYLE.accent[3], 0.8)

local title = MakeText(frame, FONT_MD, STYLE.text)
title:SetPoint("TOPLEFT", frame, "TOPLEFT", PAD, -4)
title:SetText(i18n("BotSquad"))

local function SetScale(s)
  s = Clamp(s, 0.5, 2.0)
  frame:SetScale(s)
  BotSquadDB.scale = s
end

-- Scale buttons
local function MakeScaleBtn(label)
  local b = CreateFrame("Button", nil, frame)
  b:SetSize(14, 14)
  SetBtnBackdrop(b, STYLE.btnEdge)
  local t = MakeText(b, FONT_SM, STYLE.green, true)
  t:SetPoint("CENTER")
  t:SetText(label)
  b:SetScript("OnEnter", function(self)
    self:SetBackdropBorderColor(STYLE.btnEdgeHi[1], STYLE.btnEdgeHi[2], STYLE.btnEdgeHi[3], STYLE.btnEdgeHi[4])
  end)
  b:SetScript("OnLeave", function(self)
    self:SetBackdropBorderColor(STYLE.btnEdge[1], STYLE.btnEdge[2], STYLE.btnEdge[3], STYLE.btnEdge[4])
  end)
  return b
end

local scaleUp = MakeScaleBtn("+")
scaleUp:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -PAD, -1)
scaleUp:SetScript("OnClick", function()
  SetScale(frame:GetScale() + 0.1)
end)

local scaleDown = MakeScaleBtn("-")
scaleDown:SetPoint("TOPRIGHT", scaleUp, "TOPLEFT", -2, 0)
scaleDown:SetScript("OnClick", function()
  SetScale(frame:GetScale() - 0.1)
end)

-- Drag handle (header strip) and frame drag
local function SavePosition()
  local p, _, _, x, y = frame:GetPoint()
  BotSquadDB.point = p
  BotSquadDB.x, BotSquadDB.y = x, y
end

local header = CreateFrame("Button", nil, frame)
header:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
header:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 0, -14)
header:SetScript("OnDragStart", function() frame:StartMoving() end)
header:SetScript("OnDragStop", function()
  frame:StopMovingOrSizing()
  SavePosition()
end)

frame:SetScript("OnDragStart", function() frame:StartMoving() end)
frame:SetScript("OnDragStop", function()
  frame:StopMovingOrSizing()
  SavePosition()
end)

---------------------------------------------------------------------------
-- Lookup panel
---------------------------------------------------------------------------
local lookupFrame = CreateFrame("Frame", nil, UIParent)
lookupFrame:SetSize(224, 330)
lookupFrame:SetPoint("LEFT", frame, "RIGHT", 10, 0)
lookupFrame:SetMovable(true)
lookupFrame:EnableMouse(true)
lookupFrame:RegisterForDrag("LeftButton")
SetPanelBackdrop(lookupFrame, STYLE.panelBg, STYLE.panelEdge)
lookupFrame:Hide()
lookupFrame:SetScript("OnDragStart", lookupFrame.StartMoving)
lookupFrame:SetScript("OnDragStop", lookupFrame.StopMovingOrSizing)

local lookupTitle = MakeText(lookupFrame, FONT_SM, STYLE.text)
lookupTitle:SetPoint("TOPLEFT", lookupFrame, "TOPLEFT", PAD + 2, -6)
lookupTitle:SetText(i18n("Select class:"))

local hideLookupButton = MakeButton(lookupFrame, "X", {
  width = 18, height = 18, fontSize = FONT_XS, color = STYLE.red,
  border = { 0.60, 0.32, 0.32, 0.90 },
  onClick = function() lookupFrame:Hide() end,
})
hideLookupButton:SetPoint("TOPRIGHT", lookupFrame, "TOPRIGHT", -6, -5)

local classTable = {
  ["Warrior"]      = 1,
  ["Paladin"]      = 2,
  ["Hunter"]       = 3,
  ["Rogue"]        = 4,
  ["Priest"]       = 5,
  ["Death Knight"] = 6,
  ["Shaman"]       = 7,
  ["Mage"]         = 8,
  ["Warlock"]      = 9,
  ["Druid"]        = 11,
  ["Blademaster"]  = 12,
  ["Sphynx"]       = 13,
  ["Archmage"]     = 14,
  ["Dreadlord"]    = 15,
  ["Spellbreaker"] = 16,
  ["DarkRanger"]   = 17,
  ["Necromancer"]  = 18,
  ["SeaWitch"]     = 19,
}

local classOrder = {}
for key, id in pairs(classTable) do
  classOrder[#classOrder + 1] = { key, id }
end
table.sort(classOrder, function(a, b) return a[2] < b[2] end)

local ROWS_VISIBLE = 9
local ROW_H = 26

local lookupList = CreateFrame("Frame", nil, lookupFrame)
lookupList:SetPoint("TOPLEFT", lookupFrame, "TOPLEFT", 4, -22)
lookupList:SetSize(180, ROWS_VISIBLE * ROW_H)

local scrollbar = CreateFrame("Slider", nil, lookupFrame, "UIPanelScrollBarTemplate")
scrollbar:SetPoint("TOPLEFT", lookupList, "TOPRIGHT", 8, 0)
scrollbar:SetPoint("BOTTOMLEFT", lookupList, "BOTTOMRIGHT", 8, 0)
scrollbar:SetMinMaxValues(0, math.max(#classOrder - ROWS_VISIBLE, 0))
scrollbar:SetValueStep(1)

local offset = 0

local function MakeClassButton(label)
  local b = CreateFrame("Button", nil, lookupList)
  b:SetSize(172, 22)
  b.Label = MakeText(b, FONT_XS, STYLE.text, true)
  b.Label:SetPoint("CENTER")
  b.Label:SetText(label)
  SetBtnBackdrop(b, STYLE.btnEdge)
  b:SetScript("OnEnter", function(self)
    self:SetBackdropColor(STYLE.btnBgHi[1], STYLE.btnBgHi[2], STYLE.btnBgHi[3], STYLE.btnBgHi[4])
    self:SetBackdropBorderColor(STYLE.btnEdgeHi[1], STYLE.btnEdgeHi[2], STYLE.btnEdgeHi[3], STYLE.btnEdgeHi[4])
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(self.entry and (".npcbot lookup " .. self.entry[2]) or "")
    GameTooltip:Show()
  end)
  b:SetScript("OnLeave", function(self)
    self:SetBackdropColor(STYLE.btnBg[1], STYLE.btnBg[2], STYLE.btnBg[3], STYLE.btnBg[4])
    self:SetBackdropBorderColor(STYLE.btnEdge[1], STYLE.btnEdge[2], STYLE.btnEdge[3], STYLE.btnEdge[4])
    GameTooltip:Hide()
  end)
  b:SetScript("OnClick", function(self)
    if self.entry then
      SendChatMessage(".npcbot lookup " .. self.entry[2], "SAY")
    end
  end)
  return b
end

local rows = {}
for i = 1, ROWS_VISIBLE do
  local b = MakeClassButton("")
  b:SetPoint("TOPLEFT", lookupList, "TOPLEFT", 4, -((i - 1) * ROW_H))
  rows[i] = b
end

local function UpdateRows()
  for i = 1, ROWS_VISIBLE do
    local entry = classOrder[offset + i]
    local b = rows[i]
    if entry then
      b.Label:SetText(i18n(entry[1]))
      b.entry = entry
      b:Show()
    else
      b:Hide()
    end
  end
end

scrollbar:SetScript("OnValueChanged", function(self, value)
  offset = math.floor(value + 0.5)
  UpdateRows()
end)

lookupList:EnableMouse(true)
lookupList:SetScript("OnMouseWheel", function(self, delta)
  scrollbar:SetValue(offset - delta)
end)

if #classOrder > ROWS_VISIBLE then
  scrollbar:Show()
else
  scrollbar:Hide()
end

scrollbar:SetValue(0)
UpdateRows()

-- Spawn bar
local spawnFrame = CreateFrame("Frame", nil, lookupFrame)
spawnFrame:SetPoint("BOTTOMLEFT", lookupFrame, "BOTTOMLEFT", 6, 6)
spawnFrame:SetPoint("BOTTOMRIGHT", lookupFrame, "BOTTOMRIGHT", -6, 6)
spawnFrame:SetHeight(58)
spawnFrame:SetBackdrop({
  bgFile   = "Interface\\Buttons\\WHITE8X8",
  edgeFile = "Interface\\Buttons\\WHITE8X8",
  edgeSize = 1,
  insets   = { left = 0, right = 0, top = 0, bottom = 0 },
})
spawnFrame:SetBackdropColor(0.12, 0.15, 0.20, 0.55)
spawnFrame:SetBackdropBorderColor(0.42, 0.50, 0.62, 0.85)

local spawnTitle = MakeText(spawnFrame, FONT_XS, STYLE.text)
spawnTitle:SetPoint("TOPLEFT", spawnFrame, "TOPLEFT", 6, -4)
spawnTitle:SetText(i18n("Spawn BOT ID:"))

local classInput = CreateFrame("EditBox", nil, spawnFrame, "InputBoxTemplate")
classInput:SetSize(86, 22)
classInput:SetPoint("BOTTOMLEFT", spawnFrame, "BOTTOMLEFT", 6, 8)
classInput:SetAutoFocus(false)

local buttonSpawnBot = MakeButton(spawnFrame, i18n("Spawn Bot"), {
  width = 88, height = 22, fontSize = FONT_XS,
  color = STYLE.green, border = { 0.30, 0.55, 0.35, 0.90 },
  onClick = function()
    local input = classInput:GetText()
    if input ~= "" then
      SendChatMessage(".npcbot spawn " .. input, "SAY")
      classInput:SetText("")
      classInput:ClearFocus()
    else
      print(i18n("Please enter an ID:"))
    end
  end,
})
buttonSpawnBot:SetPoint("BOTTOMRIGHT", spawnFrame, "BOTTOMRIGHT", -8, 7)

---------------------------------------------------------------------------
-- Admin panel
---------------------------------------------------------------------------
local adminFrame = CreateFrame("Frame", nil, UIParent)
adminFrame:SetSize(190, 84)
adminFrame:SetPoint("LEFT", frame, "RIGHT", 10, 0)
adminFrame:SetMovable(true)
adminFrame:EnableMouse(true)
adminFrame:RegisterForDrag("LeftButton")
SetPanelBackdrop(adminFrame, STYLE.panelBg, STYLE.panelEdge)
adminFrame:Hide()
adminFrame:SetScript("OnDragStart", adminFrame.StartMoving)
adminFrame:SetScript("OnDragStop", adminFrame.StopMovingOrSizing)

local adminTitle = MakeText(adminFrame, FONT_MD, STYLE.text)
adminTitle:SetPoint("TOPLEFT", adminFrame, "TOPLEFT", PAD, -4)
adminTitle:SetText(i18n("Admin"))

-- Generic bot id prompt
local function PromptBot(action)
  StaticPopupDialogs["BOTSQUAD_PROMPT"] = {
    text         = i18n("Enter NPCBOT ID:"),
    button1      = i18n("Ok"),
    button2      = i18n("Cancel"),
    hasEditBox   = true,
    timeout      = 0,
    whileDead    = true,
    hideOnEscape = true,
    OnAccept     = function(self)
      local id = self.editBox:GetText()
      if id ~= "" then
        ChatFrame1:AddMessage(".npcbot " .. action .. " " .. id)
        SendChatMessage(".npcbot " .. action .. " " .. id, "SAY")
      end
    end,
  }
  StaticPopup_Show("BOTSQUAD_PROMPT")
end

local function TargetOrPrompt(action)
  local t = UnitName("target")
  if UnitExists("target") and t then
    SendChatMessage(".npcbot " .. action .. " " .. t, "SAY")
  else
    PromptBot(action)
  end
end

-- Admin grid: 4 columns x 2 rows
local gridW, gridH = 42, 22
local function AddGrid(parent, rows, y)
  for i, item in ipairs(rows) do
    local b = MakeButton(parent, i18n(item.label), {
      width    = gridW,
      height   = gridH,
      fontSize = FONT_XS,
      color    = item.color,
      border   = item.border,
      tooltip  = item.tooltip,
      onClick  = item.onClick,
    })
    b:SetPoint("TOPLEFT", parent, "TOPLEFT", PAD + (i - 1) * (gridW + GAP), y)
  end
end

AddGrid(adminFrame, {
  { label = "Add",    onClick = function() TargetOrPrompt("add") end,                  tooltip = ".npcbot add" },
  { label = "Remove", onClick = function() TargetOrPrompt("remove") end,               tooltip = ".npcbot remove" },
  { label = "Recall", onClick = Command(".npcbot recall"),                             tooltip = ".npcbot recall" },
  { label = "Bot-Info", onClick = function()
      SendChatMessage(".npcbot info", "SAY")
      DoEmote("BONK")
    end, tooltip = ".npcbot info" },
}, -26)

AddGrid(adminFrame, {
  { label = "Move", onClick = Command(".npcbot move"), tooltip = ".npcbot move" },
  { label = "Delete", color = STYLE.red, border = { 0.60, 0.32, 0.32, 0.90 }, onClick = function()
      StaticPopupDialogs["BOTSQUAD_DELETE"] = {
        text         = i18n("Are you sure you want to delete?"),
        button1      = i18n("Yes"),
        button2      = i18n("No"),
        timeout      = 0,
        whileDead    = true,
        hideOnEscape = true,
        OnAccept     = function() TargetOrPrompt("delete") end,
      }
      StaticPopup_Show("BOTSQUAD_DELETE")
    end, tooltip = ".npcbot delete" },
  { label = "Revive", color = STYLE.green, border = { 0.30, 0.55, 0.35, 0.90 }, onClick = Command(".npcbot revive"), tooltip = i18n("Revive Bots") },
  { label = "Lookup", onClick = function()
      if lookupFrame:IsShown() then lookupFrame:Hide() else lookupFrame:Show() end
    end, tooltip = ".npcbot lookup" },
}, -50)

---------------------------------------------------------------------------
-- Main panel command buttons
---------------------------------------------------------------------------
local ROW_1, ROW_2, ROW_3 = -26, -54, -82

local function AddRow(rows, y)
  for i, item in ipairs(rows) do
    local b = MakeButton(frame, i18n(item.label), {
      icon     = item.icon,
      iconTint = item.iconTint,
      color    = item.color,
      border   = item.border,
      tooltip  = item.cmd,
      onClick  = Command(item.cmd),
    })
    b:SetPoint("TOPLEFT", frame, "TOPLEFT", PAD + (i - 1) * (BTN + GAP), y)
  end
end

AddRow({
  { label = "Follow", icon = "Interface\\Icons\\Ability_Tracking",         cmd = ".npcbot command follow" },
  { label = "Stand",  icon = "Interface\\Icons\\Inv_misc_map_01",          cmd = ".npcbot command standstill" },
  { label = "Stop",   icon = "Interface\\Icons\\Spell_chargenegative",     cmd = ".npcbot command stopfully" },
  { label = "Slack",  icon = "Interface\\Icons\\Spell_Nature_Sleep",       cmd = ".npcbot command follow only" },
}, ROW_1)

AddRow({
  { label = "UnHide", icon = "Interface\\Icons\\ability_hunter_beastcall", cmd = ".npcbot unhide" },
  { label = "Hide",   icon = "Interface\\Icons\\ability_stealth",          cmd = ".npcbot hide" },
  { label = "Recall", icon = "Interface\\Icons\\Inv_misc_rune_01",         cmd = ".npcbot recall" },
  { label = "Kill",   icon = "Interface\\Icons\\INV_Misc_Key_14",          cmd = ".npcbot kill", color = STYLE.red, border = { 0.60, 0.32, 0.32, 0.90 } },
}, ROW_2)

AddRow({
  { label = "Low",    icon = "Interface\\Icons\\Inv_misc_punchcards_red", cmd = ".npcbot distance 30", iconTint = { 0.85, 0.38, 0.38 } },
  { label = "Medium", icon = "Interface\\Icons\\Inv_misc_punchcards_red", cmd = ".npcbot distance 50", iconTint = { 0.92, 0.78, 0.36 } },
  { label = "High",   icon = "Interface\\Icons\\Inv_misc_punchcards_red", cmd = ".npcbot distance 85", iconTint = { 0.45, 0.82, 0.50 } },
}, ROW_3)

-- Footer: Revive / Admin
local footerW, footerH = 34, 22
local contentW = 4 * BTN + 3 * GAP
local footX = PAD + (contentW - (2 * footerW + 1 * GAP)) / 2

local reviveButton = MakeButton(frame, i18n("Revive"), {
  width = footerW, height = footerH,
  color = STYLE.green, border = { 0.30, 0.55, 0.35, 0.90 },
  tooltip = ".npcbot revive",
  onClick = Command(".npcbot revive"),
})
reviveButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", footX, 8)

local adminButton = MakeButton(frame, i18n("Admin"), {
  width = footerW, height = footerH,
  tooltip = "Toggle admin panel",
  onClick = function()
    if adminFrame:IsShown() then adminFrame:Hide() else adminFrame:Show() end
  end,
})
adminButton:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", footX + footerW + GAP, 8)

---------------------------------------------------------------------------
-- Restore saved state
---------------------------------------------------------------------------
local loaded = CreateFrame("Frame")
loaded:RegisterEvent("ADDON_LOADED")
loaded:SetScript("OnEvent", function(self, event, addonName)
  if addonName ~= "BotSquad" then return end
  if BotSquadDB.point then
    frame:ClearAllPoints()
    frame:SetPoint(BotSquadDB.point, UIParent, BotSquadDB.point, BotSquadDB.x or 0, BotSquadDB.y or 0)
  end
  if BotSquadDB.scale then
    frame:SetScale(BotSquadDB.scale)
  end
end)

---------------------------------------------------------------------------
-- Slash commands
---------------------------------------------------------------------------
SLASH_BOTSQUAD1 = "/botsquad"
SLASH_BOTSQUAD2 = "/nb"
SlashCmdList.BOTSQUAD = function(msg)
  msg = strlower(msg or "")
  local allHidden = function()
    frame:Hide()
    adminFrame:Hide()
    lookupFrame:Hide()
  end

  if msg == "show" then
    frame:Show()
  elseif msg == "hide" then
    allHidden()
  elseif frame:IsShown() then
    allHidden()
  else
    frame:Show()
  end
end

BotSquad.ToggleMain = function()
  if frame:IsShown() then
    frame:Hide()
    adminFrame:Hide()
    lookupFrame:Hide()
  else
    frame:Show()
  end
end
