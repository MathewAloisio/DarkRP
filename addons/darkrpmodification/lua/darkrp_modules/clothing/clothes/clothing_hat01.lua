local CLOTHING = {}
CLOTHING.ID = 2 --The clothings uniqueID.
CLOTHING.Name = "Test Hat" --The name of the clothing returned in menus, etc.
CLOTHING.Description = "Test hat description." --A description of the clothing article.
CLOTHING.Slot = 0 -- 0 = SLOT_HEAD, 1 = SLOT_EYES, 2 = SLOT_SHOULDERS, 3 = SLOT_CHEST, 4 = SLOT_LEGS, 5 = SLOT_FEET.
CLOTHING.ItemID = 5 -- The parent-item's ID.
CLOTHING.Flags = { --Example of damage modifiers with clothing.
	[DMG_BULLET] = 5 --5% bullet damage resistance (HITGROUP SPECIFIC!! ex: player.Clothing[SLOT_HEAD] affects headshot damage.)
}

if CLIENT then
	CLOTHING.ClothingData = {
		{Bone = "ValveBiped.Bip01_Pelvis", Pos = Vector(0.39880356192589,28.029943466187,-0.32811826467514), Ang = Angle(0,0,0), Scale = Vector(0.56244772672653,0.43145251274109,0.45192992687225), Model = "models/Combine_Helicopter/helicopter_bomb01.mdl", Skin = 0, Material = ""}
	}
end
clothing.Register(CLOTHING)