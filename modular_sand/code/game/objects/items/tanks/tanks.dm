/obj/item/tank/Initialize()
	. = ..()
	if(tank_holder_icon_state)
		AddComponent(/datum/component/container_item/tank_holder, tank_holder_icon_state)
