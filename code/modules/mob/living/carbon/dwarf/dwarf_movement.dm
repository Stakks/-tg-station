/mob/living/carbon/dwarf/movement_delay()
	if(dna)
		. += dna.species.movement_delay(src)

	. += ..()
	. += config.human_delay

	//This part is based on Baycode. |- Ricotez

//If we're riding in a wheelchair or we have no legs, we need to only check our hands.

	if(istype(buckled, /obj/structure/stool/bed/chair/wheelchair))
		. += get_penalty_for_limb("l_arm")
		. += get_penalty_for_limb("r_arm")
//If we're not, we need to check our legs.
	else
		if(!get_num_legs()) //Make them crawl slower if no arms
			.+= get_penalty_for_limb("l_arm")
			.+= get_penalty_for_limb("r_arm")
		. += get_penalty_for_limb("l_leg")
		. += get_penalty_for_limb("r_leg")

mob/living/carbon/dwarf/proc/get_penalty_for_limb(limb)
	var/datum/organ/limb/E = organsystem.get_organ(limb)
	//Doubled values because we don't have separate arms/hands and legs/feet yet. Obviously need to be halved once that is the case.
	if(!E || !E.exists())
		. += 8
	if(E.status & ORGAN_SPLINTED)
		. += 1
	else if(E.status & ORGAN_BROKEN)
		. += 3

/mob/living/carbon/dwarf/Process_Spacemove(var/movement_dir = 0)

	if(..())
		return 1

	//Do we have a working jetpack
	if(istype(back, /obj/item/weapon/tank/jetpack) && isturf(loc)) //Second check is so you can't use a jetpack in a mech
		var/obj/item/weapon/tank/jetpack/J = back
		if((movement_dir || J.stabilization_on) && J.allow_thrust(0.01, src))
			return 1

	return 0


/mob/living/carbon/dwarf/slip(var/s_amount, var/w_amount, var/obj/O, var/lube)
	if(isobj(shoes) && (shoes.flags&NOSLIP) && !(lube&GALOSHES_DONT_HELP))
		return 0
	.=..()

/mob/living/carbon/dwarf/mob_has_gravity()
	. = ..()
	if(!.)
		if(mob_negates_gravity())
			. = 1

/mob/living/carbon/dwarf/mob_negates_gravity()
	return shoes && shoes.negates_gravity()

/mob/living/carbon/dwarf/Move(NewLoc, direct)
	..()
	if(dna)
		for(var/datum/mutation/human/HM in dna.mutations)
			HM.on_move(src, NewLoc)

	if(shoes)
		if(!lying)
			if(loc == NewLoc)
				if(!has_gravity(loc))
					return
				var/obj/item/clothing/shoes/S = shoes
				S.step_action()


/mob/living/carbon/dwarf/experience_pressure_difference()
	playsound(src, 'sound/effects/space_wind.ogg', 50, 1)
	if(shoes)
		if(shoes.flags&NOSLIP)
			return 0
	. = ..()