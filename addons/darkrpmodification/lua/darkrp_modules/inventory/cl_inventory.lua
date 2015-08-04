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

function inventory.GetMaxInvSlots()
	return MaxInvSlots
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

--TODO Actual inventory UI below.
local Menu = nil
local MenuList = nil
local IsOpen = false
local sc_w, sc_h = 1280, 720
local w, h = ScrW(), ScrH()
local wx, wy = w / sc_w, h / sc_h

function inventory.MakeItemSlot(id, slot)
	if (id == 0 or id == nil) then
		if (IsValid(MenuList)) then 
			local panel = vgui.Create("DModelPanel", MenuList)
			panel:SetSize(80 * wx, 80 * wy)
			panel.Slot = slot
			panel.Paint = function()
				draw.RoundedBox(8, 0, 0, panel:GetWide(), panel:GetTall(), Color(0, 0, 0, 255))
			end		
		end
	else
		local tbl = items.Get(id)
		if (IsValid(MenuList)) then
			local panel = vgui.Create("DModelPanel", MenuList)
			panel:SetModel(tbl.Model)
			panel:SetTooltip(index)
			panel:SetSize(80 * wx, 80 * wy)
			panel.ItemID = id
			panel.Slot = slot
			panel:SetCamPos(tbl.CamPos)
			panel:SetLookAt(tbl.CamPos)
			if items.IsStackable(id) then
				panel.PaintOver = function() 
					draw.SimpleText(Inv[slot][ITEM_Q], "ScorboardSubtitle", 60 * wx, 60 * wy, Color(255, 255, 255, 255), 2, 4) 
				end
			end
		end

		panel.OnMousePressed = function()
			local menu = DermaMenu()
			--you do this part
			menu:Open()
		end
	end
	
	if (IsValid(MenuList)) then
		MenuList:AddItem(panel)
	end
end

function inventory.Menu()
	Menu = vgui.Create("DPanel")
	Menu:SetPos(450 * wx, ScrH() * wy)
	Menu:SetSize(400 * wx, 300 * wy)
	Menu:SetVisible(true)
	Menu.Paint = function()
		draw.RoundedBox(6, 0, 0, Menu:GetWide(), Menu:GetTall(), Color(34, 49, 63, 255))
		draw.RoundedBoxEx(6, 0, 0, Menu:GetWide(), 50 * wy, Color(52, 73, 94, 255), true, true, false, false)
	end

	MenuList = vgui.Create("DPanelList", Menu)
	MenuList:StretchToParent(5 * wx, 55 * wy, 5 * wx, 5 * wy)
	MenuList:EnableHorizontal(true)
	MenuList:EnableVerticalScrollbar(true)
	MenuList.Paint = function()
		draw.RoundedBox(6, 0, 0, Menu:GetWide() - 100, Menu:GetTall() - 100, Color(255, 255, 255, 255))
	end

	for slot=0, MaxInvSlots do
		inventory.MakeItemSlot(Inv[slot][ITEM_ID], slot)
	end

	gui.EnableScreenClicker(true)
end

net.Receive("openInventoryMenu", function(len, ply)
	if (!IsValid(Menu)) then
		inventory.Menu()
		Menu:MoveTo(450 * wx, ScrH() - 250 * wy, 0.5, 0)
		gui.EnableScreenClicker(true)
		IsOpen = !IsOpen
	elseif(IsValid(Menu) && IsOpen == true) then
		Menu:MoveTo(450 * wx, ScrH() + 250 * wy, 0.5, 0)
		IsOpen = !IsOpen
		gui.EnableScreenClicker(false)
		repeat
			if (Menu:GetPos().Y == 250) then Menu:Remove() end
		until !IsValid(Menu)
	end
end)