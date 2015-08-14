_G.radio = _G.radio or {}

local radioStations = radioStations or {}

util.AddNetworkString("RADIO:UpdateStations")
util.AddNetworkString("SOUNDURL::RegisterEntity")
function radio.Register(name, url)
	local tbl = {
		name = name,
		url = url
	}
	table.insert(radioStations, tbl)
	net.Start("RADIO:UpdateStations")
		net.WriteTable(radioStations)
	net.Broadcast()
end

function radio.Get(id)
	return radioStations[id]
end

function radio.GetAll()
	return radioStations
end

function radio.GetByName(name)
	for _, v in pairs(radioStations) do
		if v.name == name then
			return v
		end
	end
end

function radio.GetName(id)
	return radioStations[id].name
end

function radio.GetID(name)
	for i, v in pairs(radioStations) do
		if v.name == name then
			return i
		end
	end
end

function radio.GetURL(id)
	return radioStations[id].url
end

hook.Add("PlayerInitialSpawn", "RADIO::InitialSpawn", function(player)
	net.Start("RADIO:UpdateStations")
		net.WriteTable(radioStations)
	net.Send(player)
	for _,entity in pairs(ents.GetAll()) do -- sync all sound-ent info.
		if entity.soundSync == nil then continue end --Server detects this as a non-sound entity, so don't bother trying to sync it, skip this iteration.
		net.Start("SOUNDURL::RegisterEntity")
			net.WriteEntity(entity)
			net.WriteBool(entity.soundSync)
		net.Send(player)
		if entity.soundURL ~= nil then
			net.Start("SOUNDURL::UpdateEntityURL")
				net.WriteEntity(entity)
				net.WriteString(entity.soundURL)
			net.Send(player)
		end
	end
end)

hook.Add("Initialize", "RADIO::Initialize", function()
	if file.Exists("roleplay/radiostations.txt", "DATA") then
		radioStations = pon.decode(file.Read("roleplay/radiostations.txt", "DATA"))
		net.Start("RADIO:UpdateStations")
			net.WriteTable(radioStations)
		net.Broadcast()
	end
end)

concommand.Add("soundurl_addradio", function(player, cmd, args)
	if not player:IsDev() then DarkRP.notify(player, 1, 4, "This command is restricted for developer-use only!") return end
	if #args < 2 then return end
	radio.Register(args[1], args[2])
	DarkRP.notify(player, 4, 4, string.format("You've successfully added the %s radio station.", args[1]))
	file.Write("roleplay/radiostations.txt", pon.encode(radioStations))
end)

concommand.Add("soundurl_removeradio", function(player, cmd, args)
	if not player:IsDev() then DarkRP.notify(player, 1, 4, "This command is restricted for developer-use only!") return end
	if not args[1] then return end
	local id = tonumber(args[1])
	if radioStations[id] == nil then return end
	DarkRP.notify(player, 2, 4, string.format("You've successfully removed the %s(%i) radio station.", radioStations[id].name, id))
	table.remove(radioStations, id)
	file.Write("roleplay/radiostations.txt", pon.encode(radioStations))
end)

local ENTITY = FindMetaTable("Entity")

util.AddNetworkString("SOUNDURL::UpdateEntityURL")
util.AddNetworkString("SOUNDURL::RefreshSoundURL")

function ENTITY:RegisterSoundEnt(sync)
	self.soundSync = sync
	timer.Simple(0.1, function()
		net.Start("SOUNDURL::RegisterEntity")
			net.WriteEntity(self)
			net.WriteBool(sync)
		net.Broadcast()
	end)
end

function ENTITY:SetSoundURL(url)
	self.soundURL = url
	net.Start("SOUNDURL::UpdateEntityURL")
		net.WriteEntity(self)
		net.WriteString(url)
	net.Broadcast()
end

function ENTITY:ToggleSoundURL(on)
	self:SetNWBool("soundURLOn", on)
	timer.Simple(0.1, function()
		net.Start("SOUNDURL::RefreshSoundURL")
			net.WriteEntity(self)
		net.Broadcast()
	end)
end