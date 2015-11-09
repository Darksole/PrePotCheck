local enabled = true

local buffNames = {
	["Draenic Agility Potion"] = true,
	["Draenic Intellect Potion"] = true,
	["Draenic Strength Potion"] = true,
	["Draenic Armor Potion"] = true,
	["Draenic Mana Potion"] = true,
	["Draenic Channeled Mana Potion"] = true,
}

local spellNames = {
	["Draenic Agility Potion"] = true,
	["Draenic Intellect Potion"] = true,
	["Draenic Strength Potion"] = true,
	["Draenic Armor Potion"] = true,
	["Draenic Mana Potion"] = true,
	["Draenic Channeled Mana Potion"] = true,
}

local prepots, pots = {}, {}

local a = CreateFrame("Frame")
a:RegisterEvent("ZONE_CHANGED_NEW_AREA")

a:SetScript("OnEvent", function(self, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, subEvent, _, _, srcName, _, _, _, _, _, _, _, spellName = ...
		if subEvent == "SPELL_CAST_SUCCESS" and spellNames[spellName] then
			local i = UnitInRaid(srcName)
			if i then
				print("|cffff7f7fPPC:|r", srcName, "used", spellName)
				self.pots[GetUnitName("raid"..i, true)] = spellName
			end
		end

	elseif event == "PLAYER_REGEN_DISABLED" then
		print("|cffff7f7fPPC:|r Combat started")

		wipe(prepots)
		wipe(pots)

		for i = 1, GetNumGroupMembers() do
			local unit = "raid"..i
			for buff in pairs(buffNames) do
				if UnitBuff(unit, buff) then
					prepots[GetUnitName(unit, true)] = true
					break
				end
			end
		end

		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	elseif event == "PLAYER_REGEN_ENABLED" then
		print("|cffff7f7fPPC:|r Combat ended")

		local noprepots, nopots = {}, {}
		for i = 1, GetNumGroupMembers() do
			local name = GetUnitName("raid"..i, true)
			if not prepots[name] then
				tinsert(noprepots, name)
			end
			if not pots[name] then
				tinsert(nopots, name)
			end
			end
			
			if #noprepots > 0 then
				table.sort(noprepots)
				print("|cffffff00PrePotCheck:|r Players without a potion buff when combat started:", table.concat(noprepots, ", "))
			else
				print("|cffffff00PrePotCheck:|r Everyone had a potion buff when combat started.")
			end
			if #nopots > 0 then
				table.sort(nopots)
				print("|cffffff00PrePotCheck:|r Players who didn't use a potion in combat:", table.concat(nopots, ", "))
			else
				print("|cffffff00PrePotCheck:|r Everyone used a potion in combat.")
			end
			

		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	elseif event == "ZONE_CHANGED_NEW_AREA" then
		local _, instanceType = GetInstanceInfo()
		if enabled and instanceType == "raid" and GetNumGroupMembers() > 1 then
			
			
			self:RegisterEvent("PLAYER_REGEN_DISABLED")
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		else
			
			self:UnregisterEvent("PLAYER_REGEN_DISABLED")
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
	end
end)

SLASH_PREPOTCHECK1 = "/ppc"
SlashCmdList["PREPOTCHECK"] = function(cmd)
	enabled = not enabled
	print("|cffffff00PrePotCheck|r is now", enabled and "|cff00ff00enabled|r, |cff00ccffversion 2.0 loaded.|r" or "|cffff0000disabled|r")
	a:GetScript("OnEvent")(a, "ZONE_CHANGED_NEW_AREA")
end