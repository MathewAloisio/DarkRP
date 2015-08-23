local function legacyScale(ent, scale)
	if ent:GetBoneCount() ~= nil and ent:GetBoneCount() > 1 then
		local old = ent.BuildBonePositions
		ent.BuildBonePositions = function(...)	
			for bone=0,ent:GetBoneCount() do
				local matrix = ent:GetBoneMatrix(bone)
				if matrix then
					matrix:Scale(scale or Vector(1,1,1))
					ent:SetBoneMatrix(bone, matrix)
				end
			end
			if old then return old(...) end
		end
	else
		local matrix = Matrix()
		matrix:Scale(scale or Vector(1,1,1))
		ent:EnableMatrix("RenderMultiply", matrix)
	end	
end

do --Clothing editor
	local boneList = {
		"ValveBiped.Bip01_Pelvis",
		"ValveBiped.Bip01_Spine",
		"ValveBiped.Bip01_Spine1",
		"ValveBiped.Bip01_Spine2",
		"ValveBiped.Bip01_Spine4",
		"ValveBiped.Bip01_Neck1",
		"ValveBiped.Bip01_Head1",
		"ValveBiped.Bip01_R_Clavicle",
		"ValveBiped.Bip01_R_UpperArm",
		"ValveBiped.Bip01_R_Forearm",
		"ValveBiped.Bip01_R_Hand",
		"ValveBiped.Bip01_L_Clavicle",
		"ValveBiped.Bip01_L_UpperArm",
		"ValveBiped.Bip01_L_Forearm",
		"ValveBiped.Bip01_L_Hand",
		"ValveBiped.Bip01_R_Thigh",
		"ValveBiped.Bip01_R_Calf",
		"ValveBiped.Bip01_R_Foot",
		"ValveBiped.Bip01_R_Toe0",
		"ValveBiped.Bip01_L_Thigh",
		"ValveBiped.Bip01_L_Calf",
		"ValveBiped.Bip01_L_Foot",
		"ValveBiped.Bip01_L_Toe0"
	}


	local Pos = Pos or Vector(0,0,0)
	local Ang = Ang or Angle(0,0,0)
	local Scale = Scale or Vector(1,1,1)

	local sliders
	local parentBone = parentBone or "ValveBiped.Bip01_Pelvis"
	local currentSkin = currentSkin or 0
	local ClothingCam = ClothingCam or Vector(0,0,0)
	local selectedIndex = selectedIndex or -1
	local offsets = offsets or {}

	local function RemoveInstance(ind)
		if not IsValid(offsets[ind].VisualModel) then return end
		sliders.instanceList:Clear()
		offsets[ind].VisualModel:Remove()
		table.remove(offsets,ind)
		for index,model in pairs(offsets) do
			sliders.instanceList:AddChoice("Model "..index, {Model = model, Index = index})
		end	
	end

	local function ClearItems()
		sliders.instanceList:Clear()
		for _,v in pairs(offsets) do
			if IsValid(v.VisualModel) then v.VisualModel:Remove() end
		end
	end

	local function UpdateDoll()
		for i,Value in pairs(offsets) do
			local CachedBoneID = g_Doll:LookupBone(Value.Bone)
			if CachedBoneID != -1 && IsValid(Value.VisualModel) then
				local matrix = g_Doll:GetBoneMatrix(CachedBoneID)

				legacyScale(Value.VisualModel, Value.Scale or Vector(1,1,1))
				
				matrix:Rotate(Value.Ang or Angle(0,0,0))
				matrix:Translate(Value.Pos or Vector(0,0,0))
				
				Value.VisualModel:SetPos(matrix:GetTranslation())
				Value.VisualModel:SetAngles(matrix:GetAngles())
				
				if Value.VisualModel:GetSkin() ~= Value.Skin then
					Value.VisualModel:SetSkin(Value.Skin or 0)
				end
				if Value.VisualModel:GetMaterial() ~= Value.Material then
					Value.VisualModel:SetMaterial(Value.Material)
				end
			end
		end
	end

	local function ClothingEditorOff()
		sliders:Remove()

		hook.Remove("CalcView","ClothingEditor")
		hook.Remove("Think","UpdateDoll")
		hook.Remove("CreateMove","StopMovement")
		g_Doll:Remove()
		ClearItems()
	end

	local function AddVisualInstance(mdlPath)
		--if !util.IsValidModel(mdlPath) then ErrorNoHalt("Model Not Valid") return end
		local mdl = ClientsideModel(mdlPath,RENDERGROUP_OPAQUE)
		local t = {Bone = parentBone, Pos = Vector(0,0,0), Ang = Angle(0,0,0), Scale = Vector(1,1,1), Model = mdlPath, Skin = 0, Material = mdl:GetMaterial(), VisualModel = mdl}			
		local id = table.insert(offsets,t)
		
		local choiceID = sliders.instanceList:AddChoice("Model "..id, {Model = mdl, Index = id})
		sliders.instanceList:ChooseOptionID(choiceID)
	end

	local noChange = false
	local SLIDERS = {}
	function SLIDERS:Init()
		self:SetTitle("Clothing Editor")
		self:SetSize(200,ScrH())
		self:SetKeyboardInputEnabled(true)
		
		self.Form = vgui.Create("DForm",self)
		self.Form:SetKeyboardInputEnabled(true)
		self.Form:SetWide(190)
		self.Form:SetPos(5,25)
		self.Form:SetName("Clothing Editor!")
		
		self.itemList = self.Form:ComboBox("Clothing IDs")
		self.itemList:SetTall(100)
		for i,v in pairs(clothing.GetAll()) do
			self.itemList:AddChoice(i)
		end
		
		self.itemList.OnSelect = function(panel, index, value)
			self:SetItem(clothing.GetData(value))
		end
		
		
		self.bones = self.Form:ComboBox("Parent Bone")
		self.bones.OnSelect = function(panel, index, value) self:SetBone(value) end

		for i,v in pairs(boneList) do
			self.bones:AddChoice(v)
		end
		
		self.skinList = self.Form:ComboBox("Skin")
		self.skinList.OnSelect = function(panel, index, value) self:SetSkin(value) end
		self.skinList:AddChoice("0")
		
		self.instanceList = self.Form:ComboBox("Item")
		self.instanceList:SetTall(100)
		
		self.SetMatButt = self.Form:Button("Set Model Material")
		self.SetMatButt.DoClick = function()
			if offsets[selectedIndex] == nil or not IsValid(offsets[selectedIndex].VisualModel) then return end
			Derma_StringRequest( "Enter the material path", 
				"Example: models/props_combine/tprings_globe", 
				"", 
				function( strTextOut )
					if strTextOut == "" then 
						self:SetMaterial()
					else
						self:SetMaterial(strTextOut) 
					end
				end,
				function( strTextOut ) end,
				"Add", 
				"Cancel" )
		end
		
		self.ResMatButt = self.Form:Button("Reset Model Material")
		self.ResMatButt.DoClick = function()
			if offsets[selectedIndex] == nil or not IsValid(offsets[selectedIndex].VisualModel) then return end
			self:SetMaterial()
		end
		
		self.AddInstance = self.Form:Button("Add Visual Model")
		self.AddInstance.DoClick = function()
		
			Derma_StringRequest( "Add Visual Model", 
				"Paste a Model Path", 
				"", 
				function( strTextOut ) AddVisualInstance(strTextOut) end,
				function( strTextOut ) end,
				"Add", 
				"Cancel" )
		end
		
		self.RemoveInstance = self.Form:Button("Remove Selected Model")
		self.RemoveInstance.DoClick = function() RemoveInstance(selectedIndex) end

		self.MR = self.Form:NumSlider("Translate X", nil, -100, 100, 0 )
		self.MR.OnValueChanged = function(s,v) self:OnSliderChanged("MR",v) end
		self.MR.Label:SetTextColor(Color(255,0,0,255))
		self.MR:SetDecimals(2)
		
		self.MF = self.Form:NumSlider("Translate Y", nil, -100, 100, 0 )
		self.MF.OnValueChanged = function(s,v) self:OnSliderChanged("MF",v) end
		self.MF.Label:SetTextColor(Color(0,255,0,255))
		self.MF:SetDecimals(2)
		
		self.MU = self.Form:NumSlider("Translate Z", nil, -100, 100, 0 )
		self.MU.OnValueChanged = function(s,v) self:OnSliderChanged("MU",v) end
		self.MU.Label:SetTextColor(Color(0,0,255,255))
		self.MU:SetDecimals(2)
		
		self.RR = self.Form:NumSlider("Rotate Pitch", nil, -360, 360, 0 )
		self.RR.OnValueChanged = function(s,v) self:OnSliderChanged("RR",v) end
		self.RR.Label:SetTextColor(Color(255,0,0,255))
		self.RR:SetDecimals(2)
		
		self.RU = self.Form:NumSlider("Rotate Yaw", nil, -360, 360, 0 )
		self.RU.OnValueChanged = function(s,v) self:OnSliderChanged("RU",v) end
		self.RU.Label:SetTextColor(Color(0,0,255,255))
		self.RU:SetDecimals(2)
		
		self.RF = self.Form:NumSlider("Rotate Roll", nil, -360, 360, 0 )
		self.RF.OnValueChanged = function(s,v) self:OnSliderChanged("RF",v) end
		self.RF.Label:SetTextColor(Color(0,255,0,255))
		self.RF:SetDecimals(2)
		
		self.SX = self.Form:NumSlider("Scale X", nil, -5, 5, 0 )
		self.SX.OnValueChanged = function(s,v) self:OnSliderChanged("SX",v) end
		self.SX.Label:SetTextColor(Color(0,0,255,255))
		self.SX:SetDecimals(2)

		self.SY = self.Form:NumSlider("Scale Y", nil, -5, 5, 0 )
		self.SY.OnValueChanged = function(s,v) self:OnSliderChanged("SY",v) end
		self.SY.Label:SetTextColor(Color(255,0,0,255))
		self.SY:SetDecimals(2)
		
		self.SZ = self.Form:NumSlider("Scale Z", nil, -5, 5, 0 )
		self.SZ.OnValueChanged = function(s,v) self:OnSliderChanged("SZ",v) end
		self.SZ.Label:SetTextColor(Color(0,255,0,255))
		self.SZ:SetDecimals(2)
		
		self.instanceList.OnSelect = function(panel, index, value)
			selectedIndex = index
			noChange = true
			self.MU:SetValue(offsets[index].Pos.z or 0)
			self.MR:SetValue(offsets[index].Pos.x or 0)
			self.MF:SetValue(offsets[index].Pos.y or 0)
			self.RU:SetValue(offsets[index].Ang.yaw or 0)
			self.RR:SetValue(offsets[index].Ang.pitch or 0)
			self.RF:SetValue(offsets[index].Ang.roll or 0)
			self.SX:SetValue(offsets[index].Scale.x or 1)
			self.SY:SetValue(offsets[index].Scale.y or 1)
			noChange = false
			self.SZ:SetValue(offsets[index].Scale.z or 1)
			self.bones:SetValue(offsets[index].Bone)
			self:RebuildSkinList()
		end
		
		self.dump = self.Form:Button("Dump Code to Clipboard!")
		self.dump.DoClick = function() self:Dump() end
		
	end
	
	function SLIDERS:OnSliderChanged(moveType,value)
		if not offsets[selectedIndex] then return end
		if moveType == "MU" then
			Pos.z = value
		elseif moveType == "MR" then
			Pos.x = value
		elseif moveType == "MF" then
			Pos.y = value
		elseif moveType == "RF" then
			Ang.roll = value
		elseif moveType == "RU" then
			Ang.yaw = value
		elseif moveType == "RR" then
			Ang.pitch = value
		elseif moveType == "SX" then
			Scale.x = value
		elseif moveType == "SY" then
			Scale.y = value
		elseif moveType == "SZ" then
			Scale.z = value
		end
		if noChange then return end
		offsets[selectedIndex].Pos = Vector(Pos.x,Pos.y,Pos.z)
		offsets[selectedIndex].Ang = Angle(Ang.pitch,Ang.yaw,Ang.roll)
		offsets[selectedIndex].Scale = Vector(Scale.x,Scale.y,Scale.z)

	end
	function SLIDERS:Close()
		ClothingEditorOff()
	end

	function SLIDERS:SetItem(clothingPos)
		ClearItems()

		if clothingPos then
			offsets = table.Copy(clothingPos)
			for index,data in pairs(offsets) do
				local mdl = ClientsideModel(data.Model,RENDERGROUP_OPAQUE)
				offsets[index].VisualModel = mdl
			end
		end
	end

	function SLIDERS:SetBone(b)
		if not offsets[selectedIndex] then return end
		print(b)
		parentBone = b
		offsets[selectedIndex].Bone = parentBone
	end
	
	function SLIDERS:SetMaterial(material)
		if not offsets[selectedIndex] then return end
		offsets[selectedIndex].Material = material
	end

	function SLIDERS:SetSkin(skin)
		if not offsets[selectedIndex] then return end
		currentSkin = skin
		offsets[selectedIndex].Skin = currentSkin
	end
	
	function SLIDERS:RebuildSkinList()
		if not offsets[selectedIndex] or not IsValid(offsets[selectedIndex].VisualModel) then return end
		self.skinList:Clear()
		local skin_count = offsets[selectedIndex].VisualModel:SkinCount()-1
		if skin_count > 0 then
			for skin=0,skin_count do
				self.skinList:AddChoice(tostring(skin))
			end
		end
	end
	
	function SLIDERS:Dump()
		local str = "if CLIENT then\n\tCLOTHING.ClothingData = {\r\n"
		
		local num = 1
		for instIndex,instData in pairs(offsets) do
			if instData.Bone == nil then 
				chat.AddText(Color(255, 0, 25), "[ERROR]", Color(200, 200, 200), string.format("Couldn't dump ClothingData to clipboard because Model[%i].Bone is nil.", instIndex))
				return
			end
			local x,y,z = 0,0,0
			local pitch,yaw,roll = 0,0,0
			local sx,sy,sz = 1,1,1
			local comma = ","
			if num >= table.Count(offsets) then comma = "" end
			if instData.Pos then
				x,y,z = instData.Pos.x,instData.Pos.y,instData.Pos.z
			end
			if instData.Ang then
				pitch,yaw,roll = instData.Ang.pitch,instData.Ang.yaw,instData.Ang.roll
			end
			if instData.Scale then
				sx,sy,sz = instData.Scale.x,instData.Scale.y,instData.Scale.z
			end
			if instData.Skin == nil then instData.Skin = 0 end
			if instData.Material == nil then instData.Material = instData.VisualModel:GetMaterial() end
			if instIndex == 1 then
				str = str .."\t\t{Bone = \""..instData.Bone.."\", Pos = Vector("..x..","..y..","..z.."), Ang = Angle("..pitch..","..yaw..","..roll.."), Scale = Vector("..sx..","..sy..","..sz.."), Model = \""..instData.Model.."\", Skin = "..instData.Skin..", Material = \""..instData.Material.."\"}"..comma
			else
				str = str .."\n\t\t{Bone = \""..instData.Bone.."\", Pos = Vector("..x..","..y..","..z.."), Ang = Angle("..pitch..","..yaw..","..roll.."), Scale = Vector("..sx..","..sy..","..sz.."), Model = \""..instData.Model.."\", Skin = "..instData.Skin..", Material = \""..instData.Material.."\"}"..comma
			end
			num = num + 1
		end
		str = str .."\r\t}\nend"
		SetClipboardText(str)
	end
	vgui.Register("ClothingInfo",SLIDERS,"DFrame")

	local function ClothingEditorView(pl,origin,angles,fov)
		local amt = 200*FrameTime()
		if input.IsKeyDown(KEY_LSHIFT) then
			amt = 1000*FrameTime()
		elseif input.IsKeyDown(KEY_LCONTROL) then
			amt = 20*FrameTime()
		end

		if input.IsKeyDown(KEY_W) then
			ClothingCam = ClothingCam+LocalPlayer():GetAimVector()*amt
		end
		if input.IsKeyDown(KEY_S) then
			ClothingCam = ClothingCam+LocalPlayer():GetAimVector()*-amt
		end
		if input.IsKeyDown(KEY_A) then
			ClothingCam = ClothingCam+LocalPlayer():GetRight()*-amt
		end
		if input.IsKeyDown(KEY_D) then
			ClothingCam = ClothingCam+LocalPlayer():GetRight()*amt
		end
		
		local t = {}
		t.origin = ClothingCam
		t.angles = angles
		
		return t
	end

	concommand.Add("rp_editclothing", function()
		if g_Doll ~= nil and g_Doll:IsValid() then --Close menu
			ClothingEditorOff()	
		else
			if ValidPanel(sliders) then
				sliders:Remove()
			end
			
			offsets = {}
			sliders = vgui.Create("ClothingInfo")
			hook.Add("CalcView","ClothingEditor",ClothingEditorView)
			hook.Add("CreateMove","StopMovement",function(cmd) cmd:SetSideMove(0) cmd:SetUpMove(0) cmd:SetForwardMove(0) end)
			g_Doll = ClientsideModel("models/Humans/Group01/male_06.mdl",RENDERGROUP_OPAQUE)
			g_Doll:SetPos(LocalPlayer():GetPos()+LocalPlayer():GetRight()*60)
			ClothingCam = g_Doll:GetPos()+g_Doll:GetForward()*100
			hook.Add("Think","UpdateDoll",UpdateDoll)
		end
	end)
end

--Clothes rendering below.
hook.Add("NetworkEntityCreated", "CLOTHING:NewPVSPlayer", function(entity)
	if not entity:IsPlayer() then return end
	if entity.Clothing ~= nil then return end
	net.Start("CLOTHING::ClientRequest")
		net.WriteEntity(entity)
	net.SendToServer()
end)

local function removeClothingSlot(player, slot)
	for _,entity in pairs(player.Clothing[slot].components) do
		entity:Remove()
	end
	player.Clothing[slot].rendered_id = nil
end

local getClothingData = clothing.GetData
net.Receive("CLOTHING::NetworkPlayer", function(len)
	local player = net.ReadEntity()
	if not IsValid(player) then return end
	local first
	if player.Clothing == nil then 
		player.Clothing = {}
		first = true
	end
	local tbl = net.ReadTable()
	for slot=0,TOTAL_CLOTHING_SLOTS do
		if first ~= nil then player.Clothing[slot] = {} end
		player.Clothing[slot].id = tbl[slot] or 0
		if player.Clothing[slot].components == nil then player.Clothing[slot].components = {} end
		if player.Clothing[slot].rendered_id ~= nil and player.Clothing[slot].rendered_id ~= player.Clothing[slot].id then removeClothingSlot(player, slot) end
		if player.Clothing[slot].id == 0 then continue end
		player.Clothing[slot].rendered_id = player.Clothing[slot].id
		for i,v in pairs(getClothingData(player.Clothing[slot].id)) do
			player.Clothing[slot].components[i] = ClientsideModel(v.Model,RENDERGROUP_OPAQUE)
			player.Clothing[slot].components[i]:SetMaterial((v.Material ~= "" and v.Material) or nil)
			if v.Skin ~= nil then
				player.Clothing[slot].components[i]:SetSkin(v.Skin)
			end
			legacyScale(player.Clothing[slot].components[i], v.Scale or Vector(1,1,1))
		end
	end
end)

hook.Add("EntityRemoved", "CLOTHING::RemovePlayer", function(entity)
	if not entity:IsPlayer() or entity.Clothing == nil then return end
	for slot=0,TOTAL_CLOTHING_SLOTS do
		removeClothingSlot(entity, slot)
	end
end)

hook.Add("PostPlayerDraw", "CLOTHING::RenderPlayer", function(player)
	if player.Clothing == nil then return end
	for slot=0,TOTAL_CLOTHING_SLOTS do
		if player.Clothing[slot].id == 0 then continue end
		local tbl = getClothingData(player.Clothing[slot].id)
		for i,entity in pairs(player.Clothing[slot].components) do
			local boneID = player:LookupBone(tbl[i].Bone)
			if boneID ~= -1 and IsValid(entity) then
				local matrix = player:GetBoneMatrix(boneID)

				matrix:Rotate(tbl[i].Angles or Angle(0,0,0))
				matrix:Translate(tbl[i].Pos or Vector(0,0,0))

				entity:SetPos(matrix:GetTranslation())
				entity:SetAngles(matrix:GetAngles())
			end
		end
	end
end)