/obj/item/organ/external/genital/butt
	linked_organ_slot = ORGAN_SLOT_ANUS

/obj/item/organ/external/genital/butt/update_size()
	if(!linked_organ)
		return ..()

	linked_organ.size = size
	linked_organ.update()
	if(size < 0)
		QDEL_IN(linked_organ, 1)
	. = ..()

/obj/item/organ/external/genital/butt/toggle_visibility(visibility, update)
	. = ..()
	var/obj/item/organ/external/genital/anus/butthole = linked_organ
	if(!butthole?.is_exposed() || is_exposed())
		return .
	linked_organ.toggle_visibility(visibility)

/obj/item/organ/external/genital/butt/get_features(mob/living/carbon/human/H)
	. = ..()
	original_fluid_id = fluid_id
	fluid_max_volume += ((size - initial(size))*2.5)*(owner ? get_size(owner) : 1)
	fluid_rate += ((size - initial(size))/10)*(owner ? get_size(owner) : 1)

/obj/item/organ/external/genital/butt/climax_modify_size(mob/living/partner, obj/item/organ/external/genital/source_gen, from_belly = FALSE)
	if(!(owner.client?.prefs?.read_preference(/datum/preference/toggle/erp/butt_enlargement)))
		return

	var/datum/reagents/fluid_source = source_gen.climaxable()
	if(!fluid_source)
		return

	if(!climax_fluids)
		climax_fluids = new
		climax_fluids.maximum_volume = INFINITY

	source_gen.generate_fluid(fluid_source)
	fluid_source.trans_to(climax_fluids, fluid_source.total_volume)

	if(climax_fluids.total_volume >= fluid_max_volume * GENITAL_INFLATION_THRESHOLD)
		var/previous = size
		var/growth_amount = (from_belly ? min(climax_fluids.total_volume, 1) : climax_fluids.total_volume)
		var/list/asscheeks = list("попка", "ягодицы", "булочки", "подушечки", "шары Дамптрака", "[pick(list("покачивающиеся", "непоседливые", "шатающиеся"))] ягодицы")
		modify_size(growth_amount)
		if(size != previous)
			owner.visible_message("<span class='lewd'>\The [pick(GLOB.butt_nouns + asscheeks)] <b>[owner]</b> непристойно отскакивают наружу, как [owner.ru_who()] накачивают [lowertext(source_gen.get_fluid_name())] сзади!</span>", ignored_mobs = owner.get_unconsenting())
			fluid_id = source_gen.get_fluid_id()
		climax_fluids.clear_reagents()
