--Networked context options.
properties.Add( "makesoundobj", 
{
	MenuLabel =	"Convert into SoundURL object",
	Order =	2000,
	MenuIcon = "icon16/wrench.png",
	
	Filter = function(self, entity, player)
		if entity:GetClass() ~= "prop_physics" and not entity:IsVehicle() then return false end
		if entity.soundOn ~= nil then return false end
		if not LocalPlayer():IsAdmin() then return false end
		return true
	end,
	Action = function(self, entity)
		self:MsgStart()
			net.WriteEntity(entity)
		self:MsgEnd()
	end,
	Receive = function(self, length, player)
		if not player:IsAdmin() then return false end
		local entity = net.ReadEntity()
		if entity:GetClass() ~= "prop_physics" and not entity:IsVehicle() then return false end
		entity:RegisterSoundEnt(true)
		DarkRP.notify(player, 4, 4, "SoundURL object created! Use the same context menu to set it's URL or to toggle it's on/off status.")
	end
} )

properties.Add( "setsoundobjurl", 
{
	MenuLabel =	"Change audio URL",
	Order =	2001,
	MenuIcon = "icon16/wrench.png",
	
	Filter = function(self, entity, player)
		if entity.soundOn == nil then return false end
		if not LocalPlayer():IsAdmin() then return false end
		return true
	end,
	Action = function( self, entity )
		Derma_StringRequest( "Question", 
			"Enter a direct-link URL. (.mp3/.pls/.ogg)", 
			"http://www.example.com/example.mp3", 
			function( strTextOut ) 
				self:MsgStart()
					net.WriteEntity(entity)
					net.WriteString(strTextOut)
				self:MsgEnd()
			end,
			function( strTextOut )  end,
			"Set", 
			"Cancel" )
	end,
	Receive = function(self, length, player)
		if not player:IsAdmin() then return false end
		local entity = net.ReadEntity()
		local url = net.ReadString()
		entity:SetSoundURL(url)
		DarkRP.notify(player, 4, 4, string.format("SoundURL Objects URL changed to: %s.", url))
	end
} )

properties.Add( "soundurlon", 
{
	MenuLabel =	"Play URL stream",
	Order =	2002,
	MenuIcon = "icon16/tick.png",
	
	Filter = function(self, entity, player)
		if entity.soundOn == nil then return false end
		if not LocalPlayer():IsAdmin() then return false end
		if entity:GetNWBool("soundURLOn", false) == true then return false end
		return true
	end,
	Action = function( self, entity )
		self:MsgStart()
			net.WriteEntity(entity)
		self:MsgEnd()
	end,
	Receive = function(self, length, player)
		if not player:IsAdmin() then return false end
		local entity = net.ReadEntity()
		if entity:GetNWBool("soundURLOn", false) == true then return end
		entity:ToggleSoundURL(true)
		DarkRP.notify(player, 2, 4, "SoundURL object stream started.")
	end
} )

properties.Add( "soundurloff", 
{
	MenuLabel =	"Stop URL stream",
	Order =	2002,
	MenuIcon = "icon16/cross.png",
	
	Filter = function(self, entity, player)
		if entity.soundOn == nil then return false end
		if not LocalPlayer():IsAdmin() then return false end
		if entity:GetNWBool("soundURLOn", false) == false then return false end
		return true
	end,
	Action = function( self, entity )
		self:MsgStart()
			net.WriteEntity(entity)
		self:MsgEnd()
	end,
	Receive = function(self, length, player)
		if not player:IsAdmin() then return false end
		local entity = net.ReadEntity()
		if entity:GetNWBool("soundURLOn", false) == false then return end
		entity:ToggleSoundURL(false)
		DarkRP.notify(player, 1, 4, "SoundURL Object stream stopped.")
	end
} )