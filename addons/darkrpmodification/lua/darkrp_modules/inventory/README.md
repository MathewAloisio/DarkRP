# Inventory Documentation #


## PLAYER meta functions ##


* PLAYER:DropInvItem(slot,force) **[SERVER]**
```
    *drops the item in 'self.Inv[slot]' as loot via 'items.CreateLoot()'.
	*force is an optional argument, if set to 1 it ignores the drop-item delay.
    *returns true on success, false on failure.
```

* PLAYER:GetMaxInvWeight() **[SHARED]**
```


    * returns the total weight the specified character is allowed to carry in their inventory.

```
* PLAYER:GiveInvItem(id, quantity, e, ex) **[SERVER]**
```


    * gives a player the specific 

    * returns false if failed, returns true if succeeded.
```
* PLAYER:RemoveInvItem(id, quantity, slot) **[SERVER]**
```


    * removes a specific item by either slot or ID. 

    * usage: [Slot specified] player:RemoveInvItem(_, quantity, slot) [ItemID specified] 
      player:RemoveInvItem(id, quantity).

```
* PLAYER:RemoveAllItem(id) **[SERVER]**
```


    * removes all occurrences of an item where 'items.Get(id).ID' matches 'id' in your inventory.

```
* PLAYER:CanHoldItem(id, quantity) **[SHARED]**
```



    * returns true if the player can hold the weight of 'items.Get(id).Weight*quantity', false if they can't.

```
* PLAYER:CheckInv() **[SHARED]**
```


    * returns true if a player has free slots in their inventory, false if they don't.

```
* PLAYER:CheckInvItem(id) **[SHARED]**
```


    * returns true player has an item with a matching 'id', returns false if they don't.
    
    * NOTE: for use with non-quantity based items ONLY.


```
* PLAYER:HasInvItem(id, quantity) **[SHARED]**

```


    * checks if the player has a stack of 'items.Get(id)' with a quantity equal to or greater than 'quantity'.

    * returns: slot if player has a stack of item 'id' in an amount equal to or greater than 
      'quantity', returns -1 if the player doesn't.

    * NOTE: for quantity-based items ONLY. 
    * IMPORTANT: returns -1 instead of false, don't compare to false because 'slot' can return 0 which 
                     is equivalent to false.

```
* PLAYER:CheckInvItemEx(id) **[SHARED]**
```


    * returns the quantity of all items in your inventory where 'items.Get(id).ID' matches 'id'.

```

**NOTE:** *Use 'inventory.' instead of the meta-prefix when calling "Shared" or "Clientside" functions in a clientside environment. Example: 'inventory.CheckInvItemEx(id)' instead of 'PLAYER:CheckInvItemEx(id)'.*

## Serverside Player Variables: ##
* **player.Inv** *[type: table]*
* **player.InvWeight** *[type: float]*

## Clientside Player Variables: ##
* **Inv** *[type: table]* *[local to cl_inventory.lua]*
* **InvWeight** *[type: float]* *[local to cl_inventory.lua]*
* **MaxInvWeight** *[type: double]* *[usage: inventory.GetMaxInvWeight()]*

## Clientside-only functions: ##
* **inventory.Get(slot)** *[returns: 'Inv[slot]' table]*
* **inventory.GetAll()** *[returns: 'Inv' table]*

## Configurable Variables: ##
* **MAX_INV_SLOTS** *[default: 49]*
* **MAX_INV_WEIGHT** *[default: 100]*