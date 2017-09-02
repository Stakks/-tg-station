/obj/effect/proc_holder/changeling/revive
	name = "Regenerate"
	desc = "We regenerate, healing all damage from our form."
	req_stat = DEAD

//Revive from revival stasis
/obj/effect/proc_holder/changeling/revive/sting_action(var/mob/living/carbon/user)
	if(user.stat == DEAD)
		dead_mob_list -= user
		living_mob_list += user
	user.tod = null
	user.setToxLoss(0)
	user.setOxyLoss(0)
	user.setCloneLoss(0)
	user.SetParalysis(0)
	user.SetStunned(0)
	user.SetWeakened(0)
	user.radiation = 0
	user.heal_overall_damage(user.getBruteLoss(), user.getFireLoss())
	user.reagents.clear_reagents()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.restore_blood()
		H.remove_all_embedded_objects()
		if(H.dna)

			for(var/organname in H.organsystem.organlist)
				var/datum/organ/organdata = H.organsystem.organlist[organname]
				if(istype(organdata) && !organdata.exists())
					if(organdata.name == "organ") continue
					organdata.regenerate_organitem(H.dna) //We regenerate lost organs.
					if(organdata.exists())
						var/obj/item/organ/O = organdata.organitem
						if(istype(O))
							O.add_suborgans()
							O.on_insertion()
						user << "<span class='notice'>We regrow our [organdata.getDisplayName()]</span>"
		H.update_hud()
		H.update_body_parts()
		H.update_damage_overlays(0)

	user << "<span class='notice'>We have regenerated.</span>"
	user.status_flags &= ~(FAKEDEATH)
	user.update_canmove()
	user.mind.changeling.purchasedpowers -= src
	user.med_hud_set_status()
	user.med_hud_set_health()
	user.health_status.vision_damage = 0 //fix eyes too
	user.health_status.vision_blurry = 0
	user.disabilities &= ~(NEARSIGHT|BLIND)
	feedback_add_details("changeling_powers","CR")
	user.stat = CONSCIOUS
	return 1
