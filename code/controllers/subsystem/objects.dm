var/datum/subsystem/objects/SSobj

/datum/proc/process()
	SSobj.processing.Remove(src)
	return 0

/datum/subsystem/objects
	name = "Objects"
	priority = 12

	var/list/processing = list()
	var/list/currentrun = list()

/datum/subsystem/objects/New()
	NEW_SS_GLOBAL(SSobj)

/datum/subsystem/objects/Initialize(timeofday, zlevel)

	for(var/atom/movable/M in world)
		if (zlevel && M.z != zlevel)
			continue
		M.initialize()
		
	if (zlevel)
		return ..()
		
	// This was located in the code/game/turfs/simulated/dirtystation.dm file, faster to just put it here, though
	spawn(-1) // This block must be fully executed before code can continue and exit the function but...
	{
		var/n = 0
		for(var/i=1, i<=world.maxz, i++)
			spawn(0) // ... we can process these in basically any order
			for(var/turf/simulated/floor/F in block(locate(1,1,i), locate(world.maxx,world.maxy,i)))
			{
				// Discard invalid entries before attempting anything else
				if (!F || !F.loc)
					continue 

				// These look weird if you make them dirty
				if (istype(F, /turf/simulated/floor/carpet) || istype(F, /turf/simulated/floor/grass) || \
					istype(F, /turf/simulated/floor/plating/beach) || istype(F, /turf/simulated/floor/holofloor) || \
					istype(F, /turf/simulated/floor/plating/snow) || istype(F, /turf/simulated/floor/plating/ironsand))
					continue

				// These areas can't be dirty
				if (istype(F.loc, /area/centcom) || istype(F.loc, /area/holodeck) || \
					istype(F.loc, /area/library) || istype(F.loc, /area/janitor) || \
					istype(F.loc, /area/chapel) || istype(F.loc, /area/space/mine/explored) || \
					istype(F.loc, /area/space/mine/unexplored) || istype(F.loc, /area/solar) || \
					istype(F.loc, /area/atmos) || istype(F.loc, /area/medical/virology))
					continue
					
				// Ignore inappropriate objects
				if (locate(/obj/structure/grille) in F.contents)
					continue

				// High dirt - 1/3
				if (prob(66))
					continue
					
				if(n < 25)
					log_admin("DEBUG [n] :: TURF ([F], [istype(F, /turf/)], [F.x],[F.y],[F.z]) :: AREA :: [F.loc] :: [istype(F.loc, /area/)]")
					n++

				if (istype(F.loc, /area/toxins/test_area) || istype(F.loc, /area/mine/production) || \
					istype(F.loc, /area/mine/living_quarters) || istype(F.loc, /area/mine/north_outpost) || \
					istype(F.loc, /area/wreck) || istype(F.loc, /area/derelict) || \
					istype(F.loc, /area/djstation))
				{
					new /obj/effect/decal/cleanable/dirt(src)
					continue 
				}

				// Medium dirt - 1/15
				if (prob(80))
					continue 
				
				if (istype(F.loc, /area/engine) || istype(F.loc,/area/assembly) || \
					istype(F.loc,/area/maintenance) || istype(F.loc,/area/construction))
				{
					if (prob(3))
						new /obj/effect/decal/cleanable/blood/old(src)
					else
						if (prob(35))
							if (prob(4))
								new /obj/effect/decal/cleanable/robot_debris/old(src)
							else
								new /obj/effect/decal/cleanable/oil(src)
						else
							new /obj/effect/decal/cleanable/dirt(src)
					continue 
				}
				
				if (istype(F.loc, /area/crew_quarters/toilet) || istype(F.loc, /area/crew_quarters/locker/locker_toilet) || \
					istype(F.loc, /area/crew_quarters/bar))
				{
					if (prob(40))
						if (prob(90))
							new /obj/effect/decal/cleanable/vomit/old(src)
						else
							new /obj/effect/decal/cleanable/blood/old(src)
					continue 
				}

				if (istype(F.loc, /area/quartermaster))
				{
					if (prob(25))
						new /obj/effect/decal/cleanable/oil(src)
					continue 
				}

				// Low dirt - 1/60
				if (prob(75))
					continue 
				
				if (istype(F.loc, /area/turret_protected) || istype(F.loc, /area/security))
				{
					if (prob(20))
						if (prob(5))
							new /obj/effect/decal/cleanable/blood/gibs/old(src)
						else
							new /obj/effect/decal/cleanable/blood/old(src)
					continue 
				}

				if (istype(F.loc, /area/crew_quarters/kitchen))
				{
					if (prob(60))
						if (prob(50))
							new /obj/effect/decal/cleanable/egg_smudge(src)
						else
							new /obj/effect/decal/cleanable/flour(src)
					continue 
				}

				if (istype(F.loc, /area/medical))
				{
					if (prob(66))
						if (prob(5))
							new /obj/effect/decal/cleanable/blood/gibs/old(src)
						else
							new /obj/effect/decal/cleanable/blood/old(src)
					else
						if (prob(30))
							if(istype(F.loc, /area/medical/morgue))
								new /obj/item/weapon/ectoplasm(src)
							else
								new /obj/effect/decal/cleanable/vomit/old(src)
					continue 
				}

				if (istype(F.loc, /area/toxins))
				{
					if (prob(20))
						new /obj/effect/decal/cleanable/greenglow(src)
					continue 
				}
			}
	}
	
	..()


/datum/subsystem/objects/stat_entry()
	..("P:[processing.len]")


/datum/subsystem/objects/fire(resumed = 0)
	if (!resumed)
		currentrun = processing.Copy()
	while(currentrun.len)
		var/datum/thing = currentrun[1]
		currentrun.Cut(1, 2)
		if(thing)
			thing.process(wait)
		else
			SSobj.processing.Remove(thing)
		if (MC_TICK_CHECK)
			return
