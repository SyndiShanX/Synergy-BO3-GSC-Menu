/***************************************************************
 * Decompiled by Serious and Edited by SyndiShanX
 * Script: shared\abilities\gadgets\_gadget_servo_shortout.gsc
***************************************************************/

#using scripts\codescripts\struct;
#using scripts\shared\abilities\_ability_player;
#using scripts\shared\abilities\_ability_util;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#namespace _gadget_servo_shortout;

function autoexec __init__sytem__() {
  system::register("gadget_servo_shortout", & __init__, undefined, undefined);
}

function __init__() {
  ability_player::register_gadget_activation_callbacks(19, & gadget_servo_shortout_on, & gadget_servo_shortout_off);
  ability_player::register_gadget_possession_callbacks(19, & gadget_servo_shortout_on_give, & gadget_servo_shortout_on_take);
  ability_player::register_gadget_flicker_callbacks(19, & gadget_servo_shortout_on_flicker);
  ability_player::register_gadget_is_inuse_callbacks(19, & gadget_servo_shortout_is_inuse);
  ability_player::register_gadget_is_flickering_callbacks(19, & gadget_servo_shortout_is_flickering);
  ability_player::register_gadget_primed_callbacks(19, & gadget_servo_shortout_is_primed);
  callback::on_connect( & gadget_servo_shortout_on_connect);
}

function gadget_servo_shortout_is_inuse(slot) {
  return self flagsys::get("gadget_servo_shortout_on");
}

function gadget_servo_shortout_is_flickering(slot) {
  if(isdefined(level.cybercom) && isdefined(level.cybercom.servo_shortout)) {
    return self[[level.cybercom.servo_shortout._is_flickering]](slot);
  }
  return 0;
}

function gadget_servo_shortout_on_flicker(slot, weapon) {
  if(isdefined(level.cybercom) && isdefined(level.cybercom.servo_shortout)) {
    self[[level.cybercom.servo_shortout._on_flicker]](slot, weapon);
  }
}

function gadget_servo_shortout_on_give(slot, weapon) {
  if(isdefined(level.cybercom) && isdefined(level.cybercom.servo_shortout)) {
    self[[level.cybercom.servo_shortout._on_give]](slot, weapon);
  }
}

function gadget_servo_shortout_on_take(slot, weapon) {
  if(isdefined(level.cybercom) && isdefined(level.cybercom.servo_shortout)) {
    self[[level.cybercom.servo_shortout._on_take]](slot, weapon);
  }
}

function gadget_servo_shortout_on_connect() {
  if(isdefined(level.cybercom) && isdefined(level.cybercom.servo_shortout)) {
    self[[level.cybercom.servo_shortout._on_connect]]();
  }
}

function gadget_servo_shortout_on(slot, weapon) {
  self flagsys::set("gadget_servo_shortout_on");
  if(isdefined(level.cybercom) && isdefined(level.cybercom.servo_shortout)) {
    self[[level.cybercom.servo_shortout._on]](slot, weapon);
  }
}

function gadget_servo_shortout_off(slot, weapon) {
  self flagsys::clear("gadget_servo_shortout_on");
  if(isdefined(level.cybercom) && isdefined(level.cybercom.servo_shortout)) {
    self[[level.cybercom.servo_shortout._off]](slot, weapon);
  }
}

function gadget_servo_shortout_is_primed(slot, weapon) {
  if(isdefined(level.cybercom) && isdefined(level.cybercom.servo_shortout)) {
    self[[level.cybercom.servo_shortout._is_primed]](slot, weapon);
  }
}