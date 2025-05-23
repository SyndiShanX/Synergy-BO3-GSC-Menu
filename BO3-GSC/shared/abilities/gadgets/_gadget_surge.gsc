// Decompiled by Serious. Credits to Scoba for his original tool, Cerberus, which I heavily upgraded to support remaining features, other games, and other platforms.
#using scripts\codescripts\struct;
#using scripts\shared\abilities\_ability_player;
#using scripts\shared\abilities\_ability_util;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#namespace _gadget_surge;

/*
	Name: __init__sytem__
	Namespace: _gadget_surge
	Checksum: 0x5054829D
	Offset: 0x1E8
	Size: 0x34
	Parameters: 0
	Flags: AutoExec
*/
function autoexec __init__sytem__() {
  system::register("gadget_surge", & __init__, undefined, undefined);
}

/*
	Name: __init__
	Namespace: _gadget_surge
	Checksum: 0x4E01D168
	Offset: 0x228
	Size: 0x104
	Parameters: 0
	Flags: Linked
*/
function __init__() {
  ability_player::register_gadget_activation_callbacks(21, & gadget_surge_on, & gadget_surge_off);
  ability_player::register_gadget_possession_callbacks(21, & gadget_surge_on_give, & gadget_surge_on_take);
  ability_player::register_gadget_flicker_callbacks(21, & gadget_surge_on_flicker);
  ability_player::register_gadget_is_inuse_callbacks(21, & gadget_surge_is_inuse);
  ability_player::register_gadget_is_flickering_callbacks(21, & gadget_surge_is_flickering);
  ability_player::register_gadget_primed_callbacks(21, & gadget_surge_is_primed);
  callback::on_connect( & gadget_surge_on_connect);
}

/*
	Name: gadget_surge_is_inuse
	Namespace: _gadget_surge
	Checksum: 0x479BA9B7
	Offset: 0x338
	Size: 0x2A
	Parameters: 1
	Flags: Linked
*/
function gadget_surge_is_inuse(slot) {
  return self flagsys::get("gadget_surge_on");
}

/*
	Name: gadget_surge_is_flickering
	Namespace: _gadget_surge
	Checksum: 0xA3440021
	Offset: 0x370
	Size: 0x50
	Parameters: 1
	Flags: Linked
*/
function gadget_surge_is_flickering(slot) {
  if(isdefined(level.cybercom) && isdefined(level.cybercom.surge)) {
    return self[[level.cybercom.surge._is_flickering]](slot);
  }
}

/*
	Name: gadget_surge_on_flicker
	Namespace: _gadget_surge
	Checksum: 0xA3F92999
	Offset: 0x3C8
	Size: 0x5C
	Parameters: 2
	Flags: Linked
*/
function gadget_surge_on_flicker(slot, weapon) {
  if(isdefined(level.cybercom) && isdefined(level.cybercom.surge)) {
    self[[level.cybercom.surge._on_flicker]](slot, weapon);
  }
}

/*
	Name: gadget_surge_on_give
	Namespace: _gadget_surge
	Checksum: 0xBD42D0E6
	Offset: 0x430
	Size: 0x5C
	Parameters: 2
	Flags: Linked
*/
function gadget_surge_on_give(slot, weapon) {
  if(isdefined(level.cybercom) && isdefined(level.cybercom.surge)) {
    self[[level.cybercom.surge._on_give]](slot, weapon);
  }
}

/*
	Name: gadget_surge_on_take
	Namespace: _gadget_surge
	Checksum: 0x7AAB1492
	Offset: 0x498
	Size: 0x5C
	Parameters: 2
	Flags: Linked
*/
function gadget_surge_on_take(slot, weapon) {
  if(isdefined(level.cybercom) && isdefined(level.cybercom.surge)) {
    self[[level.cybercom.surge._on_take]](slot, weapon);
  }
}

/*
	Name: gadget_surge_on_connect
	Namespace: _gadget_surge
	Checksum: 0xBE74F5E1
	Offset: 0x500
	Size: 0x44
	Parameters: 0
	Flags: Linked
*/
function gadget_surge_on_connect() {
  if(isdefined(level.cybercom) && isdefined(level.cybercom.surge)) {
    self[[level.cybercom.surge._on_connect]]();
  }
}

/*
	Name: gadget_surge_on
	Namespace: _gadget_surge
	Checksum: 0xD4D2A9EC
	Offset: 0x550
	Size: 0x7C
	Parameters: 2
	Flags: Linked
*/
function gadget_surge_on(slot, weapon) {
  self flagsys::set("gadget_surge_on");
  if(isdefined(level.cybercom) && isdefined(level.cybercom.surge)) {
    self[[level.cybercom.surge._on]](slot, weapon);
  }
}

/*
	Name: gadget_surge_off
	Namespace: _gadget_surge
	Checksum: 0xBA460725
	Offset: 0x5D8
	Size: 0x7C
	Parameters: 2
	Flags: Linked
*/
function gadget_surge_off(slot, weapon) {
  self flagsys::clear("gadget_surge_on");
  if(isdefined(level.cybercom) && isdefined(level.cybercom.surge)) {
    self[[level.cybercom.surge._off]](slot, weapon);
  }
}

/*
	Name: gadget_surge_is_primed
	Namespace: _gadget_surge
	Checksum: 0x53FE9C60
	Offset: 0x660
	Size: 0x5C
	Parameters: 2
	Flags: Linked
*/
function gadget_surge_is_primed(slot, weapon) {
  if(isdefined(level.cybercom) && isdefined(level.cybercom.surge)) {
    self[[level.cybercom.surge._is_primed]](slot, weapon);
  }
}