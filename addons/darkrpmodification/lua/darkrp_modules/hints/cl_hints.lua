--Hints are handled 100% by the client, this isn't something the server really should have to care about.
local hintsTbl = hintsTbl or {}

function AddHint(hint)
	table.insert(hintsTbl, hint)
end

hook.Add("Initialize", "HINT::Initialize", function()
	local lastHint = lastHint or 1
	if not timer.Exists("Hints") then
		timer.Create("Hints", 120, 0, function()
			chat.AddText(Color(0, 0, 255), "[HINT] ",  Color(214, 214, 214), hintsTbl[lastHint])
			lastHint = lastHint+1
		end)
	end
end)