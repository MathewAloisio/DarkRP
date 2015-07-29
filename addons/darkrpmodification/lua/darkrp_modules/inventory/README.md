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
ITEM.Weight = 0.0
ITEM.Type = TYPE_ITEM
ITEM.Class = CLASS_NONE