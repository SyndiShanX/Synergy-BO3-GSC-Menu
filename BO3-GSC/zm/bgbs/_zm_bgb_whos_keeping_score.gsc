/*************************************************
 * Decompiled by Serious and Edited by SyndiShanX
 * Script: zm\bgbs\_zm_bgb_whos_keeping_score.gsc
*************************************************/

#using scripts\codescripts\struct;
#using scripts\shared\flag_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#namespace zm_bgb_whos_keeping_score;

function autoexec __init__sytem__() {
  system::register("zm_bgb_whos_keeping_score", & __init__, undefined, "bgb");
}

function __init__() {
  if(!(isdefined(level.bgb_in_use) && level.bgb_in_use)) {
    return;
  }
  bgb::register("zm_bgb_whos_keeping_score", "activated", 2, undefined, undefined, undefined, & activation);
}

function activation() {
  self thread bgb::function_dea74fb0("double_points");
}