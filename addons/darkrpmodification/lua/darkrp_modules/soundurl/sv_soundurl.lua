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

--Player specific functions--
function radio.Change(player)
	if player:InVehicle() and player:GetVehicle():IsRadioEnt() then 
		player:GetVehicle():ChangeStation(player) 
		return
	end
	local trace = player:GetEyeTrace()
	if IsValid(trace.Entity) then
		if trace.Entity:IsRadioEnt() and trace.Entity:GetPos():Distance(player:GetPos()) <= 120 then
			if player == _G.player.GetByID(trace.Entity:GetNWInt("Owner", -1)) then
				trace.Entity:ChangeStation(player)
				return
			else
				DarkRP.notify(player, 1, 4, "You don't own this radio.")
				return
			end
		end
	end
end
--    --

hook.Add("PlayerInitialSpawn", "RADIO::InitialSpawn", function(player)
	timer.Simple(2, function()
		net.Start("RADIO:UpdateStations") --This might work better outside the timer? Gives other stuff time since the net library has a weird 1 frame delay cause the poor coding... Seems to work fine anyhow.
			net.WriteTable(radioStations)
		net.Send(player)
		for _,entity in pairs(ents.GetAll()) do -- sync all sound-ent info.
			if entity.soundSync == nil then continue end --Server detects this as a non-sound entity, so don't bother trying to sync it, skip this iteration.
			net.Start("SOUNDURL::RegisterEntity")
				net.WriteDouble(entity:EntIndex())
				net.WriteBool(entity.soundSync)
			net.Send(player)
			if entity.soundURL ~= nil then
				net.Start("SOUNDURL::UpdateEntityURL")
					net.WriteDouble(entity:EntIndex())
					net.WriteString(entity.soundURL)
				net.Send(player)
			end
		end
	end)
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
	for _, entity in pairs(ents.GetAll()) do --We turn off all SoundURL objects when we add stations to prevent bad stuffz.
		if entity:IsSoundEnt() then
			entity:ToggleSoundURL(false)
			if entity:IsRadioEnt() then entity:SetStation(0) end
		end
	end
	net.Start("RADIO:UpdateStations")
		net.WriteTable(radioStations)
	net.Broadcast()	
end)

concommand.Add("soundurl_removeradio", function(player, cmd, args)
	if not player:IsDev() then DarkRP.notify(player, 1, 4, "This command is restricted for developer-use only!") return end
	if not args[1] then return end
	local id = tonumber(args[1])
	if radioStations[id] == nil then return end
	DarkRP.notify(player, 2, 4, string.format("You've successfully removed the %s(%i) radio station.", radioStations[id].name, id))
	table.remove(radioStations, id)
	file.Write("roleplay/radiostations.txt", pon.encode(radioStations))
	for _, entity in pairs(ents.GetAll()) do --We turn off all SoundURL objects when we add stations to prevent bad stuffz.
		if entity:IsSoundEnt() then
			entity:ToggleSoundURL(false)
			if entity:IsRadioEnt() then entity:SetStation(0) end
		end
	end
	net.Start("RADIO:UpdateStations")
		net.WriteTable(radioStations)
	net.Broadcast()
end)

local ENTITY = FindMetaTable("Entity")

util.AddNetworkString("SOUNDURL::UpdateEntityURL")
util.AddNetworkString("SOUNDURL::RefreshSoundURL")

function ENTITY:RegisterSoundEnt(sync)
	if sync == nil then sync = false end
	self.soundSync = sync
	timer.Simple(0.1, function()
		net.Start("SOUNDURL::RegisterEntity")
			net.WriteDouble(self:EntIndex())
			net.WriteBool(sync)
		net.Broadcast()
	end)
end

function ENTITY:IsSoundEnt()
	if self.soundSync ~= nil then return true end
	return false
end

function ENTITY:SetSoundURL(url)
	self.soundURL = url
	net.Start("SOUNDURL::UpdateEntityURL")
		net.WriteDouble(self:EntIndex())
		net.WriteString(url)
	net.Broadcast()
end

function ENTITY:ToggleSoundURL(on)
	self:SetNWBool("soundURLOn", on)
	timer.Simple(0.1, function()
		net.Start("SOUNDURL::RefreshSoundURL")
			net.WriteDouble(self:EntIndex())
		net.Broadcast()
	end)
end

--Radio entities--
function ENTITY:RegisterRadioEnt(sync)
	if sync == nil then sync = true end
	self:RegisterSoundEnt(sync)
	self.isRadio = true
	self.currentStation = 0
	self:ToggleSoundURL(false)
end

function ENTITY:IsRadioEnt()
	if self.isRadio ~= nil and self.isRadio == true then return true end
	return false
end

util.AddNetworkString("RADIO::ChangeStation")
function ENTITY:ChangeStation(player)
	self.currentStation = self.currentStation + 1
	if self.currentStation < 0 then self.currentStation = #radioStations end
	if self.currentStation > #radioStations then self.currentStation = 0 end
	if self.currentStation == 0 then
		self:ToggleSoundURL(false)
	else
		if self:GetNWBool("soundURLOn", false) == false then self:ToggleSoundURL(true) end
		self:SetSoundURL(radioStations[self.currentStation].url)
	end
	if player ~= nil then
		net.Start("RADIO::ChangeStation")
			net.WriteDouble(self.currentStation)
		net.Send(player)
	end
end

function ENTITY:SetStation(station)
	self.currentStation = station
	if self.currentStation < 0 then self.currentStation = #radioStations end
	if self.currentStation > #radioStations then self.currentStation = 0 end
	if self.currentStation == 0 then
		self:ToggleSoundURL(false)
	else
		if self:GetNWBool("soundURLOn", false) == false then self:ToggleSoundURL(true) end
		self:SetSoundURL(radioStations[self.currentStation].url)
	end
end

concommand.Add("soundurl_changestation", function(player, cmd, args)
	if args[1] == nil then return end
	local soundObj = ents.GetByIndex(args[1])
	if not IsValid(soundObj) or not soundObj:IsRadioEnt() then return end
	if player:GetPos():Distance(soundObj:GetPos()) >= 120 then player:ChatPrint("You need to be closer to change the station.") return end
	if player ~= _G.player.GetByID(soundObj:GetNWInt("Owner", -1)) then player:ChatPrint("You don't own this radio!") return end
	soundObj:ChangeStation(player)
end)

concommand.Add("soundurl_directlink", function(player, cmd, args)
	if args[1] == nil or args[2] == nil then return end
	local soundObj = ents.GetByIndex(args[1])
	if not IsValid(soundObj) or not soundObj:IsSoundEnt() then return end
	if player:GetPos():Distance(soundObj:GetPos()) >= 120 then player:ChatPrint("You need to be closer to change the station.") return end
	if not soundObj:IsVehicle() and player ~= _G.player.GetByID(soundObj:GetNWInt("Owner", -1)) and not player:IsAdmin() then player:ChatPrint("You don't own this radio!") return end
	if string.find(args[2], "www.youtube.com") ~= nil then player:ChatPrint("You can't use youtube videos! Only direct links. (.mp3/.pls/.ogg)") return end
	if soundObj:IsRadioEnt() then soundObj.currentStation = 0 end
	soundObj:SetSoundURL(args[2])
	if soundObj:GetNWBool("soundURLOn", false) == false then soundObj:ToggleSoundURL(true) end
	player:ChatPrint(string.format("Radios stream changed to: %s", args[2]))
end)
-- --