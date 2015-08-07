### items.CreateLoot(id, quantity, e, ex, pos, ang) **[SERVER]** 

```
    *creates loot with the given arguments. 

    *returns: 'ent' if succeeds, false if fails.
```


### items.Get(id) **[SHARED]**

```
    *returns the table ItemList[id].
```


### items.GetAll() **[SHARED]**

```
    *returns the table ItemList in it's entirety.
```


### items.GetName(id, quantity) **[SHARED]**

```
    *returns an appropriate name for the item based on the inputed 'id' and 'quantity'.
```

### items.GetWeight(id) **[SHARED]**

```
    *returns ItemList[id].Weight
```

### items.IsStackable(id) **[SHARED]**

```
    *returns true if the item is stackable, false if it isn't.
```

### items.Register(ITEM) **[SHARED]**

```
    *registers a new item with the data provided in the 'ITEM' table.
    *returns nil.
```

***NOTE:*** ITEM.Action[0] is defaulted to 'Equip' when ITEM.Type == ITYPE_WEAPON.

***NOTE:*** The LAST ITEM.Action is ALWAYS 'Drop' when there is no 'DoAction' override.

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
ITEM.Type = 0 -- 0 = ITYPE_ITEM, 1 = ITYPE_FOOD, 2 = ITYPE_DRINK, 3 = ITYPE_DRUG, 4 = ITYPE_WEAPON, 5 = ITYPE_AMMO, 6 = ITYPE_CLOTHING.
ITEM.CanSpawn = true --Can this item be dropped?
ITEM.LookAt = vector_origin --For icon-adjustment in the inventory.
ITEM.CamPos = Vector(10,40,0) --For icon-adjustment in the inventory.
ITEM.Stackable = false --Can this item be stacked? (quantity greater than 1) [Optional]

ITEM.Actions = {} --The actions displayed when the menu is used.
ITEM.Actions[0] = { --Overridden on ITYPE_WEAPON items, however still NOT optional.
	Name = "Use",
	ShowOption = function(player) return true end, --Optional
	DoAction = function(player,slot) --Optional on Action[0] for ITYPE_WEAPON items ONLY.
		--Code here.
	end
}
ITEM.Actions[1] = {--NOTE: If you don't include a 'DoAction' on Action[max] it is assumed to be 'Drop'.
	Name = "Drop",
	ShowOption = function(player) return true end, --Optional
	DoAction = function(player,slot) --Optional on the LAST ACTION only.
		--Code here.
	end
}

--OPTIONAL:
ITEM.Class = 0 -- 0 = ICLASS_NONE, 1 = ICLASS_FISH, 2 = ICLASS_PRIMARY, 3 = ICLASS_SECONDARY, 4 = ICLASS_MELEE.
ITEM.WepClass = "" -- For easier use with weapons. Example: "weapon_pistol"
ITEM.ClassOverride = "darkrp_item" --Entity class that is created when 'item.CreateLoot()' spawns this item.
ITEM.DropAng = Angle(0,0,0) --Choose the angle this item spawns at when created with 'item.CreateLoot(id)'
ITEM.OnSpawn = function(ent) end --Called after the item is spawned as loot, returns the entity created as the argument.
ITEM.Args = { -- For variables that are specific to this item-type only.
	--Example = false,
	--Example2 = true
}

items.Register(ITEM)
```