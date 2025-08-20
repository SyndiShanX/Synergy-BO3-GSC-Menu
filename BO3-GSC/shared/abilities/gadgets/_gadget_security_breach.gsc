/****************************************************************
 * Decompiled by Serious and Edited by SyndiShanX
 * Script: shared\abilities\gadgets\_gadget_security_breach.gsc
****************************************************************/

#using scripts\codescripts\struct;
#using scripts\shared\abilities\_ability_player;
#using scripts\shared\abilities\_ability_util;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#namespace _gadget_security_breach;

function autoexec __init__sytem__() {
  system::register("gadget_security_breach", & __init__, undefined, undefined);
}

function __init__() {
  ability_player::register_gadget_activation_callbacks(23, & gadget_security_breach_on, & gadget_security_breach_off);
  ability_player::register_gadget_possession_callbacks(23, & gadget_security_breach_on_give, & gadget_security_breach_on_take);
  ability_player::register_gadget_flicker_callbacks(23, & gadget_security_breach_on_flicker);
  ability_player::register_gadget_is_inuse_callbacks(23, & gadget_security_breach_is_inuse);
  ability_player::register_gadget_is_flickering_callbacks(23, & gadget_security_breach_is_flickering);
  ability_player::register_gadget_primed_callbacks(23, & gadget_security_breach_is_primed);
  callback::on_connect( & gadget_security_breach_on_connect);
}

function gadget_security_breach_is_inuse(slot) {
  return self flagsys::get("gadget_security_breach_on");
}

function gadget_security_breach_is_flickering(slot) {
  if(isdefined(level.cybercom) && isdefined(level.cybercom.security_breach)) {
    return self[[level.cybercom.security_breach._is_flickering]](slot);
  }
}

function gadget_security_breach_on_flicker(slot, weapon) {
  if(isdefined(level.cybercom) && isdefined(level.cybercom.security_breach)) {
    self[[level.cybercom.security_breach._on_flicker]](slot, weapon);
  }
}

function gadget_security_breach_on_give(slot, weapon) {
  if(isdefined(level.cybercom) && isdefined(level.cybercom.security_breach)) {
    return self[[level.cybercom.security_breach._on_give]](slot, weapon);
  }
}

function gadget_security_breach_on_take(slot, weapon) {
  if(isdefined(level.cybercom) && isdefined(level.cybercom.security_breach)) {
    return self[[level.cybercom.security_breach._on_take]](slot, weapon);
  }
}

function gadget_security_breach_on_connect() {
  if(isdefined(level.cybercom) && isdefined(level.cybercom.security_breach)) {
    return self[[level.cybercom.security_breach._on_connect]]();
  }
}

function gadget_security_breach_on(slot, weapon) {
  self flagsys::set("gadget_security_breach_on");
  if(isdefined(level.cybercom) && isdefined(level.cybercom.security_breach)) {
    return self[[level.cybercom.security_breach._on]](slot, weapon);
  }
}

function gadget_security_breach_off(slot, weapon) {
  self flagsys::clear("gadget_security_breach_on");
  if(isdefined(level.cybercom) && isdefined(level.cybercom.security_breach)) {
    return self[[level.cybercom.security_breach._off]](slot, weapon);
  }
}

function gadget_security_breach_is_primed(slot, weapon) {
  if(isdefined(level.cybercom) && isdefined(level.cybercom.security_breach)) {
    self[[level.cybercom.security_breach._is_primed]](slot, weapon);
  }
}