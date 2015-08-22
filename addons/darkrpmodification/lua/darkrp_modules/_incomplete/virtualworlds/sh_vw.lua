local ENTITY = FindMetaTable("Entity")

function ENTITY:GetVW()
	return self:GetNWInt("VW", 0)
end

hook.Add("OnEntityCreated", "ControlVWCollision", function(entity)  -- I think this calls players...
	entity:SetCustomCollisionCheck(true) 
end)

local worldObjects = {}
worldObjects["func_wall"] = true
worldObjects["worldspawn"] = true
hook.Add("ShouldCollide", "VW::ShouldCollide", function(entA, entB)
	if worldObjects[entA:GetClass()] or worldObjects[entB:GetClass()] then return end
	if entA:GetVW() == -1 or entB:GetVW() == -1 then return end -- -1 is our globally shared VW, don't handle.
    if entA:GetVW() ~= entB:GetVW() then return false end
end)

-- New version of EntityEmitSound replacement.
hook.Add("EntityEmitSound", "VW::EntityEmitSound", function(tbl)
	if CLIENT then
		if tbl.Entity:GetVW() ~= -1 and tbl.Entity:GetVW() ~= LocalPlayer():GetVW() then return false end
	end
end)
