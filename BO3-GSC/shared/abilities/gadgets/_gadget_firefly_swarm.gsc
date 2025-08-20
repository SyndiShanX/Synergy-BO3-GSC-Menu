/**************************************************************
 * Decompiled by Serious and Edited by SyndiShanX
 * Script: shared\abilities\gadgets\_gadget_firefly_swarm.gsc
**************************************************************/

#using scripts\codescripts\struct;
#using scripts\shared\abilities\_ability_player;
#using scripts\shared\abilities\_ability_util;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#namespace _gadget_firefly_swarm;

function autoexec __init__sytem__() {
  system::register("gadget_firefly_swarm", & __init__, undefined, undefined);
}

function __init__() {
  ability_player::register_gadget_activation_callbacks(35, & gadget_firefly_swarm_on, & gadget_firefly_swarm_off);
  ability_player::register_gadget_possession_callbacks(35, & gadget_firefly_swarm_on_give, & gadget_firefly_swarm_on_take);
  ability_player::register_gadget_flicker_callbacks(35, & gadget_firefly_swarm_on_flicker);
  ability_player::register_gadget_is_inuse_callbacks(35, & gadget_firefly_swarm_is_inuse);
  ability_player::register_gadget_is_flickering_callbacks(35, & gadget_firefly_swarm_is_flickering);
  ability_player::register_gadget_primed_callbacks(35, & gadget_firefly_is_primed);
  callback::on_connect( & gadget_firefly_swarm_on_connect);
}

function gadget_firefly_swarm_is_inuse(slot) {
  return self flagsys::get("gadget_firefly_swarm_on");
}

function gadget_firefly_swarm_is_flickering(slot) {
  if(isdefined(level.cybercom) && isdefined(level.cybercom.firefly_swarm)) {
    return self[[level.cybercom.firefly_swarm._is_flickering]](slot);
  }
  return 0;
}

function gadget_firefly_swarm_on_flicker(slot, weapon) {
  if(isdefined(level.cybercom) && isdefined(level.cybercom.firefly_swarm)) {
    self[[level.cybercom.firefly_swarm._on_flicker]](slot, weapon);
  }
}

function gadget_firefly_swarm_on_give(slot, weapon) {
  if(isdefined(level.cybercom) && isdefined(level.cybercom.firefly_swarm)) {
    self[[level.cybercom.firefly_swarm._on_give]](slot, weapon);
  }
}

function gadget_firefly_swarm_on_take(slot, weapon) {
  if(isdefined(level.cybercom) && isdefined(level.cybercom.firefly_swarm)) {
    self[[level.cybercom.firefly_swarm._on_take]](slot, weapon);
  }
}

function gadget_firefly_swarm_on_connect() {
  if(isdefined(level.cybercom) && isdefined(level.cybercom.firefly_swarm)) {
    self[[level.cybercom.firefly_swarm._on_connect]]();
  }
}

function gadget_firefly_swarm_on(slot, weapon) {
  self flagsys::set("gadget_firefly_swarm_on");
  if(isdefined(level.cybercom) && isdefined(level.cybercom.firefly_swarm)) {
    self[[level.cybercom.firefly_swarm._on]](slot, weapon);
  }
}

function gadget_firefly_swarm_off(slot, weapon) {
  self flagsys::clear("gadget_firefly_swarm_on");
  if(isdefined(level.cybercom) && isdefined(level.cybercom.firefly_swarm)) {
    self[[level.cybercom.firefly_swarm._off]](slot, weapon);
  }
}

function gadget_firefly_is_primed(slot, weapon) {
  if(isdefined(level.cybercom) && isdefined(level.cybercom.firefly_swarm)) {
    self[[level.cybercom.firefly_swarm._is_primed]](slot, weapon);
  }
}