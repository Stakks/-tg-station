#define SOLID 1
#define LIQUID 2
#define GAS 3

/obj/machinery/chem_heater
	name = "chemical heater"
	density = 1
	anchored = 1
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mixer0b"
	use_power = 1
	idle_power_usage = 40
	var/obj/item/weapon/reagent_containers/beaker = null
	var/desired_temp = 300
	var/heater_coefficient = 0.10
	var/on = FALSE

/obj/machinery/chem_heater/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/chem_heater(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	RefreshParts()

/obj/machinery/chem_heater/RefreshParts()
	heater_coefficient = 0.10
	for(var/obj/item/weapon/stock_parts/micro_laser/M in component_parts)
		heater_coefficient *= M.rating

/obj/machinery/chem_heater/process()
	..()
	if(stat & NOPOWER)
		return
	var/state_change = 0
	if(on)
		if(beaker)
			if(beaker.reagents.chem_temp > desired_temp)
				beaker.reagents.chem_temp += min(-1, (desired_temp - beaker.reagents.chem_temp) * heater_coefficient)
			if(beaker.reagents.chem_temp < desired_temp)
				beaker.reagents.chem_temp += max(1, (desired_temp - beaker.reagents.chem_temp) * heater_coefficient)
			beaker.reagents.chem_temp = round(beaker.reagents.chem_temp) //stops stuff like 456.12312312302

			beaker.reagents.handle_reactions()
			state_change = 1

	if(state_change)
		SSnano.update_uis(src)

/obj/machinery/chem_heater/proc/eject_beaker()
	if(beaker)
		beaker.loc = get_turf(src)
		beaker.reagents.handle_reactions()
		beaker = null
		icon_state = "mixer0b"
		SSnano.update_uis(src)

/obj/machinery/chem_heater/power_change()
	if(powered())
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			stat |= NOPOWER
	SSnano.update_uis(src)

/obj/machinery/chem_heater/attackby(var/obj/item/I as obj, var/mob/user as mob, params)
	if(isrobot(user) && !ismommi(user))
		return

	if(istype(I, /obj/item/weapon/reagent_containers/glass))
		if(beaker)
			user << "<span class='notice'>A beaker is already loaded into the machine.</span>"
			return

		if(user.drop_item())
			beaker = I
			I.loc = src
			user << "<span class='notice'>You add the beaker to the machine!</span>"
			icon_state = "mixer1b"
			SSnano.update_uis(src)

	if(default_deconstruction_screwdriver(user, "mixer0b", "mixer0b", I))
		return

	if(exchange_parts(user, I))
		return

	if(panel_open)
		if(istype(I, /obj/item/weapon/crowbar))
			eject_beaker()
			default_deconstruction_crowbar(I)
			return 1

/obj/machinery/chem_heater/attack_hand(var/mob/user as mob)
	ui_interact(user)

/obj/machinery/chem_heater/Topic(href, href_list)
	if(..())
		return 0

	if(href_list["toggle_on"])
		on = !on
		. = 1

	if(href_list["adjust_temperature"])
		var/val = href_list["adjust_temperature"]
		if(isnum(val))
			desired_temp = Clamp(desired_temp+val, 0, 1000)
		else if(val == "input")
			var/temp = input("Please input the target temperature", name) as num
			desired_temp = Clamp(temp, 0, 1000)
		else
			return 0
		. = 1

	if(href_list["eject_beaker"])
		eject_beaker()
		. = 0 //updated in eject_beaker() already

/obj/machinery/chem_heater/ui_interact(var/mob/user, ui_key = "main", var/datum/nanoui/ui = null)
	if(user.stat || user.restrained()) return

	ui = SSnano.push_open_or_new_ui(user, src, ui_key, ui, "chem_heater.tmpl", "ChemHeater", 350, 270, 0)

/obj/machinery/chem_heater/get_ui_data()
	var/data = list()
	data["targetTemp"] = desired_temp
	data["isActive"] = on
	data["isBeakerLoaded"] = beaker ? 1 : 0

	data["currentTemp"] = beaker ? beaker.reagents.chem_temp : null
	data["beakerCurrentVolume"] = beaker ? beaker.reagents.total_volume : null
	data["beakerMaxVolume"] = beaker ? beaker.volume : null

	//copy-pasted from chem dispenser
	var beakerContents[0]
	if(beaker)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			beakerContents.Add(list(list("name" = R.name, "volume" = R.volume))) // list in a list because Byond merges the first list...
	data["beakerContents"] = beakerContents

	return data