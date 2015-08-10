local NPC = FindMetaTable("NPC")

function NPC:SetNPCName(str)
	self.m_Name = str
end
function NPC:GetNPCName()
	return self.m_Name
end