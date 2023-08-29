	object_const_def
	const AZALEAPOKECENTER1F_NURSE
	const AZALEAPOKECENTER1F_GENTLEMAN
	const AZALEAPOKECENTER1F_FISHING_GURU
	const AZALEAPOKECENTER1F_POKEFAN_F

AzaleaPokecenter1F_MapScripts:
	def_scene_scripts
	scene_script AzaleaPokecenter1FNoopScene ; unusable

	def_callbacks

AzaleaPokecenter1FNoopScene:
	end

AzaleaPokecenter1FNurseScript:
	jumpstd PokecenterNurseScript

AzaleaPokecenter1FGentlemanScript:
	jumptextfaceplayer AzaleaPokecenter1FGentlemanText

AzaleaPokecenter1FFishingGuruScript:
	jumptextfaceplayer AzaleaPokecenter1FUnusedText

AzaleaPokecenter1FPokefanFScript:
	jumptextfaceplayer AzaleaPokecenter1FPokefanFText

AzaleaPokecenter1FGentlemanText:
	text "¿Tus #MON saben"
	line "movimientos MO?"

	para "Se pueden usar"
	line "estos movimientos"

	para "aunque el #MON"
	line "esté debilitado."
	done

AzaleaPokecenter1FUnusedText: 
	text "BILL creó el"
	line "Sistema de"

	para "Almacenamiento en"
	line "PC de los #MON."

	para "El PC de BILL"
	line "almacena hasta 20"
	cont "#MON por CAJA."
	done

AzaleaPokecenter1FFishingGuruText: ; Unused, English version replacement for above dialog.
	text "El PC de BILL"
	line "puede almacenar"

	para "hasta 20 #MON"
	line "por CAJA."
	done

AzaleaPokecenter1FPokefanFText:
	text "¿Sabes algo sobre"
	line "los BONGURI?"

	para "Abre uno, vacíalo"
	line "y rellénalo con"

	para "un aparato"
	line "especial."

	para "Así podrás atrapar"
	line "#MON."

	para "Antes de que se"
	line "inventaran las"

	para "# BALL, todos"
	line "usaban BONGURI."
	done

AzaleaPokecenter1F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  3,  7, AZALEA_TOWN, 1
	warp_event  4,  7, AZALEA_TOWN, 1
	warp_event  0,  7, POKECENTER_2F, 1

	def_coord_events

	def_bg_events

	def_object_events
	object_event  3,  1, SPRITE_NURSE, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, AzaleaPokecenter1FNurseScript, -1
	object_event  9,  6, SPRITE_GENTLEMAN, SPRITEMOVEDATA_WALK_UP_DOWN, 0, 1, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, AzaleaPokecenter1FGentlemanScript, -1
	object_event  6,  1, SPRITE_FISHING_GURU, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, AzaleaPokecenter1FFishingGuruScript, -1
	object_event  1,  4, SPRITE_POKEFAN_F, SPRITEMOVEDATA_WANDER, 1, 2, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, AzaleaPokecenter1FPokefanFScript, -1
