// Decompiled by Serious. Credits to Scoba for his original tool, Cerberus, which I heavily upgraded to support remaining features, other games, and other platforms.
#using scripts\codescripts\struct;
#using scripts\mp\_util;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\weapons\_lightninggun;

#namespace lightninggun;

/*
	Name: __init__sytem__
	Namespace: lightninggun
	Checksum: 0xD2BBBE8
	Offset: 0x168
	Size: 0x34
	Parameters: 0
	Flags: AutoExec
*/
function autoexec __init__sytem__() {
  system::register("lightninggun", & __init__, undefined, undefined);
}

/*
	Name: __init__
	Namespace: lightninggun
	Checksum: 0x1A2BADDB
	Offset: 0x1A8
	Size: 0x14
	Parameters: 0
	Flags: Linked
*/
function __init__() {
  init_shared();
}