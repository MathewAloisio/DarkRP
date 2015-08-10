hook.Add("PlayerInitialSpawn", "MODIFIER:InitialSpawn", function(player) player.Mod = {} end)

util.AddNetworkString("networkModifier")
local function networkModifier(player, mod)
	net.Start("networkModifier")
		net.WriteInt(mod, 4) --4bit integer = up to 16 Mods in the Mods[] table.
		net.WriteDouble(player.Mod[mod] or 0)
	net.Send(player)
end

local PLAYER = FindMetaTable("Player")

function PLAYER:AddMod(mod, val)
	self.Mod[mod] = (self.Mod[mod] or 0) + val
	if not modifier.Get(mod).CanNegative and self.Mod[mod] < 0 then self.Mod[mod] = 0 end --only allow negative modifiers for ones with 'CanNegative' set to 'true'.
	networkModifier(self, mod)
end

function PLAYER:SetMod(mod, val)
	self.Mod[mod] = val
	networkModifier(self, mod)
end