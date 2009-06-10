
-- Delete any of the four lines below to stop Peek from watching that channel.

local party = true
local raid  = true
local guild = true
local tells = true
local custom = true

local showoutput = true -- Delete this line if you want to hide your own output.

local addon = CreateFrame("Button", "Peek_Smee", UIParent)
			addon.playerTrades = nil
			addon:RegisterEvent"ADDON_LOADED"
			addon:RegisterEvent"PLAYER_LOGOUT"
--			addon:RegisterEvent("TRADE_SKILL_SHOW")
--			addon:RegisterEvent("TRADE_SKILL_UPDATE")
	  
if party then addon:RegisterEvent"CHAT_MSG_PARTY"   end
if raid  then addon:RegisterEvent"CHAT_MSG_RAID"    end
if guild then addon:RegisterEvent"CHAT_MSG_GUILD"   end
if tells then addon:RegisterEvent"CHAT_MSG_WHISPER" end
if custom then addon:RegisterEvent"CHAT_MSG_CHANNEL" end

function addon.Print(msg,isError)
	_G['ChatFrame'..addon.database.outputFrame]:AddMessage("|cff33ff99Peek:|r "..tostring((isError~=nil) and "|cffff0000Error:|r "..msg or msg))
end

addon:SetScript("OnEvent", function() 
	local event = event:lower()
	if(addon[event])then addon[event]() end
end)
addon.CheckClassMeetsFilter={
	class = function(var) return addon.charDatabase.playerClass:lower()==var end,
    rank = function(var) 
       local guildName,rankName,rank = GetGuildInfo("player")
       if(type(var)=='string') then return var==rankName
        elseif(type(var)=='number')then return var==rank
        else return false end
    end,
}
addon.db = {
		list             = function()
			local list = {
				"amount-[Item Name]: Item Count, Bags",
				"amount-[Item Name] andbank: Item Count, Bags and Bank",
				"objectives-[Quest Name]: Quest Objectives Information",
				"reputation-[Faction Name]: Faction Reputation Status",
				"durability: Averaged Durability Per Centage",
				"armour: Effective Armour (Base Armour)",
				"maxhealth: Maximum Health by Number",
				"maxpower: Maximum Mana/Energy/Rage by Number",
				"health: Current Health by Per Centage",
				"power: Current Mana/Energy/Rage by Per Centage",
				"crweapon: Weapon Skill (Combat Rating)",
				"crdefense: Defense Skill (Combat Rating)",
				"crdodge: Dodge (Combat Rating)",
				"crparry: Parry (Combat Rating)",
				"crblock: Block (Combat Rating)",
				"crmeleehit: Melee Hit (Combat Rating)",
				"crrangedhit: Ranged Hit (Combat Rating)",
				"crspellhit: Spell Hit (Combat Rating)",
				"crmeleecrit: Melee Critical (Combat Rating)",
				"crrangedcrit: Ranged Critical (Combat Rating)",
				"crspellcrit: Spell Critical (Combat Rating)",
				"crmeleetakenhit: Melee Hits Taken (Combat Rating)",
				"crrangedtakenhit: Ranged Hits Taken (Combat Rating)",
				"crspelltakenhit: Spell Hits Taken (Combat Rating)",
				"crmeleetakencrit: Melee Crits Taken (Combat Rating)",
				"crrangedtakencrit: Ranged Crits Taken (Combat Rating)",
				"crspelltakencrit: Spell Crits Taken (Combat Rating)",
				"crmeleehaste: Melee Haste (Combat Rating)",
				"crrangedhaste: Ranged Haste (Combat Rating)",
				"crspellhaste: Spell Haste (Combat Rating)",
				"crmainhand: Mainhand Weapon Skill (Combat Rating)",
				"croffhand: Offhand Weapon Skill (Combat Rating)",
				"crranged: Ranged Weapon Skill (Combat Rating)",
				"crexpertise: Expertise (Combat Rating)",
				"head: Helmet",
				"neck: Necklace",
				"shoulders: Shoulder-Pads",
				"back: Cloak",
				"torso: Chest Armour",
				"shirt: Shirt",
				"tabard: Tabard",
				"wrists: Bracers",
				"hands: Gloves/Gauntlets",
				"waist: Belt",
				"legs: Leggings",
				"feet: Shoes/Boots",
				"fingera: Ring #1",
				"fingerb: Ring #2",
				"trinketa: Trinket #1",
				"trinketb: Trinket #2",
				"mainhand: Mainhand Weapon",
				"offhand: Offhand Weapon",
				"ranged: Ranged Weapon",
				"ammo: Ammo Type and Amount",
				"baga: Bag #1",
				"bagb: Bag #2",
				"bagc: Bag #3",
				"bagd: Bag #4",
				"xp: Current Experience Per Centage",
				"restedxp: Rested Experience Per Centage",
				"money: Current Cash",
				"spec: report basic spec",
				"heallib: report version of lib",
				"channel: enable listening for a custom channel",
				"trade: return tradebook link if have this trade",
				"saved: return list of saved dungeons/raids",
				 }
	
			if Talented then list:insert("talents: WoW Talents URL") end
	
			SendChatMessage("<Peek> List incoming...", channel, nil, arg2)
	
			for _, v in pairs(list) do SendChatMessage("<Peek> "..v..".", channel, nil, arg2) end

			db = nil return "List finished"
		end,
		amount           = function()
			local item  = arg1:gmatch("amount[-][[](.*)[]]")()
			if not item then return end

			if (string.gsub(item,".-\124H([^\124]*)\124h.*", "%1"))then
				item = string.gsub(link,"^.-%[(.*)%].*", "%1")
			end
			--[[
				local link = GetContainerItemLink(1,1)
				-- This expression extracts the name from the link (if you just need name)
				local justName = string.gsub((link,"^.-%[(.*)%].*", "%1")
				-- This expression extracts the item ID from the link
				local justItemId = string.gsub(link,".-\124H([^\124]*)\124h.*", "%1");
				-- Then get info from link (NOTE: will return nil if item is not in local cache)
				local itemName, itemLink, itemRarity, itemMinLevel, itemType, itemSubType,
					  itemStackCount, itemEquipLoc = GetItemInfo(justItemId);

			--]]

			local bank  = arg1:find("andbank") and true or nil
			local count = GetItemCount(item, bank) bank = nil

			if PeekIgnore.andbank then return "The query for andbank has been disabled." end

			if count and count > 0 then return "Amount"..(bank and " (and Bank)" or "")..": "..count end
		end,
		objectives        = function()
			local quest  = arg1:gmatch("objectives[-][[](.*)[]]")()
			quest        = GetQuestLogIndexByName("  "..quest)

			if not quest then return end

			local string

			for i = 1, GetNumQuestLeaderBoards(quest) do
				local desc = GetQuestLogLeaderBoard(i, quest)
				if desc then string = string and string..", "..desc or desc end
			end quest, desc = nil, nil return "Objectives: "..string.."."
		end,
		reputation        = function()
			local faction = arg1:gmatch("reputation[-][[](.*)[]]")()

			if not faction then return end

			local name, top, earned, _

			for i = 1, GetNumFactions() do
				name, _, _, _, top, earned = GetFactionInfo(i)

				if name == faction then name = earned.."/"..top break else name = nil end
			end

			faction, top, earned, _ = nil, nil, nil, nil

			return "Reputation: "..(name or "Unknown")
		end,
		durability        = function()
			local average, count, dura, maxdura, link, id = 0, 0

			local slots             = {}
			slots.HeadSlot          = true
			slots.ShoulderSlot      = true
			slots.ChestSlot         = true
			slots.WristSlot         = true
			slots.HandsSlot         = true
			slots.WaistSlot         = true
			slots.LegsSlot          = true
			slots.FeetSlot          = true
			slots.MainHandSlot      = true
			slots.SecondaryHandSlot = true
			slots.RangedSlot        = true

			for slot in pairs(slots) do
				link, id = nil, nil
				link, id = addon.getitemlink(slot)

				if id then
					dura, maxdura = nil, nil
					dura, maxdura = GetInventoryItemDurability(id)
					dura          = (dura / maxdura)
				end

				if dura and dura >= 0 then
					average = average + dura
					count   = count   + 1
				end
			end

			average                               = math.floor((average / count) * 100)
			slots, count, dura, maxdura, link, id = nil, nil, nil, nil, nil, nil

			return "Durability: "..average.."%"
		end,
		armour            = function()
			local base, effective = UnitArmor("player")

			return "Armour: "..effective.." ("..base..")" 
		end,
		maxhealth         = function() return "Max Health: "..UnitHealthMax("player") end,
		maxpower          = function() return "Max Power: "..UnitManaMax("player") end,
		health            = function() return "Health: "..floor(UnitHealth("player") * 100/ UnitHealthMax("player")).."%" end,
		power             = function() return "Power: "..floor(UnitMana("player") * 100/ UnitManaMax("player")).."%" end,
		crweapon          = function() return ("CR Weapon Skill: %.2f"):format(GetCombatRating(1)) end,
		crdefense         = function() return ("CR Defense Skill: %.2f"):format(GetCombatRating(2)) end,
		crdodge           = function() return ("CR Dodge: %.2f"):format(GetCombatRating(3)) end,
		crparry           = function() return ("CR Parry: %.2f"):format(GetCombatRating(4)) end,
		crblock           = function() return ("CR Block: %.2f"):format(GetCombatRating(5)) end,
		crmeleehit        = function() return ("CR Melee Hit: %.2f"):format(GetCombatRating(6)) end,
		crrangedhit       = function() return ("CR Ranged Hit: %.2f"):format(GetCombatRating(7)) end,
		crspellhit        = function() return ("CR Spell Hit: %.2f"):format(GetCombatRating(8)) end,
		crmeleecrit       = function() return ("CR Melee Critical: %.2f"):format(GetCombatRating(9)) end,
		crrangedcrit      = function() return ("CR Ranged Critical: %.2f"):format(GetCombatRating(10)) end,
		crspellcrit       = function() return ("CR Spell Critical: %.2f"):format(GetCombatRating(113)) end,
		crmeleetakenhit   = function() return ("CR Melee Hits Taken: %.2f"):format(GetCombatRating(12)) end,
		crrangedtakenhit  = function() return ("CR Ranged Hits Taken: %.2f"):format(GetCombatRating(13)) end,
		crspelltakenhit   = function() return ("CR Spell Hits Taken: %.2f"):format(GetCombatRating(14)) end,
		crmeleetakencrit  = function() return ("CR Melee Crits Taken: %.2f"):format(GetCombatRating(15)) end,
		crrangedtakencrit = function() return ("CR Ranged Crits Taken: %.2f"):format(GetCombatRating(16)) end,
		crspelltakencrit  = function() return ("CR Spell Crits Taken: %.2f"):format(GetCombatRating(17)) end,
		crmeleehaste      = function() return ("CR Melee Haste: %.2f"):format(GetCombatRating(18)) end,
		crrangedhaste     = function() return ("CR Ranged Haste: %.2f"):format(GetCombatRating(19)) end,
		crspellhaste      = function() return ("CR Spell Haste: %.2f"):format(GetCombatRating(20)) end,
		crmainhand        = function() return ("CR Weapon Skill Mainhand: %.2f"):format(GetCombatRating(21)) end,
		croffhand         = function() return ("CR Weapon Skill Offhand: %.2f"):format(GetCombatRating(22)) end,
		crranged          = function() return ("CR Weapon Skill Ranged: %.2f"):format(GetCombatRating(23)) end,
		crexpertise       = function() return ("CR Expertise: %.2f"):format(GetCombatRating(24)) end,
		head              = function() return "Head: "..addon.getitemlink("HeadSlot") end,
		neck              = function() return "Neck: "..addon.getitemlink("NeckSlot") end,
		shoulders         = function() return "Shoulders: "..addon.getitemlink("ShoulderSlot") end,
		back              = function() return "Back: "..addon.getitemlink("BackSlot") end,
		torso             = function() return "Chest: "..addon.getitemlink("ChestSlot") end,
		shirt             = function() return "Shirt: "..addon.getitemlink("ShirtSlot") end,
		tabard            = function() return "Tabard: "..addon.getitemlink("TabardSlot") end,
		wrists            = function() return "Bracers: "..addon.getitemlink("WristSlot") end,
		hands             = function() return "Hands: "..addon.getitemlink("HandsSlot") end,
		waist             = function() return "Waist: "..addon.getitemlink("WaistSlot") end,
		legs              = function() return "Legs: "..addon.getitemlink("LegsSlot") end,
		feet              = function() return "Feet: "..addon.getitemlink("FeetSlot") end,
		fingera           = function() return "Finger 1: "..addon.getitemlink("Finger0Slot") end,
		fingerb           = function() return "Finger 2: "..addon.getitemlink("Finger1Slot") end,
		trinketa          = function() return "Trinket 1: "..addon.getitemlink("Trinket0Slot") end,
		trinketb          = function() return "Trinket 2: "..addon.getitemlink("Trinket1Slot") end,
		mainhand          = function() return "Main-hand: "..addon.getitemlink("MainHandSlot") end,
		offhand           = function() return "Off-hand: "..addon.getitemlink("SecondaryHandSlot") end,
		ranged            = function() return "Ranged: "..addon.getitemlink("RangedSlot") end,
		ammo              = function() return "Ammo: "..addon.getitemlink("AmmoSlot").." x "..(GetInventoryItemCount("player", select(2, addon.getitemlink("AmmoSlot"))) or "?") end,
		baga              = function() return "Bag 1: "..addon.getitemlink("Bag0Slot") end,
		bagb              = function() return "Bag 2: "..addon.getitemlink("Bag1Slot") end,
		bagc              = function() return "Bag 3: "..addon.getitemlink("Bag2Slot") end,
		bagd              = function() return "Bag 4: "..addon.getitemlink("Bag3Slot") end,
		xp                = function() return ("XP: %.2f%%"):format(UnitXP("player") * 100/ UnitXPMax("player")) end,
		restedxp          = function() return ("Rested XP: %.2f%%"):format((GetXPExhaustion() or 0) * 100/ UnitXPMax("player")) end,
		spec	          = function() return addon.getTalentSimple(arg1:gmatch("spec (.*)")()) end,
		heallib			  = function() return addon.healCommVersion() end,
		channel			  = function() return addon.toggleChannel() end,
		trade			  = function() return addon.queryForTrade(arg1:gmatch("trade (.*)")()) end,
		roll			  = function() return addon.requestRoll(arg1:gmatch("roll (.*)")()) end,
		saved			  = function()
			local showId = arg1:gmatch("saved (id)")()
			local o, q, c = "",GetSavedInstanceInfo,GetNumSavedInstances
			if c() > 0 then 
			 for i=1,c() do
			  n,a,b,h=q(i); o = o .. (h>1 and '[h' ..(showId and ' : '..a or '')..']' or '') .. n 
			  if (i < c()) then o = o .. ", " end
			 end
			 return format("Saved to : %s",o)
			else
			 return "Not saved to any dungeons/raids"
			end    
		end,
		money             = function()
			local cash, string = floor(GetMoney() + .5), ""
			local g, s, c = floor(cash / (100 * 100)), mod(floor(cash / 100), 100), mod(floor(cash), 100)
		
			if g > 0 then string = string..g.."g " end
			if s > 0 then string = string..s.."s " end
			if c > 0 then string = string..c.."c " end
		
			g, s, c, cash = nil, nil, nil, nil

			return "Money: "..string
		end,
		talents = function() 
			loaded, reason = LoadAddOn("Talented");
			if(loaded~=nil)then
				Talented:UpdateCurrentTemplate() return Talented:ExportWowheadTemplate(Talented.current)
			else
				return "Talented could not load : [ "..reason.." ]"
			end
		end,
		}

function addon.handler()
	if not arg1:lower():find("!peek") then 
		addon.wc = event:gsub("CHAT_MSG_", "")
		if(addon.wc=="WHISPER") then 
			addon.queryAuthor = arg2
			addon.queryChannel = arg8
		end
		return
	end

	local channel = event:gsub("CHAT_MSG_", "")
	addon.queryAuthor = arg2
	addon.queryChannel = arg8
	addon.classFilter = arg1:gmatch("class (.*)")()

	if (channel == "CHANNEL" and not customChannels[arg8]) then 
		print("Channel ["..arg8.."] not being listend to")
		return
	end 

	for word in arg1:gmatch("%a+") do word = word:lower()
		if PeekIgnore[word] then
			SendChatMessage("<Peek> The query for "..word.." has been disabled.", channel, nil, arg2)
		elseif channel == "WHISPER" and word == "trade" and (arg1 == nil or arg1 =='') then
			if playerTrades~=nil then
				for index,trade in pairs(playerTrades)do
					SendChatMessage("<Peek> "..trade["link"], channel, nil, arg2)
				end
			end
		elseif addon.db[word] then
			SendChatMessage("<Peek> "..(addon.db[word]().."." or "ZOMG, bug!"), channel, nil, arg2)
		end
	end
end

function addon.healCommVersion()
	local libHealCommUrl = "http://www.wowace.com/projects/libhealcomm-3-0/files/"
	if (LibStub.libs["LibHealComm-3.0"]==nil)then
		local libHealCommVersion = "not installed";
		-- user isnt having libHealComm, check if they are required to have it.
		add.
		SendChatMessage("You need to install, libHealComm-3.0 from:"..libHealCommUrl, "WHISPER", "COMMON", UnitName("player"));
		return libHealCommVersion
	else
		local libHealComm = LibStub:GetLibrary("LibHealComm-3.0")
		local libHealCommVersion = libHealComm:GetUnitVersion("player")
		local libHealCommGroupVersions = {}
		--check if upto-date
		local highest={
			["unit"] = "player",
			["version"] = libHealCommVersion
		}
				
		if(channel == "RAID" or channel == "PARTY")then
			--request made in raid or party channel
			libHealCommGroupVersions = libHealComm:GetGuildVersions()
		elseif (channel == "GUILD")then
			--request made in guild
			libHealCommGroupVersions = libHealComm:GetRaidOrPartyVersions()
		elseif(channel=="WHISPER")then
			--request made in whisper
			libHealCommGroupVersions = {
				libHealComm:GetUnitVersion(arg2),
				libHealComm:GetUnitVersion("player"),
			}
		else
			return libHealCommVersion
		end

		for unit,version in pairs(libHealCommGroupVersions)do
			if(version > libHealCommVersion) then 
				highest["unit"] = unit
				highest["version"] = version
			end
		end
		
		if((highest.version > libHealCommVersion))then
			-- determine if upgrade needed and inform
			SendChatMessage("New version of libHealComm-3.0 available from:"..libHealCommUrl, "WHISPER", "COMMON", UnitName("player"));
		end
		return libHealCommVersion
	end
end

--addon.trade_skill_show = function() addon.scanForTrades() end
--addon.trade_skill_update = function() addon.scanForTrades() end

function addon.scanForTrades()
	local count=0
	local playerTrades = {}
    tradeskillName, currentLevel, maxLevel = GetTradeSkillLine()
    if tradeskillName then
	    print("<Peek> Updating trade : "..tradeskillName)
    	playerTrades[tradeskillName:lower()] = {
			["link"] = GetTradeSkillListLink(),
    	   	["currentLevel"] = currentLevel, 
    	   	["maxLevel"] = maxLevel
    	}
    end        
    addon.charDatabase.playerTrades = playerTrades
end

function addon.listTrade(tradeQuery)
end

function addon.requestRoll(qry)

	local RequiredToRoll = true
	
	for query in qry:gmatch("%S+") do
		for cmd,filter in query:gmatch("(.*)%-+(.*)") do
			for var in filter:gmatch("(%w+)") do
				RequiredToRoll = addon.CheckClassMeetsFilter[cmd](var)
			end
		end
	end
	
	if(RequiredToRoll)then RandomRoll(1,100) end
end

function addon.queryForTrade(tradeQuery)
	local playerTrades = addon.charDatabase.playerTrades
	if tradeQuery == nil then 
		output = ''
		for index,trade in pairs(playerTrades)do
			output = output .. trade["link"]
		end
		return output
	else
		local result = playerTrades[tradeQuery]

		if(playerTrades~=nil)then 
			if(result~=nil)then 
				return "("..result["currentLevel"].."/"..result["maxLevel"]..")"..result["link"]
			end
		else
			print("You need to run '/peekscan' to provide other with tradelinks for this query.")
		end
	end

end
function addon.toggleChannel()
	customChannel = arg1:gmatch("channel[-][[](.*)[]]")()
	addon.customChannels[customChannel] = false
	if not addon.customChannels[customChannel] then 
		addon.customChannels[customChannel] = true
	else
		addon.customChannels[customChannel] = false 
	end
end

function addon.getTalentSimple(tree)
   local p={};
    for i = 1,3 do
        p[i]=select(3,GetTalentTabInfo(i));
        v=((i==1)or(p[i]>p[v])) and i or v;
    end;
    local talentTree,_,_,_ = GetTalentTabInfo(v)
	local talentString = p[1].."/"..p[2].."/"..p[3]
   	return(talentTree .. " : " ..talentString);
end
function addon.filterClass()
	if(addon.classFilter ~= nil) and (addon.charDatabase.playerClass:lower() ~= addon.classFilter:lower()) then 
		return true
	else
		return false
	end
end
function addon.getitemlink(item)
	if(not addon.filterClass())then return end
	local slot = GetInventorySlotInfo(item)
	item = GetInventoryItemLink("player", slot)
	item = item
	if item then return item, slot end return "[None]"
end

addon.player_logout=function()
	_G["PeekDB"] = addon.database
	_G["PeekPerCharDB"] = addon.charDatabase
end

addon.addon_loaded = function()
		addon.tradeSkillList = {
			"Tailoring",
			"Alchemy",
			"Enchanting",
			"LeatherWorking",
			"BlackSmithing",
			"Jewelcrafting",
			"Engineering",
			"Inscription",
			"Cooking",
			"First Aid"
		}

		addon.database = (PeekDB~=nil and PeekDB or {});
		addon.database.customChannels = {
			[7] = true,
		}
		addon.database.outputFrame = addon.database.outputFrame or 1
		addon.charDatabase = (PeekPerCharDB~=nil and PeekPerCharDB or {});
		_,addon.charDatabase.playerClass = UnitClass("player")
	
		addon:UnregisterEvent("ADDON_LOADED")
end
do
	if party then addon.chat_msg_party   = addon.handler end
	if raid  then addon.chat_msg_raid    = addon.handler end
	if guild then addon.chat_msg_guild   = addon.handler end
	if tells then addon.chat_msg_whisper = addon.handler end
	if custom then addon.chat_msg_channel = addon.handler end
	addon.chat_msg_channel = addon.handler
	if not showoutput then
		local hooks = {}

		local addmessage = function(chat, message, ...)
			if arg2 == UnitName("player") and message and message:find("<Peek>") then return end
			hooks[chat](chat, message, ...)
		end

		for i = 1, 7 do if i ~= 2 then
			local chat      = _G["ChatFrame"..i]
			hooks[chat]     = chat.AddMessage
			chat.AddMessage = addmessage
			chat            = nil
		end end
	end
end

function addon.command(msg)
	if msg == 'scan' then 
		addon.scanForTrades()
	else
		addon.processCommand(msg,UnitName("player"))
	end	
end

function addon.processCommand(msg,target)
	local printMsg=msg:gmatch("print (.*)")()
	local replyMsg=msg:gmatch("reply (.*)")()
	local setOutputFrame=msg:gmatch("frame (.*)")()
	local msg = replyMsg and replyMsg or (printMsg and printMsg or msg)
	if(setOutputFrame~=nil)then
		addon.database.outputFrame = setOutputFrame
		addon.Print("Output frame set to  _G[ChatFrame"..addon.database.outputFrame.."]")
		return
	end
	addon.Print("searching for [".. msg.."]")
	
	if(addon.db[msg]~=nil)then			
		local output = "<Peek> "..addon.db[msg]().."."
		if printMsg~=nil then
			addon.Print(output)
		elseif replyMsg~=nil then
			if(addon.queryAuthor~=nil)then
			SendChatMessage(output, "Whisper", nil,addon.queryAuthor)
			else
				addon.Print("No message author to respond to.",true)
			end
		else
			SendChatMessage(output, "Whisper", nil,target)
		end
	else
		addon.Print("Word not found",true)
	end
end
--[[
"CHAT_MSG_CHANNEL"
 #Fired when the client receives a channel message.
arg1		: chat message 
arg2		: author 
arg3		: language 
arg4	: channel name with number ex: "1. General - Stormwind City" 
			    * zone is always current zone even if not the same as the channel name 
arg5		: target 
			    * second player name when two users are passed for a CHANNEL_NOTICE_USER (E.G. x kicked y) 
arg6		: AFK/DND/GM "CHAT_FLAG_"..arg6 flags 
arg7 	: zone ID used for generic system channels (1 for General, 2 for Trade, 22 for LocalDefense, 23 for WorldDefense and 26 for LFG) 
			    * not used for custom channels or if you joined an Out-Of-Zone channel ex: "General - Stormwind City" 
arg8 	: channel number 
arg9 	: channel name without number (this is _sometimes_ in lowercase) 
			    * zone is always current zone even if not the same as the channel name 
--]]
SLASH_PEEK1 = "/peek";
SlashCmdList["PEEK"] = addon.command;
