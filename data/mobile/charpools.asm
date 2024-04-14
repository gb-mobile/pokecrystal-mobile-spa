	const_def
	const CHARPOOL_0_TO_9
	const CHARPOOL_DASH	

Zipcode_CharPools:
	; address of the charpool,       char pool length in bytes
	dwb Zipcode_CharPool_0to9,       10 ; CHARPOOL_0_TO_9
	dwb Zipcode_CharPool_Dash,        1 ; CHARPOOL_DASH

Zipcode_CharPool_0to9:
	db "0123"
Zipcode_CharPool_4:
	db "456"
Zipcode_CharPool_7:
	db "7"
Zipcode_CharPool_8:
	db "8"
Zipcode_CharPool_9:
	db "9"
Zipcode_CharPool_Dash:
	db "-"	
	