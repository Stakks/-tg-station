/obj/item/weapon/gun/projectile/automatic/pistol
	name = "syndicate pistol"
	desc = "A small, easily concealable 10mm handgun. Has a threaded barrel for suppressors."
	icon_state = "pistol"
	w_class = 2
	origin_tech = "combat=3;materials=3;syndicate=3"
	mag_type = /obj/item/ammo_box/magazine/m10mm
	can_suppress = 1
	burst_size = 1
	fire_delay = 0
	action_button_name = null

/obj/item/weapon/gun/projectile/automatic/pistol/update_icon()
	..()
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"][suppressed ? "-suppressed" : ""]"
	return

/obj/item/weapon/gun/projectile/automatic/pistol/m1911
	name = "M1911 pistol"
	desc = "A classic .45 handgun with a small magazine capacity."
	icon_state = "m1911"
	w_class = 3
	mag_type = /obj/item/ammo_box/magazine/m45
	can_suppress = 0

/obj/item/weapon/gun/projectile/automatic/pistol/deagle
	name = "desert eagle"
	desc = "A robust .50 AE handgun."
	icon_state = "deagle"
	force = 14
	mag_type = /obj/item/ammo_box/magazine/m50
	can_suppress = 0

/obj/item/weapon/gun/projectile/automatic/pistol/deagle/update_icon()
	..()
	icon_state = "[initial(icon_state)][magazine ? "" : "-e"]"

/obj/item/weapon/gun/projectile/automatic/pistol/deagle/gold
	desc = "A gold plated desert eagle folded over a million times by superior martian gunsmiths. Uses .50 AE ammo."
	icon_state = "deagleg"
	item_state = "deagleg"

/obj/item/weapon/gun/projectile/automatic/pistol/deagle/camo
	desc = "A Deagle brand Deagle for operators operating operationally. Uses .50 AE ammo."
	icon_state = "deaglecamo"
	item_state = "deagleg"

/obj/item/weapon/gun/projectile/automatic/pistol/glog
	name = "Glock 19"
	desc = "A dated, inexpensive model of 9mm pistol that remains popular amongst criminals for its reliability and high capacity magazine."
	icon_state = "glog"
	w_class = 2
	origin_tech = "combat=1;materials=1;syndicate=1"
	mag_type = /obj/item/ammo_box/magazine/m9mm
	can_suppress = 0
	burst_size = 1
	fire_delay = 0
	action_button_name = null

/obj/item/weapon/gun/projectile/automatic/pistol/glog/update_icon()
	..()
	icon_state = "[initial(icon_state)][magazine ? "-[magazine.max_ammo]" : ""][chambered ? "" : "-e"]"
	return

/obj/item/weapon/gun/projectile/automatic/pistol/macaroni
	name = "Makarov Pistol"
	desc = "A cheaply made Russian sidearm originally designed to replace the powerful but sometimes unreliable Tokarev as the standard issue for USSR conscripts."
	icon_state = "macaroni"
	w_class = 2
	origin_tech = "combat=2;materials=2;syndicate=2"
	mag_type = /obj/item/ammo_box/magazine/m9mmrus
	can_suppress = 0
	burst_size = 1
	fire_delay = 0
	action_button_name = null

/obj/item/weapon/gun/projectile/automatic/pistol/macaroni/update_icon()
	..()
	icon_state = "[initial(icon_state)][magazine ? "-[magazine.max_ammo]" : ""][chambered ? "" : "-e"]"
	return

obj/item/weapon/gun/projectile/automatic/mp40
	name = "Mp 40 Submachinegun"
	desc = "A cheaply-made and mass-produced German submachinegun chambered in 9x19mm Parabellum"
	icon_state = "mp40"
	w_class = 3
	origin_tech = "combat=3;materials=3;syndicate=3"
	mag_type = /obj/item/ammo_box/magazine/mp40
	burst_size = 3
	fire_delay = 0
	action_button_name = null

/obj/item/weapon/gun/projectile/automatic/pistol/mp40/update_icon()
	..()
	icon_state = "[initial(icon_state)][magazine ? "-[magazine.max_ammo]" : ""][chambered ? "" : "-e"]"
	return

obj/item/weapon/gun/projectile/automatic/skorpion
	name = "Skorpion vz. 61"
	desc = "A Czechoslovakian sidearm that has remained somewhat popular amongst DIRTY COMMIES. Most are chambered in .32 ACP, but this one is modified to use 9x18mm rounds instead."
	icon_state = "skorpion"
	w_class = 3
	origin_tech = "combat=3;materials=3;syndicate=3"
	mag_type = /obj/item/ammo_box/magazine/skorpion
	burst_size = 2
	fire_delay = 0
	action_button_name = null

/obj/item/weapon/gun/projectile/automatic/pistol/skorpion/update_icon()
	..()
	icon_state = "[initial(icon_state)][magazine ? "-[magazine.max_ammo]" : ""][chambered ? "" : "-e"]"
	return