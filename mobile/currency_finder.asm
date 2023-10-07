; Input: DE = the memory address were the string should be written. Also, wPrefecture should be set to the prefecture of the user.
; Output: it edits the bytes pointed by DE.
WriteCurrencyName::
	call DetermineCurrencyName
	call CopyCurrencyString
	ret

; Input: none. wPrefecture should be set to the prefecture of the user.
; Output: HL = the address of the string to use for the currency.
DetermineCurrencyName:

	ld a, [wPrefecture] ; Loads the Prefectures index (starts at 0) selected by the player. The Prefectures list is stored into mobile_12.asm
	dec a ; Beware: it the value is 0, dec will underflow and default to the default value

	ld hl, String_Currency_Cents
	ret

; Input: HL = the address to copy from.
; Output: DE = the address to copy into.
; Stops the copy when the EOL char is found ($50 or '@').
CopyCurrencyString: ; I know this is ugly, I copied and pasted this function from mobile_46.asm
.loop
	ld a, [hli]
	cp $50
	ret z
	ld [de], a
	inc de
	jr .loop

String_Currency_Cents: ; Note that this is unoptimized, as the string "Is this OK?@" is repeated.
	db   " cts.";"えん"
	next "¿Es correcto?@";"かかります　よろしい　ですか？@"
	