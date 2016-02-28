local notDrawn = {}
local function refreshVirtualEntity(entity)
	if not IsValid(entity) then return end
	if entity:GetVW() == -1 then return end
	if entity:GetVW() ~= LocalPlayer():GetVW() and entity.not_rendered == nil then
		entity.not_rendered = true
		if entity.RenderOverride ~= nil then entity.ogRO = entity.RenderOverride end
		entity.RenderOverride = function() end
		entity:SetCollisionGroup(10)
		entity:DrawShadow(false)
		entity:DestroyShadow()
		notDrawn[entity] = true
		if entity:IsPlayer() then entity.ogwepcol = entity:GetWeaponColor() end
		if entity:IsWeapon() then
			entity:SetColor(Color(0,0,0,0))
			entity:SetRenderMode(4)
		end
	elseif entity.not_rendered ~= nil and entity.not_rendered == true and entity:GetVW() == LocalPlayer():GetVW() then
		if notDrawn[entity] ~= nil then notDrawn[entity] = nil end
		entity.not_rendered = nil
		entity.RenderOverride = entity.ogRO or nil
		if entity.cg ~= nil then entity:SetCollisionGroup(entity.cg) end
		entity:MarkShadowAsDirty()
		if entity.noshadow == nil then entity:DrawShadow(true) end
		if entity:IsPlayer() then
			if entity.ogwepcol ~= nil then entity:SetWeaponColor(entity.ogwepcol) end
		end
		if entity.ogcol ~= nil then
			entity:SetColor(entity.ogcol)
			entity:SetRenderMode(0)
		end
	end
end

hook.Add("NotifyShouldTransmit", "VW::ShouldTransmit", function(entity, _)
	refreshVirtualEntity(entity)
end)

net.Receive("VW::RefreshEntity", function(len)
	local entity = net.ReadEntity()
	if entity == LocalPlayer() then hook.Call("VW::OnChanged") end
	refreshVirtualEntity(entity)
end)

net.Receive("shadowUpdate", function(len)
	for entity,_ in pairs(notDrawn) do
		if entity:IsValid() then
			entity:DestroyShadow()
		end
	end
end)

hook.Add("PrePlayerDraw", "VW::PrePlayerDraw", function(player) if LocalPlayer() ~= player and LocalPlayer():GetVW() ~= player:GetVW() then return true end end)

hook.Add("PlayerFootstep", "VW::PlayerFootstep", function(player)
	if LocalPlayer() ~= player and LocalPlayer():GetVW() ~= player:GetVW() then
		return true
	end
end)

hook.Add("InitPostEntity", "VW::InitPostEntity", function()
	for _,entity in pairs(ents.GetAll()) do
		entity.cg = entity:GetCollisionGroup()
	end
end)

hook.Add("OnEntityCreated", "VW::CLEntityCreated", function(entity)
	entity.cg = entity:GetCollisionGroup()
	if entity:IsWeapon() then
		entity.ogcol = entity:GetColor()
	end
	refreshVirtualEntity(entity)
end)