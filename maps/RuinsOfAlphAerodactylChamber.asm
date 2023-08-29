RuinsOfAlphAerodactylChamber_MapScripts:
	def_scene_scripts
	scene_script RuinsOfAlphAerodactylChamberCheckWallScene, SCENE_RUINSOFALPHAERODACTYLCHAMBER_CHECK_WALL
	scene_script RuinsOfAlphAerodactylChamberNoopScene,      SCENE_RUINSOFALPHAERODACTYLCHAMBER_NOOP

	def_callbacks
	callback MAPCALLBACK_TILES, RuinsOfAlphAerodactylChamberHiddenDoorsCallback

RuinsOfAlphAerodactylChamberCheckWallScene:
	checkevent EVENT_WALL_OPENED_IN_AERODACTYL_CHAMBER
	iftrue .OpenWall
	end

.OpenWall:
	sdefer RuinsOfAlphAerodactylChamberWallOpenScript
	end

RuinsOfAlphAerodactylChamberNoopScene:
	end

RuinsOfAlphAerodactylChamberHiddenDoorsCallback:
	checkevent EVENT_WALL_OPENED_IN_AERODACTYL_CHAMBER
	iftrue .WallOpen
	changeblock 4, 0, $2e ; closed wall
.WallOpen:
	checkevent EVENT_SOLVED_AERODACTYL_PUZZLE
	iffalse .FloorClosed
	endcallback

.FloorClosed:
	changeblock 2, 2, $01 ; left floor
	changeblock 4, 2, $02 ; right floor
	endcallback

RuinsOfAlphAerodactylChamberWallOpenScript:
	pause 30
	earthquake 30
	showemote EMOTE_SHOCK, PLAYER, 20
	pause 30
	playsound SFX_STRENGTH
	changeblock 4, 0, $30 ; open wall
	reloadmappart
	earthquake 50
	setscene SCENE_RUINSOFALPHAERODACTYLCHAMBER_NOOP
	closetext
	end

RuinsOfAlphAerodactylChamberPuzzle:
	refreshscreen
	setval UNOWNPUZZLE_AERODACTYL
	special UnownPuzzle
	closetext
	iftrue .PuzzleComplete
	end

.PuzzleComplete:
	setevent EVENT_RUINS_OF_ALPH_INNER_CHAMBER_TOURISTS
	setevent EVENT_SOLVED_AERODACTYL_PUZZLE
	setflag ENGINE_UNLOCKED_UNOWNS_S_TO_W
	setmapscene RUINS_OF_ALPH_INNER_CHAMBER, SCENE_RUINSOFALPHINNERCHAMBER_STRANGE_PRESENCE
	earthquake 30
	showemote EMOTE_SHOCK, PLAYER, 15
	changeblock 2, 2, $18 ; left hole
	changeblock 4, 2, $19 ; right hole
	reloadmappart
	playsound SFX_STRENGTH
	earthquake 80
	applymovement PLAYER, RuinsOfAlphAerodactylChamberSkyfallTopMovement
	playsound SFX_KINESIS
	waitsfx
	pause 20
	warpcheck
	end

RuinsOfAlphAerodactylChamberAncientReplica:
	jumptext RuinsOfAlphAerodactylChamberAncientReplicaText

RuinsOfAlphAerodactylChamberDescriptionSign:
	jumptext RuinsOfAlphAerodactylChamberDescriptionText

RuinsOfAlphAerodactylChamberWallPatternLeft:
	opentext
	writetext RuinsOfAlphAerodactylChamberWallPatternLeftText
	setval UNOWNWORDS_LIGHT
	special DisplayUnownWords
	closetext
	end

RuinsOfAlphAerodactylChamberWallPatternRight:
	checkevent EVENT_WALL_OPENED_IN_AERODACTYL_CHAMBER
	iftrue .WallOpen
	opentext
	writetext RuinsOfAlphAerodactylChamberWallPatternRightText
	setval UNOWNWORDS_LIGHT
	special DisplayUnownWords
	closetext
	end

.WallOpen:
	opentext
	writetext RuinsOfAlphAerodactylChamberWallHoleText
	waitbutton
	closetext
	end

RuinsOfAlphAerodactylChamberSkyfallTopMovement:
	skyfall_top
	step_end

RuinsOfAlphAerodactylChamberWallPatternLeftText:
	text "Aparecieron"
	line "dibujos en las"
	cont "paredes…"
	done

RuinsOfAlphAerodactylChamberUnownText: ; unreferenced
	text "¡Es texto UNOWN!"
	done

RuinsOfAlphAerodactylChamberWallPatternRightText:
	text "Aparecieron"
	line "dibujos en las"
	cont "paredes…"
	done

RuinsOfAlphAerodactylChamberWallHoleText:
	text "¡Hay un gran agu-"
	line "jero en la pared!"
	done

RuinsOfAlphAerodactylChamberAncientReplicaText:
	text "Es una réplica de"
	line "un #MON"
	cont "antiguo."
	done

RuinsOfAlphAerodactylChamberDescriptionText:
	text "Este #MON"
	line "volador ataca a"

	para "su presa con sus"
	line "fuertes colmillos."
	done

RuinsOfAlphAerodactylChamber_MapEvents:
	db 0, 0 ; filler

	def_warp_events
	warp_event  3,  9, RUINS_OF_ALPH_OUTSIDE, 4
	warp_event  4,  9, RUINS_OF_ALPH_OUTSIDE, 4
	warp_event  3,  3, RUINS_OF_ALPH_INNER_CHAMBER, 8
	warp_event  4,  3, RUINS_OF_ALPH_INNER_CHAMBER, 9
	warp_event  4,  0, RUINS_OF_ALPH_AERODACTYL_ITEM_ROOM, 1

	def_coord_events

	def_bg_events
	bg_event  2,  3, BGEVENT_READ, RuinsOfAlphAerodactylChamberAncientReplica
	bg_event  5,  3, BGEVENT_READ, RuinsOfAlphAerodactylChamberAncientReplica
	bg_event  3,  2, BGEVENT_UP, RuinsOfAlphAerodactylChamberPuzzle
	bg_event  4,  2, BGEVENT_UP, RuinsOfAlphAerodactylChamberDescriptionSign
	bg_event  3,  0, BGEVENT_UP, RuinsOfAlphAerodactylChamberWallPatternLeft
	bg_event  4,  0, BGEVENT_UP, RuinsOfAlphAerodactylChamberWallPatternRight

	def_object_events
