umsg.PoolString("expSet")
umsg.PoolString("levelSet")
local function networkSkills(player)
	for i,_ in pairs(skills.GetAll()) do
		if player.Exp[i] > 0 then
			umsg.Start("expSet",player)
				umsg.String(i)
				umsg.Long(player.Exp[i])
			umsg.End()
		end
		if player.Level[i] > 1 then
			umsg.Start("levelSet",player)
				umsg.String(i)
				umsg.Char(player.Level[i])
			umsg.End()
		end
	end
end

local function saveSkills(player)
	local tbl = {
		levels = player.Level,
		exp = player.Exp
	}
	file.Write(string.format("roleplay/skills/%s.txt", player:UniqueID()), pon.encode(tbl))
end
hook.Add("PlayerDisconnected", "Skills::OnDisconnect", saveSkills)

hook.Add("PlayerInitialSpawn", "Skills::InitialSpawn", function(player)
	player.Level = {}
	player.Exp = {}
	if file.Exists(string.format("roleplay/skills/%s.txt", player:UniqueID()), "DATA") then -- Load skills.
		local tbl = pon.decode(file.Read(string.format("roleplay/skills/%s.txt", player:UniqueID()), "DATA"))
		player.Level = tbl.levels
		player.Exp = tbl.exp
		networkSkills(player)
	else 
		for i,_ in pairs(skills.GetAll()) do
			player.Exp[i] = 0
			player.Level[i] = 0
			saveSkills(player)
		end
	end
end)

for i,v in pairs(skills.GetAll()) do
	if v.hookUsed ~= nil then
		hook.Add(v.hookUsed,i.."Increase", function(player)
			player.Exp[i] = player.Exp[i] + 1
			if player.Exp[i] >= v.getNeeded(player) and player:CanLevel(i) then player:LevelUp(i) end
			if v.custFunc then v.custFunc(player) end
			networkSkills(player)
		end)
	end
end

local PLAYER = FindMetaTable("Player")

function PLAYER:LevelUp(skill)
	self.Level[skill] = self.Level[skill] + 1
	self.Exp[skill] = 0
	if skills.Get(skill).levelUp then skills.Get(skill).levelUp(self) end
	DarkRP.notify(self, 4, 4, string.format("Congratulations! You've leveled your %s skill to level %i.", skill, self.Level[skill]))
	saveSkills(self)
	networkSkills(self)
end

function PLAYER:SetLevel(skill, val)
	self.Level[skill] = val
	saveSkills(self)
	networkSkills(self)
end

function PLAYER:SetExp(skill, val)
	self.Level[skill] = val
	saveSkills(self)
	networkSkills(self)
end

function PLAYER:AddExp(skill, val)
	self.Exp[skill] = self.Exp[skill] + val
	if self.Exp[skill] >= skills.Get(skill).getNeeded(self) and self:CanLevel(skill) then self:LevelUp(skill) end
	saveSkills(self)
	networkSkills(self)
end