// Decompiled by Serious. Credits to Scoba for his original tool, Cerberus, which I heavily upgraded to support remaining features, other games, and other platforms.
#using scripts\codescripts\struct;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_powerups;

#namespace zm_powerup_ww_grenade;

/*
	Name: __init__sytem__
	Namespace: zm_powerup_ww_grenade
	Checksum: 0x4531185B
	Offset: 0xF8
	Size: 0x34
	Parameters: 0
	Flags: AutoExec
*/
function autoexec __init__sytem__() {
  system::register("zm_powerup_ww_grenade", & __init__, undefined, undefined);
}

/*
	Name: __init__
	Namespace: zm_powerup_ww_grenade
	Checksum: 0x71205521
	Offset: 0x138
	Size: 0x34
	Parameters: 0
	Flags: Linked
*/
function __init__() {
  zm_powerups::include_zombie_powerup("ww_grenade");
  zm_powerups::add_zombie_powerup("ww_grenade");
}