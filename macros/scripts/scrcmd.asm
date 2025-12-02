MACRO playmusic
	ld a, SFX_STOP_ALL_MUSIC
	call PlaySound
	ld c, 0
	ld a, \1
	call PlayMusic
ENDM

MACRO writetext
	ld hl, \1
	call PrintText
ENDM

MACRO waitframes
	ld c, \1
	call DelayFrames
ENDM

MACRO writetextm 
	ld a, \1
	ldh [hTextID], a
	;memseth hTextID, \1
	call DisplayTextID
ENDM

MACRO appearobj
	memset wMissableObjectIndex, \1
	predef ShowObject
ENDM

MACRO disappearobj
	memset wMissableObjectIndex, \1
	predef HideObject
ENDM

MACRO showemote
	memset wEmotionBubbleSpriteIndex, \1
	memset wWhichEmotionBubble, \2
	predef EmotionBubble
ENDM

MACRO disablewaitbutton
	memset wDoNotWaitForButtonPressAfterDisplayingText, 1
ENDM

MACRO enablewaitbutton
	memset wDoNotWaitForButtonPressAfterDisplayingText, 0
ENDM	

MACRO playmapmusic
	ld a, [wMapMusicSoundID]
	call PlayMusic
ENDM

MACRO applymovement
	ld de, \2
	memseth hSpriteIndex, \1
	call MoveSprite
ENDM

MACRO spritedir
	memseth hSpriteIndex, \1
	memseth hSpriteFacingDirection, \2
	call SetSpriteFacingDirectionAndDelay
ENDM

MACRO locateplayer
	memseth hNPCPlayerRelativePosPerspective, 1
	ld a, 1
	swap a
	ldh [hNPCSpriteOffset], a
	predef CalcPositionOfPlayerRelativeToNPC
	ld hl, hNPCPlayerYDistance
	dec [hl]
	predef FindPathToPlayer
ENDM

MACRO loadrlelist
	ld hl, \1
	ld de, \2
	call DecodeRLEList
ENDM

MACRO moveplayer_rle
	loadrlelist wSimulatedJoypadStatesEnd, \1
	dec a
	ld [wSimulatedJoypadStatesIndex], a
ENDM

MACRO releasectrls
	memset wJoyIgnore, 0
ENDM

MACRO lockctrls_all
	memset wJoyIgnore, PAD_SELECT | PAD_START | PAD_CTRL_PAD
ENDM

MACRO lockctrls_nostart
	memset wJoyIgnore, PAD_SELECT | PAD_CTRL_PAD
ENDM

MACRO turnplayer
	memset wPlayerMovingDirection, \1
ENDM

MACRO loadtrainer
	memset wCurOpponent, \1
	memset wTrainerNo, \2
ENDM

MACRO winlosstext
	ld hl, \1
	ld de, \2
	call SaveEndBattleTextPointers
ENDM

MACRO endifnpcmoving
	checkbit wStatusFlags5, BIT_SCRIPTED_NPC_MOVEMENT
	endiftrue
ENDM