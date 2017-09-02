
/datum/reagent/blood
			data = list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"=null,"resistances"=null,"trace_chem"=null,"mind"=null,"ckey"=null,"gender"=null,"real_name"=null,"cloneable"=null,"factions"=null)
			name = "Blood"
			id = "blood"
			can_synth = 0
			color = "#C80000" // rgb: 200, 0, 0

/datum/reagent/blood/reaction_mob(mob/M, method=TOUCH, reac_volume)
	var/datum/reagent/blood/self = src
	if(self.data && self.data["viruses"])
		for(var/datum/disease/D in self.data["viruses"])

			if(D.spread_flags & SPECIAL || D.spread_flags & NON_CONTAGIOUS)
				continue

			if(method == TOUCH || method == VAPOR)
				M.ContractDisease(D)
			else //injected
				M.ForceContractDisease(D)

/datum/reagent/blood/on_new(var/list/data)
	if(istype(data))
		SetViruses(src, data)

/datum/reagent/blood/on_merge(var/list/data)
	if(src.data && data)
		src.data["cloneable"] = 0 //On mix, consider the genetic sampling unviable for pod cloning, or else we won't know who's even getting cloned, etc
		if(src.data["viruses"] || data["viruses"])

			var/list/mix1 = src.data["viruses"]
			var/list/mix2 = data["viruses"]

			// Stop issues with the list changing during mixing.
			var/list/to_mix = list()

			for(var/datum/disease/advance/AD in mix1)
				to_mix += AD
			for(var/datum/disease/advance/AD in mix2)
				to_mix += AD

			var/datum/disease/advance/AD = Advance_Mix(to_mix)
			if(AD)
				var/list/preserve = list(AD)
				for(var/D in src.data["viruses"])
					if(!istype(D, /datum/disease/advance))
						preserve += D
				src.data["viruses"] = preserve
	return 1

/datum/reagent/blood/reaction_turf(turf/simulated/T, reac_volume)//splash the blood all over the place
	if(!istype(T)) return
	var/datum/reagent/blood/self = src
	if(reac_volume < 3) return
	//var/datum/disease/D = self.data["virus"]
	if(!self.data["donor"] || istype(self.data["donor"], /mob/living/carbon/human))
		var/obj/effect/decal/cleanable/blood/blood_prop = locate() in T //find some blood here
		if(!blood_prop) //first blood!
			blood_prop = new(T)
			blood_prop.blood_DNA[self.data["blood_DNA"]] = self.data["blood_type"]

		for(var/datum/disease/D in self.data["viruses"])
			var/datum/disease/newVirus = D.Copy(1)
			blood_prop.viruses += newVirus
			newVirus.holder = blood_prop


	else if(istype(self.data["donor"], /mob/living/carbon/monkey))
		var/obj/effect/decal/cleanable/blood/blood_prop = locate() in T
		if(!blood_prop)
			blood_prop = new(T)
			blood_prop.blood_DNA["Non-Human DNA"] = "A+"
		for(var/datum/disease/D in self.data["viruses"])
			var/datum/disease/newVirus = D.Copy(1)
			blood_prop.viruses += newVirus
			newVirus.holder = blood_prop

	else if(istype(self.data["donor"], /mob/living/carbon/alien))
		var/obj/effect/decal/cleanable/blood/xeno/blood_prop = locate() in T
		if(!blood_prop)
			blood_prop = new(T)
			blood_prop.blood_DNA["UNKNOWN DNA STRUCTURE"] = "X*"
		for(var/datum/disease/D in self.data["viruses"])
			var/datum/disease/newVirus = D.Copy(1)
			blood_prop.viruses += newVirus
			newVirus.holder = blood_prop
	return

/datum/reagent/vaccine
	//data must contain virus type
	name = "Vaccine"
	id = "vaccine"
	can_synth = 0 //for the chem synth
	color = "#C81040" // rgb: 200, 16, 64

/datum/reagent/vaccine/reaction_mob(mob/M, method=TOUCH, reac_volume)
	var/datum/reagent/vaccine/self = src
	if(islist(self.data) && method == INGEST)
		for(var/datum/disease/D in M.viruses)
			if(D.GetDiseaseID() in self.data)
				D.cure()
		M.resistances |= self.data
	return

/datum/reagent/vaccine/on_merge(var/list/data)
	if(istype(data))
		src.data |= data.Copy()


/datum/reagent/water
	name = "Water"
	id = "water"
	description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
	color = "#AAAAAA77" // rgb: 170, 170, 170, 77 (alpha)
	var/cooling_temperature = 2
	lub_c = 0.5
	lub_l = 50
	cool_c = 1.5
	cool_l = 273.15
/*
 *	Water reaction to turf
 */

/datum/reagent/water/reaction_turf(turf/simulated/T, reac_volume)
	if (!istype(T)) return
	var/CT = cooling_temperature
	if(reac_volume >= 10)
		T.MakeSlippery(SLIPPERY_TURF_WATER)

	for(var/mob/living/carbon/slime/M in T)
		M.apply_water()


	var/obj/effect/hotspot/hotspot = (locate(/obj/effect/hotspot) in T)

	if(hotspot && !istype(T, /turf/space))
		if(T.air)
			var/datum/gas_mixture/G = T.air
			G.temperature = max(min(G.temperature-(CT*1000),G.temperature/CT),0)
			G.react()
			hotspot.Kill()
	return

/*
 *	Water reaction to an object
 */

/datum/reagent/water/reaction_obj(obj/O, reac_volume)
	// Monkey cube
	if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/monkeycube))
		var/obj/item/weapon/reagent_containers/food/snacks/monkeycube/cube = O
		if(!cube.wrapped)
			cube.Expand()

	// Dehydrated carp
	if(istype(O,/obj/item/toy/carpplushie/dehy_carp))
		var/obj/item/toy/carpplushie/dehy_carp/dehy = O
		dehy.Swell() // Makes a carp

	return

/*
 *	Water reaction to a mob
 */

/datum/reagent/water/reaction_mob(mob/living/M, method=TOUCH, reac_volume)//Splashing people with water can help put them out!
	if(!istype(M, /mob/living))
		return
	if(method == TOUCH)
		M.adjust_fire_stacks(-(reac_volume / 10))
		if(M.fire_stacks <= 0)
			M.ExtinguishMob()
		return
	if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		var/datum/species/S = H.dna.species
		if(S.id == "abductor")
			M.adjustBruteLoss(reac_volume) //abductors don't like water
			
/datum/reagent/water/reaction_hydroponics_tray(var/obj/machinery/hydroponics/H, var/reac_volume, var/mob/user)
	if(reac_volume >= 1)
		H.adjustWater(round(reac_volume) * 1)
	return

/datum/reagent/water/holywater
	name = "Holy Water"
	id = "holywater"
	synth_cost = 66
	description = "Water blessed by some deity."
	color = "#E0E8EF" // rgb: 224, 232, 239

/datum/reagent/water/holywater/on_mob_life(var/mob/living/M as mob)
	if(!data) data = 1
	data++
	M.jitteriness = max(M.jitteriness-5,0)
	if(data >= 30)		// 12 units, 54 seconds @ metabolism 0.4 units & tick rate 1.8 sec
		if (!M.health_status.verbal_stutter) M.health_status.verbal_stutter = 1
		M.health_status.verbal_stutter += 4
		M.Dizzy(5)
		if(iscultist(M) && prob(5))
			M.say(pick("Av'te Nar'sie","Pa'lid Mors","INO INO ORA ANA","SAT ANA!","Daim'niodeis Arc'iai Le'eones","Egkau'haom'nai en Chaous","Ho Diak'nos tou Ap'iron","R'ge Na'sie","Diabo us Vo'iscum","Si gn'um Co'nu"))
	if(data >= 75 && prob(33))	// 30 units, 135 seconds
		if (!M.health_status.spatial_confuse) M.health_status.spatial_confuse = 1
		M.health_status.spatial_confuse += 3
		if(iscultist(M))
			ticker.mode.remove_cultist(M.mind)
			holder.remove_reagent(src.id, src.volume)	// maybe this is a little too perfect and a max() cap on the statuses would be better??
			M.jitteriness = 0
			M.health_status.verbal_stutter = 0
			M.health_status.spatial_confuse = 0
	if(!holder)
		return
	holder.remove_reagent(src.id, 0.4)	//fixed consumption to prevent balancing going out of whack
	return

/datum/reagent/water/holywater/reaction_turf(turf/simulated/T, reac_volume)
	..()
	if(!istype(T)) return
	if(reac_volume>=10)
		for(var/obj/effect/rune/R in T)
			qdel(R)
	T.Bless()
	
/datum/reagent/water/holywater/reaction_hydroponics_tray(var/obj/machinery/hydroponics/H, var/reac_volume, var/mob/user)
	if(reac_volume >= 1)
		H.adjustWater(round(reac_volume) * 1)
		H.adjustHealth(round(reac_volume) * 0.1)
	return

/datum/reagent/fuel/unholywater		//if you somehow managed to extract this from someone, dont splash it on yourself and have a smoke
	name = "Unholy Water"
	id = "unholywater"
	synth_cost = 66
	description = "Something that shouldn't exist on this plane of existance."

/datum/reagent/fuel/unholywater/on_mob_life(var/mob/living/M as mob)
	if(iscultist(M))
		M.status_flags |= GOTTAGOFAST
		M.drowsyness = max(M.drowsyness-5, 0)
		M.AdjustParalysis(-2)
		M.AdjustStunned(-2)
		M.AdjustWeakened(-2)
	else
		M.adjustToxLoss(2)
		M.adjustFireLoss(2)
		M.adjustOxyLoss(2)
		M.adjustBruteLoss(2)
		M.adjustBrainLoss(5)
	holder.remove_reagent(src.id, 1)

/datum/reagent/hellwater			//if someone has this in their system they've really pissed off an eldrich god
	name = "Hell Water"
	id = "hell_water"
	synth_cost = 666
	description = "YOUR FLESH! IT BURNS!"

/datum/reagent/hellwater/on_mob_life(var/mob/living/M as mob)
	M.fire_stacks = min(5,M.fire_stacks + 3)
	M.IgniteMob()			//Only problem with igniting people is currently the commonly availible fire suits make you immune to being on fire
	M.adjustToxLoss(1)
	M.adjustFireLoss(1)		//Hence the other damages... ain't I a bastard?
	M.adjustBrainLoss(5)
	holder.remove_reagent(src.id, 1)

/datum/reagent/lube
	name = "Space Lube"
	id = "lube"
	synth_cost = 3
	description = "Lubricant is a substance introduced between two moving surfaces to reduce the friction and wear between them. giggity."
	color = "#009CA8" // rgb: 0, 156, 168
	lub_c = 2
	lub_l = 99
	cool_c = 1
	cool_l = 260

/datum/reagent/lube/reaction_turf(turf/simulated/T, reac_volume)
	if (!istype(T)) return
	if(reac_volume >= 1)
		T.MakeSlippery(SLIPPERY_TURF_LUBE)

/datum/reagent/slimetoxin
	name = "Mutation Toxin"
	id = "mutationtoxin"
	synth_cost = 10
	can_synth = 1
	description = "A corruptive toxin produced by slimes."
	color = "#13BC5E" // rgb: 19, 188, 94

/datum/reagent/unstableslimetoxin
	name = "Unstable Mutation Toxin"
	id = "unstablemutationtoxin"
	synth_cost = 20
	can_synth = 0
	description = "An unstable and unpredictable corruptive toxin produced by slimes."
	color = "#5EFF3B" //RGB: 94, 255, 59
	metabolization_rate = INFINITY //So it instantly removes all of itself

/datum/reagent/unstableslimetoxin/on_mob_life(var/mob/living/carbon/human/H as mob)
	..()
	H << "<span class='warning'><b>You crumple in agony as your flesh wildly morphs into new forms!</b></span>"
	H.visible_message("<b>[H]</b> falls to the ground and screams as their skin bubbles and froths!") //'froths' sounds painful when used with SKIN.
	H.Weaken(3)
	sleep(30)
	var/list/blacklisted_species = list(/datum/species/zombie, /datum/species/skeleton, /datum/species/human, /datum/species/golem, /datum/species/golem/adamantine, /datum/species/shadow, /datum/species/shadow/ling, /datum/species/plasmaman, /datum/species)
	var/list/possible_morphs = typesof(/datum/species/) - blacklisted_species
	var/datum/species/mutation = pick(possible_morphs)
	if(prob(90) && mutation && !istype(H.dna.species, /datum/species/golem) )
		H << "<span class='danger'>The pain subsides. You feel... different.</span>"
		hardset_dna(H, null, null, null, null, mutation)
		H.regenerate_icons()
		if(mutation == /datum/species/slime)
			H.faction |= "slime"
		else
			H.faction -= "slime"
	else
		H << "<span class='danger'>The pain vanishes suddenly. You feel no different.</span>"
	return 1

/datum/reagent/aslimetoxin
	name = "Advanced Mutation Toxin"
	id = "amutationtoxin"
	synth_cost = 30
	can_synth = 0
	description = "An advanced corruptive toxin produced by slimes."
	color = "#13BC5E" // rgb: 19, 188, 94

/datum/reagent/aslimetoxin/reaction_mob(mob/M, method=TOUCH, reac_volume)
	M.ForceContractDisease(new /datum/disease/transformation/slime(0))

/datum/reagent/serotrotium
	name = "Serotrotium"
	id = "serotrotium"
	synth_cost = 5
	description = "A chemical compound that promotes concentrated production of the serotonin neurotransmitter in humans."
	color = "#202040" // rgb: 20, 20, 40
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

/datum/reagent/serotrotium/on_mob_life(var/mob/living/M as mob)
	if(ishuman(M))
		if(prob(7)) M.emote(pick("twitch","drool","moan","gasp"))
	..()
	return

/datum/reagent/glycerol
	name = "Glycerol"
	id = "glycerol"
	can_synth = 1
	description = "Glycerol is a simple polyol compound. Glycerol is sweet-tasting and of low toxicity."
	color = "#808080" // rgb: 128, 128, 128

/datum/reagent/sterilizine
	name = "Sterilizine"
	id = "sterilizine"
	description = "Sterilizes wounds in preparation for surgery."
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/fuel
	name = "Welding fuel"
	id = "fuel"
	description = "Required for welders. Flamable."
	color = "#660000" // rgb: 102, 0, 0

/datum/reagent/fuel/reaction_mob(mob/living/M, method=TOUCH, reac_volume)//Splashing people with welding fuel to make them easy to ignite!
	if(!istype(M, /mob/living))
		return
	if(method == TOUCH || method == VAPOR)
		M.adjust_fire_stacks(reac_volume / 10)
		return

/datum/reagent/fuel/on_mob_life(var/mob/living/M as mob)
	M.adjustToxLoss(1)
	..()
	return

/datum/reagent/space_cleaner
	name = "Space cleaner"
	id = "cleaner"
	synth_cost = 5
	description = "A compound used to clean things. Now with 50% more sodium hypochlorite!"
	color = "#A5F0EE" // rgb: 165, 240, 238

/datum/reagent/space_cleaner/reaction_obj(obj/O, reac_volume)
	if(istype(O,/obj/effect/decal/cleanable))
		qdel(O)
	else
		if(O)
			O.clean_blood()

/datum/reagent/space_cleaner/reaction_turf(turf/T, reac_volume)
	if(volume >= 1)
		T.clean_blood()
		for(var/obj/effect/decal/cleanable/C in T)
			qdel(C)

		for(var/mob/living/simple_animal/slime/M in T)
			M.adjustToxLoss(rand(5,10))
	if(istype(T, /turf/simulated/floor))
		var/turf/simulated/floor/F = T
		if(reac_volume >= 1)
			F.dirt = 0

/datum/reagent/space_cleaner/reaction_mob(mob/M, method=TOUCH, reac_volume)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(istype(M,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = M
			if(H.lip_style)
				H.lip_style = null
				H.update_body()
		if(C.r_hand)
			C.r_hand.clean_blood()
		if(C.l_hand)
			C.l_hand.clean_blood()
		if(C.wear_mask)
			if(C.wear_mask.clean_blood())
				C.update_inv_wear_mask(0)
		if(ishuman(M))
			var/mob/living/carbon/human/H = C
			if(H.head)
				if(H.head.clean_blood())
					H.update_inv_head(0)
			if(H.wear_suit)
				if(H.wear_suit.clean_blood())
					H.update_inv_wear_suit(0)
			else if(H.w_uniform)
				if(H.w_uniform.clean_blood())
					H.update_inv_w_uniform(0)
			if(H.shoes)
				if(H.shoes.clean_blood())
					H.update_inv_shoes(0)
		M.clean_blood()

/datum/reagent/cryptobiolin
	name = "Cryptobiolin"
	id = "cryptobiolin"
	synth_cost = 3
	description = "Cryptobiolin causes confusion and dizzyness."
	color = "#C8A5DC" // rgb: 200, 165, 220
	metabolization_rate = 1.5 * REAGENTS_METABOLISM

/datum/reagent/cryptobiolin/on_mob_life(var/mob/living/M as mob)
	M.Dizzy(1)
	if(!M.health_status.spatial_confuse)
		M.health_status.spatial_confuse = 1
	M.health_status.spatial_confuse = max(M.health_status.spatial_confuse, 20)
	..()
	return


/datum/reagent/nanites
	name = "Nanomachines"
	id = "nanomachines"
	synth_cost = 25
	can_synth = 0
	description = "Microscopic construction robots."
	color = "#535E66" // rgb: 83, 94, 102

/datum/reagent/nanites/reaction_mob(mob/M, method=TOUCH, reac_volume)
	if( (prob(10) && method==VAPOR) || method==INGEST || method==TOUCH)
		M.ForceContractDisease(new /datum/disease/transformation/robot(0))

/datum/reagent/xenomicrobes
	name = "Xenomicrobes"
	id = "xenomicrobes"
	synth_cost = 50
	can_synth = 0
	description = "Microbes with an entirely alien cellular structure."
	color = "#535E66" // rgb: 83, 94, 102

/datum/reagent/xenomicrobes/reaction_mob(mob/M, method=TOUCH, reac_volume)
	if( (prob(10) && method==VAPOR) || method==INGEST|| method==TOUCH)
		M.ContractDisease(new /datum/disease/transformation/xeno(0))

/datum/reagent/fluorosurfactant//foam precursor
	name = "Fluorosurfactant"
	id = "fluorosurfactant"
	synth_cost = 5
	description = "A perfluoronated sulfonic acid that forms a foam when mixed with water."
	color = "#9E6B38" // rgb: 158, 107, 56

/datum/reagent/foaming_agent// Metal foaming agent. This is lithium hydride. Add other recipes (e.g. LiH + H2O -> LiOH + H2) eventually.
	name = "Foaming agent"
	id = "foaming_agent"
	synth_cost = 2
	description = "A agent that yields metallic foam when mixed with light metal and a strong acid."
	reagent_state = SOLID
	color = "#664B63" // rgb: 102, 75, 99

/datum/reagent/ammonia
	name = "Ammonia"
	id = "ammonia"
	synth_cost = 4
	description = "A caustic substance commonly used in fertilizer or household cleaners."
	reagent_state = GAS
	color = "#404030" // rgb: 64, 64, 48
	
/datum/reagent/ammonia/reaction_hydroponics_tray(var/obj/machinery/hydroponics/H, var/reac_volume, var/mob/user)
	if(reac_volume >= 1)
		H.adjustHealth(round(reac_volume) * 0.5)
		H.adjustNutri(round(reac_volume) * 1)
		H.adjustSYield(round(reac_volume) * 0.01)
	return

/datum/reagent/diethylamine
	name = "Diethylamine"
	id = "diethylamine"
	synth_cost = 5
	description = "A secondary amine, mildly corrosive."
	color = "#604030" // rgb: 96, 64, 48

/datum/reagent/diethylamine/reaction_hydroponics_tray(var/obj/machinery/hydroponics/H, var/reac_volume, var/mob/user)
	if(reac_volume >= 1)
		H.adjustHealth(round(reac_volume) * 1)
		H.adjustNutri(round(reac_volume) * 2)
		H.adjustSYield(round(reac_volume) * 0.02)
		H.adjustPests(-rand(1,2))
	return

/////////////////////////Coloured Crayon Powder////////////////////////////
//For colouring in /proc/mix_color_from_reagents


/datum/reagent/crayonpowder
	name = "Crayon Powder"
	id = "crayon powder"
	var/colorname = "none"
	description = "A powder made by grinding down crayons, good for colouring chemical reagents."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 207, 54, 0

/datum/reagent/crayonpowder/New()
	description = "\an [colorname] powder made by grinding down crayons, good for colouring chemical reagents."


/datum/reagent/crayonpowder/red
	name = "Red Crayon Powder"
	id = "redcrayonpowder"
	colorname = "red"

/datum/reagent/crayonpowder/orange
	name = "Orange Crayon Powder"
	id = "orangecrayonpowder"
	colorname = "orange"
	color = "#FF9300" // orange

/datum/reagent/crayonpowder/yellow
	name = "Yellow Crayon Powder"
	id = "yellowcrayonpowder"
	colorname = "yellow"
	color = "#FFF200" // yellow

/datum/reagent/crayonpowder/green
	name = "Green Crayon Powder"
	id = "greencrayonpowder"
	colorname = "green"
	color = "#A8E61D" // green

/datum/reagent/crayonpowder/blue
	name = "Blue Crayon Powder"
	id = "bluecrayonpowder"
	colorname = "blue"
	color = "#00B7EF" // blue

/datum/reagent/crayonpowder/purple
	name = "Purple Crayon Powder"
	id = "purplecrayonpowder"
	colorname = "purple"
	color = "#DA00FF" // purple

/datum/reagent/crayonpowder/invisible
	name = "Invisible Crayon Powder"
	id = "invisiblecrayonpowder"
	colorname = "invisible"
	color = "#FFFFFF00" // white + no alpha




//////////////////////////////////Hydroponics stuff///////////////////////////////

/datum/reagent/plantnutriment
	name = "Generic nutriment"
	id = "plantnutriment"
	description = "Some kind of nutriment. You can't really tell what it is. You should probably report it, along with how you obtained it."
	color = "#000000" // RBG: 0, 0, 0
	var/tox_prob = 0

/datum/reagent/plantnutriment/on_mob_life(var/mob/living/M as mob)
	if(prob(tox_prob))
		M.adjustToxLoss(1*REM)
	..()
	return

/datum/reagent/plantnutriment/eznutriment
	name = "E-Z-Nutrient"
	id = "eznutriment"
	description = "Cheap and extremely common type of plant nutriment."
	color = "#376400" // RBG: 50, 100, 0
	tox_prob = 10

/datum/reagent/plantnutriment/eznutriment/reaction_hydroponics_tray(var/obj/machinery/hydroponics/H, var/reac_volume, var/mob/user)
	if(reac_volume >= 1)
		H.yieldmod = 1
		H.mutmod = 1
		H.adjustNutri(round(reac_volume) * 1)
	return

/datum/reagent/plantnutriment/left4zednutriment
	name = "Left 4 Zed"
	id = "left4zednutriment"
	description = "Unstable nutriment that makes plants mutate more often than usual."
	color = "#1A1E4D" // RBG: 26, 30, 77
	tox_prob = 25
	
/datum/reagent/plantnutriment/left4zednutriment/reaction_hydroponics_tray(var/obj/machinery/hydroponics/H, var/reac_volume, var/mob/user)
	if(reac_volume >= 1)
		H.yieldmod = 0
		H.mutmod = 2
		H.adjustNutri(round(reac_volume) * 1)
	return

/datum/reagent/plantnutriment/robustharvestnutriment
	name = "Robust Harvest"
	id = "robustharvestnutriment"
	description = "Very potent nutriment that prevents plants from mutating."
	color = "#9D9D00" // RBG: 157, 157, 0
	tox_prob = 15

/datum/reagent/plantnutriment/robustharvestnutriment/reaction_hydroponics_tray(var/obj/machinery/hydroponics/H, var/reac_volume, var/mob/user)
	if(reac_volume >= 1)
		H.yieldmod = 2
		H.mutmod = 0
		H.adjustNutri(round(reac_volume) * 1)
	return





// GOON OTHERS



/datum/reagent/oil
	name = "Oil"
	id = "oil"
	synth_cost = 3
	description = "Burns in a small smoky fire, mostly used to get Ash."
	reagent_state = LIQUID
	lub_c = 1
	lub_l = 100
	cool_c = 1.5
	cool_l = 150
	color = "#C8A5DC"

/datum/reagent/stable_plasma
	name = "Stable Plasma"
	id = "stable_plasma"
	description = "Non-flammable plasma locked into a liquid form that cannot ignite or become gaseous/solid."
	reagent_state = LIQUID
	color = "#C8A5DC"

/datum/reagent/stable_plasma/on_mob_life(mob/living/M)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.adjustPlasma(10)
	..()
	return

/datum/reagent/carpet
	name = "Carpet"
	id = "carpet"
	synth_cost = 2
	description = "A slippery solution."
	reagent_state = LIQUID
	color = "#C8A5DC"

/datum/reagent/carpet/reaction_turf(turf/simulated/T, reac_volume)
	if(istype(T, /turf/simulated/floor/plating) || istype(T, /turf/simulated/floor/plasteel))
		var/turf/simulated/floor/F = T
		F.ChangeTurf(/turf/simulated/floor/carpet)
	..()
	return

/datum/reagent/bromine
	name = "Bromine"
	id = "bromine"
	synth_cost = 5
	description = "A highly reactive chemical element." //It's a halogen you dip, not a watery solution
	reagent_state = LIQUID
	color = "#E59049"
	
/datum/reagent/bromine/on_mob_life(var/mob/living/M as mob) //People have to carry this shit around in lead-lined steel tanks.
	M.adjustToxLoss(1*REM) //This shit eats through aluminum, too.
	M.adjustBruteLoss(1*REM) //What made you think you could drink it?
	..()
	return

/datum/reagent/phenol
	name = "Phenol"
	id = "phenol"
	synth_cost = 6
	description = "Used for certain medical recipes."
	reagent_state = LIQUID
	color = "#C8A5DC"

/datum/reagent/ash
	name = "Ash"
	id = "ash"
	synth_cost = 2
	description = "Basic ingredient in a couple of recipes."
	reagent_state = LIQUID
	color = "#C8A5DC"

/datum/reagent/acetone
	name = "Acetone"
	id = "acetone"
	synth_cost = 5
	description = "Common ingredient in other recipes."
	reagent_state = LIQUID
	color = "#C8A5DC"

/datum/reagent/colorful_reagent
	name = "Colorful Reagent"
	id = "colorful_reagent"
	synth_cost = 15
	description = "A solution."
	reagent_state = LIQUID
	color = "#C8A5DC"
	var/list/random_color_list = list("#00aedb","#a200ff","#f47835","#d41243","#d11141","#00b159","#00aedb","#f37735","#ffc425","#008744","#0057e7","#d62d20","#ffa700")


/datum/reagent/colorful_reagent/on_mob_life(mob/living/M)
	if(M && isliving(M))
		M.color = pick(random_color_list)
	..()
	return

/datum/reagent/colorful_reagent/reaction_mob(mob/living/M, reac_volume)
	if(M && isliving(M))
		M.color = pick(random_color_list)
	..()
	return
/datum/reagent/colorful_reagent/reaction_obj(obj/O, reac_volume)
	if(O)
		O.color = pick(random_color_list)
	..()
	return
/datum/reagent/colorful_reagent/reaction_turf(turf/T, reac_volume)
	if(T)
		T.color = pick(random_color_list)
	..()
	return

/datum/reagent/hair_dye
	name = "Quantum Hair Dye"
	id = "hair_dye"
	synth_cost = 19
	description = "A solution."
	reagent_state = LIQUID
	color = "#C8A5DC"
	var/list/potential_colors = list("0ad","a0f","f73","d14","d14","0b5","0ad","f73","fc2","084","05e","d22","fa0") // fucking hair code

/datum/reagent/hair_dye/reaction_mob(mob/living/M, reac_volume)
	if(M && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.hair_color = pick(potential_colors)
		H.facial_hair_color = pick(potential_colors)
		H.update_hair()
	..()
	return

/datum/reagent/barbers_aid
	name = "Barber's Aid"
	id = "barbers_aid"
	synth_cost = 6
	description = "A solution to hair loss across the world."
	reagent_state = LIQUID
	color = "#C8A5DC"

/datum/reagent/barbers_aid/reaction_mob(mob/living/M, reac_volume)
	if(M && ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/sprite_accessory/hair/picked_hair = pick(hair_styles_list)
		var/datum/sprite_accessory/facial_hair/picked_beard = pick(facial_hair_styles_list)
		H.hair_style = picked_hair
		H.facial_hair_style = picked_beard
		H.update_hair()
	..()
	return

/datum/reagent/concentrated_barbers_aid
	name = "Concentrated Barber's Aid"
	id = "concentrated_barbers_aid"
	synth_cost = 9
	description = "A concentrated solution to hair loss across the world."
	reagent_state = LIQUID
	color = "#C8A5DC"

/datum/reagent/concentrated_barbers_aid/reaction_mob(mob/living/M, reac_volume)
	if(M && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.hair_style = "Very Long Hair"
		H.facial_hair_style = "Very Long Beard"
		H.update_hair()
	..()
	return

/datum/reagent/saltpetre
	name = "Saltpetre"
	id = "saltpetre"
	synth_cost = 5
	description = "Volatile."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132

/datum/reagent/bluespacejelly
	name = "Bluespace Jelly"
	id = "bluespacejelly"
	description = "A strange, viscous pseudo-substance composed of tiny holes in quantum fields. Not recommended for consumption."
	reagent_state = LIQUID
	can_synth = 0
	color = "#3399ff"
	metabolization_rate = 4*REAGENTS_METABOLISM
	overdose_threshold = 30

/datum/reagent/bluespacejelly/on_mob_delete(var/mob/living/M as mob)
	M.adjustToxLoss(current_cycle*REM)
	M.adjustBruteLoss(current_cycle*REM)
	..()

/datum/reagent/bluespacejelly/on_mob_life(mob/living/M)
	var/blink_range = current_cycle
	if(M && ishuman(M))

		if(blink_range <= 2) //The spacetime continuum hasn't acclimated to your consuming things that weren't supposed to be consumed!
			do_teleport(M, get_turf(M), blink_range + 1, asoundin = 'sound/effects/phasein.ogg')

		else //The spacetime continuum thinks you've had enough fun.
			do_teleport(M, get_turf(M), 12/blink_range, asoundin = 'sound/effects/phasein.ogg')

			if (M.health_status.spatial_confuse <= 6)
				M.health_status.spatial_confuse += 2

			if(prob(17))
				M.visible_message("<span class = 'danger'>[M]'s hands seem to flicker and vanish for a moment!</span>")
				var/obj/item/RI = M.get_active_hand()
				var/obj/item/LI = M.get_inactive_hand()
				if(RI)
					M.unEquip(RI)
				if (LI)
					M.unEquip(LI) //Not going to let you off with breaking into the captain's office that easily!
	..()
	return

/datum/reagent/bluespacejelly/overdose_process(mob/living/M)	//You took too much of this!
	var/list/droppables = M.get_equipped_items()

	if(prob(33))
		M << "<span class = 'userdanger'>You don't feel together...</span>"
		M.adjustBruteLoss(REM)
		M.adjustCloneLoss(0.5*REM) //NOT FUN!

		if (M.hallucination <= 10)
			M.hallucination += 5

	if (prob(20))
		M.visible_message("<span class = 'danger'>[M]'s body seems to flicker and vanish for a moment!</span>")
		do_teleport(M, get_turf(M), 3, asoundin = 'sound/effects/phasein.ogg')
		for (var/obj/item/O in droppables)
			if (O)
				M.unEquip(O)
				break

	if (prob(1))
		var/list/tlorgan = M.get_all_internal_organs() //no longer refrains from removing vital organs
		var/toremove = rand(1, tlorgan.len)
		if (tlorgan)
			var/datum/organ/internal/orgdatum_to_remove = tlorgan[toremove]
			var/obj/item/orgitem_to_remove = orgdatum_to_remove.organitem
			if (orgitem_to_remove)
				orgdatum_to_remove.remove(ORGAN_REMOVED, M.loc)
				do_teleport(orgitem_to_remove, get_turf(orgitem_to_remove.loc), 5, asoundin = 'sound/effects/phasein.ogg')
				M << "<span class = 'userdanger'>You feel like you just lost something REALLY important!</span>"
	..()
	return
	
/datum/reagent/bluespacejelly/blube
	name = "Bluespace Lube"
	id = "blube"
	description = "A rare, elite-grade lubricant employed in only the finest machining shops in the universe. Slips heat into chasms of time and space."
	color = "#00c3e6"
	lub_c = 4
	lub_l = 200
	cool_c = 4
	cool_l = 0.0025 //Wew.

/datum/reagent/bluespacejelly/blube/reaction_turf(turf/simulated/T, reac_volume)
	if (!istype(T)) return
	if(reac_volume >= 15) //You need access to the command/AI teleporter to get crystals for this much jelly at roundstart. It's like the hand tele, but more conspicuous yet transient.
		T.MakeSlippery(SLIPPERY_TURF_BLUBE) //Does fun things.