MACRO memset ;wram, input val is 8bit
	ld a, \2
	ld [\1], a
ENDM

MACRO memset16 ;wram, input val is 16bit
	ld a, [\2]
	ld [\1], a
ENDM

MACRO memseth ;hram
	ld a, \2
	ldh [\1], a
ENDM

MACRO checkbit
	ld a, [\1]
	bit \2, a
ENDM

MACRO resetbit
	ld hl, \1
	res \2, [hl]
ENDM

MACRO setbit
	ld hl, \1
	set \2, [hl]
ENDM

MACRO iftrue
	jp nz, \1
ENDM

MACRO iffalse
	jp z, \1
ENDM

MACRO ifeq
	cp \1
	jp z, \2
ENDM

MACRO ifneq
	cp \1
	jp nz, \2
ENDM

MACRO checkmem
	ld a, [\1]
ENDM

MACRO checkbool
	and a
ENDM

MACRO endiffalse
	ret z
ENDM

MACRO endiftrue
	ret nz
ENDM

MACRO endifbset
	ret z
ENDM

MACRO endifbunset
	ret nz
ENDM

MACRO endifeq
	cp \1
	ret z
ENDM

MACRO endifneq
	cp \1
	ret nz
ENDM

MACRO endif_memand_set
	checkmem \1
	checkbool
	endifbset
ENDM

MACRO endif_memand_unset
	checkmem \1
	checkbool
	endifbunset
ENDM

MACRO if_memand_unset
	checkmem \1
	checkbool
	jp nz, \2
ENDM

MACRO if_memand_set
	checkmem \1
	checkbool
	jp z, \2
ENDM