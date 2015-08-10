local PANEL = {}

function PANEL:CreateInventory()
	self.inventory = vgui.Create("DPanel", self)
	self.inventory:StretchToParent(5,30,5,self:GetTall()*0.5+5)
	self.inventory:SetVisible(true)
	self.inventory.Paint = function()
		draw.DrawText("Player Inventory", "DermaDefault", surface.GetTextSize("Player Inventory")/2.75, 1.5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER)
		draw.RoundedBox(8, 0, 0, self.inventory:GetWide(), self.inventory:GetTall(), Color(GetConVarNumber("background1"), GetConVarNumber("background2"), GetConVarNumber("background3"), GetConVarNumber("background4")))

		surface.SetDrawColor(GetConVarNumber("Healthforeground1"), GetConVarNumber("Healthforeground2"), GetConVarNumber("Healthforeground3"), GetConVarNumber("Healthforeground4"))
		surface.DrawLine(0, 20, self.inventory:GetWide(), 20)
		
		local InvWeight = inventory.GetWeight()
		local MaxInvWeight = inventory.GetMaxInvWeight()
		draw.RoundedBox(0,2,24,InvWeight/MaxInvWeight*(self.inventory:GetWide()-4),7,Color(InvWeight/MaxInvWeight*255,255-InvWeight/MaxInvWeight*255,0,255))
	end

	self.inventory.list = vgui.Create("DPanelList", self.inventory)
	self.inventory.list:StretchToParent(5,35,5,5);
	self.inventory.list:EnableHorizontal(true)
	self.inventory.list:EnableVerticalScrollbar(true)
	self.inventory.list.Paint = function()
		draw.RoundedBox(4, 0, 0, self.inventory.list:GetWide(), self.inventory.list:GetTall(), Color(GetConVarNumber("Healthbackground1"), GetConVarNumber("Healthbackground2"), GetConVarNumber("Healthbackground3"), GetConVarNumber("Healthbackground4")))
	end
	self:RebuildInventory()
end

local Bank = Bank or {}
function PANEL:RebuildInventory()
	self.inventory.list:Clear()
	for slot=0,MAX_INV_SLOTS do
		local id = inventory.Get(slot)[ITEM_ID]
		local panel
		if id == nil or id == 0 then
			panel = vgui.Create("DModelPanel", self.inventory.list)
			panel:SetSize(defines.ScreenScale(60), defines.ScreenScale(60))
			panel.Slot = slot
		else
			local tbl = items.Get(id)
			panel = vgui.Create("DModelPanel", self.inventory.list)
			panel:SetModel(tbl.Model)
			panel:SetTooltip(items.GetName(id, inventory.Get(slot)[ITEM_Q]))
			panel:SetSize(defines.ScreenScale(60), defines.ScreenScale(60))
			panel:SetCamPos(tbl.CamPos)
			panel:SetLookAt(tbl.LookAt)
			panel.Slot = slot
			panel.PaintOver = function() 
				if items.IsStackable(id) then
					draw.SimpleText(inventory.Get(slot)[ITEM_Q], "DermaDefaultBold", panel:GetWide()-1.5, panel:GetTall()-1.5, Color(255, 255, 255, 255), 2, 4) 
				end
				if panel:IsHovered() then
					draw.RoundedBox(8, 0, 0, panel:GetWide(), panel:GetTall(), Color(GetConVarNumber("background1"), GetConVarNumber("background2"), GetConVarNumber("background3"), 100))
					surface.SetDrawColor(GetConVarNumber("Healthforeground1"), GetConVarNumber("Healthforeground2"), GetConVarNumber("Healthforeground3"), GetConVarNumber("Healthforeground4"))
					surface.DrawOutlinedRect(0, 0, panel:GetWide(), panel:GetTall())
				end
			end

			panel.OnMousePressed = function()
				local menu = DermaMenu()
				menu:AddOption("Transfer to bank",function() RunConsoleCommand("itemToBank", panel.Slot, 1) end)
				if items.IsStackable(id) then
					menu:AddOption("Transfer X to bank",function()
						Derma_StringRequest( "Question", 
							"How many do you want to transfer?", 
							"Type a number here.", 
							function( strTextOut ) RunConsoleCommand("itemToBank", panel.Slot, strTextOut) end,
							function( strTextOut )  end,
							"Transfer", 
							"Cancel" )
					end)
					menu:AddOption("Transfer all to bank",function() RunConsoleCommand("itemToBank", panel.Slot, -1) end)
				end
				menu:Open()
			end
		end
		self.inventory.list:AddItem(panel)
	end
end

function PANEL:Init()
	self:SetTitle("Banking")
	self:SetSkin("DarkRP")
	
	self:SetSize(ScrW()*0.6,ScrH()*0.6)
	self:Center()
	
	self:SetDraggable(false)

	self:CreateInventory()
	
	self.bankAccount = vgui.Create("DPanel", self)
	self.bankAccount:StretchToParent(5,self:GetTall()*0.5,5,5)
	self.bankAccount:SetVisible(true)
	self.bankAccount.Paint = function()
		draw.DrawText("Bank Account", "DermaDefault", surface.GetTextSize("Player Inventory")/2.5, 1.5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER)
		draw.RoundedBox(8, 0, 0, self.bankAccount:GetWide(), self.bankAccount:GetTall(), Color(GetConVarNumber("background1"), GetConVarNumber("background2"), GetConVarNumber("background3"), GetConVarNumber("background4")))

		surface.SetDrawColor(GetConVarNumber("Healthforeground1"), GetConVarNumber("Healthforeground2"), GetConVarNumber("Healthforeground3"), GetConVarNumber("Healthforeground4"))
		surface.DrawLine(0, 20, self.bankAccount:GetWide(), 20)
	end
	
	self.bankList = vgui.Create("DPanelList",self.bankAccount)
	self.bankList:StretchToParent(5,25,5,5)
	self.bankList:EnableHorizontal(true)
	self.bankList:EnableVerticalScrollbar(true)
	self.bankList.Paint = function()
		draw.RoundedBox(4, 0, 0, self.bankList:GetWide(), self.bankList:GetTall(), Color(GetConVarNumber("Healthbackground1"), GetConVarNumber("Healthbackground2"), GetConVarNumber("Healthbackground3"), GetConVarNumber("Healthbackground4")))
	end
	self:RebuildItems()
	gui.EnableScreenClicker(true)
end

function PANEL:RebuildItems()
	self.bankList:Clear()
	for slot=0,MAX_BANK_SLOTS do
		local id = Bank[slot][ITEM_ID] or 0
		local panel
		if id == nil or id == 0 then
			panel = vgui.Create("DModelPanel", self.bankList)
			panel:SetSize(defines.ScreenScale(60), defines.ScreenScale(60))
			panel.Slot = slot
			--panel.Paint = function()
			--	draw.RoundedBox(8, 0, 0, panel:GetWide(), panel:GetTall(), Color(0, 0, 0, 255))
			--end		
		else
			local tbl = items.Get(id)
			panel = vgui.Create("DModelPanel", self.bankList)
			panel:SetModel(tbl.Model)
			panel:SetTooltip(items.GetName(id, Bank[slot][ITEM_Q]))
			panel:SetSize(defines.ScreenScale(60),defines.ScreenScale(60))
			panel:SetCamPos(tbl.CamPos)
			panel:SetLookAt(tbl.LookAt)
			panel.Slot = slot
			panel.PaintOver = function() 
				if items.IsStackable(id) then
					draw.SimpleText(Bank[slot][ITEM_Q], "DermaDefaultBold", panel:GetWide()-1.5, panel:GetTall()-1.5, Color(255, 255, 255, 255), 2, 4) 
				end
				if panel:IsHovered() then
					draw.RoundedBox(8, 0, 0, panel:GetWide(), panel:GetTall(), Color(GetConVarNumber("background1"), GetConVarNumber("background2"), GetConVarNumber("background3"), 100))
					surface.SetDrawColor(GetConVarNumber("Healthforeground1"), GetConVarNumber("Healthforeground2"), GetConVarNumber("Healthforeground3"), GetConVarNumber("Healthforeground4"))
					surface.DrawOutlinedRect(0, 0, panel:GetWide(), panel:GetTall())
				end
			end
			panel.OnMousePressed = function()
				local menu = DermaMenu()
				menu:AddOption("Transfer to inventory", function() RunConsoleCommand("itemToInventory", panel.Slot, 1) end)
				if items.IsStackable(id) then
					menu:AddOption("Transfer X to inventory", function()
						Derma_StringRequest( "Question", 
							"How many do you want to transfer?", 
							"Type a number here.", 
							function( strTextOut ) RunConsoleCommand("itemToInventory", panel.Slot, strTextOut) end,
							function( strTextOut )  end,
							"Transfer", 
							"Cancel" 
						)
					end)
					menu:AddOption("Transfer all to inventory", function() RunConsoleCommand("itemToInventory", panel.Slot, -1) end)
				end
				menu:Open()
			end
		end
		self.bankList:AddItem(panel)
	end
end

function PANEL:Think()
	if not LocalPlayer():Alive() then self:Close() end
end

local bankMenu
function PANEL:Close()

	self:Remove()
	bankMenu = nil
	gui.EnableScreenClicker(false)
	RunConsoleCommand("bankFinished")
end
vgui.Register("BankMenu", PANEL, "DFrame")

usermessage.Hook("openBank", function()
	bankMenu = vgui.Create("BankMenu")
	RunConsoleCommand("requestBank")
end)

hook.Add("ChatEnded", "BANK::FixMouse", function()
	if bankMenu && bankMenu:IsValid() then
		gui.EnableScreenClicker(true)
	end
end)

net.Receive("networkBank", function(len)
	Bank = net.ReadTable()
	
	if IsValid(bankMenu) then
		bankMenu:RebuildItems()
	end
end)

function getBanking()
	return bankMenu
end