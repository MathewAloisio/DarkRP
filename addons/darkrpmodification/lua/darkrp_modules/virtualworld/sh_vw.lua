local ENTITY = FindMetaTable("Entity")

function ENTITY:GetVW()
	return self:GetNWInt("VW", -1)
end

if ENTITY.oldSetCustomCollisionCheck == nil then
	ENTITY.oldSetCustomCollisionCheck = ENTITY.SetCustomCollisionCheck
	function ENTITY:SetCustomCollisionCheck(...)
		self:oldSetCustomCollisionCheck(...)
		self:CollisionRulesChanged()
	end
end

--[[
hook.Add("OnEntityCreated", "ControlVWCollision", function(entity)  -- I think this calls for players as well... (No longer neccesary.)
	entity:SetCustomCollisionCheck(true) 
end)
]]--

local worldObjects = {}
worldObjects["func_wall"] = true
worldObjects["worldspawn"] = true
hook.Add("ShouldCollide", "VW::ShouldCollide", function(entA, entB) --DO NOT EVER MODIFY THIS if you slightly screw up source physics will randomly break.
	if worldObjects[entA:GetClass()] or worldObjects[entB:GetClass()] then return end
	if entA.isBlocker ~= nil then
		if entB:GetVW() < 100 or entB:GetVW() > 300 then return false end
	end
	if entB.isBlocker ~= nil then
		if entA:GetVW() < 100 or entA:GetVW() > 300 then return false end
	end
	if entA:GetVW() == -1 or entB:GetVW() == -1 then return end -- -1 is our globally shared VW, don't handle.
    if entA:GetVW() ~= entB:GetVW() then return false end
end)

-- New version of EntityEmitSound replacement. Thank you GMod 13 for some wonderful hooks. Now if only we could override this engine-side.
if CLIENT then
	hook.Add("EntityEmitSound", "VW::EntityEmitSound", function(tbl)
		if tbl.Entity:GetVW() ~= -1 and tbl.Entity:GetVW() ~= LocalPlayer():GetVW() then return false end
	end)
end
