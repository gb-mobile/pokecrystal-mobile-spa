BattleTowerTrainers:
; The trainer class is not used in Crystal 1.0 due to a bug.
; Instead, the sixth character in the trainer's name is used.
; See BattleTowerText in engine/events/battle_tower/trainer_text.asm.
	table_width (NAME_LENGTH - 1) + 1, BattleTowerTrainers
	; name, class
	db "HANSON@@@@", FISHER
	db "SOYA@@@@@@", POKEMANIAC
	db "MASU@@@@@@", GUITARIST
	db "NICKY@@@@@", SCIENTIST
	db "OLSON@@@@@", POKEFANM
	db "ZABORA@@@@", LASS
	db "RUPERTO@@@", YOUNGSTER
	db "ALEJO@@@@@", HIKER
	db "KAWAKAMI@@", TEACHER
	db "VOLDO@@@@@", POKEFANM
	db "KIM@@@@@@@", KIMONO_GIRL
	db "PAN@@@@@@@", BOARDER
	db "DÍAZ@@@@@@", PICNICKER
	db "ERICK@@@@@", BIKER
	db "FAIR@@@@@@", JUGGLER
	db "MUFFY@@@@@", POKEFANF
	db "JUNI@@@@@@", FIREBREATHER
	db "JÁVEA@@@@@", SWIMMERF
	db "KAUFMAN@@@", SWIMMERM
	db "CASTA@@@@@", SKIER
	db "JUNIOR@@@@", CAMPER
	assert_table_length BATTLETOWER_NUM_UNIQUE_MON
; The following can only be sampled in Crystal 1.1.
	db "OCÓN@@@@@@", GENTLEMAN
	db "FROST@@@@@", BEAUTY
	db "MORS@@@@@@", SUPER_NERD
	db "YUFUNE@@@@", BLACKBELT_T
	db "RAYA@@@@@@", COOLTRAINERF
	db "RODRI@@@@@", OFFICER
	db "SANTIAGO@@", PSYCHIC_T
	db "CASCABEL@@", POKEFANM
	db "THURM@@@@@", SCIENTIST
	db "VALENTINA@", BEAUTY
	db "WAGNER@@@@", CAMPER
	db "YATES@@@@@", BIRD_KEEPER
	db "LÓPEZ@@@@@", PICNICKER
	db "BAR@@@@@@@", POKEMANIAC
	db "MORI@@@@@@", SCIENTIST
	db "KONDO@@@@@", SAGE
	db "MINI@@@@@@", SCHOOLBOY
	db "PÉREZ@@@@@", FISHER
	db "ARI@@@@@@@", KIMONO_GIRL
	db "CAMP@@@@@@", PSYCHIC_T
	db "FREEMAN@@@", CAMPER
	db "GERTRU@@@@", LASS
	db "DINER@@@@@", GENTLEMAN
	db "JACKSON@@@", POKEFANF
	db "COBU@@@@@@", POKEMANIAC
	db "LEÓN@@@@@@", YOUNGSTER
	db "MARINA@@@@", TEACHER
	db "WILLY@@@@@", SAILOR
	db "ARRÁS@@@@@", BLACKBELT_T
	db "OJÉN@@@@@@", SUPER_NERD
	db "SONIA@@@@@", COOLTRAINERF
	db "AGUAS@@@@@", SWIMMERM
	db "SERES@@@@@", BIRD_KEEPER
	db "ROC@@@@@@@", BOARDER
	db "TURNER@@@@", LASS
	db "VICENT@@@@", OFFICER
	db "VANDY@@@@@", SKIER
	db "RANGO@@@@@", SCHOOLBOY
	db "CAMINO@@@@", SWIMMERF
	db "JUANITO@@@", YOUNGSTER
	db "ADÁN@@@@@@", GUITARIST
	db "SATOS@@@@@", BUG_CATCHER
	db "TAJIR@@@@@", BUG_CATCHER
	db "VACA@@@@@@", POKEMANIAC
	db "COLÍN@@@@@", SCIENTIST
	db "MORT@@@@@@", SUPER_NERD
	db "RAMONA@@@@", SWIMMERF
	db "RULI@@@@@@", BIKER
	db "ÍGNEO@@@@@", FIREBREATHER
	assert_table_length BATTLETOWER_NUM_UNIQUE_TRAINERS
