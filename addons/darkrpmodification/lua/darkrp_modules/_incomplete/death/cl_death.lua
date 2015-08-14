net.Receive("CORPSE::PlayerDead", function()
	local ent = Entity(net.ReadFloat())
	hook.Add("CalcView", "Corpse.CalcView", function(ply, origin, angles, fov)
		if not IsValid(ent) then return end

		local head = ent:LookupAttachment("eyes")
		head = ent:GetAttachment(head)
		if not head or not head.Pos then return end

		local view = {}
		view.origin = head.Pos
		view.angles = head.Ang
		view.fov = fov
		return view
	end)
end)

net.Receive("CORPSE::PlayerSpawn", function()
	hook.Remove("CalcView", "Corpse.CalcView")
end)