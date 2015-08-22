local ITEM = {}
ITEM.ID = 4
ITEM.Name = "Kevlar Vest" 
ITEM.Plural = "Kevlar Vests"
ITEM.Description = "Body armor made of Kevlar."
ITEM.Model = "models/weapons/w_pistol.mdl"
ITEM.Weight = 5.0
ITEM.Type = 6 -- 0 = ITYPE_ITEM, 1 = ITYPE_FOOD, 2 = TYPE_DRINK, 3 = ITYPE_DRUG, 4 = ITYPE_WEAPON, 5 = ITYPE_AMMO, 6 = ITYPE_CLOTHING.
ITEM.CanSpawn = true 
ITEM.ClothingID = 1 --The matching ClothingTbl item where CLOTHING.ID == ITEM.ClothingID
ITEM.LookAt = vector_origin
ITEM.CamPos = Vector(10,40,0)

ITEM.Actions = {} --The actions displayed when the menu is used. (auto-generated for clothing.)
ITEM.Actions[0] = {
    Name = "Wear"
}
ITEM.Actions[1] = {
    Name = "Drop"
}

items.Register(ITEM)