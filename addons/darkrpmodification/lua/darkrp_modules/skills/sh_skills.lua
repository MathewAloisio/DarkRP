local function UpdateJumpPower(player)
	player:SetJumpPower(GAMEMODE.Config.jumppower+(player:GetLevel("Acrobatics")*2))
end
hook.Add("PlayerSpawn", "Skills:UpdateJumpPower", UpdateJumpPower)

hook.Add("UpdatePlayerSpeed", "Skills::UpdatePlayerSpeed", function(player) --Handle player speed.
	if player:isArrested() then
		GAMEMODE:SetPlayerSpeed(player, GAMEMODE.Config.arrestspeed, GAMEMODE.Config.arrestspeed+(player:GetLevel("Stamina")*2))
	elseif player:isCP() then
		GAMEMODE:SetPlayerSpeed(player, GAMEMODE.Config.walkspeed, GAMEMODE.Config.runspeedcp+(player:GetLevel("Stamina")*2))
	else
		GAMEMODE:SetPlayerSpeed(player, GAMEMODE.Config.walkspeed, GAMEMODE.Config.runspeed+(player:GetLevel("Stamina")*2))
	end
	return true --Override the main UpdatePlayerSpeed hook.
end)

_G.skills = _G.skills or {}

local skillTbl = {}

skillTbl["Acrobatics"] = {
	getNeeded = function(player) return player:GetLevel("Acrobatics") * 50 end,
	levelUp = function(player) UpdateJumpPower(player) end,
	maxLevel = 10,
	hookUsed = "OnJump"
}

skillTbl["Stamina"] = {
	getNeeded = function(player) return player:GetLevel("Stamina") * 275 end,
	levelUp = function(player) hook.Call("UpdatePlayerSpeed", GAMEMODE, player) end,
	maxLevel = 50,
	hookUsed = "PlayerFootstep"
}

skillTbl["Strength"] = {
	getNeeded = function(player) return player:GetLevel("Strength") * 275 end,
	levelUp = function(player) hook.Call("UpdatePlayerSpeed", GAMEMODE, player) end,
	maxLevel = 50
}

function skills.Register(name, tbl)
	skillTbl[name] = tbl
end

function skills.GetAll()
	return skillTbl
end

function skills.Get(skill)
	return skillTbl[skill]
end

local PLAYER = FindMetaTable("Player")

function PLAYER:CanLevel(skill)
	if SERVER then
		return self.Level[skill] < skillTbl[skill].maxLevel
	else
		return Level[skill] < skillTbl[skill].maxLevel
	end
end

function PLAYER:GetLevel(skill)
	if SERVER then
		return self.Level[skill] or 1
	else
		return skills.GetLevel(skill)
	end
end

function PLAYER:GetExp(skill)
	if SERVER then
		return self.Exp[skill] or 0
	else
		return skills.GetExp(skill)
	end
end