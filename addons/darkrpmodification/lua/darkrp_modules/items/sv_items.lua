_G.items = _G.items or {}

function items.CreateLoot(id, quantity, e, ex, pos, ang)
	local tbl = items.Get(id)
	if tbl.CanSpawn == false then return false end
	local ent = ents.Create(tbl.ClassOverride or "darkrp_item")
	ent:SetNWString("itemName",items.GetName(id, quantity))
	ent:SetModel(tbl.Model)
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent.ItemID = id
	ent.Quantity = quantity
	ent.E = e
	ent.Ex = ex
	ent:Spawn()
	ent:Activate()	
end	