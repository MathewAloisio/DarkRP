AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include('shared.lua')

function ENT:Initialize()
	self.Entity:SetModel("models/props_borealis/bluebarrel001.mdl")
	self.Entity:SetMaterial( "models/null" )
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetUseType(SIMPLE_USE)
	self.Entity:SetCollisionGroup(0)
	local phys = self.Entity:GetPhysicsObject()
	if phys and phys:IsValid() then 
		phys:EnableMotion( false )  
	end
	self:DrawShadow(false)
	self.isBlocker = true
	blockers.Add(self)
end

function ENT:OnRemove()
	blockers.Remove(self)
end