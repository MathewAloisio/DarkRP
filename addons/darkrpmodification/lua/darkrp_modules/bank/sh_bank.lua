_G.defines = _G.defines or {}

defines.Dialog = defines.Dialog or {}
defines.Dialog["Banker"] = {}
defines.Dialog["Banker"][1] = {
	Text 		= "Hello sir, would you like to see your bank account?",
	Replies 	= {1, 2}
}
defines.Dialog["Banker"][2] = {
	Text 		= "Have a good day sir!",
	Replies 	= {5}
}

defines.Replies = defines.Replies or {}
defines.Replies["Banker"] = {}
defines.Replies["Banker"][1] = {
	Text		= "Yes.",
	OnUse		= function(player) umsg.Start("openBank", player) umsg.End() end
}
defines.Replies["Banker"][2] = {
	Text		= "No thanks.",
	OnUse		= function() return 2 end
}

defines.Replies["Banker"][5] = {
	Text		= "See you later.",
	OnUse		= function() return nil end
}