/datum/disease/advance/dwarfism
	form = "Condition"
	name = "Dwarfism"
	symptoms = list(new/datum/symptom/beard)
	max_stages = 5
	cure_text = "None viable; the surgery would be fatal."
	agent = "Engorged Liver"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 1
	desc = "The subject is a short, sturdy creature fond of drink and industry."
	severity = "Dwarves need alcohol to get through the working day."
	longevity = 1000000
	disease_flags = CAN_CARRY
	spread_flags = NON_CONTAGIOUS
	visibility_flags = HIDDEN_PANDEMIC