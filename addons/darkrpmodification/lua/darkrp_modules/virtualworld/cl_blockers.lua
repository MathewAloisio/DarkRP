hook.Add("VW::OnChanged", "BLOCKER::OnVWChanged", function()
	if LocalPlayer():GetVW() < 100 or LocalPlayer():GetVW() > 300 then
		for entity,_ in pairs(blockers.GetAll()) do
			entity:SetCollisionGroup(10)
		end
	else 
		for entity,_ in pairs(blockers.GetAll()) do
			entity:SetCollisionGroup(0)
		end
	end
end)