/*************************************************
 * Decompiled by Serious and Edited by SyndiShanX
 * Script: zm\zm_tomb_quest_fire.gsc
*************************************************/

#using scripts\codescripts\struct;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_utility;
#using scripts\zm\zm_tomb_chamber;
#using scripts\zm\zm_tomb_utility;
#using scripts\zm\zm_tomb_vo;
#using_animtree("generic");
#namespace zm_tomb_quest_fire;

function main() {
  level flag::init("fire_puzzle_1_complete");
  level flag::init("fire_puzzle_2_complete");
  level flag::init("fire_upgrade_available");
  callback::on_connect( & onplayerconnect);
  fire_puzzle_1_init();
  fire_puzzle_2_init();
  zm_tomb_vo::add_puzzle_completion_line(1, "vox_sam_fire_puz_solve_0");
  zm_tomb_vo::add_puzzle_completion_line(1, "vox_sam_fire_puz_solve_1");
  zm_tomb_vo::add_puzzle_completion_line(1, "vox_sam_fire_puz_solve_2");
  level thread zm_tomb_vo::watch_one_shot_line("puzzle", "try_puzzle", "vo_try_puzzle_fire1");
  level thread zm_tomb_vo::watch_one_shot_line("puzzle", "try_puzzle", "vo_try_puzzle_fire2");
  level thread fire_puzzle_1_run();
  level flag::wait_till("fire_puzzle_1_complete");
  playsoundatposition("zmb_squest_step1_finished", (0, 0, 0));
  level thread zm_tomb_utility::rumble_players_in_chamber(5, 3);
  level thread fire_puzzle_1_cleanup();
  level thread fire_puzzle_2_run();
  level flag::wait_till("fire_puzzle_2_complete");
  level thread fire_puzzle_2_cleanup();
  level flag::wait_till("staff_fire_upgrade_unlocked");
}

function onplayerconnect() {
  self thread fire_puzzle_watch_staff();
}

function fire_puzzle_1_init() {}

function fire_puzzle_1_run() {
  level.sacrifice_volumes = getentarray("fire_sacrifice_volume", "targetname");
  level.clone_list = [];
  level thread clone_cleanup_watch_player_presence();
  array::thread_all(level.sacrifice_volumes, & init_sacrifice_volume);
  b_any_volumes_unfinished = 1;
  while (b_any_volumes_unfinished) {
    level waittill("fire_sacrifice_completed");
    b_any_volumes_unfinished = 0;
    foreach(e_volume in level.sacrifice_volumes) {
      if(!e_volume.b_gods_pleased) {
        b_any_volumes_unfinished = 1;
      }
    }
  }
  iprintlnbold("");
  e_player = zm_utility::get_closest_player(level.sacrifice_volumes[0].origin);
  e_player thread zm_tomb_vo::say_puzzle_completion_line(1);
  level flag::set("fire_puzzle_1_complete");
}

function fire_puzzle_1_cleanup() {
  array::delete_all(level.sacrifice_volumes);
  level.sacrifice_volumes = [];
  array::delete_all(level.clone_list);
  level.clone_list = [];
}

function clone_cleanup_watch_player_presence() {
  level endon("fire_puzzle_1_complete");
  while (true) {
    wait(1);
    if(level.clone_list.size > 0) {
      if(!zm_tomb_chamber::is_chamber_occupied()) {
        array::delete_all(level.clone_list);
        level.clone_list = [];
      }
    }
  }
}

function init_sacrifice_volume() {
  self.b_gods_pleased = 0;
  self.num_sacrifices_received = 0;
  self.pct_sacrifices_received = 0;
  self.e_ignition_point = struct::get(self.target, "targetname");
  self.e_ignition_point thread run_sacrifice_ignition(self);
}

function run_sacrifice_plinth(e_volume) {
  while (true) {
    if(level flag::get("fire_puzzle_1_complete")) {
      break;
    } else if(isdefined(e_volume)) {
      if(e_volume.pct_sacrifices_received > self.script_float || e_volume.b_gods_pleased) {
        break;
      }
    }
    wait(0.5);
  }
  light_plinth();
}

function run_sacrifice_ignition(e_volume) {
  e_volume flag::init("flame_on");
  if(level flag::get("fire_puzzle_1_complete")) {
    return;
  }
  level endon("fire_puzzle_1_complete");
  a_torch_pos = struct::get_array(self.target, "targetname");
  array::thread_all(a_torch_pos, & run_sacrifice_plinth, e_volume);
  sndorigin = a_torch_pos[0].origin;
  if(!isdefined(self.angles)) {
    self.angles = (0, 0, 0);
  }
  max_hit_distance_sq = 10000;
  while (!e_volume.b_gods_pleased) {
    e_volume flag::clear("flame_on");
    level waittill("fire_staff_explosion", v_point, e_projectile);
    if(!zm_tomb_chamber::is_chamber_occupied()) {
      continue;
    }
    if(!e_projectile istouching(e_volume)) {
      continue;
    }
    self.e_fx = spawn("script_model", self.origin);
    self.e_fx.angles = vectorscale((-1, 0, 0), 90);
    self.e_fx setmodel("tag_origin");
    self.e_fx clientfield::set("barbecue_fx", 1);
    e_volume flag::set("flame_on");
    wait(6);
    self.e_fx delete();
  }
  level notify("fire_sacrifice_completed");
}

function light_plinth() {
  e_fx = spawn("script_model", self.origin);
  e_fx setmodel("tag_origin");
  str_exploder_name = "lgtexp_fire_charge_0" + self.script_int;
  exploder::exploder(str_exploder_name);
  e_fx.angles = vectorscale((-1, 0, 0), 90);
  e_fx playsound("zmb_squest_fire_torch_ignite");
  e_fx playloopsound("zmb_squest_fire_torch_loop", 0.6);
  level flag::wait_till("fire_puzzle_1_complete");
  wait(30);
  e_fx stoploopsound(0.1);
  e_fx playsound("zmb_squest_fire_torch_out");
  e_fx delete();
  exploder::kill_exploder(str_exploder_name);
}

function is_church_occupied() {
  return true;
}

function sacrifice_puzzle_zombie_killed(einflictor, attacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime) {
  if(!(isdefined(level.craftables_crafted["elemental_staff_fire"]) && level.craftables_crafted["elemental_staff_fire"]) && getdvarint("zombie_cheat") <= 0) {
    return;
  }
  if(isdefined(self.is_mechz) && self.is_mechz) {
    return;
  }
  if(!isdefined(level.sacrifice_volumes)) {
    return;
  }
  if(!zm_tomb_chamber::is_chamber_occupied()) {
    return;
  }
  foreach(e_volume in level.sacrifice_volumes) {
    if(e_volume.b_gods_pleased) {
      continue;
    }
    if(self istouching(e_volume)) {
      level notify("vo_try_puzzle_fire1", attacker);
      self thread fire_sacrifice_death_clone(e_volume);
      return;
    }
  }
}

function delete_oldest_clone() {
  if(level.clone_list.size == 0) {
    return;
  }
  clone = level.clone_list[0];
  arrayremoveindex(level.clone_list, 0, 0);
  clone delete();
}

function fire_sacrifice_death_clone(e_sacrifice_volume) {
  if(level.clone_list.size >= 15) {
    level delete_oldest_clone();
  }
  self ghost();
  clone = self spawn_zombie_clone();
  level.clone_list[level.clone_list.size] = clone;
  clone endon("death");
  if(isdefined(self.missinglegs) && self.missinglegs) {
    clone scene::play("cin_zmhd_zombie_death_crawl", clone);
  } else {
    clone scene::play("cin_zmhd_zombie_death", clone);
  }
  e_sacrifice_volume flag::wait_till("flame_on");
  w_staff_fire = level.a_elemental_staffs["staff_fire"].w_weapon;
  a_players = getplayers();
  foreach(e_player in a_players) {
    if(e_player hasweapon(w_staff_fire)) {
      level notify("vo_puzzle_good", e_player);
    }
  }
  playfx(level._effect["fire_ash_explosion"], clone.origin, anglestoforward(clone.angles), anglestoup(clone.angles));
  e_sacrifice_volume.num_sacrifices_received++;
  e_sacrifice_volume.pct_sacrifices_received = e_sacrifice_volume.num_sacrifices_received / 32;
  if(e_sacrifice_volume.num_sacrifices_received >= 32) {
    e_sacrifice_volume.b_gods_pleased = 1;
  }
  e_sacrifice_volume notify("sacrifice_received");
  arrayremovevalue(level.clone_list, clone);
  clone delete();
}

function spawn_zombie_clone() {
  clone = util::spawn_model(self.model, self.origin, self.angles);
  if(isdefined(self.headmodel)) {
    clone.headmodel = self.headmodel;
    clone attach(clone.headmodel, "", 1);
  }
  clone useanimtree($generic);
  return clone;
}

function fire_puzzle_2_init() {
  for (i = 1; i <= 4; i++) {
    a_ternary = getentarray("fire_torch_ternary_group_0" + i, "targetname");
    if(a_ternary.size > 1) {
      index_to_save = randomintrange(0, a_ternary.size);
      a_ternary[index_to_save] ghost();
      arrayremoveindex(a_ternary, index_to_save, 0);
      array::delete_all(a_ternary);
      continue;
    }
    a_ternary[0] ghost();
  }
  a_torches = struct::get_array("church_torch_target", "script_noteworthy");
  array::thread_all(a_torches, & fire_puzzle_torch_run);
}

function fire_puzzle_2_run() {
  a_ternary = getentarray("fire_torch_ternary", "script_noteworthy");
  assert(a_ternary.size == 4);
  foreach(e_number in a_ternary) {
    e_number show();
    e_target_torch = struct::get(e_number.target, "targetname");
    e_target_torch.b_correct_torch = 1;
    e_target_torch thread zm_tomb_utility::puzzle_debug_position();
  }
}

function fire_puzzle_2_cleanup() {
  a_torches = struct::get_array("church_torch_target", "script_noteworthy");
  foreach(s_torch in a_torches) {
    if(!isdefined(s_torch.e_fx)) {
      s_torch thread fire_puzzle_2_torch_flame();
      wait(0.25);
    }
  }
  wait(30);
  foreach(s_torch in a_torches) {
    if(isdefined(s_torch.e_fx)) {
      s_torch.e_fx delete();
      wait(0.25);
    }
  }
}

function fire_puzzle_2_is_complete() {
  a_torches = struct::get_array("church_torch_target", "script_noteworthy");
  wrong_torch = 0;
  unlit_torch = 0;
  foreach(e_torch in a_torches) {
    if(isdefined(e_torch.e_fx) && !e_torch.b_correct_torch) {
      wrong_torch = 1;
    }
    if(!isdefined(e_torch.e_fx) && e_torch.b_correct_torch) {
      unlit_torch = 1;
    }
  }
  if(!isdefined(level.n_torches_lit)) {
    level.n_torches_lit = 0;
  }
  if(!isdefined(level.n_wrong_torches)) {
    level.n_wrong_torches = 0;
  }
  level.n_torches_lit++;
  a_players = getplayers();
  foreach(e_player in a_players) {
    if(e_player hasweapon(level.a_elemental_staffs["staff_fire"].w_weapon)) {
      if((level.n_torches_lit % 12) == 0 && !level flag::get("fire_puzzle_2_complete")) {
        level notify("vo_puzzle_confused", e_player);
        continue;
      }
      if(wrong_torch && !level flag::get("fire_puzzle_2_complete")) {
        level.n_wrong_torches++;
        if((level.n_wrong_torches % 5) == 0) {
          level notify("vo_puzzle_bad", e_player);
        }
        continue;
      }
      if(unlit_torch) {
        level notify("vo_puzzle_good", e_player);
      }
    }
  }
  return !wrong_torch && !unlit_torch;
}

function fire_puzzle_watch_staff() {
  self endon("disconnect");
  while (true) {
    self waittill("projectile_impact", weapon, v_explode_point, n_radius, e_projectile, n_impact);
    if(weapon == level.a_elemental_staffs["staff_fire"].w_weapon) {
      level notify("fire_staff_explosion", v_explode_point, e_projectile);
    }
  }
}

function fire_puzzle_2_torch_flame() {
  if(isdefined(self.e_fx)) {
    self.e_fx delete();
  }
  self.e_fx = spawn("script_model", self.origin);
  self.e_fx.angles = vectorscale((-1, 0, 0), 90);
  self.e_fx setmodel("tag_origin");
  playfxontag(level._effect["fire_torch"], self.e_fx, "tag_origin");
  self.e_fx playsound("zmb_squest_fire_torch_ignite");
  self.e_fx playloopsound("zmb_squest_fire_torch_loop", 0.6);
  zm_tomb_utility::rumble_nearby_players(self.origin, 1500, 2);
  self.e_fx endon("death");
  if(fire_puzzle_2_is_complete() && !level flag::get("fire_puzzle_2_complete")) {
    self.e_fx thread zm_tomb_vo::say_puzzle_completion_line(1);
    level thread zm_tomb_utility::play_puzzle_stinger_on_all_players();
    level flag::set("fire_puzzle_2_complete");
  }
  wait(15);
  self.e_fx stoploopsound(0.1);
  self.e_fx playsound("zmb_squest_fire_torch_out");
  if(!level flag::get("fire_puzzle_2_complete")) {
    self.e_fx delete();
  }
}

function fire_puzzle_torch_run() {
  level endon("fire_puzzle_2_complete");
  self.b_correct_torch = 0;
  max_hit_distance_sq = 4096;
  w_staff_fire = level.a_elemental_staffs["staff_fire"].w_weapon;
  while (true) {
    level waittill("fire_staff_explosion", v_point);
    if(!is_church_occupied()) {
      continue;
    }
    dist_sq = distancesquared(v_point, self.origin);
    if(dist_sq > max_hit_distance_sq) {
      continue;
    }
    a_players = getplayers();
    foreach(e_player in a_players) {
      if(e_player hasweapon(w_staff_fire)) {
        level notify("vo_try_puzzle_fire2", e_player);
      }
    }
    self thread fire_puzzle_2_torch_flame();
    wait(2);
  }
}