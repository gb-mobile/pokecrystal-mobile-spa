ItemPocketNames:
; entries correspond to item type constants
	table_width 2, ItemPocketNames
	dw .Item
	dw .Key
	dw .Ball
	dw .TM
	assert_table_length NUM_ITEM_TYPES

.Item: db "CAJA OBJ@"
.Key:  db "OBJ. CLAVE@"
.Ball: db "CAJA-BALL@"
.TM:   db "CAJA-MT@"
