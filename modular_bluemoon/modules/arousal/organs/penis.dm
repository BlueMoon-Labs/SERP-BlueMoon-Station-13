/obj/item/organ/external/genital/penis
	name = "penis"
	desc = "A male reproductive organ."
	icon_state = "penis"
	icon = 'icons/obj/genitals/penis.dmi'
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_PENIS
	mutantpart_key = ORGAN_SLOT_PENIS
	mutantpart_info = list(MUTANT_INDEX_NAME = "Human", MUTANT_INDEX_COLOR_LIST = list("#FFEEBB"))
	drop_when_organ_spilling = FALSE
	masturbation_verb = "stroke"
	arousal_verb = "У тебя сильный стояк"
	unarousal_verb = "Твой стояк опускается"
	genital_flags = CAN_MASTURBATE_WITH|CAN_CLIMAX_WITH|GENITAL_CAN_AROUSE|UPDATE_OWNER_APPEARANCE|GENITAL_UNDIES_HIDDEN|GENITAL_CAN_TAUR|CAN_CUM_INTO|HAS_EQUIPMENT
	linked_organ_slot = ORGAN_SLOT_TESTICLES
	fluid_transfer_factor = 0.5
	shape = DEF_COCK_SHAPE
	size = 2 //arbitrary value derived from length and diameter for sprites.
	layer_index = PENIS_LAYER_INDEX
	var/length = 6 //inches
	var/sheath = SHEATH_NONE
	var/prev_length = 6 //really should be renamed to prev_length
	var/diameter = 4
	var/diameter_ratio = COCK_DIAMETER_RATIO_DEF //0.25; check citadel_defines.dm
	bodypart_overlay = /datum/bodypart_overlay/mutant/genital/penis

/datum/bodypart_overlay/mutant/genital/penis
	feature_key = ORGAN_SLOT_PENIS
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND

/obj/item/organ/external/genital/penis/build_from_accessory(datum/sprite_accessory/genital/accessory, datum/dna/DNA)
	var/datum/sprite_accessory/genital/penis/snake = accessory
	if(snake.can_have_sheath)
		sheath = DNA.features["penis_sheath"]
	if(DNA.features["genitals_use_skintone"])
		uses_skintones = accessory.has_skintone_shading

/obj/item/organ/external/genital/penis/modify_size(modifier, min = -INFINITY, max = INFINITY)
	var/new_value = clamp(length + modifier, min, max)
	if(new_value == length)
		return
	prev_length = length
	length = clamp(length + modifier, min, max)
	update()
	..()

/obj/item/organ/external/genital/penis/update_size(modified = FALSE)
	if(length <= 0)//I don't actually know what round() does to negative numbers, so to be safe!!
		if(owner)
			to_chat(owner, "<span class='warning'>Вы чувствуете, как ваш пенис уменьшается в размерах по сравнению с вашим телом, а пах становится плоским!</b></span>")
		QDEL_IN(src, 1)
		if(linked_organ)
			QDEL_IN(linked_organ, 1)
		return
	var/rounded_length = round(length)
	var/new_size
	switch(rounded_length)
		if(0 to 12) //If modest size
			new_size = 1
		if(13 to 24) //If large
			new_size = 2
		if(23 to 50) //If massive
			new_size = 3
		if(51 to 90) //If comical
			new_size = 4 //no new sprites for anything larger yet //Now there is :3
		if(91 to INFINITY)
			new_size = 5

	if(linked_organ)
		linked_organ.size = clamp(size, BALLS_SIZE_MIN, BALLS_SIZE_MAX) //SPLURT Edit. No more randomly massive balls
		linked_organ.update()
	size = new_size

	if(owner)
		if (round(length) > round(prev_length))
			to_chat(owner, "<span class='warning'>Твой [pick(GLOB.dick_nouns)] начинает [pick("разбухать до", "расцветать до", "расширяться до", "пухнуть до", "расти с нетерпением до", "увеличиваться до")] [uppertext(round(length*get_size(owner)))]-см. Да!</b></span>")
		else if ((round(length) < round(prev_length)) && (length > 0.5))
			to_chat(owner, "<span class='warning'>Твой [pick(GLOB.dick_nouns)] начинает [pick("уменьшаться до", "сдуваться до", "колебаться до", "сокращаться до", "сморщиваться с сожалением до", "сдуваться до")] [uppertext(round(length*get_size(owner)))]-см. Не-ет!</b></span>")
	icon_state = sanitize_text("penis_[shape]_[size]")
	diameter = (length * diameter_ratio)//Is it just me or is this ludicous, why not make it exponentially decay?

/obj/item/organ/external/genital/penis/get_sprite_size_string()
	if(aroused_state != AROUSAL_FULL && sheath != SHEATH_NONE) //Sheath time!
		var/poking_out = 0
		if(aroused_state == AROUSAL_PARTIAL)
			poking_out = 1
		return "[lowertext(sheath)]_[poking_out]"

	var/size_affix
	var/measured_size = FLOOR(genital_size,1)
	var/is_erect = 0
	if(aroused_state == AROUSAL_FULL)
		is_erect = 1
	if(measured_size < 1)
		measured_size = 1
	switch(measured_size)
		if(0 to 12)
			size_affix = 1
		if(13 to 24)
			size_affix = 2
		if(23 to 50)
			size_affix = 3
		if(51 to 90)
			size_affix = 4
		if(91 to INFINITY)
			size_affix = 5

	var/passed_string = "[shape]_[size_affix]_[is_erect]"
	if(uses_skintones)
		passed_string += "_s"
	return passed_string

/obj/item/organ/external/genital/penis/build_from_dna(datum/dna/DNA, associated_key)
	length = DNA.features["cock_length"]
	uses_skintones = DNA.features["genitals_use_skintone"]
	update_size(DNA.features["cock_diameter_ratio"])

	return ..()

/obj/item/organ/external/genital/penis/update_appearance()
	. = ..()
	var/datum/sprite_accessory/genital/S = GLOB.cock_shapes_list[shape]
	var/icon_shape = S ? S.icon_state : "human"
	if(aroused_state != AROUSAL_FULL && sheath != SHEATH_NONE) //Sheath time!
		if(aroused_state == AROUSAL_NONE)
			aroused_state = 1
		return "penis_[lowertext(sheath)]_[aroused_state]"
	else icon_state = "penis_[icon_shape]_[size]"
	var/lowershape = lowertext(shape)

	if(owner)
		if(owner.dna.species.use_skintones && owner.dna.features["genitals_use_skintone"])
			if(ishuman(owner)) // Check before recasting type, although someone fucked up if you're not human AND have use_skintones somehow...
				var/mob/living/carbon/human/H = owner // only human mobs have skin_tone, which we need.
				color = SKINTONE2HEX(H.skin_tone)
				if(!H.dna.skin_tone_override)
					icon_state += "_s"
		else
			color = "#[owner.dna.features["cock_color"]]"
		if(genital_flags & GENITAL_CAN_TAUR && S?.taur_icon && (!S.feat_taur || owner.dna.features[S.feat_taur]) && owner.dna.species.mutant_bodyparts["taur"])
			var/datum/sprite_accessory/taur/T = GLOB.taur_list[owner.dna.features["taur"]]
			if(T.taur_mode & S.accepted_taurs) //looks out of place on those.
				lowershape = "крупный таурский, [lowershape]"

	desc = "Вы наблюдаете [lowershape] [aroused_state ? "эрегированный" : "висящий"] [pick(GLOB.dick_nouns)]. По вашим оценкам, он примерно [round(length*get_size(owner), 0.25)] [round(length*get_size(owner), 0.25) != 1 ? "" : ""] сантиметров в длину и [round(diameter*get_size(owner), 0.25)] [round(diameter*get_size(owner), 0.25) != 1 ? "" : ""] сантиметров в ширину."

/obj/item/organ/external/genital/penis/get_features(datum/sprite_accessory/genital/accessory, mob/living/carbon/human/H)
	var/datum/dna/D = H.dna
	var/datum/sprite_accessory/genital/penis/snake = accessory
	if(snake.can_have_sheath)
		sheath = D.features["penis_sheath"]
	if(D.species.use_skintones && D.features["genitals_use_skintone"])
		color = SKINTONE2HEX(H.skin_tone)
	else
		color = "#[D.features["cock_color"]]"
	length = D.features["cock_length"]
	diameter_ratio = D.features["cock_diameter_ratio"]
	shape = D.features["cock_shape"]
	prev_length = length
	toggle_visibility(D.features["cock_visibility"], FALSE)
	if(D.features["cock_stuffing"])
		toggle_visibility(GEN_ALLOW_EGG_STUFFING, FALSE)

/obj/item/organ/external/genital/penis/get_features(mob/living/carbon/human/H)
	. = ..()
	original_fluid_id = fluid_id
	fluid_max_volume += ((length - initial(length))*2.5)*(owner ? get_size(owner) : 1)
	fluid_rate += ((length - initial(length))/10)*(owner ? get_size(owner) : 1)

/obj/item/organ/external/genital/penis/climax_modify_size(mob/living/partner, obj/item/organ/external/genital/source_gen)
	if(!(owner.client?.prefs.read_preference(/datum/preference/toggle/erp/penis_enlargement)))
		return

	var/datum/reagents/fluid_source = source_gen.climaxable(partner)
	if(!fluid_source)
		return

	var/datum/reagents/target
	if(linked_organ)
		if(!linked_organ.climax_fluids)
			linked_organ.climax_fluids = new
			linked_organ.climax_fluids.maximum_volume = INFINITY
		target = linked_organ.climax_fluids
	else
		if(!climax_fluids)
			climax_fluids = new
			climax_fluids.maximum_volume = INFINITY
		target = climax_fluids

	source_gen.generate_fluid(fluid_source)
	fluid_source.trans_to(target, fluid_source.total_volume)

	if(target.total_volume >= fluid_max_volume * GENITAL_INFLATION_THRESHOLD)
		var/previous = size
		modify_size(target.total_volume / (fluid_max_volume * GENITAL_INFLATION_THRESHOLD))
		if(size != previous)
			owner.visible_message("<span class='lewd'>\The <b>[owner]</b> [pick(GLOB.dick_nouns)][linked_organ ? " и [pick(list("орехи", "яйца", "яички", "семенники", "мешочек"))]" : ""] набухают и увеличиваются в размерах по мере того, как они наполняются \the <b>[partner]</b>'s [lowertext(source_gen.get_fluid_name())]!</span>", ignored_mobs = owner.get_unconsenting())
			if(linked_organ)
				linked_organ.fluid_id = source_gen.get_fluid_id()
		target.clear_reagents()

/datum/bodypart_overlay/mutant/genital/penis/get_global_feature_list()
	return GLOB.sprite_accessories[ORGAN_SLOT_PENIS]

/datum/sprite_accessory/genital/penis
	icon = 'icons/obj/genitals/penis_onmob.dmi'
	organ_type = /obj/item/organ/external/genital/penis
	color_src = USE_MATRIXED_COLORS
	key = ORGAN_SLOT_PENIS
	always_color_customizable = TRUE
	center = TRUE
	special_icon_case = TRUE
	special_x_dimension = TRUE
	relevent_layers = list(BODY_BEHIND_LAYER, BODY_FRONT_LAYER)
	genetic = TRUE
	var/can_have_sheath = TRUE
	feat_taur = "penis_taur_mode"

/datum/sprite_accessory/genital/penis/none
	icon_state = "none"
	name = "None"
	factual = FALSE
	color_src = null

/datum/sprite_accessory/genital/penis/human
	icon_state = "human"
	name = "Human"
	can_have_sheath = FALSE
	has_skintone_shading = TRUE

/datum/sprite_accessory/genital/penis/knotted
	icon_state = "knotted"
	name = "Knotted"
	taur_icon = 'icons/obj/genitals/taur_penis_onmob.dmi'
	taur_dimension_x = 64

/datum/sprite_accessory/genital/penis/flared
	icon_state = "flared"
	name = "Flared"
	taur_icon = 'icons/obj/genitals/taur_penis_onmob.dmi'
	taur_dimension_x = 64

/datum/sprite_accessory/genital/penis/barbknot
	icon_state = "barbknot"
	name = "Barbknot"

/datum/sprite_accessory/genital/penis/tapered
	icon_state = "tapered"
	name = "Tapered"
	taur_icon = 'icons/obj/genitals/taur_penis_onmob.dmi'
	taur_dimension_x = 64

/datum/sprite_accessory/genital/penis/tentacle
	icon_state = "tentacle"
	name = "Tentacle"

/datum/sprite_accessory/genital/penis/hemi
	icon_state = "hemi"
	name = "Hemi"

/datum/sprite_accessory/genital/penis/hemiknot
	icon_state = "hemiknot"
	name = "Hemiknot"

/datum/sprite_accessory/genital/penis/thick
	icon_state = "thick"
	name = "Thick"
