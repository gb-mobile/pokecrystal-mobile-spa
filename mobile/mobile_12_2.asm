MobileCheckOwnMonAnywhere:
; Like CheckOwnMonAnywhere, but only checks for species.
; OT/ID don't matter.

; inputs:
; [wScriptVar] should contain the species we're looking for.

; outputs:
; sets carry if monster matches species.

	; If there are no monsters in the party,
	; the player must not own any yet.

	ld a, [wPartyCount]
	and a
	ret z

	ld d, a
	ld e, 0
	ld hl, wPartyMon1Species
	ld bc, wPartyMonOTs

	; Run .CheckMatch on each Pokémon in the party.

.partymon
	call .CheckMatch
	ret c

	push bc
	ld bc, PARTYMON_STRUCT_LENGTH
	add hl, bc
	pop bc
	call .AdvanceOTName
	dec d
	jr nz, .partymon

	; Run .CheckMatch on each Pokémon in the PC.

	ld a, BANK(sBoxCount)
	call OpenSRAM
	ld a, [sBoxCount]
	and a
	jr z, .boxes

	ld d, a
	ld hl, sBoxMon1Species
	ld bc, sBoxMonOTs
.openboxmon
	call .CheckMatch
	jr nc, .loop

	call CloseSRAM
	ret

.loop
	push bc
	ld bc, BOXMON_STRUCT_LENGTH
	add hl, bc
	pop bc
	call .AdvanceOTName
	dec d
	jr nz, .openboxmon

	; Run .CheckMatch on each monster in the other 13 PC boxes.

.boxes
	call CloseSRAM

	ld c, 0
.box
	; Don't search the current box again.
	ld a, [wCurBox]
	and $f
	cp c
	jr z, .loopbox

	; Load the box.

	ld hl, .BoxAddresses
	ld b, 0
	add hl, bc
	add hl, bc
	add hl, bc
	ld a, [hli]
	call OpenSRAM
	ld a, [hli]
	ld h, [hl]
	ld l, a

	; Number of monsters in the box

	ld a, [hl]
	and a
	jr z, .loopbox

	push bc

	push hl
	ld de, sBoxMons - sBoxCount
	add hl, de
	ld d, h
	ld e, l
	pop hl
	push de
	ld de, sBoxMonOTs - sBoxCount
	add hl, de
	ld b, h
	ld c, l
	pop hl

	ld d, a

.boxmon
	call .CheckMatch
	jr nc, .loopboxmon

	pop bc
	call CloseSRAM
	ret

.loopboxmon
	push bc
	ld bc, BOXMON_STRUCT_LENGTH
	add hl, bc
	pop bc
	call .AdvanceOTName
	dec d
	jr nz, .boxmon
	pop bc

.loopbox
	inc c
	ld a, c
	cp NUM_BOXES
	jr c, .box

	call CloseSRAM
	and a
	ret

.CheckMatch:
	; Check if a Pokémon is of a specific species.
	; We compare the species we are looking for in
	; [wScriptVar] to the species we have in [hl].
	; Sets carry flag if species matches.

	push bc
	push hl
	push de
	ld d, b
	ld e, c

	; check species

	ld a, [wScriptVar]
	ld b, [hl]
	cp b
	jr nz, .no_match
	jr .match

.no_match
	pop de
	pop hl
	pop bc
	and a
	ret

.match
	pop de
	pop hl
	pop bc
	scf
	ret

.BoxAddresses:
	table_width 3, MobileCheckOwnMonAnywhere.BoxAddresses
for n, 1, NUM_BOXES + 1
	dba sBox{d:n}
endr
	assert_table_length NUM_BOXES

.AdvanceOTName:
	push hl
	ld hl, NAME_LENGTH
	add hl, bc
	ld b, h
	ld c, l
	pop hl
	ret

UnusedFindItemInPCOrBag:
	ld a, [wScriptVar]
	ld [wCurItem], a
	ld hl, wNumPCItems
	call CheckItem
	jr c, .found

	ld a, [wScriptVar]
	ld [wCurItem], a
	ld hl, wNumItems
	call CheckItem
	jr c, .found

	xor a
	ld [wScriptVar], a
	ret

.found
	ld a, 1
	ld [wScriptVar], a
	ret

Function4a94e:
	call FadeToMenu
	ld a, -1
	ld hl, wd002
	ld bc, 3
	call ByteFill
	xor a
	ld [wd018], a
	ld [wd019], a
	ld b, SCGB_PACKPALS
	call GetSGBLayout
	call SetPalettes
	call Function4aa22
	jr c, .asm_4a985
	jr z, .asm_4a9a1
	jr .asm_4a97b

.asm_4a974
	call Function4aa25
	jr c, .asm_4a985
	jr z, .asm_4a9a1

.asm_4a97b
	call Function4ac58
	ld hl, wd019
	res 1, [hl]
	jr .asm_4a974

.asm_4a985
	ld a, [wd018]
	and a
	jr nz, .asm_4a990
	call Function4aba8
	jr c, .asm_4a974

.asm_4a990
	call CloseSubmenu
	ld hl, wd002
	ld a, -1
	ld bc, 3
	call ByteFill
	scf
	jr .asm_4a9af

.asm_4a9a1
	call Function4a9c3
	jr c, .asm_4a9b0
	call Function4a9d7
	jr c, .asm_4a974
	call CloseSubmenu
	and a

.asm_4a9af
	ret

.asm_4a9b0
	ld de, SFX_WRONG
	call PlaySFX
	ld hl, MobilePickThreeMonForBattleText
	call PrintText
	jr .asm_4a974

MobilePickThreeMonForBattleText:
	text_far _MobilePickThreeMonForBattleText
	text_end

Function4a9c3:
	ld hl, wd002
	ld a, $ff
	cp [hl]
	jr z, .asm_4a9d5
	inc hl
	cp [hl]
	jr z, .asm_4a9d5
	inc hl
	cp [hl]
	jr z, .asm_4a9d5
	and a
	ret

.asm_4a9d5
	scf
	ret

Function4a9d7:
	ld a, [wd002]
	ld hl, wPartyMonNicknames
	call GetNickname
	ld h, d
	ld l, e
	ld de, wMobileParticipant1Nickname ;wd006
	ld bc, NAME_LENGTH ;6
	call CopyBytes
	ld a, [wd003]
	ld hl, wPartyMonNicknames
	call GetNickname
	ld h, d
	ld l, e
	ld de, wMobileParticipant2Nickname ;wd00c
	ld bc, NAME_LENGTH ;6
	call CopyBytes
	ld a, [wd004]
	ld hl, wPartyMonNicknames
	call GetNickname
	ld h, d
	ld l, e
	ld de, wMobileParticipant3Nickname ;wd012
	ld bc, NAME_LENGTH ;6
	call CopyBytes
	ld hl, MobileUseTheseThreeMonText
	call PrintText
	call YesNoBox
	ret

MobileUseTheseThreeMonText:
	text_far _MobileUseTheseThreeMonText
	text_end

Function4aa22:
	call ClearBGPalettes

Function4aa25:
	farcall LoadPartyMenuGFX
	farcall InitPartyMenuWithCancel
	call Function4aad3

Function4aa34:
	ld a, PARTYMENUACTION_MOBILE
	ld [wPartyMenuActionText], a
	farcall WritePartyMenuTilemap
	xor a
	ld [wPartyMenuActionText], a
	farcall PrintPartyMenuText
	call Function4aab6
	call WaitBGMap
	call SetPalettes
	call DelayFrame
	call Function4ab1a
	jr z, .asm_4aa66
	push af
	call Function4aafb
	jr c, .asm_4aa67
	call Function4ab06
	jr c, .asm_4aa67
	pop af

.asm_4aa66
	ret

.asm_4aa67
	ld hl, wd019
	set 1, [hl]
	pop af
	ret

Function4aa6e: ; unreferenced
	pop af
	ld de, SFX_WRONG
	call PlaySFX
	call WaitSFX
	jr Function4aa34

Function4aa7a:
	ld hl, wd002
	ld d, $3
.loop
	ld e, PARTY_LENGTH
	ld a, [hli]
	push de
	push hl
	cp -1
	jr z, .done
	ld hl, wSpriteAnimationStructs
	inc a
	ld d, a
.inner_loop
	ld a, [hl]
	and a
	jr z, .next
	cp d
	jr z, .same_as_d
	jr .next

	ld a, $3
	jr .proceed

.same_as_d
	ld a, $2

.proceed
	push hl
	ld c, l
	ld b, h
	ld hl, $2
	add hl, bc
	ld [hl], a
	pop hl

.next
	ld bc, $10
	add hl, bc
	dec e
	jr nz, .inner_loop
	pop hl
	pop de
	dec d
	jr nz, .loop
	jr .finished

.done
	pop hl
	pop de

.finished
	ret

Function4aab6:
	ld hl, wd002
	ld d, $3
.loop
	ld a, [hli]
	cp -1
	jr z, .done
	push de
	push hl
	hlcoord 0, 1
	ld bc, $28
	call AddNTimes
	ld [hl], $ec
	pop hl
	pop de
	dec d
	jr nz, .loop

.done
	ret

Function4aad3:
	ld hl, wPartyCount
	ld a, [hli]
	and a
	ret z ; Nothing in your party

	ld c, a
	xor a
	ldh [hObjectStructIndex], a
.loop
	push bc
	push hl
	ld e, MONICON_PARTYMENU
	farcall LoadMenuMonIcon
	ldh a, [hObjectStructIndex]
	inc a
	ldh [hObjectStructIndex], a
	pop hl
	pop bc
	dec c
	jr nz, .loop

	call Function4aa7a
	farcall PlaySpriteAnimations
	ret

Function4aafb:
	ld a, [wCurPartySpecies]
	cp EGG
	jr z, .egg
	and a
	ret

.egg
	scf
	ret

Function4ab06:
	ld a, [wCurPartyMon]
	ld bc, PARTYMON_STRUCT_LENGTH
	ld hl, wPartyMon1HP
	call AddNTimes
	ld a, [hli]
	ld b, a
	ld a, [hl]
	or b
	jr nz, .NotFainted
	scf

.NotFainted:
	ret

Function4ab1a:
.asm_4ab1a
	ld a, $fb
	ld [wMenuJoypadFilter], a
	ld a, $24
	ld [w2DMenuCursorOffsets], a
	ld a, $2
	ld [w2DMenuNumCols], a
	call Function4adf7
	call StaticMenuJoypad
	call Function4abc3
	jr c, .asm_4ab1a
	push af
	call Function4ab99
	call nc, PlaceHollowCursor
	pop af
	bit 1, a
	jr nz, .asm_4ab6d
	ld a, [wPartyCount]
	inc a
	ld b, a
	ld a, [wMenuCursorY]
	ld [wPartyMenuCursor], a
	cp b
	jr z, .asm_4ab7e
	ld a, [wMenuCursorY]
	dec a
	ld [wCurPartyMon], a
	ld c, a
	ld b, 0
	ld hl, wPartySpecies
	add hl, bc
	ld a, [hl]
	ld [wCurPartySpecies], a
	ld de, SFX_READ_TEXT_2
	call PlaySFX
	call WaitSFX
	ld a, $1
	and a
	ret

.asm_4ab6d
	ld a, [wMenuCursorY]
	ld [wPartyMenuCursor], a
.asm_4ab73
	ld de, SFX_READ_TEXT_2
	call PlaySFX
	call WaitSFX
	scf
	ret

.asm_4ab7e
	ld a, $1
	ld [wd018], a
	ld a, [wMenuCursorX]
	cp $2
	jr z, .asm_4ab73
	ld de, SFX_READ_TEXT_2
	call PlaySFX
	call WaitSFX
	xor a
	ld [wd018], a
	and a
	ret

Function4ab99:
	bit 1, a
	jr z, .asm_4aba6
	ld a, [wd002]
	cp $ff
	jr z, .asm_4aba6
	scf
	ret

.asm_4aba6
	and a
	ret

Function4aba8:
	ld hl, wd004
	ld a, [hl]
	cp $ff
	jr nz, .asm_4abbe
	dec hl
	ld a, [hl]
	cp $ff
	jr nz, .asm_4abbe
	dec hl
	ld a, [hl]
	cp $ff
	jr nz, .asm_4abbe
	and a
	ret

.asm_4abbe
	ld a, $ff
	ld [hl], a
	scf
	ret

Function4abc3:
	bit 3, a
	jr z, .asm_4abd5
	ld a, [wPartyCount]
	inc a
	ld [wMenuCursorY], a
	ld a, $1
	ld [wMenuCursorX], a
	jr .asm_4ac29

.asm_4abd5
	bit 6, a
	jr z, .asm_4abeb
	ld a, [wMenuCursorY]
	ld [wMenuCursorY], a
	and a
	jr nz, .asm_4ac29
	ld a, [wPartyCount]
	inc a
	ld [wMenuCursorY], a
	jr .asm_4ac29

.asm_4abeb
	bit 7, a
	jr z, .asm_4ac08
	ld a, [wMenuCursorY]
	ld [wMenuCursorY], a
	ld a, [wPartyCount]
	inc a
	inc a
	ld b, a
	ld a, [wMenuCursorY]
	cp b
	jr nz, .asm_4ac29
	ld a, $1
	ld [wMenuCursorY], a
	jr .asm_4ac29

.asm_4ac08
	bit 4, a
	jr nz, .asm_4ac10
	bit 5, a
	jr z, .asm_4ac56

.asm_4ac10
	ld a, [wMenuCursorY]
	ld b, a
	ld a, [wPartyCount]
	inc a
	cp b
	jr nz, .asm_4ac29
	ld a, [wMenuCursorX]
	cp $1
	jr z, .asm_4ac26
	ld a, $1
	jr .asm_4ac29

.asm_4ac26
	ld [wMenuCursorX], a

.asm_4ac29
	hlcoord 0, 1
	lb bc, 13, 1
	call ClearBox
	call Function4aab6
	ld a, [wPartyCount]
	hlcoord 4, 1
.asm_4ac3b
	ld bc, $28
	add hl, bc
	dec a
	jr nz, .asm_4ac3b
	ld [hl], $7f
	ld a, [wMenuCursorY]
	ld b, a
	ld a, [wPartyCount]
	inc a
	cp b
	jr z, .asm_4ac54
	ld a, $1
	ld [wMenuCursorX], a

.asm_4ac54
	scf
	ret

.asm_4ac56
	and a
	ret

Function4ac58:
	lb bc, 2, 18
	hlcoord 1, 15
	call ClearBox
	farcall FreezeMonIcons
	ld hl, MenuHeader_0x4aca2
	call LoadMenuHeader
	ld hl, wd019
	bit 1, [hl]
	jr z, .asm_4ac89
	hlcoord 11, 13
	ld b, $3
	ld c, $7
	call Textbox
	hlcoord 13, 14
	ld de, String_4ada7
	call PlaceString
	jr .asm_4ac96

.asm_4ac89
	hlcoord 8, 9;11, 9
	ld b, $7
	ld c, $a;$7
	call Textbox
	call Function4ad68

.asm_4ac96
	ld a, $1
	ldh [hBGMapMode], a
	call Function4acaa
	call ExitMenu
	and a
	ret

MenuHeader_0x4aca2:
	db MENU_BACKUP_TILES ; flags
	menu_coords 9, 9, SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1;11, 9, SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1
	dw NULL
	db 1 ; default option

Function4acaa:
.asm_4acaa
	ld a, $a0
	ld [wMenuDataFlags], a
	ld a, [wd019]
	bit 1, a
	jr z, .asm_4acc2
	ld a, $2
	ld [wMenuDataItems], a
	ld a, $c
	ld [wMenuBorderTopCoord], a
	ld a, $b
	ld [wMenuBorderLeftCoord], a
	jr .asm_4accc

.asm_4acc2
	ld a, $4
	ld [wMenuDataItems], a
	ld a, $8
	ld [wMenuBorderTopCoord], a
	ld a, $8;$b
	ld [wMenuBorderLeftCoord], a

.asm_4accc
	;ld a, $b
	;ld [wMenuBorderLeftCoord], a
	ld a, $1
	ld [wMenuCursorPosition], a
	call InitVerticalMenuCursor
	ld hl, w2DMenuFlags1
	set 6, [hl]
	call StaticMenuJoypad
	ld de, SFX_READ_TEXT_2
	call PlaySFX
	ldh a, [hJoyPressed]
	bit 0, a
	jr nz, .asm_4acf4
	bit 1, a
	jr nz, .asm_4acf3
	jr .asm_4acaa

.asm_4acf3
	ret

.asm_4acf4
	ld a, [wd019]
	bit 1, a
	jr nz, .asm_4ad0e
	ld a, [wMenuCursorY]
	cp $1
	jr z, Function4ad17
	cp $2
	jp z, Function4ad56
	cp $3
	jp z, Function4ad60
	jr .asm_4acf3

.asm_4ad0e
	ld a, [wMenuCursorY]
	cp $1
	jr z, Function4ad56
	jr .asm_4acf3

Function4ad17:
	call Function4adb2
	jr z, .asm_4ad4a
	ld hl, wd002
	ld a, $ff
	cp [hl]
	jr z, .asm_4ad39
	inc hl
	cp [hl]
	jr z, .asm_4ad39
	inc hl
	cp [hl]
	jr z, .asm_4ad39
	ld de, SFX_WRONG
	call WaitPlaySFX
	ld hl, MobileOnlyThreeMonMayEnterText
	call PrintText
	ret

.asm_4ad39
	ld a, [wCurPartyMon]
	ld [hl], a
	call Function4a9c3
	ret c
	ld a, [wd019]
	set 0, a
	ld [wd019], a
	ret

.asm_4ad4a
	ld a, $ff
	ld [hl], a
	call Function4adc2
	ret

MobileOnlyThreeMonMayEnterText:
	text_far _MobileOnlyThreeMonMayEnterText
	text_end

Function4ad56:
	farcall OpenPartyStats
	call WaitBGMap2
	ret

Function4ad60:
	farcall ManagePokemonMoves
	ret

Function4ad67: ; unreferenced
	ret

Function4ad68:
	hlcoord 10, 12;13, 12
	ld de, String_4ad88
	call PlaceString
	call Function4adb2
	jr c, .asm_4ad7e
	hlcoord 10, 10;13, 10
	ld de, String_4ada0
	jr .asm_4ad84

.asm_4ad7e
	hlcoord 10, 10;13, 10
	ld de, String_4ad9a

.asm_4ad84
	call PlaceString
	ret

String_4ad88:
	db   "ESTAD.";"つよさをみる"
	next "MOVER";"つかえるわざ"
	next "SALIR@";"もどる@"

String_4ad9a:
	db   "ENTRAR@";"さんかする@"

String_4ada0:
	db   "NO ENTRAR@";"さんかしない@"

String_4ada7:
	db   "ESTAD.";"つよさをみる"
	next "SALIR@";"もどる@" ; BACK

Function4adb2:
	ld hl, wd002
	ld a, [wCurPartyMon]
	cp [hl]
	ret z
	inc hl
	cp [hl]
	ret z
	inc hl
	cp [hl]
	ret z
	scf
	ret

Function4adc2:
	ld a, [wd002]
	cp $ff
	jr nz, .skip
	ld a, [wd003]
	cp $ff
	jr nz, .skip2
	ld a, [wd004]
	ld [wd002], a
	ld a, $ff
	ld [wd004], a
	jr .skip

.skip2
	ld [wd002], a
	ld a, $ff
	ld [wd003], a

.skip
	ld a, [wd003]
	cp $ff
	ret nz
	ld b, a
	ld a, [wd004]
	ld [wd003], a
	ld a, b
	ld [wd004], a
	ret

Function4adf7:
	ld a, [wd019]
	bit 0, a
	ret z
	ld a, [wPartyCount]
	inc a
	ld [wMenuCursorY], a
	ld a, $1
	ld [wMenuCursorX], a
	ld a, [wd019]
	res 0, a
	ld [wd019], a
	ret

Function11a0ca:
	xor a
	ld [wMenuBorderLeftCoord], a
	ld [wMenuBorderTopCoord], a
	ld a, $13
	ld [wMenuBorderRightCoord], a
	ld a, $11
	ld [wMenuBorderBottomCoord], a
	call PushWindow
	farcall Function11765d
	farcall Function17d3f6
	farcall Stubbed_Function106462
	farcall Function106464
	call ExitMenu
	farcall ReloadMapPart
	farcall Function115d99
	ld c, $0
	farcall Function115e18
	ld a, $1
	ld [wc305], a
	ret
	

Function11a88c:
	ld a, [bc]
	sla a
	ld c, a
	xor a
	ld b, a
	add hl, bc
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
	inc de
	ret
	

Function11acb7: ; mobile phone animation?
	ld hl, TilemapPack_11ba44
	ld a, [wcd49]
	ld c, a
	ld b, 0
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	add hl, bc
	decoord 5, 12 ;6, 6
	ld a, [hli]
	ld [de], a
	decoord 4, 6 ;0, 7
	;ld bc, 7
	;call CopyBytes

	; vertical
	ld a, [hli]
	ld [de], a
	decoord 4, 7
	ld a, [hli]
	ld [de], a
	decoord 4, 8
	ld a, [hli]
	ld [de], a
	decoord 4, 9
	ld a, [hli]
	ld [de], a
	decoord 4, 10
	ld a, [hli]
	ld [de], a
	decoord 4, 11
	ld a, [hli]
	ld [de], a
	decoord 4, 12
	ld a, [hli]
	ld [de], a


	ld a, [wcd49]
	inc a
	ld [wcd49], a
	ld a, [hl]
	cp $ff
	jr nz, .get_the_other
	xor a
	ld [wcd49], a
.get_the_other
	ld hl, TilemapPack_11bb7d
	ld a, [wcd4a]
	ld c, a
	ld b, 0
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	add hl, bc
	decoord 2, 8 ;3, 9 ; wanted pokemon animation coordinates
	;ld bc, 7
	;call CopyBytes

	; vertical
	ld a, [hli]
	ld [de], a
	decoord 2, 9
	ld a, [hli]
	ld [de], a
	decoord 2, 10
	ld a, [hli]
	ld [de], a
	decoord 2, 11
	ld a, [hli]
	ld [de], a
	decoord 2, 12
	ld a, [hli]
	ld [de], a
	decoord 2, 13
	ld a, [hli]
	ld [de], a
	decoord 2, 14
	ld a, [hli]
	ld [de], a


	ld a, [wcd4a]
	inc a
	ld [wcd4a], a
	inc hl
	ld a, [hl]
	cp $ff
	ret nz
	xor a
	ld [wcd4a], a
	ret
	
TilemapPack_11ba44:
	db $47, $30, $0a, $0a, $0a, $0a, $0a, $56 ; 00
	db $46, $2f, $0a, $0a, $0a, $0a, $0a, $55 ; 01
	db $45, $3d, $0a, $0a, $0a, $0a, $0a, $54 ; 02
	db $44, $30, $0a, $0a, $0a, $0a, $0a, $53 ; 03
	db $43, $2f, $0a, $0a, $0a, $0a, $0a, $52 ; 04
	db $4a, $3d, $0a, $0a, $0a, $0a, $0a, $51 ; 05
	db $4a, $30, $0a, $0a, $0a, $0a, $0a, $50 ; 06
	db $4a, $2f, $0a, $0a, $0a, $0a, $0a, $4f ; 07
	db $4a, $3d, $0a, $0a, $0a, $0a, $0a, $4e ; 08
	db $4a, $30, $0a, $0a, $0a, $0a, $4d, $42 ; 09
	db $4a, $2f, $0a, $0a, $0a, $0a, $6b, $58 ; 0a
	db $4a, $3d, $0a, $0a, $0a, $0a, $6a, $58 ; 0b
	db $4a, $30, $0a, $0a, $0a, $0a, $69, $58 ; 0c
	db $4a, $2f, $0a, $0a, $0a, $0a, $68, $58 ; 0d
	db $4a, $3d, $0a, $0a, $0a, $66, $67, $58 ; 0e
	db $4a, $30, $0a, $0a, $0a, $65, $0a, $58 ; 0f
	db $4a, $2f, $0a, $0a, $0a, $64, $0a, $58 ; 10
	db $4a, $3d, $0a, $0a, $0a, $63, $0a, $58 ; 11
	db $4a, $30, $0a, $0a, $61, $62, $0a, $58 ; 12
	db $4a, $2f, $0a, $0a, $5f, $60, $0a, $58 ; 13
	db $4a, $3d, $0a, $61, $62, $0a, $0a, $58 ; 14
	db $4a, $30, $0a, $63, $0a, $0a, $0a, $58 ; 15
	db $4a, $2f, $69, $0a, $0a, $0a, $0a, $58 ; 16
	db $4a, $3d, $81, $0a, $0a, $0a, $0a, $58 ; 17
	db $4a, $30, $80, $0a, $0a, $0a, $0a, $58 ; 18
	db $4a, $2f, $7f, $0a, $0a, $0a, $0a, $58 ; 19
	db $4a, $3d, $0a, $0a, $0a, $0a, $0a, $58 ; 1a
	db $4a, $30, $0a, $0a, $0a, $0a, $0a, $58 ; 1b
	db $4a, $2f, $68, $87, $88, $89, $0a, $58 ; 1c
	db $4a, $3d, $6e, $6f, $70, $75, $76, $58 ; 1d
	db $4a, $30, $75, $76, $5c, $5d, $5e, $58 ; 1e
	db $4a, $2f, $71, $72, $73, $74, $6d, $58 ; 1f
	db $4a, $3d, $75, $76, $77, $8a, $8b, $58 ; 20
	db $4a, $30, $66, $67, $65, $0a, $6a, $58 ; 21
	db $4a, $2f, $83, $84, $0a, $83, $84, $58 ; 22
	db $4a, $3d, $0a, $85, $82, $84, $0a, $58 ; 23
	db $4a, $30, $41, $80, $40, $0a, $0a, $58 ; 24
	db $4a, $2f, $83, $0a, $0a, $0a, $0a, $58 ; 25
	db $4a, $3d, $40, $0a, $0a, $0a, $0a, $58 ; 26
	db -1

TilemapPack_11bb7d:
	db $0a, $0a, $0a, $0a, $0a, $0a, $16, $00 ; 00
	db $78, $0a, $0a, $0a, $0a, $0a, $8c, $00 ; 01
	db $79, $0a, $0a, $0a, $0a, $0a, $8d, $00 ; 02
	db $7a, $0a, $0a, $0a, $0a, $0a, $8e, $00 ; 03
	db $7b, $0a, $0a, $0a, $0a, $0a, $8c, $00 ; 04
	db $7c, $0a, $0a, $0a, $0a, $0a, $8d, $00 ; 05
	db $7d, $0a, $0a, $0a, $0a, $0a, $8e, $00 ; 06
	db $2e, $7e, $0a, $0a, $0a, $0a, $8c, $00 ; 07
	db $2e, $80, $0a, $0a, $0a, $0a, $8d, $00 ; 08
	db $2e, $81, $0a, $0a, $0a, $0a, $8e, $00 ; 09
	db $2e, $82, $0a, $0a, $0a, $0a, $8c, $00 ; 0a
	db $2e, $69, $0a, $0a, $0a, $0a, $8d, $00 ; 0b
	db $2e, $6a, $0a, $0a, $0a, $0a, $8e, $00 ; 0c
	db $2e, $6b, $0a, $0a, $0a, $0a, $8c, $00 ; 0d
	db $2e, $0a, $68, $0a, $0a, $0a, $8d, $00 ; 0e
	db $2e, $0a, $69, $0a, $0a, $0a, $8e, $00 ; 0f
	db $2e, $0a, $0a, $6a, $0a, $0a, $8c, $00 ; 10
	db $2e, $0a, $0a, $6b, $0a, $0a, $8d, $00 ; 11
	db $2e, $0a, $0a, $0a, $80, $0a, $8e, $00 ; 12
	db $2e, $0a, $0a, $0a, $82, $0a, $8c, $00 ; 13
	db $2e, $0a, $0a, $0a, $6c, $0a, $8d, $00 ; 14
	db $2e, $0a, $0a, $0a, $0a, $83, $8e, $00 ; 15
	db $2e, $0a, $6b, $0a, $0a, $0a, $8c, $00 ; 16
	db $2e, $0a, $0a, $69, $0a, $0a, $8d, $00 ; 17
	db $2e, $0a, $0a, $6a, $0a, $0a, $8e, $00 ; 18
	db $2e, $0a, $0a, $0a, $68, $0a, $8c, $00 ; 19
	db $2e, $0a, $0a, $0a, $63, $0a, $8d, $00 ; 1a
	db $2e, $0a, $0a, $61, $62, $0a, $8e, $00 ; 1b
	db $2e, $0a, $0a, $0a, $5f, $60, $8c, $00 ; 1c
	db $2e, $0a, $0a, $0a, $63, $0a, $8d, $00 ; 1d
	db $2e, $0a, $0a, $0a, $0a, $69, $8c, $00 ; 1e
	db $2e, $0a, $0a, $0a, $0a, $6b, $8d, $00 ; 1f
	db $2e, $0a, $0a, $0a, $0a, $83, $8e, $00 ; 20
	db $2e, $0a, $0a, $0a, $0a, $86, $8c, $00 ; 21
	db $2e, $0a, $85, $0a, $0a, $0a, $8d, $00 ; 22
	db $2e, $0a, $0a, $84, $0a, $0a, $8e, $00 ; 23
	db -1	