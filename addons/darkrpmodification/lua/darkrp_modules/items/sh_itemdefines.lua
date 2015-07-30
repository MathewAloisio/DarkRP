local ITEM = {}
ITEM.ID = 1
ITEM.Name = "Pistol" 
ITEM.Plural = "Pistols"
ITEM.Description = "Example weapon item."
ITEM.Model = "models/weapons/w_pistol.mdl"
ITEM.Weight = 2.5
ITEM.Type = TYPE_WEAPON
ITEM.CanSpawn = true 
ITEM.LookAt = vector_origin
ITEM.CamPos = Vector(10,40,0)

ITEM.Actions = {} --The actions displayed when the menu is used.
ITEM.Actions[0] = {
    Name = "Equip"
}
ITEM.Actions[1] = {
    Name = "Drop",
    ShowOption = function(player) return true end,
    DoAction = function(player)
        --Code here.
    end
}
--OPTIONAL:
ITEM.WepClass = "weapon_pistol" -- For easier use with weapons. Example: "weapon_pistol"

items.Register(ITEM)