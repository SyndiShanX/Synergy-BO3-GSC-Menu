// Decompiled by Serious. Credits to Scoba for his original tool, Cerberus, which I heavily upgraded to support remaining features, other games, and other platforms.
#using scripts\codescripts\struct;
#using scripts\shared\system_shared;

#namespace sticky_grenade;

/*
	Name: __init__sytem__
	Namespace: sticky_grenade
	Checksum: 0xD3401C50
	Offset: 0xD0
	Size: 0x34
	Parameters: 0
	Flags: AutoExec
*/
function autoexec __init__sytem__() {
  system::register("sticky_grenade", & __init__, undefined, undefined);
}

/*
	Name: __init__
	Namespace: sticky_grenade
	Checksum: 0x99EC1590
	Offset: 0x110
	Size: 0x4
	Parameters: 0
	Flags: Linked
*/
function __init__() {}

/*
	Name: watch_bolt_detonation
	Namespace: sticky_grenade
	Checksum: 0xD3136D03
	Offset: 0x120
	Size: 0xC
	Parameters: 1
	Flags: None
*/
function watch_bolt_detonation(owner) {}