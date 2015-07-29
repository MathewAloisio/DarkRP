_G.inventory = _G.inventory or {}

local InvWeight = InvWeight or 0.0
local MaxInvSlots = MaxInvSlots or MAX_INV_SLOTS
local Inv = Inv or {}
net.Receive("networkInventory", function(len)
	InvWeight = net.ReadFloat()
	MaxInvSlots = net.ReadDouble()
	Inv = net.ReadTable()
end)

function inventory.GetMaxInvWeight()
	return MAX_INV_WEIGHT + (Levels["Strength"]*5)
end

function inventory.CanHoldItem(id)
	if (InvWeight + items.Get(id).Weight) > GetMaxInvWeight() then return false end
	return true
end

function inventory.CheckInv() --Check if the inventory is full
	for slot=0,MaxInvSlots do
		if Inv[slot][ITEM_ID] == 0 then
			return true
		end
	end
	return false
end

function inventory.CheckInvItem(id) --NOTE: not for use with quantity-based items.
	for slot=0,MaxInvSlots do
		if Inv[slot][ITEM_ID] == id then
			return true
		end
	end
	return false
end

function inventory.HasInvItem(id, quantity) -- Checks if the player has a stack of 'items.Get(id)' with a quantity equal to or greater than 'quantity'. NOTE: for quantity-based items ONLY. IMPORTANT: returns -1 instead of 'false'.
	for slot=0,MaxInvSlots do
		if Inv[slot][ITEM_ID] == id then
			if Inv[slot][ITEM_Q] >= quantity then
				return slot
			end
		end
	end
	return -1
end

function inventory.CheckInvItemEx(id) --Counts total amount of a specific item ID in your inventory, all stacks taken into consideration.
	local count = 0
	for slot=0,MaxInvSlots do
		if Inv[slot][ITEM_ID] == id then
			if Inv[slot][ITEM_Q] == 0 then
				count = count + 1
			else
				count = count + Inv[slot][ITEM_Q]
			end
		end
	end
	if count != 0 then return count end
	return false
end