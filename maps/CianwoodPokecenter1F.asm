	object_const_def
	const CIANWOODPOKECENTER1F_NURSE
	const CIANWOODPOKECENTER1F_LASS
	const CIANWOODPOKECENTER1F_GYM_GUIDE
	const CIANWOODPOKECENTER1F_SUPER_NERD

CianwoodPokecenter1F_MapScripts:
	def_scene_scripts

	def_callbacks

CianwoodPokecenter1FNurseScript:
	jumpstd PokecenterNurseScript

CianwoodPokecenter1FLassScript:
	jumptextfaceplayer CianwoodPokecenter1FLassText

CianwoodGymGuideScript:
	faceplayer
	checkevent EVENT_BEAT_CHUCK
	iftrue .CianwoodGymGuideWinScript
	opentext
	writetext CianwoodGymGuideText
	waitbutton
	closetext
	end

.CianwoodGymGuideWinScript:
	opentext
	writetext CianwoodGymGuideWinText
	waitbutton
	closetext
	end

CianwoodPokecenter1FSuperNerdScript:
	special Mobile_DummyReturnFalse
	iftrue .mobile
	jumptextfaceplayer CianwoodPokecenter1FPreMobileText
	
.mobile
	jumptextfaceplayer CianwoodPokecenter1FMobileText

CianwoodPokecenter1FLassText:
	text "¿Conoces al"
	line "#MANÍACO?"

	para "Siempre está"
	line "presumiendo de sus"
	cont "raros #MON."
	done

CianwoodGymGuideText:
	text "Los entrenadores"
	line "del GIMNASIO"

	para "#MON de aquí"
	line "son muy"
	cont "agresivos."

	para "Si me ven, seguro"
	line "que vienen a por"
	cont "mí."

	para "Escucha este"
	line "consejo: el LÍDER"

	para "del GIMNASIO usa"
	line "#MON del tipo"
	cont "lucha."

	para "Así que deberías"
	line "retarle con"

	para "#MON de tipo"
	line "psíquico."

	para "Elimina sus #-"
	line "MON antes de que"

	para "puedan usar su"
	line "fuerza física."

	para "¿Y esas rocas en"
	line "mitad del"
	cont "GIMNASIO?"

	para "Si no las mueves"
	line "adecuadamente,"

	para "no llegarás hasta"
	line "el LÍDER del"
	cont "GIMNASIO."

	para "Si te atascas,"
	line "salte."
	done

CianwoodGymGuideWinText:
	text "¡<PLAYER>! ¡Has"
	line "ganado! ¡Con sólo"
	cont "mirarte, lo sé!"
	done

CianwoodPokecenter1FPreMobileText: ; unreferenced
	text "¿No te gusta mos-"
	line "trar tus #MON a"
	cont "tus amigos?"

	para "Ojalá pudiera"
	line "mostrarle mis"

	para "#MON a mi amigo"
	line "que vive en MALVA."
	done

CianwoodPokecenter1FMobileText: ; unreferenced
	text "He luchado con mi"
	line "amigo de MALVA"

	para "usando un ADAPTA-"
	line "DOR de MÓVIL."

	para "Voy perdiendo 5"
	line "a 7 contra él."
	cont "¡Tengo que ganar!"
	done

CianwoodPokecenter1FSuperNerdText:
	text "Me encanta fardar"
	line "de los #MON"

	para "que he mejorado."
	line "¿A ti no?"

	para "¡Voy a enfrentarme"
	line "a otros entrenado-"
	cont "res para mostrar"
	cont "mis #MON!"
	done

CianwoodPokecenter1F_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  3,  7, CIANWOOD_CITY, 3
	warp_event  4,  7, CIANWOOD_CITY, 3
	warp_event  0,  7, POKECENTER_2F, 1

	def_coord_events

	def_bg_events

	def_object_events
	object_event  3,  1, SPRITE_NURSE, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, 0, OBJECTTYPE_SCRIPT, 0, CianwoodPokecenter1FNurseScript, -1
	object_event  1,  5, SPRITE_LASS, SPRITEMOVEDATA_WALK_UP_DOWN, 0, 1, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, CianwoodPokecenter1FLassScript, -1
	object_event  5,  3, SPRITE_GYM_GUIDE, SPRITEMOVEDATA_STANDING_DOWN, 0, 0, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, CianwoodGymGuideScript, -1
	object_event  8,  6, SPRITE_SUPER_NERD, SPRITEMOVEDATA_WALK_LEFT_RIGHT, 1, 0, -1, -1, PAL_NPC_BLUE, OBJECTTYPE_SCRIPT, 0, CianwoodPokecenter1FSuperNerdScript, -1
