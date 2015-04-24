/obj/structure/dispenser
	name = "tank storage unit"
	desc = "A simple yet bulky storage device for gas tanks. Has room for up to ten oxygen tanks, and ten plasma tanks."
	icon = 'icons/obj/objects.dmi'
	icon_state = "dispenser"
	density = 1
	anchored = 1.0
	var/oxygentanks = 10
	var/plasmatanks = 10
	var/list/oxytanks = list()	//sorry for the similar var names
	var/list/platanks = list()


/obj/structure/dispenser/oxygen
	plasmatanks = 0

/obj/structure/dispenser/plasma
	oxygentanks = 0


/obj/structure/dispenser/New()
	update_icon()


/obj/structure/dispenser/update_icon()
	overlays.Cut()
	switch(oxygentanks)
		if(1 to 3)	overlays += "oxygen-[oxygentanks]"
		if(4 to INFINITY) overlays += "oxygen-4"
	switch(plasmatanks)
		if(1 to 4)	overlays += "plasma-[plasmatanks]"
		if(5 to INFINITY) overlays += "plasma-5"

/obj/structure/dispenser/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/dispenser/attack_hand(mob/user as mob)
	if(!user.IsAdvancedToolUser())
		user << "<span class='warning'>You don't have the dexterity to do this!</span>"
		return 1
	user.set_machine(src)
	var/dat = "[src]<br><br>"
	dat += "Oxygen tanks: [oxygentanks] - [oxygentanks ? "<A href='?src=\ref[src];oxygen=1'>Dispense</A>" : "empty"]<br>"
	dat += "Plasma tanks: [plasmatanks] - [plasmatanks ? "<A href='?src=\ref[src];plasma=1'>Dispense</A>" : "empty"]"
	user << browse(dat, "window=dispenser")
	onclose(user, "dispenser")
	return


/obj/structure/dispenser/attackby(obj/item/I as obj, mob/user as mob, params)
	if(istype(I, /obj/item/weapon/tank/internals/oxygen) || istype(I, /obj/item/weapon/tank/internals/air) || istype(I, /obj/item/weapon/tank/internals/anesthetic))
		if(oxygentanks < 10)
			user.drop_item()
			I.loc = src
			oxytanks.Add(I)
			oxygentanks++
			user << "<span class='notice'>You put [I] in [src].</span>"
		else
			user << "<span class='notice'>[src] is full.</span>"
	if(istype(I, /obj/item/weapon/tank/internals/plasma))
		if(plasmatanks < 10)
			user.drop_item()
			I.loc = src
			platanks.Add(I)
			plasmatanks++
			user << "<span class='notice'>You put [I] in [src].</span>"
		else
			user << "<span class='notice'>[src] is full.</span>"
	updateUsrDialog()


/obj/structure/dispenser/Topic(href, href_list)
	if(usr.stat || usr.restrained())
		return
	if(Adjacent(usr))
		usr.set_machine(src)
		if(href_list["oxygen"])
			if(oxygentanks > 0)
				var/obj/item/weapon/tank/internals/oxygen/O
				if(oxytanks.len == oxygentanks)
					O = oxytanks[1]
					oxytanks.Remove(O)
				else
					O = new /obj/item/weapon/tank/internals/oxygen(loc)
				O.loc = loc
				usr << "<span class='notice'>You take [O] out of [src].</span>"
				oxygentanks--
				update_icon()
		if(href_list["plasma"])
			if(plasmatanks > 0)
				var/obj/item/weapon/tank/internals/plasma/P
				if(platanks.len == plasmatanks)
					P = platanks[1]
					platanks.Remove(P)
				else
					P = new /obj/item/weapon/tank/internals/plasma(loc)
				P.loc = loc
				usr << "<span class='notice'>You take [P] out of [src].</span>"
				plasmatanks--
				update_icon()
		add_fingerprint(usr)
		updateUsrDialog()
	else
		usr << browse(null, "window=dispenser")
		return
	return