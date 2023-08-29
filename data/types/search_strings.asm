PokedexTypeSearchStrings:
; entries correspond with PokedexTypeSearchConversionTable (see data/types/search_types.asm)
	table_width POKEDEX_TYPE_STRING_LENGTH, PokedexTypeSearchStrings
	db "  ----  @"
	db " NORMAL @"
	db " FUEGO  @"
	db "  AGUA  @"
	db " PLANTA @"
	db "ELÉCTRIC@"
	db " HIELO  @"
	db " LUCHA  @"
	db " VENENO @"
	db " TIERRA @"
	db "VOLADOR @"
	db " PSICO  @"
	db " BICHO  @"
	db "  ROCA  @"
	db "FANTASMA@"
	db " DRAGÓN @"
	db "SINIEST.@"
	db " ACERO  @"
	assert_table_length NUM_TYPES + 1
