/*
//////////////////////////////////////
Inert Virus

	Noticable.
	No stat change

BONUS
	Nothing. Symptom disappears when other symptoms manifest

//////////////////////////////////////
*/

/datum/symptom/inert

	name = "Inert Virus"
	stealth = 1
	resistance = 0
	stage_speed = 0
	transmittable = 0
	level = 10 //so it's not on the random rotation
	severity = 1

/datum/symptom/inert/Activate(var/datum/disease/advance/A)
	..()
	return

/datum/symptom/viral_readaption

	name = "Viral Readaption Secretion"
	stealth = 0
	resistance = -5
	stage_speed = -5
	transmittable = -5
	level = 6

/datum/symptom/viral_readaption/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4, 5)
				if (M.reagents.get_reagent_amount("viral_readaption") < 20)
					M.reagents.add_reagent("viral_readaption", 20)
	return

/*
//////////////////////////////////////
Oh BOY
        The stats don't matter.
Bonus
        Get turned into a human. FOR TEH EMPRAH
//////////////////////////////////////
*/

/datum/symptom/purge

        name = "Imperium Blessing"
        stealth = -5
        resistance = 3
        stage_speed = 5
        transmittable = 2
        level = 10 //only available with FEV
        severity = 5

/datum/symptom/purge/Activate(var/datum/disease/advance/A)
        ..()
        if(prob(SYMPTOM_ACTIVATION_PROB))
                var/mob/living/M = A.affected_mob
                switch(A.stage)
                        if(1, 2)
                                if(prob(SYMPTOM_ACTIVATION_PROB))
                                        M << "<span class='notice'>[pick("You hear distant sounds of battle.", "You feel like you should report back to your commander.")]</span>"
                        if(3, 4)
                                if(prob(SYMPTOM_ACTIVATION_PROB))
                                        M << A.affected_mob.say(pick("FUCKING XENOS, PURGE, HERESY"))
                                        M << "<span class='notice'>[pick("You feel an overwhelming hatred of Xenos.")]</span>"
                        if(5)
                                if(ishuman(A.affected_mob))
                                        var/mob/living/carbon/human/human = A.affected_mob
                                        if(human.dna && human.dna.species.id != "human")
                                                human.dna.species = new /datum/species/human()
                                                human.update_icons()
                                                human.update_body()
                                                human.update_hair()
                                else
                                        return

        return

/*
//////////////////////////////////////

Living Bomb
	Dissabled by level = 10.
Bonus
	Turns the affected person into a living bomb.Ishmillah.

//////////////////////////////////////
*/

/datum/symptom/explosive

	name = "Jihad Syndrome"
	stealth = -3
	resistance = -5
	stage_speed = -1
	transmittable = -1
	level = 10
	severity = 5

/datum/symptom/explosive/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2)
				M << "<span class='notice'>[pick("Something snaps inside you.", "You hear a crunching sound coming from your lungs.")]</span>"
			if(3,4)
				M << "<span class='alert'>[pick("Everything feels hot around you!", "You smell sulphur and brimstone!")]</span>"
				M.atmos_spawn_air(SPAWN_HEAT | SPAWN_CO2, 200)
				M.reagents.add_reagent("smoke_powder", 20) //should make some clouds of smoke. Hopefully anyway.
			else
				M << A.affected_mob.say("ALLAHU ACKBAR!")
				explosion(M.loc,1,2,4,7)
				M.Dizzy(5)
	return

//disallowed by level = 10
/datum/symptom/limb_regen

	name = "Limb Regeneration"
	stealth = -1
	resistance = -3
	stage_speed = 4
	transmittable = -4
	level = 10

/datum/symptom/limb_regen/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 5))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(5)
				var/mob/living/carbon/human/H = M
				if(H.dna)
					for(var/organname in H.organsystem.organlist)
						var/datum/organ/organdata = H.organsystem.organlist[organname]
						if(istype(organdata) && !organdata.exists())
							if(organdata.name == "organ") continue
							organdata.regenerate_organitem(H.dna) //IT JUST WERKS
							if(organdata.exists())
								var/obj/item/organ/O = organdata.organitem
								if(istype(O))
									O.add_suborgans()
									O.on_insertion()
								M << "<span class='notice'>You regrow your [organdata.getDisplayName()]</span>"
				M.update_hud()
				H.update_body_parts()
				M.update_damage_overlays(0)
	return

/*
//////////////////////////////////////

Scarab Infestation

	Visible.
	Lowers resistance.
	Decreases stage speed.
	Not very transmittable.
	Intense Level.

Bonus
	Creates a Scarab Injector after a while while harming the mob. Self-Cures.

//////////////////////////////////////
*/

/datum/symptom/scarab

	name = "Confusion"
	stealth = 1
	resistance = -1
	stage_speed = -3
	transmittable = 0
	level = 10
	severity = 2


/datum/symptom/scarab/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/M = A.affected_mob
		switch(A.stage)
			if(1, 2)
				M << "<span class='notice'>[pick("You feel itchy.", "You scratch yourself.")]</span>"
			if(3,4)
				M << "<span class='alert'>[pick("You feel something crawling under your skin!", "You feel something biting your insides!")]</span>"
				M.adjustBruteLoss(-1)
			else
				M.visible_message("<span class='danger'>[M] skin bursts like a bubble releasing a scarab!</span>", \
					"<span class='userdanger'>Your skin bursts like a bubble releasing the scarab!</span>")
				M.health_status.spatial_confuse = min(100, M.health_status.spatial_confuse + 2)
				M.adjustBruteLoss(-60)
				new/obj/item/weapon/guardiancreator/biological/choose ( M.loc )
				A.cure()

	return

/*
//////////////////////////////////////

Sensory-Restoration

	Very very very very noticable.
	Lowers resistance tremendously.
	Decreases stage speed tremendously.
	Decreases transmittablity tremendously.
	Fatal Level.

Bonus
	The body generates Sensory restorational chemicals.

//////////////////////////////////////
*/

/datum/symptom/sensres

	name = "Sensory Restoration"
	stealth = -3
	resistance = -3
	stage_speed = -3
	transmittable = -4
	level = 10
	severity = 0

/datum/symptom/sensres/Activate(var/datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 100))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1)
				M.setEarDamage(0,0)
				if(M.disabilities & DEAF)
					M.disabilities &= ~DEAF
			if(2)
				M.health_status.vision_blurry = max(M.health_status.vision_blurry-5 , 0)
				M.health_status.vision_blindness = max(M.health_status.vision_blindness-5 , 0)
				M.disabilities &= ~NEARSIGHT
				M.health_status.vision_damage = max(M.health_status.vision_damage-5, 0)
				M.setEarDamage(0,0)
				if(M.disabilities & DEAF)
					M.disabilities &= ~DEAF
			if(3)
				M.drowsyness = max(M.drowsyness-5, 0)
				M.AdjustParalysis(-1)
				M.AdjustStunned(-1)
				M.AdjustWeakened(-1)
				M.hallucination = max(0, M.hallucination - 10)
				if(prob(60))
					M.adjustToxLoss(1)
				M.health_status.vision_blurry = max(M.health_status.vision_blurry-5 , 0)
				M.health_status.vision_blindness = max(M.health_status.vision_blindness-5 , 0)
				M.disabilities &= ~NEARSIGHT
				M.health_status.vision_damage = max(M.health_status.vision_damage-5, 0)
				M.setEarDamage(0,0)
				if(M.disabilities & DEAF)
					M.disabilities &= ~DEAF
			if(4, 5)
				if(M != DEAD)
					M.adjustBrainLoss(-3)
				M.drowsyness = max(M.drowsyness-5, 0)
				M.AdjustParalysis(-1)
				M.AdjustStunned(-1)
				M.AdjustWeakened(-1)
				M.hallucination = max(0, M.hallucination - 10)
				if(prob(60))
					M.adjustToxLoss(1)
				M.health_status.vision_blurry = max(M.health_status.vision_blurry-5 , 0)
				M.health_status.vision_blindness = max(M.health_status.vision_blindness-5 , 0)
				M.disabilities &= ~NEARSIGHT
				M.health_status.vision_damage = max(M.health_status.vision_damage-5, 0)
				M.setEarDamage(0,0)
				if(M.disabilities & DEAF)
					M.disabilities &= ~DEAF
			else
				if(prob(SYMPTOM_ACTIVATION_PROB * 5))
					M << "<span class='notice'>[pick("Your eyes feel great.", "Your ears feel great.", "Your head feels great.")]</span>"
	return

