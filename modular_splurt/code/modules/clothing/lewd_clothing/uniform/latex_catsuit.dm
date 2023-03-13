/obj/item/clothing/under/misc/latex_catsuit
	name = "latex catsuit"
	desc = "A shiny uniform that fits snugly to the skin."
	icon_state = "latex_catsuit_female"
	icon_state = "latex_catsuit"
	icon = 'modular_splurt/icons/obj/clothing/lewd_clothes/uniform/lewd_uniform.dmi'
	worn_icon = 'modular_splurt/icons/mob/clothing/lewd_clothing/uniform/lewd_uniform.dmi'
	worn_icon_digi = 'modular_splurt/icons/mob/clothing/lewd_clothing/uniform/lewd_uniform-digi.dmi'
	lefthand_file = 'modular_splurt/icons/mob/inhands/lewd_items/lewd_inhand_left.dmi'
	righthand_file = 'modular_splurt/icons/mob/inhands/lewd_items/lewd_inhand_right.dmi'
	can_adjust = FALSE
	strip_delay = 80
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION|STYLE_ALL_TAURIC
	var/seamless = FALSE

/obj/item/clothing/under/misc/latex_catsuit/attack_hand(mob/living/carbon/human/user)
	var/mob/living/carbon/human/C = user
	if(iscarbon(user) && seamless && (src == C.w_uniform))
		to_chat(C, span_purple(pick("Your hands uselessly roam across your rubber predicament and you fail to find a seam",
									"You find it impossible to leverage your fingers beneath the suit.",
									"The suit almost seems to be tightening away from your pointless clawing")))
		return

	else
		if(iscarbon(user) && src == C.w_uniform)
			if(!do_after(C, 60, target = src))
				return
	. = ..()

//some gender identification magic
/obj/item/clothing/under/misc/latex_catsuit/equipped(mob/living/carbon/human/U, slot)
	var/mob/living/carbon/human/C = U
	if(src == C.w_uniform)
		if(U.gender == FEMALE)
			icon_state = "latex_catsuit_female"
			C.update_inv_w_uniform()
			C.remove_overlay(HANDS_PART_LAYER)

		else
			icon_state = "latex_catsuit_male"
			C.update_inv_w_uniform()
			C.remove_overlay(HANDS_PART_LAYER)

	var/variation_flag = NONE
	var/datum/sprite_accessory/taur/T
	if(C.dna.species.mutant_bodyparts["taur"])
		T = GLOB.taur_list[C.dna.features["taur"]]

	if(T?.taur_mode && src == C.w_uniform)
		variation_flag |= src.supports_variations_flags & T.taur_mode || src.supports_variations_flags & T.alt_taur_mode
		switch(variation_flag)
			if(STYLE_TAUR_HOOF)
				worn_icon = 'modular_splurt/icons/mob/clothing/lewd_clothing/uniform/lewd_uniform-hoof.dmi'
				//worn_icon_digi = 'modular_splurt/icons/mob/clothing/lewd_clothing/uniform/lewd_uniform-hoof.dmi'
			if(STYLE_TAUR_SNAKE)
				worn_icon = 'modular_splurt/icons/mob/clothing/lewd_clothing/uniform/lewd_uniform-snake.dmi'
				//worn_icon_digi = 'modular_splurt/icons/mob/clothing/lewd_clothing/uniform/lewd_uniform-snake.dmi'
			if(STYLE_TAUR_PAW)
				worn_icon = 'modular_splurt/icons/mob/clothing/lewd_clothing/uniform/lewd_uniform-paw.dmi'
				//worn_icon_digi = 'modular_splurt/icons/mob/clothing/lewd_clothing/uniform/lewd_uniform-paw.dmi'

		worn_x_dimension = 64 //To fix the offset
		worn_y_dimension = 32
		C.update_inv_w_uniform()

	if(C.dna.species.mutant_bodyparts["taur"] && src == C.w_uniform)
		C.remove_overlay(BODY_BEHIND_LAYER)
		C.remove_overlay(BODY_FRONT_LAYER)
	. = ..()

/obj/item/clothing/under/misc/latex_catsuit/dropped(mob/living/U)
	. = ..()
	var/mob/living/carbon/human/C = U
	C.apply_overlay(HANDS_LAYER)
	if(C.dna.species.mutant_bodyparts["taur"] && src == C.w_uniform)
		C.apply_overlay(BODY_BEHIND_LAYER)
		C.apply_overlay(BODY_FRONT_LAYER)
	C.regenerate_icons() //Just in case

/obj/item/clothing/under/misc/latex_catsuit/MouseDrop(atom/over_object)

/obj/item/clothing/under/misc/latex_catsuit/attackby(obj/item/K, mob/user, params)
	if(istype(K, /obj/item/key/latex))
		if(seamless != FALSE)
			to_chat(user, span_warning("The suit suddenly loosens!"))
			seamless = FALSE
		else
			to_chat(user, span_warning("The suit suddenly tighten!"))
			seamless = TRUE
	return
