	object_const_def
	const ROUTE40BATTLETOWERGATE_ROCKER
	const ROUTE40BATTLETOWERGATE_TWIN

Route40BattleTowerGate_MapScripts:
	def_scene_scripts

	def_callbacks
	callback MAPCALLBACK_OBJECTS, RouteBattleTowerGateShowSailorCallback

RouteBattleTowerGateShowSailorCallback:
	special Mobile_DummyReturnFalse
	iffalse .nomobile
	clearevent EVENT_BATTLE_TOWER_OPEN_CIVILIANS

.nomobile
	return

Route40BattleTowerGateRockerScript:
	jumptextfaceplayer Route40BattleTowerGateUnusedText3

Route40BattleTowerGateTwinScript:
	special Mobile_DummyReturnFalse
	iftrue .mobile
	jumptextfaceplayer Route40BattleTowerGateUnusedText1

.mobile
	jumptextfaceplayer Route40BattleTowerGateUnusedText2

Route40BattleTowerGateUnusedText1:
	text "¿También has"
	line "venido a ver la"
	cont "TORRE BATALLA?"

	para "Pero imagino que"
	line "no puedes entrar"
	cont "todavía."
	done

Route40BattleTowerGateUnusedText2:
	text "TORRE BATALLA ha"
	line "abierto."

	para "Quiero ir, pero"
	line "todavía no he"

	para "ideado una frase"
	line "para cuando gane."
	done

Route40BattleTowerGateRockerText:
	text "¿Vas a la TORRE"
	line "BATALLA?"

	para "Es un secreto,"
	line "pero si ganas"

	para "muchas veces"
	line "podrás conseguir"

	para "regalos"
	line "especiales."
	done

Route40BattleTowerGateUnusedText3:
	text "Voy a entrenar mi"
	line "#MON y así"

	para "estaré listo para"
	line "la TORRE BATALLA."
	done

Route40BattleTowerGateTwinText:
	text "Los niveles de los"
	line "#MON que quiero"

	para "usar son todos"
	line "diferentes."

	para "¡Tengo que"
	line "entrenarlos ahora!"
	done

Route40BattleTowerGate_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  4,  7, ROUTE_40, 1
	warp_event  5,  7, ROUTE_40, 1
	warp_event  4,  0, BATTLE_TOWER_OUTSIDE, 1
	warp_event  5,  0, BATTLE_TOWER_OUTSIDE, 2

	def_coord_events

	def_bg_events

	def_object_events
	object_event  3,  3, SPRITE_ROCKER, SPRITEMOVEDATA_SPINRANDOM_SLOW, 0, 0, -1, -1, PAL_NPC_GREEN, OBJECTTYPE_SCRIPT, 0, Route40BattleTowerGateRockerScript, EVENT_BATTLE_TOWER_OPEN_CIVILIANS
	object_event  7,  5, SPRITE_TWIN, SPRITEMOVEDATA_WALK_UP_DOWN, 0, 1, -1, -1, PAL_NPC_RED, OBJECTTYPE_SCRIPT, 0, Route40BattleTowerGateTwinScript, -1
