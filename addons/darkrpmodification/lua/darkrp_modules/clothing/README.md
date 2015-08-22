# Example clothing file with all **current** parameters.#

```
#!lua

local CLOTHING = {}
CLOTHING.ID = 0 --The clothings uniqueID.
CLOTHING.Name = "" --The name of the clothing returned in menus, etc.
CLOTHING.Description = "" --A description of the clothing article.
CLOTHING.Slot = 0 -- 0 = SLOT_HEAD, 1 = SLOT_EYES, 2 = SLOT_SHOULDERS, 3 = SLOT_CHEST, 4 = SLOT_LEGS, 5 = SLOT_FEET.
CLOTHING.ItemID = 4 -- The parent-item's ID.
CLOTHING.Flags = { --Example of damage modifiers with clothing.
	[DMG_BLAST] = 5 --5% general restistance to DMG_BLAST.
	[DMG_BULLET] = 7 --7% bullet damage resistance (HITGROUP SPECIFIC!! ex: player.Clothing[SLOT_HEAD] affects headshot damage.)
}

CLOTHING.ClothingData = {} --Generated w/ the in-game clothing editor. (rp_editclothing)

clothing.Register(CLOTHING)
```

# NOTE: # Only SLOT_HEAD, SLOT_BODY, SLOT_ARMS, SLOT_LEGS affect damage.