local ITEM = {}
ITEM.ID = 2
ITEM.Name = "Gas Can" 
ITEM.Plural = "Gas Cans"
ITEM.Description = "Example item."
ITEM.Model = "models/props_junk/gascan001a.mdl"
ITEM.Weight = 1.5
ITEM.Type = 0
ITEM.CanSpawn = true 
ITEM.LookAt = vector_origin
ITEM.CamPos = Vector(10,40,0)
ITEM.Stackable = true
ITEM.MaxStack = 100

ITEM.Actions = {} --The actions displayed when the menu is used.
ITEM.Actions[0] = {
    Name = "Use"
}
ITEM.Actions[1] = { -- #ITEM.Actions-2 is "Combine" on items where 'ITEM.Stackable == true'.
    Name = "Combine"
}
ITEM.Actions[2] = {-- #ITEM.Actions-1 is "Divide" on items where 'ITEM.Stackable == true'.
    Name = "Divide"
}
ITEM.Actions[3] = {
    Name = "Drop",
	DoAction = function(player, slot)
		if CLIENT then 
			print("Client!!!")
		end
		if SERVER then
			DarkRP.notify(playerid, 1, 4, "SERVER!!!")
			player:RemoveInvItem(_, 1, slot)
		end
	end
}
--OPTIONAL:
ITEM.OnSpawn = function(ent) DarkRP.notify(playerid, 1, 4, "OnSpawn called!") end

items.Register(ITEM)