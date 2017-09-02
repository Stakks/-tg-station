/datum/round_event_control/vent_clog
	name = "Clogged Vents"
	typepath = /datum/round_event/vent_clog
	weight = 35
	announcement = 1

/datum/round_event/vent_clog
	announceWhen	= 5
	startWhen		= 1
	endWhen			= 40
	
	var/interval 	= 1
	var/list/vents  = list()

	
/datum/round_event/vent_clog/announce()
	priority_announce("The scrubbers network is experiencing a backpressure surge. Some ejection of contents may occur.", "Atmospherics alert")

/datum/round_event/vent_clog/setup()
	endWhen = rand(25, 100)
	for(var/obj/machinery/atmospherics/components/unary/vent_scrubber/temp_vent in machines)
		if(temp_vent.loc.z == ZLEVEL_STATION)
			var/datum/pipeline/temp_vent_parent = temp_vent.parents["p1"]
			if(temp_vent_parent.other_atmosmch.len > 8)
				vents += temp_vent
	if(!vents.len)
		return kill()

/datum/round_event/vent_clog/tick()
	if(activeFor % interval == 0)
		var/obj/vent = pick_n_take(vents)
		if(vent && vent.loc)
			
			var/datum/reagents/R
			
			if(vent.reagents && vent.reagents.total_volume) // Scubber has contents, use those
				R = vent.reagents
			else // Scrubber has no contents, eject some random shit instead
				R = new/datum/reagents(50)
				R.my_atom = vent
			
				var/list/gunk = list(
					"water","carbon","flour","radium","toxin","cleaner","nutriment","condensedcapsaicin","mushroomhallucinogen","lube",
					"plantbgone","banana","anti_toxin","space_drugs","morphine","holywater","ethanol","hot_coco","pacid",
					"b_sorium", "neurotoxin")
				R.add_reagent(pick(gunk), 50)
			
			var/datum/effect/effect/system/smoke_spread/chem/smoke = new
			smoke.set_up(R, rand(1, 2), 0, vent, 0, silent = 1)
			playsound(vent.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
			smoke.start()
			qdel(R)	//GC the reagents