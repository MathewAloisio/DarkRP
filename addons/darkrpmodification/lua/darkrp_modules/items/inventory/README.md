# Inventory Documentation #


## PLAYER meta functions ##


* PLAYER:GetMaxInvSlots()
```
#!lua

    * returns the total amount of available inventory slots for the specified player.

```
* PLAYER:GetMaxInvWeight()
```
#!lua

    * returns the total weight the specified character is allowed to carry in their inventory.

```
* PLAYER:GiveInvItem(id, quantity, e, ex)
```
#!lua

    * gives a player the specific 

    * returns false if failed, returns true if succeeded.
```
* PLAYER:RemoveInvItem(id, quantity, slot)
```
#!lua

    * removes a specific item by either slot or ID. 

    * usage: [Slot specified] player:RemoveInvItem(_, quantity, slot) [ItemID specified] 
      player:RemoveInvItem(id, quantity).

```
* PLAYER:RemoveAllItem(id) 
```
#!lua

    * removes all occurrences of an item where 'items.Get(id).ID' matches 'id' in your inventory.

```
* PLAYER:CanHoldItem(id)
```
#!lua


    * returns true if the player can hold the weight of 'items.Get(id).Weight', false if they can't.

```
* PLAYER:CheckInv()
```
#!lua

    * returns true if a player has free slots in their inventory, false if they don't.

```
* PLAYER:CheckInvItem(id)
```
#!lua

    * returns true player has an item with a matching 'id', returns false if they don't.
    
    * NOTE: for use with non-quantity based items ONLY.


```
* PLAYER:HasInvItem(id, quantity)

```
#!lua

    * checks if the player has a stack of 'items.Get(id)' with a quantity equal to or greater than 'quantity'.

    * returns: slot if player has a stack of item 'id' in an amount equal to or greater than 
      'quantity', returns -1 if the player doesn't.

    * NOTE: for quantity-based items ONLY. 
    * **IMPORTANT:** returns -1 instead of false, don't compare to false because 'slot' can return 0 which 
                     is equivalent to false.

```
* PLAYER:CheckInvItemEx(id) 
```
#!lua

    * returns the quantity of all items in your inventory where 'items.Get(id).ID' matches 'id'.

```

items -> (table structure)
items.Get(id) - returns the table of the item with the given-ID.
items.GetAll() - returns the whole items table.
items.GetName(id, quantity) - returns an appropriate name for the item based on the inputed 'id' and 'quantity'.
items.Register(ITEM) - registers a new item with the data provided in the 'ITEM' table.

ITEM -> (table fields)
ITEM.ID = 0
ITEM.Name = ""
ITEM.Plural = ITEM.Name or ""
ITEM.Model = ""
ITEM.Weight = 0
ITEM.Type = TYPE_ITEM
ITEM.Class = CLASS_NONE