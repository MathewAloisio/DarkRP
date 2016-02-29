hook.Add("Initialize", "CEXEC::Initialize", function() umsg.PoolString("unblocked_cexec") end)

concommand.Add("rp_forcecexec", function(player, cmd, args) 
	if not ply:IsSuperAdmin() then DarkRP.notify(player, 1, 4, "Only super-admins can use this command!") return end
	if #args < 3 then ply:PrintMessage(HUD_PRINTTALK, "USAGE: rp_cexec [target] [command] [arguments].") return end
	local who = DarkRP.findPlayer(args[1])
	if IsValid(who) and who:IsPlayer() then
		umsg.Start("unblocked_cexec", who)
			umsg.String(tostring(args[2]))
			umsg.String(tostring(args[3]))
		umsg.End()
		ply:PrintMessage(HUD_PRINTTALK, "You've ran the command '"..tostring(args[2]).."' on "..who:Nick().." with the args "..tostring(args[3]))
	else
		ply:PrintMessage(HUD_PRINTTALK, "No 'who' found for rp_forcecexec 'who' should be the first argument.")
	end
end)

function ForceConsoleCommand(player, command, args)
	if args == nil then
		umsg.Start("unblocked_cexec", player) umsg.String(command) umsg.End()
	else
		umsg.Start("unblocked_cexec", player)
			umsg.String(command)
			umsg.String(args)
		umsg.End()
	end
end