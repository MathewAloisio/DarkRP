_G.inventory = _G.inventory or {}

local InvWeight = InvWeight or 0.0
local MaxInvWeight = MaxInvWeight or MAX_INV_WEIGHT
local Inv = Inv or {}


function inventory.GetAll()
	return Inv
end

function inventory.Get(slot)
	return Inv[slot]
end

function inventory.GetMaxInvWeight()
	return MaxInvWeight or MAX_INV_WEIGHT
end

function inventory.CanHoldItem(id)
	if (InvWeight + items.Get(id).Weight) > GetMaxInvWeight() then return false end
	return true
end

function inventory.CheckInv() --Check if the inventory is full
	for slot=0,MAX_INV_SLOTS do
		if Inv[slot][ITEM_ID] == 0 then
			return true
		end
	end
	return false
end

function inventory.CheckInvItem(id) --NOTE: not for use with quantity-based items.
	for slot=0,MAX_INV_SLOTS do
		if Inv[slot][ITEM_ID] == id then
			return true
		end
	end
	return false
end

function inventory.HasInvItem(id, quantity) -- Checks if the player has a stack of 'items.Get(id)' with a quantity equal to or greater than 'quantity'. NOTE: for quantity-based items ONLY. IMPORTANT: returns -1 instead of 'false'.
	for slot=0,MAX_INV_SLOTS do
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
	for slot=0,MAX_INV_SLOTS do
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
	local panel
	if id == nil or id == 0 then
		panel = vgui.Create("DModelPanel", MenuList)
		panel:SetSize(defines.ScreenScale(60), defines.ScreenScale(60))
		panel.Slot = slot
		--panel.Paint = function()
		--	draw.RoundedBox(8, 0, 0, panel:GetWide(), panel:GetTall(), Color(0, 0, 0, 255))
		--end		
	else
		local tbl = items.Get(id)
		panel = vgui.Create("DModelPanel", MenuList)
		panel:SetModel(tbl.Model)
		panel:SetTooltip(index)
		panel:SetSize(defines.ScreenScale(60), defines.ScreenScale(60))
		panel.ItemID = id
		panel.Slot = slot
		panel:SetCamPos(tbl.CamPos)
		panel:SetLookAt(tbl.LookAt)
		panel.PaintOver = function() 
			if items.IsStackable(id) then
				draw.SimpleText(Inv[slot][ITEM_Q], "DermaDefaultBold", panel:GetWide()-1.5, panel:GetTall()-1.5, Color(255, 255, 255, 255), 2, 4) 
			end
			if panel:IsHovered() then
				draw.RoundedBox(8, 0, 0, panel:GetWide(), panel:GetTall(), Color(GetConVarNumber("background1"), GetConVarNumber("background2"), GetConVarNumber("background3"), 100))
				surface.SetDrawColor(GetConVarNumber("Healthforeground1"), GetConVarNumber("Healthforeground2"), GetConVarNumber("Healthforeground3"), GetConVarNumber("Healthforeground4"))
				surface.DrawOutlinedRect( 0, 0, panel:GetWide(), panel:GetTall() )
			end
		end

		panel.OnMousePressed = function()
			local menu = DermaMenu()
			for i,v in pairs(tbl.Actions) do
				if (v.ShowOption ~= nil and v.ShowOption() == false) then continue end
				menu:AddOption(v.Name, function()
					RunConsoleCommand("rp_invaction", panel.Slot, i) 
					MenuList:Clear()
					for slot=0,MAX_INV_SLOTS do
						makeItemSlot(Inv[slot][ITEM_ID], slot)
					end
				end)
			end
			menu:Open()
		end
	end
	
	MenuList:AddItem(panel)
end

local function createInventory()
	Menu = vgui.Create("DPanel")
	Menu:SetPos(ScrW(), ScrH()-500)
	Menu:SetSize(defines.ScreenScale(480), defines.ScreenScale(240))
	Menu:SetSkin("DarkRP")
	Menu:SetVisible(true)
	Menu.Paint = function()
		draw.DrawText("Player Inventory", "TargetID", surface.GetTextSize("Player Inventory")/1.75, 0.5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER)
		draw.RoundedBox(8, 0, 0, Menu:GetWide(), Menu:GetTall(), Color(GetConVarNumber("background1"), GetConVarNumber("background2"), GetConVarNumber("background3"), GetConVarNumber("background4")))

		surface.SetDrawColor(GetConVarNumber("Healthforeground1"), GetConVarNumber("Healthforeground2"), GetConVarNumber("Healthforeground3"), GetConVarNumber("Healthforeground4"))
		surface.DrawLine(0, 20, Menu:GetWide(), 20)
	end

	MenuList = vgui.Create("DPanelList", Menu)
	MenuList:StretchToParent(defines.ScreenScale(5), defines.ScreenScale(30), defines.ScreenScale(5), defines.ScreenScale(5))
	MenuList:EnableHorizontal(true)
	MenuList:EnableVerticalScrollbar(true)
	MenuList.Paint = function()
		draw.RoundedBox( 4, 0, 0, Menu:GetWide() - 50, Menu:GetTall() - 50, Color(GetConVarNumber("Healthbackground1"), GetConVarNumber("Healthbackground2"), GetConVarNumber("Healthbackground3"), GetConVarNumber("Healthbackground4")))
	end
end

net.Receive("networkInventory", function(len)
	InvWeight = net.ReadFloat()
	MaxInvWeight = net.ReadDouble()
	Inv = net.ReadTable()

	if IsValid(MenuList) then
		MenuList:Clear() --rebuild item icons.
		for slot=0,MAX_INV_SLOTS do
			makeItemSlot(Inv[slot][ITEM_ID], slot)
		end
	end
end)

net.Receive("openInventoryMenu", function(len, ply)
	if IsOpen == false then
		Menu:MoveTo(ScrW()-defines.ScreenScale(453),ScrH()-500,0.2,0,1)
		gui.EnableScreenClicker(true)
		IsOpen = true
	elseif IsOpen == true then
		Menu:MoveTo(ScrW(),ScrH()-500,0.2,0,1)
		IsOpen = false
		gui.EnableScreenClicker(false)
	end
end)

hook.Add("Initialize", "buildInventory", function()
	if not IsValid(Menu) then
		createInventory()
	end
end)