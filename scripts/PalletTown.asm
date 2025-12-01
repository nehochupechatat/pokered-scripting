PalletTown_Script:
	CheckEvent EVENT_GOT_POKEBALLS_FROM_OAK
	iffalse .next
	SetEvent EVENT_PALLET_AFTER_GETTING_POKEBALLS
.next
	call EnableAutoTextBoxDrawing
	ld hl, PalletTown_ScriptPointers
	ld a, [wPalletTownCurScript]
	jp CallFunctionInTable

PalletTown_ScriptPointers:
	def_script_pointers
	dw_const PalletTownDefaultScript,              SCRIPT_PALLETTOWN_DEFAULT
	dw_const PalletTownOakHeyWaitScript,           SCRIPT_PALLETTOWN_OAK_HEY_WAIT
	dw_const PalletTownOakWalksToPlayerScript,     SCRIPT_PALLETTOWN_OAK_WALKS_TO_PLAYER
	dw_const PalletTownOakNotSafeComeWithMeScript, SCRIPT_PALLETTOWN_OAK_NOT_SAFE_COME_WITH_ME
	dw_const PalletTownPlayerFollowsOakScript,     SCRIPT_PALLETTOWN_PLAYER_FOLLOWS_OAK
	dw_const PalletTownDaisyScript,                SCRIPT_PALLETTOWN_DAISY
	dw_const PalletTownNoopScript,                 SCRIPT_PALLETTOWN_NOOP

PalletTownDefaultScript:
	CheckEvent EVENT_FOLLOWED_OAK_INTO_LAB
	endiftrue
	checkmem wYCoord
	endifneq 1
	memseth hJoyHeld, 0
	memset wPlayerMovingDirection, PLAYER_DIR_DOWN
	playmusic MUSIC_MEET_PROF_OAK
	memset wJoyIgnore, PAD_SELECT | PAD_START | PAD_CTRL_PAD
	SetEvent EVENT_OAK_APPEARED_IN_PALLET
	; trigger the next script
	memset wPalletTownCurScript, SCRIPT_PALLETTOWN_OAK_HEY_WAIT
	ret

PalletTownOakHeyWaitScript:
	disablewaitbutton
	writetextm TEXT_PALLETTOWN_OAK ;writetextm necessary for map coord scripts!
	enablewaitbutton ; reset button wait back
	appearobj HS_PALLET_TOWN_OAK
	; trigger the next script
	memset wPalletTownCurScript, SCRIPT_PALLETTOWN_OAK_WALKS_TO_PLAYER
	ret

PalletTownOakWalksToPlayerScript:
	spritedir PALLETTOWN_OAK, SPRITE_FACING_UP
	call Delay3
	memset wYCoord, 1
	locateplayer ; load Oak's movement into wNPCMovementDirections2
	applymovement PALLETTOWN_OAK, wNPCMovementDirections2
	memset wJoyIgnore, PAD_BUTTONS | PAD_CTRL_PAD
	; trigger the next script
	memset wPalletTownCurScript, SCRIPT_PALLETTOWN_OAK_NOT_SAFE_COME_WITH_ME
	ret

PalletTownOakNotSafeComeWithMeScript:
	checkbit wStatusFlags5, BIT_SCRIPTED_NPC_MOVEMENT
	endiftrue
	memset wSpritePlayerStateData1FacingDirection, SPRITE_FACING_DOWN
	memset wOakWalkedToPlayer, TRUE
	memset wJoyIgnore, PAD_SELECT | PAD_START | PAD_CTRL_PAD
	writetextm TEXT_PALLETTOWN_OAK_UNSAFE
	
; set up movement script that causes the player to follow Oak to his lab
	memset wJoyIgnore, PAD_BUTTONS | PAD_CTRL_PAD
	memset wSpriteIndex, PALLETTOWN_OAK
	memset wNPCMovementScriptFunctionNum, 0
	memset wNPCMovementScriptPointerTableNum, 1
	ldh a, [hLoadedROMBank]
	ld [wNPCMovementScriptBank], a

	; trigger the next script
	memset wPalletTownCurScript, SCRIPT_PALLETTOWN_PLAYER_FOLLOWS_OAK
	ret

PalletTownPlayerFollowsOakScript:
	checkmem wNPCMovementScriptPointerTableNum
	checkbool
	endifboolunset

	; trigger the next script
	memset wPalletTownCurScript, SCRIPT_PALLETTOWN_DAISY
	ret

PalletTownDaisyScript:
	CheckEvent EVENT_DAISY_WALKING
	iftrue .next
	CheckBothEventsSet EVENT_GOT_TOWN_MAP, EVENT_ENTERED_BLUES_HOUSE, 1
	iftrue .next
	SetEvent EVENT_DAISY_WALKING
	disappearobj HS_DAISY_SITTING
	appearobj HS_DAISY_WALKING
.next
	CheckEvent EVENT_GOT_POKEBALLS_FROM_OAK
	endiffalse
	SetEvent EVENT_PALLET_AFTER_GETTING_POKEBALLS_2
PalletTownNoopScript:
	ret

PalletTown_TextPointers:
	def_text_pointers
	dw_const PalletTownOakText,              TEXT_PALLETTOWN_OAK
	dw_const PalletTownGirlText,             TEXT_PALLETTOWN_GIRL
	dw_const PalletTownFisherText,           TEXT_PALLETTOWN_FISHER
	dw_const PalletTownOaksLabSignText,      TEXT_PALLETTOWN_OAKSLAB_SIGN
	dw_const PalletTownSignText,             TEXT_PALLETTOWN_SIGN
	dw_const PalletTownPlayersHouseSignText, TEXT_PALLETTOWN_PLAYERSHOUSE_SIGN
	dw_const PalletTownRivalsHouseSignText,  TEXT_PALLETTOWN_RIVALSHOUSE_SIGN
	dw_const PalletTownOakItsUnsafeText,     TEXT_PALLETTOWN_OAK_UNSAFE

PalletTownOakText:
	text "OAK: Hey! Wait!"
	line "Don't go out!@"
	text_asm
		waitframes 10	
		showemote 0, EXCLAMATION_BUBBLE
		memset wPlayerMovingDirection, PLAYER_DIR_DOWN
		memset wJoyIgnore, PAD_BUTTONS | PAD_CTRL_PAD
		jp TextScriptEnd
	text_end

PalletTownGirlText:
	text "I'm raising"
	line "#MON too!"

	para "When they get"
	line "strong, they can"
	cont "protect me!"
	done
	text_end

PalletTownFisherText:
	text "Technology is"
	line "incredible!"

	para "You can now store"
	line "and recall items"
	cont "and #MON as"
	cont "data via PC!"
	done
	text_end

PalletTownOaksLabSignText:
	text "OAK #MON"
	line "RESEARCH LAB"
	done
	text_end

PalletTownSignText:
	text "PALLET TOWN"
	line "Shades of your"
	cont "journey await!"
	done
	text_end

PalletTownPlayersHouseSignText:
	text "<PLAYER>'s house "
	done
	text_end

PalletTownRivalsHouseSignText:
	text "<RIVAL>'s house "
	done
	text_end

PalletTownOakItsUnsafeText:
	text "OAK: It's unsafe!"
	line "Wild #MON live"
	cont "in tall grass!"

	para "You need your own"
	line "#MON for your"
	cont "protection."
	cont "I know!"

	para "Here, come with"
	line "me!"
	done