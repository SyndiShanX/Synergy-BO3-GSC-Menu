// Decompiled by Serious. Credits to Scoba for his original tool, Cerberus, which I heavily upgraded to support remaining features, other games, and other platforms.
#using scripts\codescripts\struct;
#using scripts\shared\system_shared;
#using scripts\zm\_zm_powerups;

#namespace zm_powerup_full_ammo;

/*
	Name: __init__sytem__
	Namespace: zm_powerup_full_ammo
	Checksum: 0xF9F02082
	Offset: 0x108
	Size: 0x34
	Parameters: 0
	Flags: AutoExec
*/
function autoexec __init__sytem__() {
  system::register("zm_powerup_full_ammo", & __init__, undefined, undefined);
}

/*
	Name: __init__
	Namespace: zm_powerup_full_ammo
	Checksum: 0xB1F6D697
	Offset: 0x148
	Size: 0x6C
	Parameters: 0
	Flags: Linked
*/
function __init__() {
  zm_powerups::include_zombie_powerup("full_ammo");
  if(tolower(getdvarstring("g_gametype")) != "zcleansed") {
    zm_powerups::add_zombie_powerup("full_ammo");
  }
}