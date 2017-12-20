//Make sure I'm not missing anything in the /dwarf/ directory that's needed here. Human animations used are temporary until a spritefag can make new ones.
/mob/living/carbon/dwarf/gib_animation(var/animate)
	..(animate, "gibbed-h")

/mob/living/carbon/dwarf/dust_animation(var/animate)
	..(animate, "dust-h")

/mob/living/carbon/dwarf/dust(var/animation = 1)
	..()

/mob/living/carbon/dwarf/spawn_gibs()
	if(dna)
		hgibs(loc, viruses, dna)
	else
		hgibs(loc, viruses, null)

/mob/living/carbon/dwarf/spawn_dust()
	new /obj/effect/decal/remains/human(loc)

/mob/living/carbon/dwarf/death(gibbed)
	if(stat == DEAD)	return
	if(status_flags & FAKEDEATH)	return
	if(healths)		healths.icon_state = "health5"
	stat = DEAD
	dizziness = 0
	jitteriness = 0
	heart_attack = 0

	if(istype(loc, /obj/mecha))
		var/obj/mecha/M = loc
		if(M.occupant == src)
			M.go_out()

	if(!gibbed)
		emote("dwarfgasp") //let the world KNOW WE ARE DEAD

	if(dna)
		dna.species.spec_death(gibbed,src)

	tod = worldtime2text()		//weasellos time of death patch
	if(mind)	mind.store_memory("Time of death: [tod]", 0)
	if(ticker && ticker.mode)
//		world.log << "k"
		sql_report_death(src)
		ticker.mode.check_win()		//Calls the rounds wincheck, mainly for wizard, malf, and changeling now
	return ..(gibbed)

/mob/living/carbon/dwarf/proc/makeSkeleton()
	if(!check_dna_integrity(src))	return
	status_flags |= DISFIGURED
	hardset_dna(src, null, null, null, null, /datum/species/skeleton)
	return 1