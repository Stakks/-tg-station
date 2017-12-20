/*
 HUMANS
*/

/datum/species/human
	name = "Human"
	id = "human"
	roundstart = 1
	specflags = list(EYECOLOR,HAIR,FACEHAIR,LIPS,MUTCOLORS)
	use_skintones = 1

/datum/species/human/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "mutationtoxin")
		H << "<span class='danger'>Your flesh rapidly mutates!</span>"
		hardset_dna(H, null, null, null, null, /datum/species/slime)
		H.regenerate_icons()
		H.reagents.del_reagent(chem.type)
		H.faction |= "slime"
		return 1

/*
 DORFS
*/

/datum/species/dwarf
	name = "Dwarf"
	id = "dwarf"
	roundstart = 0
	nojumpsuit = 1
	darksight = 1
	default_color = "E8B59B"
	speedmod = 0.75
	brutemod = 0.75
	burnmod = 0.75
	coldmod = 0.25
	heatmod = 1.50
	punchmod = 5
	safe_toxins_max = 8
	cold_slow = 200
	hot_slow = 420
	specflags = list(EYECOLOR,HAIR,FACEHAIR,LIPS,MUTCOLORS,HARDFEET)
	use_skintones = 0
	/mob/living/carbon/human/HasDisease(var/datum/disease/dwarfism)
	/mob/living/carbon/human/add_organ(var/datum/organ/internal/dwarf/liver)

/datum/species/dwarf/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "mutationtoxin")
		H << "<span class='danger'>Your flesh rapidly mutates!</span>"
		hardset_dna(H, null, null, null, null, /datum/species/slime)
		H.regenerate_icons()
		H.reagents.del_reagent(chem.type)
		H.faction |= "slime"
		return 1

/*
 LIZARDPEOPLE
*/

/datum/species/lizard
	// Reptilian humanoids with scaled skin and tails.
	name = "Lizardperson"
	id = "lizard"
	say_mod = "hisses"
	default_color = "00FF00"
	roundstart = 1
	specflags = list(EYECOLOR,LIPS,MUTCOLORS)
	mutant_bodyparts = list("tail", "snout")
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/lizard

	warmblooded = 0			//Can't stabilize their temperature

	//Hibernation vars
	var/hibernating = 0
	var/hiberncounter = 0	//Incremented when in cold
	var/hibernsleep = 20		//When will you fall unconscious?
	var/hibernmax = 40		//How deep do you hibernate?

	coldmod = 1
	heatmod = 1

	//Might be too prohibitive, needs testing. Room temperature is roughly T20C. Might want to increase base speed just a bit too.
	heat_damage_limit = T0C+60
	cold_damage_limit = T0C-20
	//May be too prohibitive
	cold_slow = T0C+25
	hot_slow = T0C+35

	base_hunger_rate = HUNGER_FACTOR/2

/datum/species/lizard/handle_speech(message)
	// jesus christ why
	if(copytext(message, 1, 2) != "*")
		message = replacetext(message, "s", "sss")

	return message

/datum/species/lizard/spec_life(mob/living/carbon/human/H)
	if(H.bodytemperature < T0C+5)
		hiberncounter++
		hiberncounter += max(round((cold_slow-10 - H.bodytemperature)/10),3)	//each 10 degrees below 15 increments by one
	else
		hiberncounter += max(round((cold_slow-20 - H.bodytemperature)/10),-3)	//each 10 degrees above 5 decrements by one
	hiberncounter = min(max(hiberncounter, 0), hibernmax)

	if(hiberncounter && !hibernating)
		H.health_status.vision_blurry = max(round(hiberncounter/4), H.health_status.vision_blurry)

	if(hiberncounter >= hibernsleep)
		if(!H.sleeping)
			H.sleeping += 1
		H.sleeping += 1
		if(H.sleeping)
			hibernating = 1

			//Good temperature resistance when hibernating
			coldmod = 0.5
			heatmod = 0.5

	if(hiberncounter < hibernsleep && hibernating)
		H.sleeping = max( H.sleeping - 1, 0)
		if(!H.sleeping)
			hibernating = 0
			coldmod = 1
			heatmod = 1
/*
 PLANTPEOPLE
*/

/datum/species/plant
	// Creatures made of leaves and plant matter.
	name = "Sentient Vegetable"
	id = "plant"
	roundstart = 1
	default_color = "59CE00"
	specflags = list(EYECOLOR,MUTCOLORS)
	attack_verb = "slice"
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	burnmod = 1.25
	heatmod = 1.5
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/plant

/datum/species/plant/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "plantbgone")
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1

/datum/species/plant/on_hit(proj_type, mob/living/carbon/human/H)
	switch(proj_type)
		if(/obj/item/projectile/energy/floramut)
			if(prob(15))
				H.apply_effect((rand(30,80)),IRRADIATE)
				H.Weaken(5)
				for (var/mob/V in viewers(H))
					V.show_message("<span class='danger'>[H] writhes in pain as \his vacuoles boil.</span>", 3, "<span class='danger'>You hear the crunching of leaves.</span>", 2)
				if(prob(80))
					randmutb(H)
					domutcheck(H,null)
				else
					randmutg(H)
					domutcheck(H,null)
			else
				H.adjustFireLoss(rand(5,15))
				H.show_message("<span class='danger'>The radiation beam singes you!</span>")
		if(/obj/item/projectile/energy/florayield)
			H.nutrition = min(H.nutrition+30, NUTRITION_LEVEL_FULL)
	return

/*
 PODPEOPLE
*/

/datum/species/plant/pod
	// A mutation caused by a human being ressurected in a revival pod. These regain health in light, and begin to wither in darkness.
	name = "Podperson"
	id = "pod"
	specflags = list(EYECOLOR,MUTCOLORS)
	roundstart = 0	//These are only the cloned ones. They grow up to be plant people after a while

/datum/species/plant/pod/spec_life(mob/living/carbon/human/H)
	var/light_amount = 0 //how much light there is in the place, affects receiving nutrition and healing
	if(isturf(H.loc)) //else, there's considered to be no light
		var/turf/T = H.loc
		var/area/A = T.loc
		if(A)
			if(A.lighting_use_dynamic)	light_amount = min(10,T.get_lumcount() * 10) - 5
			else						light_amount =  5
		H.nutrition += light_amount
		if(H.nutrition > NUTRITION_LEVEL_FULL)
			H.nutrition = NUTRITION_LEVEL_FULL
		if(light_amount > 2) //if there's enough light, heal
			H.heal_overall_damage(1,1)
			H.adjustToxLoss(-1)
			H.adjustOxyLoss(-1)

	if(H.nutrition < NUTRITION_LEVEL_STARVING + 50)
		H.take_overall_damage(2,0)

/*
 SHADOWPEOPLE
*/

/datum/species/shadow
	// Humans cursed to stay in the darkness, lest their life forces drain. They regain health in shadow and die in light.
	name = "Shadow"	//Used to be ???
	id = "shadow"
	darksight = 8
	invis_sight = SEE_INVISIBLE_MINIMUM
	sexes = 0
	roundstart = 1
	ignored_by = list(/mob/living/simple_animal/hostile/faithless)
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/shadow
	specflags = list(NOBREATH,NOBLOOD,RADIMMUNE)
	dangerous_existence = 1
	var/light_message = 0 //to prevent message spamming

/datum/species/shadow/spec_life(mob/living/carbon/human/H)
	var/light_amount = 0
	if(isturf(H.loc))
		var/turf/T = H.loc
		var/area/A = T.loc
		if(A)
			if(A.lighting_use_dynamic)	light_amount = T.get_lumcount() * 10
			else						light_amount =  10
		if(light_amount > 7) //if there's enough light, start dying
			if(!light_message)
				light_message = 1
				H << "<span class='warning'>The light is too strong here! Find shelter!</span>"
			H.take_overall_damage(1,1)
			H << "<span class='userdanger'>The light burns you!</span>"
			H << 'sound/weapons/sear.ogg'
		else
			if(light_message)
				light_message = 0
				H << "<span class='warning'>Darkness envelops you.</span>"
			if (light_amount < 2) //heal in the dark
				H.heal_overall_damage(1,1)

/*
 SLIMEPEOPLE
*/

/datum/species/slime
	// Humans mutated by slime mutagen, produced from green slimes. They are not targetted by slimes.
	name = "Slimeperson"
	id = "slime"
	default_color = "00FFFF"
	darksight = 3
	invis_sight = SEE_INVISIBLE_MINIMUM
	specflags = list(EYECOLOR,HAIR,FACEHAIR,NOBLOOD)
	hair_color = "mutcolor"
	hair_alpha = 150
	ignored_by = list(/mob/living/carbon/slime)
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/slime
	exotic_blood = /datum/reagent/toxin/slimejelly
	var/recently_changed = 1

/datum/species/slime/spec_life(mob/living/carbon/human/H)
	if(!H.reagents.get_reagent_amount("slimejelly"))
		if(recently_changed)
			H.reagents.add_reagent("slimejelly", 80)
			recently_changed = 0
		else
			H.reagents.add_reagent("slimejelly", 5)
			H.adjustBruteLoss(5)
			H << "<span class='danger'>You feel empty!</span>"

	for(var/datum/reagent/toxin/slimejelly/S in H.reagents.reagent_list)
		if(S.volume < 100)
			if(H.nutrition >= NUTRITION_LEVEL_STARVING)
				H.reagents.add_reagent("slimejelly", 0.5)
				H.nutrition -= 5
		if(S.volume < 50)
			if(prob(5))
				H << "<span class='danger'>You feel drained!</span>"
		if(S.volume < 10)
			H.losebreath++

/datum/species/slime/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "slimejelly")
		return 1

/*
 JELLYPEOPLE
*/

/datum/species/jelly
	// Entirely alien beings that seem to be made entirely out of gel. They have three eyes and a skeleton visible within them.
	name = "Xenobiological Jelly Entity"
	id = "jelly"
	roundstart = 1
	default_color = "00FF90"
	say_mod = "chirps"
	eyes = "jelleyes"
	specflags = list(EYECOLOR,NOBLOOD)
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/slime
	exotic_blood = /datum/reagent/toxin/slimejelly
	var/recently_changed = 1

/datum/species/jelly/spec_life(mob/living/carbon/human/H)
	if(!H.reagents.get_reagent_amount("slimejelly"))
		if(recently_changed)
			H.reagents.add_reagent("slimejelly", 80)
			recently_changed = 0
		else
			H.reagents.add_reagent("slimejelly", 5)
			H.adjustBruteLoss(5)
			H << "<span class='danger'>You feel empty!</span>"

	for(var/datum/reagent/toxin/slimejelly/S in H.reagents.reagent_list)
		if(S.volume < 100)
			if(H.nutrition >= NUTRITION_LEVEL_STARVING)
				H.reagents.add_reagent("slimejelly", 0.5)
				H.nutrition -= 5
			else if(prob(5))
				H << "<span class='danger'>You feel drained!</span>"
		if(S.volume < 10)
			H.losebreath++

/datum/species/jelly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "slimejelly")
		return 1
/*
 GOLEMS
*/

/datum/species/golem
	// Animated beings of stone. They have increased defenses, and do not need to breathe. They're also slow as fuuuck.
	name = "Golem"
	id = "golem"
	specflags = list(NOBREATH,HEATRES,COLDRES,NOGUNS,NOBLOOD,RADIMMUNE,VIRUSIMMUNE,HARDFEET)
	speedmod = 3
	armor = 55
	punchmod = 5
	no_equip = list(slot_wear_mask, slot_wear_suit, slot_gloves, slot_shoes, slot_head, slot_w_uniform)
	nojumpsuit = 1
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/golem


/*
 ADAMANTINE GOLEMS
*/

/datum/species/golem/adamantine
	name = "Adamantine Golem"
	id = "adamantine"
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/golem/adamantine


/*
 FLIES
*/

/datum/species/fly
	// Humans turned into fly-like abominations in teleporter accidents.

	name = "Flyperson"	//Used to be Human?
	id = "fly"
	roundstart = 1
	say_mod = "buzzes"
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/fly

/datum/species/fly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "pestkiller")
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1

/datum/species/fly/handle_speech(message)
	return replacetext(message, "z", stutter("zz"))

/datum/species/fly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(istype(chem,/datum/reagent/consumable))
		var/datum/reagent/consumable/nutri_check = chem
		if(nutri_check.nutriment_factor >0)
			var/turf/pos = get_turf(H)
			pos.add_vomit_floor(H,1) //toxic vomit, for the extra "disgusting" feeling
			//var/vomit_pile =
			//vomit_pile
			//H.reagents.
			//H.reagents.trans_to(vomit_pile, H.reagents.total_volume) //might need nerfing later since it allows fly people to purge all poisons too.
			playsound(pos, 'sound/effects/splat.ogg', 50, 1)
			H.visible_message("<span class='danger'>[H] vomits on the floor!</span>", \
						"<span class='userdanger'>You throw up on the floor!</span>")
	..()

/*
 SKELETONS
*/

/datum/species/skeleton
	// 2spooky
	name = "Spooky Scary Skeleton"
	id = "skeleton"
	say_mod = "rattles"
	sexes = 0
	roundstart = 1
	brutemod = 2
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/skeleton
	specflags = list(NOBREATH,COLDRES,NOBLOOD,RADIMMUNE)

/*
 ZOMBIES
*/

/datum/species/zombie
	// 1spooky
	name = "Brain-Munching Zombie"
	id = "zombie"
	say_mod = "moans"
	sexes = 0
	roundstart = 1
	burnmod = 2
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/zombie
	specflags = list(NOBREATH,COLDRES,NOBLOOD,RADIMMUNE)

/datum/species/zombie/handle_speech(message)
	var/list/message_list = splittext(message, " ")
	var/maxchanges = max(round(message_list.len / 1.5), 2)

	for(var/i = rand(maxchanges / 2, maxchanges), i > 0, i--)
		var/insertpos = rand(1, message_list.len - 1)
		var/inserttext = message_list[insertpos]

		if(!(copytext(inserttext, length(inserttext) - 2) == "..."))
			message_list[insertpos] = inserttext + "..."

		if(prob(20) && message_list.len > 3)
			message_list.Insert(insertpos, "[pick("BRAINS", "Brains", "Braaaiinnnsss", "BRAAAIIINNSSS")]...")

	return jointext(message_list, " ")

/datum/species/abductor
	name = "Abductor"
	id = "abductor"
//	darksight = 3
	say_mod = "gibbers"
	sexes = 0
	roundstart = 1
	invis_sight = SEE_INVISIBLE_LEVEL_ONE
	specflags = list(NOBLOOD,NOBREATH,VIRUSIMMUNE)
	var/scientist = 0 // vars to not pollute spieces list with castes
	var/agent = 0
	var/abductor = 0 //If they're part of the gamemode
	var/team = 1
	var/tele_target = null //The target for telepathic comunication between species
	var/mind_message_pain = 0
	var/mind_message_minds = 0 //controls the spam of mind messages

/datum/species/abductor/handle_speech(message)
	//Hacks
	//Extra Hacks
	var/mob/living/carbon/human/user = usr
	var/datum/species/abductor/target_spec
	if (abductor)
		for(var/mob/living/carbon/human/H in mob_list)
			if(H.dna.species.id != "abductor")
				continue
			else
				target_spec = H.dna.species
				if(target_spec.team == team)
					H << "<i><font color=#800080><b>[user.name]:</b> [message]</font></i>"
					//return - technically you can add more aliens to a team
		for(var/mob/M in dead_mob_list)
			M << "<i><font color=#800080><b>[user.name]:</b> [message]</font></i>"
		return ""
	else
		//standard telepathy for all ayys
		for(var/mob/living/carbon/human/H in mob_list)
			target_spec = H.dna.species
			if(target_spec.id == "abductor")
				H << "<i><font color=#800080><b>[user.name]:</b> [message]</font></i>"
		for(var/mob/M in dead_mob_list)
			M << "<i><font color=#800080><b>[user.name]:</b> [message]</font></i>"
		//return ..() //ayys don't talk
	if(tele_target)
		tele_target << "<i><font color=#800080><b>[user.name]:</b> [message]</font></i>"

//Telepathy shit moved to main proc to make it work with all species

/datum/species/abductor/spec_life(var/mob/living/carbon/human/H)
	var/alone_test = 0 //to check if we found someone
	var/pain_felt = 0
	for (var/mob/living/carbon/M in range(7,H))  //not orange() because this should probably look for hurt mobs who are in the same tile as H
		if(M.stat != DEAD && M.client && M != H) //only interacts with other players
			alone_test = 1 //we're not lonely!
			if(M.health < M.getMaxHealth())
				pain_felt += (M.getMaxHealth() - M.health) / M.getMaxHealth() //coefficient, goes from 0% to 1 if it's in crit. >1 if it's closer to death
	if(pain_felt)
		H.AdjustWeakened(-pain_felt*4)
		H.adjustStaminaLoss(-pain_felt*3) // people in crit or closer than that CAN in fact down an ayy.
		H.Jitter(pain_felt) //comically low levels of jitter
		if(!mind_message_pain)
			mind_message_pain = 1
			H << "<span class='alert'>You feel someone in pain!</span>"
		else
			mind_message_pain = 0
			H << "<span class='alert'>You feel peace in your mind.</span>"
	else
		mind_message_pain = 0
	if(!alone_test)
		H.adjustStaminaLoss(-rand(1,3)) //can knock someone out, since they recover 2 per tick.
		if(prob(10))
			H.Dizzy(4) //This will get annoying fast now that it can actually get triggered
		if(!mind_message_minds)
			mind_message_minds = 1
			H << "<span class='alert'>You feel no minds nearby. Your thoughts echo in the distance.</span>"
	else
		if(mind_message_minds)
			mind_message_minds = 0
			H << "<span class='alert'>You hear the thoughts of another.</span>"
	return

/datum/species/abductor/handle_vision(mob/living/carbon/human/H)
	H.see_in_dark = 3
	H.see_invisible = SEE_INVISIBLE_MINIMUM

var/global/image/plasmaman_on_fire = image("icon"='icons/mob/OnFire.dmi', "icon_state"="plasmaman")

// Plasmamen
/datum/species/plasmaman
	name = "Plasbone"
	id = "plasmaman"
	say_mod = "rattles"
	sexes = 0
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/skeleton
	specflags = list(RADIMMUNE, NOBLOOD)
	exotic_blood = /datum/reagent/toxin/plasma
	safe_oxygen_min = 0 //We don't breath this
	safe_oxygen_max = 0.005 //This kills the plasmaman
	safe_toxins_min = 10 //We breath THIS! Equivalent to about 16.7 kPa at body temperature
	safe_toxins_max = 0
	dangerous_existence = 1 //So so much
	var/skin = 0
	default_body_temperature = T0C+200
	heat_damage_limit = T0C+250
	cold_damage_limit = T0C+150

/datum/species/plasmaman/skin
	name = "Skinbone"
	skin = 1

/datum/species/plasmaman/update_base_icon_state(mob/living/carbon/human/H)
	var/base = ..()
	if(base == id)
		base = "[base][skin]"
	return base

/datum/species/plasmaman/spec_life(mob/living/carbon/human/H)
	if(!H.loc) return
	var/datum/gas_mixture/environment = H.loc.return_air()

	if(!(istype(H.wear_suit, /obj/item/clothing/suit/bio_suit/plasma) && istype(H.head, /obj/item/clothing/head/bio_hood/plasma)) && !istype(H.head, /obj/item/clothing/head/helmet/space/hardsuit/atmos/plasmaman)) //disgust
		if(environment)
			var/total_moles = environment.total_moles()
			if(total_moles)
				if((environment.oxygen /total_moles) >= 0.01 && (environment.toxins / environment.oxygen) <= PLASMA_MINIMUM_OXYGEN_PLASMA_RATIO)	//At less than 3% oxygen in air you won't combust
					if(!H.on_fire)
						H.visible_message("<span class='danger'>[H]'s body reacts with the atmosphere and bursts into flames!</span>","<span class='userdanger'>Your body reacts with the atmosphere and bursts into flame!</span>")
					H.adjust_fire_stacks(0.5)
					H.IgniteMob()
	else
		if(H.fire_stacks)
			var/obj/item/clothing/suit/space/hardsuit/atmos/plasmaman/P = H.wear_suit
			if(istype(P))
				P.Extinguish(H)
	H.update_fire()

//Heal from plasma
/datum/species/plasmaman/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)	//Pretty strong right now, between tricord and cryo
	if(chem.id == "plasma")
		H.adjustBruteLoss(-2)
		H.adjustFireLoss(-2)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1

/datum/species/plasmaman/spec_death(gibbed, mob/living/carbon/human/H)	//Resurrection isn't a given
	if(H.reagents)
		for(var/A in H.reagents.reagent_list)
			var/datum/reagent/R = A
			if(R.id == "plasma")
				H.reagents.remove_reagent(R.id, R.volume)
