local function StopChatting(player)
	player.TalkingTo = nil
	player.ChatNum = nil
	umsg.Start("endChat", player)
	umsg.End()
	player:Freeze(false)
end
 
local function TalkToNPC(player, cmd, args)
	local ent = ents.GetByIndex(tonumber(args[1]))
	local response = tonumber(args[2])
	if not IsValid(ent) or not player:CanReach(ent) then return end
	if not ent:CanChat() or not defines.Dialog[ent:GetNPCName()] then return end --This NPC can't chat
	if not response && not player.TalkingTo then
		player:Freeze(true)
		player.TalkingTo = ent:GetNPCName()
		player.lastTalkEnt = ent
		player.ChatNum = 1

		umsg.Start("beginChatting",player)
			umsg.Short(ent:EntIndex())
			umsg.String(ent:GetNPCName())
				local t = defines.Dialog[player.TalkingTo][player.ChatNum].Replies
				
				if type(t) == "function" then t = t(player) end

				for _, v in pairs(t) do
					umsg.Short(v)
				end
		umsg.End()
	elseif response && player.TalkingTo then
		local t = defines.Dialog[player.TalkingTo][player.ChatNum].Replies
		if type(t) == "function" then t = t(player) end
		for _,v in pairs(t) do
			if v == response then
				local newNum = defines.Replies[player.TalkingTo][response].OnUse(player,ent)
				if not newNum then StopChatting(player) return end
				player.ChatNum = newNum
				umsg.Start("NPCRespond",player)
					umsg.Short(newNum) --send the new dialog-id you should be at.
					local t = defines.Dialog[player.TalkingTo][player.ChatNum].Replies
					
					if type(t) == "function" then t = t(player) end

					for _,val in pairs(t) do
						umsg.Short(val)
					end
				umsg.End()
				return
			end
		end
		return
	end
end
concommand.Add("talkto", TalkToNPC)




