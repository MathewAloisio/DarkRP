umsg.PoolString("openBank")
util.AddNetworkString("networkBank")
local bankers = bankers or {}
hook.Add("InitPostEntity", "BANK::LoadBankers", function()
		if file.Exists("roleplay/economy/bankers/"..game.GetMap()..".txt", "DATA") then
			local tbl = pon.decode(file.Read("roleplay/economy/bankers/"..game.GetMap()..".txt", "DATA"))
			for _, v in pairs(tbl) do
				local ent = ents.Create("npc_generic")
				ent:SetPos(v.pos)
				ent:SetAngles(v.ang)
				ent.m_Name = "Banker"
				ent:SetNWString("NPCName","Banker")
				ent:SetModel("models/barney.mdl")
				ent:Spawn()
				ent:EnableChat()
				table.insert(bankers, ent)
			end
		end
end)

local function saveBankers()
	local tbl = {}
	for i, v in pairs(bankers) do
		tbl[i] = {
			pos = v:GetPos(),
			ang = v:GetAngles()
		}
	end
	file.Write("roleplay/economy/bankers/"..game.GetMap()..".txt", pon.encode(tbl))
end

concommand.Add("rp_addbanker", function(player, cmd, args)
	if not player:IsDev() then DarkRP.notify(player, 1, 4, "This command can only be used by developers.") return end
	local ent = ents.Create("npc_generic")
	ent.m_Name = "Banker"
	ent:SetNWString("NPCName", "Banker")
	ent:SetModel("models/barney.mdl")
	ent:SetPos(player:GetPos())
	ent:SetAngles(player:GetAngles())
	ent:Spawn()
	ent:EnableChat()
	table.insert(bankers, ent)
	saveBankers()
end)

local function networkBank(player)
	net.Start("networkBank")
		net.WriteTable(player.Bank)
	net.Send(player)
end

hook.Add("PlayerInitialSpawn", "BANK::InitialSpawn", function(player)
	player.Bank = {}
	for slot=0,MAX_BANK_SLOTS do --Fully initialize our table.
		player.Bank[slot] = {}
		player.Bank[slot][ITEM_ID] = 0
		player.Bank[slot][ITEM_Q] = 0
		player.Bank[slot][ITEM_E] = 0
		player.Bank[slot][ITEM_EX] = 0
	end
	if file.Exists("roleplay/economy/bankaccounts/"..player:UniqueID()..".txt", "DATA") then
		player.Bank = pon.decode(file.Read("roleplay/economy/bankaccounts/"..player:UniqueID()..".txt", "DATA"))
	end
	networkBank(player)
end)

concommand.Add("requestBank", function(player, cmd, args)
	local tr = {}
	tr.start = player:GetShootPos()
	tr.endpos = tr.start + player:GetAimVector()*MAX_INTERACT_DIST
	tr.filter = player
	tr = util.TraceLine(tr)
	if tr.MatType == MAT_GLASS then
		local start = tr.HitPos
		tr = {}
		tr.start = start + player:GetAimVector()*20
		tr.endpos = tr.start + player:GetAimVector()*50
		tr = util.TraceLine(tr)			
	end
	if tr.Entity:IsValid() and tr.Entity:GetClass() == "npc_generic" and tr.Entity.m_Name == "Banker" then
		player:Freeze(true)
	end
end)

concommand.Add("bankFinished", function(player, cmd, args)
	player:Freeze(false)
end)

local function saveBank(player)
	file.Write("roleplay/economy/bankaccounts/"..player:UniqueID()..".txt", pon.encode(player.Bank))
end

local PLAYER = FindMetaTable("Player")
function PLAYER:GiveBankItem(id, quantity, e, ex)
	for slot=0,MAX_BANK_SLOTS do	
		if self.Bank[slot] == nil or self.Bank[slot][ITEM_ID] == 0 then
			self.Bank[slot][ITEM_ID] = id
			self.Bank[slot][ITEM_Q] = quantity
			self.Bank[slot][ITEM_E] = e
			self.Bank[slot][ITEM_EX] = ex
			saveBank(self)
			networkBank(self)
			return
		end
	end
end

local function fixBank(player) -- Slides everything down 1 slot when an item is removed.
	for slot=0,MAX_BANK_SLOTS do
		if player.Bank[slot] and player.Bank[slot][ITEM_ID] == 0 and slot != MAX_BANK_SLOTS then
			local new = slot+1
			player.Bank[slot][ITEM_ID] = player.Bank[new][ITEM_ID]
			player.Bank[new][ITEM_ID] = 0
			player.Bank[slot][ITEM_Q] = player.Bank[new][ITEM_Q]
			player.Bank[new][ITEM_Q] = 0
			player.Bank[slot][ITEM_E] = player.Bank[new][ITEM_E]
			player.Bank[new][ITEM_E] = 0
			player.Bank[slot][ITEM_EX] = player.Bank[new][ITEM_EX]
			player.Bank[new][ITEM_EX] = 0
		end
	end
end

function PLAYER:RemoveBankItem(id, quantity, slot)
	local slot = slot or -1
	if slot == -1 then
		for i=0,MAX_BANK_SLOTS do
			if self.Bank[slot] and self.Bank[slot][ITEM_ID] == id then
				slot = i
				break
			end
		end
	end
	if slot == -1 then return end -- Kill the function if their is still no slot specified and the item wasn't found.
	if quantity == 0 or not items.IsStackable(self.Bank[slot][ITEM_ID]) then -- Remove all items.
		self.Bank[slot][ITEM_ID] = 0
		self.Bank[slot][ITEM_Q] = 0
		self.Bank[slot][ITEM_E] = 0
		self.Bank[slot][ITEM_EX] = 0
	else -- Remove 'quantity' of item.
		self.Bank[slot][ITEM_Q] = self.Bank[slot][ITEM_Q] - quantity
		if self.Bank[slot][ITEM_Q] < 1 then
			self.Bank[slot][ITEM_ID] = 0
			self.Bank[slot][ITEM_Q] = 0
			self.Bank[slot][ITEM_E] = 0
			self.Bank[slot][ITEM_EX] = 0
		end
	end
	fixBank(self)
	saveBank(self)
	networkBank(self)
end

concommand.Add("itemToBank", function(player, cmd, args)
	if #args < 2 then ErrorNoHalt("[BANK ERROR] Invalid # of arguments used in 'itemToBank' concommand.") return end
	local slot = tonumber(args[1])
	local amt = tonumber(args[2])
	local invitem = player.Inv[slot]
	if amt == -1 then --deposit all
		player:GiveBankItem(invitem[ITEM_ID], invitem[ITEM_Q], invitem[ITEM_E], invitem[ITEM_EX])
		player:RemoveInvItem(_, 0, slot)
	else --remove amt
		if amt > invitem[ITEM_Q] then amt = invitem[ITEM_Q] end
		player:GiveBankItem(invitem[ITEM_ID], amt, invitem[ITEM_E], invitem[ITEM_EX])
		player:RemoveInvItem(_, amt, slot)
	end
end)

concommand.Add("itemToInventory", function(player, cmd, args)
	if #args < 2 then ErrorNoHalt("[BANK ERROR] Invalid # of arguments used in 'itemToInventory' concommand.") return end
	local slot = tonumber(args[1])
	local amt = tonumber(args[2])
	local bankitem = player.Bank[slot]
	if amt == -1 then --withdraw all
		if player:CanHoldItem(bankitem[ITEM_ID], bankitem[ITEM_Q]) == false then DarkRP.notify(player, 1, 4, string.format("You're carrying too much weight to hold this %s.", items.Get(bankitem[ITEM_ID]).Name)) return end
		player:GiveInvItem(bankitem[ITEM_ID], bankitem[ITEM_Q], bankitem[ITEM_E], bankitem[ITEM_EX])
		player:RemoveBankItem(_, 0, slot)
	else --remove amt
		if amt > bankitem[ITEM_Q] then amt = bankitem[ITEM_Q] end
		if player:CanHoldItem(bankitem[ITEM_ID], amt) == false then DarkRP.notify(player, 1, 4, string.format("You're carrying too much weight to hold this %s.", items.Get(bankitem[ITEM_ID]).Name)) return end
		player:GiveInvItem(bankitem[ITEM_ID], amt, bankitem[ITEM_E], bankitem[ITEM_EX])
		player:RemoveBankItem(_, amt, slot)
	end
end)