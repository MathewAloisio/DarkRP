util.AddNetworkString("openInventoryMenu")
util.AddNetworkString("networkInventory")
util.AddNetworkString("startCombine")
util.AddNetworkString("startDivide")
local function recalculateInvWeight(player)
	player.InvWeight = 0.0
	for slot=0,MAX_INV_SLOTS do
		if player.Inv[slot][ITEM_ID] != 0 then
			if items.IsStackable(player.Inv[slot][ITEM_ID]) then
				player.InvWeight = player.InvWeight + (items.GetWeight(player.Inv[slot][ITEM_ID]) * player.Inv[slot][ITEM_Q])
			else
				player.InvWeight = player.InvWeight + items.GetWeight(player.Inv[slot][ITEM_ID])
			end
		end
	end
end

local function saveInventory(player)
	recalculateInvWeight(player)
	file.Write(string.format("roleplay/inventory/%s.txt", player:UniqueID()), pon.encode(player.Inv))
end

local function networkInventory(player)
	net.Start("networkInventory")
		net.WriteFloat(player.InvWeight)
		net.WriteDouble(player:GetMaxInvWeight())
		net.WriteTable(player.Inv)
	net.Send(player)
end

hook.Add("PlayerInitialSpawn", "Inventory::InitialSpawn", function(player)
	player.Inv = {}
	for slot=0,MAX_INV_SLOTS do --Fully initialize our table.
		player.Inv[slot] = {}
		player.Inv[slot][ITEM_ID] = 0
		player.Inv[slot][ITEM_Q] = 0
		player.Inv[slot][ITEM_E] = 0
		player.Inv[slot][ITEM_EX] = 0
	end

	if file.Exists(string.format("roleplay/inventory/%s.txt", player:UniqueID()), "DATA") then
		player.Inv = pon.decode(file.Read(string.format("roleplay/inventory/%s.txt", player:UniqueID()), "DATA"))
		recalculateInvWeight(player)
	else 
		for slot=0,MAX_INV_SLOTS do
			player.Inv[slot][ITEM_ID] = 0
			player.Inv[slot][ITEM_Q] = 0
			player.Inv[slot][ITEM_E] = 0
			player.Inv[slot][ITEM_EX] = 0
		end
		saveInventory(player)
	end
	timer.Simple(0.1, function() networkInventory(player) end)
end)

hook.Add("ShutDown", "inventoryShutDown", function() --Redundant but just incase.
	for _,v in pairs(player.GetAll()) do
		saveInventory(v)
	end
end)

DarkRP.defineChatCommand("putgun", function(player, args)
	local weapon = player:GetActiveWeapon()
	if not weapon.ItemID then DarkRP.notify(player, 1, 4, "You can't put this weapon into your inventory.") return "" end
	if player.holsterTime and player.holsterTime > CurTime() then DarkRP.notify(player, 1, 4, "You can't put this weapon away yet.") return "" end
	player.holsterTime = CurTime() + 2
	player:GiveInvItem(weapon.ItemID, 1, weapon:Clip1())
	player:StripWeapon(weapon:GetClass())
	return ""
end)

concommand.Add("rp_invaction", function(player, cmd, args)
	if #args < 2 then return end
	local slot = tonumber(args[1])
	local action = tonumber(args[2])
	local inv = player.Inv[slot]
	if inv[ITEM_ID] ~= 0 then
		local tbl = items.Get(inv[ITEM_ID])
		if tbl == nil then MsgN(string.format("[ERROR] Item[%i] not found. Called by [rp_invaction].", inv[ITEM_ID])) return end
		if (tbl.ShowOption ~= nil and tbl.ShowOption(player) == false) then return end --direct-concommand abuse protection. (this means we need an equivalent ShowOption serverside and clientside.)
		if action == 0 then
			if tbl.Type == ITYPE_WEAPON then
				if player:HasWeapon(tbl.WepClass) then DarkRP.notify(player, 1, 4, "You already have this weapon equipped!") return end
				local wep = player:Give(tbl.WepClass)
				wep:SetClip1(inv[ITEM_E])
				player:RemoveInvItem(_, 0, slot)
				player:SelectWeapon(tbl.WepClass)
				wep.ItemID = tbl.ID
				if tbl.Actions[0].DoAction then tbl.Actions[0].DoAction(player, slot) end
				return
			end
			--TODO: Add other custom types like food.
		end
		if not tbl.Actions[action] then MsgN(string.format("[ERROR] Invalid action[%i] called for Item[%i].", action, inv[ITEM_ID])) return end
		if tbl.Actions[action].DoAction then
			tbl.Actions[action].DoAction(player, slot)
		elseif action == #tbl.Actions-2 and items.IsStackable(inv[ITEM_ID]) then -- Combine
			net.Start("startCombine")
				net.WriteDouble(inv[ITEM_ID])
				net.WriteDouble(slot)
			net.Send(player)
		elseif action == #tbl.Actions-1 and items.IsStackable(inv[ITEM_ID]) then -- Divide
			net.Start("startDivide")
				net.WriteDouble(inv[ITEM_ID])
				net.WriteDouble(slot)
			net.Send(player)
		elseif action >= #tbl.Actions then --Drop since we're on the last Action and there is no custom 'DoAction' set, assumed drop.
			player:DropInvItem(slot)
		end
	end
end)

concommand.Add("divideItem", function(player, cmd, args)
	if #args < 3 then return end
	local slot = tonumber(args[1])
	if player.Inv[slot][ITEM_ID] ~= tonumber(args[3]) then return end --Incase the inventory shifts while we're dividing.
	local amt = tonumber(args[2])
	if player.Inv[slot][ITEM_Q] < amt+1 then DarkRP.notify(player, 1, 4, string.format("You can't divide this many items out of this item-stack. Limit: %i.", player.Inv[slot][ITEM_Q]-1)) return end
	player.Inv[slot][ITEM_Q] = player.Inv[slot][ITEM_Q] - amt --Use this instead of PLAYER:RemoveInvItem so we don't shift the inventory, AND it's faster anyways.
	player:GiveInvItem(player.Inv[slot][ITEM_ID], amt, player.Inv[slot][ITEM_E], player.Inv[slot][ITEM_EX])
end)

concommand.Add("combineItem", function(player, cmd, args)
	if #args < 3 then return end
	local slotone = tonumber(args[1])
	local slottwo = tonumber(args[2])
	if slotone == slottwo then return end -- Can't combine a stack with itself.
	local id = tonumber(args[3])
	if player.Inv[slotone][ITEM_ID] ~= id or player.Inv[slottwo][ITEM_ID] ~= id then DarkRP.notify(player, 1, 4, "You can only combine items of the same type.") return end --No combining two items of different types.
	if items.Get(id).MaxStack and (player.Inv[slotone][ITEM_Q] + player.Inv[slottwo][ITEM_Q]) > items.Get(id).MaxStack then DarkRP.notify(player, 1, 4, string.format("This item has a stack-size limit of %i items.", items.Get(id).MaxStack)) return end
	if slotone > slottwo then -- Move the items to slotone. (prevents problems caused by fixInventory)
		player.Inv[slotone][ITEM_Q] = player.Inv[slotone][ITEM_Q] + player.Inv[slottwo][ITEM_Q]
		player:RemoveInvItem(_, 0, slottwo)
	else -- Move the items to slottwo. (prevents problems caused by fixInventory)
		player.Inv[slottwo][ITEM_Q] = player.Inv[slottwo][ITEM_Q] + player.Inv[slotone][ITEM_Q]
		player:RemoveInvItem(_, 0, slotone)	
	end
end)

concommand.Add("rp_giveitem", function(player, cmd, args) 
	if player:IsDev() == false then DarkRP.notify(player, 1, 4, "Only developers can use this command!") return end
	if #args < 4 then DarkRP.notify(player, 2, 4, "[Usage] rp_giveitem [id] [quantity] [ex] [ex2]") return end
	local q = tonumber(args[2])
	player:GiveInvItem(tonumber(args[1]), q, tonumber(args[3]), tonumber(args[4]))
	DarkRP.notify(player, 4, 4, string.format("You've given yourself %s (x%i) [ITEM_E = %i] [ITEM_EX = %i]", items.GetName(tonumber(args[1]),q), q, tonumber(args[3]), tonumber(args[4])))
end)

local PLAYER = FindMetaTable("Player")

function PLAYER:CheckInv() --Check if the inventory is full
	for slot=0,MAX_INV_SLOTS do
		if self.Inv[slot][ITEM_ID] == 0 then
			return true
		end
	end
	return false
end

function PLAYER:GetMaxInvWeight()
	return MAX_INV_WEIGHT + (self:GetLevel("Strength")*2) + self:GetMod(MOD_WEIGHT)
end

function PLAYER:CanHoldItem(id, q)
	local q = q or 1
	if items.IsStackable(id) then
		if (self.InvWeight + (items.Get(id).Weight * q)) > self:GetMaxInvWeight() then return false end
	else
		if (self.InvWeight + items.Get(id).Weight) > self:GetMaxInvWeight() then return false end
	end
	return true
end

function PLAYER:GiveInvItem(id, quantity, e, ex)
	if self:CanHoldItem(id, quantity) == false then --Item is too heavy.
		DarkRP.notify(self, 1, 4, string.format("You're carrying too much weight to hold this %s.", items.Get(id).Name))
		return false 
	end
	for slot=0,MAX_INV_SLOTS do
		if self.Inv[slot][ITEM_ID] == 0 then
			self.Inv[slot][ITEM_ID] = id
			self.Inv[slot][ITEM_Q] = quantity or 1
			self.Inv[slot][ITEM_E] = e or 0
			self.Inv[slot][ITEM_EX] = ex or 0
			saveInventory(self)
			networkInventory(self)
			return true
		end
	end
	DarkRP.notify(self, 1, 4, string.format("You're don't have room to hold this %s.", items.Get(id).Name))
	return false
end

local function fixInventory(player) -- Slides everything down 1 inv-slot when an item is removed.
	for slot=0,MAX_INV_SLOTS do
		if player.Inv[slot][ITEM_ID] == 0 and slot != MAX_INV_SLOTS then
			local new = slot+1
			player.Inv[slot][ITEM_ID] = player.Inv[new][ITEM_ID]
			player.Inv[new][ITEM_ID] = 0
			player.Inv[slot][ITEM_Q] = player.Inv[new][ITEM_Q]
			player.Inv[new][ITEM_Q] = 0
			player.Inv[slot][ITEM_E] = player.Inv[new][ITEM_E]
			player.Inv[new][ITEM_E] = 0
			player.Inv[slot][ITEM_EX] = player.Inv[new][ITEM_EX]
			player.Inv[new][ITEM_EX] = 0
		end
	end
end

function PLAYER:RemoveInvItem(id, quantity, slot)
	local quantity = quantity or 0
	local slot = slot or -1
	if slot == -1 then
		for i=0,MAX_INV_SLOTS do
			if self.Inv[slot][ITEM_ID] == id then
				slot = i
				break
			end
		end
	end
	if slot == -1 then return end -- Kill the function if their is still no slot specified and the item wasn't found.
	if quantity == 0 or not items.IsStackable(self.Inv[slot][ITEM_ID]) then -- Remove all items.
		self.Inv[slot][ITEM_ID] = 0
		self.Inv[slot][ITEM_Q] = 0
		self.Inv[slot][ITEM_E] = 0
		self.Inv[slot][ITEM_EX] = 0
	else -- Remove 'quantity' of item.
		self.Inv[slot][ITEM_Q] = self.Inv[slot][ITEM_Q] - quantity
		if self.Inv[slot][ITEM_Q] < 1 then
			self.Inv[slot][ITEM_ID] = 0
			self.Inv[slot][ITEM_Q] = 0
			self.Inv[slot][ITEM_E] = 0
			self.Inv[slot][ITEM_EX] = 0
		end
	end
	fixInventory(self)
	saveInventory(self)
	networkInventory(self)
end

function PLAYER:RemoveAllItem(id) -- Removes all occurances of an item with the ID 'id' in your inventory.
	for slot=0,MAX_INV_SLOTS do
			if self.Inv[slot][ITEM_ID] == id then
			self.Inv[slot][ITEM_ID] = 0
			self.Inv[slot][ITEM_Q] = 0
			self.Inv[slot][ITEM_E] = 0
			self.Inv[slot][ITEM_EX] = 0
			fixInventory(self)
		end
	end
	saveInventory(self)
	networkInventory(self)
end

function PLAYER:CheckInvItem(id) --NOTE: not for use with quantity-based items.
	for slot=0,MAX_INV_SLOTS do
		if self.Inv[slot][ITEM_ID] == id then
			return true
		end
	end
	return false
end

function PLAYER:HasInvItem(id, quantity) -- Checks if the player has a stack of 'items.Get(id)' with a quantity equal to or greater than 'quantity'. NOTE: for quantity-based items ONLY. IMPORTANT: returns -1 instead of 'false'.
	for slot=0,MAX_INV_SLOTS do
		if self.Inv[slot][ITEM_ID] == id then
			if self.Inv[slot][ITEM_Q] >= quantity then
				return slot
			end
		end
	end
	return -1
end

function PLAYER:CheckInvItemEx(id) --Counts total amount of a specific item ID in your inventory, all stacks taken into consideration.
	local count = 0
	for slot=0,MAX_INV_SLOTS do
		if self.Inv[slot][ITEM_ID] == id then
			if self.Inv[slot][ITEM_Q] == 0 then
				count = count + 1
			else
				count = count + self.Inv[slot][ITEM_Q]
			end
		end
	end
	if count != 0 then return count end
	return false
end

function PLAYER:DropInvItem(slot,force)
	local force = force or 0
	if self.Inv[slot][ITEM_ID] == 0 then return false end
	if (self.nextItemDrop and self.nextItemDrop > CurTime()) and force == 0 then DarkRP.notify(self, 1, 4, "Wait a moment before dropping another item.") return false end
	self.nextItemDrop = CurTime() + 2
	local tbl = {
		id = self.Inv[slot][ITEM_ID],
		q = self.Inv[slot][ITEM_Q],
		e = self.Inv[slot][ITEM_E],
		ex = self.Inv[slot][ITEM_EX]
	}
	self.Inv[slot][ITEM_ID] = 0
	self.Inv[slot][ITEM_Q] = 0
	self.Inv[slot][ITEM_E] = 0
	self.Inv[slot][ITEM_EX] = 0
	fixInventory(self)
	saveInventory(self)
	networkInventory(self)
	local tr = self:GetEyeTrace(100)
	local ent = items.CreateLoot(tbl.id, tbl.q, tbl.e, tbl.ex, tr.HitPos, items.Get(tbl.id).DropAng or nil)
	if ent ~= false and IsValid(ent) then
		ent:SetPos(tr.HitPos + (tr.HitNormal*(ent:OBBMaxs()*2)))
	end
	return true
end

hook.Add("ShowTeam", "Inventory::OpenMenu", function(player)
	net.Start("openInventoryMenu")
	net.Send(player)
end)