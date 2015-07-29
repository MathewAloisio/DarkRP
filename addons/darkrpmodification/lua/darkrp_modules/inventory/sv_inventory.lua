--Dependencies: "skills", "item".
util.AddNetworkString("networkInventory")
local function recalculateInvWeight(player)
	player.InvWeight = 0.0
	for slot=0,player:GetMaxInvSlots() do
		if player.Inv[slot][ITEM_ID] != 0 then
			player.InvWeight = player.InvWeight + items.Get(player.Inv[slot][ITEM_ID]).Weight
		end
	end
end

local function saveInventory(player) --Redundant but just incase.
	recalculateInvWeight(playerid)
	file.Write(string.format("roleplay/inventory/%s.txt", player:UniqueID()), pon.encode(player.Inv))
end
hook.Add("PlayerDisconnect", "inventoryDisconnect", saveInventory)

local function networkInventory(player)
	net.Start("networkInventory")
		net.WriteFloat(player.InvWeight)
		net.WriteDouble(player:GetMaxInvSlots())
		net.WriteTable(player.Inv)
	net.Send(player)
end

hook.Add("PlayerInitialSpawn", "loadInventory", function(player)
	player.Inv = {}
	if file.Exists(string.format("roleplay/inventory/%s.txt", player:UniqueID()), "DATA") then
		player.Inv = pon.decode(string.format("roleplay/inventory/%s.txt", player:UniqueID()), "DATA")
		recalculateInvWeight(player)
	else 
		player.Inv[slot] = {}
		for slot=0,player:GetMaxInvSlots() do
			player.Inv[slot][ITEM_ID] = 0
			player.Inv[slot][ITEM_Q]] = 0
			player.Inv[slot][ITEM_E] = 0
			player.Inv[slot][ITEM_EX] = 0
		end
		saveInventory(player)
	end
	networkInventory(player)
end)

hook.Add("ShutDown", "inventoryShutDown", function() --Redundant but just incase.
	for _,v in pairs(player.GetAll()) do
		saveInventory(v)
	end
end)

local PLAYER = FindMetaTable("Player")

function PLAYER:RecalculateMaxInvSlots()
	local slots = 0
	--TODO: Calculate MaxInvSlots()
	ply.MaxInvSlots = slots
end

function PLAYER:GetMaxInvSlots()
	--TODO: Donator MaxInvSlots and possibly backpacks, etc.
	return ply.InvMaxSlots or MAX_INV_SLOTS
end

function PLAYER:CheckInv() --Check if the inventory is full
	for slot=0,self:GetMaxInvSlots() do
		if self.Inv[slot][ITEM_ID] == 0 then
			return true
		end
	end
	return false
end

function PLAYER:GetMaxInvWeight() --Can be mimicked clientside, no need to network.
	return MAX_INV_WEIGHT + (self:GetLevel("Strength")*5) --TODO: Make the skill system.
end

function PLAYER:CanHoldItem(id)
	if (self.InvWeight + items.Get(id).Weight) > self:GetMaxInvWeight() then return false end
	return true
end

function PLAYER:GiveInvItem(id, quantity, e, ex)
	if self:CanHoldItem(id) == false then --Item is too heavy.
		DarkRP.notify(self, 1, 4, string.format("You're carrying too much weight to hold this %s.", items.Get(id).Name))
		return false 
	end
	if self:CheckInv() == false then --No free inventory slots.
		DarkRP.notify(self, 1, 4, string.format("You're don't have room to hold this %s.", items.Get(id).Name))
		return false
	end
	for slot=0,self:GetMaxInvSlots() do
		if self.Inv[slot][ITEM_ID] == 0 then
			self.Inv[slot][ITEM_ID] = id
			self.Inv[slot][ITEM_Q]] = quantity
			self.Inv[slot][ITEM_E] = e
			self.Inv[slot][ITEM_EX] = ex
			saveInventory(self)
			networkInventory(self)
			return true
		end
	end
	return false
end

local function fixInventory(self) -- Slides everything down 1 inv-slot when an item is removed.
	local max_slots = self:GetMaxInvSlots() --Store it just incase it changes in the fraction of a second this takes to run.
	for slot=0,max_slots do
		if self.Inv[slot][ITEM_ID] == 0 and slot != max_slots then
			local new = slot+1
			self.Inv[slot][ITEM_ID] = self.Inv[new][ITEM_ID]
			self.Inv[new][ITEM_ID] = 0
			self.Inv[slot][ITEM_Q] = self.Inv[new][ITEM_Q]
			self.Inv[new][ITEM_Q] = 0
			self.Inv[slot][ITEM_E] = self.Inv[new][ITEM_E]
			self.Inv[new][ITEM_E] = 0
			self.Inv[slot][ITEM_EX] = self.Inv[new][ITEM_EX]
			self.Inv[new][ITEM_EX] = 0
		end
	end
end

function PLAYER:RemoveInvItem(id, quantity, slot)
	local quantity = quantity or 0
	local slot = slot or -1
	if slot == -1 then
		for i=0,self:GetMaxInvSlots() do
			if self.Inv[slot][ITEM_ID] == 0 then
				slot = i
				break
			end
		end
	end
	if slot == -1 return end -- Kill the function if their is no slot specified and the item wasn't found.
	if quantity == 0 then -- Remove all items.
		self.Inv[slot][ITEM_ID] = 0
		self.Inv[slot][ITEM_Q]] = 0
		self.Inv[slot][ITEM_E] = 0
		self.Inv[slot][ITEM_EX] = 0
	else -- Remove 'quantity' of item.
		self.Inv[slot][ITEM_Q] = self.Inv[slot][ITEM_Q] - quantity
		if self.Inv[slot][ITEM_Q] < 1 then
			self.Inv[slot][ITEM_ID] = 0
			self.Inv[slot][ITEM_Q]] = 0
			self.Inv[slot][ITEM_E] = 0
			self.Inv[slot][ITEM_EX] = 0
		end
	end
	fixInventory(self)
	saveInventory(self)
	networkInventory(self)
end

function PLAYER:RemoveAllItem(id) -- Removes all occurances of an item with the ID 'id' in your inventory.
	for slot=0,self:GetMaxInvSlots() do
			if self.Inv[slot][ITEM_ID] == id then
			self.Inv[slot][ITEM_ID] = 0
			self.Inv[slot][ITEM_Q]] = 0
			self.Inv[slot][ITEM_E] = 0
			self.Inv[slot][ITEM_EX] = 0
			fixInventory(self)
		end
	end
	saveInventory(self)
	networkInventory(self)
end

function PLAYER:CheckInvItem(id) --NOTE: not for use with quantity-based items.
	for slot=0,self:GetMaxInvSlots() do
		if self.Inv[slot][ITEM_ID] == id then
			return true
		end
	end
	return false
end

function PLAYER:HasInvItem(id, quantity) -- Checks if the player has a stack of 'items.Get(id)' with a quantity equal to or greater than 'quantity'. NOTE: for quantity-based items ONLY. IMPORTANT: returns -1 instead of 'false'.
	for slot=0,self:GetMaxInvSlots() do
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
	for slot=0,self:GetMaxInvSlots() do
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