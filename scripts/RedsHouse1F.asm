RedsHouse1F_Script:
	jp EnableAutoTextBoxDrawing

RedsHouse1F_TextPointers:
	def_text_pointers
	dw_const RedsHouse1FMomText, TEXT_REDSHOUSE1F_MOM
	dw_const RedsHouse1FTVText,  TEXT_REDSHOUSE1F_TV

RedsHouse1FMomText:
	text_asm
	checkbit wStatusFlags4, BIT_GOT_STARTER
	iftrue .heal
	writetext .WakeUpText
	jr .done
.heal
	call RedsHouse1FMomHealScript
.done
	jp TextScriptEnd

.WakeUpText:
	text_far _RedsHouse1FMomWakeUpText
	text_end

RedsHouse1FMomHealScript:
	writetext RedsHouse1FMomYouShouldRestText
	call GBFadeOutToWhite
	call ReloadMapData
	playmusic MUSIC_PKMN_HEALED
	call WaitForSongToFinish
	playmapmusic
	call GBFadeInFromWhite
	writetext RedsHouse1FMomLookingGreatText


RedsHouse1FMomYouShouldRestText:
	text_far _RedsHouse1FMomYouShouldRestText
	text_end
RedsHouse1FMomLookingGreatText:
	text_far _RedsHouse1FMomLookingGreatText
	text_end

RedsHouse1FTVText:
	text_asm
	checkmem wSpritePlayerStateData1FacingDirection
	ifneq SPRITE_FACING_UP, .wrongside
	writetext StandByMeMovieText
	jp TextScriptEnd
.wrongside:
	writetext WrongSideText
	jp TextScriptEnd


StandByMeMovieText:
	text_far _RedsHouse1FTVStandByMeMovieText
	text_end

WrongSideText:
	text_far _RedsHouse1FTVWrongSideText
	text_end
