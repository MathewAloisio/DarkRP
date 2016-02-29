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
	if val == nil or type(val) ~= "number" then return end --Redundancy
	val = math.floor(val) --Redundancy
	if not self:GetCustomCollisionCheck() then self:SetCustomCollisionCheck(true) end
	if self:IsPlayer() then
		ForceConsoleCommand(player, "stopsound")
		local wep = self:GetActiveWeapon()
		if IsValid(wep) then wep:SetVW(val) end
	end
	self:SetNWInt("VW", val)
	self:CollisionRulesChanged() --Now exposed CBaseEntity::CollisionRulesChanged() so our custom function was removed. (Fucking finally only took 3 years of asking, and someone else did it... not even Garry.)
	timer.Simple(0.35, function()
		net.Start("VW::RefreshEntity")
			net.WriteEntity(self)
		net.Broadcast()
		if self:IsPlayer() then
			for _,entity in pairs(ents.GetAll()) do
				if entity:GetVW() == -1 then continue end
				if entity:GetVW() ~= self:GetVW() then
					net.Start("VW::RefreshEntity")
						net.WriteEntity(entity)
					net.Send(self)
					entity:SetPreventTransmit(self, true) --Visible to us again yay! Source will now send us info about this entity once again. :D
				else
					entity:SetPreventTransmit(self, false) --Lets pretend we don't even exist. :) Source will no longer send us info about this entity. (Since we're making it seem like this entity doesn't exist to us, why bother receiving info about it til we're ready to draw it again?)
					net.Start("VW::RefreshEntity")
						net.WriteEntity(entity)
					net.Send(self)
				end
			end
			--hook.Call("VW::OnChanged", self) --for now we only need the clientside one.
		end
	end)
	setChildrenVW(self)
end	

hook.Add("PlayerInitialSpawn", "VW::PlayerInitialSpawn", function(player) --This we do need because we never want players to be part of the global virtual world. (Default returned value, -1.)
	player:SetVW(0)
end)

--[[ --Lets disable this, we'll manually choose when to set their VW back to 0.
hook.Add("PlayerSpawn", "VW::PlayerSpawn", function(player)
	player:SetVW(0)
end)
]]--

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
	vehicle:SetNWString("CustomName", "Spawned Car")
end)

hook.Add("GravGunPickupAllowed", "VW::GravGunPickup", function(player, entity)
	if entity.isBlocker ~= nil then return false end
	if player:GetVW() ~= entity:GetVW() then return false end
end)

hook.Add("PhysgunPickup", "VW::PhysgunPickup", function(player, entity)
	if entity.isBlocker ~= nil then return false end
	if player:GetVW() ~= entity:GetVW() then return false end
end)

hook.Add("CanTool", "VW::ControlTool", function(player, trace)
	local entity = trace.Entity
	if IsValid(entity) and (player:GetVW() ~= entity:GetVW() or entity.isBlocker ~= nil) then return false end
end)

concommand.Add("rp_setvw", function(player, cmd, args)
	if not player:IsAdmin() then DarkRP.notify(player, 1, 4, "Admin only!") return end
	if #args < 2 then DarkRP.notify(player, 1, 4, "Usage: rp_setvw [player] [# vw (Default: 0)].") return end
	local target = DarkRP.findPlayer(args[1])
	if not IsValid(target) then DarkRP.notify(player, 1, 4, "Could not find target!") return end
	local vw = tonumber(args[2])
	target:SetVW(vw)
	DarkRP.notify(player, 2, 4, string.format("You've set %s's Virtual World to %i.", target:Nick(), vw))
	DarkRP.notify(player, 2, 4, string.format("%s set your Virtual World to %i.", player:Nick(), vw))
end)

concommand.Add("rp_checkvw", function(player, cmd, args)
	if not player:IsAdmin() then DarkRP.notify(player, 1, 4, "Admin only!") return end
	if not args[1] then DarkRP.notify(player, 1, 4, "Usage: rp_checkvw [player].") return end
	local target = DarkRP.findPlayer(args[1])
	if not IsValid(target) then DarkRP.notify(player, 1, 4, "Could not find target!") return end
	DarkRP.notify(player, 4, 4, string.format("%s is in Virtual World #%i.", target:Nick(), target:GetVW()))
end)

hook.Add("PlayerShouldTakeDamage", "VW::ShouldTakeDamage", function(player, attacker)
	if attacker:GetVW() ~= -1 and player:GetVW() ~= attacker:GetVW() then return false end
end)

hook.Add("PlayerUse", "VW::PlayerUse", function(player, entity)
	if (pl:GetVW() ~= ent:GetVW()) then return false end
	return true
end)

hook.Add("InitPostEntity", "VW::InitPostEntity", function()
	for _,entity in pairs(ents.GetAll()) do
		if entity:IsPlayer() then continue end
		if entity:IsDoor() then --Sadly Source is buggy as shit when it comes to doors, and players can still open doors from other VWs by clicking use beside them and not actually on them.
			entity:SetVW(0)
			continue
		end
		--entity:SetVW(-1)
	end
end)