util.AddNetworkString("VW::RefreshEntity")
local function setChildrenVW(ply)
	for _,v in pairs(ents.GetAll()) do
		if v:GetParent() == ply then
			v:SetVW(ply:GetVW())
		end
	end
end

local ENTITY = FindMetaTable("Entity")

function ENTITY:SetVW(val)
	if self:IsPlayer() then
		self:ConCommand("stopsound")
		local wep = self:GetActiveWeapon()
		if IsValid(wep) then
			wep:SetVW(floor(num))
		end
	end
	self:SetNWInt( "VW", num)
	self:CollisionRulesChanged() --Now exposed CBaseEntity::CollisionRulesChanged() so our custom function was removed.
	net.Start("VW::RefreshEntity")
		net.WriteEntity(self)
	net.Broadcast()
	setChildrenVW(self)
end	

hook.Add("PlayerSpawnedNPC", "VW::SpawnNPC", function(player, npc)
	npc:SetVW(player:GetVW())
end)


hook.Add("PlayerSpawnedProp", "VW::SpawnedProp", function(player, _, entity)
	entity:SetVW(player:GetVW())
end)

hook.Add("PlayerSpawnedRagdoll", "VW::SpawnedRagdoll", function(player, _, index)
	local entity = ents.GetByIndex(index)
	entity:SetVW(player:GetVW())
end)

hook.Add("PlayerSpawnedSENT", "VW::SpawnedSENT", function(player, entity)
	entity:SetVW(player:GetVW())
end)

hook.Add("PlayerSpawnedVehicle", "VW::SpawnedVehicle", function(player, vehicle)
    vehicle:SetVW(player:GetVW())
end)

hook.Add("GravGunPickupAllowed", "VW::GravGunPickup", function(player, entity)
	if player:GetVW() ~= entity:GetVW() then return false end
end)

hook.Add("PhysgunPickup", "VW::PhysgunPickup", function(player, entity)
	if player:GetVW() ~= entity:GetVW() then return false end
end)

hook.Add("CanTool", "VW::ControlTool", function(player, trace)
	local entity = trace.Entity
	if IsValid(entity) and player:GetVW() ~= entity:GetVW() then return false end
end)

concommand.Add("rp_setvw", function(player, cmd, args)
	if not player:IsAdmin() then DarkRP.notify(player, 1, 4, "Admin only!") return end
	if #args < 2 then DarkRP.notify(player, 1, 4, "Usage: rp_setvw [player] [# vw (Default: 0)].") return end
	local target = FindPlayer(args[1])
	if not IsValid(target) then DarkRP.notify(player, 1, 4, "Could not find target!") return end
	local vw = tonumber(args[2])
	target:SetVW(vw)
	DarkRP.notify(player, 2, 4, string.format("You've set %s's Virtual World to %i.", target:Nick(), vw)))
	DarkRP.notify(player, 2, 4, string.format("%s set your Virtual World to %i.", player:Nick(), vw)))
end)

local function CheckPlayerVW(ply,cmd,args)
	if !ply:IsAdmin() then CAKE.SendError(ply, "Admin only!") return end
	if !args[1] then CAKE.SendError(ply,"Format: checkvw [who] <-- 0 = Default") return end
	local who = CAKE.FindPlayer(args[1])
	if !who or !IsValid(who) then CAKE.SendChat(ply, "Could not find player.") return end
	if !who:IsCharLoaded() then CAKE.SendChat(ply, "That person's player isn't loaded.") return end
	CAKE.SendError(ply, who:Nick().." is in the VW number "..who:GetVW().."!")
end
concommand.Add("rp_checkvw", function(player, cmd, args)
	if not player:IsAdmin() then DarkRP.notify(player, 1, 4, "Admin only!") return end
	if not args[1] then DarkRP.notify(player, 1, 4, "Usage: rp_checkvw [player].") return end
	local target = FindPlayer(args[1])
	if not IsValid(target) then DarkRP.notify(player, 1, 4, "Could not find target!") return end
	DarkRP.notify(player, 4, 4, string.format("%s is in Virtual World #%i.", target:GetVW()))
end)

hook.Add("PlayerShouldTakeDamage", "VW::ShouldTakeDamage", function(player, attacker)
	if player:GetVW() ~= attacker:GetVW() then return false end
end)

hook.Add("PlayerUse", "VW::PlayerUse", function(player, entity)
	if (pl:GetVW() ~= ent:GetVW()) then return false end
	return true
end)

hook.Add("InitPostEntity", "VW::InitPostEntity", function()
	for _,entity in pairs(ents.GetAll()) do
		entity:SetVW(-1)
	end
end)