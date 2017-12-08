/obj/item/organ/internal/dwarf/liver
	name = "dwarf liver"
	hardpoint = "dwarf liver"
	origin_tech = "biotech=5;plasma=2"
	w_class = 3
	zone = "chest"
	slot = "plasmavessel"
	desc = "It needs alcohol to get through the working day."
	var/storedBooze = 375
	var/max_booze = 500
	var/booze_rate = 1.5

/mob/living/carbon/proc/getBooze()
	var/datum/organ/internal/dwarf/liver/OR = get_organdatum("dwarf liver")
	if(OR && OR.exists())
		var/obj/item/organ/internal/dwarf/liver/vessel = OR.organitem
		return vessel.storedBooze

/mob/living/carbon/proc/updateBoozeDisplay()
	if(hud_used) //clientless aliens
		hud_used.alien_plasma_display.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='magenta'>[round(getBooze())]</font></div>"

/mob/living/carbon/proc/adjustBooze(amount)
	var/datum/organ/internal/dwarf/liver/OR = get_organdatum("dwarf liver")
	if(OR && OR.exists())
		amount = max(500)
		amount = min(0) //upper limit of max_plasma, lower limit of 0
		return 1

/datum/species/dwarf/handle_chemicals(datum/reagent/consumable/ethanol/booze, mob/living/carbon/dwarf/owner)
	if(booze.boozepwr <= 45)
		owner.adjustBooze(1.5)
	else
		owner.adjustBooze(-0.1)

/obj/item/organ/internal/dwarf/liver/on_life()
	if(istype(owner, /mob/living/carbon/human))
		if(storedBooze >= 300)
			owner.adjustBruteLoss(-1)
			owner.adjustFireLoss(-1)
			owner.adjustToxLoss(-1)
			owner.adjustCloneLoss(-1)
		else
			owner.adjustBruteLoss()
			owner.adjustFireLoss()
			owner.adjustToxLoss()
			owner.adjustCloneLoss()
		if(storedBooze == 0)
			if(istype(owner, /mob/living/carbon/human))
				owner.adjustToxLoss(1.5)

/obj/item/organ/internal/dwarf/liver/on_insertion()
	..()
	if(istype(owner, /mob/living/carbon/human))
		var/mob/living/carbon/human/A = owner
		hardset_dna(A, null, null, null, null, /datum/species/dwarf)
		A.updateBoozeDisplay()

/obj/item/organ/internal/dwarf/liver/Remove(mob/living/carbon/M, special = 0)
	..()
	if(istype(owner, /mob/living/carbon/human))
		var/mob/living/carbon/human/A = M
		A.updateBoozeDisplay()

/mob/living/carbon/Stat()
	..()
	if(statpanel("Status"))
		var/datum/organ/internal/dwarf/liver/vessel = get_organdatum("plasmavessel")
		if(vessel && vessel.exists())
			var/obj/item/organ/internal/dwarf/liver/PV = vessel.organitem
			stat(null, "Booze Stored: [PV.storedBooze]/[PV.max_booze]")