/*
	Author: Dan
	Date: August 19, 2017
	
	This is a large refactor which moves several non-harmful "damage" values into a status object so it
	removes cluttering from the main mob varlist. Eg, deafness, blurry vision, etc.

	// TODO: More intensity level integration eg blind -> radius of overlay
	// TODO: Split audio stuff to care between sounds and speech
	// TODO: Life.dm has handle_disabilities declared multiple times
*/

datum/health_status

	// Spatial
	var/spatial_confuse               = 0 // Occasionally mis-step into the wrong tile
	var/spatial_confuse_intensity     = 0
	//var/spatial_hallucinate           = 0
	//var/spatial_hallucinate_intensity = 0
	//var/spatial_brainloss             = 0
	//var/spatial_brainloss_intensity   = 0

	// Hearing
	var/aural_audio             = 0 // Prevents sounds from being played
	var/aural_audio_intensity   = 0
	var/aural_speech           = 0 // Prevents hearing speech
	var/aural_speech_intensity = 0

	// Speech
	var/verbal_mute              = 0 // Prevents speech
	var/verbal_mute_intensity    = 0
	var/verbal_stutter           = 0 // Adds stuttering to speech
	var/verbal_stutter_intensity = 0
	var/verbal_slur		         = 0 // Adds slurring to speech
	var/verbal_slur_intensity	 = 0

	// Vision
	var/vision_damage              = 0 // Overlay: checkerboard
	var/vision_damage_intensity    = 0
	var/vision_blindness           = 0 // Overlay: only see around you
	var/vision_blindness_intensity = 0 
	var/vision_blurry              = 0 // Overlay: cloudy
	var/vision_blurry_intensity    = 0
	var/vision_druggy              = 0 // Overlay: hue shifting
	var/vision_druggy_intensity    = 0

	// Others
	var/nausea_vomit           = 0 // Yes, you can be made to constantly throw up indefinitely
	var/nausea_vomit_intensity = 0