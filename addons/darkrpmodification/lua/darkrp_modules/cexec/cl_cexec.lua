usermessage.Hook("unblocked_cexec", function(um)
	local concmd = um:ReadString()
	local toargs = um:ReadString()
	if toargs ~= nil then
		RunConsoleCommand(concmd, toargs)
	else
		RunConsoleCommand(concmd)
	end
end)
