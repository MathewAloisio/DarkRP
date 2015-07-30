-- Inventory variables for the 4 different item-slots. Example: player.Inv[MAX_INV_SLOTS]
ITEM_ID = 0
ITEM_Q = 1
ITEM_E = 2
ITEM_EX = 3

-- Item types
TYPE_ITEM = 0
TYPE_FOOD = 1
TYPE_DRINK = 2
TYPE_DRUG = 3
TYPE_WEAPON = 4
TYPE_AMMO = 5
TYPE_CLOTHING = 0

-- Item subclasses
CLASS_NONE = 0
CLASS_FISH = 1
CLASS_PRIMARY = 2
CLASS_SECONDARY = 3
CLASS_MELEE = 4

-- Inventory settings.
MAX_INV_SLOTS = 20
MAX_INV_WEIGHT = 100

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


--DarkRP Chat commands below:
DarkRP.declareChatCommand{
	command = "putgun",
	description = "Store your current gun in your inventory.",
	delay = 1.5
}