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
local Menu = Menu or nil
local MenuList = MenuList or nil
local IsOpen = IsOpen or false

local function makeItemSlot(id, slot)
	if not IsValid(MenuList) then return end
	if id == 0 or id == nil then
		local panel = vgui.Create("DModelPanel", MenuList)
		panel:SetSize(defines.ScreenScale(60), defines.ScreenScale(60))
		panel.Slot = slot
		panel.Paint = function()
			draw.RoundedBox(8, 0, 0, panel:GetWide(), panel:GetTall(), Color(0, 0, 0, 255))
		end		
	else
		local tbl = items.Get(id)
		local panel = vgui.Create("DModelPanel", MenuList)
		panel:SetModel(tbl.Model)
		panel:SetTooltip(index)
		panel:SetSize(defines.ScreenScale(60), defines.ScreenScale(60))
		panel.ItemID = id
		panel.Slot = slot
		panel:SetCamPos(tbl.CamPos)
		panel:SetLookAt(tbl.LookAt)
		if items.IsStackable(id) then
			panel.PaintOver = function() 
				draw.SimpleText(Inv[slot][ITEM_Q], "ScorboardSubtitle", defines.ScreenScale(60), defines.ScreenScale(60), Color(255, 255, 255, 255), 2, 4) 
			end
		end

		panel.OnMousePressed = function()
			local menu = DermaMenu()
			--you do this part
			menu:Open()
		end
	end
	
	MenuList:AddItem(panel)
end

local function createInventory()
	Menu = vgui.Create("DPanel")
	Menu:SetPos(ScrW(), ScrH()-400)
	Menu:SetSize(defines.ScreenScale(520), defines.ScreenScale(280))
	Menu:SetVisible(true)
	Menu.Paint = function()
		draw.RoundedBox(6, 0, 0, Menu:GetWide(), Menu:GetTall(), Color(34, 49, 63, 255))
		draw.RoundedBoxEx(6, 0, 0, Menu:GetWide(), defines.ScreenScale(50), Color(52, 73, 94, 255), true, true, false, false)
	end
	

	MenuList = vgui.Create("DPanelList", Menu)
	MenuList:StretchToParent(defines.ScreenScale(5), defines.ScreenScale(55), defines.ScreenScale(5), defines.ScreenScale(5))
	MenuList:EnableHorizontal(true)
	MenuList:EnableVerticalScrollbar(true)
	MenuList.Paint = function()
		draw.RoundedBox(6, 0, 0, Menu:GetWide() - 100, Menu:GetTall() - 100, Color(255, 255, 255, 255))
	end
	
	for slot=0,MaxInvSlots do
		makeItemSlot(Inv[slot][ITEM_ID], slot)
	end

	gui.EnableScreenClicker(true)
end

net.Receive("openInventoryMenu", function(len, ply)
	if not IsValid(Menu) then createInventory() end
	if IsOpen == false then
		Menu:MoveTo(ScrW()-500,ScrH()-400,0.2,0,1)
		gui.EnableScreenClicker(true)
		IsOpen = true
	elseif IsOpen == true then
		Menu:MoveTo(ScrW(),ScrH()-400,0.2,0,1)
		IsOpen = false
		gui.EnableScreenClicker(false)
	end
end)