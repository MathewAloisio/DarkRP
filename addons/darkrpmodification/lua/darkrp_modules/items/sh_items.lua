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

function items.Register(tbl)
	if !tbl or tbl.ID == nil then MsgN("[ERROR] no 'tbl.ID' sent to 'items.Register'.") return end
	ItemList[tbl.ID] = tbl
end