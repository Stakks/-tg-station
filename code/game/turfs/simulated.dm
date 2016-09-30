/turf/simulated
	name = "station"
	var/wet = 0
	var/image/wet_overlay = null
	var/thermite = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	var/to_be_destroyed = 0 //Used for fire, if a melting temperature was reached, it will be destroyed
	var/max_fire_temperature_sustained = 0 //The max temperature of the fire which it was subjected to

/turf/simulated/New()
	..()
	levelupdate()
	if(smooth)
		smooth_icon(src)
		icon_state = ""

/turf/simulated/proc/burn_tile()

/turf/simulated/proc/MakeSlippery(var/wet_setting = SLIPPERY_TURF_WATER) // 1 = Water, 2 = Lube, 3 = Bluespace Lube
	if(wet >= wet_setting)
		return
	wet = wet_setting
	if(wet_setting == SLIPPERY_TURF_WATER)
		if(wet_overlay)
			overlays -= wet_overlay
			wet_overlay = null
		wet_overlay = image('icons/effects/water.dmi', src, "wet_floor_static")
		overlays += wet_overlay

	if(wet_setting == SLIPPERY_TURF_BLUBE)
		if(wet_overlay)
			overlays -= wet_overlay
			wet_overlay = null
		wet_overlay = image('icons/effects/water.dmi', src, "blue_floor_static")
		overlays += wet_overlay

	spawn(rand(790, 820)) // Purely so for visual effect
		if(!istype(src, /turf/simulated)) //Because turfs don't get deleted, they change, adapt, transform, evolve and deform. they are one and they are all.
			return
		if(wet > wet_setting) return
		wet = 0
		if(wet_overlay)
			overlays -= wet_overlay

/turf/simulated/Entered(atom/A, atom/OL)
	..()
	if (istype(A,/mob/living/carbon))
		var/mob/living/carbon/M = A
		if(M.lying)	return
		switch (src.wet)
			if(1) //wet floor
				if(!M.slip(2, 1, null, (NO_SLIP_WHEN_WALKING|STEP)))
					M.inertia_dir = 0
				return
			if(2) //lube
				M.slip(0, 4, null, (STEP|SLIDE|GALOSHES_DONT_HELP))
			if(3) //bluelube
				M.slip(0, 4, null, (STEP|SLIDE|GALOSHES_DONT_HELP|BLUESPACE_SLIPPERY))

/turf/simulated/ChangeTurf(var/path)
	. = ..()
	smooth_icon_neighbors(src)