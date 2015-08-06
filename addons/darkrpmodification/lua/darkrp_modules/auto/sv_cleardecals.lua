concommand.Add("rp_cleardecals", function(player, cmd, args)
	if not player:IsAdmin() then DarkRP.notify(player, 1, 4, "Only admins can use this command!") return end
	for _,v in pairs(player.GetAll()) do v:ConCommand("r_cleardecals\n") end
end)

