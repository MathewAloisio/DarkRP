local PLAYER = FindMetaTable("Player")

local oldCheckLimit = oldCheckLimit or PLAYER.CheckLimit
local oldGetCount = oldGetCount or PLAYER.GetCount
function PLAYER:CheckLimit(str)
	if self:IsDev() then return true end
	return oldCheckLimit(str)
end

function PLAYER:GetCount(str, minus)
	if self:IsDev() then
		if minus then return 1 else return -1 end
	end
	return oldGetCount(str, minus)
end