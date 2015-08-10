local Mods = Mods or {}

Mods[0] = { --[MOD_WEIGHT]
	Name = "Carry Weight",
	Max = 100
}

Mods[1] = { --[MOD_SPEED]
	Name = "Speed",
	Max = 50,
	CanNegative = true
}

_G.modifier = _G.modifier or {}

function modifier.Get(mod)
	return Mods[mod]
end

function modifier.GetAll()
	return Mods
end

local PLAYER = FindMetaTable("Player")

function PLAYER:GetMod(mod)
	if SERVER then
		return self.Mod[mod] or 0
	else
		return Mod[mod] or 0
	end
end