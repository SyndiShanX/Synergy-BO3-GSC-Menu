// Decompiled by Serious. Credits to Scoba for his original tool, Cerberus, which I heavily upgraded to support remaining features, other games, and other platforms.
#using scripts\codescripts\struct;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_stats;

#namespace _zm_weap_ballistic_knife;

/*
	Name: init
	Namespace: _zm_weap_ballistic_knife
	Checksum: 0x9D4D6AEB
	Offset: 0x198
	Size: 0x1C
	Parameters: 0
	Flags: None
*/
function init() {
  if(!isdefined(level.ballistic_knife_autorecover)) {
    level.ballistic_knife_autorecover = 1;
  }
}

/*
	Name: on_spawn
	Namespace: _zm_weap_ballistic_knife
	Checksum: 0x2CBFACF8
	Offset: 0x1C0
	Size: 0x354
	Parameters: 2
	Flags: Linked
*/
function on_spawn(watcher, player) {
  player endon(# "death");
  player endon(# "disconnect");
  player endon(# "zmb_lost_knife");
  level endon(# "game_ended");
  self waittill(# "stationary", endpos, normal, angles, attacker, prey, bone);
  isfriendly = 0;
  if(isdefined(endpos)) {
    retrievable_model = spawn("script_model", endpos);
    retrievable_model setmodel("t6_wpn_ballistic_knife_projectile");
    retrievable_model setowner(player);
    retrievable_model.owner = player;
    retrievable_model.angles = angles;
    retrievable_model.weapon = watcher.weapon;
    if(isdefined(prey)) {
      if(isplayer(prey) && player.team == prey.team) {
        isfriendly = 1;
      } else if(isai(prey) && player.team == prey.team) {
        isfriendly = 1;
      }
      if(!isfriendly) {
        retrievable_model linkto(prey, bone);
        retrievable_model thread force_drop_knives_to_ground_on_death(player, prey);
      } else if(isfriendly) {
        retrievable_model physicslaunch(normal, (randomint(10), randomint(10), randomint(10)));
        normal = (0, 0, 1);
      }
    }
    watcher.objectarray[watcher.objectarray.size] = retrievable_model;
    if(isfriendly) {
      retrievable_model waittill(# "stationary");
    }
    retrievable_model thread drop_knives_to_ground(player);
    if(isfriendly) {
      player notify(# "ballistic_knife_stationary", retrievable_model, normal);
    } else {
      player notify(# "ballistic_knife_stationary", retrievable_model, normal, prey);
    }
    retrievable_model thread wait_to_show_glowing_model(prey);
  }
}

/*
	Name: wait_to_show_glowing_model
	Namespace: _zm_weap_ballistic_knife
	Checksum: 0xA37D9A67
	Offset: 0x520
	Size: 0x44
	Parameters: 1
	Flags: Linked
*/
function wait_to_show_glowing_model(prey) {
  level endon(# "game_ended");
  self endon(# "death");
  wait(2);
  self setmodel("t6_wpn_ballistic_knife_projectile");
}

/*
	Name: on_spawn_retrieve_trigger
	Namespace: _zm_weap_ballistic_knife
	Checksum: 0x449804A3
	Offset: 0x570
	Size: 0x454
	Parameters: 2
	Flags: Linked
*/
function on_spawn_retrieve_trigger(watcher, player) {
  player endon(# "death");
  player endon(# "disconnect");
  player endon(# "zmb_lost_knife");
  level endon(# "game_ended");
  player waittill(# "ballistic_knife_stationary", retrievable_model, normal, prey);
  if(!isdefined(retrievable_model)) {
    return;
  }
  trigger_pos = [];
  if(isdefined(prey) && (isplayer(prey) || isai(prey))) {
    trigger_pos[0] = prey.origin[0];
    trigger_pos[1] = prey.origin[1];
    trigger_pos[2] = prey.origin[2] + 10;
  } else {
    trigger_pos[0] = retrievable_model.origin[0] + (10 * normal[0]);
    trigger_pos[1] = retrievable_model.origin[1] + (10 * normal[1]);
    trigger_pos[2] = retrievable_model.origin[2] + (10 * normal[2]);
  }
  if(isdefined(level.ballistic_knife_autorecover) && level.ballistic_knife_autorecover) {
    trigger_pos[2] = trigger_pos[2] - 50;
    pickup_trigger = spawn("trigger_radius", (trigger_pos[0], trigger_pos[1], trigger_pos[2]), 0, 50, 100);
  } else {
    pickup_trigger = spawn("trigger_radius_use", (trigger_pos[0], trigger_pos[1], trigger_pos[2]));
    pickup_trigger setcursorhint("HINT_NOICON");
  }
  pickup_trigger.owner = player;
  retrievable_model.retrievabletrigger = pickup_trigger;
  hint_string = & "WEAPON_BALLISTIC_KNIFE_PICKUP";
  if(isdefined(hint_string)) {
    pickup_trigger sethintstring(hint_string);
  } else {
    pickup_trigger sethintstring( & "GENERIC_PICKUP");
  }
  pickup_trigger setteamfortrigger(player.team);
  player clientclaimtrigger(pickup_trigger);
  pickup_trigger enablelinkto();
  if(isdefined(prey)) {
    pickup_trigger linkto(prey);
  } else {
    pickup_trigger linkto(retrievable_model);
  }
  if(isdefined(level.knife_planted)) {
    [
      [level.knife_planted]
    ](retrievable_model, pickup_trigger, prey);
  }
  retrievable_model thread watch_use_trigger(pickup_trigger, retrievable_model, & pick_up, watcher.weapon, watcher.pickupsoundplayer, watcher.pickupsound);
  player thread watch_shutdown(pickup_trigger, retrievable_model);
}

/*
	Name: debug_print
	Namespace: _zm_weap_ballistic_knife
	Checksum: 0x14729F32
	Offset: 0x9D0
	Size: 0x48
	Parameters: 1
	Flags: None
*/
function debug_print(endpos) {
  /#
  self endon(# "death");
  while (true) {
    print3d(endpos, "");
    wait(0.05);
  }
  # /
}

/*
	Name: watch_use_trigger
	Namespace: _zm_weap_ballistic_knife
	Checksum: 0x8396DDDF
	Offset: 0xA20
	Size: 0x350
	Parameters: 6
	Flags: Linked
*/
function watch_use_trigger(trigger, model, callback, weapon, playersoundonuse, npcsoundonuse) {
  self endon(# "death");
  self endon(# "delete");
  level endon(# "game_ended");
  max_ammo = weapon.maxammo + 1;
  autorecover = isdefined(level.ballistic_knife_autorecover) && level.ballistic_knife_autorecover;
  while (true) {
    trigger waittill(# "trigger", player);
    if(!isalive(player)) {
      continue;
    }
    if(!player isonground() && (!(isdefined(trigger.force_pickup) && trigger.force_pickup))) {
      continue;
    }
    if(isdefined(trigger.triggerteam) && player.team != trigger.triggerteam) {
      continue;
    }
    if(isdefined(trigger.claimedby) && player != trigger.claimedby) {
      continue;
    }
    ammo_stock = player getweaponammostock(weapon);
    ammo_clip = player getweaponammoclip(weapon);
    current_weapon = player getcurrentweapon();
    total_ammo = ammo_stock + ammo_clip;
    hasreloaded = 1;
    if(total_ammo > 0 && ammo_stock == total_ammo && current_weapon == weapon) {
      hasreloaded = 0;
    }
    if(total_ammo >= max_ammo || !hasreloaded) {
      continue;
    }
    if(autorecover || (player usebuttonpressed() && !player.throwinggrenade && !player meleebuttonpressed()) || (isdefined(trigger.force_pickup) && trigger.force_pickup)) {
      if(isdefined(playersoundonuse)) {
        player playlocalsound(playersoundonuse);
      }
      if(isdefined(npcsoundonuse)) {
        player playsound(npcsoundonuse);
      }
      player thread[[callback]](weapon, model, trigger);
      break;
    }
  }
}

/*
	Name: pick_up
	Namespace: _zm_weap_ballistic_knife
	Checksum: 0x9D254968
	Offset: 0xD78
	Size: 0x1B4
	Parameters: 3
	Flags: Linked
*/
function pick_up(weapon, model, trigger) {
  if(self hasweapon(weapon)) {
    current_weapon = self getcurrentweapon();
    if(current_weapon != weapon) {
      clip_ammo = self getweaponammoclip(weapon);
      if(!clip_ammo) {
        self setweaponammoclip(weapon, 1);
      } else {
        new_ammo_stock = self getweaponammostock(weapon) + 1;
        self setweaponammostock(weapon, new_ammo_stock);
      }
    } else {
      new_ammo_stock = self getweaponammostock(weapon) + 1;
      self setweaponammostock(weapon, new_ammo_stock);
    }
  }
  self zm_stats::increment_client_stat("ballistic_knives_pickedup");
  self zm_stats::increment_player_stat("ballistic_knives_pickedup");
  model destroy_ent();
  trigger destroy_ent();
}

/*
	Name: destroy_ent
	Namespace: _zm_weap_ballistic_knife
	Checksum: 0xBF0DD262
	Offset: 0xF38
	Size: 0x4C
	Parameters: 0
	Flags: Linked
*/
function destroy_ent() {
  if(isdefined(self)) {
    if(isdefined(self.glowing_model)) {
      self.glowing_model delete();
    }
    self delete();
  }
}

/*
	Name: watch_shutdown
	Namespace: _zm_weap_ballistic_knife
	Checksum: 0x76ED68AB
	Offset: 0xF90
	Size: 0x74
	Parameters: 2
	Flags: Linked
*/
function watch_shutdown(trigger, model) {
  self util::waittill_any("death", "disconnect", "zmb_lost_knife");
  trigger destroy_ent();
  model destroy_ent();
}

/*
	Name: drop_knives_to_ground
	Namespace: _zm_weap_ballistic_knife
	Checksum: 0x6260A55A
	Offset: 0x1010
	Size: 0xB0
	Parameters: 1
	Flags: Linked
*/
function drop_knives_to_ground(player) {
  player endon(# "death");
  player endon(# "zmb_lost_knife");
  for (;;) {
    level waittill(# "drop_objects_to_ground", origin, radius);
    if(distancesquared(origin, self.origin) < (radius * radius)) {
      self physicslaunch((0, 0, 1), vectorscale((1, 1, 1), 5));
      self thread update_retrieve_trigger(player);
    }
  }
}

/*
	Name: force_drop_knives_to_ground_on_death
	Namespace: _zm_weap_ballistic_knife
	Checksum: 0xA9CCB7D4
	Offset: 0x10C8
	Size: 0x8C
	Parameters: 2
	Flags: Linked
*/
function force_drop_knives_to_ground_on_death(player, prey) {
  self endon(# "death");
  player endon(# "zmb_lost_knife");
  prey waittill(# "death");
  self unlink();
  self physicslaunch((0, 0, 1), vectorscale((1, 1, 1), 5));
  self thread update_retrieve_trigger(player);
}

/*
	Name: update_retrieve_trigger
	Namespace: _zm_weap_ballistic_knife
	Checksum: 0x54F633AB
	Offset: 0x1160
	Size: 0xBC
	Parameters: 1
	Flags: Linked
*/
function update_retrieve_trigger(player) {
  self endon(# "death");
  player endon(# "zmb_lost_knife");
  if(isdefined(level.custom_update_retrieve_trigger)) {
    self[[level.custom_update_retrieve_trigger]](player);
    return;
  }
  self waittill(# "stationary");
  trigger = self.retrievabletrigger;
  trigger.origin = (self.origin[0], self.origin[1], self.origin[2] + 10);
  trigger linkto(self);
}