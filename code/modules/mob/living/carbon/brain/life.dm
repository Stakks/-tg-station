
/mob/living/carbon/brain/handle_breathing()
	return

/mob/living/carbon/brain/handle_mutations_and_radiation()

	if (radiation)
		if (radiation > 100)
			if(!container)//If it's not in an MMI
				src << "<span class='danger'>You feel weak.</span>"
			else//Fluff-wise, since the brain can't detect anything itself, the MMI handles thing like that
				src << "<span class='danger'>STATUS: CRITICAL AMOUNTS OF RADIATION DETECTED.</span>"

		switch(radiation)

			if(50 to 75)
				if(prob(5))
					if(!container)
						src << "<span class='danger'>You feel weak.</span>"
					else
						src << "<span class='danger'>STATUS: DANGEROUS LEVELS OF RADIATION DETECTED.</span>"
		..()

/mob/living/carbon/brain/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		return
	var/environment_heat_capacity = environment.heat_capacity()
	if(istype(get_turf(src), /turf/space))
		var/turf/heat_turf = get_turf(src)
		environment_heat_capacity = heat_turf.heat_capacity

	if((environment.temperature > (T0C + 50)) || (environment.temperature < (T0C + 10)))
		var/transfer_coefficient = 1

		handle_temperature_damage(HEAD, environment.temperature, environment_heat_capacity*transfer_coefficient)

	if(stat==2)
		bodytemperature += 0.1*(environment.temperature - bodytemperature)*environment_heat_capacity/(environment_heat_capacity + 270000)

	//Account for massive pressure differences

	return //TODO: DEFERRED

/mob/living/carbon/brain/proc/handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
	if(status_flags & GODMODE) return

	if(exposed_temperature > bodytemperature)
		var/discomfort = min( abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)
		adjustFireLoss(20.0*discomfort)

	else
		var/discomfort = min( abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)
		adjustFireLoss(5.0*discomfort)


/mob/living/carbon/brain/handle_regular_status_updates()	//TODO: comment out the unused bits >_>

	if(stat == DEAD)
		health_status.vision_blindness = max(health_status.vision_blindness, 1)
		health_status.vision_blindness_intensity = 11
		silent = 0
	else
		updatehealth()
		if( !container && (health < config.health_threshold_dead || ((world.time - timeofhostdeath) > config.revival_brain_life)) )
			death()
			health_status.vision_blindness = max(health_status.vision_blindness, 1)
			health_status.vision_blindness_intensity = 11
			silent = 0
			return 1
	/*	if(health < config.health_threshold_crit)
			stat = UNCONSCIOUS
			health_status.vision_blindness = max(health_status.vision_blindness, 1)
			health_status.vision_blindness_intensity = 11
			*/
		else
			stat = CONSCIOUS

			//Handling EMP effect in the Life(), it's made VERY simply, and has some additional effects handled elsewhere
			if(emp_damage)			//This is pretty much a damage type only used by MMIs, dished out by the emp_act
				if(!(container && istype(container, /obj/item/device/mmi)))
					emp_damage = 0
				else
					emp_damage = round(emp_damage,1)//Let's have some nice numbers to work with
				switch(emp_damage)
					if(31 to INFINITY)
						emp_damage = 30//Let's not overdo it
					if(21 to 30)//High level of EMP damage, unable to see, hear, or speak
						health_status.vision_blindness = max(health_status.vision_blindness, 1)
						health_status.vision_blindness_intensity = 11
						setEarDamage(-1,1)
						silent = 1
						if(!alert)//Sounds an alarm, but only once per 'level'
							emote("alarm")
							src << "<span class='danger'>Major electrical distruption detected: System rebooting.</span>"
							alert = 1
						if(prob(75))
							emp_damage -= 1
					if(20)
						alert = 0
						health_status.vision_blindness = 0
						setEarDamage(-1,0)
						silent = 0
						emp_damage -= 1
					if(11 to 19)//Moderate level of EMP damage, resulting in nearsightedness and ear damage
						health_status.vision_blurry = 1
						setEarDamage(1,-1)
						if(!alert)
							emote("alert")
							src << "<span class='danger'>Primary systems are now online.</span>"
							alert = 1
						if(prob(50))
							emp_damage -= 1
					if(10)
						alert = 0
						health_status.vision_blurry = 0
						setEarDamage(0,-1)
						emp_damage -= 1
					if(2 to 9)//Low level of EMP damage, has few effects(handled elsewhere)
						if(!alert)
							emote("notice")
							src << "<span class='danger'>System reboot nearly complete.</span>"
							alert = 1
						if(prob(25))
							emp_damage -= 1
					if(1)
						alert = 0
						src << "<span class='danger'>All systems restored.</span>"
						emp_damage -= 1
			else
				health_status.vision_blindness = 0
				health_status.vision_blindness_intensity = 0
	return 1


/mob/living/carbon/brain/update_sight()

	if(stat == DEAD)
		sight |= SEE_TURFS
		sight |= SEE_MOBS
		sight |= SEE_OBJS
		see_in_dark = 8
		see_invisible = SEE_INVISIBLE_LEVEL_TWO
	else
		sight &= ~(SEE_TURFS)
		sight &= ~(SEE_MOBS)
		sight &= ~(SEE_OBJS)
		see_in_dark =  2
		see_invisible =  SEE_INVISIBLE_LIVING


/mob/living/carbon/brain/handle_disabilities()
		//Eyes
	if(stat)
		health_status.vision_blindness = max(health_status.vision_blindness, 5)
		health_status.vision_blindness_intensity = 11
	if(!(disabilities & BLIND))	//blindness from disability or unconsciousness doesn't get better on its own
		if(health_status.vision_blindness)			//blindness, heals slowly over time
			health_status.vision_blindness = max(health_status.vision_blindness-1,0)
		else if(health_status.vision_blurry)			//blurry eyes heal slowly
			health_status.vision_blurry = max(health_status.vision_blurry-1, 0)
	else
		health_status.vision_blindness = max(health_status.vision_blindness,1) //Force blindness if user is actually blind
		health_status.vision_blindness_intensity = 11
	//Ears
	if(disabilities & DEAF)		//disabled-deaf, doesn't get better on its own
		setEarDamage(-1, max(health_status.aural_audio, 1))
	else
		// deafness heals slowly over time, unless ear_damage is over 100
		if(health_status.aural_audio_intensity < 100)
			adjustEarDamage(-0.05,-1)



/mob/living/carbon/brain/handle_regular_hud_updates()

	handle_vision()

	update_action_buttons()

	handle_hud_icons_health()

	return 1

