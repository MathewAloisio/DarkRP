_G.clothing = _G.clothing or {}

local ClothingList = {}

function clothing.GetAll()
	return ClothingList
end

function clothing.Get(id)
	return ClothingList[id]
end

function clothing.GetName(id)
	return ClothingList[id].Name
end

function clothing.GetFlags(id)
	return ClothingList[id].Flags
end

function clothing.GetData(id)
	return ClothingList[id].ClothingData
end

function clothing.Register(tbl)
	if !tbl or tbl.ID == nil then MsgN("[ERROR] no 'tbl.ID' sent to 'clothing.Register'.") return end
	ClothingList[tbl.ID] = tbl
end

local files = file.Find("darkrp_modules/clothing/clothes/*.lua", "LUA")
for _,v in pairs(files) do
	if SERVER then
		AddCSLuaFile(string.format("darkrp_modules/clothing/clothes/%s", v))
	end
	include(string.format("darkrp_modules/clothing/clothes/%s", v))
	MsgN(string.format("Clothing loaded: %s", v))
end