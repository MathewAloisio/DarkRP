_G.items = _G.items or {}

local ItemList = {}

function items.GetAll()
	return ItemList
end

function items.Get(id)
	return ItemList[id]
end

function items.GetName(id, quantity)
	if quantity > 1 then return ItemList[id].Plural end
	return ItemList[id].Name
end

function items.GetWeight(id)
	return ItemList[id].Weight or 0.0
end

function items.IsStackable(id)
	return ItemList[id].Stackable or false
end

do
	local files = file.Find("darkrp_modules/items/items/*.lua", "LUA")

	function items.Register(tbl)
		if !tbl or tbl.ID == nil then ErrorNoHalt("[ERROR] no 'tbl.ID' sent to 'items.Register'.\n") return end
		if !tbl or tbl.ID == nil then ErrorNoHalt("[ERROR] no 'tbl.ID' sent to 'items.Register'.\n") return end
		if ItemList[tbl.ID] ~= nil then ErrorNoHalt(string.format("[WARNING] items.Register failed: Reason - Duplicate 'ITEM.ID'.\n[DEBUG] Failed to register Item[%q](%i) because Item[%q](%i) already exists!\n[SOLUTION] Fix this by changing Item[%q]'s or Item[%s]'s ID to %i.\n**NOTE: Change the ID of the item that was most recently made.**\n",tbl.Name,tbl.ID,ItemList[tbl.ID].Name,tbl.ID,tbl.Name,ItemList[tbl.ID].Name,(ItemList[#files] == nil and #files) or #files+1)) return end
		ItemList[tbl.ID] = tbl
	end

	for _,v in pairs(files) do
		if SERVER then
			AddCSLuaFile(string.format("darkrp_modules/items/items/%s", v))
		end
		include(string.format("darkrp_modules/items/items/%s", v))
		MsgN(string.format("Item loaded: %s", v))
	end
end