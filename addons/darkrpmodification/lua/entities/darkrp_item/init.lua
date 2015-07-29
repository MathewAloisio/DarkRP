AddCSLuaFile("shared.lua")

include('shared.lua')

function ENT:Initialize()
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.nodupe = true
	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self:SetUseType(SIMPLE_USE)
end 

function ENT:Use(activator, caller)
	if !activator:IsPlayer() then return end
	if(self.ItemID == nil) then activator:PrintMessage(HUD_PRINTTALK, "[ERROR] No 'ItemID' provided for this loot.") return end
	if !activator:GiveInvItem(self.ItemID, self.Quantity or 1, self.E or 0, self.Ex or 0) then return end
	self:Remove()
end