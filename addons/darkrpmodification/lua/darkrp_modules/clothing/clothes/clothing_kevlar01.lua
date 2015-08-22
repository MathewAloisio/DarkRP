local CLOTHING = {}
CLOTHING.ID = 1 --The clothings uniqueID.
CLOTHING.Name = "Kevlar Vest" --The name of the clothing returned in menus, etc.
CLOTHING.Description = "Body armor made of Kevlar." --A description of the clothing article.
CLOTHING.Slot = 3 -- 0 = SLOT_HEAD, 1 = SLOT_EYES, 2 = SLOT_SHOULDERS, 3 = SLOT_CHEST, 4 = SLOT_LEGS, 5 = SLOT_FEET.
CLOTHING.ItemID = 4 -- The parent-item's ID.
CLOTHING.Flags = { --Example of damage modifiers with clothing.
	[DMG_BLAST] = 5, --5% general restistance to DMG_BLAST.
	[DMG_BULLET] = 7 --7% bullet damage resistance (HITGROUP SPECIFIC!! ex: player.Clothing[SLOT_HEAD] affects headshot damage.)
}

if CLIENT then
	CLOTHING.ClothingData = {
		{Bone = "ValveBiped.Bip01_Pelvis", Pos = Vector(0,0,-12.377893447876), Ang = Angle(0,0,90.102630615234), Scale = Vector(1,1,0.10328627377748), Model = "models/props_c17/oildrum001.mdl"},
		{Bone = "ValveBiped.Bip01_Pelvis", Pos = Vector(0,0,-5.5940208435059), Ang = Angle(0,0,90.102630615234), Scale = Vector(1,1,0.22858372330666), Model = "models/props_c17/oildrum001.mdl"}
	}
end
clothing.Register(CLOTHING)