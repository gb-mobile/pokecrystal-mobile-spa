DEF EZCHAT_WORD_COUNT EQU EASY_CHAT_MESSAGE_WORD_COUNT
DEF EZCHAT_WORD_LENGTH EQU 8
DEF EZCHAT_WORDS_PER_ROW EQU 2
DEF EZCHAT_WORDS_PER_COL EQU 4
DEF EZCHAT_WORDS_IN_MENU EQU EZCHAT_WORDS_PER_ROW * EZCHAT_WORDS_PER_COL
DEF EZCHAT_CUSTOM_BOX_BIG_SIZE EQU 9
DEF EZCHAT_CUSTOM_BOX_BIG_START EQU 4
DEF EZCHAT_CUSTOM_BOX_START_X EQU 5
DEF EZCHAT_CUSTOM_BOX_START_Y EQU $1B
DEF EZCHAT_CHARS_PER_LINE EQU 18
DEF EZCHAT_BLANK_SIZE EQU 5

	const_def
	const EZCHAT_SORTED_A
	const EZCHAT_SORTED_B
	const EZCHAT_SORTED_C
	const EZCHAT_SORTED_D
	const EZCHAT_SORTED_E
	const EZCHAT_SORTED_F
	const EZCHAT_SORTED_G
	const EZCHAT_SORTED_H
	const EZCHAT_SORTED_I
	const EZCHAT_SORTED_J
	const EZCHAT_SORTED_K
	const EZCHAT_SORTED_L
	const EZCHAT_SORTED_M
	const EZCHAT_SORTED_N
	const EZCHAT_SORTED_O
	const EZCHAT_SORTED_P
	const EZCHAT_SORTED_Q
	const EZCHAT_SORTED_R
	const EZCHAT_SORTED_S
	const EZCHAT_SORTED_T
	const EZCHAT_SORTED_U
	const EZCHAT_SORTED_V
	const EZCHAT_SORTED_W
	const EZCHAT_SORTED_X
	const EZCHAT_SORTED_Y
	const EZCHAT_SORTED_Z
	const EZCHAT_SORTED_ETC
	const EZCHAT_SORTED_ERASE
	const EZCHAT_SORTED_MODE
	const EZCHAT_SORTED_CANCEL
DEF NUM_EZCHAT_SORTED EQU const_value
DEF EZCHAT_SORTED_NULL EQU $ff

; These functions seem to be related to the selection of preset phrases
; for use in mobile communications.  Annoyingly, they separate the
; Battle Tower function above from the data it references.

EZChat_LoadOneWord:
; hl = where to place it to
; d,e = params?
	ld a, e
	or d
	jr z, .error
	ld a, e
	and d
	cp $ff
	jr z, .error
	call CopyMobileEZChatToC608
	and a
	ret

.error
	ld c, l
	ld b, h
	scf
	ret

EZChat_RenderOneWord:
; hl = where to place it to
; d,e = params?
	push hl
	call EZChat_LoadOneWord
	pop hl
	ld a, 0
	ret c
	call PlaceString
	and a
	ret

Function11c075:
	push de
	ld a, c
	call Function11c254
	pop de
	ld bc, wEZChatWords ; (?)
	call EZChat_RenderWords
	ret

Function11c082: ; unreferenced
	push de
	ld a, c
	call Function11c254
	pop de
	ld bc, wEZChatWords
	call PrintEZChatBattleMessage
	ret

Function11c08f:
EZChat_RenderWords:
	ld l, e
	ld h, d
	ld a, EZCHAT_WORDS_PER_ROW ; Determines the number of easy chat words displayed before going onto the next line
	call .single_line
	ld de, 2 * SCREEN_WIDTH
	add hl, de
	ld a, EZCHAT_WORDS_PER_ROW
.single_line
	push hl
.loop
	push af
	ld a, [bc]
	ld e, a
	inc bc
	ld a, [bc]
	ld d, a
	inc bc
	push bc
	call EZChat_RenderOneWord
	jr c, .okay
	inc bc

.okay
	ld l, c
	ld h, b
	pop bc
	pop af
	dec a
	jr nz, .loop
	pop hl
	ret

PrintEZChatBattleMessage:
; Use up to 6 words from bc to print text starting at de.
	; Preserve [wJumptableIndex], [wcf64]
	ld a, [wJumptableIndex]
	ld l, a
	ld a, [wcf64]
	ld h, a
	push hl
	; reset value at [wc618] (not preserved)
	ld hl, wc618
	ld a, $0
	ld [hli], a
	; preserve de
	push de
	; [wJumptableIndex] keeps track of which line we're on (0, 1, 2 or 3)
	; [wcf64] keeps track of how much room we have left in the current line
	xor a
	ld [wJumptableIndex], a
	ld a, EZCHAT_CHARS_PER_LINE
	ld [wcf64], a
	ld a, EZCHAT_WORD_COUNT
.loop
	push af
	; load the 2-byte word data pointed to by bc
	ld a, [bc]
	ld e, a
	inc bc
	ld a, [bc]
	ld d, a
	inc bc
	; if $0000, we're done
	or e
	jr z, .done
	
	cp $ff
	jr nz, .d_not_ff
	ld a, e
	cp $ff
	jr z, .done ; de == $ffff, done

.d_not_ff
	; preserving hl and bc, get the length of the word
	push hl
	push bc
	call CopyMobileEZChatToC608
	call GetLengthOfWordAtC608
	ld e, c
	pop bc
	pop hl
	; if the functions return 0, we're done
	ld a, e
	or a
	jr z, .done
.loop2
	; e contains the length of the word
	; add 1 for the space, unless we're at the start of the line
	ld a, [wcf64]
	cp EZCHAT_CHARS_PER_LINE
	jr z, .skip_inc
	inc e

.skip_inc
	; if the word fits, put it on the same line
	cp e
	jr nc, .same_line
	; otherwise, go to the next line
	ld a, [wJumptableIndex]
	inc a
	ld [wJumptableIndex], a
	; if we're on line 1, insert "<NEXT>"
	ld [hl], "<NEXT>"
	rra
	jr c, .got_line_terminator
	; otherwise, insert "<CONT>" in line 0 and 2
	ld [hl], "<CONT>"

.got_line_terminator
	inc hl
	; init the next line, holding on to the same word
	ld a, EZCHAT_CHARS_PER_LINE
	ld [wcf64], a
	dec e
	jr .loop2

.same_line
	; add the space, unless we're at the start of the line
	cp EZCHAT_CHARS_PER_LINE
	jr z, .skip_space
	ld [hl], " "
	inc hl

.skip_space
	; deduct the length of the word
	sub e
	ld [wcf64], a
	ld de, wEZChatWordBuffer
.place_string_loop
	; load the string from de to hl
	ld a, [de]
	cp "@"
	jr z, .done
	inc de
	ld [hli], a
	jr .place_string_loop

.done
	; next word?
	pop af
	dec a
	jr nz, .loop
	; we're finished, place "<DONE>"
	ld [hl], "<DONE>"
	; now, let's place the string from wc618 to bc
	pop bc
	ld hl, wc618
	call PlaceHLTextAtBC
	; restore the original values of [wJumptableIndex] and [wcf64]
	pop hl
	ld a, l
	ld [wJumptableIndex], a
	ld a, h
	ld [wcf64], a
	ret

GetLengthOfWordAtC608: ; Finds the length of the word being stored for EZChat?
	ld c, $0
	ld hl, wEZChatWordBuffer
.loop
	ld a, [hli]
	cp "@"
	ret z
	inc c
	jr .loop

CopyMobileEZChatToC608:
	ldh a, [rSVBK]
	push af
	ld a, $1
	ldh [rSVBK], a
	ld a, "@"
	ld hl, wEZChatWordBuffer
	ld bc, NAME_LENGTH + 1
	call ByteFill
	ld a, d
	and a
	jr z, .get_name
; load in name
	ld hl, MobileEZChatCategoryPointers
	dec d
	sla d
	ld c, d
	ld b, $0
	add hl, bc
; got category pointer
	ld a, [hli]
	ld c, a
	ld a, [hl]
	ld b, a
; bc -> hl
	push bc
	pop hl
	ld c, e
	ld b, $0
; got which word
; bc * (5 + 1 + 1 + 1) = bc * 8
;	sla c
;	rl b
;	sla c
;	rl b
;	sla c
;	rl b
;	add hl, bc
rept EZCHAT_WORD_LENGTH + 3 ; fuck it, do (bc * 11) this way
	add hl, bc
endr
; got word address
	ld bc, EZCHAT_WORD_LENGTH
.copy_string
	ld de, wEZChatWordBuffer
	call CopyBytes
	ld de, wEZChatWordBuffer
	pop af
	ldh [rSVBK], a
	ret

.get_name
	ld a, e
	ld [wNamedObjectIndex], a
	call GetPokemonName
	ld hl, wStringBuffer1
	ld a, 1
	ld [wEZChatPokemonNameRendered], a
	ld bc, NAME_LENGTH
	jr .copy_string

Function11c1ab:
	ldh a, [hInMenu]
	push af
	ld a, $1
	ldh [hInMenu], a
	call Function11c1b9
	pop af
	ldh [hInMenu], a
	ret

Function11c1b9:
	call .InitKanaMode
	ldh a, [rSVBK]
	push af
	ld a, $5
	ldh [rSVBK], a
	call EZChat_MasterLoop
	pop af
	ldh [rSVBK], a
	ret

.InitKanaMode: ; Possibly opens the appropriate sorted list of words when sorting by letter?
	xor a
	ld [wJumptableIndex], a
	ld [wcf64], a
	ld [wcf65], a
	ld [wcf66], a
	ld [wEZChatBlinkingMask], a
	ld [wEZChatSelection], a
	ld [wEZChatCategorySelection], a
	ld [wEZChatSortedSelection], a
	ld [wEZChatPokemonNameRendered], a
	ld [wcd35], a
	ld [wEZChatCategoryMode], a
	ld a, $ff
	ld [wEZChatSpritesMask], a
	ld a, [wMenuCursorY]
	dec a
	call Function11c254
	call ClearBGPalettes
	call ClearSprites
	call ClearScreen
	call Function11d323
	call SetPalettes
	call DisableLCD
	ld hl, SelectStartGFX ; GFX_11d67e
	ld de, vTiles2
	ld bc, $60
	call CopyBytes
	ld hl, EZChatSlowpokeLZ ; LZ_11d6de
	ld de, vTiles0
	call Decompress
	call EnableLCD
	farcall ReloadMapPart
	farcall ClearSpriteAnims
	farcall LoadPokemonData
	farcall Pokedex_ABCMode
	ldh a, [rSVBK]
	push af
	ld a, $5
	ldh [rSVBK], a
	ld hl, wc6d0
	ld de, wLYOverrides
	ld bc, $100
	call CopyBytes
	pop af
	ldh [rSVBK], a
	call EZChat_GetCategoryWordsByKana
	call EZChat_GetSeenPokemonByKana
	ret

Function11c254:
	push af
	ld a, BANK(sEZChatIntroductionMessage)
	call OpenSRAM
	ld hl, sEZChatIntroductionMessage
	pop af
; a * 4 * 2
	sla a
	sla a
	sla a
	ld c, a
	ld b, 0
	add hl, bc
	ld de, wEZChatWords
	ld bc, EZCHAT_WORD_COUNT * 2
	call CopyBytes
	call CloseSRAM
	ret

EZChat_ClearBottom12Rows: ; Clears area below selected messages.
	ld a, "　"
	hlcoord 0, 6 ; Start of the area to clear
	ld bc, (SCREEN_HEIGHT - 6) * SCREEN_WIDTH
	call ByteFill
	ret

EZChat_MasterLoop:
.loop
	call JoyTextDelay
	ldh a, [hJoyPressed]
	ldh [hJoypadPressed], a
	ld a, [wJumptableIndex]
	bit 7, a
	jr nz, .exit
	call .DoJumptableFunction
	farcall PlaySpriteAnimations
	farcall ReloadMapPart
	jr .loop

.exit
	farcall ClearSpriteAnims
	call ClearSprites
	ret

.DoJumptableFunction:
	jumptable .Jumptable, wJumptableIndex

.Jumptable: ; and jumptable constants
	const_def

	const EZCHAT_SPAWN_OBJECTS
	dw .SpawnObjects ; 00

	const EZCHAT_INIT_RAM
	dw .InitRAM ; 01

	const EZCHAT_02
	dw Function11c35f ; 02

	const EZCHAT_03
	dw Function11c373 ; 03

	const EZCHAT_DRAW_CHAT_WORDS
	dw EZChatDraw_ChatWords ; 04

	const EZCHAT_MENU_CHAT_WORDS
	dw EZChatMenu_ChatWords ; 05

	const EZCHAT_DRAW_CATEGORY_MENU
	dw EZChatDraw_CategoryMenu ; 06

	const EZCHAT_MENU_CATEGORY_MENU
	dw EZChatMenu_CategoryMenu ; 07

	const EZCHAT_DRAW_WORD_SUBMENU
	dw EZChatDraw_WordSubmenu ; 08

	const EZCHAT_MENU_WORD_SUBMENU
	dw EZChatMenu_WordSubmenu ; 09

	const EZCHAT_DRAW_ERASE_SUBMENU
	dw EZChatDraw_EraseSubmenu ; 0a

	const EZCHAT_MENU_ERASE_SUBMENU
	dw EZChatMenu_EraseSubmenu ; 0b

	const EZCHAT_DRAW_EXIT_SUBMENU
	dw EZChatDraw_ExitSubmenu ; 0c

	const EZCHAT_MENU_EXIT_SUBMENU
	dw EZChatMenu_ExitSubmenu ; 0d

	const EZCHAT_DRAW_MESSAGE_TYPE_MENU
	dw EZChatDraw_MessageTypeMenu ; 0e

	const EZCHAT_MENU_MESSAGE_TYPE_MENU
	dw EZChatMenu_MessageTypeMenu ; 0f

	const EZCHAT_10
	dw Function11cbf5 ; 10 (Something related to sound)

	const EZCHAT_MENU_WARN_EMPTY_MESSAGE
	dw EZChatMenu_WarnEmptyMessage ; 11 (Something related to SortBy menus)

	const EZCHAT_12
	dw Function11cd04 ; 12 (Something related to input)

	const EZCHAT_DRAW_SORT_BY_MENU
	dw EZChatDraw_SortByMenu ; 13

	const EZCHAT_MENU_SORT_BY_MENU
	dw EZChatMenu_SortByMenu ; 14

	const EZCHAT_DRAW_SORT_BY_CHARACTER
	dw EZChatDraw_SortByCharacter ; 15

	const EZCHAT_MENU_SORT_BY_CHARACTER
	dw EZChatMenu_SortByCharacter ; 16

.SpawnObjects:
	depixel 3, 1, 2, 5
	ld a, SPRITE_ANIM_INDEX_EZCHAT_CURSOR
	call InitSpriteAnimStruct
	depixel 8, 1, 2, 5

	ld a, SPRITE_ANIM_INDEX_EZCHAT_CURSOR
	call InitSpriteAnimStruct
	ld hl, SPRITEANIMSTRUCT_VAR1
	add hl, bc
	ld a, $1 ; Message Menu Index (?)
	ld [hl], a

	depixel 9, 2, 2, 0
	ld a, SPRITE_ANIM_INDEX_EZCHAT_CURSOR
	call InitSpriteAnimStruct
	ld hl, SPRITEANIMSTRUCT_VAR1
	add hl, bc
	ld a, $3 ; Word Menu Index (?)
	ld [hl], a

	depixel 10, 16
	ld a, SPRITE_ANIM_INDEX_EZCHAT_CURSOR
	call InitSpriteAnimStruct
	ld hl, SPRITEANIMSTRUCT_VAR1
	add hl, bc
	ld a, $4
	ld [hl], a

	depixel 10, 4
	ld a, SPRITE_ANIM_INDEX_EZCHAT_CURSOR
	call InitSpriteAnimStruct
	ld hl, SPRITEANIMSTRUCT_VAR1
	add hl, bc
	ld a, $5 ; Sort By Menu Index (?)
	ld [hl], a

	depixel 10, 2
	ld a, SPRITE_ANIM_INDEX_EZCHAT_CURSOR
	call InitSpriteAnimStruct
	ld hl, SPRITEANIMSTRUCT_VAR1
	add hl, bc
	ld a, $2 ; Sort By Letter Menu Index (?)
	ld [hl], a

	ld hl, wEZChatBlinkingMask
	set 1, [hl]
	set 2, [hl]
	jp EZChat_IncreaseJumptable

.InitRAM:
	ld a, $9
	ld [wcd2d], a
	ld a, $2
	ld [wcd2e], a
	ld [wcd2f], a
	ld [wcd30], a
	ld de, wcd2d
	call EZChat_Textbox
	jp EZChat_IncreaseJumptable

Function11c35f:
	ld hl, wcd2f
	inc [hl]
	inc [hl]
	dec hl
	dec hl
	dec [hl]
	push af
	ld de, wcd2d
	call EZChat_Textbox
	pop af
	ret nz
	jp EZChat_IncreaseJumptable

Function11c373:
	ld hl, wcd30
	inc [hl]
	inc [hl]
	dec hl
	dec hl
	dec [hl]
	push af
	ld de, wcd2d
	call EZChat_Textbox
	pop af
	ret nz
	call EZChat_VerifyWordPlacement
	call EZChatMenu_MessageSetup
	jp EZChat_IncreaseJumptable

EZChatMenu_RerenderMessage:
; nugget of a solution
	ld de, EZChatBKG_ChatWords
	call EZChat_Textbox
	call EZChat_ClearAllWords
	jr EZChatMenu_MessageSetup

EZChatMenu_GetRealChosenWordSize:
	push hl
	push de
	ld hl, wEZChatWords
	sla a
	ld d, 0
	ld e, a
	add hl, de
	ld a, [hli]
	ld e, a
	ld d, [hl]
	jr EZChatMenu_DirectGetRealChosenWordSize.after_initial_setup

EZChatMenu_DirectGetRealChosenWordSize:
	push hl
	push de
.after_initial_setup
	push bc
	ld a, e
	or d
	jr z, .emptystring
	ld a, e
	and d
	cp $ff
	jr z, .emptystring
	call EZChat_LoadOneWord
	ld a, 0
	jr c, .done
	call GetLengthOfWordAtC608
	ld a, c
.done
	pop bc
	pop de
	pop hl
	ret

.emptystring
	xor a
	jr .done

EZChatMenu_GetChosenWordSize:
	push af
	call EZChatMenu_GetRealChosenWordSize
	pop hl
	and a
	ret nz
	ld a, h
	and 1
	ld a, h
	jr z, .after_decrement
	dec a
	dec a
.after_decrement
	inc a
	call EZChatMenu_GetRealChosenWordSize
	sub (EZCHAT_CHARS_PER_LINE - EZCHAT_BLANK_SIZE)
	ld h, a
	ld a, EZCHAT_BLANK_SIZE
	ret c
	sub h
	dec a
	ret

EZChatMenu_MessageLocationSetup:
	push de
	push bc
	ld bc, wMobileBoxSpritePositionDataTotal
	ld a, [bc]
	cp EZCHAT_WORDS_PER_ROW
	decoord 0, 2
	ld a, EZCHAT_CUSTOM_BOX_START_Y
	jr c, .after_initial_setup
	decoord 0, 4
	add $0F
.after_initial_setup
	ld d, a
	ld a, l
	sub e
	sla a
	sla a
	sla a
	add EZCHAT_CUSTOM_BOX_START_X
	ld e, a
	ld a, [bc]
	inc a
	ld [bc], a
	dec a
	inc bc
	push hl
	sla a
	ld h, 0
	ld l, a
	add hl, bc
	ld [hl], e
	inc hl
	ld [hl], d
	pop hl
	pop bc
	pop de
	ret

EZChatMenu_MessageSetup:
	ld a, EZCHAT_MAIN_RESET
	ld [wMobileBoxSpriteLoadedIndex], a
	xor a
	ld [wMobileBoxSpritePositionDataTotal], a
	hlcoord 1, 2
	ld bc, wEZChatWords
	call .after_initial_setup
	ld a, EZCHAT_WORDS_PER_ROW
	hlcoord 1, 4

.after_initial_setup
	push af
	inc a
	call EZChatMenu_GetRealChosenWordSize
	push af
	push hl
	call .print_word_of_line
	pop hl
	pop de
	pop af
	call EZChatMenu_GetRealChosenWordSize
	sub EZCHAT_CHARS_PER_LINE - ((EZCHAT_CHARS_PER_LINE - 1) / 2)
	ld e, EZCHAT_CHARS_PER_LINE - ((EZCHAT_CHARS_PER_LINE - 1) / 2) + 1
	jr nc, .after_size_calcs
	dec e
	ld a, d
	cp ((EZCHAT_CHARS_PER_LINE - 1) / 2) + 1
	jr c, .after_size_set
	sub ((EZCHAT_CHARS_PER_LINE - 1) / 2)
	ld d, a
	ld a, e
	sub d
	jr .after_size_increase
.after_size_calcs
	add e
.after_size_increase
	ld e, a
.after_size_set
	ld d, 0
	add hl, de

.print_word_of_line
	ld d, a
	ld a, [bc]
	inc bc
	push bc
	ld e, a
	ld a, [bc]
	ld b, d
	ld d, a
	or e
	jr z, .emptystring
	ld a, e
	and d
	cp $ff
	jr z, .emptystring
	call EZChatMenu_MessageLocationSetup
	call EZChat_RenderOneWord
	jr .asm_11c3b5
.emptystring
	ld de, EZChatString_EmptyWord
	ld a, b
	sub EZCHAT_CHARS_PER_LINE - EZCHAT_BLANK_SIZE
	jr c, .after_shrink
	add e
	ld e, a
	adc d
	sub e
	ld d, a
.after_shrink
	call EZChatMenu_MessageLocationSetup
	call PlaceString
.asm_11c3b5
	pop bc
	inc bc
	ret

EZChatString_EmptyWord: ; EZChat Unassigned Words
	db "-----@"

; ezchat main options
	const_def
	const EZCHAT_MAIN_WORD1
	const EZCHAT_MAIN_WORD2
	const EZCHAT_MAIN_WORD3
	const EZCHAT_MAIN_WORD4
	;const EZCHAT_MAIN_WORD5
	;const EZCHAT_MAIN_WORD6

	const EZCHAT_MAIN_RESET
	const EZCHAT_MAIN_QUIT
	const EZCHAT_MAIN_OK

EZChatDraw_ChatWords: ; Switches between menus?, not sure which.
	call EZChat_ClearBottom12Rows
	ld de, EZChatBKG_ChatExplanation
	call EZChat_Textbox2
	hlcoord 1, 7 ; Location of EZChatString_ChatExplanation
	ld de, EZChatString_ChatExplanation
	call PlaceString
	hlcoord 1, 16 ; Location of EZChatString_ChatExplanationBottom
	ld de, EZChatString_ChatExplanationBottom
	call PlaceString
	call EZChatDrawBKG_ChatWords
	ld hl, wEZChatSpritesMask
	res 0, [hl]
	call EZChat_IncreaseJumptable

EZChatMenu_ChatWords: ; EZChat Word Menu

; ----- (00) ----- (01) ----- (02)
; ----- (03) ----- (04) ----- (05)
; RESET (06)  QUIT (07)   OK  (08)

; to

; -------- (00) -------- (01)
; -------- (02) -------- (03)
; RESET (04)  QUIT (05)   OK  (06)

	ld hl, wEZChatSelection
	ld de, hJoypadPressed
	ld a, [de]
	and START
	jr nz, .select_ok
	ld a, [de]
	and B_BUTTON
	jr nz, .click_sound_and_quit
	ld a, [de]
	and A_BUTTON
	jr nz, .select_option
	ld de, hJoyLast
	ld a, [de]
	and D_UP
	jp nz, .up
	ld a, [de]
	and D_DOWN
	jp nz, .down
	ld a, [de]
	and D_LEFT
	jp nz, .left
	ld a, [de]
	and D_RIGHT
	jp nz, .right
; manage blinkies
	ld hl, wEZChatBlinkingMask
	set 0, [hl]
	ret

.click_sound_and_quit
	call PlayClickSFX
.to_quit_prompt
	ld hl, wEZChatSpritesMask
	set 0, [hl]
	ld a, EZCHAT_DRAW_EXIT_SUBMENU
	jr .move_jumptable_index

.select_ok
	ld a, EZCHAT_MAIN_OK
	ld [wEZChatSelection], a
	ret

.select_option
	ld a, [wEZChatSelection]
	cp EZCHAT_MAIN_RESET
	jr c, .to_word_select
	sub EZCHAT_MAIN_RESET
	jr z, .to_reset_prompt
	dec a
	jr z, .to_quit_prompt
; ok prompt
	ld hl, wEZChatWords
	ld c, EZCHAT_WORD_COUNT * 2
	xor a
.go_through_all_words
	or [hl]
	inc hl
	dec c
	jr nz, .go_through_all_words
	and a
	jr z, .if_all_empty

; filled out
	ld de, EZChatBKG_ChatWords
	call EZChat_Textbox
	decoord 1, 2
	ld bc, wEZChatWords
	call EZChat_RenderWords
	ld hl, wEZChatSpritesMask
	set 0, [hl]
	ld a, EZCHAT_DRAW_MESSAGE_TYPE_MENU
	jr .move_jumptable_index

.if_all_empty
	ld hl, wEZChatSpritesMask
	set 0, [hl]
	ld a, EZCHAT_MENU_WARN_EMPTY_MESSAGE
	jr .move_jumptable_index

.to_reset_prompt
	ld hl, wEZChatSpritesMask
	set 0, [hl]
	ld a, EZCHAT_DRAW_ERASE_SUBMENU
	jr .move_jumptable_index

.to_word_select
	call EZChat_MoveToCategoryOrSortMenu
.move_jumptable_index
	ld [wJumptableIndex], a
	call PlayClickSFX
	ret

.up
	ld a, [hl]
	cp EZCHAT_MAIN_WORD3
	ret c
	sub 2
	cp EZCHAT_MAIN_WORD4
	jr nz, .keep_checking_up
	dec a
.keep_checking_up
	cp EZCHAT_MAIN_RESET
	jr nz, .finish_dpad
	dec a
.finish_dpad
	ld [hl], a
	ret

.down
	ld a, [hl]
	cp 4
	ret nc
	add 2
	ld [hl], a
	ret

.left
	ld a, [hl]
	and a
	ret z
	cp 2
	ret z
	cp EZCHAT_MAIN_RESET
	ret z
	dec a
	ld [hl], a
	ret

.right
	ld a, [hl]
; rightmost side of everything
	cp 1
	ret z
	cp 3
	ret z
	cp EZCHAT_MAIN_OK
	ret z
	inc a
	ld [hl], a
	ret

EZChat_CheckCategorySelectionConsistency:
	ld a, [wEZChatCategoryMode]
	bit 7, a
	ret z
	set 0, a
	ld [wEZChatCategoryMode], a
	ret

EZChat_MoveToCategoryOrSortMenu:
	call EZChat_CheckCategorySelectionConsistency
	ld hl, wEZChatBlinkingMask
	res 0, [hl]
	ld a, [wEZChatCategoryMode]
	bit 0, a
	jr nz, .to_sort_menu
	xor a
	ld [wEZChatCategorySelection], a
	ld a, EZCHAT_DRAW_CATEGORY_MENU ; from where this is called, it sets jumptable stuff
	ret

.to_sort_menu
	xor a
	ld [wEZChatSortedSelection], a
	ld a, EZCHAT_DRAW_SORT_BY_CHARACTER
	ret

EZChatDrawBKG_ChatWords:
	ld a, $1
	hlcoord 0, 6, wAttrmap 	; Draws the pink background for 'Combine words'
	ld bc, $a0 				; Area to fill
	call ByteFill
	ld a, $7
	hlcoord 0, 14, wAttrmap ; Clears white area at bottom of menu
	ld bc, $28 				; Area to clear
	call ByteFill
	farcall ReloadMapPart
	ret

EZChatString_ChatExplanation: ; Explanation string
	db   "Combine cuatro pa-";"６つのことば¯くみあわせます"
	next "labras o frases.";"かえたいところ¯えらぶと　でてくる"
	next "Comience eligiendo";"ことばのグループから　いれかえたい"
	next "una casilla.";"たんご¯えらんでください"
	db   "@"

EZChatString_ChatExplanationBottom: ; Explanation commands string
	db "BORRA　SALIR　　OK@";"ぜんぶけす　やめる　　　けってい@"

; ezchat categories defines
def EZCHAT_CATEGORIES_ROWS EQU 5
def EZCHAT_CATEGORIES_COLUMNS EQU 2
def EZCHAT_DISPLAYED_CATEGORIES EQU (EZCHAT_CATEGORIES_ROWS * EZCHAT_CATEGORIES_COLUMNS)
def EZCHAT_NUM_CATEGORIES EQU 15
def EZCHAT_NUM_EXTRA_ROWS EQU ((EZCHAT_NUM_CATEGORIES + 1 - EZCHAT_DISPLAYED_CATEGORIES) / 2)
def EZCHAT_EMPTY_VALUE EQU ((EZCHAT_NUM_EXTRA_ROWS << 5) | (EZCHAT_DISPLAYED_CATEGORIES - 1))

	const_def EZCHAT_DISPLAYED_CATEGORIES
	const EZCHAT_CATEGORY_CANC
	const EZCHAT_CATEGORY_MODE
	const EZCHAT_CATEGORY_OK

EZChatDraw_CategoryMenu: ; Open category menu
; might need no change here
	call DelayFrame
	call EZChat_ClearBottom12Rows
	call EZChat_PlaceCategoryNames
	call EZChat_SortMenuBackground
	ld hl, wEZChatSpritesMask
	res 1, [hl]
	call EZChat_IncreaseJumptable

EZChatMenu_CategoryMenu: ; Category Menu Controls
	ld hl, wEZChatCategorySelection
	ld de, hJoypadPressed

	ld a, [de]
	and START
	jr nz, .start

	ld a, [de]
	and SELECT
	jr nz, .select

	ld a, [de]
	and B_BUTTON
	jr nz, .b

	ld a, [de]
	and A_BUTTON
	jr nz, .a

	ld de, hJoyLast

	ld a, [de]
	and D_UP
	jp nz, .up

	ld a, [de]
	and D_DOWN
	jp nz, .down

	ld a, [de]
	and D_LEFT
	jp nz, .left

	ld a, [de]
	and D_RIGHT
	jp nz, .right

; manage blinkies
	ld a, [hl]
	and $0f
	cp EZCHAT_CATEGORY_CANC
	ld hl, wEZChatBlinkingMask
	jr nc, .blink
; no blink
	res 1, [hl]
	ret
.blink
	set 1, [hl]
	ret

.a
	ld a, [wEZChatCategorySelection]
	and $0f
	cp EZCHAT_CATEGORY_CANC
	jr c, .got_category
	sub EZCHAT_CATEGORY_CANC
	jr z, .done
	dec a
	jr z, .mode
	jr .b

.start
	ld hl, wEZChatSpritesMask
	set 0, [hl]
	ld a, EZCHAT_MAIN_OK
	ld [wEZChatSelection], a

.b
	ld a, EZCHAT_DRAW_CHAT_WORDS
	jr .go_to_function

.select
	ld a, [wEZChatCategoryMode]
	xor (1 << 0) + (1 << 7)
	ld [wEZChatCategoryMode], a
	ld a, EZCHAT_DRAW_SORT_BY_CHARACTER
	jr .go_to_function

.mode
	ld a, EZCHAT_DRAW_SORT_BY_MENU
	jr .go_to_function

.got_category
	ld a, EZCHAT_DRAW_WORD_SUBMENU

.go_to_function
	ld hl, wEZChatSpritesMask
	set 1, [hl]
	ld [wJumptableIndex], a
	call PlayClickSFX
	ret

.done
	ld a, [wEZChatSelection]
	call EZChatDraw_EraseWordsLoop
	call EZChatMenu_RerenderMessage
	call PlayClickSFX
	ret

.up
	ld a, [hl]
	cp EZCHAT_CATEGORIES_COLUMNS
	ret c
	ld e, a
	and $f0
	ld d, a
	ld a, e
	and $0f
	cp EZCHAT_CATEGORIES_COLUMNS
	jr nc, .normal_up
	ld a, e
	sub EZCHAT_CATEGORIES_COLUMNS << 4
	ld [hl], a
	ld a, EZCHAT_DRAW_CATEGORY_MENU
	jr .go_to_function

.normal_up
	ld a, e
	and $0f
	cp EZCHAT_CATEGORY_MODE
	jr c, .continue_normal_up
	ld a, EZCHAT_CATEGORY_CANC
.continue_normal_up
	sub EZCHAT_CATEGORIES_COLUMNS
.up_end
	or d
	jr .finish_dpad

.down
	ld a, [hl]
	cp EZCHAT_EMPTY_VALUE - EZCHAT_CATEGORIES_COLUMNS
	jr nz, .continue_down
	dec a
.continue_down
	ld e, a
	and $f0
	ld d, a
	ld a, e
	and $0f
	cp EZCHAT_CATEGORY_CANC
	ret nc
	cp EZCHAT_DISPLAYED_CATEGORIES - EZCHAT_CATEGORIES_COLUMNS
	jr c, .normal_down
	ld a, d
	cp EZCHAT_NUM_EXTRA_ROWS << 5
	jr nz, .print_down
	ld a, EZCHAT_CATEGORY_CANC
	jr .down_end
.print_down
	ld a, e
	add EZCHAT_CATEGORIES_COLUMNS << 4
	cp EZCHAT_EMPTY_VALUE
	jr nz, .continue_print_down
	dec a
.continue_print_down
	ld [hl], a
	ld a, EZCHAT_DRAW_CATEGORY_MENU
	jr .go_to_function

.normal_down
	add EZCHAT_CATEGORIES_COLUMNS
.down_end
	or d
	jr .finish_dpad

.left
	ld a, [hl]
	and $0f
	cp EZCHAT_CATEGORY_OK
	jr z, .left_okay
	bit 0, a
	ret z
.left_okay
	ld a, [hl]
	dec a
	jr .finish_dpad

.right
	ld a, [hl]
	cp EZCHAT_EMPTY_VALUE - 1
	ret z
	and $0f
	cp EZCHAT_CATEGORY_MODE
	jr z, .right_okay
	bit 0, a
	ret nz
	cp EZCHAT_CATEGORY_OK
	ret z
.right_okay
	ld a, [hl]
	inc a

.finish_dpad
	ld [hl], a
	ret

EZChat_FindNextCategoryName:
	; The category names are padded with "@".
	; To find the next category, the system must
	; find the first character at de that is not "@".
.find_end_loop
	ld a, [de]
	inc de
	cp "@"
	jr nz, .find_end_loop
.find_next_loop
	ld a, [de]
	inc de
	cp "@"
	jr z, .find_next_loop
	dec de
	ret

EZChat_GetSelectedCategory:
	push de
	ld e, a
	and $0f
	ld d, a
	ld a, e
	swap a
	and $0f
	add d
	pop de
	ret

EZChat_PlaceCategoryNames:
	ld de, MobileEZChatCategoryNames
	ld a, [wEZChatCategorySelection]
	swap a
	and $0f
	jr z, .setup_start
.start_loop
	push af
	call EZChat_FindNextCategoryName
	pop af
	dec a
	jr nz, .start_loop
.setup_start
	hlcoord  1,  7
	ld a, 10 / 2 ; Number of EZ Chat categories displayed
.loop
	push af
	call PlaceString
	call EZChat_FindNextCategoryName
	ld bc, 10
	add hl, bc
	call PlaceString
	call EZChat_FindNextCategoryName
	ld bc, 30
	add hl, bc
	pop af
	dec a
	jr nz, .loop
	ld de, EZChatString_Stop_Mode_Cancel
	call PlaceString
	ret

EZChat_SortMenuBackground:
	ld a, $2
	hlcoord 0, 6, wAttrmap
	ld bc, $c8
	call ByteFill
	farcall ReloadMapPart
	ret

EZChatString_Stop_Mode_Cancel:
	db "BORRA　MODO　　SALIR@";"けす　　　　モード　　　やめる@"

EZChatDraw_WordSubmenu: ; Opens/Draws Word Submenu
	call EZChat_ClearBottom12Rows
	call EZChat_DetermineWordCounts
	ld de, EZChatBKG_WordSubmenu
	call EZChat_Textbox2
	call EZChat_WhiteOutLowerMenu
	call EZChat_RenderWordChoices
	call EZChatMenu_WordSubmenuBottom
	ld hl, wEZChatSpritesMask
	res 3, [hl]
	xor a
	ld hl, wEZChatScrollBufferIndex
	ld [hli], a
	ld [hli], a
	ld [hl], a
	call EZChat_IncreaseJumptable

EZChatMenu_WordSubmenu: ; Word Submenu Controls
	ld hl, wEZChatWordSelection
	ld de, hJoypadPressed
	ld a, [de]
	and A_BUTTON
	jp nz, .a
	ld a, [de]
	and B_BUTTON
	jp nz, .b
	ld a, [de]
	and START
	jr nz, .next_page
	ld a, [de]
	and SELECT
	jr z, .check_joypad

; select
	ld a, [wEZChatPageOffset]
	and a
	ret z
	ld e, EZCHAT_WORDS_PER_COL
.select_loop
	call .move_menu_up_by_one
	dec e
	jr nz, .select_loop
	jr .navigate_to_page

.next_page
	ld a, EZCHAT_WORDS_PER_COL
	call EZChatGetValidWordsLine
	ret nc
	ld a, d
	ld hl, wEZChatLoadedItems
	cp [hl]
	ret nc
	ld e, EZCHAT_WORDS_PER_COL
.start_loop
	push de
	call .force_menu_down_by_one
	pop de
	dec e
	jr nz, .start_loop
.navigate_to_page
	call DelayFrame
	call Function11c992
	call EZChat_RenderWordChoices
	call EZChatMenu_WordSubmenuBottom
	ld hl, wEZChatWordSelection
	ld a, [hl]
	jp .finish_dpad

.check_joypad
	ld de, hJoyLast
	ld a, [de]
	and D_UP
	jr nz, .up
	ld a, [de]
	and D_DOWN
	jr nz, .down
	ld a, [de]
	and D_LEFT
	jr nz, .left
	ld a, [de]
	and D_RIGHT
	jr nz, .right
	ret

.failure_to_set
	ld de, SFX_WRONG
	call PlaySFX
	jp WaitSFX

.a
	call EZChat_SetOneWord
	jr nc, .failure_to_set
	call EZChat_VerifyWordPlacement
	call EZChatMenu_RerenderMessage
	ld a, EZCHAT_DRAW_CHAT_WORDS
	ld [wcd35], a

; autoselect "OK" if all words filled
; not when only word #4 is filled
	push af
	ld hl, wEZChatWords
	ld c, EZCHAT_WORD_COUNT
.check_word
	ld b, [hl]
	inc hl
	ld a, [hli]
	or b
	jr z, .check_done
	dec c
	jr nz, .check_word
	ld a, $6 ; OK
	ld [wEZChatSelection], a
.check_done
	pop af
	jr .jump_to_index

.b
	call EZChat_CheckCategorySelectionConsistency
	ld a, [wEZChatCategoryMode]
	bit 0, a
	jr nz, .to_sorted_menu
	ld a, EZCHAT_DRAW_CATEGORY_MENU
	jr .jump_to_index

.to_sorted_menu
	ld a, EZCHAT_DRAW_SORT_BY_CHARACTER
.jump_to_index
	ld [wJumptableIndex], a
	ld hl, wEZChatSpritesMask
	set 3, [hl]
	call PlayClickSFX
	ret

.up
	ld a, [hl]
	sub EZCHAT_WORDS_PER_ROW
	jr nc, .finish_dpad
	call .move_menu_up_by_one
	ret nc
	jp .navigate_to_page

.down
	ld a, [hl]
	add EZCHAT_WORDS_PER_ROW
	cp EZCHAT_WORDS_IN_MENU
	jr c, .finish_dpad
	call .move_menu_down_by_one
	ret nc
	jp .navigate_to_page

.left
	ld a, [hl]
	and a ; cp a, 0
	ret z
	and 1
	ret z
	ld a, [hl]
	dec a
	jr .finish_dpad

.right
	ld a, [hl]
	and 1
	ret nz
	ld a, [hl]
	inc a

.finish_dpad
	push af
	srl a
	inc a
	call EZChatGetValidWordsLine
	pop bc
	and a
	ld c, a
	ld a, b
	jr nz, .after_y_positioning
	sub EZCHAT_WORDS_PER_ROW
	jr nc, .finish_dpad
	xor a
	ld b, a
.after_y_positioning
	and 1
	jr z, .done
	dec c
	jr nz, .done
	dec b
.done
	ld a, b
	ld [wEZChatWordSelection], a
	ret

.move_menu_up_by_one
	ld a, [wEZChatPageOffset]
	and a
	ret z
	ld hl, wEZChatScrollBufferIndex
	ld a, [hl]
	and a
	ret z
	dec a
	ld [hli], a
	inc hl
	add l
	ld l, a
	adc h
	sub l
	ld h, a
	ld a, [hl]
	ld [wEZChatPageOffset], a
	scf
	ret

.move_menu_down_by_one
	ld a, EZCHAT_WORDS_PER_COL
	call EZChatGetValidWordsLine
	ret nc
	ld a, d
	ld hl, wEZChatLoadedItems
	cp [hl]
	ret nc
.force_menu_down_by_one
	ld hl, wEZChatScrollBufferIndex
	ld a, [hli]
	cp [hl]
	jr nc, .not_found_previous_value
	dec hl
	inc a
	ld [hli], a
	inc hl
	add l
	ld l, a
	adc h
	sub l
	ld h, a
	ld a, [hl]
	ld [wEZChatPageOffset], a
	jr .after_scroll_buffer_setup

.not_found_previous_value
	ld a, 1
	call EZChatGetValidWordsLine
	ld a, d
	ld [wEZChatPageOffset], a
	ld hl, wEZChatScrollBufferIndex
	ld a, [hl]
	inc a
	jr z, .after_scroll_buffer_setup
	ld [hli], a
	cp [hl]
	jr c, .after_scroll_max_increase
	ld [hl], a
.after_scroll_max_increase
	inc hl
	add l
	ld l, a
	adc h
	sub l
	ld h, a
	ld [hl], d
.after_scroll_buffer_setup
	scf
	ret

EZChat_DetermineWordCounts:
	xor a
	ld [wEZChatWordSelection], a
	ld [wEZChatPageOffset], a
	ld [wcd27], a
	ld [wcd29], a
	ld a, [wEZChatCategoryMode]
	bit 0, a
	jr nz, .is_sorted_mode
	ld a, [wEZChatCategorySelection]
	and a
	jr z, .is_pokemon_selection
	; load from data array
	call EZChat_GetSelectedCategory
	dec a
	sla a
	ld hl, MobileEZChatData_WordAndPageCounts
	ld c, a
	ld b, 0
.prepare_items_load
	add hl, bc
	ld a, [hl]
.set_loaded_items
	ld [wEZChatLoadedItems], a
	ret

.is_pokemon_selection
	; compute from [wc7d2]
	ld a, [wc7d2]
	jr .set_loaded_items

.is_sorted_mode
	; compute from [c6a8 + 2 * [cd22]]
	ld hl, wc6a8 ; $c68a + 30
	ld a, [wEZChatSortedSelection]
	ld c, a
	ld b, 0
	add hl, bc
	jr .prepare_items_load
	
EZChat_RenderWordChoices:
	ld bc, EZChatCoord_WordSubmenu
	ld a, [wEZChatCategoryMode]
	bit 0, a
	jr nz, .is_sorted
; grouped
	ld a, [wEZChatCategorySelection]
	call EZChat_GetSelectedCategory
	ld d, a
	and a
	ld a, [wEZChatPageOffset]
	ld e, a
	jr nz, .loop
	ld hl, wListPointer
	add hl, de
.loop
	call .printing_one_word
	cp -1
	ret z
	cp ((EZCHAT_CHARS_PER_LINE - 2) / 2) + 1
	jr nc, .skip_one
	push de
	inc e
	push hl
	call .get_next_word
	call EZChatMenu_DirectGetRealChosenWordSize
	pop hl
	pop de
	cp ((EZCHAT_CHARS_PER_LINE - 2) / 2) + 1
	jr nc, .skip_one
	inc e
	ld a, [wEZChatLoadedItems]
	cp e
	ret z
	call .printing_one_word
	jr .after_skip
.skip_one
	inc bc
	inc bc
.after_skip
	inc e
	ld a, [wEZChatLoadedItems]
	cp e
	jr nz, .loop
	ret

.is_sorted
	ld hl, wEZChatSortedWordPointers
	ld a, [wEZChatSortedSelection]
	ld e, a
	ld d, 0
	add hl, de
	add hl, de
; got word
	ld a, [hli]
	ld e, a
	ld a, [hl]
	ld d, a
; de -> hl
	push de
	pop hl
	ld a, [wEZChatPageOffset]
	ld e, a
	ld d, 0
	add hl, de
	add hl, de
	ld a, [wEZChatPageOffset]
	ld e, a
	ld d, $80
	jr .loop

.printing_one_word
	push de
	call .get_next_word
	push hl
	ld a, [bc]
	ld l, a
	inc bc
	ld a, [bc]
	ld h, a
	inc bc
	and l
	cp -1
	jr z, .printing_loop_exit
	push bc
	call EZChat_RenderOneWord
	ld a, c
	sub l
	pop bc
.printing_loop_exit
	pop hl
	pop de
	ret

.get_next_word
	ld a, d
	and $7F
	ret nz
	ld a, [hli]
	ld e, a
	ld a, d
	and a
	ret z
	ld a, [hli]
	ld d, a
	ret

EZChatCoord_WordSubmenu: ; Word coordinates (within category submenu)
	dwcoord  2,  8
	dwcoord  11,  8 ; 8, 8 MENU_WIDTH
	dwcoord  2, 10
	dwcoord  11, 10 ; 8, 10 MENU_WIDTH
	dwcoord  2, 12
	dwcoord  11, 12 ; 8, 12 MENU_WIDTH
	dwcoord  2, 14
	dwcoord  11, 14 ; 8, 14 MENU_WIDTH
	dw -1
	dw -1

EZChatMenu_WordSubmenuBottom: ; Seems to handle the bottom of the word menu.
	ld a, [wEZChatPageOffset]
	and a
	jr z, .asm_11c88a
	hlcoord 1, 17 	; Draw PREV string (2, 17)
	ld de, MobileString_Prev
	call PlaceString
	hlcoord 6, 17 	; Draw SELECT tiles
	ld c, $3 		; SELECT tile length
	xor a
.asm_11c883
	ld [hli], a
	inc a
	dec c
	jr nz, .asm_11c883
	jr .asm_11c895
.asm_11c88a
	hlcoord 1, 17 	; Clear PREV/SELECT (2, 17)
	ld c, $8 		; Clear PREV/SELECT length
	ld a, $7f
.asm_11c891
	ld [hli], a
	dec c
	jr nz, .asm_11c891
.asm_11c895
	ld a, EZCHAT_WORDS_PER_COL
	call EZChatGetValidWordsLine
	jr nc, .asm_11c8b7
	ld a, d
	ld hl, wEZChatLoadedItems
	cp [hl]
	jr nc, .asm_11c8b7
	hlcoord 15, 17 	; NEXT string (16, 17)
	ld de, MobileString_Next
	call PlaceString
	hlcoord 11, 17 	; START tiles
	ld a, $3 		; START tile length
	ld c, a
.asm_11c8b1
	ld [hli], a
	inc a
	dec c
	jr nz, .asm_11c8b1
	ret

.asm_11c8b7
	hlcoord 17, 16
	ld a, $7f
	ld [hl], a
	hlcoord 11, 17 	; Clear START/NEXT
	ld c, $9 		; Clear START/NEXT length
.asm_11c8c2
	ld [hli], a
	dec c
	jr nz, .asm_11c8c2
	ret

BCD2String: ; unreferenced
	inc a
	push af
	and $f
	ldh [hDividend], a
	pop af
	and $f0
	swap a
	ldh [hDividend + 1], a
	xor a
	ldh [hDividend + 2], a
	push hl
	farcall Function11a80c
	pop hl
	ld a, [wcd63]
	add "０"
	ld [hli], a
	ld a, [wcd62]
	add "０"
	ld [hli], a
	ret

MobileString_Page: ; unreferenced
	db "PÁG.@";"ぺージ@"

MobileString_Prev:
	db "ANT.@";"まえ@"

MobileString_Next:
	db "SIG.@";"つぎ@"

EZChat_VerifyWordPlacement:
	push hl
	push bc
	push de
	ld a, [wEZChatSelection]
	ld b, a
	srl a
	sla a
	ld c, a
	push bc

	ld d, 0
	ld e, EZCHAT_WORDS_PER_ROW
.loop_line
	push bc
	push de
	ld a, c
	call EZChatMenu_GetRealChosenWordSize
	pop de
	pop bc
	add d
	inc a
	ld d, a
	inc c
	dec e
	jr nz, .loop_line
	ld a, d
	dec a

	pop bc
	cp EZCHAT_CHARS_PER_LINE + 1
	jr c, .after_sanitization
	ld a, b
	and 1
	ld hl, wEZChatWords
	jr nz, .chosen_base
	inc hl
	inc hl
.chosen_base
	ld a, c
	sla a
	ld d, 0
	ld e, a
	add hl, de
	xor a
	ld [hli], a
	ld [hl], a

.after_sanitization
	pop de
	pop bc
	pop hl
	ret

EZChat_SetOneWord:
; get which category mode
	ld a, [wEZChatWordSelection]
	srl a
	call EZChatGetValidWordsLine
	ld a, [wEZChatWordSelection]
	and 1
	add d
	ld b, 0
	ld c, a
	ld a, [wEZChatCategoryMode]
	bit 0, a
	jr nz, .alphabetical
; categorical
	ld a, [wEZChatCategorySelection]
	call EZChat_GetSelectedCategory
	ld d, a
	and a
	jr z, .pokemon
	ld e, c
.put_word
	call EZChatMenu_DirectGetRealChosenWordSize
	ld b, a
	ld a, [wEZChatSelection]
	ld c, a
	and 1
	ld a, c
	jr z, .after_dec
	dec a
	dec a
.after_dec
	inc a
	call EZChatMenu_GetRealChosenWordSize
	add b
	inc a
	cp EZCHAT_CHARS_PER_LINE + 1
	ret nc
	ld b, 0
	ld hl, wEZChatWords
	add hl, bc
	add hl, bc
	ld [hl], e
	inc hl
	ld [hl], d
; finished
	scf
	ret

.pokemon
	ld hl, wListPointer
	add hl, bc
	ld a, [hl]
	ld e, a
	jr .put_word

.alphabetical
	ld hl, wEZChatSortedWordPointers
	ld a, [wEZChatSortedSelection]
	ld e, a
	ld d, 0
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	add hl, bc
	add hl, bc
	ld a, [hli]
	ld e, a
	ld a, [hl]
	ld d, a
	jr .put_word

EZChat_GetWordSize:
; get which category mode
	push hl
	push de
	push bc
	push af
	ld a, [wEZChatCategoryMode]
	bit 0, a
	jr nz, .alphabetical
; categorical
	ld a, [wEZChatCategorySelection]
	call EZChat_GetSelectedCategory
	ld d, a
	and a
	jr z, .pokemon
	pop af
.got_word_entry
	ld e, a
.get_word_size
	call EZChatMenu_DirectGetRealChosenWordSize
	pop bc
	pop de
	pop hl
	ret

.pokemon
	pop af
	ld c, a
	ld b, 0
	ld hl, wListPointer
	add hl, bc
	ld a, [hl]
	jr .got_word_entry

.alphabetical
	ld hl, wEZChatSortedWordPointers
	ld a, [wEZChatSortedSelection]
	ld e, a
	ld d, 0
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop af
	ld e, a
	ld d, 0
	add hl, de
	add hl, de
	ld a, [hli]
	ld e, a
	ld a, [hl]
	ld d, a
	jr .get_word_size

EZChatGetValidWordsLine:
	push af
	ld a, [wEZChatPageOffset]
	ld d, a
	pop af
	and a
	ret z
	push bc
	ld hl, wEZChatLoadedItems
	ld e, a
.loop
	ld c, 0
	ld a, d
	cp [hl]
	jr nc, .early_end
	inc c
	call EZChat_GetWordSize
	inc d
	cp ((EZCHAT_CHARS_PER_LINE - 2) / 2) + 1
	jr nc, .decrease_e
	ld a, d
	cp [hl]
	jr nc, .early_end
	call EZChat_GetWordSize
	cp ((EZCHAT_CHARS_PER_LINE - 2) / 2) + 1
	jr nc, .decrease_e
	inc c
	inc d

.decrease_e
	dec e
	jr nz, .loop
	scf
.end
	ld a, c
	pop bc
	ret

.early_end
	dec e
	jr z, .after_end_sanitization
	ld c, 0
.after_end_sanitization
	and a
	jr .end

EZChat_ClearAllWords:
	hlcoord 1, 1
	call .after_initial_position
	hlcoord 1, 3
.after_initial_position
	push hl
	call .clear_line
	pop hl
	ld de, SCREEN_WIDTH
	add hl, de
.clear_line
	ld c, EZCHAT_CHARS_PER_LINE
	ld a, " "
.clear_word
	ld [hli], a
	dec c
	jr nz, .clear_word
	ret

Function11c992: ; Likely related to the word submenu, references the first word position
	ld a, $8
	hlcoord 2, 7
.asm_11c997
	push af
	ld a, $7f
	push hl
	ld bc, $11
	call ByteFill
	pop hl
	ld bc, $14
	add hl, bc
	pop af
	dec a
	jr nz, .asm_11c997
	ret

EZChat_WhiteOutLowerMenu:
	ld a, $7
	hlcoord 0, 6, wAttrmap
	ld bc, $c8
	call ByteFill
	farcall ReloadMapPart
	ret

EZChatDraw_EraseSubmenu:
	ld de, EZChatString_EraseMenu
	call EZChatDraw_ConfirmationSubmenu

EZChatMenu_EraseSubmenu: ; Erase submenu controls
	ld hl, wcd2a
	ld de, hJoypadPressed
	ld a, [de]
	and $1 ; A
	jr nz, .a
	ld a, [de]
	and $2 ; B
	jr nz, .b
	ld a, [de]
	and $40 ; UP
	jr nz, .up
	ld a, [de]
	and $80 ; DOWN
	jr nz, .down
	ret

.a
	ld a, [hl]
	and a
	jr nz, .b
	call EZChatMenu_EraseWordsAccept
	xor a
	ld [wEZChatSelection], a
.b
	ld hl, wEZChatSpritesMask
	set 4, [hl]
	ld a, EZCHAT_DRAW_CHAT_WORDS
	ld [wJumptableIndex], a
	call PlayClickSFX
	ret

.up
	ld a, [hl]
	and a
	ret z
	dec [hl]
	ret

.down
	ld a, [hl]
	and a
	ret nz
	inc [hl]
	ret

Function11ca01: ; Erase Yes/No Menu (?)
	hlcoord 15, 7, wAttrmap
	ld de, $14
	ld a, $5
	ld c, a
.asm_11ca0a
	push hl
	ld a, $5
	ld b, a
	ld a, $7
.asm_11ca10
	ld [hli], a
	dec b
	jr nz, .asm_11ca10
	pop hl
	add hl, de
	dec c
	jr nz, .asm_11ca0a

Function11ca19:
	hlcoord 0, 12, wAttrmap
	ld de, $14
	ld a, $6
	ld c, a
.asm_11ca22
	push hl
	ld a, $14
	ld b, a
	ld a, $7
.asm_11ca28
	ld [hli], a
	dec b
	jr nz, .asm_11ca28
	pop hl
	add hl, de
	dec c
	jr nz, .asm_11ca22
	farcall ReloadMapPart
	ret

EZChatString_EraseMenu: ; Erase words string, accessed from erase command on entry menu for EZ chat
	db   "Todo será borrado.";"とうろくちゅう<NO>あいさつ¯ぜんぶ"
	next "¿De acuerdo?@";"けしても　よろしいですか？@"

EZChatString_EraseConfirmation: ; Erase words confirmation string
	db   "SÍ";"はい"
	next "NO@";"いいえ@"

EZChatMenu_EraseWordsAccept:
	xor a
.loop
	call EZChatDraw_EraseWordsLoop
	inc a
	cp EZCHAT_WORD_COUNT
	jr nz, .loop
	call EZChatMenu_RerenderMessage
	ret

EZChatDraw_EraseWordsLoop:
	ld hl, wEZChatWords
	ld c, a
	ld b, 0
	add hl, bc
	add hl, bc
	ld [hl], b
	inc hl
	ld [hl], b
	ret

EZChatDraw_ConfirmationSubmenu:
	push de
	ld de, EZChatBKG_SortBy
	call EZChat_Textbox
	ld de, EZChatBKG_SortByConfirmation
	call EZChat_Textbox
	hlcoord 1, 14
	pop de
	call PlaceString
	hlcoord 17, 8
	ld de, EZChatString_EraseConfirmation
	call PlaceString
	call Function11ca01
	ld a, $1
	ld [wcd2a], a
	ld hl, wEZChatSpritesMask
	res 4, [hl]
	call EZChat_IncreaseJumptable
	ret

EZChatDraw_ExitSubmenu:
	ld de, EZChatString_ExitPrompt
	call EZChatDraw_ConfirmationSubmenu

EZChatMenu_ExitSubmenu: ; Exit Message menu
	ld hl, wcd2a
	ld de, hJoypadPressed
	ld a, [de]
	and $1 ; A
	jr nz, .a
	ld a, [de]
	and $2 ; B
	jr nz, .b
	ld a, [de]
	and $40 ; UP
	jr nz, .up
	ld a, [de]
	and $80 ; DOWN
	jr nz, .down
	ret

.a
	call PlayClickSFX
	ld a, [hl]
	and a
	jr nz, .asm_11cafc
	ld a, [wcd35]
	and a
	jr z, .asm_11caf3
	cp $ff
	jr z, .asm_11caf3
	ld a, $ff
	ld [wcd35], a
	hlcoord 1, 14
	ld de, EZChatString_ExitConfirmation
	call PlaceString
	ld a, $1
	ld [wcd2a], a
	ret

.asm_11caf3
	ld hl, wJumptableIndex
	set 7, [hl] ; exit
	ret

.b
	call PlayClickSFX
.asm_11cafc
	ld hl, wEZChatSpritesMask
	set 4, [hl]
	ld a, EZCHAT_DRAW_CHAT_WORDS
	ld [wJumptableIndex], a
	ld a, [wcd35]
	cp $ff
	ret nz
	ld a, $1
	ld [wcd35], a
	ret

.up
	ld a, [hl]
	and a
	ret z
	dec [hl]
	ret

.down
	ld a, [hl]
	and a
	ret nz
	inc [hl]
	ret

EZChatString_ExitPrompt: ; Exit menu string
	db   "¿Dejar de escribir";"あいさつ<NO>とうろく¯ちゅうし"
	next "un mensaje?@";"しますか？@"

EZChatString_ExitConfirmation: ; Exit menu confirmation string
	db   "¿Salir sin guardar";"とうろくちゅう<NO>あいさつ<WA>ほぞん"
	next "un mensaje?@";"されません<GA>よろしい　ですか？@"

EZChatDraw_MessageTypeMenu: ; Message Type Menu Drawing (Intro/Battle Start/Win/Lose menu)
	ld hl, EZChatString_MessageDescription
	ld a, [wMenuCursorY]
.asm_11cb58
	dec a
	jr z, .asm_11cb5f
	inc hl
	inc hl
	jr .asm_11cb58
.asm_11cb5f
	ld a, [hli]
	ld e, a
	ld a, [hl]
	ld d, a
	call EZChatDraw_ConfirmationSubmenu

EZChatMenu_MessageTypeMenu: ; Message Type Menu Controls (Intro/Battle Start/Win/Lose menu)
	ld hl, wcd2a
	ld de, hJoypadPressed
	ld a, [de]
	and $1 ; A
	jr nz, .a
	ld a, [de]
	and $2 ; B
	jr nz, .b
	ld a, [de]
	and $40 ; UP
	jr nz, .up
	ld a, [de]
	and $80 ; DOWN
	jr nz, .down
	ret

.a
	ld a, [hl]
	and a
	jr nz, .clicksound
	ld a, BANK(sEZChatIntroductionMessage)
	call OpenSRAM
	ld hl, sEZChatIntroductionMessage
	ld a, [wMenuCursorY]
	dec a
	sla a
	sla a
	sla a
	ld c, a
	ld b, 0
	add hl, bc
	ld de, wEZChatWords
	ld c, EZCHAT_WORD_COUNT * 2
.save_message
	ld a, [de]
	ld [hli], a
	inc de
	dec c
	jr nz, .save_message
	call CloseSRAM
	call PlayClickSFX
	ld de, EZChatBKG_SortBy
	call EZChat_Textbox
	ld hl, EZChatString_MessageSet
	ld a, [wMenuCursorY]
.asm_11cbba
	dec a
	jr z, .asm_11cbc1
	inc hl
	inc hl
	jr .asm_11cbba
.asm_11cbc1
	ld a, [hli]
	ld e, a
	ld a, [hl]
	ld d, a
	hlcoord 1, 14
	call PlaceString
	ld hl, wJumptableIndex
	inc [hl]
	inc hl
	ld a, $10
	ld [hl], a
	ret

.clicksound
	call PlayClickSFX
.b
	call EZChatMenu_RerenderMessage
	ld hl, wEZChatSpritesMask
	set 4, [hl]
	ld a, EZCHAT_DRAW_CHAT_WORDS
	ld [wJumptableIndex], a
	ret

.up
	ld a, [hl]
	and a
	ret z
	dec [hl]
	ret

.down
	ld a, [hl]
	and a
	ret nz
	inc [hl]
	ret

Function11cbf5:
	call WaitSFX
	ld hl, wcf64
	dec [hl]
	ret nz
	dec hl
	set 7, [hl]
	ret

EZChatString_MessageDescription: ; Message usage strings
	dw EZChatString_MessageIntroDescription
	dw EZChatString_MessageBattleStartDescription
	dw EZChatString_MessageBattleWinDescription
	dw EZChatString_MessageBattleLoseDescription

EZChatString_MessageIntroDescription:
	db   "Visto cuando te";"じこしょうかい　は"
	next "presentas. ¿OK?@";"この　あいさつで　いいですか？@"

EZChatString_MessageBattleStartDescription:
	db   "Visto cuando ini-";"たいせん　<GA>はじまるとき　は"
	next "cia combate. ¿OK?@";"この　あいさつで　いいですか？@"

EZChatString_MessageBattleWinDescription:
	db   "Visto cuando ganas";"たいせん　<NI>かったとき　は"
	next "combate. ¿OK?@";"この　あいさつで　いいですか？@"

EZChatString_MessageBattleLoseDescription:
	db   "Visto cuando pier-";"たいせん　<NI>まけたとき　は"
	next "des combate. ¿OK?@";"この　あいさつで　いいですか？@"

EZChatString_MessageSet: ; message accept strings, one for each type of message.
	dw EZChatString_MessageIntroSet
	dw EZChatString_MessageBattleStartSet
	dw EZChatString_MessageBattleWinSet
	dw EZChatString_MessageBattleLoseSet

EZChatString_MessageIntroSet:
	db   "¡Saludo de intro-"		;"じこしょうかい　の"
	next "ducción elegido!@"	;next "あいさつ¯とうろくした！@"

EZChatString_MessageBattleStartSet:
	db   "¡Saludo de com-"		;"たいせん　<GA>はじまるとき　の"
	next "bate elegido!@"	;next "あいさつ¯とうろくした！@"

EZChatString_MessageBattleWinSet:
	db   "¡Saludo de victo-"		;"たいせん　<NI>かったとき　の"
	next "RIA elegido!@"	;next "あいさつ¯とうろくした！@"

EZChatString_MessageBattleLoseSet:
	db   "¡Saludo de derro-"		;"たいせん　<NI>まけたとき　の"
	next "ta elegido!@"	;next "あいさつ¯とうろくした！@"

EZChatMenu_WarnEmptyMessage:
	ld de, EZChatBKG_SortBy
	call EZChat_Textbox
	hlcoord 1, 14
	ld de, EZChatString_EnterSomeWords
	call PlaceString
	call Function11ca19
	call EZChat_IncreaseJumptable

Function11cd04:
	ld de, hJoypadPressed
	ld a, [de]
	and a
	ret z
	ld a, EZCHAT_DRAW_CHAT_WORDS
	ld [wJumptableIndex], a
	ret

EZChatString_EnterSomeWords:
	db 	 "Favor ingresar una";"なにか　ことば¯いれてください@"
	next "frase o palabra.@"

EZChatDraw_SortByMenu: ; Draws/Opens Sort By Menu
	call EZChat_ClearBottom12Rows
	ld de, EZChatBKG_SortBy
	call EZChat_Textbox
	hlcoord 1, 14
	ld a, [wEZChatCategoryMode]
	ld [wcd2c], a
	bit 0, a
	jr nz, .asm_11cd3a
	ld de, EZChatString_SortByCategory
	jr .asm_11cd3d
.asm_11cd3a
	ld de, EZChatString_SortByAlphabetical
.asm_11cd3d
	call PlaceString
	hlcoord 3, 8
	ld de, EZChatString_SortByMenu
	call PlaceString
	call Function11cdaa
	ld hl, wEZChatSpritesMask
	res 5, [hl]
	call EZChat_IncreaseJumptable

EZChatMenu_SortByMenu: ; Sort Menu Controls
	ld hl, wcd2c
	res 7, [hl]
	ld de, hJoypadPressed
	ld a, [de]
	and A_BUTTON
	jr nz, .a
	ld a, [de]
	and B_BUTTON
	jr nz, .b
	ld a, [de]
	and D_UP
	jr nz, .up
	ld a, [de]
	and D_DOWN
	jr nz, .down
	ret

.a
	ld a, [hl]
	bit 0, a
	jr z, .a_skip_setting_7
	set 7, a
	jr .a_ok
.a_skip_setting_7
	res 7, a
.a_ok
	ld [wEZChatCategoryMode], a
.b
	ld a, [wEZChatCategoryMode]
	bit 0, a
	jr nz, .asm_11cd7d
	ld a, EZCHAT_DRAW_CATEGORY_MENU
	jr .jump_to_index

.asm_11cd7d
	ld a, EZCHAT_DRAW_SORT_BY_CHARACTER
.jump_to_index
	ld [wJumptableIndex], a
	ld hl, wEZChatSpritesMask
	set 5, [hl]
	call PlayClickSFX
	ret

.up
	ld a, [hl]
	and a
	ret z
	dec [hl]
	ld de, EZChatString_SortByCategory
	jr .asm_11cd9b

.down
	ld a, [hl]
	and a
	ret nz
	inc [hl]
	ld de, EZChatString_SortByAlphabetical
.asm_11cd9b
	push de
	ld de, EZChatBKG_SortBy
	call EZChat_Textbox
	pop de
	hlcoord 1, 14
	call PlaceString
	ret

Function11cdaa:
	ld a, $2
	hlcoord 0, 6, wAttrmap
	ld bc, 6 * SCREEN_WIDTH
	call ByteFill
	ld a, $7
	hlcoord 0, 12, wAttrmap
	ld bc, 4 * SCREEN_WIDTH
	call ByteFill
	farcall ReloadMapPart
	ret

EZChatString_SortByCategory:
; Words will be displayed by category
	db   "Palabras ordenados";"ことば¯しゅるいべつに"
	next "por categoría.@";"えらべます@"

EZChatString_SortByAlphabetical:
; Words will be displayed in alphabetical order
	db   "Palabras ordenados";"ことば¯アイウエオ　の"
	next "alfabéticamente.@";"じゅんばんで　ひょうじ　します@"

EZChatString_SortByMenu:
	db   "MODO CATEGORÍA";"しゅるいべつ　モード"  ; Category mode
	next "MODO A a Z@";"アイウエオ　　モード@" ; ABC mode

EZChatDraw_SortByCharacter: ; Sort by Character Menu
	call EZChat_ClearBottom12Rows
	hlcoord 1, 7
	ld de, EZChatScript_SortByCharacterTable
	call PlaceString
	hlcoord 1, 17
	ld de, EZChatString_Stop_Mode_Cancel
	call PlaceString
	call EZChat_SortMenuBackground
	ld hl, wEZChatSpritesMask
	res 2, [hl]
	call EZChat_IncreaseJumptable

EZChatMenu_SortByCharacter: ; Sort By Character Menu Controls
	ld a, [wEZChatSortedSelection] ; x 4
	sla a
	sla a
	ld c, a
	ld b, 0
	ld hl, .NeighboringCharacters
	add hl, bc

; got character
	ld de, hJoypadPressed
	ld a, [de]
	and START
	jr nz, .start
	ld a, [de]
	and SELECT
	jr nz, .select
	ld a, [de]
	and A_BUTTON
	jr nz, .a
	ld a, [de]
	and B_BUTTON
	jr nz, .b

	ld de, hJoyLast
	ld a, [de]
	and D_UP
	jr nz, .up
	ld a, [de]
	and D_DOWN
	jr nz, .down
	ld a, [de]
	and D_LEFT
	jr nz, .left
	ld a, [de]
	and D_RIGHT
	jr nz, .right

	ret

.a
	ld a, [wEZChatSortedSelection]
	cp EZCHAT_SORTED_ERASE
	jr c, .place
	sub EZCHAT_SORTED_ERASE
	jr z, .done
	dec a
	jr z, .mode
	jr .b ; cancel

.start
	ld hl, wEZChatSpritesMask
	set 0, [hl]
	ld a, EZCHAT_MAIN_OK
	ld [wEZChatSelection], a
.b
	ld a, EZCHAT_DRAW_CHAT_WORDS
	jr .load

.select
	ld a, [wEZChatCategoryMode]
	xor (1 << 0) + (1 << 7)
	ld [wEZChatCategoryMode], a
	ld a, EZCHAT_DRAW_CATEGORY_MENU
	jr .load

.place
	ld hl, wc6a8 ; $c68a + 30
	ld c, a
	ld b, 0
	add hl, bc
	add hl, bc
	ld a, [hl]
	and a
;	jr nz, .valid ; Removed to be more in line with Gen 3
;	ld de, SFX_WRONG
;	call PlaySFX
;	jp WaitSFX
	ret z
.valid
	ld a, EZCHAT_DRAW_WORD_SUBMENU
	jr .load

.mode
	ld a, EZCHAT_DRAW_SORT_BY_MENU
.load
	ld [wJumptableIndex], a
	ld hl, wEZChatSpritesMask
	set 2, [hl]
	call PlayClickSFX
	ret

.done
	ld a, [wEZChatSelection]
	call EZChatDraw_EraseWordsLoop
	call EZChatMenu_RerenderMessage
	call PlayClickSFX
	ret

.left
	inc hl
.down
	inc hl
.right
	inc hl
.up
	ld a, [hl]
	cp EZCHAT_SORTED_NULL
	ret z
	ld [wEZChatSortedSelection], a
	ret

.NeighboringCharacters: ; Sort Menu Letter tile values or coordinates?
	table_width 4, .NeighboringCharacters
; A
	;  Up                  Right               Down                  Left
	db EZCHAT_SORTED_NULL, EZCHAT_SORTED_B,      EZCHAT_SORTED_J,      EZCHAT_SORTED_NULL
; B
	db EZCHAT_SORTED_NULL, EZCHAT_SORTED_C,      EZCHAT_SORTED_K,      EZCHAT_SORTED_A
; C
	db EZCHAT_SORTED_NULL, EZCHAT_SORTED_D,      EZCHAT_SORTED_L,      EZCHAT_SORTED_B
; D
	db EZCHAT_SORTED_NULL, EZCHAT_SORTED_E,      EZCHAT_SORTED_M,      EZCHAT_SORTED_C
; E
	db EZCHAT_SORTED_NULL, EZCHAT_SORTED_F,      EZCHAT_SORTED_N,      EZCHAT_SORTED_D
; F
	db EZCHAT_SORTED_NULL, EZCHAT_SORTED_G,      EZCHAT_SORTED_O,      EZCHAT_SORTED_E
; G
	db EZCHAT_SORTED_NULL, EZCHAT_SORTED_H,      EZCHAT_SORTED_P,      EZCHAT_SORTED_F
; H
	db EZCHAT_SORTED_NULL, EZCHAT_SORTED_I,      EZCHAT_SORTED_Q,      EZCHAT_SORTED_G
; I
	db EZCHAT_SORTED_NULL, EZCHAT_SORTED_NULL,   EZCHAT_SORTED_R,      EZCHAT_SORTED_H
; J
	db EZCHAT_SORTED_A,    EZCHAT_SORTED_K,      EZCHAT_SORTED_S,      EZCHAT_SORTED_NULL
; K
	db EZCHAT_SORTED_B,    EZCHAT_SORTED_L,      EZCHAT_SORTED_T,      EZCHAT_SORTED_J
; L
	db EZCHAT_SORTED_C,    EZCHAT_SORTED_M,      EZCHAT_SORTED_U,      EZCHAT_SORTED_K
; M
	db EZCHAT_SORTED_D,    EZCHAT_SORTED_N,      EZCHAT_SORTED_V,      EZCHAT_SORTED_L
; N
	db EZCHAT_SORTED_E,    EZCHAT_SORTED_O,      EZCHAT_SORTED_W,      EZCHAT_SORTED_M
; O
	db EZCHAT_SORTED_F,    EZCHAT_SORTED_P,      EZCHAT_SORTED_X,      EZCHAT_SORTED_N
; P
	db EZCHAT_SORTED_G,    EZCHAT_SORTED_Q,      EZCHAT_SORTED_Y,      EZCHAT_SORTED_O
; Q
	db EZCHAT_SORTED_H,    EZCHAT_SORTED_R,      EZCHAT_SORTED_Z,      EZCHAT_SORTED_P
; R
	db EZCHAT_SORTED_I,    EZCHAT_SORTED_NULL,   EZCHAT_SORTED_CANCEL, EZCHAT_SORTED_Q
; S
	db EZCHAT_SORTED_J,    EZCHAT_SORTED_T,      EZCHAT_SORTED_ETC,    EZCHAT_SORTED_NULL
; T
	db EZCHAT_SORTED_K,    EZCHAT_SORTED_U,      EZCHAT_SORTED_ETC,    EZCHAT_SORTED_S
; U
	db EZCHAT_SORTED_L,    EZCHAT_SORTED_V,      EZCHAT_SORTED_ETC,    EZCHAT_SORTED_T
; V
	db EZCHAT_SORTED_M,    EZCHAT_SORTED_W,      EZCHAT_SORTED_MODE,   EZCHAT_SORTED_U
; W
	db EZCHAT_SORTED_N,    EZCHAT_SORTED_X,      EZCHAT_SORTED_MODE,   EZCHAT_SORTED_V
; X
	db EZCHAT_SORTED_O,    EZCHAT_SORTED_Y,      EZCHAT_SORTED_MODE,   EZCHAT_SORTED_W
; Y
	db EZCHAT_SORTED_P,    EZCHAT_SORTED_Z,      EZCHAT_SORTED_CANCEL, EZCHAT_SORTED_X
; Z
	db EZCHAT_SORTED_Q,    EZCHAT_SORTED_NULL,   EZCHAT_SORTED_CANCEL, EZCHAT_SORTED_Y
; ETC.
	db EZCHAT_SORTED_S,    EZCHAT_SORTED_NULL,   EZCHAT_SORTED_ERASE,  EZCHAT_SORTED_NULL
; ERASE
	db EZCHAT_SORTED_ETC,  EZCHAT_SORTED_MODE,   EZCHAT_SORTED_NULL,   EZCHAT_SORTED_NULL
; MODE
	db EZCHAT_SORTED_V,    EZCHAT_SORTED_CANCEL, EZCHAT_SORTED_NULL,   EZCHAT_SORTED_ERASE
; CANCEL
	db EZCHAT_SORTED_Y,    EZCHAT_SORTED_NULL,   EZCHAT_SORTED_NULL,   EZCHAT_SORTED_MODE
	assert_table_length NUM_EZCHAT_SORTED

EZChatScript_SortByCharacterTable:
	db   "A B C D E F G H I"
	next "J K L M N O P Q R"
	next "S T U V W X Y Z"
	next "otros"
	db   "@"

EZChat_IncreaseJumptable:
	ld hl, wJumptableIndex
	inc [hl]
	ret

EZChatBKG_ChatWords: ; EZChat Word Background
	db  0,  0 ; start coords
	db 20,  6 ; end coords

EZChatBKG_ChatExplanation: ; EZChat Explanation Background
	db  0, 14 ; start coords
	db 20,  4 ; end coords

EZChatBKG_WordSubmenu:
	db  0,  6 ; start coords
	db 20, 10 ; end coords

EZChatBKG_SortBy: ; Sort Menu
	db  0, 12 ; start coords
	db 20,  6 ; end coords

EZChatBKG_SortByConfirmation:
	db 15,  7 ; start coords
	db  5,  5 ; end coords

EZChat_Textbox:
	hlcoord 0, 0
	ld bc, SCREEN_WIDTH
	ld a, [de]
	inc de
	push af
	ld a, [de]
	inc de
	and a
.add_n_times
	jr z, .done_add_n_times
	add hl, bc
	dec a
	jr .add_n_times
.done_add_n_times
	pop af
	ld c, a
	ld b, 0
	add hl, bc
	push hl
	ld a, $79
	ld [hli], a
	ld a, [de]
	inc de
	dec a
	dec a
	jr z, .skip_fill
	ld c, a
	ld a, $7a
.fill_loop
	ld [hli], a
	dec c
	jr nz, .fill_loop
.skip_fill
	ld a, $7b
	ld [hl], a
	pop hl
	ld bc, SCREEN_WIDTH
	add hl, bc
	ld a, [de]
	dec de
	dec a
	dec a
	jr z, .skip_section
	ld b, a
.loop
	push hl
	ld a, $7c
	ld [hli], a
	ld a, [de]
	dec a
	dec a
	jr z, .skip_row
	ld c, a
	ld a, $7f
.row_loop
	ld [hli], a
	dec c
	jr nz, .row_loop
.skip_row
	ld a, $7c
	ld [hl], a
	pop hl
	push bc
	ld bc, SCREEN_WIDTH
	add hl, bc
	pop bc
	dec b
	jr nz, .loop
.skip_section
	ld a, $7d
	ld [hli], a
	ld a, [de]
	dec a
	dec a
	jr z, .skip_remainder
	ld c, a
	ld a, $7a
.final_loop
	ld [hli], a
	dec c
	jr nz, .final_loop
.skip_remainder
	ld a, $7e
	ld [hl], a
	ret

EZChat_Textbox2:
	hlcoord 0, 0
	ld bc, SCREEN_WIDTH
	ld a, [de]
	inc de
	push af
	ld a, [de]
	inc de
	and a
.add_n_times
	jr z, .done_add_n_times
	add hl, bc
	dec a
	jr .add_n_times
.done_add_n_times
	pop af
	ld c, a
	ld b, 0
	add hl, bc
	push hl
	ld a, $79
	ld [hl], a
	pop hl
	push hl
	ld a, [de]
	dec a
	inc de
	ld c, a
	add hl, bc
	ld a, $7b
	ld [hl], a
	call .AddNMinusOneTimes
	ld a, $7e
	ld [hl], a
	pop hl
	push hl
	call .AddNMinusOneTimes
	ld a, $7d
	ld [hl], a
	pop hl
	push hl
	inc hl
	push hl
	call .AddNMinusOneTimes
	pop bc
	dec de
	ld a, [de]
	cp $2
	jr z, .skip
	dec a
	dec a
.loop
	push af
	ld a, $7a
	ld [hli], a
	ld [bc], a
	inc bc
	pop af
	dec a
	jr nz, .loop
.skip
	pop hl
	ld bc, $14
	add hl, bc
	push hl
	ld a, [de]
	dec a
	ld c, a
	ld b, 0
	add hl, bc
	pop bc
	inc de
	ld a, [de]
	cp $2
	ret z
	push bc
	dec a
	dec a
	ld c, a
	ld b, a
	ld de, $14
.loop2
	ld a, $7c
	ld [hl], a
	add hl, de
	dec c
	jr nz, .loop2
	pop hl
.loop3
	ld a, $7c
	ld [hl], a
	add hl, de
	dec b
	jr nz, .loop3
	ret

.AddNMinusOneTimes:
	ld a, [de]
	dec a
	ld bc, SCREEN_WIDTH
.add_n_minus_one_times
	add hl, bc
	dec a
	jr nz, .add_n_minus_one_times
	ret

PrepareEZChatCustomBox:
	ld a, [wEZChatSelection]
	cp EZCHAT_MAIN_RESET
	ret nc
	ld hl, wMobileBoxSpriteLoadedIndex
	cp [hl]
	ret z
	ld [hl], a
	ld d, a
	call DelayFrame
	ld a, d
	call EZChatMenu_GetRealChosenWordSize
	ld hl, wMobileBoxSpriteBuffer
	ld c, a
	dec c
	cp EZCHAT_CUSTOM_BOX_BIG_SIZE
	jr c, .after_big_reshape
	ld a, (EZCHAT_CUSTOM_BOX_BIG_START * 2) - 1
	jr .done_reshape
.after_big_reshape
	ld a, d
	and 1
	ld a, d
	jr z, .after_reshape
	dec a
	dec a
.after_reshape
	inc a
	call EZChatMenu_GetRealChosenWordSize
	sub EZCHAT_CHARS_PER_LINE - ((EZCHAT_CHARS_PER_LINE - 1) / 2)
	ld c, a
	ld a, ((EZCHAT_CHARS_PER_LINE - 1) / 2)
	jr c, .prepare_for_resize
	dec a
	sub c
.prepare_for_resize
	ld c, a
	dec c

.done_reshape
	inc a
	sla a
	ld [hli], a
	ld de, $3000
	ld b, 0
	call .single_row
	ld de, $3308
.single_row
	push bc
	ld [hl], e
	inc hl
	ld [hl], b
	inc hl
	ld [hl], d
	inc hl
	inc d
	ld [hl], b
	inc hl
	ld a, c
	srl c
	sub c
	push bc
	ld c, a
	and a
	ld a, 8
	call nz, .line_loop
	pop bc
	sub a, 4
	ld [hl], a
	ld a, c
	and a
	ld a, [hl]
	call nz, .line_loop
	inc d
	ld [hl], e
	inc hl
	ld [hli], a
	ld [hl], d
	inc hl
	ld [hl], b
	inc hl
	pop bc
	ld a, c
	cp EZCHAT_CUSTOM_BOX_BIG_SIZE - 1
	ret c
	sub EZCHAT_CUSTOM_BOX_BIG_START - 2
	sla a
	sla a
	ld d, 0
	ld e, a
	ld a, l
	sub e
	ld l, a
	ld a, h
	sbc d
	ld h, a
	ld a, c
	sub (EZCHAT_CUSTOM_BOX_BIG_START * 2) - 2
	sla a
	sla a
	push hl
	ld e, a
	add hl, de
	pop de
	push bc
	ld c, EZCHAT_CUSTOM_BOX_BIG_START * 4
.resize_loop
	ld a, [hli]
	ld [de], a
	inc de
	dec c
	jr nz, .resize_loop
	pop bc
	ld h, d
	ld l, e
	ret

.line_loop
	ld [hl], e
	inc hl
	ld [hli], a
	add a, 8
	ld [hl], d
	inc hl
	ld [hl], b
	inc hl
	dec c
	jr nz, .line_loop
	ret

AnimateEZChatCursor: ; EZChat cursor drawing code, extends all the way down to roughly line 2958
	ld hl, SPRITEANIMSTRUCT_VAR1
	add hl, bc
	jumptable .Jumptable, hl

.Jumptable:
	dw .zero   ; EZChat Message Menu
	dw .one    ; Category Menu
	dw .two    ; Sort By Letter Menu
	dw .three  ; Words Submenu
	dw .four   ; Yes/No Menu
	dw .five   ; Sort By Menu
	dw .six
	dw .seven
	dw .eight
	dw .nine
	dw .ten

.coords_null
	dbpixel  0,  20 ; A

.null_cursor_out
	ld a, SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_2
	call ReinitSpriteAnimFrame
	xor a
	ld hl, .coords_null
	jp .load

.zero ; EZChat Message Menu
; reinit sprite
	ld a, [wEZChatSelection]
	cp EZCHAT_MAIN_RESET
	jr c, .zero_check_word
	ld a, SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_1
	jr .zero_sprite_anim_frame

.zero_check_word
	call EZChatMenu_GetChosenWordSize
	and a
	ret z
	push bc
	call PrepareEZChatCustomBox
	pop bc
	ld a, SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_CUSTOM_BOX
.zero_sprite_anim_frame
	call ReinitSpriteAnimFrame
	ld e, $1 ; Category Menu Index (?) (May be the priority of which the selection boxes appear (0 is highest))
	ld a, [wEZChatSelection]
	cp EZCHAT_MAIN_RESET
	jr nc, .use_base_coords
	ld hl, wMobileBoxSpritePositionData
	sla a
	jr .load

.use_base_coords
	sub EZCHAT_MAIN_RESET
	sla a
	ld hl, .Coords_Zero
	jr .load

.one ; Category Menu
	ld a, [wJumptableIndex]
	ld e, $2 ; Sort by Letter Menu Index (?)
	cp EZCHAT_DRAW_CATEGORY_MENU
	jr z, .continue_one
	cp EZCHAT_MENU_CATEGORY_MENU
	jr nz, .null_cursor_out
.continue_one
	ld a, [wEZChatCategorySelection]
	and $0f
	cp EZCHAT_CATEGORY_CANC
	push af
	jr c, .not_menu
	ld a, SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_1
	call ReinitSpriteAnimFrame
	jr .got_sprite
.not_menu
	ld a, SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_2
	call ReinitSpriteAnimFrame
.got_sprite
	pop af
	sla a
	ld hl, .Coords_One
	ld e, $2 ; Sort by Letter Menu Index (?)
	jr .load

.two ; Sort By Letter Menu
	ld a, [wJumptableIndex]
	ld e, $4 ; Yes/No Menu Index (?)
	cp EZCHAT_DRAW_SORT_BY_CHARACTER
	jr z, .continue_two
	cp EZCHAT_MENU_SORT_BY_CHARACTER
	jr nz, .null_cursor_out
.continue_two
	ld hl, .FramesetsIDs_Two
	ld a, [wEZChatSortedSelection]
	ld e, a
	ld d, $0 ; Message Menu Index (?)
	add hl, de
	ld a, [hl]
	call ReinitSpriteAnimFrame

	ld a, [wEZChatSortedSelection]
	sla a
	ld hl, .Coords_Two
	ld e, $4 ; Yes/No Menu Index (?)
	jr .load

.three ; Words Submenu
	ld a, SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_2 ; $27
	call ReinitSpriteAnimFrame
	ld a, [wEZChatWordSelection]
	sla a
	ld hl, .Coords_Three
	ld e, $8
.load
	push de
	ld e, a
	ld d, $0 ; Message Menu Index (?)
	add hl, de
	push hl
	pop de
	ld hl, SPRITEANIMSTRUCT_XCOORD
	add hl, bc
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	ld [hl], a
	pop de
	ld a, e
	call .UpdateObjectFlags
	ret

.four ; Yes/No Menu
	ld a, SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_2 ; $27
	call ReinitSpriteAnimFrame
	ld a, [wcd2a]
	sla a
	ld hl, .Coords_Four
	ld e, $10
	jr .load

.five ; Sort By Menu
	ld a, SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_2 ; $27
	call ReinitSpriteAnimFrame
	ld a, [wcd2c]
	sla a
	ld hl, .Coords_Five
	ld e, $20
	jr .load

.six
	ld a, SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_5 ; $2a
	call ReinitSpriteAnimFrame
	ld a, [wcd4a] ; X = [wcd4a] * 8 + 24
	sla a
	sla a
	sla a
	add $18
	ld hl, SPRITEANIMSTRUCT_XCOORD
	add hl, bc
	ld [hli], a
	ld a, $30 ; Y = 48
	ld [hl], a

	ld a, $1
	ld e, a
	call .UpdateObjectFlags
	ret

.seven
	ld a, [wEZChatCursorYCoord]
	cp $4 ; Yes/No Menu Index (?)
	jr z, .cursor0
	ld a, SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3 ; $28
	jr .got_frameset
;test
.cursor0
	ld a, SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_1 ; $26
.got_frameset
	call ReinitSpriteAnimFrame
	ld a, [wEZChatCursorYCoord]
	cp $4 ; Yes/No Menu Index (?)
	jr z, .asm_11d1b1
	ld a, [wEZChatCursorXCoord]	; X = [wEZChatCursorXCoord] * 8 + 32
	sla a
	sla a
	sla a
	add $20
	ld hl, SPRITEANIMSTRUCT_XCOORD
	add hl, bc
	ld [hli], a
	ld a, [wEZChatCursorYCoord]	; Y = [wEZChatCursorYCoord] * 16 + 72
	sla a
	sla a
	sla a
	sla a
	add $48
	ld [hl], a
	ld a, $2 ; Sort by Letter Menu Index (?)
	ld e, a
	call .UpdateObjectFlags
	ret

.asm_11d1b1
	ld a, [wEZChatCursorXCoord] ; X = [wEZChatCursorXCoord] * 40 + 24
	sla a
	sla a
	sla a
	ld e, a
	sla a
	sla a
	add e
	add $18
	ld hl, SPRITEANIMSTRUCT_XCOORD
	add hl, bc
	ld [hli], a
	ld a, $8a ; Y = 138
	ld [hl], a
	ld a, $2 ; Sort By Letter Menu Index (?)
	ld e, a
	call .UpdateObjectFlags
	ret

.nine
	ld d, -13 * 8
	ld a, SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_7 ; $2c
	jr .eight_nine_load

.eight
	ld d, 2 * 8
	ld a, SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_6 ; $2b
.eight_nine_load
	push de
	call ReinitSpriteAnimFrame
	ld a, [wcd4a]
	sla a
	sla a
	sla a
	ld e, a
	sla a
	add e
	add 8 * 8
	ld hl, SPRITEANIMSTRUCT_YCOORD
	add hl, bc
	ld [hld], a
	pop af
	ld [hl], a
	ld a, $4 ; Yes/No Menu Index (?)
	ld e, a
	call .UpdateObjectFlags
	ret

.ten
	ld a, SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_1 ; $26
	call ReinitSpriteAnimFrame
	ld a, $8
	ld e, a
	call .UpdateObjectFlags
	ret

.Coords_Zero: ; EZChat Message Menu
	dbpixel  1, 17, 5, 2 ; RESET     - 04
	dbpixel  7, 17, 5, 2 ; QUIT      - 05
	dbpixel 13, 17, 5, 2 ; OK        - 06

.Coords_One: ; Category Menu
	dbpixel  0,  8, 8, 8 ; Category 1
	dbpixel 10,  8, 8, 8 ; Category 2
	dbpixel  0, 10, 8, 8 ; Category 3
	dbpixel 10, 10, 8, 8 ; Category 4
	dbpixel  0, 12, 8, 8 ; Category 5
	dbpixel 10, 12, 8, 8 ; Category 6
	dbpixel  0, 14, 8, 8 ; Category 7
	dbpixel 10, 14, 8, 8 ; Category 8
	dbpixel  0, 16, 8, 8 ; Category 9
	dbpixel 10, 16, 8, 8 ; Category 10
	dbpixel  1, 18, 5, 2 ; DEL
	dbpixel  7, 18, 5, 2 ; MODE
	dbpixel 13, 18, 5, 2 ; QUIT

.Coords_Two: ; Sort By Letter Menu
	table_width 2, .Coords_Two
	dbpixel  2,  9 ; A
	dbpixel  4,  9 ; B
	dbpixel  6,  9 ; C
	dbpixel  8,  9 ; D
	dbpixel 10,  9 ; E
	dbpixel 12,  9 ; F
	dbpixel 14,  9 ; G
	dbpixel 16,  9 ; H
	dbpixel 18,  9 ; I
	dbpixel  2, 11 ; J
	dbpixel  4, 11 ; K
	dbpixel  6, 11 ; L
	dbpixel  8, 11 ; M
	dbpixel 10, 11 ; N
	dbpixel 12, 11 ; O
	dbpixel 14, 11 ; P
	dbpixel 16, 11 ; Q
	dbpixel 18, 11 ; R
	dbpixel  2, 13 ; S
	dbpixel  4, 13 ; T
	dbpixel  6, 13 ; U
	dbpixel  8, 13 ; V
	dbpixel 10, 13 ; W
	dbpixel 12, 13 ; X
	dbpixel 14, 13 ; Y
	dbpixel 16, 13 ; Z
	dbpixel  2, 15 ; ETC.
	dbpixel  1, 18, 5, 2 ; ERASE
	dbpixel  7, 18, 5, 2 ; MODE
	dbpixel 13, 18, 5, 2 ; CANCEL
	assert_table_length NUM_EZCHAT_SORTED

.Coords_Three: ; Words Submenu Arrow Positions
	dbpixel  2, 10
	dbpixel  11, 10 ; 8, 10 MENU_WIDTH
	dbpixel  2, 12
	dbpixel  11, 12 ; 8, 12 MENU_WIDTH
	dbpixel  2, 14
	dbpixel  11, 14 ; 8, 14 MENU_WIDTH
	dbpixel  2, 16
	dbpixel  11, 16 ; 8, 16 MENU_WIDTH

.Coords_Four: ; Yes/No Box
	dbpixel 17, 10 ; YES
	dbpixel 17, 12 ; NO

.Coords_Five: ; Sort By Menu
	dbpixel  3, 10 ; Group Mode
	dbpixel  3, 12 ; ABC Mode

.FramesetsIDs_Two:
	table_width 1, .FramesetsIDs_Two
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3  ; 00 (Letter selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3  ; 01 (Letter selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3  ; 02 (Letter selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3  ; 03 (Letter selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3  ; 04 (Letter selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3  ; 05 (Letter selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3  ; 06 (Letter selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3  ; 07 (Letter selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3  ; 08 (Letter selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3  ; 09 (Letter selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3  ; 0a (Letter selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3  ; 0b (Letter selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3  ; 0c (Letter selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3  ; 0d (Letter selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3  ; 0e (Letter selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3  ; 0f (Letter selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3  ; 10 (Letter selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3  ; 11 (Letter selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3  ; 12 (Letter selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3  ; 13 (Letter selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3  ; 14 (Letter selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3  ; 15 (Letter selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3  ; 16 (Letter selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3  ; 17 (Letter selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3  ; 18 (Letter selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_3  ; 19 (Letter selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_10 ; 1a (Misc selection box for the sort by menu)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_1  ; 1c (Bottom Menu Selection box?)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_1  ; 1d (Bottom Menu Selection box?)
	db SPRITE_ANIM_FRAMESET_EZCHAT_CURSOR_1  ; 1e (Bottom Menu Selection box?)
	assert_table_length NUM_EZCHAT_SORTED

.UpdateObjectFlags:
	ld hl, wEZChatSpritesMask
	and [hl]
	jr nz, .update_y_offset
	ld a, e
	ld hl, wEZChatBlinkingMask
	and [hl]
	jr z, .reset_y_offset
	ld hl, SPRITEANIMSTRUCT_VAR3
	add hl, bc
	ld a, [hl]
	and a
	jr z, .flip_bit_0
	dec [hl]
	ret

.flip_bit_0
	ld a, $0
	ld [hld], a
	ld a, $1
	xor [hl]
	ld [hl], a
	and a
	jr nz, .update_y_offset
.reset_y_offset
	ld hl, SPRITEANIMSTRUCT_YOFFSET
	add hl, bc
	xor a
	ld [hl], a
	ret

.update_y_offset
	ld hl, SPRITEANIMSTRUCT_YCOORD
	add hl, bc
	ld a, $b0
	sub [hl]
	ld hl, SPRITEANIMSTRUCT_YOFFSET
	add hl, bc
	ld [hl], a
	ret

Function11d323:
	ldh a, [rSVBK]
	push af
	ld a, $5
	ldh [rSVBK], a
	ld hl, Palette_11d33a
	ld de, wBGPals1
	ld bc, 16 palettes
	call CopyBytes
	pop af
	ldh [rSVBK], a
	ret

Palette_11d33a:
	RGB 31, 31, 31
	RGB 00, 00, 00
	RGB 00, 00, 00
	RGB 00, 00, 00

	RGB 31, 16, 31
	RGB 00, 00, 00
	RGB 00, 00, 00
	RGB 00, 00, 00

	RGB 23, 17, 31
	RGB 00, 00, 00
	RGB 00, 00, 00
	RGB 00, 00, 00

	RGB 31, 31, 31
	RGB 00, 00, 00
	RGB 00, 00, 00
	RGB 00, 00, 00

	RGB 31, 31, 31
	RGB 00, 00, 00
	RGB 00, 00, 00
	RGB 00, 00, 00

	RGB 31, 31, 31
	RGB 00, 00, 00
	RGB 00, 00, 00
	RGB 00, 00, 00

	RGB 31, 31, 31
	RGB 00, 00, 00
	RGB 00, 00, 00
	RGB 00, 00, 00

	RGB 31, 31, 31
	RGB 00, 00, 00
	RGB 00, 00, 00
	RGB 00, 00, 00

	RGB 00, 00, 00
	RGB 00, 00, 00
	RGB 00, 00, 00
	RGB 00, 00, 00

	RGB 00, 00, 00
	RGB 00, 00, 00
	RGB 00, 00, 00
	RGB 00, 00, 00

	RGB 00, 00, 00
	RGB 00, 00, 00
	RGB 00, 00, 00
	RGB 00, 00, 00

	RGB 00, 00, 00
	RGB 00, 00, 00
	RGB 00, 00, 00
	RGB 00, 00, 00

	RGB 00, 00, 00
	RGB 00, 00, 00
	RGB 00, 00, 00
	RGB 00, 00, 00

	RGB 00, 00, 00
	RGB 00, 00, 00
	RGB 00, 00, 00
	RGB 00, 00, 00

	RGB 00, 00, 00
	RGB 00, 00, 00
	RGB 00, 00, 00
	RGB 00, 00, 00

	RGB 00, 00, 00
	RGB 00, 00, 00
	RGB 00, 00, 00
	RGB 00, 00, 00

EZChat_GetSeenPokemonByKana:
; final placement of words in the sorted category, stored in 5:D800
	ldh a, [rSVBK]
	push af
	ld hl, wEZChatSortedWordPointers
	ld a, LOW(wEZChatSortedWords)
	ld [wcd2d], a
	ld [hli], a
	ld a, HIGH(wEZChatSortedWords)
	ld [wcd2e], a
	ld [hl], a

	ld a, LOW(EZChat_SortedPokemon)
	ld [wcd2f], a
	ld a, HIGH(EZChat_SortedPokemon)
	ld [wcd30], a

	ld a, LOW(wc6a8)
	ld [wcd31], a
	ld a, HIGH(wc6a8)
	ld [wcd32], a

	ld a, LOW(wc64a)
	ld [wcd33], a
	ld a, HIGH(wc64a)
	ld [wcd34], a

	ld hl, EZChat_SortedWords
	ld a, (EZChat_SortedWords.End - EZChat_SortedWords) / 4

.MasterLoop:
	push af
; read row
; offset
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
; size
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
; bc == 0?
	or c

; save the pointer to the next row
	push hl
; add de to w3_d000
	ld hl, w3_d000
	add hl, de
; recover de from wcd2d (default: wEZChatSortedWords)
	ld a, [wcd2d]
	ld e, a
	ld a, [wcd2e]
	ld d, a
; save bc for later
	push bc
	jr z, .done_copying

.loop1
; copy 2*bc bytes from 3:hl to 5:de
	ld a, $3
	ldh [rSVBK], a
	ld a, [hli]
	push af
	ld a, $5
	ldh [rSVBK], a
	pop af
	ld [de], a
	inc de

	ld a, $3
	ldh [rSVBK], a
	ld a, [hli]
	push af
	ld a, $5
	ldh [rSVBK], a
	pop af
	ld [de], a
	inc de

	dec bc
	ld a, c
	or b
	jr nz, .loop1

.done_copying
; recover the pointer from wcd2f (default: EZChat_SortedPokemon)
	ld a, [wcd2f]
	ld l, a
	ld a, [wcd30]
	ld h, a
; copy the pointer from [hl] to bc
	ld a, [hli]
	ld c, a
	ld a, [hli]
	ld b, a
; store the pointer to the next pointer back in wcd2f
	ld a, l
	ld [wcd2f], a
	ld a, h
	ld [wcd30], a
	ld h, b
	ld l, c
	ld c, $0
.loop2
; Have you seen this Pokemon?
	ld a, [hl]
	cp $ff
	jr z, .done
	call .CheckSeenMon
	jr nz, .next
; If not, skip it.
	inc hl
	jr .loop2

.next
; If so, append it to the list at 5:de, and increase the count.
	ld a, [hli]
	ld [de], a
	inc de
	xor a
	ld [de], a
	inc de
	inc c
	jr .loop2

.done
; Remember the original value of bc from the table?
; Well, the stack remembers it, and it's popping it to hl.
	pop hl
; Add the number of seen Pokemon from the list.
	ld b, $0
	add hl, bc
; Push pop to bc.
	ld b, h
	ld c, l
; Load the pointer from [wcd31] (default: wc6a8)
	ld a, [wcd31]
	ld l, a
	ld a, [wcd32]
	ld h, a
; Save the quantity from bc to [hl]
	ld a, c
	ld [hli], a
	ld a, b
	ld [hli], a
; Save the new value of hl to [wcd31]
	ld a, l
	ld [wcd31], a
	ld a, h
	ld [wcd32], a
; Recover the pointer from [wcd33] (default: wc64a)
	ld a, [wcd33]
	ld l, a
	ld a, [wcd34]
	ld h, a
; Save the current value of de there
	ld a, e
	ld [wcd2d], a
	ld [hli], a
	ld a, d
	ld [wcd2e], a
; Save the new value of hl back to [wcd33]
	ld [hli], a
	ld a, l
	ld [wcd33], a
	ld a, h
	ld [wcd34], a
; Next row
	pop hl
	pop af
	dec a
	jr z, .ExitMasterLoop
	jp .MasterLoop

.ExitMasterLoop:
	pop af
	ldh [rSVBK], a
	ret

.CheckSeenMon:
	push hl
	push bc
	push de
	dec a
	ld hl, rSVBK
	ld e, $1
	ld [hl], e
	call CheckSeenMon
	ld hl, rSVBK
	ld e, $5
	ld [hl], e
	pop de
	pop bc
	pop hl
	ret

EZChat_GetCategoryWordsByKana:
; initial sort of words, stored in 3:D000
	ldh a, [rSVBK]
	push af
	ld a, BANK(w3_d000)
	ldh [rSVBK], a

	; load pointers
	ld hl, MobileEZChatCategoryPointers
	ld bc, MobileEZChatData_WordAndPageCounts

	; init WRAM registers
	xor a
	ld [wcd2d], a
	inc a
	ld [wcd2e], a

	; enter the first loop
	ld a, 14 ; number of categories
.loop1
	push af

	; load the pointer to the category
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	push hl

	; skip to the attributes
	ld hl, EZCHAT_WORD_LENGTH
	add hl, de

	; get the number of words in the category
	ld a, [bc] ; number of entries to copy
	inc bc
	inc bc
	push bc

.loop2
	push af
	push hl

	; load word placement offset from [hl] -> de
	ld a, [hli]
	ld e, a
	ld a, [hl]
	ld d, a

	; add to w3_d000
	ld hl, w3_d000
	add hl, de

	; copy from wcd2d and increment [wcd2d] in place
	ld a, [wcd2d]
	ld [hli], a
	inc a
	ld [wcd2d], a

	; copy from wcd2e
	ld a, [wcd2e]
	ld [hl], a

	; next entry
	pop hl
	ld de, EZCHAT_WORD_LENGTH + 3
	add hl, de
	pop af
	dec a
	jr nz, .loop2

	; reset and go to next category
	ld hl, wcd2d
	xor a
	ld [hli], a
	inc [hl]
	pop bc
	pop hl
	pop af
	dec a
	jr nz, .loop1
	pop af
	ldh [rSVBK], a
	ret

INCLUDE "data/pokemon/ezchat_order.asm"

SelectStartGFX:
INCBIN "gfx/mobile/select_start.2bpp"

EZChatSlowpokeLZ:
INCBIN "gfx/pokedex/slowpoke_mobile.2bpp.lz"

MobileEZChatCategoryNames:
; Fixed message categories
	db "POKéMON@" 		; 00 ; Pokemon 		; "ポケモン@@" ; this could've also been rendered as <PK><MN> but it looks odd
	db "TIPOS@" 		; 01 ; Types		; "タイプ@@@"
	db "SALUDOS@" 		; 02 ; Greetings	; "あいさつ@@"
	db "GENTE@" 		; 03 ; People		; "ひと@@@@"
	db "COMBATE@" 		; 04 ; Battle		; "バトル@@@"
	db "VOCES@" 		; 05 ; Voices		; "こえ@@@@"
	db "NEXOS@" 		; 06 ; Speech		; "かいわ@@@"
	db "SENSACIÓN@" 	; 07 ; Feelings		; "きもち@@@"
	db "HABILIDAD@" 	; 08 ; Conditions	; "じょうたい@"
	db "VIDA@" 			; 09 ; Lifestyle	; "せいかつ@@"
	db "AFICIONES@" 	; 0a ; Hobbies		; "しゅみ@@@"
	db "ACCIONES@" 		; 0b ; Actions		; "こうどう@@"
	db "TIEMPO@@" 		; 0c ; Time			; "じかん@@@"
	db "VERBOS@@" 		; 0d ; Endings		; "むすび@@@"
	db "OTROS@" 		; 0e ; Misc			; "あれこれ@@"
	db " @@@@@"	    	; 0f ; EMPTY

MobileEZChatCategoryPointers:
; entries correspond to EZCHAT_* constants
	dw .Types          ; 01
	dw .Greetings      ; 02
	dw .People         ; 03
	dw .Battle         ; 04
	dw .Exclamations   ; 05
	dw .Conversation   ; 06
	dw .Feelings       ; 07
	dw .Conditions     ; 08
	dw .Life           ; 09
	dw .Hobbies        ; 0a
	dw .Actions        ; 0b
	dw .Time           ; 0c
	dw .Farewells      ; 0d
	dw .ThisAndThat    ; 0e

MACRO ezchat_word
	db \1 ; word
	dw \2 ; where to put the word relative to the start of the sorted words array (must be divisible by 2)
	db 0 ; padding
ENDM

.Types:
        ezchat_word "SINIEST.", $516
        ezchat_word "ROCA@@@@", $4d2
        ezchat_word "PSÍQUICO", $48c
        ezchat_word "CRUEL@@@", $1e4
        ezchat_word "PLANTA@@", $46a
        ezchat_word "FANTASMA", $2b4
        ezchat_word "HIELO@@@", $31e
        ezchat_word "TIERRA@@", $55c
        ezchat_word "TIPO@@@@", $562
        ezchat_word "ELÉCTRIC", $248
        ezchat_word "VENENO@@", $5a8
        ezchat_word "DRAGÓN@@", $238
        ezchat_word "NORMAL@@", $3fa
        ezchat_word "ACERO@@@", $09a
        ezchat_word "VOLADOR@", $5c2
        ezchat_word "FUEGO@@@", $2cc
        ezchat_word "AGUA@@@@", $0b6
        ezchat_word "BICHO@@@", $140
.Greetings:
        ezchat_word "GRACIAS!", $2f0
        ezchat_word "GRACIAS@", $2ee
        ezchat_word "¡VAMOS!@", $070
        ezchat_word "¡SIGUE!@", $068
        ezchat_word "¡DALE!@@", $024
        ezchat_word "SÍÍÍ@@@@", $514
        ezchat_word "DE NADA@", $1fa
        ezchat_word "BUEN DÍA", $14e
        ezchat_word "¡HURRA!@", $03a
        ezchat_word "PERDÓN@@", $456
        ezchat_word "¡PIEDAD!", $060
        ezchat_word "¡OYE!@@@", $05a
        ezchat_word "¡BUENAS!", $016
        ezchat_word "¡HOLA!@@", $036
        ezchat_word "¡ADIÓS!@", $00a
        ezchat_word "SALUD@@@", $4da
        ezchat_word "¡LLEGUÉ!", $046
        ezchat_word "¡PERDÓN!", $05e
        ezchat_word "QUÉ PENA", $49c
        ezchat_word "¡CHAO!@@", $020
        ezchat_word "¡EY!@@@@", $02a
        ezchat_word "BUENO…@@", $158
        ezchat_word "GRATO@@@", $2f6
        ezchat_word "¿BIEN?@@", $07e
        ezchat_word "BUENAS@@", $152
        ezchat_word "CIERTO@@", $18e
        ezchat_word "¡ME VOY!", $04a
        ezchat_word "AY, AY@@", $126
        ezchat_word "OLVÍDATE", $420
        ezchat_word "ALÓ@@@@@", $0d8
        ezchat_word "¡PASO!@@", $05c
        ezchat_word "HURRAAA@", $334
        ezchat_word "¡PÍRATE!", $062
        ezchat_word "SALUDOS@", $4dc
        ezchat_word "¡DÉJAME!", $026
        ezchat_word "BIENVEN.", $144
.People:
        ezchat_word "OPONENTE", $422
        ezchat_word "YO@@@@@@", $5ce
        ezchat_word "TÚ@@@@@@", $57e
        ezchat_word "NADIE@@@", $3d8
        ezchat_word "HIJO@@@@", $322
        ezchat_word "NINGUNO@", $3e8
        ezchat_word "BRUJITA@", $14a
        ezchat_word "ATLETA@@", $112
        ezchat_word "MADRE@@@", $380
        ezchat_word "ABUELO@@", $092
        ezchat_word "TÍO@@@@@", $560
        ezchat_word "PADRE@@@", $42c
        ezchat_word "NIÑO@@@@", $3ea
        ezchat_word "ADULTO@@", $0a6
        ezchat_word "HERMANO@", $314
        ezchat_word "HERMANA@", $312
        ezchat_word "ABUELA@@", $090
        ezchat_word "TÍA@@@@@", $554
        ezchat_word "NINGUNA@", $3e6
        ezchat_word "NIÑA@@@@", $3e4
        ezchat_word "BEBÉ@@@@", $138
        ezchat_word "FAMILIA@", $2b2
        ezchat_word "PRIMO@@@", $482
        ezchat_word "PRIMA@@@", $47e
        ezchat_word "ÉL@@@@@@", $246
        ezchat_word "SOBRINO@", $51a
        ezchat_word "HIJA@@@@", $320
        ezchat_word "SOBRINA@", $518
        ezchat_word "CHICO@@@", $188
        ezchat_word "CHICA@@@", $186
        ezchat_word "OCULTO@@", $416
        ezchat_word "HERMANOS", $316
        ezchat_word "NIÑOS@@@", $3ec
        ezchat_word "YO MISMO", $5d4
        ezchat_word "YO MISMA", $5d2
        ezchat_word "NIETO@@@", $3e2
        ezchat_word "NIETA@@@", $3e0
        ezchat_word "COLEGAS@", $19a
        ezchat_word "POKéFAN@", $472
        ezchat_word "QUIÉN@@@", $4a6
        ezchat_word "ALGUIEN@", $0c4
        ezchat_word "AMIGA@@@", $0e4
        ezchat_word "NOVIO@@@", $406
        ezchat_word "NOVIA@@@", $404
        ezchat_word "CONOCIDO", $1c2
        ezchat_word "ESTÁ@@@@", $28e
        ezchat_word "SRTA.@@@", $526
        ezchat_word "AMIGO@@@", $0e6
        ezchat_word "ALIADO@@", $0d2
        ezchat_word "PERSONA@", $45c
        ezchat_word "ALIADA@@", $0d0
        ezchat_word "ELLOS@@@", $250
        ezchat_word "ELLAS@@@", $24e
        ezchat_word "TODOS@@@", $56a
        ezchat_word "TODAS@@@", $566
        ezchat_word "COMPI@@@", $1ae
        ezchat_word "NOSOTRAS", $3fe
        ezchat_word "NOSOTROS", $400
        ezchat_word "VOSOTROS", $5c6
        ezchat_word "VOSOTRAS", $5c4
        ezchat_word "MAESTRO@", $384
        ezchat_word "MAESTRA@", $382
        ezchat_word "RIVAL@@@", $4d0
        ezchat_word "ELLA@@@@", $24c
        ezchat_word "COLEGIAL", $19c
        ezchat_word "ALGUNO@@", $0cc
        ezchat_word "ALGUNA@@", $0c8
        ezchat_word "ALGUNAS@", $0ca
        ezchat_word "ALGUNOS@", $0ce
.Battle:
        ezchat_word "VITAL@@@", $5c0
        ezchat_word "AVANZA@@", $120
        ezchat_word "N.° 1@@@", $3d4
        ezchat_word "GANARÁS@", $2de
        ezchat_word "YO GANO@", $5d0
        ezchat_word "GANA@@@@", $2da
        ezchat_word "GANAR@@@", $2dc
        ezchat_word "GANÉ@@@@", $2e4
        ezchat_word "SI GANO@", $508
        ezchat_word "FUERZAS@", $2d4
        ezchat_word "GANARME@", $2e0
        ezchat_word "VENCERÉ@", $5a4
        ezchat_word "PERDERÁS", $450
        ezchat_word "ESPÍRITU", $28c
        ezchat_word "TU RIVAL", $57c
        ezchat_word "AS@@@@@@", $102
        ezchat_word "HI-YA!@@", $31c
        ezchat_word "VENCERME", $5a6
        ezchat_word "ATACO@@@", $108
        ezchat_word "ME RINDO", $3a4
        ezchat_word "AGALLAS@", $0aa
        ezchat_word "TALENTO@", $538
        ezchat_word "TÁCTICAS", $534
        ezchat_word "ALUCINAR", $0dc
        ezchat_word "CÓLERA@@", $1a0
        ezchat_word "VICTORIA", $5b8
        ezchat_word "OFENSIVA", $41c
        ezchat_word "SENTIR@@", $4fa
        ezchat_word "VERSUS@@", $5b4
        ezchat_word "LUCHAR@@", $376
        ezchat_word "PODER@@@", $46c
        ezchat_word "DESAFÍO@", $20e
        ezchat_word "FUERZA@@", $2d2
        ezchat_word "TE PASAS", $544
        ezchat_word "MALA@@@@", $386
        ezchat_word "TERRIBLE", $550
        ezchat_word "¡CALMA!@", $01c
        ezchat_word "¡LUCHA!@", $048
        ezchat_word "GENIO@@@", $2e8
        ezchat_word "LEYENDA@", $362
        ezchat_word "ENTREN.@", $272
        ezchat_word "ESCAPAR@", $280
        ezchat_word "MODESTO@", $3c6
        ezchat_word "ODIO@@@@", $41a
        ezchat_word "COMBATE@", $1a2
        ezchat_word "LUCHO@@@", $37a
        ezchat_word "LUCHEMOS", $378
        ezchat_word "PUNTOS@@", $496
        ezchat_word "POKéMON@", $474
        ezchat_word "PELEO@@@", $440
        ezchat_word "¡OH NO!@", $052
        ezchat_word "PERDER@@", $44e
        ezchat_word "PALIZA@@", $42e
        ezchat_word "PERDERÉ@", $452
        ezchat_word "PERDIDO@", $454
        ezchat_word "LUCHA@@@", $374
        ezchat_word "AZOTES@@", $12c
        ezchat_word "RECHAZAR", $4ba
        ezchat_word "¡ACEPTO!", $008
        ezchat_word "INVICTO@", $344
        ezchat_word "TE TENGO", $546
        ezchat_word "FÁCIL@@@", $2ac
        ezchat_word "APRENDE@", $0f4
        ezchat_word "DEBILIT.", $202
        ezchat_word "MACHACAR", $37e
        ezchat_word "CAPITÁN@", $174
        ezchat_word "REGLAS@@", $4c4
        ezchat_word "NIVEL@@@", $3ee
        ezchat_word "MOV.@@@@", $3ca
.Exclamations:
        ezchat_word "!!@@@@@@", $004
        ezchat_word "!@@@@@@@", $000
        ezchat_word "¡@@@@@@@", $002
        ezchat_word "¿@@@@@@@", $07c
        ezchat_word "?@@@@@@@", $07a
        ezchat_word "¡MOLA!@@", $04e
        ezchat_word "¡GUAY!@@", $032
        ezchat_word "¡FLIPA!@", $02e
        ezchat_word "ALUCINA@", $0da
        ezchat_word "VAYA LÍO", $59c
        ezchat_word "¡VAYA!@@", $072
        ezchat_word "AJAJÁ@@@", $0bc
        ezchat_word "¿EH?@@@@", $082
        ezchat_word "¡NANAY!@", $050
        ezchat_word "EN@@@@@@", $258
        ezchat_word "¡ARREA!@", $00e
        ezchat_word "MMM@@@@@", $3c0
        ezchat_word "¡CARAY!@", $01e
        ezchat_word "¡AAAAAA!", $006
        ezchat_word "GUAU@@@@", $2fc
        ezchat_word "¡JI JI!@", $040
        ezchat_word "EN SHOCK", $25c
        ezchat_word "BUAAA@@@", $14c
        ezchat_word "¡VALE!@@", $06e
        ezchat_word "¿CÓMO?@@", $080
        ezchat_word "AY DE MÍ", $128
        ezchat_word "¡EJEJE!@", $028
        ezchat_word "MOMENTO@", $3c8
        ezchat_word "¡YEAH!@@", $076
        ezchat_word "¡MIRA!@@", $04c
        ezchat_word "¡FÍJATE!", $02c
        ezchat_word "EEK@@@@@", $242
        ezchat_word "¡QUÉ VA!", $066
        ezchat_word "JE, JE@@", $34a
        ezchat_word "¡BIEN!@@", $014
        ezchat_word "BONITA@@", $146
        ezchat_word "¡BUF!@@@", $01a
        ezchat_word "¡JE JE!@", $03e
        ezchat_word "DONDE@@@", $230
        ezchat_word "¿OH?@@@@", $088
        ezchat_word "¡BUENO!@", $018
        ezchat_word "¡AJÁ!@@@", $00c
        ezchat_word "ANDA@@@@", $0e8
        ezchat_word "¡LA LA!@", $042
        ezchat_word "JUA, JUA", $350
        ezchat_word "SUSURRO@", $52e
        ezchat_word "¡SNIF!@@", $06a
        ezchat_word "¡TÚ!@@@@", $06c
        ezchat_word "HUMF@@@@", $332
        ezchat_word "JEJEJE@@", $34c
        ezchat_word "¡JE, JE!", $03c
        ezchat_word "OHJOJO@@", $41e
        ezchat_word "¡YUJU!@@", $078
        ezchat_word "¡CIELOS!", $022
        ezchat_word "¡ARRGH!@", $010
        ezchat_word "¡OSTRAS!", $058
        ezchat_word "¡HALA!@@", $034
        ezchat_word "¡BAH!@@@", $012
        ezchat_word "¡OLÉ!@@@", $056
        ezchat_word "¡OK!@@@@", $054
        ezchat_word "¡LA!@@@@", $044
        ezchat_word "CUIDADO@", $1ea
        ezchat_word "QUÉ MONO", $49a
        ezchat_word "¡PUMBA!@", $064
        ezchat_word "¡VENGA!@", $074
        ezchat_word "¡GENIAL!", $030
.Conversation:
        ezchat_word "A@@@@@@@", $08c
        ezchat_word "ANTE@@@@", $0ee
        ezchat_word "COMO@@@@", $1aa
        ezchat_word "DE@@@@@@", $1f6
        ezchat_word "TE@@@@@@", $540
        ezchat_word "¡HOLI!@@", $038
        ezchat_word "PARA@@@@", $430
        ezchat_word "QUE@@@@@", $498
        ezchat_word "BASTANTE", $136
        ezchat_word "DESDE@@@", $210
        ezchat_word "AL@@@@@@", $0be
        ezchat_word "PERO@@@@", $45a
        ezchat_word "POR@@@@@", $478
        ezchat_word "TODO@@@@", $568
        ezchat_word "CON@@@@@", $1b2
        ezchat_word "VUESTROS", $5c8
        ezchat_word "DEL@@@@@", $208
        ezchat_word "O@@@@@@@", $40e
        ezchat_word "PRONTO@@", $486
        ezchat_word "MUCHO@@@", $3cc
        ezchat_word "ALGO@@@@", $0c2
        ezchat_word "CHACHI@@", $182
        ezchat_word "MÁS@@@@@", $3a0
        ezchat_word "ME@@@@@@", $3a2
        ezchat_word "Y@@@@@@@", $5ca
        ezchat_word "LOS@@@@@", $372
        ezchat_word "LO@@@@@@", $36c
        ezchat_word "LAS@@@@@", $35c
        ezchat_word "SI@@@@@@", $506
        ezchat_word "MUY@@@@@", $3d2
        ezchat_word "EL@@@@@@", $244
        ezchat_word "E@@@@@@@", $240
        ezchat_word "LA@@@@@@", $35a
        ezchat_word "O SEA@@@", $410
        ezchat_word "CÓMO@@@@", $1ac
        ezchat_word "UNAS@@@@", $58c
        ezchat_word "UNA@@@@@", $58a
        ezchat_word "TÚ MISMO", $57a
        ezchat_word "UN@@@@@@", $588
        ezchat_word "¿HEY?@@@", $084
        ezchat_word "PUES@@@@", $494
        ezchat_word "LES@@@@@", $360
        ezchat_word "NUESTROS", $40a
        ezchat_word "AUNQUE@@", $11e
        ezchat_word "ADEMÁS@@", $0a0
        ezchat_word "CREO QUE", $1e0
        ezchat_word "TUS@@@@@", $580
        ezchat_word "TI@@@@@@", $552
        ezchat_word "TODA@@@@", $564
        ezchat_word "SE@@@@@@", $4de
        ezchat_word "CLARO@@@", $192
        ezchat_word "ALGÚN@@@", $0c6
        ezchat_word "TUYA@@@@", $582
        ezchat_word "ESA@@@@@", $27e
        ezchat_word "NOS@@@@@", $3fc
        ezchat_word "OS@@@@@@", $424
        ezchat_word "ENTONCES", $270
        ezchat_word "TU@@@@@@", $578
        ezchat_word "CASI@@@@", $178
        ezchat_word "SU@@@@@@", $528
        ezchat_word "MÍA@@@@@", $3b0
        ezchat_word "MIS@@@@@", $3bc
        ezchat_word "SUS@@@@@", $52c
        ezchat_word "MÍO@@@@@", $3ba
        ezchat_word "TUYO@@@@", $584
        ezchat_word "SUYO@@@@", $530
.Feelings:
        ezchat_word "ENFADADO", $266
        ezchat_word "ANIMADO@", $0ec
        ezchat_word "ANIMADA@", $0ea
        ezchat_word "MAREADO@", $39c
        ezchat_word "MAREADA@", $39a
        ezchat_word "ALEGRE@@", $0c0
        ezchat_word "FELIZ@@@", $2b8
        ezchat_word "CANSADA@", $16c
        ezchat_word "DÉBIL@@@", $200
        ezchat_word "HOGAREÑO", $328
        ezchat_word "HOGAREÑA", $326
        ezchat_word "FALLIDO@", $2ae
        ezchat_word "TRISTE@@", $576
        ezchat_word "HARTO@@@", $306
        ezchat_word "ATENTO@@", $110
        ezchat_word "ATENTA@@", $10e
        ezchat_word "ARISCO@@", $0fe
        ezchat_word "ARISCA@@", $0fc
        ezchat_word "HAMBRUNA", $304
        ezchat_word "AVERSIÓN", $124
        ezchat_word "PICADO@@", $460
        ezchat_word "ENOJO@@@", $268
        ezchat_word "ALIENADA", $0d4
        ezchat_word "SOLO@@@@", $520
        ezchat_word "SOLA@@@@", $51e
        ezchat_word "TIMORATA", $55e
        ezchat_word "MALDITA@", $388
        ezchat_word "LISTO@@@", $366
        ezchat_word "CANSADO@", $16e
        ezchat_word "AFINIDAD", $0a8
        ezchat_word "ODIA@@@@", $418
        ezchat_word "ABURRIDO", $096
        ezchat_word "ABURRIDA", $094
        ezchat_word "LOCO@@@@", $370
        ezchat_word "LOCA@@@@", $36e
        ezchat_word "DISFRUTA", $22a
        ezchat_word "BUENITO@", $154
        ezchat_word "ATONTADO", $116
        ezchat_word "ASUSTADA", $106
        ezchat_word "ATONTADA", $114
        ezchat_word "MALO@@@@", $38c
        ezchat_word "BORDE@@@", $148
        ezchat_word "DE MÁS@@", $1f8
        ezchat_word "BUENA@@@", $150
        ezchat_word "SEDIENTO", $4e8
        ezchat_word "SEDIENTA", $4e6
        ezchat_word "MIEDOSO@", $3b6
        ezchat_word "HORRIBLE", $32e
        ezchat_word "MIEDOSA@", $3b4
        ezchat_word "HORRENDA", $32c
        ezchat_word "MALÉVOLA", $38a
        ezchat_word "VISCOSO@", $5be
        ezchat_word "CONTENTO", $1c8
        ezchat_word "CONTENTA", $1c6
        ezchat_word "RARO@@@@", $4b4
        ezchat_word "LEGÍTIMO", $35e
        ezchat_word "RARA@@@@", $4b2
        ezchat_word "RIESGOSO", $4ce
        ezchat_word "PELIGRO@", $444
        ezchat_word "INSEGURO", $342
        ezchat_word "AGOTADO@", $0b4
        ezchat_word "AGOTADA@", $0b2
        ezchat_word "COQUETO@", $1cc
        ezchat_word "LLENO@@@", $36a
        ezchat_word "COQUETA@", $1ca
        ezchat_word "SOCIABLE", $51c
        ezchat_word "AGOBIADO", $0b0
        ezchat_word "AGOBIADA", $0ae
        ezchat_word "BUENO@@@", $156
.Conditions:
        ezchat_word "BENÉVOLO", $13e
        ezchat_word "BENÉVOLA", $13c
        ezchat_word "FUERTE@@", $2ce
        ezchat_word "MIEDO@@@", $3b2
        ezchat_word "APURADO@", $0f8
        ezchat_word "ÚNICO@@@", $590
        ezchat_word "ÚNICA@@@", $58e
        ezchat_word "MENDA@@@", $3a6
        ezchat_word "RAUDA@@@", $4b6
        ezchat_word "RAUDO@@@", $4b8
        ezchat_word "FURIA@@@", $2d8
        ezchat_word "CERTERO@", $180
        ezchat_word "CERTERA@", $17e
        ezchat_word "FUERTES@", $2d0
        ezchat_word "SAGAZ@@@", $4d8
        ezchat_word "GENIAL@@", $2e6
        ezchat_word "CORDIAL@", $1ce
        ezchat_word "MAÑOSO@@", $396
        ezchat_word "MAÑOSA@@", $394
        ezchat_word "ASTUTA@@", $104
        ezchat_word "ENCANTOS", $25e
        ezchat_word "PACIENTE", $42a
        ezchat_word "GRACIOSO", $2f4
        ezchat_word "GRACIOSA", $2f2
        ezchat_word "CARISMA@", $176
        ezchat_word "DULZURA@", $23e
        ezchat_word "PERFECTO", $458
        ezchat_word "SERENO@@", $502
        ezchat_word "SERENA@@", $500
        ezchat_word "ALIENADO", $0d6
        ezchat_word "FLAMANTE", $2c2
        ezchat_word "SEGURO@@", $4ec
        ezchat_word "SEGURA@@", $4ea
        ezchat_word "TENAZ@@@", $54a
        ezchat_word "AMABLE@@", $0de
        ezchat_word "PRUDENTE", $48a
        ezchat_word "RESPONS.", $4ca
        ezchat_word "DISCRETO", $228
        ezchat_word "VALE@@@@", $59a
        ezchat_word "DISCRETA", $226
        ezchat_word "CORRECTA", $1d2
        ezchat_word "CORRECTO", $1d4
        ezchat_word "MODERADO", $3c4
        ezchat_word "MODERADA", $3c2
        ezchat_word "VIGOROSO", $5bc
        ezchat_word "RÁPIDO@@", $4b0
        ezchat_word "SENSIBLE", $4f8
        ezchat_word "FOGOSO@@", $2c6
        ezchat_word "CALLADO@", $164
        ezchat_word "CALLADA@", $162
        ezchat_word "CAPAZ@@@", $172
        ezchat_word "PENSADOR", $44a
        ezchat_word "SUPER@@@", $52a
        ezchat_word "ENÉRGICO", $262
        ezchat_word "ENÉRGICA", $260
        ezchat_word "SENSATO@", $4f6
        ezchat_word "SENSATA@", $4f4
        ezchat_word "EXTRAÑO@", $2aa
        ezchat_word "VELOZ@@@", $59e
        ezchat_word "ÁGIL@@@@", $0ac
        ezchat_word "EVASIVO@", $2a4
        ezchat_word "EVASIVA@", $2a2
        ezchat_word "SENCILLO", $4f2
        ezchat_word "SENCILLA", $4f0
        ezchat_word "AMENA@@@", $0e0
        ezchat_word "AMENO@@@", $0e2
.Life:
        ezchat_word "RUTINA@@", $4d4
        ezchat_word "HOGAR@@@", $324
        ezchat_word "DINERO@@", $224
        ezchat_word "AHORROS@", $0ba
        ezchat_word "BAÑO@@@@", $132
        ezchat_word "COLEGIO@", $19e
        ezchat_word "RECUERDA", $4c2
        ezchat_word "GRUPO@@@", $2f8
        ezchat_word "HAZTE@@@", $30e
        ezchat_word "CANJEAR@", $16a
        ezchat_word "TRABAJO@", $572
        ezchat_word "METRO@@@", $3ae
        ezchat_word "CLASES@@", $194
        ezchat_word "DEBERES@", $1fc
        ezchat_word "EVOLUC.@", $2a6
        ezchat_word "CUADERNO", $1e6
        ezchat_word "MERENDAR", $3aa
        ezchat_word "PROFESOR", $484
        ezchat_word "CENTRO@@", $17c
        ezchat_word "TORRE@@@", $56c
        ezchat_word "CONEXIÓN", $1b4
        ezchat_word "EXÁMENES", $2a8
        ezchat_word "TV@@@@@@", $586
        ezchat_word "TELÉFONO", $548
        ezchat_word "RECREO@@", $4c0
        ezchat_word "CAMBIA@@", $166
        ezchat_word "DUCHARSE", $23a
        ezchat_word "NOTICIAS", $402
        ezchat_word "CINE@@@@", $190
        ezchat_word "FESTIVO@", $2ba
        ezchat_word "ESTUDIOS", $29e
        ezchat_word "COCHES@@", $196
        ezchat_word "TARJETA@", $53c
        ezchat_word "MENSAJE@", $3a8
        ezchat_word "RENOVAR@", $4c6
        ezchat_word "AULA@@@@", $11a
        ezchat_word "PISCINA@", $468
        ezchat_word "RADIO@@@", $4ae
        ezchat_word "MUNDO@@@", $3ce
.Hobbies:
        ezchat_word "ÍDOLO@@@", $336
        ezchat_word "DORMIR@@", $234
        ezchat_word "CANTAR@@", $170
        ezchat_word "PELÍCULA", $442
        ezchat_word "CHUCHE@@", $18a
        ezchat_word "CHATEAR@", $184
        ezchat_word "JUEGO@@@", $352
        ezchat_word "JUGUETES", $358
        ezchat_word "MÚSICA@@", $3d0
        ezchat_word "TARJETAS", $53e
        ezchat_word "COMPRAS@", $1b0
        ezchat_word "GOURMET@", $2ec
        ezchat_word "CAJA@@@@", $160
        ezchat_word "REVISTAS", $4cc
        ezchat_word "PASEAR@@", $43c
        ezchat_word "CICLISMO", $18c
        ezchat_word "ESTUDIAR", $29c
        ezchat_word "DEPORTES", $20c
        ezchat_word "COCINAR@", $198
        ezchat_word "DARDOS@@", $1f4
        ezchat_word "VIAJAR@@", $5b6
        ezchat_word "BAILAR@@", $130
        ezchat_word "PESCAR@@", $45e
        ezchat_word "FECHA@@@", $2b6
        ezchat_word "TRENES@@", $574
        ezchat_word "PELUCHE@", $448
        ezchat_word "PC@@@@@@", $43e
        ezchat_word "FLORES@@", $2c4
        ezchat_word "HÉROE@@@", $318
        ezchat_word "SIESTA@@", $512
        ezchat_word "HEROÍNA@", $31a
        ezchat_word "AVENTURA", $122
        ezchat_word "TABLA@@@", $532
        ezchat_word "PELOTA@@", $446
        ezchat_word "LIBROS@@", $364
        ezchat_word "MANGA@@@", $392
        ezchat_word "PARQUE@@", $436
        ezchat_word "FIESTA@@", $2bc
        ezchat_word "MAQUETAS", $398
.Actions:
        ezchat_word "CONOCE@@", $1c0
        ezchat_word "ADMITO@@", $0a2
        ezchat_word "DOY@@@@@", $236
        ezchat_word "DAR@@@@@", $1f2
        ezchat_word "JUGADO@@", $356
        ezchat_word "HE@@@@@@", $310
        ezchat_word "RECOLEC.", $4be
        ezchat_word "NADAR@@@", $3d6
        ezchat_word "FUNCIONA", $2d6
        ezchat_word "FUE@@@@@", $2ca
        ezchat_word "ADELANTE", $09e
        ezchat_word "DESPERT.", $212
        ezchat_word "DESPERTÓ", $214
        ezchat_word "ENFADA@@", $264
        ezchat_word "ENSEÑO@@", $26e
        ezchat_word "ENSEÑAS@", $26c
        ezchat_word "CRIAR@@@", $1e2
        ezchat_word "APRENDO@", $0f6
        ezchat_word "CAMBIO@@", $168
        ezchat_word "CONFÍO@@", $1b8
        ezchat_word "ESCUCHAR", $284
        ezchat_word "ENTRENA@", $274
        ezchat_word "ELIJO@@@", $24a
        ezchat_word "VENGO@@@", $5aa
        ezchat_word "BUSCO@@@", $15e
        ezchat_word "CAUSAR@@", $17a
        ezchat_word "ESTOS@@@", $298
        ezchat_word "CONOZCO@", $1c4
        ezchat_word "ATAÑIDO@", $10a
        ezchat_word "RECHAZO@", $4bc
        ezchat_word "GUARDAR@", $2fa
        ezchat_word "DENOTA@@", $20a
        ezchat_word "IGNORO@@", $338
        ezchat_word "PIENSA@@", $464
        ezchat_word "PENSAR@@", $44c
        ezchat_word "RESBALAR", $4c8
        ezchat_word "COME@@@@", $1a4
        ezchat_word "USO@@@@@", $596
        ezchat_word "USA@@@@@", $592
        ezchat_word "USAR@@@@", $594
        ezchat_word "NO PODÍA", $3f2
        ezchat_word "SIENTES@", $510
        ezchat_word "SE PIRÓ@", $4e0
        ezchat_word "APARECER", $0f2
        ezchat_word "ARROJAR@", $100
        ezchat_word "INQUIETO", $340
        ezchat_word "DORMIDO@", $232
        ezchat_word "DUERMO@@", $23c
        ezchat_word "SIENTE@@", $50e
        ezchat_word "BEBER@@@", $13a
        ezchat_word "CORRE@@@", $1d0
        ezchat_word "CORRER@@", $1d6
        ezchat_word "TRABAJA@", $56e
        ezchat_word "TRABAJAR", $570
        ezchat_word "QUERER@@", $4a4
        ezchat_word "GOLPEAR@", $2ea
        ezchat_word "TIENE@@@", $556
        ezchat_word "CONGELAR", $1bc
        ezchat_word "QUIERE@@", $4a8
        ezchat_word "OBSERVAR", $414
        ezchat_word "BUSCAR@@", $15c
        ezchat_word "ATRAPAR@", $118
        ezchat_word "PARALIZ.", $432
        ezchat_word "CONFUND.", $1ba
        ezchat_word "ENVENEN.", $278
        ezchat_word "ENTRENAR", $276
        ezchat_word "CURAR@@@", $1ee
        ezchat_word "VENCER@@", $5a2
        ezchat_word "PIERDO@@", $466
.Time:
        ezchat_word "OTOÑO@@@", $426
        ezchat_word "MAÑANAS@", $390
        ezchat_word "MAÑANA@@", $38e
        ezchat_word "DÍA@@@@@", $21a
        ezchat_word "OTRO DÍA", $428
        ezchat_word "SIEMPRE@", $50c
        ezchat_word "ACTUAL@@", $09c
        ezchat_word "NUNCA@@@", $40c
        ezchat_word "DÍAS@@@@", $21e
        ezchat_word "FIN@@@@@", $2be
        ezchat_word "MARTES@@", $39e
        ezchat_word "AYER@@@@", $12a
        ezchat_word "HOY@@@@@", $330
        ezchat_word "VIERNES@", $5ba
        ezchat_word "LUNES@@@", $37c
        ezchat_word "DESPUÉS@", $216
        ezchat_word "ANTES@@@", $0f0
        ezchat_word "JAMÁS@@@", $348
        ezchat_word "HORA@@@@", $32a
        ezchat_word "DÉCADA@@", $204
        ezchat_word "MIÉRC.@@", $3b8
        ezchat_word "COMIENZO", $1a8
        ezchat_word "MES@@@@@", $3ac
        ezchat_word "ACABAR@@", $098
        ezchat_word "AHORA@@@", $0b8
        ezchat_word "FINAL@@@", $2c0
        ezchat_word "PRÓXIMO@", $488
        ezchat_word "SÁBADO@@", $4d6
        ezchat_word "VERANO@@", $5b0
        ezchat_word "DOMINGO@", $22e
        ezchat_word "INICIO@@", $33e
        ezchat_word "PRIMAV.@", $480
        ezchat_word "DIURNO@@", $22c
        ezchat_word "INVIERNO", $346
        ezchat_word "DIARIO@@", $21c
        ezchat_word "JUEVES@@", $354
        ezchat_word "NOCTURNO", $3f8
        ezchat_word "NOCHE@@@", $3f6
        ezchat_word "SEMANA@@", $4ee
.Farewells:
        ezchat_word "HAS@@@@@", $308
        ezchat_word "ESTOY@@@", $29a
        ezchat_word "QUÉ PLAN", $49e
        ezchat_word "¿MM?@@@@", $086
        ezchat_word "¿SÍ?@@@@", $08a
        ezchat_word "DEVORA@@", $218
        ezchat_word "SER@@@@@", $4fc
        ezchat_word "SEAS@@@@", $4e4
        ezchat_word "DIME@@@@", $222
        ezchat_word "VER@@@@@", $5ae
        ezchat_word "QUEDAR@@", $4a2
        ezchat_word "ES@@@@@@", $27c
        ezchat_word "SOY@@@@@", $524
        ezchat_word "ERES@@@@", $27a
        ezchat_word "SERVIRÁ@", $504
        ezchat_word "ESTÁS@@@", $290
        ezchat_word "SON@@@@@", $522
        ezchat_word "SERÁ@@@@", $4fe
        ezchat_word "DICEN@@@", $220
        ezchat_word "ESPERO@@", $28a
        ezchat_word "NO SERÁ@", $3f4
        ezchat_word "PUEDES@@", $490
        ezchat_word "PUEDO@@@", $492
        ezchat_word "NI@@@@@@", $3de
        ezchat_word "HAZ@@@@@", $30c
        ezchat_word "SÉ@@@@@@", $4e2
        ezchat_word "TENGO@@@", $54e
        ezchat_word "FALTA@@@", $2b0
        ezchat_word "COMER@@@", $1a6
        ezchat_word "PUEDE@@@", $48e
        ezchat_word "TIENES@@", $558
        ezchat_word "TE FALTA", $542
        ezchat_word "NECESITO", $3dc
        ezchat_word "TENER@@@", $54c
        ezchat_word "PONGAS@@", $476
        ezchat_word "ADORAMOS", $0a4
        ezchat_word "CREO@@@@", $1de
        ezchat_word "CORRIDO@", $1d8
        ezchat_word "TAL VEZ@", $536
        ezchat_word "EMPEZAR@", $256
        ezchat_word "PODRÁS@@", $46e
        ezchat_word "GUSTAN@@", $300
        ezchat_word "LLEGAN@@", $368
        ezchat_word "DEBERÍA@", $1fe
        ezchat_word "PRÉSTAME", $47c
        ezchat_word "PODRÍAS@", $470
        ezchat_word "UTILIZA@", $598
        ezchat_word "CUIDAS@@", $1ec
        ezchat_word "VEO@@@@@", $5ac
        ezchat_word "EMOCIONA", $254
        ezchat_word "QUIERO@@", $4aa
        ezchat_word "HACERME@", $302
        ezchat_word "HAY@@@@@", $30a
        ezchat_word "CREAS@@@", $1dc
        ezchat_word "ESCUCHA@", $282
        ezchat_word "DECIDAN@", $206
        ezchat_word "OBSERVA@", $412
        ezchat_word "GUSTA@@@", $2fe
        ezchat_word "PARECE@@", $434
        ezchat_word "DA@@@@@@", $1f0
        ezchat_word "EVANECE@", $2a0
        ezchat_word "BUSCANDO", $15a
        ezchat_word "VEN@@@@@", $5a0
        ezchat_word "ESPABILA", $288
        ezchat_word "PASARLO@", $43a
        ezchat_word "CONFÍA@@", $1b6
.ThisAndThat:
        ezchat_word "INFANTIL", $33c
        ezchat_word "JOVEN@@@", $34e
        ezchat_word "BASTA@@@", $134
        ezchat_word "TIERNOS@", $55a
        ezchat_word "COSAS@@@", $1da
        ezchat_word "BIEN@@@@", $142
        ezchat_word "A VER@@@", $08e
        ezchat_word "PREFIERO", $47a
        ezchat_word "AQUÍ@@@@", $0fa
        ezchat_word "AÚN@@@@@", $11c
        ezchat_word "QUIZÁ@@@", $4ac
        ezchat_word "EN FORMA", $25a
        ezchat_word "ESTE@@@@", $292
        ezchat_word "ESTO@@@@", $296
        ezchat_word "TAN@@@@@", $53a
        ezchat_word "VERDAD@@", $5b2
        ezchat_word "QUÉ@@@@@", $4a0
        ezchat_word "EMOCIÓN@", $252
        ezchat_word "GANAS@@@", $2e2
        ezchat_word "PIEL@@@@", $462
        ezchat_word "ESO ES@@", $286
        ezchat_word "PARTES@@", $438
        ezchat_word "ATENCIÓN", $10c
        ezchat_word "SÍ@@@@@@", $50a
        ezchat_word "YA@@@@@@", $5cc
        ezchat_word "NUESTRAS", $408
        ezchat_word "NATURAL@", $3da
        ezchat_word "CONMIGO@", $1be
        ezchat_word "NO@@@@@@", $3f0
        ezchat_word "CUANDO@@", $1e8
        ezchat_word "ESTILO@@", $294
        ezchat_word "MISMO@@@", $3be
        ezchat_word "ENORME@@", $26a
        ezchat_word "FORMA@@@", $2c8
        ezchat_word "IGUAL@@@", $33a
        ezchat_word "BAILA@@@", $12e

MobileEZChatData_WordAndPageCounts:
MACRO macro_11f220
; parameter: number of words
	db \1
; 12 words per page (0-based indexing)
	DEF x = \1 / (EZCHAT_WORD_COUNT * 2) ; 12 MENU_WIDTH to 8
	if \1 % (EZCHAT_WORD_COUNT * 2) == 0 ; 12 MENU_WIDTH to 8
		DEF x = x + -1
	endc
	db x
ENDM
	macro_11f220 18 ; 01: Types
	macro_11f220 36 ; 02: Greetings
	macro_11f220 69 ; 03: People
	macro_11f220 69 ; 04: Battle
	macro_11f220 66 ; 05: Exclamations
	macro_11f220 66 ; 06: Conversation
	macro_11f220 69 ; 07: Feelings
	macro_11f220 66 ; 08: Conditions
	macro_11f220 39 ; 09: Life
	macro_11f220 39 ; 0a: Hobbies
	macro_11f220 69 ; 0b: Actions
	macro_11f220 39 ; 0c: Time
	macro_11f220 66 ; 0d: Farewells
	macro_11f220 36 ; 0e: ThisAndThat

EZChat_SortedWords:
; Addresses in WRAM bank 3 where EZChat words beginning
; with the given kana are sorted in memory, and the pre-
; allocated size for each.
; These arrays are expanded dynamically to accomodate
; any Pokemon you've seen that starts with each kana.
MACRO macro_11f23c
	dw x - w3_d000, \1
	DEF x = x + 2 * \1
ENDM
DEF x = $d08c
	macro_11f23c  81 ; A
	macro_11f23c  25 ; B
	macro_11f23c  72 ; C
	macro_11f23c  40 ; D
	macro_11f23c  54 ; E
	macro_11f23c  23 ; F
	macro_11f23c  20 ; G
	macro_11f23c  26 ; H
	macro_11f23c   9 ; I
	macro_11f23c   9 ; J
	macro_11f23c   0 ; K
	macro_11f23c  18 ; L
	macro_11f23c  43 ; M
	macro_11f23c  29 ; N
	macro_11f23c  14 ; O
	macro_11f23c  55 ; P
	macro_11f23c  11 ; Q
	macro_11f23c  20 ; R
	macro_11f23c  46 ; S
	macro_11f23c  43 ; T
	macro_11f23c  9  ; U
	macro_11f23c  24 ; V
	macro_11f23c  0  ; W
	macro_11f23c  0  ; X
	macro_11f23c  6  ; Y
	macro_11f23c  0  ; Z
DEF x = $d000
	macro_11f23c  70 ; !?
.End
