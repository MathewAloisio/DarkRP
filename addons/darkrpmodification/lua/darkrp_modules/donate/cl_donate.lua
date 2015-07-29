local Donate = Donate or 0
local DaysLeft = DaysLeft or 0
net.Receive("networkDonate", function(len)
	Donate = net.ReadInt(3)
	Daysleft = net.ReadDouble()
end)

_G.donate = _G.donate or {}

function donate.DonateDaysLeft()
	return DaysLeft
end

function donate.GetDonate()
	return Donate
end

function donate.IsDonate(rank)
	return (Donate >= rank) or false
end