local ChatterName = ChatterName or "None"
local NPCChatMenu = NPCChatMenu or nil

--Chat Menu
local PANEL = {}

function PANEL:Init()
	self:SetSize(700,200)
	self:ShowCloseButton(false)
	self:SetTitle(ChatterName)
	self:SetDraggable(false)
	self:SetPos(ScrW()*0.5-350,ScrH()-250)
	self:SetSkin("DarkRP")
	self.leftpan = vgui.Create("DPanel",self)
	self.leftpan:StretchToParent(5,25,self:GetWide()-120,5)
	
	self.ico = vgui.Create("DModelPanel",self.leftpan)
	self.ico:SetSize(200,200)
	self.ico:SetPos(-45,self.leftpan:GetTall() - 200)
	self.ico.LayoutEntity = function(wtf,Entity )
			if ( self.ico.bAnimated ) then
				self.ico:RunAnimation()
			end
			Entity:SetAngles(Angle( 0, 40,  0))
		end
	
	self.rightpan = vgui.Create("DPanelList",self)
	self.rightpan:SetPadding(6)
	self.rightpan:EnableVerticalScrollbar()
	self.rightpan:StretchToParent(125,25,5,95)
	self.blist = vgui.Create("DPanelList",self)
	self.blist:SetPadding(6)
	self.blist:StretchToParent(125,self:GetTall()-90,5,5)
	self.blist:EnableVerticalScrollbar()
end

function PANEL:Close()
	gui.EnableScreenClicker(false)
	self:Remove()
end

function PANEL:SetNPC(ent)
	self.Ent = ent
	self.ico:SetModel(self.Ent:GetModel())
	self.ico:SetLookAt(Vector(0,0,64))
	self.ico:SetCamPos(Vector(30,30,64))
end
vgui.Register("NPCChatMenu", PANEL, "DFrame")

local function addReply(str, num)
	if not ValidPanel(NPCChatMenu) then return end
	local b = vgui.Create("DButton")
	b:SetText(str)
	b.DoClick = function() RunConsoleCommand("talkto", NPCChatMenu.Ent:EntIndex(), num) end
	NPCChatMenu.blist:AddItem(b)
end

local function addNPCText(txt)
	if not ValidPanel(NPCChatMenu) then return end
	local lbl = Label(txt)
	lbl:SetWrap(true)
	lbl:SetTall(50)
	NPCChatMenu.rightpan:AddItem(lbl)
end

local ChattingNPC = ChattingNPC or nil
local CurrentChat = CurrentChat or 0

--get and set correct starting node
local function beginChatting(um)
	local ent = ents.GetByIndex(um:ReadShort())
	if not IsValid(ent) then return end
	if ValidPanel(NPCChatMenu) then return end
	ChattingNPC = ent
	CurrentChat = 1
	ChatterName = um:ReadString()
	NPCChatMenu = vgui.Create("NPCChatMenu")
	NPCChatMenu:SetNPC(ent)
	addNPCText(defines.Dialog[ChatterName][1].Text)
	
	local id = um:ReadShort()
	while (id ~= 0) do
		addReply(defines.Replies[ChatterName][id].Text,id)
		id = um:ReadShort()
	end
	gui.EnableScreenClicker(true)
end
usermessage.Hook("beginChatting", beginChatting)

--run a getnodebyid and set the new current node
local function npcResponse(um)
	CurrentChat = um:ReadShort()
	NPCChatMenu.rightpan:Clear()
	NPCChatMenu.blist:Clear()
	addNPCText(defines.Dialog[ChatterName][CurrentChat].Text)
	
	local id = um:ReadShort()
	while (id ~= 0) do
		addReply(defines.Replies[ChatterName][id].Text,id)
		id = um:ReadShort()
	end
end
usermessage.Hook("NPCRespond", npcResponse)

local function endChat()
	NPCChatMenu:Remove()
	gui.EnableScreenClicker(false)
	hook.Call("ChatEnded", GAMEMODE)
end
usermessage.Hook("endChat",endChat)

hook.Add("PlayerBindPress", "NPCUse", function(player, bind, pressed) 
	if string.find(bind, "+use") and not ValidPanel(NPCChatMenu) then
		local tr = {}
		tr.start = LocalPlayer():GetShootPos()
		tr.endpos = tr.start + LocalPlayer():GetAimVector()*110
		tr.filter = LocalPlayer()
		tr = util.TraceLine(tr)
		if tr.MatType == MAT_GLASS then
			local start = tr.HitPos
			tr = {}
			tr.start = start+LocalPlayer():GetAimVector()*20
			tr.endpos = tr.start + LocalPlayer():GetAimVector()*50
			tr = util.TraceLine(tr)			
		end
		if tr.Entity:IsValid() and tr.Entity:GetClass() == "npc_generic" then
			RunConsoleCommand("talkto", tr.Entity:EntIndex())
		end
	end
end)