/mob/living/carbon/dwarf/attack_hulk(mob/living/carbon/human/user)
	if(user.a_intent == "harm")
		..(user, 1)
		adjustBruteLoss(5)
		Weaken(4)

/mob/living/carbon/dwarf/attack_hulk(mob/living/carbon/dwarf/user)
	if(user.a_intent == "harm")
		..(user, 1)
		adjustBruteLoss(10)
		Weaken(8)

/mob/living/carbon/dwarf/attack_hand(mob/living/carbon/human/M)
	if(ismommi(M))
		return


	if(..())	//to allow surgery to return properly.
		return

	if(dna)
		dna.species.spec_attack_hand(M, src)

	return

/mob/living/carbon/dwarf/attack_hand(mob/living/carbon/dwarf/M)
	if(ismommi(M))
		return


	if(..())	//to allow surgery to return properly.
		return

	if(dna)
		dna.species.spec_attack_hand(M, src)

	return


/mob/living/carbon/dwarf/proc/afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, inrange, params)
	return