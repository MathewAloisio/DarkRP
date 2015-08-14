util.AddNetworkString("CORPSE::PlayerDead")
util.AddNetworkString("CORPSE::PlayerSpawn")

local function createCorpse(player)
	local corpse = ents.Create("prop_ragdoll")
	corpse:SetPos(player:GetPos())
	corpse:SetAngles(player:GetAngles())
	corpse:SetModel(player:GetModel())
	
	local v = player:GetVelocity()/5
	local num = corpse:GetPhysicsObjectCount() - 1

	for i=0, num do
		local bone = corpse:GetPhysicsObjectNum(i)
		if IsValid(bone) then
		local bp, ba = player:GetBonePosition(corpse:TranslatePhysBoneToBone(i))
		if bp and ba then
			bone:SetPos(bp)
			bone:SetAngles(ba)
		end

		bone:SetVelocity(v)
		end
	end

	corpse:Spawn()
	corpse:Activate()

	corpse:SetCollisionGroup(COLLISION_GROUP_WEAPON)

	local prop = ents.Create("prop_physics")
	prop:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	prop:SetPos(corpse:GetPos())
	prop:SetCollisionGroup(COLLISION_GROUP_WORLD)
	prop:SetNoDraw(true)

	prop:Spawn()
	prop:Activate()

	corpse.block = prop
	corpse.owner = player
	corpse.IsCorpse = true

	constraint.Weld(corpse, prop, 0, 0, 0, false)

	player.corpse = corpse
	return corpse
end

local PLAYER = FindMetaTable("Player")

function PLAYER:DeathMode()
	if self.corpse and IsValid(self.corpse) then 
		SafeRemoveEntity(self.corpse.block)
		SafeRemoveEntity(self.corpse) 
	end
	self.deathmode = true
	local entity = createCorpse(self)
	timer.Simple(0.1, function()
		net.Start("CORPSE::PlayerDead")
			net.WriteFloat(entity:EntIndex())
			net.WriteFloat(self.NextSpawnTime - CurTime())
		net.Send(self)
	end)
end

function PLAYER:FinishDeath()
	--TODO: Player was killed while in death mode.
end

hook.Add("DoPlayerDeath", "DEATH::DoPlayerDeath", function(player, killer, dmginfo)
	if killer:IsPlayer() and player ~= killer then
		player:DeathMode()
	end
end)

hook.Add("PlayerDisconnected", "DEATH::PlayerDisconnected", function(player)
	if player.corpse && IsValid(player.corpse) then
		SafeRemoveEntity(player.corpse.block)
		SafeRemoveEntity(player.corpse)
	end
end)

hook.Add("PlayerSpawn", "DEATH::PlayerSpawn", function(player)
	player.bloodFrom = {}
	
	net.Start("DEATH::PlayerSpawn")
	net.Send(player)
end)

hook.Add("EntityTakeDamage", "Corpse.EntityTakeDamage", function(entity, dmginfo)
	local attacker = dmginfo:GetAttacker()
	if entity.IsCorpse && !(entity.dmg && entity.dmg > 30) && attacker:IsPlayer() then
		entity.dmg = (entity.dmg or 0) + dmginfo:GetDamage()
		if entity.dmg > 30 and entity.owner.deathmode == true then
			entity.owner:FinishDeath()
			entity:EmitSound("vo/npc/male01/pain0"..math.random(5, 9)..".wav", 100, 100)
		end
	end
	if entity:IsPlayer() and attacker:IsPlayer() then
		if dmginfo:IsDamageType(DMG_BULLET) or dmginfo:IsDamageType(DMG_SLASH) or dmginfo:IsDamageType(DMG_BUCKSHOT) or dmginfo:IsDamageType(DMG_BLAST) then
			if entity:GetPos():Distance(attacker:GetPos()) < MAX_INTERACT_DIST then
				attacker.bloodFrom[entity:Nick()] = true
			end
		end
	end
end)
