
ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.PrintName		= "Rotating Shit"
ENT.Author		= "BennyG"
ENT.Category 		= ""
ENT.Contact    		= ""
ENT.Purpose 		= ""
ENT.Instructions 	= "" 

ENT.Spawnable			= true
ENT.AdminSpawnable		= false


function ENT:SetupDataTables()


self:DTVar( "Entity", 0, "target" );

end