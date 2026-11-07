-- Dvorak Forever
-- Copyright (C) 2026 Donald Morton
--
-- This program is free software: you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by the Free
-- Software Foundation, either version 3 of the License, or (at your option)
-- any later version. It is distributed WITHOUT ANY WARRANTY; see the LICENSE
-- file or <https://www.gnu.org/licenses/> for details.

-- Moves every key binding between QWERTY and Dvorak, so each action stays on
-- the same physical key when the keyboard types Dvorak. Options -> AddOns ->
-- Dvorak Forever has the dropdown; /dvorak does the same from chat.

-- The same physical keys, read as QWERTY and as Dvorak.
local QWERTY = "QWERTYUIOP[]ASDFGHJKL;'ZXCVBNM,./-="
local DVORAK = "',.PYFGCRL/=AOEUIDHTNS-;QJKXBMWVZ[]"

local TO_DVORAK, TO_QWERTY = {}, {}
for i = 1, #QWERTY do
	local q, d = QWERTY:sub(i, i), DVORAK:sub(i, i)
	TO_DVORAK[q], TO_QWERTY[d] = d, q
end

local MAPS = { DVORAK = TO_DVORAK, QWERTY = TO_QWERTY }
local NAMES = { QWERTY = "Default (QWERTY)", DVORAK = "Dvorak" }

local MODIFIERS = { "", "SHIFT-", "CTRL-", "ALT-", "CTRL-SHIFT-", "ALT-SHIFT-", "ALT-CTRL-", "ALT-CTRL-SHIFT-" }

-- Actions that belong to the character on the key, not its place: "/" starts
-- a slash command in chat. They stay on their character when that key is free.
local BY_CHARACTER = { OPENCHATSLASH = true }

local function Print(text)
	print("|cff33ccffDvorak Forever:|r " .. text)
end

-- Bindings are kept for the whole account or for one character, whichever the
-- Key Bindings screen is set to; the layout is remembered for that same set.
local function StateKey()
	if GetCurrentBindingSet() == 2 then -- 1 is account-wide, 2 is per character
		return UnitName("player") .. "-" .. GetRealmName()
	end
	return "account"
end

local function GetLayout()
	DvorakForeverDB = DvorakForeverDB or {}
	local layout = DvorakForeverDB[StateKey()]
	if layout then return layout end
	-- Nothing remembered yet (first use): the game can't tell an addon which
	-- layout the keyboard types, so read it from the movement bindings. Each
	-- one found on its Dvorak key counts for Dvorak, on its QWERTY key for QWERTY.
	local dvorak, qwerty = 0, 0
	for action, keys in pairs({ MOVEFORWARD = { "W", "," }, MOVEBACKWARD = { "S", "O" }, STRAFERIGHT = { "D", "E" } }) do
		local k1, k2 = GetBindingKey(action)
		for _, k in ipairs({ k1, k2 }) do
			if k == keys[1] then qwerty = qwerty + 1 elseif k == keys[2] then dvorak = dvorak + 1 end
		end
	end
	return dvorak > qwerty and "DVORAK" or "QWERTY"
end

local function Convert(map)
	local old = {}
	for key in pairs(map) do
		for _, mod in ipairs(MODIFIERS) do
			local action = GetBindingAction(mod .. key, false)
			if action and action ~= "" then
				old[#old + 1] = { mod = mod, key = key, action = action }
			end
		end
	end

	local new = {}
	for _, b in ipairs(old) do
		new[b.mod .. map[b.key]] = b.action
	end
	for _, b in ipairs(old) do
		if BY_CHARACTER[b.action] and not new[b.mod .. b.key] then
			new[b.mod .. map[b.key]] = nil
			new[b.mod .. b.key] = b.action
		end
	end

	for _, b in ipairs(old) do
		SetBinding(b.mod .. b.key)
	end
	for combo, action in pairs(new) do
		SetBinding(combo, action)
	end
	SaveBindings(GetCurrentBindingSet())
	return #old
end

local dropdown

local function SetLayout(layout)
	if layout == GetLayout() then
		Print("bindings are already " .. NAMES[layout] .. ".")
	elseif InCombatLockdown() then
		Print("key bindings can't be changed during combat; try again afterwards.")
	else
		local moved = Convert(MAPS[layout])
		DvorakForeverDB[StateKey()] = layout
		Print(("switched to %s (%d bindings moved)."):format(NAMES[layout], moved))
	end
	if dropdown then dropdown:GenerateMenu() end
end

-- Key test: prints the name the game gives each key press, to check that the
-- punctuation keys arrive under the names this addon binds.
local tester = CreateFrame("Frame")
tester:Hide()
tester:SetScript("OnKeyDown", function(_, key)
	if key:find("SHIFT$") or key:find("CTRL$") or key:find("ALT$") then return end
	local mod = (IsAltKeyDown() and "ALT-" or "") .. (IsControlKeyDown() and "CTRL-" or "") .. (IsShiftKeyDown() and "SHIFT-" or "")
	local action = GetBindingAction(mod .. key)
	Print(("key %s -> %s"):format(mod .. key, action ~= "" and action or "(nothing)"))
end)

local function ToggleKeyTest()
	if tester:IsShown() then
		tester:Hide()
		tester:EnableKeyboard(false)
		Print("key test off.")
	elseif InCombatLockdown() then
		Print("the key test can't start during combat.")
	else
		tester:EnableKeyboard(true)
		tester:SetPropagateKeyboardInput(true)
		tester:Show()
		Print("key test on: each key press is printed. Type /dvorak keys again to stop.")
	end
end

local panel = CreateFrame("Frame")
local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Dvorak Forever")

local notes = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
notes:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
notes:SetPoint("RIGHT", -16, 0)
notes:SetJustifyH("LEFT")
notes:SetText("Moves every key binding to the key in the same place on a Dvorak keyboard, or back. "
	.. "Changes the binding set the Key Bindings screen uses. Works only out of combat.\n\n"
	.. "/dvorak dvorak, /dvorak qwerty: switch from chat\n/dvorak keys: print each key press, to test keys")

local label = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
label:SetPoint("TOPLEFT", notes, "BOTTOMLEFT", 0, -20)
label:SetText("Keyboard layout")

dropdown = CreateFrame("DropdownButton", nil, panel, "WowStyle1DropdownTemplate")
dropdown:SetPoint("LEFT", label, "RIGHT", 16, 0)
dropdown:SetWidth(180)
dropdown:SetupMenu(function(_, root)
	for _, layout in ipairs({ "QWERTY", "DVORAK" }) do
		root:CreateRadio(NAMES[layout], function() return GetLayout() == layout end, function() SetLayout(layout) end)
	end
end)
panel:SetScript("OnShow", function() dropdown:GenerateMenu() end)

local category = Settings.RegisterCanvasLayoutCategory(panel, "Dvorak Forever")
Settings.RegisterAddOnCategory(category)

SLASH_DVORAKFOREVER1 = "/dvorak"
SlashCmdList.DVORAKFOREVER = function(arg)
	arg = arg:lower():match("^%s*(.-)%s*$")
	if arg == "dvorak" then
		SetLayout("DVORAK")
	elseif arg == "qwerty" or arg == "default" then
		SetLayout("QWERTY")
	elseif arg == "keys" then
		ToggleKeyTest()
	else
		Print("bindings are " .. NAMES[GetLayout()] .. ". /dvorak dvorak, /dvorak qwerty, /dvorak keys")
		Settings.OpenToCategory(category:GetID())
	end
end
