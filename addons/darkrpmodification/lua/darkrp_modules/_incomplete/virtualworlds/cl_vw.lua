local function refreshVirtualEntity(entity)
	if entity:GetVW() == -1 then return end
	if entity:GetVW() ~= LocalPlayer():GetVW() and entity.not_rendered == nil then
		entity.not_rendered = true
		entity.RenderOverride = function() end
		entity:SetCollisonGroup(10)
		entity:DrawShadow(false)
		entity:DestroyShadow()
		if entity:IsWeapon() then
			entity:SetColor(0,0,0,0)
			entity:SetRenderMdoe(4)
		end
	elseif entity.not_rendered ~= nil and entity.not_rendered == true then
		entity.not_rendered = nil
		entity.RenderOverride = nil
		entity:SetCollisionGroup(entity.cg)
		entity:MarkShadowAsDirty()
		entity:DrawShadow(true)
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
	refreshVirtualEntity(entity)
end)

--[[
net.Receive("shadowUpdate", function(len)
	for i,v in pairs(NotDrawn) do
		if i:IsValid() then
			i:DestroyShadow()
		end
	end
end)
]]--

hook.Add("PrePlayerDraw", "VW::PrePlayerDraw", function(player) if LocalPlayer() ~= player and LocalPlayer():GetVW() ~= player:GetVW() then return true end end)

hook.Add("PlayerFootstep", "VW::PlayerFootstep", function(player)
	if LocalPlayer() ~= player and LocalPlayer():GetVW() ~= player:GetVW() then
		return true
	end
end)

hook.Add("OnEntityCreated", "VW::CLEntityCreated", function(entity)
	entity.cg = entity:GetCollisionGroup()
	if entity:IsWeapon() then
		entity.ogcol = entity:GetColor()
	end
end)