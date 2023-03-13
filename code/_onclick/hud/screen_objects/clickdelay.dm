/mob
	// CLICKDELAY AND RELATED
	// Generic clickdelay - Hybrid time-since-last-attack and time-to-next-attack system.
	// next_action is a hard cooldown, as Click()s will not pass unless it is passed.
	// last_action is not a hard cooldown and different items can check for different delays.
	/// Generic clickdelay variable. Marks down the last world.time we did something that should cause or impact generic clickdelay. This should be directly set or set using [DelayNextAction()]. This should only be checked using [CheckActionCooldown()].
	var/last_action = 0
	/**
	  * The difference between the above and this is this is set immediately before even the pre-attack begins to ensure clickdelay is respected.
	  * Then, it is flushed or discarded using [FlushLastAttack()] or [DiscardLastAttack()] respectively.
	  */

	var/last_action_immediate = 0
	/// Generic clickdelay variable. Next world.time we should be able to do something that respects generic clickdelay. This should be set using [DelayNextAction()] This should only be checked using [CheckActionCooldown()].
	var/next_action = 0
	/// Ditto
	var/next_action_immediate = 0
	/// Default clickdelay for an UnarmedAttack() that successfully passes. Respects action_cooldown_mod.
	var/unarmed_attack_speed = CLICK_CD_MELEE
	/// Simple modification variable multiplied to next action modifier on adjust and on checking time since last action using [CheckActionCooldown()].
	/// This should only be manually modified using multipliers.
	var/action_cooldown_mod = 1
	/// Simple modification variable added to amount on adjust and on checking time since last action using [CheckActionCooldown()].
	/// This should only be manually modified via addition.
	var/action_cooldown_adjust = 0

	// Resisting - While resisting will give generic clickdelay, it is also on its own resist delay system. However, resisting does not check generic movedelay.
	// Resist cooldown should only be set at the start of a resist chain - whether this is clicking an alert button, pressing or hotkeying the resist button, or moving to resist out of a locker.
	/*
	 * Special clickdelay variable for resisting. Last time we did a special action like resisting. This should only be set using [MarkResistTime()].
	 * Use [CheckResistCooldown()] to check cooldowns, this should only be used for the resist action bar visual.
	 */
	var/last_resist = 0
	/// How long we should wait before allowing another resist. This should only be manually modified using multipliers.
	var/resist_cooldown = CLICK_CD_RESIST
	/// Minimum world time for another resist. This should only be checked using [CheckResistCooldown()].
	var/next_resist = 0
	/// Simple modification variable multiplied to next action modifier on adjust and on checking time since last action using [CheckActionCooldown()].
	/// This should only be manually modified using multipliers.
	var/action_cooldown_mod = 1
	/// Simple modification variable added to amount on adjust and on checking time since last action using [CheckActionCooldown()].
	/// This should only be manually modified via addition.
	var/action_cooldown_adjust = 0

/atom/movable/screen/action_bar

/atom/movable/screen/action_bar/Destroy()
	STOP_PROCESSING(SShuds, src)
	return ..()

/atom/movable/screen/action_bar/proc/mark_dirty()
	var/mob/living/L = hud?.mymob
	if(L?.client && update_to_mob(L))
		START_PROCESSING(SShuds, src)

/atom/movable/screen/action_bar/process()
	var/mob/living/L = hud?.mymob
	if(!L?.client || !update_to_mob(L))
		return PROCESS_KILL

/atom/movable/screen/action_bar/proc/update_to_mob(mob/living/L)
	return FALSE

/datum/hud/var/atom/movable/screen/action_bar/clickdelay/clickdelay

/atom/movable/screen/action_bar/clickdelay
	name = "click delay"
	icon = 'icons/effects/progessbar.dmi'
	icon_state = "prog_bar_100"
	layer = 20		// under hand buttons

/atom/movable/screen/action_bar/clickdelay/Initialize(mapload)
	. = ..()
	var/matrix/M = new
	M.Scale(2, 1)
	transform = M

/atom/movable/screen/action_bar/clickdelay/update_to_mob(mob/living/L)
	var/estimated = L.EstimatedNextActionTime()
	var/diff = estimated - L.last_action
	var/left = estimated - world.time
	if(left < 0 || diff < 0)
		icon_state = "prog_bar_100"
		return FALSE
	icon_state = "prog_bar_[round(clamp(((diff - left)/diff) * 100, 0, 100), 5)]"
	return TRUE

/datum/hud/var/atom/movable/screen/action_bar/resistdelay/resistdelay

/atom/movable/screen/action_bar/resistdelay
	name = "resist delay"
	icon = 'icons/effects/progessbar.dmi'
	icon_state = "prog_bar_100"

/atom/movable/screen/action_bar/resistdelay/update_to_mob(mob/living/L)
	var/diff = L.next_resist - L.last_resist
	var/left = L.next_resist - world.time
	if(left < 0 || diff < 0)
		icon_state = "prog_bar_100"
		return FALSE
	icon_state = "prog_bar_[round(clamp(((diff - left)/diff) * 100, 0, 100), 5)]"
	return TRUE
