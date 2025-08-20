/************************************************************
 * Decompiled by Serious and Edited by SyndiShanX
 * Script: cp\cybercom\_cybercom_tactical_rig_multicore.gsc
************************************************************/

#using scripts\codescripts\struct;
#using scripts\cp\cybercom\_cybercom;
#using scripts\cp\cybercom\_cybercom_dev;
#using scripts\cp\cybercom\_cybercom_tactical_rig;
#using scripts\cp\cybercom\_cybercom_util;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\math_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#namespace cybercom_tacrig_multicore;

function init() {}

function main() {
  callback::on_connect( & on_player_connect);
  callback::on_spawned( & on_player_spawned);
  cybercom_tacrig::register_cybercom_rig_ability("cybercom_multicore", 7);
  cybercom_tacrig::register_cybercom_rig_possession_callbacks("cybercom_multicore", & multicoregive, & multicoretake);
}

function on_player_connect() {}

function on_player_spawned() {}

function multicoregive(type) {
  self thread cybercom_tacrig::turn_rig_ability_on(type);
}

function multicoretake(type) {
  self thread cybercom_tacrig::turn_rig_ability_off(type);
}