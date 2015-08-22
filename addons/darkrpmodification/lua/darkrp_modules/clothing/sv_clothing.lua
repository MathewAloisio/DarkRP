util.AddNetworkString("CLOTHING::NetworkPlayer")
util.AddNetworkString("CLOTHING::ClientRequest")
local function refreshPlayerClothing(player)
	if player.Clothing == nil then return end
	net.Start("CLOTHING::NetworkPlayer")
		net.WriteEntity(player)
		net.WriteTable(player.Clothing)
	net.Broadcast()
end
hook.Add("PlayerSetModel", "CLOTHING::ModelChanged", refreshPlayerClothing)

net.Receive("CLOTHING::ClientRequest", function()
	local entity = net.ReadEntity()
	if not entity:IsValid() then return end
	refreshPlayerClothing(entity)
end)

hook.Add("PlayerInitialSpawn", "CLOTHING::InitialSpawn", function(player)
	player.Clothing = {}
	for slot=0,TOTAL_CLOTHING_SLOTS do
		player.Clothing[slot] = 0
	end
	if file.Exists(string.format("roleplay/clothing/%s.txt", player:UniqueID()), "DATA") then
		player.Clothing = pon.decode(file.Read(string.format("roleplay/clothing/%s.txt", player:UniqueID()), "DATA"))
	end
	refreshPlayerClothing(player)
	for _,entity in pairs(_G.player.GetAll()) do
		if entity.Clothing ~= nil then
			net.Start("CLOTHING::NetworkPlayer")
				net.WriteEntity(entity)
				net.WriteTable(entity.Clothing)
			net.Send(player)
		end
	end
end)

hook.Add("EntityTakeDamage", "CLOTHING::TakeDamage", function(player, dmg)
	if not player:IsPlayer() then return end --We do player-damage scaling only.
	local attacker = dmg:GetAttacker()
	if IsValid(attacker) and (attacker:IsPlayer() or attacker:IsNPC()) and dmg:IsBulletDamage() ~= true then
		local lowerDamage = 0
		for slot=0,TOTAL_CLOTHING_SLOTS do
			if player.Clothing[slot] == 0 then continue end
			local flags = clothing.GetFlags(player.Clothing[slot])
			if flags == nil then continue end
			if flags[dmg:GetDamageType()] then
				lowerDamage = lowerDamage + (flags[dmg:GetDamageType()] * 0.01)
			end
		end
		dmg:SubtractDamage(lowerDamage)
	end
	return dmg:GetDamage()
end)

hook.Add("ScalePlayerDamage", "CLOTHING::ScaleDamage", function(player, hitgroup, dmg)
	if dmg:IsBulletDamage() then
		local slot = -1
		if hitgroup == 1 then --Head
			slot = 0
		elseif hitgroup == 2 or hitgroup == 3 then --Body
			slot = 3
		elseif hitgroup == 4 or hitgroup == 5 then --Arms
			slot = 2
		elseif hitgroup == 6 or hitgroup == 7 then --Legs
			slot = 4
		end	
		if slot == -1 then return end --Not damage we want to scale, this doesn't need to go further.
		if player.Clothing[slot] == 0 then return end --No armor in this slot, end function here.
		local flags = clothing.GetFlags(player.Clothing[slot])
		if flags == nil or flags[2] == nil then return end --This clothing doesn't affect bullet damage.
		local lowerDamage = 0
		lowerDamage = (flags[2] * 0.01)
		dmg:SetDamage(dmg:GetDamage() - lowerDamage)
	end
end)

concommand.Add("rp_removeclothing", function(player, cmd, args)
	if args[1] == nil then return end
	local slot = tonumber(args[1])
	if player.Clothing[slot] == 0 then return end
	DarkRP.notify(player, 2, 4, string.format("%s unequipped!", clothing.GetName(player.Clothing[slot])))
	player:RemoveClothing(slot)
end)

local PLAYER = FindMetaTable("Player")

function PLAYER:WearClothing(id)
	local slot = clothing.Get(id).Slot
	if self.Clothing[slot] ~= 0 then self:RemoveClothing(slot) end
	self.Clothing[slot] = id
	refreshPlayerClothing(self)
	file.Write(string.format("roleplay/clothing/%s.txt", self:UniqueID()), pon.encode(self.Clothing))
end

function PLAYER:RemoveClothing(slot)
	--if self.Clothing[slot] == 0 then return end
	local id = clothing.Get(self.Clothing[slot]).ItemID or 0
	if id ~= 0 then self:GiveInvItem(id, 1, 0, 0) end
	self.Clothing[slot] = 0
	refreshPlayerClothing(self)
	file.Write(string.format("roleplay/clothing/%s.txt", self:UniqueID()), pon.encode(self.Clothing))
end

function PLAYER:RemoveAllClothing()
	for slot=0,TOTAL_CLOTHING_SLOTS do
		if self.Clothing[slot] == 0 then continue end
		local id = clothing.Get(self.Clothing[slot]).ItemID or 0
		if id ~= 0 then self:GiveInvItem(id, 1, 0, 0) end
		self.Clothing[slot] = 0
	end
	refreshPlayerClothing(self)
	file.Write(string.format("roleplay/clothing/%s.txt", self:UniqueID()), pon.encode(self.Clothing))
end

function PLAYER:RemoveClothingID(id)
	local slot = clothing.Get(id).Slot
	if self.Clothing[slot] == id then
		self:RemoveClothing(slot)
		return true
	end
	return false
end