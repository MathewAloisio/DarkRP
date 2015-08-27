local ITEM = {}
ITEM.ID = 1
ITEM.Name = "Pistol" 
ITEM.Plural = "Pistols"
ITEM.Description = "Example weapon item."
ITEM.Model = "models/weapons/w_pistol.mdl"
ITEM.Weight = 2.5
ITEM.Type = 4 -- 0 = ITYPE_ITEM, 1 = ITYPE_FOOD, 2 = TYPE_DRINK, 3 = ITYPE_DRUG, 4 = ITYPE_WEAPON, 5 = ITYPE_AMMO, 6 = ITYPE_CLOTHING.
ITEM.CanSpawn = true 
if CLIENT then
	ITEM.LookAt = vector_origin
	ITEM.CamPos = Vector(10,40,0)
end
ITEM.Actions = {} --The actions displayed when the menu is used.
ITEM.Actions[0] = {
    Name = "Equip"
}
ITEM.Actions[1] = {
    Name = "Drop"
}
--OPTIONAL:
ITEM.WepClass = "weapon_pistol" -- For easier use with weapons. Example: "weapon_pistol"

items.Register(ITEM)