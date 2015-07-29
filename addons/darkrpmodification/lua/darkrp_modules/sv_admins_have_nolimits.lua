if not ConVarExists("admins_nolimits") then
	CreateConVar( "admins_nolimits", "1", FCVAR_NOTIFY )
end

local PLAYER = FindMetaTable("Player")

PLAYER.OldCheckLimit = PLAYER.CheckLimit
PLAYER.OldGetCount = PLAYER.GetCount

function PLAYER:CheckLimit(str)
	if GetConVarNumber( "admins_nolimits" ) == 1 and self:IsSuperAdmin() then
		return true
	end
	return self:OldCheckLimit(str)
end

function PLAYER:GetCount(str, minus)
	if GetConVarNumber( "admins_nolimits" ) == 1 and self:IsSuperAdmin() then
		if minus then
			return 1
		else 
			return -1
		end
	end
	return self:OldGetCount(str, minus)
end