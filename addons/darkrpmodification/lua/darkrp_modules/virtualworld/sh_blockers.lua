blockers = _G.blockers or {}

local blockerTbl = {}

function blockers.Add(entity)
	if entity:GetClass() == "darkrp_blocker" then blockerTbl[entity] = true end
end

function blockers.Remove(entity)
	if blockerTbl[entity] ~= nil then blockerTbl[entity] = nil end
end

function blockers.GetAll()
	return blockerTbl
end