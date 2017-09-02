/*
//////////////////////////////////////
Whiteknighting
	It's a meme.
BONUS
        Will annoy non-whiteknights.
//////////////////////////////////////
*/

/datum/symptom/mlady

        name = "Increased Fedora"
        stealth = -2
        resistance = -1
        stage_speed = 0
        transmittable = -1
        level = 2
        severity = 3

/datum/symptom/mlady/Activate(var/datum/disease/advance/A)
        ..()
        if(prob(SYMPTOM_ACTIVATION_PROB))
                var/mob/living/M = A.affected_mob
                switch(A.stage)
                        if(1, 2, 3, 4)
                                M << "<span notice='notice'>[pick("You suddenly feel like equipping the nearest Fedora ", "You have an intense urge to aide a helpless wymyn.")]</span>"
                                M.visible_message("<span class='danger'>[M] shouts a vigorous M'lady</span>")
                        else
                                M << "<span notice='danger'>[pick("You begin to feel pain due to a lack of female attention")]</span>"
                                M.adjustBruteLoss(1)
        return

/*
//////////////////////////////////////

Sneezing

	Very Noticable.
	Increases resistance.
	Doesn't increase stage speed.
	Very transmittable.
	Low Level.

Bonus
	Forces a spread type of AIRBORNE
	with extra range!

//////////////////////////////////////
*/

/datum/symptom/sneeze

	name = "Sneezing"
	stealth = -2
	resistance = 2
	stage_speed = 0
	transmittable = 2
	level = 1
	severity = 1

/datum/symptom/sneeze/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2, 3)
				M.emote("sniff")
			else
				M.emote("sneeze")
				A.spread(A.holder, 5)
	return

/*
//////////////////////////////////////

Shivering

	No change to hidden.
	Increases resistance.
	Increases stage speed.
	Little transmittable.
	Low level.

Bonus
	Cools down your body.

//////////////////////////////////////
*/

/datum/symptom/shivering

	name = "Shivering"
	stealth = 1
	resistance = 4
	stage_speed = -1
	transmittable = -1
	level = 2
	severity = 2

/datum/symptom/shivering/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/M = A.affected_mob
		M << "<span class='notice'>[pick("You feel cold.", "You start shaking from the cold.")]</span>"
		if(M.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT)
			M.bodytemperature = min(M.bodytemperature - (20 * A.stage), BODYTEMP_COLD_DAMAGE_LIMIT + 1)

	return

/*
//////////////////////////////////////

Hyphema (Eye bleeding)

	Slightly noticable.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity.
	Critical Level.

Bonus
	Causes blindness.

//////////////////////////////////////
*/

/datum/symptom/visionloss

	name = "Hyphema"
	stealth = -4
	resistance = -2
	stage_speed = -2
	transmittable = -3
	level = 5
	severity = 4

/datum/symptom/visionloss/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2)
				M << "<span class='notice'>Your eyes itch.</span>"
			if(3, 4)
				M << "<span class='notice'>Your eyes ache.</span>"
				M.health_status.vision_blurry = 10
				M.health_status.vision_damage += 1
			else
				M << "<span class='danger'>Your eyes burn horrificly!</span>"
				M.health_status.vision_blurry = 20
				M.health_status.vision_damage += 5
				if (M.health_status.vision_damage >= 10)
					M.disabilities |= NEARSIGHT
					if (prob(M.health_status.vision_damage - 10 + 1) && !(M.health_status.vision_blindness))
						M << "<span class='danger'>You go blind!</span>"
						M.disabilities |= BLIND
						M.health_status.vision_blindness = 1
	return




/*
//////////////////////////////////////

Weight Loss

	Very Very Noticable.
	Decreases resistance.
	Decreases stage speed.
	Reduced Transmittable.
	High level.

Bonus
	Decreases the weight of the mob,
	forcing it to be skinny.

//////////////////////////////////////
*/

/datum/symptom/weight_loss

	name = "Weight Loss"
	stealth = -3
	resistance = 0
	stage_speed = -1
	transmittable = -3
	level = 3
	severity = 1

/datum/symptom/weight_loss/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2, 3, 4)
				M << "<span class='notice'>[pick("You feel hungry.", "You crave for food.")]</span>"
			else
				M << "<span class='notice'>Your stomach rumbles.</span>"
				M.overeatduration = max(M.overeatduration - 100, 0)
				M.nutrition = max(M.nutrition - 100, 0)

	return

/*
//////////////////////////////////////

Vomiting

	Very Very Noticable.
	Decreases resistance.
	Doesn't increase stage speed.
	Little transmittable.
	Medium Level.

Bonus
	Forces the affected mob to vomit!
	Meaning your disease can spread via
	people walking on vomit.
	Makes the affected mob lose nutrition and
	heal toxin damage.

//////////////////////////////////////
*/

/datum/symptom/vomit

	name = "Vomiting"
	stealth = -1
	resistance = -1
	stage_speed = 1
	transmittable = 2
	level = 3
	severity = 4

/datum/symptom/vomit/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB / 2))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2, 3, 4)
				M << "<span class='notice'>[pick("You feel nauseous.", "You feel like you're going to throw up!")]</span>"
			else
				Vomit(M)

	return

/datum/symptom/vomit/proc/Vomit(var/mob/living/M)

	M.visible_message("<span class='danger'>[M] vomits on the floor!</span>", \
					"<span class='userdanger'>You throw up on the floor!</span>")

	M.nutrition -= 20
	M.adjustToxLoss(-3)

	var/turf/pos = get_turf(M)
	pos.add_vomit_floor(M)
	playsound(pos, 'sound/effects/splat.ogg', 50, 1)
/*
//////////////////////////////////////

Vomiting Blood

	Very Very Noticable.
	Decreases resistance.
	Decreases stage speed.
	Little transmittable.
	Intense level.

Bonus
	Forces the affected mob to vomit blood!
	Meaning your disease can spread via
	people walking on the blood.
	Makes the affected mob lose health.

//////////////////////////////////////
*/

/datum/symptom/vomit/blood

	name = "Blood Vomiting"
	stealth = -2
	resistance = -3
	stage_speed = -3
	transmittable = 0
	level = 4
	severity = 5

/datum/symptom/vomit/blood/Vomit(var/mob/living/M)

	M.Stun(1)
	M.visible_message("<span class='danger'>[M] vomits on the floor!</span>", \
						"<span class='userdanger'>You throw up on the floor!</span>")

	// They lose blood and health.
	var/brute_dam = M.getBruteLoss()
	if(brute_dam < 50)
		M.adjustBruteLoss(3)

	var/turf/pos = get_turf(M)
	pos.add_blood_floor(M)
	playsound(pos, 'sound/effects/splat.ogg', 50, 1)

/*
//////////////////////////////////////

Dizziness

	Hidden.
	Lowers resistance considerably.
	Decreases stage speed.
	Reduced transmittability
	Intense Level.

Bonus
	Shakes the affected mob's screen for short periods.

//////////////////////////////////////
*/

/datum/symptom/dizzy // Not the egg

	name = "Dizziness"
	stealth = 2
	resistance = -1
	stage_speed = 0
	transmittable = -2
	level = 4
	severity = 2

/datum/symptom/dizzy/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 4))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2, 3, 4)
				M << "<span class='notice'>[pick("You feel dizzy.", "Your head starts spinning.")]</span>"
			else
				M << "<span class='notice'>You are unable to look straight!</span>"
				M.Dizzy(5)
	return

/*
//////////////////////////////////////

Fever

	No change to hidden.
	Increases resistance.
	Increases stage speed.
	Little transmittable.
	Low level.

Bonus
	Heats up your body.

//////////////////////////////////////
*/

/datum/symptom/fever

	name = "Fever"
	stealth = 0
	resistance = 3
	stage_speed = 3
	transmittable = 0
	level = 2
	severity = 2

/datum/symptom/fever/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/M = A.affected_mob
		M << "<span class='notice'>[pick("You feel hot.", "You feel like you're burning.")]</span>"
		if(M.bodytemperature < BODYTEMP_HEAT_DAMAGE_LIMIT)
			M.bodytemperature = min(M.bodytemperature + (20 * A.stage), BODYTEMP_HEAT_DAMAGE_LIMIT - 1)

	return

/*
//////////////////////////////////////

Deafness

	Slightly noticable.
	Lowers resistance.
	Decreases stage speed slightly.
	Decreases transmittablity.
	Intense Level.

Bonus
	Causes intermittent loss of hearing.

//////////////////////////////////////
*/

/datum/symptom/deafness

	name = "Deafness"
	stealth = -1
	resistance = -2
	stage_speed = -2
	transmittable = -3
	level = 4
	severity = 3

/datum/symptom/deafness/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(3, 4)
				M << "<span class='notice'>[pick("You hear a ringing in your ear.", "Your ears pop.")]</span>"
			if(5)
				if(!(M.health_status.aural_audio))
					M << "<span class='danger'>Your ears pop and begin ringing loudly!</span>"
					M.setEarDamage(-1,INFINITY) //Shall be enough
					spawn(200)
						if(M)
							M.setEarDamage(-1,0)
	return

/*
//////////////////////////////////////

Itching

	Not noticable or unnoticable.
	Resistant.
	Increases stage speed.
	Little transmittable.
	Low Level.

BONUS
	Displays an annoying message!
	Should be used for buffing your disease.

//////////////////////////////////////
*/

/datum/symptom/itching

	name = "Itching"
	stealth = 0
	resistance = 1
	stage_speed = 1
	transmittable = 2
	level = 1
	severity = 1

/datum/symptom/itching/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		M << "<span class='notice'>Your [pick("back", "arm", "leg", "elbow", "head")] itches.</span>"
	return

/*
//////////////////////////////////////

Necrotizing Fasciitis (AKA Flesh-Eating Disease)

	Very very noticable.
	Lowers resistance tremendously.
	No changes to stage speed.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Deals brute damage over time.

//////////////////////////////////////
*/

/datum/symptom/flesh_eating

	name = "Necrotizing Fasciitis"
	stealth = -3
	resistance = -4
	stage_speed = 0
	transmittable = -4
	level = 6
	severity = 5

/datum/symptom/flesh_eating/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4, 5)
				if(prob(6.66)) //Gotta make sure they die long before it matters! If you aren't trying to get skele'd, you shouldn't get it for free.
					M << "<span class='notice'>Your skeleton has finally clawed its way out of its fleshly cage!</span>"
					M.adjustBruteLoss(rand(65,130)) //See above.
					hardset_dna(M, null, null, null, null, /datum/species/skeleton)
				else
					M << "<span class='notice'>[pick("You cringe as a violent pain takes over your body.", "It feels like your body is eating itself inside out.", "IT HURTS.")]</span>"
					M.adjustBruteLoss(8)
				return
	return

/*
//////////////////////////////////////

Confusion

	Little bit hidden.
	Lowers resistance.
	Decreases stage speed.
	Not very transmittable.
	Intense Level.

Bonus
	Makes the affected mob be confused for short periods of time.

//////////////////////////////////////
*/

/datum/symptom/confusion

	name = "Confusion"
	stealth = 1
	resistance = -2
	stage_speed = -2
	transmittable = -1
	level = 4
	severity = 2


/datum/symptom/confusion/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/M = A.affected_mob
		switch(A.stage)
			if(1, 2, 3, 4)
				M << "<span class='notice'>[pick("You feel confused.", "You forgot what you were thinking about.")]</span>"
			else
				M << "<span class='notice'>You are unable to think straight!</span>"
				M.health_status.spatial_confuse = min(100, M.health_status.spatial_confuse + 3)

	return

/*
//////////////////////////////////////

Choking

	Very very noticable.
	Lowers resistance.
	Decreases stage speed.
	Decreases transmittablity tremendously.
	Moderate Level.

Bonus
	Inflicts spikes of oxyloss

//////////////////////////////////////
*/

/datum/symptom/choking

	name = "Choking"
	stealth = -3
	resistance = -2
	stage_speed = -2
	transmittable = -3
	level = 3
	severity = 3

/datum/symptom/choking/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2)
				M << "<span class='notice'>[pick("You're having difficulty breathing.", "Your breathing becomes heavy.")]</span>"
			if(3, 4)
				M.adjustOxyLoss(5)
				M.emote("gasp")
			else
				M << "<span class='danger'>[pick("You're choking!", "You can't breathe!")]</span>"
				M.adjustOxyLoss(30)
				M.emote("gasp")
				if(istype(M, /mob/living/carbon/human)) //Who removed this bit? Not really worth it without it.
					var/mob/living/carbon/human/H = M
					H.silent += 3
	return

/*
//////////////////////////////////////

Hallucigen

	Very noticable.
	Lowers resistance considerably.
	Decreases stage speed.
	Reduced transmittable.
	Critical Level.

Bonus
	Makes the affected mob be hallucinated for short periods of time.

//////////////////////////////////////
*/

/datum/symptom/hallucigen

	name = "Hallucigen"
	stealth = -2
	resistance = -2
	stage_speed = -2
	transmittable = -2
	level = 5
	severity = 3

/datum/symptom/hallucigen/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/M = A.affected_mob
		switch(A.stage)
			if(1, 2, 3, 4)
				M << "<span class='notice'>[pick("You notice someone in the corner of your eye.", "Is that footsteps?.")]</span>"
			else
				M.hallucination += 5

	return

/*
//////////////////////////////////////

Coughing

	Noticable.
	Little Resistance.
	Doesn't increase stage speed much.
	Transmittable.
	Low Level.

BONUS
	Will force the affected mob to drop small items!

//////////////////////////////////////
*/

/datum/symptom/cough

	name = "Cough"
	stealth = -1
	resistance = 2
	stage_speed = 0
	transmittable = 2
	level = 1
	severity = 1

/datum/symptom/cough/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2, 3)
				M << "<span notice='notice'>[pick("You swallow excess mucus.", "You lightly cough.")]</span>"
			else
				M.emote("cough")
				var/obj/item/I = M.get_active_hand()
				if(I && I.w_class == 1)
					M.drop_item()
	return

/*
//////////////////////////////////////

Headache

	Noticable.
	Highly resistant.
	Increases stage speed.
	Not transmittable.
	Low Level.

BONUS
	Displays an annoying message!
	Should be used for buffing your disease.

//////////////////////////////////////
*/

/datum/symptom/headache

	name = "Headache"
	stealth = 1
	resistance = 2
	stage_speed = 2
	transmittable = 0
	level = 1
	severity = 1

/datum/symptom/headache/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		M << "<span class='notice'>[pick("Your head hurts.", "Your head starts pounding.")]</span>"
	return
