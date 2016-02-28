--NOTE: Blockers simply don't allow people who aren't in Virtual World 0 (Default player VW) to pass through these objects.)
--BEWARE: Although it's coded to deal with most situations nicely, if we were to have a 3rd person camera based on ray-tracing and our VW changed back to 0 FAR away from "Object X" our camera would collide with "Object X" when we pass through it.
--Luckily we're making a gamemode that's first person and this will never be a problem, so I won't waste your CPUs time addressing this issue. It's mostly dealt with in a low-resource way. (Dealt with for objects within your PVS when your VW is changed.) (Again, not that it matters cause we're first person.)

hook.Add("InitPostEntity", "BLOCKER::Load", function()
	if file.Exists("roleplay/blockers.txt", "DATA") then
		loadTbl = pon.decode(file.Read("roleplay/blockers.txt", "DATA"))
		for _,v in pairs(loadTbl) do
			local blocker = ents.Create("darkrp_blocker")
			blocker:SetModel(v.model)
			blocker:SetPos(v.pos)
			blocker:SetAngles(v.ang)
			blocker:Spawn()
			blocker:Activate()
		end
	end
end)

local function saveBlockers()
	local save = {}
	for entity,_ in pairs(blockers.GetAll()) do
		table.insert(save, {model = entity:GetModel(), pos = entity:GetPos(), ang = entity:GetAngles()})
	end
	file.Write("roleplay/blockers.txt", pon.encode(save))
end

concommand.Add("rp_makeblocker", function(player, cmd, args)
	if not player:IsDev() then return end
	local trace = player:GetEyeTrace()
	if trace.Entity ~= nil and IsValid(trace.Entity) and trace.Entity:GetClass() == "prop_physics" then
		local cache = {
			model = trace.Entity:GetModel(),
			pos = trace.Entity:GetPos(),
			ang = trace.Entity:GetAngles()
		}
		trace.Entity:Remove()
		local blocker = ents.Create("darkrp_blocker")
		blocker:SetModel(cache.model)
		blocker:SetPos(cache.pos)
		blocker:SetAngles(cache.ang)
		blocker:Spawn()
		blocker:Activate()
		player:ChatPrint("Prop converted into a virtual world blocker.")
		saveBlockers()
	else
		player:ChatPrint("You aren't looking at a prop!")
	end
end)

concommand.Add("rp_saveblockers", function(player)
	if not player:IsDev() then return end
	saveBlockers()
	player:ChatPrint("Blockers saved!")
end)
