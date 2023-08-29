TypeNames:
; entries correspond to types (see constants/type_constants.asm)
	table_width 2, TypeNames
	dw Normal
	dw Fighting
	dw Flying
	dw Poison
	dw Ground
	dw Rock
	dw Bird
	dw Bug
	dw Ghost
	dw Steel
	assert_table_length UNUSED_TYPES
	dw Normal
	dw Normal
	dw Normal
	dw Normal
	dw Normal
	dw Normal
	dw Normal
	dw Normal
	dw Normal
	dw CurseType
	assert_table_length UNUSED_TYPES_END
	dw Fire
	dw Water
	dw Grass
	dw Electric
	dw Psychic
	dw Ice
	dw Dragon
	dw Dark
	assert_table_length TYPES_END

Normal:    db "NORMAL@"
Fighting:  db "LUCHA@"
Flying:    db "VOLADOR@"
Poison:    db "VENENO@"
CurseType: db "¿¿??@"
Fire:      db "FUEGO@"
Water:     db "AGUA@"
Grass:     db "PLANTA@"
Electric:  db "ELÉCTRIC@"
Psychic:   db "PSÍQUICO@"
Ice:       db "HIELO@"
Ground:    db "TIERRA@"
Rock:      db "ROCA@"
Bird:      db "@"
Bug:       db "BICHO@"
Ghost:     db "FANTASMA@"
Steel:     db "ACERO@"
Dragon:    db "DRAGÓN@"
Dark:      db "SINIEST.@"
