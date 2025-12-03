CeladonMansionRoofHouse_Script:
	jp EnableAutoTextBoxDrawing

CeladonMansionRoofHouse_TextPointers:
	def_text_pointers
	dw_const CeladonMansionRoofHouseHikerText,         TEXT_CELADONMANSION_ROOF_HOUSE_HIKER
	dw_const CeladonMansionRoofHouseEeveePokeballText, TEXT_CELADONMANSION_ROOF_HOUSE_EEVEE_POKEBALL

CeladonMansionRoofHouseHikerText:
	text_far _CeladonMansionRoofHouseHikerText
	text_end

CeladonMansionRoofHouseEeveePokeballText:
	text_asm
	givepokemon EEVEE, 25
	jr nc, .party_full
	disappearobj HS_CELADON_MANSION_EEVEE_GIFT
.party_full
	jp TextScriptEnd
