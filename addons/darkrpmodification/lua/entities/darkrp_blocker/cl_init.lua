include('shared.lua')

function ENT:Initialize()
	self.isBlocker = true
	blockers.Add(self)
	self:SetRenderMode(10)
	self:SetColor(Color(255, 255, 255, 0))
end

function ENT:Draw()
	return
end

function ENT:OnRemove()
	blockers.Remove(self)
end
