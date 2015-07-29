local function saveDonate(player)
	local tbl = {
		rank = player.Donate,
		date = player.DonateTime
	}
	file.Write(string.format("roleplay/donate/%s.txt", player:UniqueID()), pon.encode(tbl))
end
hook.Add("PlayerDisconnect", "donateDisconnect", saveDonate)

util.AddNetworkString("networkDonate")
local function networkDonate(player)
	net.Start("networkDonate")
		net.WriteInt(player.Donate, 3)
		net.WriteDouble(player:DonateDaysLeft())
	net.Send(player)
end

hook.Add("PlayerInitialSpawn", "loadDonate", function(player)
	if file.Exists(string.format("roleplay/inventory/%s.txt", player:UniqueID()), "DATA") then
		local tbl = pon.decode(file.Read(string.format("roleplay/inventory/%s.txt", player:UniqueID()), "DATA"))
		player.Donate = tbl.rank
		player.DonateTime = tbl.date
		player.DonateExpire = os.difftime(tbl.date, os.time())
		if tbl.rank > 0 then
			local dl = player:DonateDaysLeft()
			if dl > 0 then --Not yet expired.
				player:PrintMessage(HUD_PRINTTALK, string.format("Welcome back! you're a %s donator and your rank is set to expire in %d days.", defines.TranslateDonate(tbl.rank), dl)
			else --Expired.
				player:SetDonate(0)
				player:PrintMessage(HUD_PRINTTALK, string.format("Welcome back! your %s donor status has expired. You can renew your donor status at %s/donate.", defines.TranslateDonate(tbl.rank), defines.Website)
			end
		end
	else 
		player.Donate = 0
		player.DonateTime = 0
		player.DonateExpire = 0
		saveDonate(player)
	end
	networkDonate(player)
end)

local PLAYER = FindMetaTable("Player")

function PLAYER:DonateDaysLeft() -- returns the days left in a players donor subscription.
	return (30 - defines.SecondsToDays(self.DonateExpires)) or 0
end

function PLAYER:SetDonate(rank)
	if rank == 0 then
		self.Donate = 0
		self.DonateTime = 0
		self.DonateExpire = 0 
		saveDonate(self)
		return
	end
	local t = os.time()
	if self.Donate > 0 then --If they're already a donor add their time-left.
		self.DonateTime = (t - defines.DaysToSeconds(self:DonateDaysLeft())) --Inefficient but who cares?
		self.DonateExpire = os.difftime(self.DonateTime, t)
	else --else give them the normal 30 days.
		self.DonateTime = t
		self.DonateExpire = 0
	end
	self.Donate = rank
	saveDonate(self)
	networkDonate(self)
end

function PLAYER:IsDonate(rank)
	return (self.Donate >= rank) or false
end

function PLAYER:GetDonate()
	return self.Donate
end