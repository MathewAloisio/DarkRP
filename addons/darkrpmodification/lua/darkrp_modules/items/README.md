### items.CreateLoot(id, quantity, e, ex, pos, ang) **[SERVER]** 

```
    *creates loot with the given arguments. 

    *returns: true if succeeds, false if fails.
```


### items.Get(id) **[SHARED]**

```
    *returns the table ItemInfo[id].
```


### items.GetAll() **[SHARED]**

```
    *returns the table ItemInfo in it's entirety.
```


### items.GetName(id, quantity) **[SHARED]**

```
    *returns an appropriate name for the item based on the inputed 'id' and 'quantity'.
```


### items.Register(ITEM) **[SHARED]**

```
    *registers a new item with the data provided in the 'ITEM' table.
    *returns nil.
```

# Example item file with all **current** parameters.#

```
#!lua

local ITEM = {}
ITEM.ID = 0 --The items uniqueID.
ITEM.Name = "" --The name of the item returned in menus and when 'items.GetName(id,q)' is called while q < 2.
ITEM.Plural = ITEM.Name or "" --The name of the item 'items.GetName(id,q)' returns when q > 1.
ITEM.Description = "" --A description of what the item is.
ITEM.Model = "" --The items model.
ITEM.Weight = 0.0 --The items weight.
ITEM.Type = TYPE_ITEM --Item type. (for easier use-with-code, maybe sorting later).
ITEM.Class = CLASS_NONE --Class for this item. (for easier use-with-code.)
ITEM.CanSpawn = true --Can this item be dropped?
ITEM.LookAt = vector_origin --For icon-adjustment in the inventory.
ITEM.CamPos = Vector(10,40,0) --For icon-adjustment in the inventory.

ITEM.Args = { -- For variables that are specific to this item-type only.
	--Example = false,
	--Example2 = true
}

ITEM.Actions = {} --The actions displayed when the menu is used.
ITEM.Actions[1] = {
	Name = "Use",
	ShowOption = function() return true end,
	DoAction = function()
		--Code here.
	end
}
ITEM.Actions[2] = {
	Name = "Drop",
	ShowOption = function() return true end,
	DoAction = function()
		--Code here.
	end
}

--OPTIONAL:
ITEM.ClassOverride = "darkrp_item" --Entity class that is created when 'item.CreateLoot()' spawns this item.
```
