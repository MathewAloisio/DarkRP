_G.radio = _G.radio or {}

local radioStations = radioStations or {}
net.Receive("RADIO:UpdateStations", function(len)
	radioStations = net.ReadTable()
end)

function radio.Get(id)
	return radioStations[id]
end

function radio.GetAll()
	return radioStations
end

function radio.GetByName(name)
	for i, v in pairs(radioStations) do
		if v.name == name then
			return radioStations[i]
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

_G.soundurl = _G.soundurl or {}

local maxSoundURLs = maxSoundURLs or 5
local soundURLs = soundURLs or {}

function soundurl.SetMaxURLs(count)
	maxSoundURLs = count
	for i,_ in pairs(soundURLs) do --Clear all audio streams over the limit.
		if i > count then soundurl.StopStream(i) end
	end
end

function soundurl.Get(id)
	return soundURLs[id]
end

function soundurl.GetAll()
	return soundURLs
end

function soundurl.GetStream(id)
	return soundURLs[id].stream
end

function soundurl.GetURL(id)
	return soundURLs[id].url or ""
end

function soundurl.PlayStream(url, flags, callback, parent, noplay)
	if #soundURLs > (maxSoundURLs-1) then return -1 end --Don't play it if we're at our limit.
	local failed = 0
	sound.PlayURL(url, flags, function(stream)
		if stream:IsValid() then
			if callback ~= nil then callback(stream) end
			local tbl = {stream = stream, url = url}
			if parent ~= nil then tbl.parent = parent end
			table.insert(soundURLs, tbl)
			if noplay == nil then
				stream:Play()
			end
		else
			failed = 1
			return
		end
	end)
	return ((failed == 0) and #soundURLs+1) or -1
end

concommand.Add("soundurl_maxurls", function()
	Derma_StringRequest( "Question", 
		"What do you want your URL-stream limit to be?", 
		"5", 
		function( strTextOut ) 
			local limit = tonumber(strTextOut)
			if type(limit) ~= "number" then LocalPlayer():ChatPrint("Failed to set max-urls, the limit must be a number!") return end
			soundurl.SetMaxURLs(limit)
			LocalPlayer():ChatPrint(string.format("You've set your URL streaming limit to %i.", limit))
		end,
		function( strTextOut )  end,
		"Set", 
		"Cancel" )
end)

function soundurl.SetParent(id, parent)
	soundURLs[id].parent = parent
end

function soundurl.GetParent(id)
	return soundURLs[id].parent
end

function soundurl.StopAllStreams()
	for i,_ in pairs(soundURLs) do
		soundurl.StopStream(i)
	end
end

local refreshSoundEnts = refreshSoundEnts or {}
function soundurl.MakeEntRefresh(entity)
	if table.HasValue(refreshSoundEnts, entity) then return end
	entity.refreshSoundID = #refreshSoundEnts+1
	table.insert(refreshSoundEnts, entity)
end

function soundurl.StopStream(id)
	if soundURLs[id] ~= nil then
		if soundURLs[id].stream:IsValid() then
			soundURLs[id].stream:Stop()
		end
		if soundURLs[id].parent ~= nil and soundURLs[id].parent:IsValid() then
			soundURLs[id].parent.soundOn = false
			if soundURLs[id].parent:GetNWBool("soundURLOn", false) == true then
				soundurl.MakeEntRefresh(soundURLs[id].parent)
			end
		end
		table.remove(soundURLs, id)
	end
end

local blockedSoundEnts = blockedSoundEnts or {}
function soundurl.RemoveEntity(entity)
	for i, v in pairs(soundURLs) do
		if v.parent ~= nil and v.parent == entity then
			soundurl.StopStream(i)
		end
	end
	if entity.refreshSoundID ~= nil then table.remove(refreshSoundEnts, entity.refreshSoundID) end
	for i,v in pairs(blockedSoundEnts) do
		if v == entity then
			table.remove(blockedSoundEnts, i)
		end
	end
end

hook.Add("EntityRemoved", "SOUNDURL::EntityRemoved", function(entity)
	if entity.soundOn ~= nil then soundurl.RemoveEntity(entity) end
end)

local function updateSoundEntity(entity)
	if table.HasValue(blockedSoundEnts, entity) then return end
	local entityActive = entity:GetNWBool("soundURLOn", false)
	if entity.soundOn == false and entityActive == true then --turn on
		if entity.soundURL ~= nil and entity:GetPos():Distance(LocalPlayer():GetPos()) < 800 then -- In range
			entity.refreshSoundID = nil
			entity.soundOn = true
			local id = soundurl.PlayStream(entity.soundURL, "3d", _, entity)
			if id == -1 then entity.soundOn = false return end -- failed to general the audio stream so kill our operation after telling the entity that no sound is playing.
		else --out of range.	
			soundurl.MakeEntRefresh(entity)
		end
	elseif entity.soundOn == true and (entityActive == false or entity:GetPos():Distance(LocalPlayer():GetPos()) > 800) then
		for i, v in pairs(soundURLs) do
			if v.parent ~= nil and v.parent == entity then
				soundurl.StopStream(i)
			end
		end
		if entityActive == true then
			soundurl.MakeEntRefresh(entity)
		end
	end
	if entity.soundOn == true and entityActive == true then --Check for song-changes.
		for i, v in pairs(soundURLs) do
			if v.parent ~= nil and v.parent == entity and entity.soundURL ~= v.url then
				soundurl.StopStream(i)
				updateSoundEntity(entity)
			end
		end	
	end
end

function soundurl.RegisterEntity(entity, sync)
	entity.soundOn = false
	entity.soundSync = sync or false
	updateSoundEntity(entity)
end

function soundurl.SetEntityURL(entity, url)
	entity.soundURL = url
	updateSoundEntity(entity)
end

hook.Add("NetworkEntityCreated", "SOUNDURL::EntityCreated", function(entity)
	if entity.soundOn == nil then return end
	updateSoundEntity(entity)
end)

net.Receive("SOUNDURL::UpdateEntityURL", function(len)
	local entity = net.ReadEntity()
	if not IsValid(entity) then return end
	entity.soundURL = net.ReadString()
	updateSoundEntity(entity)
end)

net.Receive("SOUNDURL::RegisterEntity", function(len)
	local entity = net.ReadEntity()
	if not IsValid(entity) then return end
	soundurl.RegisterEntity(entity, net.ReadBool())
end)

net.Receive("SOUNDURL::RefreshSoundURL", function(len) 
	local entity = net.ReadEntity()
	if not IsValid(entity) then return end
	updateSoundEntity(entity) 
end)

local lastRefresh = lastRefresh or 0
hook.Add("Think", "SOUNDURL::Think", function() --sync/refresh streams
	for i,v in pairs(soundURLs) do
		if v.parent ~= nil then
			local pos
			if v.parent:IsValid() and v.parent.soundSync == true and v.stream:IsValid() then
				pos = v.parent:GetPos()
				v.stream:SetPos(pos)
			elseif not v.parent:IsValid() then
				soundurl.StopStream(i)
				continue
			end
			if lastRefresh <= CurTime() and v.parent.soundOn == true and LocalPlayer():GetPos():Distance(pos) > 800 then
				soundurl.StopStream(i)
				if v.parent:GetNWBool("soundURLOn", false) == true then
					soundurl.MakeEntRefresh(v.parent)
				end			
			end
		end
	end
	if lastRefresh <= CurTime() then --refresh entities that WERE out of range.
		for _,entity in pairs(refreshSoundEnts) do updateSoundEntity(entity) end
		lastRefresh = CurTime() + 4 --refresh out-of-range sound-entities every 4 seconds.
	end
end)

--Blacklist sound ent option.
properties.Add( "blocksoundent", 
{
	MenuLabel =	"Disable URL-streaming",
	Order =	999,
	MenuIcon = "icon16/cross.png",
	
	Filter = function( self, entity, player )
		if entity.soundOn == nil then return false end
		if table.HasValue(blockedSoundEnts, entity) then return false end
		return true
	end,
	Action = function( self, entity )
		table.insert(blockedSoundEnts, entity)
		for i, v in pairs(soundURLs) do
			if v.parent ~= nil and v.parent == entity then
				soundurl.StopStream(i)
			end
		end
		chat.AddText(Color(255, 0, 50), "Entity added to blocked sound-entity list.")
	end
} )

properties.Add( "allowsoundent", 
{
	MenuLabel =	"Allow URL-streaming",
	Order =	999,
	MenuIcon = "icon16/tick.png",
	
	Filter = function( self, entity, player )
		if entity.soundOn == nil then return false end
		if not table.HasValue(blockedSoundEnts, entity) then return false end
		return true
	end,
	Action = function( self, entity )
		for i,v in pairs(blockedSoundEnts) do
			if v == entity then
				table.remove(blockedSoundEnts, i)
				updateSoundEntity(entity)
				chat.AddText(Color(50, 255, 0), "Entity removed from the blocked sound-entity list.")
				return
			end
		end
	end
} )

hook.Add("Initialize", "SOUNDURL::Initialize", function() 
	local cmenu = input.LookupBinding("+menu_context")
	if cmenu ~= nil then 
		cmenu = string.upper(cmenu)
	else
		cmenu = "not bound[+menu_context]"
		timer.Simple(15, function() chat.AddText(Color(255, 0, 0), "[NOTICE] Your context menu isn't bound! Type 'bind [key] +menu_context' in console to bind it to a key. (It is used for some per-entity settings.)") end)
	end
	AddHint(string.format("Did you know you can disable URL-streaming for a specific object by holding '%s', right clicking it, and selecting 'Disable/Allow URL-streaming'?", cmenu)) 
end)