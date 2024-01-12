ChrisNameMenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 10, TEXTBOX_Y - 1
	dw .MaleNames
	db 1 ; default option
	db 0 ; ????

.MaleNames:
	db STATICMENU_CURSOR | STATICMENU_PLACE_TITLE | STATICMENU_DISABLE_B ; flags
	db 5 ; items
	db "NUEVO N.@"
MalePlayerNameArray:
	db "CRIS@"
	db "ANTONIO@"
	db "ÁLEX@"
	db "EMILIO@"
	db 2 ; title indent
	db " NOMBRE @" ; title

KrisNameMenuHeader:
	db MENU_BACKUP_TILES ; flags
	menu_coords 0, 0, 10, TEXTBOX_Y - 1
	dw .FemaleNames
	db 1 ; default option
	db 0 ; ????

.FemaleNames:
	db STATICMENU_CURSOR | STATICMENU_PLACE_TITLE | STATICMENU_DISABLE_B ; flags
	db 5 ; items
	db "NUEVO N.@"
FemalePlayerNameArray:
	db "CRISTI@"
	db "MARÍA@"
	db "SUSANA@"
	db "YOLANDA@"
	db 2 ; title indent
	db " NOMBRE @" ; title
