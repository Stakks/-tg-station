/mob/living/carbon/dwarf/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if(check_shields(0, M.name))
		visible_message("<span class='danger'>[M] attempted to touch [src]!</span>")
		return 0

	if(..())
		if(M.a_intent == "harm")
			if (w_uniform)
				w_uniform.add_fingerprint(M)
			var/damage = rand(10, 25)
			if(!damage)
				playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1, -1)
				visible_message("<span class='danger'>[M] has lunged at [src]!</span>", \
					"<span class='userdanger'>[M] has lunged at [src]!</span>")
				return 0
			var/zone = ran_zone(M.zone_sel.selecting)
			zone = check_zone(zone)
			var/armor_block = run_armor_check(zone, "melee","","",10)

			playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
			visible_message("<span class='danger'>[M] has slashed at [src]!</span>", \
				"<span class='userdanger'>[M] has slashed at [src]!</span>")

			apply_damage(damage, BRUTE, zone, armor_block)
			if (damage >= 24)
				visible_message("<span class='danger'>[M] has wounded [src]!</span>", \
					"<span class='userdanger'>[M] has wounded [src]!</span>")
				apply_effect(4, WEAKEN, armor_block)
				add_logs(M, src, "attacked", admin=0)
			updatehealth()

		if(M.a_intent == "disarm") //Unlike in Dwarf Fortress, a low center of gravity is an advantage against larger opponents
			var/randn = rand(1, 100)
			if (randn <= 20)
				playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
				Weaken(5)
				add_logs(M, src, "tackled", admin=0)
				visible_message("<span class='danger'>[M] has tackled down [src]!</span>", \
					"<span class='userdanger'>[M] has tackled down [src]!</span>")
			else
				if (randn <= 33)
					playsound(loc, 'sound/weapons/slash.ogg', 25, 1, -1)
					drop_item()
					visible_message("<span class='danger'>[M] disarmed [src]!</span>", \
						"<span class='userdanger'>[M] disarmed [src]!</span>")
				else
					playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1, -1)
					visible_message("<span class='danger'>[M] has tried to disarm [src]!</span>", \
						"<span class='userdanger'>[M] has tried to disarm [src]!</span>")
	return
