// Decompiled by Serious. Credits to Scoba for his original tool, Cerberus, which I heavily upgraded to support remaining features, other games, and other platforms.
#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;

#namespace zm_bgb_wall_power;

/*
	Name: __init__sytem__
	Namespace: zm_bgb_wall_power
	Checksum: 0xCB3DE2E1
	Offset: 0x188
	Size: 0x34
	Parameters: 0
	Flags: AutoExec
*/
function autoexec __init__sytem__() {
  system::register("zm_bgb_wall_power", & __init__, undefined, "bgb");
}

/*
	Name: __init__
	Namespace: zm_bgb_wall_power
	Checksum: 0x740B41F8
	Offset: 0x1C8
	Size: 0x54
	Parameters: 0
	Flags: Linked
*/
function __init__() {
  if(!(isdefined(level.bgb_in_use) && level.bgb_in_use)) {
    return;
  }
  bgb::register("zm_bgb_wall_power", "event", & event, undefined, undefined, undefined);
}

/*
	Name: event
	Namespace: zm_bgb_wall_power
	Checksum: 0x2DB4A56C
	Offset: 0x228
	Size: 0x7C
	Parameters: 0
	Flags: Linked
*/
function event() {
  self endon(# "disconnect");
  self endon(# "bgb_update");
  self waittill(# "zm_bgb_wall_power_used");
  self playsoundtoplayer("zmb_bgb_wall_power", self);
  self zm_stats::increment_challenge_stat("GUM_GOBBLER_WALL_POWER");
  self bgb::do_one_shot_use();
}