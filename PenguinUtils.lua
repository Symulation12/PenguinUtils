--[[
IDEAS!
Refrigerator based text based adventure.





]]




--PenguinUtilVars (name of my saved variable)
local pf = CreateFrame("Frame") -- Frame for registering events

local ADDON, Addon = ... -- ADDON is name of Addon
--Addon is table that can pass variables through files

--Variables
local autoReady = true
local raritymin = 3 --If trash isn't expensive
local sellmin = 30000 -- min price
local itemBlacklist,itemTypeBlacklist,itemSubtypeBlacklist = {},{},{}
local itemWhitelist,itemTypeWhitelist,itemSubtypeWhitelist = {},{},{}
local lootFunctions,lootChoice,lootChoiceRoll = {}, "ORIGINAL", "SINGLE_ROLL"
local whatRoll = 2
--Helper functions
local function rsend(str)
	SendChatMessage(str,"CHANNEL","COMMON",GetChannelName("Refrigerator"))
end
local function split(str)
	output = {}
	for i in string.gmatch(str,"%S+") do
		table.insert(output,i)
	end
	return output
end

local function doLoot(slot) 
	LootSlot(slot)
	ConfirmLootSlot(slot)
end
local function mprint(msg)
	print(msg)
	ChatFrame3:AddMessage(msg)
end
local function tcontains(t,value)
	for k,v in pairs(t) do
		if v==value then
			return true
		end
	end
	return false

end

--Event functions
pf["Initialize"] = function () -- Calls upon logging in
end

pf["READY_CHECK"] = function()
	if autoReady then
		ConfirmReadyCheck(true)
	end
end
--[[
Notes about this event
1 = Registered frame
2 = Triggering event
3 = Msg
4 = Sender with server extension
5 = ?
6 = Channel name with number (#.name)
7 = Sender name without extension
8 = ?
9 = ? (Also channel number?)
10 = Channel number
11 = channel name
12 = ?
13 = ?
14 = Sender GUID?
15-18 = ?

]]
pf["CHAT_MSG_CHANNEL"] = function(...)
	local Targs = {...}
	if(Targs[11] == "Refrigerator") then
		if(Targs[3]:sub(1,1) == "?") then -- Wizard command
			local input = string.lower(Targs[3]:sub(2,-1))
			local args = split(input)
			if args[1] == "running" then
				rsend("Yes, and you better go catch it")
			end
		end
		
		
	end
	

end
--[[
1: Registered table
2: Triggering event
3: ?
4: Name + server
5: ?
6: #+channel
7:?
8:?
9:?
10: Channel number
11:Channel name
12:?
13:?
14:Trigger player guid
15-18:?

]]
pf["CHAT_MSG_CHANNEL_JOIN"] = function(...)
	local args = {...}
end
pf["CHAT_MSG_CHANNEL_LEAVE"] = function(...)
	local args = {...}
end

--[[

	New concept for looting
	A table consisting of different "modes"
	Each mode will have a function that is passed the item data, and returns a boolean representing whether to take it or not
	Alt still ignores
	
	i is loot slot
]]
lootFunctions["ORIGINAL"] = function (i) 
	local _,_,quantity,_,locked = GetLootSlotInfo(i)
	outputString = fn
	if quantity==0 then
		return true
	elseif IsFishingLoot() then
		return true
	elseif not locked then
		-- Does the item have a link?
		if(GetLootSlotLink(i) == nil) then --If no, then it must be something I want
			return true
		end
		local lootitem = {GetItemInfo(GetLootSlotLink(i))} -- Also doubles for error checking
		if #lootitem == 0 then -- Does the item not have any info? Probably how currency works
			return true
		elseif tcontains(itemWhitelist,lootitem[1]) then -- Pull it even if it doesn't match the conditions
			return true
		elseif not (tcontains(itemBlacklist,lootitem[1]) or tcontains(itemTypeBlacklist,lootitem[6]) or tcontains(itemSubtypeBlacklist,lootitem[7]))  then -- Stop if it's in the blacklist
			if LootCheckAnd then
				if ((tcontains(itemTypeWhitelist,lootitem[6]) or tcontains(itemSubtypeWhitelist,lootitem[7])) or (#itemTypeWhitelist == 0 and #itemSubtypeWhitelist == 0)) and ((lootitem[11] == nil or lootitem[11] >= sellmin) and lootitem[3] >= raritymin) then -- Pull it if it matches the conditions and is in the whitelist (unless the whitelist is empty)
					return true
				elseif lootitem[6] == "Quest" then -- or is a quest item
					return true
				else
					mprint("|cFFFF0000Yuck|r:"..(GetLootSlotLink(i)==nil and fn or GetLootSlotLink(i))) --Not looted
				end
			else
				if (lootitem[3] >= raritymin) and ((tcontains(itemTypeWhitelist,lootitem[6]) or tcontains(itemSubtypeWhitelist,lootitem[7])) or (#itemTypeWhitelist == 0 and #itemSubtypeWhitelist == 0)) then
					return true
				elseif (lootitem[11] == nil or lootitem[11] >= sellmin) then -- Worth g/e min or has no value
					return true
				elseif lootitem[6] == "Quest" then -- or is a quest item
					return true
				else
					mprint("|cFFFF0000Yuck|r:"..(GetLootSlotLink(i)==nil and fn or GetLootSlotLink(i))) --Not looted
				end
			end
		else
			mprint("|cFFFF0000Yuck|r:"..(GetLootSlotLink(i)==nil and fn or GetLootSlotLink(i))) --Not looted
		end
	else
		mprint("|cFFFF0000Yuck|r:"..(GetLootSlotLink(i)==nil and fn or GetLootSlotLink(i))) --Not looted
	end
	return false
end
-- Returns 0 to pass, 1 to need, 2 to greed, 3 to d/e
lootFunctions["SINGLE_ROLL"] = function (rollid) 
	return whatRoll
end


--[[
	 NO ARGUMENTS
	 Notes about functions
	 loot contains
	 1: Name
	 2: Link
	 3: Rarity: 0 Grey, 1 white/quest, 2 green, 3 blue, 4 epic, 5 legendary, 6 artifact, 7 heirloom
	 4: ilvl
	 5: minlevel req
	 6: type:
		Type broken down:
			Armor(Type):
				Miscellaneous(subtype)
				Cloth
				Leather
				Mail
				Plate
				Shields
				Librams
				Idols
				Totems
				Sigils
			Consumable:
				Food & Drink
				Potion
				Elixir
				Flask
				Bandage
				Item Enhancement
				Scroll
				Other
				Consumable
			Container:
				Bag
				Enchanting Bag
				Engineering Bag
				Gem Bag
				Herb Bag
				Mining Bag
				Soul Bag
				Leatherworking Bag
			Gem:
				Blue
				Green
				Orange
				Meta
				Prismatic
				Purple
				Red
				Simple
				Yellow
			Key:
				Key
			Miscellaneous:
				Junk
				Reagent
				Pet
				Holiday
				Mount
				Other
			Money:
				Badges and linkable items etc.
			Reagent:
				Reagent
			Recipe:
				Alchemy
				Blacksmithing
				Book
				Cooking
				Enchanting
				Engineering
				First Aid
				Leatherworking
				Tailoring
			Projectile:
				Arrow
				Bullet
			Quest:
				Quest
			Quiver:
				Ammo Pouch
				Quiver
			Trade Goods:
				Armor Enchantment
				Cloth
				Devices
				Elemental
				Enchanting
				Explosives
				Herb
				Jewelcrafting
				Leather
				Materials
				Meat
				Metal & Stone
				Other
				Parts
				Trade Goods
				Weapon Enchantment
			Weapon:
				Bows
				Crossbows
				Daggers
				Guns
				Fishing Poles
				Fist Weapons
				Miscellaneous
				One-Handed Axes
				One-Handed Maces
				One-Handed Swords
				Polearms
				Staves
				Thrown
				Two-Handed Axes
				Two-Handed Maces
				Two-Handed Swords
				Wands
	 7: Subtype, see above
	 8: stackcount: Max stack size
	 9: Equiploc: where it can be equipped, empty if not equippable
	 10:texture: string of texture location
	 11:sellprice: Value in copper
	 
	 What kind of loot I search for
	 
]]
pf["LOOT_OPENED"] = function(...)
	if not IsAltKeyDown() then
		
		for i=1,GetNumLootItems() do
			if lootFunctions[lootChoice](i) then 
				doLoot(i)
			end
		end	
		CloseLoot()
	end
end
--[[
	Notes:
	1: Frame
	2: Event
	3: ID
	4: Time roll will be active
	5: ?
	
	I'll just use the same functions to determine whether I want it or not
]]
pf["START_LOOT_ROLL"] = function(...)
	_,_,rollid,_,_ = ...
	RollOnLoot(rollid,lootFunction[lootChoiceRoll](rollid))
	
	
	
end
pf:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		self:UnregisterEvent(event)
		self:Initialize()
	else
		self[event](self, event, ...)
	end
end)

-- Slash Command
SLASH_PENGUINUTILS1,SLASH_PENGUINUTILS2 = "/pu","/penguinutils"
SlashCmdList["PENGUINUTILS"] = function(argString,editbox)
	local args = {}
	for x in argString:gmatch("%S+") do
		newthing = string.gsub(x,"~"," ")
		table.insert(args,newthing)
	end
	if(args[2] == nil) then
		if args[1] == "srm" then
			mprint("Rarity:"..raritymin)
		elseif args[1] == "ssm" then
			mprint("Sell:"..sellmin)
		elseif args[1] == "aib" then
			mprint("--------ItemBlacklist----------")
			for k,v in pairs(itemBlacklist) do
				mprint(k..":"..tostring(v))
			end
			mprint("--------------------------------")
		elseif args[1] == "aitb" then
			mprint("--------ItemTypeBlacklist----------")
			for k,v in pairs(itemTypeBlacklist) do
				mprint(k..":"..tostring(v))
			end
			mprint("--------------------------------")
		elseif args[1] == "aistb" then
			mprint("--------ItemSubtypeBlacklist----------")
			for k,v in pairs(itemSubtypeBlacklist) do
				mprint(k..":"..tostring(v))
			end
			mprint("--------------------------------")
		elseif args[1] == "aiw" then
			mprint("--------ItemWhitelist----------")
			for k,v in pairs(itemWhitelist) do
				mprint(k..":"..tostring(v))
			end
			mprint("--------------------------------")
		elseif args[1] == "aitw" then
			mprint("--------ItemTypeWhitelist----------")
			for k,v in pairs(itemTypeWhitelist) do
				mprint(k..":"..tostring(v))
			end
			mprint("--------------------------------")
		elseif args[1] == "aistw" then
			mprint("--------ItemSubtypeWhitelist----------")
			for k,v in pairs(itemSubtypeWhitelist) do
				mprint(k..":"..tostring(v))
			end
			mprint("--------------------------------")
		elseif args[1] == "lc" then
			mprint("LootChoice:"..lootChoice)
		elseif args[1] == "help" then
			mprint("\nsrm: Set rarity min (0-4)\nssm: Set sell min in copper\naib: Add itemblacklist\naitb: Add itemtypeblacklist\naistb: Add itemSubtypeBlacklist\nReplace b with w for whitelist\nHelp: Displays this message")
		elseif args[1] == "wr" then
			mprint("whatRoll:"..whatRoll)
		
		else -- Don't judge me
			mprint("|cffffc0c0[5] [|r|cff0070ddLucia|r]|cffffc0c0:|r |cffffc0c0"..table.concat(args," ", 1).."|r")
		end
	else
		if args[1] == "srm" then
			raritymin = tonumber(args[2])
		elseif args[1] == "ssm" then
			sellmin = tonumber(args[2])
		elseif args[1] == "aib" then
			table.insert(itemBlacklist, args[2])
			mprint("|cFF290066Added|r:"..args[2])
		elseif args[1] == "aitb" then
			table.insert(itemTypeBlacklist,args[2])
			mprint("|cFF290066Added|r:"..args[2])
		elseif args[1] == "aistb" then
			table.insert(itemSubtypeBlacklist,args[2])
			mprint("|cFF290066Added|r:"..args[2])
		elseif args[1] == "help" then
			mprint("\nsrm: Set rarity min (0-4)\nssm: Set sell min in copper\naib: Add itemblacklist\naitb: Add itemtypeblacklist\naistb: Add itemSubtypeBlacklist\nReplace b with w for whitelist\nHelp: Displays this message")
		elseif args[1] == "aiw" then
			table.insert(itemWhitelist, args[2])
			mprint("|cFF290066Added|r:"..args[2])
		elseif args[1] == "aitw" then
			table.insert(itemTypeWhitelist,args[2])
			mprint("|cFF290066Added|r:"..args[2])
		elseif args[1] == "aistw" then
			table.insert(itemSubtypeWhitelist,args[2])
			mprint("|cFF290066Added|r:"..args[2])
		elseif args[1] == "lc" then
			lootChoice = args[2]
		elseif args[1] == "wr" then -- Note: 0 = pass, 1 = need, 2 = greed, 3 = d/e
			whatRoll = tonumber(args[2])
		else -- Don't judge me
			mprint("|cffffc0c0[5] [|r|cff0070ddLucia|r]|cffffc0c0:|r |cffffc0c0"..table.concat(args," ", 1).."|r")
		end
	end
end

--Place event registration here
pf:RegisterEvent("PLAYER_LOGIN")
pf:RegisterEvent("READY_CHECK")
pf:RegisterEvent("CHAT_MSG_CHANNEL")
pf:RegisterEvent("CHAT_MSG_CHANNEL_JOIN")
pf:RegisterEvent("CHAT_MSG_CHANNEL_LEAVE")
pf:RegisterEvent("LOOT_OPENED")
pf:RegisterEvent("START_LOOT_ROLL")