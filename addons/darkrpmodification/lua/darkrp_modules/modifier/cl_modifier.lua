local Mod = Mod or {}

net.Receive("networkModifier", function(len)
	Mod[net.ReadInt(4)] = net.ReadDouble()
end)