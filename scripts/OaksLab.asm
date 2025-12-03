OaksLab_Script:
	CheckEvent EVENT_PALLET_AFTER_GETTING_POKEBALLS_2
	call nz, OaksLabLoadTextPointers2Script
	ld a, 1 << BIT_NO_AUTO_TEXT_BOX
	ld [wAutoTextBoxDrawingControl], a
	xor a
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld hl, OaksLab_ScriptPointers
	ld a, [wOaksLabCurScript]
	jp CallFunctionInTable

OaksLab_ScriptPointers:
	def_script_pointers
	dw_const OaksLabDefaultScript,                   SCRIPT_OAKSLAB_DEFAULT
	dw_const OaksLabOakEntersLabScript,              SCRIPT_OAKSLAB_OAK_ENTERS_LAB
	dw_const OaksLabHideShowOaksScript,              SCRIPT_OAKSLAB_HIDE_SHOW_OAKS
	dw_const OaksLabPlayerEntersLabScript,           SCRIPT_OAKSLAB_PLAYER_ENTERS_LAB
	dw_const OaksLabFollowedOakScript,               SCRIPT_OAKSLAB_FOLLOWED_OAK
	dw_const OaksLabOakChooseMonSpeechScript,        SCRIPT_OAKSLAB_OAK_CHOOSE_MON_SPEECH
	dw_const OaksLabPlayerDontGoAwayScript,          SCRIPT_OAKSLAB_PLAYER_DONT_GO_AWAY_SCRIPT
	dw_const OaksLabPlayerForcedToWalkBackScript,    SCRIPT_OAKSLAB_PLAYER_FORCED_TO_WALK_BACK_SCRIPT
	dw_const OaksLabChoseStarterScript,              SCRIPT_OAKSLAB_CHOSE_STARTER_SCRIPT
	dw_const OaksLabRivalChoosesStarterScript,       SCRIPT_OAKSLAB_RIVAL_CHOOSES_STARTER
	dw_const OaksLabRivalChallengesPlayerScript,     SCRIPT_OAKSLAB_RIVAL_CHALLENGES_PLAYER
	dw_const OaksLabRivalStartBattleScript,          SCRIPT_OAKSLAB_RIVAL_START_BATTLE
	dw_const OaksLabRivalEndBattleScript,            SCRIPT_OAKSLAB_RIVAL_END_BATTLE
	dw_const OaksLabRivalStartsExitScript,           SCRIPT_OAKSLAB_RIVAL_STARTS_EXIT
	dw_const OaksLabPlayerWatchRivalExitScript,      SCRIPT_OAKSLAB_PLAYER_WATCH_RIVAL_EXIT
	dw_const OaksLabRivalArrivesAtOaksRequestScript, SCRIPT_OAKSLAB_RIVAL_ARRIVES_AT_OAKS_REQUEST
	dw_const OaksLabOakGivesPokedexScript,           SCRIPT_OAKSLAB_OAK_GIVES_POKEDEX
	dw_const OaksLabRivalLeavesWithPokedexScript,    SCRIPT_OAKSLAB_RIVAL_LEAVES_WITH_POKEDEX
	dw_const OaksLabNoopScript,                      SCRIPT_OAKSLAB_NOOP

OaksLabDefaultScript:
	CheckEvent EVENT_OAK_APPEARED_IN_PALLET
	endiffalse
	endif_memand_unset wNPCMovementScriptFunctionNum	
	appearobj HS_OAKS_LAB_OAK_2
	resetbit wStatusFlags4, BIT_NO_BATTLES
	memset wOaksLabCurScript, SCRIPT_OAKSLAB_OAK_ENTERS_LAB
	ret

OaksLabOakEntersLabScript:
	applymovement OAKSLAB_OAK2, .OakEntryMovement
	memset wOaksLabCurScript, SCRIPT_OAKSLAB_HIDE_SHOW_OAKS
	ret
.OakEntryMovement
	db NPC_MOVEMENT_UP
	db NPC_MOVEMENT_UP
	db NPC_MOVEMENT_UP
	db -1 ; end

OaksLabHideShowOaksScript:
	endifnpcmoving
	disappearobj HS_OAKS_LAB_OAK_2
	appearobj HS_OAKS_LAB_OAK_1
	memset wOaksLabCurScript, SCRIPT_OAKSLAB_PLAYER_ENTERS_LAB
	ret

OaksLabPlayerEntersLabScript:
	call Delay3
	moveplayer_rle PlayerEntryMovementRLE
	call StartSimulatingJoypadStates
	spritedir OAKSLAB_RIVAL, SPRITE_FACING_DOWN
	spritedir OAKSLAB_OAK1, SPRITE_FACING_DOWN
	memset wOaksLabCurScript, SCRIPT_OAKSLAB_FOLLOWED_OAK
	ret

PlayerEntryMovementRLE:
	db PAD_UP, 8
	db -1 ; end

OaksLabFollowedOakScript:
	endif_memand_unset wSimulatedJoypadStatesIndex
	
	SetEvent EVENT_FOLLOWED_OAK_INTO_LAB
	SetEvent EVENT_FOLLOWED_OAK_INTO_LAB_2
	
	spritedir OAKSLAB_RIVAL, SPRITE_FACING_UP
	playmapmusic
	memset wOaksLabCurScript, SCRIPT_OAKSLAB_OAK_CHOOSE_MON_SPEECH
	ret

OaksLabOakChooseMonSpeechScript:
	lockctrls_all
	writetextm TEXT_OAKSLAB_RIVAL_FED_UP_WITH_WAITING
	call Delay3
	writetextm TEXT_OAKSLAB_OAK_CHOOSE_MON
	call Delay3
	writetextm TEXT_OAKSLAB_RIVAL_WHAT_ABOUT_ME
	call Delay3
	writetextm TEXT_OAKSLAB_OAK_BE_PATIENT
	SetEvent EVENT_OAK_ASKED_TO_CHOOSE_MON
	releasectrls
	memset wOaksLabCurScript, SCRIPT_OAKSLAB_PLAYER_DONT_GO_AWAY_SCRIPT
	ret

OaksLabPlayerDontGoAwayScript:
	checkmem wYCoord
	endifneq 6
	
	spritedir OAKSLAB_OAK1, SPRITE_FACING_DOWN
	spritedir OAKSLAB_RIVAL, SPRITE_FACING_DOWN
	call UpdateSprites
	writetextm TEXT_OAKSLAB_OAK_DONT_GO_AWAY_YET
	memset wSimulatedJoypadStatesIndex, 1
	memset wSimulatedJoypadStatesEnd, PAD_UP
	call StartSimulatingJoypadStates
	turnplayer PLAYER_DIR_UP

	memset wOaksLabCurScript, SCRIPT_OAKSLAB_PLAYER_FORCED_TO_WALK_BACK_SCRIPT
	ret

OaksLabPlayerForcedToWalkBackScript:
	endif_memand_unset wSimulatedJoypadStatesIndex
	call Delay3
	memset wOaksLabCurScript, SCRIPT_OAKSLAB_PLAYER_DONT_GO_AWAY_SCRIPT
	ret

OaksLabChoseStarterScript:
	checkmem wPlayerStarter
	ifeq STARTER1, .Charmander
	ifeq STARTER2, .Squirtle
	jr .Bulbasaur
.Charmander
	checkmem wYCoord
	ifeq 4, .charman_mov1
	applymovement OAKSLAB_RIVAL, .MiddleBallMovement2
	jr .scrend

.charman_mov1
	applymovement OAKSLAB_RIVAL, .MiddleBallMovement1
	jr .scrend

.Squirtle
	checkmem wYCoord
	ifeq 4, .squirtle_mov1
	applymovement OAKSLAB_RIVAL, .RightBallMovement2
	jr .scrend

.squirtle_mov1
	applymovement OAKSLAB_RIVAL, .RightBallMovement1
	jr .scrend

.Bulbasaur
	checkmem wXCoord
	ifneq 9, .bulba_mov1 ; is the player standing to the right of the table?
	push hl
	
	memseth hSpriteIndex, OAKSLAB_RIVAL
	memseth hSpriteDataOffset, SPRITESTATEDATA1_YPIXELS
	call GetPointerWithinSpriteStateData1
	push hl
	ld [hl], $4c ; SPRITESTATEDATA1_YPIXELS
	inc hl
	inc hl
	ld [hl], $0 ; SPRITESTATEDATA1_XPIXELS
	pop hl
	inc h
	ld [hl], 8 ; SPRITESTATEDATA2_MAPY
	inc hl
	ld [hl], 9 ; SPRITESTATEDATA2_MAPX
	pop hl
	applymovement OAKSLAB_RIVAL, .LeftBallMovement2
	jr .scrend
.bulba_mov1
	applymovement OAKSLAB_RIVAL, .LeftBallMovement1
.scrend
	memset wOaksLabCurScript, SCRIPT_OAKSLAB_RIVAL_CHOOSES_STARTER
	ret
	
.LeftBallMovement1
	db NPC_MOVEMENT_DOWN
	db NPC_MOVEMENT_RIGHT
.LeftBallMovement2
	db NPC_MOVEMENT_RIGHT
	db -1 ; end
	
.MiddleBallMovement1
	db NPC_MOVEMENT_DOWN
	db NPC_MOVEMENT_DOWN
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_UP
	db -1 ; end

.MiddleBallMovement2
	db NPC_MOVEMENT_DOWN
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db -1 ; end
	
.RightBallMovement1
	db NPC_MOVEMENT_DOWN
	db NPC_MOVEMENT_DOWN
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_UP
	db -1 ; end

.RightBallMovement2
	db NPC_MOVEMENT_DOWN
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db NPC_MOVEMENT_RIGHT
	db -1 ; end

OaksLabRivalChoosesStarterScript:
	endifnpcmoving
	lockctrls_all
	spritedir OAKSLAB_RIVAL, SPRITE_FACING_UP
	writetextm TEXT_OAKSLAB_RIVAL_ILL_TAKE_THIS_ONE
	checkmem wRivalStarterBallSpriteIndex
	ifneq OAKSLAB_CHARMANDER_POKE_BALL, .not_charmander
	disappearobj HS_STARTER_BALL_1
	jr .conteenyu
.not_charmander
	ifneq OAKSLAB_SQUIRTLE_POKE_BALL, .not_squirtle
	disappearobj HS_STARTER_BALL_2
	jr .conteenyu
.not_squirtle
	disappearobj HS_STARTER_BALL_3
.conteenyu
	call Delay3
	ld a, [wRivalStarterTemp]
	ld [wRivalStarter], a
	ld [wCurPartySpecies], a
	ld [wNamedObjectIndex], a
	call GetMonName
	
	spritedir OAKSLAB_RIVAL, SPRITE_FACING_UP

	writetextm TEXT_OAKSLAB_RIVAL_RECEIVED_MON
	SetEvent EVENT_GOT_STARTER
	releasectrls

	ld a, SCRIPT_OAKSLAB_RIVAL_CHALLENGES_PLAYER
	ld [wOaksLabCurScript], a
	ret

OaksLabRivalChallengesPlayerScript:
	checkmem wYCoord
	endifneq 6
	spritedir OAKSLAB_RIVAL, SPRITE_FACING_DOWN
	turnplayer PLAYER_DIR_UP
	playmusic MUSIC_MEET_RIVAL
	writetextm TEXT_OAKSLAB_RIVAL_ILL_TAKE_YOU_ON
	locateplayer
	applymovement OAKSLAB_RIVAL, wNPCMovementDirections2
	memset wOaksLabCurScript, SCRIPT_OAKSLAB_RIVAL_START_BATTLE
	ret

OaksLabRivalStartBattleScript:
	endifnpcmoving
	; define which team rival uses, and fight it
	checkmem wRivalStarter
	ifneq STARTER2, .not_squirtle
	loadtrainer OPP_RIVAL1, 1
	jr .done
.not_squirtle
	ifneq STARTER3, .not_bulbasaur
	loadtrainer OPP_RIVAL1, 2
	jr .done
.not_bulbasaur
	loadtrainer OPP_RIVAL1, 3
.done
	memset wSpriteIndex, OAKSLAB_RIVAL
	call GetSpritePosition1
	winlosstext OaksLabRivalIPickedTheWrongPokemonText, OaksLabRivalAmIGreatOrWhatText
	setbit wStatusFlags3, BIT_TALKED_TO_TRAINER
	setbit wStatusFlags3, BIT_PRINT_END_BATTLE_TEXT
	releasectrls
	turnplayer PLAYER_DIR_UP
	memset wOaksLabCurScript, SCRIPT_OAKSLAB_RIVAL_END_BATTLE
	ret

OaksLabRivalEndBattleScript:
	lockctrls_nostart
	turnplayer PLAYER_DIR_UP
	call UpdateSprites
	memset wSpriteIndex, OAKSLAB_RIVAL
	call SetSpritePosition1
	spritedir OAKSLAB_RIVAL, SPRITE_FACING_DOWN
	predef HealParty
	SetEvent EVENT_BATTLED_RIVAL_IN_OAKS_LAB
	memset wOaksLabCurScript, SCRIPT_OAKSLAB_RIVAL_STARTS_EXIT
	ret

OaksLabRivalStartsExitScript:
	waitframes 20
	writetextm TEXT_OAKSLAB_RIVAL_SMELL_YOU_LATER
	farcall Music_RivalAlternateStart
	
	applymovement OAKSLAB_RIVAL, .RivalExitMovement
	checkmem wXCoord
	; move left or right depending on where the player is standing
	ifneq 4, .moveLeft
	jr .moveRight
.moveLeft
	memset wNPCMovementDirections, NPC_MOVEMENT_LEFT
	jr .next
.moveRight
	memset wNPCMovementDirections, NPC_MOVEMENT_RIGHT
.next
	memset wOaksLabCurScript, SCRIPT_OAKSLAB_PLAYER_WATCH_RIVAL_EXIT
	ret

.RivalExitMovement
	db NPC_CHANGE_FACING
	db NPC_MOVEMENT_DOWN
	db NPC_MOVEMENT_DOWN
	db NPC_MOVEMENT_DOWN
	db NPC_MOVEMENT_DOWN
	db NPC_MOVEMENT_DOWN
	db -1 ; end

OaksLabPlayerWatchRivalExitScript:
	checkbit wStatusFlags5, BIT_SCRIPTED_NPC_MOVEMENT
	iftrue .checkRivalPosition
	disappearobj HS_OAKS_LAB_RIVAL
	releasectrls
	playmapmusic
	memset wOaksLabCurScript, SCRIPT_OAKSLAB_NOOP
	jr .done
; make the player keep facing the rival as he walks away
.checkRivalPosition
	checkmem wNPCNumScriptedSteps
	ifneq 5, .turnPlayerDown
	checkmem wXCoord
	ifneq 4, .turnPlayerLeft
	memset wSpritePlayerStateData1FacingDirection, SPRITE_FACING_RIGHT
	jr .done
.turnPlayerLeft
	memset wSpritePlayerStateData1FacingDirection, SPRITE_FACING_LEFT
	jr .done
.turnPlayerDown
	endifneq 4
	memset wSpritePlayerStateData1FacingDirection, SPRITE_FACING_DOWN
.done
	ret

OaksLabRivalArrivesAtOaksRequestScript:
	xor a
	ldh [hJoyHeld], a
	call EnableAutoTextBoxDrawing
	ld a, SFX_STOP_ALL_MUSIC
;	ld [wNewSoundID], a
	call PlaySound
	farcall Music_RivalAlternateStart
	ld a, TEXT_OAKSLAB_RIVAL_GRAMPS
	ldh [hTextID], a
	call DisplayTextID
	call OaksLabCalcRivalMovementScript
	ld a, HS_OAKS_LAB_RIVAL
	ld [wMissableObjectIndex], a
	predef ShowObject
	ld a, [wNPCMovementDirections2Index]
	ld [wSavedNPCMovementDirections2Index], a
	ld b, 0
	ld c, a
	ld hl, wNPCMovementDirections2
	ld a, NPC_MOVEMENT_UP
	call FillMemory
	ld [hl], $ff
	ld a, OAKSLAB_RIVAL
	ldh [hSpriteIndex], a
	ld de, wNPCMovementDirections2
	call MoveSprite

	ld a, SCRIPT_OAKSLAB_OAK_GIVES_POKEDEX
	ld [wOaksLabCurScript], a
	ret

OaksLabRivalFaceUpOakFaceDownScript:
	ld a, OAKSLAB_RIVAL
	ldh [hSpriteIndex], a
	ld a, SPRITE_FACING_UP
	ldh [hSpriteFacingDirection], a
	call SetSpriteFacingDirectionAndDelay
	ld a, OAKSLAB_OAK2
	ldh [hSpriteIndex], a
	xor a ; SPRITE_FACING_DOWN
	ldh [hSpriteFacingDirection], a
	jp SetSpriteFacingDirectionAndDelay

OaksLabOakGivesPokedexScript:
	ld a, [wStatusFlags5]
	bit BIT_SCRIPTED_NPC_MOVEMENT, a
	ret nz
	call EnableAutoTextBoxDrawing
	call PlayDefaultMusic
	ld a, PAD_SELECT | PAD_START | PAD_CTRL_PAD
	ld [wJoyIgnore], a
	call OaksLabRivalFaceUpOakFaceDownScript
	ld a, TEXT_OAKSLAB_RIVAL_WHAT_DID_YOU_CALL_ME_FOR
	ldh [hTextID], a
	call DisplayTextID
	call DelayFrame
	call OaksLabRivalFaceUpOakFaceDownScript
	ld a, TEXT_OAKSLAB_OAK_I_HAVE_A_REQUEST
	ldh [hTextID], a
	call DisplayTextID
	call DelayFrame
	call OaksLabRivalFaceUpOakFaceDownScript
	ld a, TEXT_OAKSLAB_OAK_MY_INVENTION_POKEDEX
	ldh [hTextID], a
	call DisplayTextID
	call DelayFrame
	ld a, TEXT_OAKSLAB_OAK_GOT_POKEDEX
	ldh [hTextID], a
	call DisplayTextID
	call Delay3
	ld a, HS_POKEDEX_1
	ld [wMissableObjectIndex], a
	predef HideObject
	ld a, HS_POKEDEX_2
	ld [wMissableObjectIndex], a
	predef HideObject
	call OaksLabRivalFaceUpOakFaceDownScript
	ld a, TEXT_OAKSLAB_OAK_THAT_WAS_MY_DREAM
	ldh [hTextID], a
	call DisplayTextID
	ld a, OAKSLAB_RIVAL
	ldh [hSpriteIndex], a
	ld a, SPRITE_FACING_RIGHT
	ldh [hSpriteFacingDirection], a
	call SetSpriteFacingDirectionAndDelay
	call Delay3
	ld a, TEXT_OAKSLAB_RIVAL_LEAVE_IT_ALL_TO_ME
	ldh [hTextID], a
	call DisplayTextID
	SetEvent EVENT_GOT_POKEDEX
	SetEvent EVENT_OAK_GOT_PARCEL
	ld a, HS_LYING_OLD_MAN
	ld [wMissableObjectIndex], a
	predef HideObject
	ld a, HS_OLD_MAN
	ld [wMissableObjectIndex], a
	predef ShowObject
	ld a, [wSavedNPCMovementDirections2Index]
	ld b, 0
	ld c, a
	ld hl, wNPCMovementDirections2
	xor a ; NPC_MOVEMENT_DOWN
	call FillMemory
	ld [hl], $ff
	ld a, SFX_STOP_ALL_MUSIC
;	ld [wNewSoundID], a
	call PlaySound
	farcall Music_RivalAlternateStart
	ld a, OAKSLAB_RIVAL
	ldh [hSpriteIndex], a
	ld de, wNPCMovementDirections2
	call MoveSprite

	ld a, SCRIPT_OAKSLAB_RIVAL_LEAVES_WITH_POKEDEX
	ld [wOaksLabCurScript], a
	ret

OaksLabRivalLeavesWithPokedexScript:
	ld a, [wStatusFlags5]
	bit BIT_SCRIPTED_NPC_MOVEMENT, a
	ret nz
	call PlayDefaultMusic
	ld a, HS_OAKS_LAB_RIVAL
	ld [wMissableObjectIndex], a
	predef HideObject
	SetEvent EVENT_1ST_ROUTE22_RIVAL_BATTLE
	ResetEventReuseHL EVENT_2ND_ROUTE22_RIVAL_BATTLE
	SetEventReuseHL EVENT_ROUTE22_RIVAL_WANTS_BATTLE
	ld a, HS_ROUTE_22_RIVAL_1
	ld [wMissableObjectIndex], a
	predef ShowObject
	ld a, SCRIPT_PALLETTOWN_DAISY
	ld [wPalletTownCurScript], a
	xor a
	ld [wJoyIgnore], a

	ld a, SCRIPT_OAKSLAB_NOOP
	ld [wOaksLabCurScript], a
	ret

OaksLabNoopScript:
	ret

OaksLabScript_RemoveParcel:
	ld hl, wBagItems
	ld bc, 0
.loop
	ld a, [hli]
	cp $ff
	ret z
	cp OAKS_PARCEL
	jr z, .foundParcel
	inc hl
	inc c
	jr .loop
.foundParcel
	ld hl, wNumBagItems
	ld a, c
	ld [wWhichPokemon], a
	ld a, 1
	ld [wItemQuantity], a
	jp RemoveItemFromInventory

OaksLabCalcRivalMovementScript:
	ld a, $7c
	ldh [hSpriteScreenYCoord], a
	ld a, 8
	ldh [hSpriteMapXCoord], a
	ld a, [wYCoord]
	cp 3
	jr nz, .not_below_oak
	ld a, $4
	ld [wNPCMovementDirections2Index], a
	ld a, $30
	ld b, 11
	jr .done
.not_below_oak
	cp 1
	jr nz, .not_above_oak
	ld a, $2
	ld [wNPCMovementDirections2Index], a
	ld a, $30
	ld b, 9
	jr .done
.not_above_oak
	ld a, $3
	ld [wNPCMovementDirections2Index], a
	ld b, 10
	ld a, [wXCoord]
	cp 4
	jr nz, .not_left_of_oak
	ld a, $40
	jr .done
.not_left_of_oak
	ld a, $20
.done
	ldh [hSpriteScreenXCoord], a
	ld a, b
	ldh [hSpriteMapYCoord], a
	ld a, OAKSLAB_RIVAL
	ld [wSpriteIndex], a
	call SetSpritePosition1
	ret

OaksLabLoadTextPointers2Script:
	ld hl, OaksLab_TextPointers2
	ld a, l
	ld [wCurMapTextPtr], a
	ld a, h
	ld [wCurMapTextPtr + 1], a
	ret

OaksLab_TextPointers:
	def_text_pointers
	dw_const OaksLabRivalText,                    TEXT_OAKSLAB_RIVAL
	dw_const OaksLabCharmanderPokeBallText,       TEXT_OAKSLAB_CHARMANDER_POKE_BALL
	dw_const OaksLabSquirtlePokeBallText,         TEXT_OAKSLAB_SQUIRTLE_POKE_BALL
	dw_const OaksLabBulbasaurPokeBallText,        TEXT_OAKSLAB_BULBASAUR_POKE_BALL
	dw_const OaksLabOak1Text,                     TEXT_OAKSLAB_OAK1
	dw_const OaksLabPokedexText,                  TEXT_OAKSLAB_POKEDEX1
	dw_const OaksLabPokedexText,                  TEXT_OAKSLAB_POKEDEX2
	dw_const OaksLabOak2Text,                     TEXT_OAKSLAB_OAK2
	dw_const OaksLabGirlText,                     TEXT_OAKSLAB_GIRL
	dw_const OaksLabScientistText,                TEXT_OAKSLAB_SCIENTIST1
	dw_const OaksLabScientistText,                TEXT_OAKSLAB_SCIENTIST2
	dw_const OaksLabOakDontGoAwayYetText,         TEXT_OAKSLAB_OAK_DONT_GO_AWAY_YET
	dw_const OaksLabRivalIllTakeThisOneText,      TEXT_OAKSLAB_RIVAL_ILL_TAKE_THIS_ONE
	dw_const OaksLabRivalReceivedMonText,         TEXT_OAKSLAB_RIVAL_RECEIVED_MON
	dw_const OaksLabRivalIllTakeYouOnText,        TEXT_OAKSLAB_RIVAL_ILL_TAKE_YOU_ON
	dw_const OaksLabRivalSmellYouLaterText,       TEXT_OAKSLAB_RIVAL_SMELL_YOU_LATER
	dw_const OaksLabRivalFedUpWithWaitingText,    TEXT_OAKSLAB_RIVAL_FED_UP_WITH_WAITING
	dw_const OaksLabOakChooseMonText,             TEXT_OAKSLAB_OAK_CHOOSE_MON
	dw_const OaksLabRivalWhatAboutMeText,         TEXT_OAKSLAB_RIVAL_WHAT_ABOUT_ME
	dw_const OaksLabOakBePatientText,             TEXT_OAKSLAB_OAK_BE_PATIENT
	dw_const OaksLabRivalGrampsText,              TEXT_OAKSLAB_RIVAL_GRAMPS
	dw_const OaksLabRivalWhatDidYouCallMeForText, TEXT_OAKSLAB_RIVAL_WHAT_DID_YOU_CALL_ME_FOR
	dw_const OaksLabOakIHaveARequestText,         TEXT_OAKSLAB_OAK_I_HAVE_A_REQUEST
	dw_const OaksLabOakMyInventionPokedexText,    TEXT_OAKSLAB_OAK_MY_INVENTION_POKEDEX
	dw_const OaksLabOakGotPokedexText,            TEXT_OAKSLAB_OAK_GOT_POKEDEX
	dw_const OaksLabOakThatWasMyDreamText,        TEXT_OAKSLAB_OAK_THAT_WAS_MY_DREAM
	dw_const OaksLabRivalLeaveItAllToMeText,      TEXT_OAKSLAB_RIVAL_LEAVE_IT_ALL_TO_ME

OaksLab_TextPointers2:
	dw OaksLabRivalText
	dw OaksLabCharmanderPokeBallText
	dw OaksLabSquirtlePokeBallText
	dw OaksLabBulbasaurPokeBallText
	dw OaksLabOak1Text
	dw OaksLabPokedexText
	dw OaksLabPokedexText
	dw OaksLabOak2Text
	dw OaksLabGirlText
	dw OaksLabScientistText
	dw OaksLabScientistText

OaksLabRivalText:
	text_asm
	CheckEvent EVENT_FOLLOWED_OAK_INTO_LAB_2
	jr nz, .beforeChooseMon
	ld hl, .GrampsIsntAroundText
	call PrintText
	jr .done
.beforeChooseMon
	CheckEventReuseA EVENT_GOT_STARTER
	jr nz, .afterChooseMon
	ld hl, .GoAheadAndChooseText
	call PrintText
	jr .done
.afterChooseMon
	ld hl, .MyPokemonLooksStrongerText
	call PrintText
.done
	jp TextScriptEnd

.GrampsIsntAroundText:
	text_far _OaksLabRivalGrampsIsntAroundText
	text_end

.GoAheadAndChooseText:
	text_far _OaksLabRivalGoAheadAndChooseText
	text_end

.MyPokemonLooksStrongerText:
	text_far _OaksLabRivalMyPokemonLooksStrongerText
	text_end

OaksLabCharmanderPokeBallText:
	text_asm
	memset wRivalStarterTemp, STARTER2
	memset wRivalStarterBallSpriteIndex, OAKSLAB_SQUIRTLE_POKE_BALL
	ld a, STARTER1
	ld b, OAKSLAB_CHARMANDER_POKE_BALL
	jr OaksLabSelectedPokeBallScript

OaksLabSquirtlePokeBallText:
	text_asm
	memset wRivalStarterTemp, STARTER3
	memset wRivalStarterBallSpriteIndex, OAKSLAB_BULBASAUR_POKE_BALL
	ld a, STARTER2
	ld b, OAKSLAB_SQUIRTLE_POKE_BALL
	jr OaksLabSelectedPokeBallScript

OaksLabBulbasaurPokeBallText:
	text_asm
	memset wRivalStarterTemp, STARTER1
	memset wRivalStarterBallSpriteIndex, OAKSLAB_CHARMANDER_POKE_BALL
	ld a, STARTER3
	ld b, OAKSLAB_BULBASAUR_POKE_BALL

OaksLabSelectedPokeBallScript:
	ld [wCurPartySpecies], a
	ld [wPokedexNum], a
	ld a, b
	ld [wSpriteIndex], a
	CheckEvent EVENT_GOT_STARTER
	iftrue OaksLabLastMonScript
	CheckEventReuseA EVENT_OAK_ASKED_TO_CHOOSE_MON
	jr nz, OaksLabShowPokeBallPokemonScript
	writetext OaksLabThoseArePokeBallsText
	jp TextScriptEnd

OaksLabThoseArePokeBallsText:
	text_far _OaksLabThoseArePokeBallsText
	text_end

OaksLabShowPokeBallPokemonScript:
	memseth hSpriteIndex, OAKSLAB_OAK1
	memseth hSpriteDataOffset, SPRITESTATEDATA1_FACINGDIRECTION
	call GetPointerWithinSpriteStateData1
	ld [hl], SPRITE_FACING_DOWN
	
	memseth hSpriteIndex, OAKSLAB_RIVAL
	memseth hSpriteDataOffset, SPRITESTATEDATA1_FACINGDIRECTION
	call GetPointerWithinSpriteStateData1
	ld [hl], SPRITE_FACING_RIGHT
	setbit wStatusFlags5, BIT_NO_TEXT_DELAY
	predef StarterDex
	resetbit wStatusFlags5, BIT_NO_TEXT_DELAY
	call ReloadMapData
	waitframes 10
	checkmem wSpriteIndex
	ifeq OAKSLAB_CHARMANDER_POKE_BALL, OaksLabYouWantCharmanderText
	ifeq OAKSLAB_SQUIRTLE_POKE_BALL, OaksLabYouWantSquirtleText
	jr OaksLabYouWantBulbasaurText

OaksLabYouWantCharmanderText:
	ld hl, .Text
	jr OaksLabMonChoiceMenu
.Text:
	text_far _OaksLabYouWantCharmanderText
	text_end

OaksLabYouWantSquirtleText:
	ld hl, .Text
	jr OaksLabMonChoiceMenu
.Text:
	text_far _OaksLabYouWantSquirtleText
	text_end

OaksLabYouWantBulbasaurText:
	ld hl, .Text
	jr OaksLabMonChoiceMenu
.Text:
	text_far _OaksLabYouWantBulbasaurText
	text_end

OaksLabMonChoiceMenu:
	call PrintText
	disablewaitbutton
	call YesNoChoice ; yes/no menu
	ifno OaksLabMonChoiceEnd
	memset16 wPlayerStarter, wCurPartySpecies
	memset16 wNamedObjectIndex, wCurPartySpecies
	call GetMonName
	checkmem wSpriteIndex
	ifneq OAKSLAB_CHARMANDER_POKE_BALL, .not_charmander
	disappearobj HS_STARTER_BALL_1
	jr .continue
.not_charmander
	ifneq OAKSLAB_SQUIRTLE_POKE_BALL, .not_squirtle
	disappearobj HS_STARTER_BALL_2
	jr .continue
.not_squirtle
	disappearobj HS_STARTER_BALL_3
.continue
	disablewaitbutton
	writetext OaksLabMonEnergeticText
	writetext OaksLabReceivedMonText
	memset wMonDataLocation, 0 ; PLAYER_PARTY_DATA
	memset wCurEnemyLevel, 5
	memset16 wPokedexNum, wCurPartySpecies
	call AddPartyMon
	setbit wStatusFlags4, BIT_GOT_STARTER
	lockctrls_all
	memset wOaksLabCurScript, SCRIPT_OAKSLAB_CHOSE_STARTER_SCRIPT
OaksLabMonChoiceEnd:
	jp TextScriptEnd

OaksLabMonEnergeticText:
	text_far _OaksLabMonEnergeticText
	text_end

OaksLabReceivedMonText:
	text_far _OaksLabReceivedMonText
	sound_get_key_item
	text_end

OaksLabLastMonScript:
	memseth hSpriteIndex, OAKSLAB_OAK1
	memseth hSpriteDataOffset, SPRITESTATEDATA1_FACINGDIRECTION
	call GetPointerWithinSpriteStateData1
	ld [hl], SPRITE_FACING_DOWN
	writetext OaksLabLastMonText
	jp TextScriptEnd

OaksLabLastMonText:
	text_far _OaksLabLastMonText
	text_end

OaksLabOak1Text:
	text_asm
	CheckEvent EVENT_PALLET_AFTER_GETTING_POKEBALLS
	jr nz, .already_got_poke_balls
	ld hl, wPokedexOwned
	ld b, wPokedexOwnedEnd - wPokedexOwned
	call CountSetBits
	ld a, [wNumSetBits]
	cp 2
	jr c, .check_for_poke_balls
	CheckEvent EVENT_GOT_POKEDEX
	jr z, .check_for_poke_balls
.already_got_poke_balls
	ld hl, .HowIsYourPokedexComingText
	call PrintText
	ld a, $1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	predef DisplayDexRating
	jp .done
.check_for_poke_balls
	ld b, POKE_BALL
	call IsItemInBag
	jr nz, .come_see_me_sometimes
	CheckEvent EVENT_BEAT_ROUTE22_RIVAL_1ST_BATTLE
	jr nz, .give_poke_balls
	CheckEvent EVENT_GOT_POKEDEX
	jr nz, .mon_around_the_world
	CheckEventReuseA EVENT_BATTLED_RIVAL_IN_OAKS_LAB
	jr nz, .check_got_parcel
	ld a, [wStatusFlags4]
	bit BIT_GOT_STARTER, a
	jr nz, .already_got_pokemon
	ld hl, .WhichPokemonDoYouWantText
	call PrintText
	jr .done
.already_got_pokemon
	ld hl, .YourPokemonCanFightText
	call PrintText
	jr .done
.check_got_parcel
	ld b, OAKS_PARCEL
	call IsItemInBag
	jr nz, .got_parcel
	ld hl, .RaiseYourYoungPokemonText
	call PrintText
	jr .done
.got_parcel
	ld hl, .DeliverParcelText
	call PrintText
	call OaksLabScript_RemoveParcel
	ld a, SCRIPT_OAKSLAB_RIVAL_ARRIVES_AT_OAKS_REQUEST
	ld [wOaksLabCurScript], a
	jr .done
.mon_around_the_world
	ld hl, .PokemonAroundTheWorldText
	call PrintText
	jr .done
.give_poke_balls
	CheckAndSetEvent EVENT_GOT_POKEBALLS_FROM_OAK
	jr nz, .come_see_me_sometimes
	lb bc, POKE_BALL, 5
	call GiveItem
	ld hl, .GivePokeballsText
	call PrintText
	jr .done
.come_see_me_sometimes
	ld hl, .ComeSeeMeSometimesText
	call PrintText
.done
	jp TextScriptEnd

.WhichPokemonDoYouWantText:
	text_far _OaksLabOak1WhichPokemonDoYouWantText
	text_end

.YourPokemonCanFightText:
	text_far _OaksLabOak1YourPokemonCanFightText
	text_end

.RaiseYourYoungPokemonText:
	text_far _OaksLabOak1RaiseYourYoungPokemonText
	text_end

.DeliverParcelText:
	text_far _OaksLabOak1DeliverParcelText
	sound_get_key_item
	text_far _OaksLabOak1ParcelThanksText
	text_end

.PokemonAroundTheWorldText:
	text_far _OaksLabOak1PokemonAroundTheWorldText
	text_end

.GivePokeballsText:
	text_far _OaksLabOak1ReceivedPokeballsText
	sound_get_key_item
	text_far _OaksLabGivePokeballsExplanationText
	text_end

.ComeSeeMeSometimesText:
	text_far _OaksLabOak1ComeSeeMeSometimesText
	text_end

.HowIsYourPokedexComingText:
	text_far _OaksLabOak1HowIsYourPokedexComingText
	text_end

OaksLabPokedexText:
	text_asm
	ld hl, .Text
	call PrintText
	jp TextScriptEnd

.Text:
	text_far _OaksLabPokedexText
	text_end

OaksLabOak2Text:
	text_far _OaksLabOak2Text
	text_end

OaksLabGirlText:
	text_asm
	ld hl, .Text
	call PrintText
	jp TextScriptEnd

.Text:
	text_far _OaksLabGirlText
	text_end

OaksLabRivalFedUpWithWaitingText:
	text_asm
	ld hl, .Text
	call PrintText
	jp TextScriptEnd

.Text:
	text_far _OaksLabRivalFedUpWithWaitingText
	text_end

OaksLabOakChooseMonText:
	text_asm
	ld hl, .Text
	call PrintText
	jp TextScriptEnd

.Text:
	text_far _OaksLabOakChooseMonText
	text_end

OaksLabRivalWhatAboutMeText:
	text_asm
	ld hl, .Text
	call PrintText
	jp TextScriptEnd

.Text:
	text_far _OaksLabRivalWhatAboutMeText
	text_end

OaksLabOakBePatientText:
	text_asm
	ld hl, .Text
	call PrintText
	jp TextScriptEnd

.Text:
	text_far _OaksLabOakBePatientText
	text_end

OaksLabOakDontGoAwayYetText:
	text_asm
	ld hl, .Text
	call PrintText
	jp TextScriptEnd

.Text:
	text_far _OaksLabOakDontGoAwayYetText
	text_end

OaksLabRivalIllTakeThisOneText:
	text_asm
	ld hl, .Text
	call PrintText
	jp TextScriptEnd

.Text:
	text_far _OaksLabRivalIllTakeThisOneText
	text_end

OaksLabRivalReceivedMonText:
	text_asm
	ld hl, .Text
	call PrintText
	jp TextScriptEnd

.Text:
	text_far _OaksLabRivalReceivedMonText
	sound_get_key_item
	text_end

OaksLabRivalIllTakeYouOnText:
	text_asm
	ld hl, .Text
	call PrintText
	jp TextScriptEnd

.Text:
	text_far _OaksLabRivalIllTakeYouOnText
	text_end

OaksLabRivalIPickedTheWrongPokemonText:
	text_far _OaksLabRivalIPickedTheWrongPokemonText
	text_end

OaksLabRivalAmIGreatOrWhatText:
	text_far _OaksLabRivalAmIGreatOrWhatText
	text_end

OaksLabRivalSmellYouLaterText:
	text_asm
	ld hl, .Text
	call PrintText
	jp TextScriptEnd

.Text:
	text_far _OaksLabRivalSmellYouLaterText
	text_end

OaksLabRivalGrampsText:
	text_far _OaksLabRivalGrampsText
	text_end

OaksLabRivalWhatDidYouCallMeForText:
	text_far _OaksLabRivalWhatDidYouCallMeForText
	text_end

OaksLabOakIHaveARequestText:
	text_far _OaksLabOakIHaveARequestText
	text_end

OaksLabOakMyInventionPokedexText:
	text_far _OaksLabOakMyInventionPokedexText
	text_end

OaksLabOakGotPokedexText:
	text_far _OaksLabOakGotPokedexText
	sound_get_key_item
	text_end

OaksLabOakThatWasMyDreamText:
	text_far _OaksLabOakThatWasMyDreamText
	text_end

OaksLabRivalLeaveItAllToMeText:
	text_far _OaksLabRivalLeaveItAllToMeText
	text_end

OaksLabScientistText:
	text_asm
	ld hl, .Text
	call PrintText
	jp TextScriptEnd

.Text:
	text_far _OaksLabScientistText
	text_end
