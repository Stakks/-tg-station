//All code in this file and in others
//required to make this code work are
//probably from Fallout-13 unless it isn't
//figure it out for yourself
//The original source can be found at
//https://bitbucket.org/Jackerzz/fallout-13
//In addition hide.dmi is by them too (as far as I know)
// - The only guy that writes code for this codebase
// - Not danjen because he's a furry and doesn't actually do anything

/////////////VISION CONE///////////////
//Vision cone code by Matt and Honkertron. This vision cone code allows for mobs and/or items to blocked out from a players field of vision.
//This code makes use of the "cone of effect" proc created by Lummox, contributed by Jtgibson. More info on that here:
//http://www.byond.com/forum/?post=195138
///////////////////////////////////////

//"Made specially for Otuska"
// - Honker



//Defines.

#define OPPOSITE_DIR(D) turn(D, 180)

/mob
	var/obj/screen/fov = null//The screen object because I can't figure out how the hell TG does their screen objects so I'm just using legacy code.

client/
	var/list/hidden_atoms = list()
	var/list/hidden_mobs = list()



//Procs
//If an atom is in the cone then InCone returns 1
atom/proc/InCone(atom/center = usr, dir = NORTH)
	//Anything in the center is not in the cone
	if(get_dist(center, src) == 0 || src == center) return 0
	var/d = get_dir(center, src)
	//If get_dir returns nil or the object in the direction of
	//the cone then they must be in the cone
	//cone direction is |>dir not <|dir
	if(!d || d == dir) return 1
	//if the direction is a cardinal then
	//the atom is in the cone only if it's in the opposite direction
	if(dir & (dir-1))
		return (d & ~dir) ? 0 : 1
	if(!(d & dir)) return 0

	var/dx = abs(x - center.x)
	var/dy = abs(y - center.y)
	//45 degrees from the center which is in the cone
	if(dx == dy) return 1
	//basically if the atom is further on y than x then
	//it must be either north or south
	if(dy > dx)
		return (dir & (NORTH|SOUTH)) ? 1 : 0
	//if the atom is further on the x than y then
	// it must be either east or west
	return (dir & (EAST|WEST)) ? 1 : 0

mob/dead/InCone(mob/center = usr, dir = NORTH)//So ghosts aren't calculated.
	return

/*//TG doesn't have the grab item. But if you're porting it and you do then uncomment this.
mob/living/InCone(mob/center = usr, dir = NORTH)
	. = ..()
	for(var/obj/item/weapon/grab/G in center)
		if(src == G.affecting)
			return 0
		else
			return .
*/
proc/cone(atom/center = usr, dir = NORTH, list/list = oview(center))
	for(var/atom/A in list)
		if(!A.InCone(center, dir))
			list -= A
	return list

mob/proc/update_vision_cone()
	return

//Updating fov position on screen depends from client.pixel_x/y values
mob/proc/update_fov_position()

mob/living/update_fov_position()
	if(!client || !fov)
		return
	fov.screen_loc = "1:[-client.pixel_x],1:[-client.pixel_y]"

mob/living/update_vision_cone()
	if(src.client)
		var/image/I = null
		for(I in src.client.hidden_atoms)
			I.override = 0
			qdel(I)
		rest_cone_act()
		src.client.hidden_atoms = list()
		src.client.hidden_mobs = list()
		src.fov.dir = src.dir
		if(fov.alpha != 0)
			var/mob/living/M
			for(M in cone(src, OPPOSITE_DIR(src.dir), view(10, src)))
				I = image("split", M)
				I.override = 1
				src.client.images += I
				src.client.hidden_atoms += I
				src.client.hidden_mobs += M
				if(src.pulling == M)//If we're pulling them we don't want them to be invisible, too hard to play like that.
					I.override = 0

			//Optional items can be made invisible too. Uncomment this part if you wish to items to be invisible. Potentially cpu intensive.
			var/obj/item/O
			for(O in cone(src, OPPOSITE_DIR(src.dir), oview(src)))
				I = image("split", O)
				I.override = 1
				src.client.images += I
				src.client.hidden_atoms += I

	else
		return

mob/proc/rest_cone_act()//For showing and hiding the cone when you rest or lie down.
	if(resting || lying)
		hide_cone()
	else
		show_cone()

//Making these generic procs so you can call them anywhere.
mob/proc/show_cone()
	if(src.fov)
		src.fov.alpha = 255

mob/proc/hide_cone()
	if(src.fov)
		src.fov.alpha = 0





