//For cavity implants, obviously
/datum/organ/cavity
	name = "cavity"
	organitem_type = /obj/item

/datum/organ/internal
	var/vital = 0	//Whether this organ is vital. Kills you when removed

/datum/organ/internal/dismember(var/dism_type, var/special = 0)
	return remove(dism_type, owner.loc, special)

/datum/organ/internal/remove(var/dism_type, var/newloc, var/special = 0)
	var/obj/item/O = ..(dism_type, newloc, special)
	if(O)
		if(owner && vital && !special)
			owner.death()
	return O

/datum/organ/internal/brain
	name = "brain"
	vital = 1
	organitem_type = /obj/item/organ/internal/brain

/datum/organ/internal/heart
	name = "heart"
	vital = 1
	organitem_type = /obj/item/organ/internal/heart

/datum/organ/internal/appendix
	name = "appendix"
	organitem_type = /obj/item/organ/internal/appendix

/datum/organ/internal/liver
	name = "liver"
	organitem_type = /obj/item/organ/internal/liver

/datum/organ/internal/dwarf/liver
	name = "dwarf liver"
	vital = 1
	organitem_type = /obj/item/organ/internal/dwarf/liver

/datum/organ/internal/kidneys
	name = "kidneys"
	organitem_type = /obj/item/organ/internal/kidneys

/datum/organ/internal/lungs
	name = "lungs"
	organitem_type = /obj/item/organ/internal/lungs
	vital = 1

/datum/organ/internal/eyes
	name = "eyes"

/datum/organ/internal/cyberimp
	organitem_type = /obj/item/organ/internal/cyberimp

/datum/organ/internal/cyberimp/brain
	name = "cyberimp_brain"
	organitem_type = /obj/item/organ/internal/cyberimp/brain

/datum/organ/internal/cyberimp/chest
	name = "cyberimp_chest"
	organitem_type = /obj/item/organ/internal/cyberimp/chest