// Decompiled by Serious. Credits to Scoba for his original tool, Cerberus, which I heavily upgraded to support remaining features, other games, and other platforms.
#using scripts\codescripts\struct;
#using scripts\shared\abilities\_ability_player;
#using scripts\shared\abilities\_ability_power;
#using scripts\shared\abilities\_ability_util;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\duplicaterender_mgr;
#using scripts\shared\filter_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;

#namespace _gadget_combat_efficiency;

/*
	Name: __init__sytem__
	Namespace: _gadget_combat_efficiency
	Checksum: 0x1FB0F39
	Offset: 0x248
	Size: 0x34
	Parameters: 0
	Flags: AutoExec
*/
function autoexec __init__sytem__() {
  system::register("gadget_combat_efficiency", & __init__, undefined, undefined);
}

/*
	Name: __init__
	Namespace: _gadget_combat_efficiency
	Checksum: 0x99EC1590
	Offset: 0x288
	Size: 0x4
	Parameters: 0
	Flags: Linked
*/
function __init__() {}