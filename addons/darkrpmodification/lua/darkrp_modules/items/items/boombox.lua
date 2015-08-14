local ITEM = {}
ITEM.ID = 3
ITEM.Name = "Boombox" 
ITEM.Plural = "Boomboxes"
ITEM.Description = "Test boombox."
ITEM.Model = "models/props/cs_office/radio.mdl"
ITEM.Weight = 3.0
ITEM.Type = 0 -- 0 = ITYPE_ITEM, 1 = ITYPE_FOOD, 2 = TYPE_DRINK, 3 = ITYPE_DRUG, 4 = ITYPE_WEAPON, 5 = ITYPE_AMMO, 6 = ITYPE_CLOTHING.
ITEM.CanSpawn = true 
ITEM.LookAt = vector_origin
ITEM.CamPos = Vector(10,40,0)

ITEM.Actions = {} --The actions displayed when the menu is used.
ITEM.Actions[0] = {
    Name = "Place",
	DoAction = function(player, slot)
		player:RemoveInvItem(_, 0, slot)
		local ent = ents.Create("prop_physics")
		ent:SetModel("models/weapons/w_pistol.mdl")
		ent:SetPos(player:GetEyeTrace().HitPos)
		ent:Spawn()
		ent.Use = function(player)
			ent:Remove()
			player:GiveInvItem(3, 1, 0, 0)
			DarkRP.notify(player, 4, 4, "Boombox picked up!")
		end
		ent:Activate()
		ent:RegisterSoundEnt(true)
		timer.Simple(1, function()
			ent:SetSoundURL("http://mp3light.net/assets/songs/15000-15999/15660-fire-burning-sean-kingston--1411568653.mp3")
			ent:ToggleSoundURL(true)
		end)
		DarkRP.notify(player, 4, 4, "Boombox activated!")
	end
}
ITEM.Actions[1] = {
    Name = "Drop"
}

items.Register(ITEM)