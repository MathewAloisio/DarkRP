local Exp = Exp or {}
local Level = Level or {}

for i,v in pairs(skills.GetAll()) do
	Exp[i] = 0
	Level[i] = 1
	
	if v.hookUsed ~= nil then
		hook.Add(v.hookUsed,i.."Increase", function(player)
			if player ~= LocalPlayer() then return end
			Exp[i] = Exp[i] + 1
		end)
	end
end

--Sent upon joining the server
usermessage.Hook("expSet",function( um ) Exp[um:ReadString()] = um:ReadLong() end)
usermessage.Hook("levelSet",function( um ) Level[um:ReadString()] = um:ReadChar() end)

--UI Below.

local function buildSkillsTab()
	local SkillMenu = vgui.Create("DPanelList")
	SkillMenu:SetSpacing(1)
	SkillMenu:SetPadding(7)
	SkillMenu:StretchToParent(5,25,5,5)
	SkillMenu:SetSkin("DarkRP")
	for i,v in pairs(skills.GetAll()) do
		local panel = vgui.Create("DPanel")
		panel:SetTall(64)
		panel.Paint = function() 
			draw.RoundedBox(4, 0, 0, panel:GetWide(), panel:GetTall(), Color(GetConVarNumber("Healthbackground1"), GetConVarNumber("Healthbackground2"), GetConVarNumber("Healthbackground3"), GetConVarNumber("Healthbackground4")))
			draw.SimpleText(i,"Trebuchet24",panel:GetWide()-5,15,Color(240,140,0,255),2,1)
			draw.SimpleText("Level "..Level[i],"Trebuchet24",5,15,Color(20,20,130,255),0,1)
			local xpneeded = v.getNeeded(LocalPlayer())
			draw.SimpleText(Exp[i].."/"..xpneeded,"HudHintTextLarge",panel:GetWide()-5,30,Color(255,255,255,255),2,1)
			draw.RoundedBox(2,5,panel:GetTall()-20,panel:GetWide()-10,15,Color(10,10,10,255))
			if Exp[i] > 0 then
				draw.RoundedBox(2,7,panel:GetTall()-18,Exp[i]/xpneeded*panel:GetWide()-14,11,Color(255,255,10,255))
			end
		end
		SkillMenu:AddItem(panel)
	end
	return SkillMenu
end
 
hook.Add("F4MenuTabs", "Skills::AddTab", function()
	local tabNr = DarkRP.addF4MenuTab("Skills", buildSkillsTab())
	DarkRP.switchTabOrder(tabNr, 2)
end)