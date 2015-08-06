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

-- Inventory settings.
MAX_INV_SLOTS = 20
MAX_INV_WEIGHT = 100
INV_SLOT_LIMIT = 50

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

function defines.ScreenScale(val,scalefactor)
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

local developers = {"STEAM_0:1:20252092"}
function PLAYER:IsDev()
	if table.HasValue(developers, self:SteamID()) then return true end
	return false
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