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
		{Bone = "ValveBiped.Bip01_Spine", Pos = Vector(1.3023743629456,1.0023951530457,0), Ang = Angle(78.350250244141,-90.16130065918,-90.670806884766), Scale = Vector(0.73227721452713,0.50770497322083,0.36487928032875), Model = "models/props_c17/oildrum001.mdl", Skin = 0, Material = "models/props_combine/tprings_globe"},
		{Bone = "ValveBiped.Bip01_Spine", Pos = Vector(0,0,0), Ang = Angle(197.28674316406,0,74.26016998291), Scale = Vector(1,0.34068858623505,0.70388907194138), Model = "models/props_c17/metalladder002b.mdl", Skin = 0, Material = "models/props_combine/stasisshield_sheet"}
	}
end
clothing.Register(CLOTHING)