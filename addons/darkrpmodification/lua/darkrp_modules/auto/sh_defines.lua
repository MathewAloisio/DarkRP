-- Inventory variables for the 4 different item-slots. Example: player.Inv[MAX_INV_SLOTS]
ITEM_ID = 0
ITEM_Q = 1
ITEM_E = 2
ITEM_EX = 3

-- Item types
ITYPE_ITEM = 0
ITYPE_FOOD = 1
ITYPE_DRINK = 2
ITYPE_DRUG = 3
ITYPE_WEAPON = 4
ITYPE_AMMO = 5
ITYPE_CLOTHING = 6

-- Item subclasses
ICLASS_NONE = 0
ICLASS_FISH = 1
ICLASS_PRIMARY = 2
ICLASS_SECONDARY = 3
ICLASS_MELEE = 4

-- Modifier types
MOD_WEIGHT = 0
MOD_SPEED = 1

-- Inventory settings.
MAX_INV_SLOTS = 49 --Limit = MAX_INV_SLOTS + 1 because we use '0' in our loops.
MAX_INV_WEIGHT = 100

-- Bank settings.
MAX_BANK_SLOTS = 49 --Limit = MAX_INV_SLOTS +1 because we use '0' in our loops.

--General settings.
MAX_INTERACT_DIST = 100

_G.defines = _G.defines or {}

defines.Website = "www.ls-life.com"

function defines.SecondsToDays(sec)
	return math.floor(sec/86400)
end

function defines.DaysToSeconds(day)
	return math.floor(day*86400)
end

function defines.TranslateDonate(rank)
	if rank == 1 then return "Bronze" end
	if rank == 2 then return "Silver" end
	if rank == 3 then return "Gold" end
	return "None"
end

function defines.ScreenScale(val,scaleFactor)
	if not scaleFactor then
		local adjX = ScrW() / 1024.0
		if (adjX * ScrH()) > ScrH() then
			scaleFactor = ScrH() / 768.0
		else
			scaleFactor = adjX
		end
	end
	return val * scaleFactor
end

local PLAYER = FindMetaTable("Player")

local developers = {"STEAM_0:1:20252092","STEAM_0:0:19681809"}
function PLAYER:IsDev()
	if table.HasValue(developers, self:SteamID()) then return true end
	return false
end

function PLAYER:CanReach(ent)
	return self:GetPos():Distance(ent:GetPos()) < MAX_INTERACT_DIST
end

if SERVER then
	local fw = file.Write
	function file.Write(path, data) --file.Write hotfix, auto create directories.
		local dir = string.GetPathFromFilename(path)	
		if not file.Exists(dir, "DATA") then
			file.CreateDir( dir )
		end
		fw(path, data)
	end
end

defines.Dialog = defines.Dialog or {}
defines.Replies = defines.Replies or {}