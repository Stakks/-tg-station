/**********************************************
	Adding new job uplink items is super easy
	All you have to do create a new object type
	like so: /datum/uplink_item/job/<job>
	then set the job variable for the new object type to <job>
	It must be exactly as listed in /code/game/jobs/jobs.dm
	Refer to /code/datums/uplink_item.dm for more information
	on implementing new uplink items
	The basics are the same
***********************************************/

/datum/uplink_item/job/
	category = "Job"
	var/job = ""