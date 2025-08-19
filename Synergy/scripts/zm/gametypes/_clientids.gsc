#using scripts\codescripts\struct;
#using scripts\shared\aat_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientField_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_blockers;
#using scripts\zm\_zm_hero_weapon;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;

#insert scripts\shared\shared.gsh;

#namespace clientids;

REGISTER_SYSTEM("clientids", &__init__, undefined)

function __init__() {
	callback::on_start_gametype(&init);
}

function init() {
	setDvar("sv_cheats", "1");

	level thread player_connect();
	level thread create_rainbow_color();

	level thread session_expired();
}

function initial_variable() {
	self.menu = [];
	self.cursor = [];
	self.slider = [];
	self.previous = [];

	self.font = "default";
	self.font_scale = 1;
	self.option_limit = 10;
	self.option_spacing = 16;
	self.x_offset = 175;
	self.y_offset = 160;
	self.width = -20;
	self.interaction_enabled = true;
	self.description_enabled = true;
	self.randomizing_enabled = true;
	self.scrolling_buffer = 3;

	self set_menu();
	self set_title();

	self.menu_color_red = 255;
	self.menu_color_green = 255;
	self.menu_color_blue = 255;
	self.color_theme = "rainbow";
	self.point_increment = 100;
	level.doors_done = false;

	self.syn["visions"][0] = array("", "zm_bgb_idle_eyes", "zm_bgb_eye_candy_vs_1", "zm_bgb_eye_candy_vs_2", "zm_bgb_eye_candy_vs_3", "zm_bgb_eye_candy_vs_4", "zm_bgb_now_you_see_me", "zm_bgb_in_plain_sight", "drown_blur", "zm_health_blur");
	self.syn["visions"][1] = array("None", "Idle Eyes", "Eye Candy 1", "Eye Candy 2", "Eye Candy 3", "Eye Candy 4", "Now You See Me", "In Plain Sight", "Drown Blur", "Health Blur");

	self.syn["visions"]["soe"][0] = array("zm_idgun_vortex_visionset", "zm_idgun_vortex_blur", "zod_ritual_dim", "zombie_beast_2", "zombie_noire", "zm_zod_transported");
	self.syn["visions"]["soe"][1] = array("Apothicon Servant Vortex", "Apothicon Servant Vortex Blur", "Low Visibility", "Beast Mode", "Noire", "WIP Teleport");

	self.syn["visions"]["de"][0] = array("zm_factory_teleport", "zm_trap_electric");
	self.syn["visions"]["de"][1] = array("Teleport", "Electric Trap");

	self.syn["visions"]["zns"][0] = array("zm_isl_thrasher_stomach_visionset");
	self.syn["visions"]["zns"][1] = array("Thrasher Stomach");

	self.syn["visions"]["gk"][0] = array("raygun_mark3_vortex_visionset", "raygun_mark3_vortex_blur", "zm_trap_electric");
	self.syn["visions"]["gk"][1] = array("Ray Gun Mark 3 Vortex", "Ray Gun Mark 3 Vortex Blur", "Electric Trap");

	self.syn["visions"]["rev"][0] = array("zm_factory_teleport", "zm_trap_electric", "zm_idgun_vortex_visionset", "zm_idgun_vortex_blur", "zm_chaos_organge");
	self.syn["visions"]["rev"][1] = array("Teleport", "Electric Trap", "Apothicon Servant Vortex", "Apothicon Servant Vortex Blur", "Chaos Orange");

	self.syn["visions"]["nza"][0] = array("zm_trap_electric", "zm_waterfall_postfx", "zm_showerhead_postfx", "zm_showerhead");
	self.syn["visions"]["nza"][1] = array("Electric Trap", "Waterfall", "Shower","Bloody Shower");

	self.syn["visions"]["nzs"][0] = array("zm_trap_electric");
	self.syn["visions"]["nzs"][1] = array("Electric Trap");

	self.syn["visions"]["kino"][0] = array("zm_trap_electric", "zm_ai_quad_blur");
	self.syn["visions"]["kino"][1] = array("Electric Trap", "Blur");

	self.syn["visions"]["ascen"][0] = array("zm_cosmodrome_no_power", "zm_cosmodrome_power_antic", "zm_cosmodrome_power_flare", "zm_cosmodrome_monkey_on", "zm_idgun_vortex_blur");
	self.syn["visions"]["ascen"][1] = array("No Power", "Dim", "Bright", "Monkey Round", "Vortex Blur");

	self.syn["visions"]["shang"][0] = array("zm_ai_screecher_blur", "zm_temple_eclipse", "zm_waterfall_postfx");
	self.syn["visions"]["shang"][1] = array("Screecher Blur", "Eclipse", "Waterfall");

	self.syn["visions"]["moon"][0] = array("zm_gasmask_postfx", "zm_ai_quad_blur", "zm_idgun_vortex_blur");
	self.syn["visions"]["moon"][1] = array("Gas Mask", "Blur", "Vortex Blur");

	self.syn["visions"]["origins"][0] = array("zm_tomb_in_plain_sight", "zm_factory_teleport");
	self.syn["visions"]["origins"][1] = array("Zombie Blood", "Teleport");

	self.syn["weapons"]["category"] = array("Assault Rifles", "Sub Machine Guns", "Sniper Rifles", "Shotguns", "Light Machine Guns", "Pistols", "Launchers", "Extras");

	self.syn["weapons"]["extras"][0] = array("knife", "knife_widows_wine", "bowie_knife", "bowie_knife_widows_wine", "frag_grenade", "sticky_grenade_widows_wine", "bouncingbetty", "ray_gun", "minigun", "defaultweapon");
	self.syn["weapons"]["extras"][1] = array("Knife", "Widow's Wine Knife", "Bowie Knife", "Bowie Knife Widow's Wine", "Frag Grenade", "Widow's Wine Grenade", "Trip Mines", "Ray Gun", "Death Machine", "Default Weapon");

	self.syn["weapons"]["extras"]["soe"][0] = array("ar_standard_upgraded_companion", "smg_longrange", "pistol_standard", "octobomb", "octobomb_upgraded", "bouncingbetty_devil", "bouncingbetty_holly", "zod_riotshield", "zod_riotshield_upgraded", "glaive_apothicon_0", "glaive_keeper_0", "idgun_0", "idgun_1", "idgun_2", "idgun_3", "hero_gravityspikes");
	self.syn["weapons"]["extras"]["soe"][1] = array("Civil Protector KN-44", "Razorback", "MR6", "Lil' Arnies", "Upgraded Lil' Arnies", "Donut Trip Mines", "Cream Cake Trip Mines", "Rocket Shield", "Upgraded Rocket Shield", "Sword", "Upgraded Sword", "Kor-Maroth", "Mar-Astagua", "Nar-Ullaqua", "Lor-Zarozzor", "Gravity Spikes");

	self.syn["weapons"]["extras"]["nzf"][0] = array("smg_longrange", "lmg_rpk", "cymbal_monkey", "hero_annihilator", "tesla_gun", "hero_gravityspikes");
	self.syn["weapons"]["extras"]["nzf"][1] = array("Razorback", "RPK", "Monkey Bombs", "Annihilator", "Wunderwaffe DG-2", "Gravity Spikes");

	self.syn["weapons"]["extras"]["de"][0] = array("smg_longrange", "lmg_rpk", "cymbal_monkey", "castle_riotshield", "hero_gravityspikes_melee", "elemental_bow", "elemental_bow_storm", "elemental_bow_wolf_howl", "elemental_bow_rune_prison", "elemental_bow_demongate", "hero_gravityspikes");
	self.syn["weapons"]["extras"]["de"][1] = array("Razorback", "RPK", "Monkey Bombs", "Rocket Shield", "Ragnarok DG-4", "Wrath of the Ancients", "Storm Bow", "Wolf Bow", "Fire Bow", "Void Bow", "Gravity Spikes");

	self.syn["weapons"]["extras"]["zns"][0] = array("cymbal_monkey", "island_riotshield", "skull_gun", "hero_mirg2000", "hero_mirg2000_upgraded", "hero_gravityspikes");
	self.syn["weapons"]["extras"]["zns"][1] = array("Monkey Bombs", "Rocket Shield", "Skull of Nan Sapwe", "KT-4", "Masamune", "Gravity Spikes");

	self.syn["weapons"]["extras"]["gk"][0] = array("ar_famas", "lmg_rpk", "launcher_multi", "melee_wrench", "melee_dagger", "melee_fireaxe", "melee_sword", "special_crossbow_dw", "cymbal_monkey", "cymbal_monkey_upgraded", "dragonshield", "dragonshield_upgraded", "dragon_gauntlet_flamethrower", "launcher_dragon_strike", "raygun_mark3");
	self.syn["weapons"]["extras"]["gk"][1] = array("FFAR", "RPK", "L4 Siege", "Wrench", "Malice", "Slash N' Burn", "Fury's Song", "NX Shadowclaw", "Monkey Bombs", "Upgraded Monkey Bombs", "Guard of Fafnir", "Upgraded Guard of Fafnir", "Gauntlet of Siegfried", "Dragon Strike", "Ray Gun Mark 3");

	self.syn["weapons"]["extras"]["rev"][0] = array("ar_peacekeeper", "smg_thompson", "shotgun_energy", "pistol_energy", "melee_nunchuks", "melee_mace", "melee_improvise", "melee_boneglass", "melee_katana", "octobomb", "octobomb_upgraded", "dragonshield", "dragonshield_upgraded", "hero_gravityspikes_melee", "idgun_genesis_0", "thundergun", "hero_gravityspikes");
	self.syn["weapons"]["extras"]["rev"][1] = array("Peacekeeper MK2", "M1927", "Banshii", "Rift E9", "Nunchuks", "Skull Splitter", "Buzz Cut", "Nightbreaker", "Path of Sorrows", "Lil' Arnies", "Upgraded Lil' Arnies", "Guard of Fafnir", "Upgraded Guard of Fafnir", "Ragnarok DG-4", "Estulla Astoth", "Thundergun", "Gravity Spikes");

	self.syn["weapons"]["extras"]["nzp"][0] = array("ar_stg44", "smg_mp40_1940", "cymbal_monkey", "raygun_mark2");
	self.syn["weapons"]["extras"]["nzp"][1] = array("STG-44", "MP40", "Monkey Bombs", "Ray Gun Mark II");

	self.syn["weapons"]["extras"]["nza"][0] = array("ar_stg44", "smg_mp40_1940", "cymbal_monkey", "raygun_mark2");
	self.syn["weapons"]["extras"]["nza"][1] = array("STG-44", "MP40", "Monkey Bombs", "Ray Gun Mark II");

	self.syn["weapons"]["extras"]["nzs"][0] = array("ar_stg44", "smg_mp40_1940", "cymbal_monkey", "raygun_mark2");
	self.syn["weapons"]["extras"]["nzs"][1] = array("STG-44", "MP40", "Monkey Bombs", "Ray Gun Mark II");

	self.syn["weapons"]["extras"]["kino"][0] = array("ar_m14", "ar_m16", "ar_galil", "smg_mp40_1940", "cymbal_monkey", "raygun_mark2");
	self.syn["weapons"]["extras"]["kino"][1] = array("M14", "M16", "Galil", "MP40", "Monkey Bombs", "Ray Gun Mark II");

	self.syn["weapons"]["extras"]["ascen"][0] = array("ar_m14", "ar_m16", "ar_galil", "sickle_knife", "nesting_dolls", "black_hole_bomb", "raygun_mark2");
	self.syn["weapons"]["extras"]["ascen"][1] = array("M14", "M16", "Galil", "Sickle", "Matryoshka Doll", "Gersh Device", "Ray Gun Mark II");

	self.syn["weapons"]["extras"]["shang"][0] = array("ar_m14", "ar_m16", "ar_galil", "cymbal_monkey", "raygun_mark2", "shrink_ray");
	self.syn["weapons"]["extras"]["shang"][1] = array("M14", "M16", "Galil", "Monkey Bombs", "Ray Gun Mark II", "31-79 JGb215");

	self.syn["weapons"]["extras"]["moon"][0] = array("ar_m14", "ar_m16", "ar_galil", "black_hole_bomb", "quantum_bomb", "raygun_mark2", "microwavegundw");
	self.syn["weapons"]["extras"]["moon"][1] = array("M14", "M16", "Galil", "Gersh Device", "Quantum Entaglement Device", "Ray Gun Mark II", "Zap Gun Dual Wield");

	self.syn["weapons"]["extras"]["origins"][0] = array("ar_m14", "ar_stg44", "smg_mp40_1940", "lmg_mg08", "pistol_c96", "cymbal_monkey", "beacon", "tomb_shield", "raygun_mark2", "staff_water", "staff_lightning", "staff_fire", "staff_air");
	self.syn["weapons"]["extras"]["origins"][1] = array("M14", "STG-44", "MP40", "MG-08/15", "Mauser C96", "Monkey Bombs", "G-Strike", "Zombie Shield", "Ray Gun Mark II", "Ice Staff", "Lightning Staff", "Wind Staff", "Fire Staff");

	self.syn["weapons"]["aats"][0] = array("zm_aat_blast_furnace", "zm_aat_dead_wire", "zm_aat_fire_works", "zm_aat_thunder_wall", "zm_aat_turned");
	self.syn["weapons"]["aats"][1] = array("Blast Furnace", "Dead Wire", "Fireworks", "Thunder Wall", "Turned");

	self.syn["perks"]["common"][0] = array("specialty_quickrevive", "specialty_armorvest", "specialty_doubletap2", "specialty_staminup", "specialty_fastreload", "specialty_additionalprimaryweapon", "specialty_deadshot", "specialty_widowswine", "specialty_electriccherry", "specialty_phdflopper", "specialty_whoswho");
	self.syn["perks"]["common"][1] = array("Quick Revive", "Juggernog", "Double Tap", "Stamin-Up", "Speed Cola", "Mule Kick", "Deadshot", "Widow's Wine", "Electric Cherry", "PhD Slider", "Who's Who");
	self.syn["perks"]["all"] = getArrayKeys(level._custom_perks);

	forEach(type, v_array in level.vsmgr) {
		forEach(v_name, v_struct in level.vsmgr[type].info) {
			vision = level.vsmgr[type].info[v_name];
			if(vision.state.should_activate_per_player) {
				displayName = construct_string(replace_character(vision.name, "_", " "));
				if(isSubStr(displayName, "Zm")) {
					displayName = getSubStr(displayName, 3);
				}
				if(isSubStr(displayName, "Bgb")) {
					displayName = getSubStr(displayName, 4);
				}
				vision.displayName = displayName;
				forEach(existingVision in self.syn["visions"]) {
					if(vision.name == existingVision.name) {
						self.isInArray = true;
					}
				}
				if(!isDefined(self.isInArray)) {
					array::add(self.syn["visions"], vision, 0);
				}
				self.isInArray = undefined;
			}
		}
	}

	self.syn["powerups"][0] = getArrayKeys(level.zombie_include_powerups);
  self.syn["powerups"][1] = [];
  for (i = 0; i < self.syn["powerups"][0].size; i++) {
    self.syn["powerups"][1][i] = construct_string(replace_character(self.syn["powerups"][0][i], "_", " "));
		if(self.syn["powerups"][1][i] == "Ww Grenade") {
			self.syn["powerups"][1][i] = "Widow's Wine Grenade";
		}
	}

	self.syn["gobblegum"][0] = getArrayKeys(level.bgb);
	self.syn["gobblegum"][1] = [];
	for(i = 0; i < self.syn["gobblegum"][0].size; i++) {
		self.syn["gobblegum"][1][i] = construct_string(replace_character(getSubStr(self.syn["gobblegum"][0][i], 7), "_", " "));
	}

	weapon_types = array("assault", "smg", "cqb", "lmg", "sniper", "pistol", "launcher");

	weapon_names = [];
	forEach(weapon in getArrayKeys(level.zombie_weapons)) {
		weapon_names[weapon_names.size] = weapon.name;
	}

	for(i = 0; i < weapon_types.size; i++) {
		self.syn["weapons"][i] = [];
		for(e = 1; e < 100; e++) {
			weapon_category = tableLookup("gamedata/stats/zm/zm_statstable.csv", 0, e, 2);
			weapon_id = tableLookup("gamedata/stats/zm/zm_statstable.csv", 0, e, 4);

			if(weapon_category == "weapon_" + weapon_types[i]) {
				if(isInArray(weapon_names, weapon_id)) {
					weapon = spawnStruct();
					weapon.name = makeLocalizedString(getWeapon(weapon_id).displayName);
					if(weapon_id == "pistol_m1911") {
						weapon.name = "M1911";
					}
					weapon.id = weapon_id;
					weapon.category = weapon_category;
					self.syn["weapons"][i][self.syn["weapons"][i].size] = weapon;
				}
			}
		}
	}

	self.syn["weapons"][7] = [];
	forEach(weapon in getArrayKeys(level.zombie_weapons)) {
		isInArray = false;
		for(e = 0; e < self.syn["weapons"].size; e++) {
			for(i = 0; i < self.syn["weapons"][e].size; i++) {
				if(isDefined(self.syn["weapons"][e][i]) && self.syn["weapons"][e][i].id == weapon.name) {
					isInArray = true;
					break;
				}
			}
		}
		if(!isInArray && weapon.displayName != "") {
			weapons = spawnStruct();
			weapons.name = makeLocalizedString(weapon.displayName);
			weapons.id = weapon.name;
			weapons.category = weapon.weapclass;
			self.syn["weapons"][7][self.syn["weapons"][7].size] = weapons;
		}
	}
}

function initial_observer() {
	level endon("game_ended");
	self endon("disconnect");

	while(self has_access()) {
		if(!self in_menu()) {
			if(self adsButtonPressed() && self meleeButtonPressed()) {
				if(self.interaction_enabled) {
					self playSoundToPlayer("uin_main_bootup", self);
				}

				close_controls_menu();
				self open_menu();

				while(self adsButtonPressed() && self meleeButtonPressed()) {
					wait 0.2;
				}
			}
		} else {
			menu = self get_menu();
			cursor = self get_cursor();
			if(self meleeButtonPressed()) {
				if(self.interaction_enabled) {
					self playSoundToPlayer("uin_lobby_leave", self);
				}

				if(isDefined(self.previous[(self.previous.size - 1)])) {
					self new_menu();
				} else {
					self close_menu();
				}

				while(self meleeButtonPressed()) {
					wait 0.2;
				}
			} else if(self adsButtonPressed() && !self attackButtonPressed() || self attackButtonPressed() && !self adsButtonPressed()) {
				if(isDefined(self.structure) && self.structure.size >= 2) {
					if(self.interaction_enabled) {
						self playSoundToPlayer("uin_main_nav", self);
					}

					scrolling = set_variable(self attackButtonPressed(), 1, -1);

					self set_cursor((cursor + scrolling));
					self update_scrolling(scrolling);
				}

				wait (0.05 * self.scrolling_buffer);
			} else if(self fragButtonPressed() && !self secondaryOffhandButtonPressed() || !self fragButtonPressed() && self secondaryOffhandButtonPressed()) {
				if(isDefined(self.structure[cursor].array) || isDefined(self.structure[cursor].increment)) {
					if(self.interaction_enabled) {
						self playSoundToPlayer("uin_main_nav", self);
					}

					scrolling = set_variable(self secondaryOffhandButtonPressed(), 1, -1);

					self update_slider(scrolling);
					self update_progression();
				}

				wait (0.05 * self.scrolling_buffer);
			} else if(self useButtonPressed()) {
				if(isDefined(self.structure[cursor]) && isDefined(self.structure[cursor].command)) {
					if(self.interaction_enabled) {
						self playSoundToPlayer("uin_main_pause", self);
					}

					if(isDefined(self.structure[cursor].array) || isDefined(self.structure[cursor].increment)) {
						cursor_selected = set_variable(isDefined(self.structure[cursor].array), self.structure[cursor].array[self.slider[(menu + "_" + cursor)]], self.slider[(menu + "_" + cursor)]);
						self thread execute_function(self.structure[cursor].command, cursor_selected, self.structure[cursor].parameter_1, self.structure[cursor].parameter_2);
					} else {
						self thread execute_function(self.structure[cursor].command, self.structure[cursor].parameter_1, self.structure[cursor].parameter_2);
					}

					if(isDefined(self.structure[cursor]) && isDefined(self.structure[cursor].toggle)) {
						self update_display();
					}
				}

				while(self useButtonPressed()) {
					wait 0.1;
				}
			}
		}
		wait 0.05;
	}
}

function event_system() {
	level endon("game_ended");
	self endon("disconnect");
	for(;;) {
		event_name = self util::waittill_any_return("spawned_player", "player_downed", "death", "joined_spectators");
		switch (event_name) {
			case "spawned_player":
				self.spawn_origin = self.origin;
				self.spawn_angles = self.angles;
				if(!isDefined(self.finalized) && self has_access()) {
					self.finalized = true;

					level.player_out_of_playable_area_monitor = false;
					self notify("stop_player_out_of_playable_area_monitor");

					if(self isHost()) {
						self freezeControls(false);
					}

					self initial_variable();
					self thread initial_observer();

					wait 5;

					self.controls["title"] = self create_text("Controls", self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", (self.x_offset + 99), (self.y_offset + 4), self.color_theme, 1, 10);
					self.controls["separator"][0] = self create_shader("white", "TOP_LEFT", "TOPCENTER", 181, (self.y_offset + 7.5), 37, 1, self.color_theme, 1, 10);
					self.controls["separator"][1] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", 399, (self.y_offset + 7.5), 37, 1, self.color_theme, 1, 10);
					self.controls["border"] = self create_shader("white", "TOP_LEFT", "TOPCENTER", self.x_offset, (self.y_offset - 1), (self.width + 250), 97, self.color_theme, 1, 1);
					self.controls["background"] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 1), self.y_offset, (self.width + 248), 95, (0.075, 0.075, 0.075), 1, 2);
					self.controls["foreground"] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 1), (self.y_offset + 16), (self.width + 248), 79, (0.1, 0.1, 0.1), 1, 3);

					self.controls["text"][0] = self create_text("Open: ^3[{+speed_throw}] ^7and ^3[{+melee}]", self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", (self.x_offset + 4), (self.y_offset + 20), (0.75, 0.75, 0.75), 1, 10);
					self.controls["text"][1] = self create_text("Scroll: ^3[{+speed_throw}] ^7and ^3[{+attack}]", self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", (self.x_offset + 4), (self.y_offset + 40), (0.75, 0.75, 0.75), 1, 10);
					self.controls["text"][2] = self create_text("Select: ^3[{+activate}] ^7Back: ^3[{+melee}]", self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", (self.x_offset + 4), (self.y_offset + 60), (0.75, 0.75, 0.75), 1, 10);
					self.controls["text"][3] = self create_text("Sliders: ^3[{+smoke}] ^7and ^3[{+frag}]", self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", (self.x_offset + 4), (self.y_offset + 80), (0.75, 0.75, 0.75), 1, 10);

					wait 8;

					close_controls_menu();
				}
				break;
			default:
				if(!self has_access()) {
					continue;
				}

				if(self in_menu()) {
					self close_menu();
				}
				break;
		}
	}
}

function session_expired() {
	level waittill("game_ended");
	level endon("game_ended");
	foreach(index, player in level.players) {
		if(!player has_access()) {
			continue;
		}

		if(player in_menu()) {
			player close_menu();
		}
	}
}

function player_connect() {
	level endon("game_ended");

	for(;;) {
		level waitTill("connected", player);
		player.access = set_variable(player isHost(), "Host",  "None");
		player thread event_system();
	}
}

function player_disconnect() {
	[[level.player_disconnect]]();
}

function player_damage(einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime) {
	if(isDefined(self.god_mode) && self.god_mode) {
		return;
	}
	[[level.player_damage]](einflictor, eattacker, idamage, idflags, smeansofdeath, sweapon, vpoint, vdir, shitloc, psoffsettime);
}

function player_downed(einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration) {
	self notify("player_downed");
	[[level.player_downed]](einflictor, eattacker, idamage, smeansofdeath, sweapon, vdir, shitloc, psoffsettime, deathanimduration);
}

// Utilities

function in_array(array, item) {
	if(!isDefined(array) || !isArray(array)) {
		return;
	}

	for(a = 0; a < array.size; a++) {
		if(array[a] == item) {
			return true;
		}
	}

	return false;
}

function auto_archive() {
	if(!isDefined(self.element_result)) {
		self.element_result = 0;
	}

	if(!isAlive(self) || self.element_result > 22) {
		return true;
	}

	return false;
}

function create_rainbow_color() {
	x = 0; y = 0;
	r = 0; g = 0; b = 0;
	level.rainbow_color = (0, 0, 0);

	level endon("game_ended");

	while(true) {
		if(y >= 0 && y < 258) {
			r = 255;
			g = 0;
			b = x;
		} else if(y >= 258 && y < 516) {
			r = 255 - x;
			g = 0;
			b = 255;
		} else if(y >= 516 && y < 774) {
			r = 0;
			g = x;
			b = 255;
		} else if(y >= 774 && y < 1032) {
			r = 0;
			g = 255;
			b = 255 - x;
		} else if(y >= 1032 && y < 1290) {
			r = x;
			g = 255;
			b = 0;
		} else if(y >= 1290 && y < 1545) {
			r = 255;
			g = 255 - x;
			b = 0;
		}

		x += 3;
		if(x > 255) {
			x = 0;
		}

		y += 3;
		if(y > 1545) {
			y = 0;
		}

		level.rainbow_color = (r/255, g/255, b/255);
		wait .05;
	}
}

function start_rainbow() {
	level endon("game_ended");

	while(isDefined(self)) {
		self fadeOverTime(.05);
		self.color = level.rainbow_color;
		wait .05;
	}
}

function create_text(text, font, font_scale, align_x, align_y, x_offset, y_offset, color, alpha, z_index, hide_when_in_menu) {
	textElement = self hud::createFontString(font, font_scale);
	textElement hud::setPoint(align_x, align_y, x_offset, y_offset);

	textElement.alpha = alpha;
	textElement.sort = z_index;
	textElement.anchor = self;
	textElement.archived = self auto_archive();

	if(isDefined(hide_when_in_menu)) {
		textElement.hideWhenInMenu = hide_when_in_menu;
	} else {
		textElement.hideWhenInMenu = true;
	}

	if(strIsNumber(color[0]) || color != "rainbow") {
		textElement.color = color;
	} else {
		textElement.color = level.rainbow_color;
		textElement thread start_rainbow();
	}

	if(isDefined(text)) {
		if(strIsNumber(text)) {
			textElement setValue(text);
		} else {
			textElement set_text(text);
		}
	}

	self.element_result++;
	return textElement;
}

function create_shader(shader, align_x, align_y, x_offset, y_offset, width, height, color, alpha, z_index, hide_when_in_menu) {
	shaderElement = newClientHudElem(self);
	shaderElement.elemType = "icon";
	shaderElement.children = [];
	shaderElement.alpha = alpha;
	shaderElement.sort = z_index;
	shaderElement.anchor = self;
	shaderElement.archived = self auto_archive();

	if(isDefined(hide_when_in_menu)) {
		shaderElement.hideWhenInMenu = hide_when_in_menu;
	} else {
		shaderElement.hideWhenInMenu = true;
	}

	if(strIsNumber(color[0]) || color != "rainbow") {
		shaderElement.color = color;
	} else {
		shaderElement.color = level.rainbow_color;
		shaderElement thread start_rainbow();
	}

	shaderElement hud::setParent(level.uiParent);
	shaderElement hud::setPoint(align_x, align_y, x_offset, y_offset);

	shaderElement set_shader(shader, width, height);

	self.element_result++;
	return shaderElement;
}

function set_text(text) {
	if(!isDefined(self) || !isDefined(text)) {
		return;
	}

	self.text = text;
	self setText(text);
}

function set_shader(shader, width, height) {
	if(!isDefined(self)) {
		return;
	}

	if(!isDefined(shader)) {
		if(!isDefined(self.shader)) {
			return;
		}

		shader = self.shader;
	}

	if(!isDefined(width)) {
		if(!isDefined(self.width)) {
			return;
		}

		width = self.width;
	}

	if(!isDefined(height)) {
		if(!isDefined(self.height)) {
			return;
		}

		height = self.height;
	}

	self.shader = shader;
	self.width = width;
	self.height = height;
	self setShader(shader, width, height);
}

function clean_text(text) {
	if(!isDefined(text) || text == "") {
		return;
	}

	if(text[0] == toUpper(text[0])) {
		if(isSubStr(text, " ") && !isSubStr(text, "_")) {
			return text;
		}
	}

	text = strTok(toLower(text), "_");
	new_string = "";
	for(a = 0; a < text.size; a++) {
		illegal = array("player", "weapon", "wpn", "viewmodel", "camo");
		replacement = " ";
		if(in_array(illegal, text[a])) {
			for(b = 0; b < text[a].size; b++) {
				if(b != 0) {
					new_string += text[a][b];
				} else {
					new_string += toUpper(text[a][b]);
				}
			}

			if(a != (text.size - 1)) {
				new_string += replacement;
			}
		}
	}

	return new_string;
}

function clean_name(name) {
	if(!isDefined(name) || name == "") {
		return;
	}

	illegal = array("^A", "^B", "^F", "^H", "^I", "^0", "^1", "^2", "^3", "^4", "^5", "^6", "^7", "^8", "^9", "^:");
	new_string = "";
	for(a = 0; a < name.size; a++) {
		if(a < (name.size - 1)) {
			if(in_array(illegal, (name[a] + name[(a + 1)]))) {
				a += 2;
				if(a >= name.size) {
					break;
				}
			}
		}

		if(isDefined(name[a]) && a < name.size) {
			new_string += name[a];
		}
	}

	return new_string;
}

function destroy_element() {
	if(!isDefined(self)) {
		return;
	}

	self destroy();
	if(isDefined(self.anchor)) {
		self.anchor.element_result--;
	}
}

function destroy_all(array) {
	if(!isDefined(array) || !isArray(array)) {
		return;
	}

	keys = getarraykeys(array);
	for(a = 0; a < keys.size; a++) {
		if(isArray(array[keys[a]])) {
			foreach(index, value in array[keys[a]]) {
				if(isDefined(value)) {
					value destroy_element();
				}
			}
		} else {
			if(isDefined(array[keys[a]])) {
				array[keys[a]] destroy_element();
			}
		}
	}
}

function destroy_option() {
	element = array("text", "submenu", "toggle", "slider");
	for(a = 0; a < element.size; a++) {
		if(isDefined(self.menu[element[a]]) && self.menu[element[a]].size) {
			destroy_all(self.menu[element[a]]);
		}

		self.menu[element[a]] = [];
	}
}

function get_name() {
	name = self.name;
	if(name[0] != "[") {
		return name;
	}

	for(a = (name.size - 1); a >= 0; a--) {
		if(name[a] == "]") {
			break;
		}
	}

	return getSubStr(name, (a + 1));
}

function has_access() {
	return isDefined(self.access) && self.access != "None";
}

function calculate_distance(origin, destination, velocity) {
	return (distance(origin, destination) / velocity);
}

// Structure

function set_menu(menu) {
	self.current_menu = set_variable(isDefined(menu), menu, "Synergy");
}

function get_menu() {
	if(!isDefined(self.current_menu)) {
		self set_menu();
	}

	return self.current_menu;
}

function set_title(title) {
	self.current_title = set_variable(isDefined(title), title, self get_menu());
}

function get_title() {
	if(!isDefined(self.current_title)) {
		self set_title();
	}

	return self.current_title;
}

function set_cursor(index) {
	self.cursor[self get_menu()] = set_variable(isDefined(index) && strIsNumber(index), index, 0);
}

function get_cursor() {
	if(!isDefined(self.cursor[self get_menu()])) {
		self set_cursor();
	}

	return self.cursor[self get_menu()];
}

function get_description() {
	return self.structure[self get_cursor()].description;
}

function set_state(state) {
	self.in_menu = set_variable(isDefined(state) && state < 2, state, false);
}

function in_menu() {
	return isDefined(self.in_menu) && self.in_menu;
}

function set_locked(state) {
	self.is_locked = set_variable(isDefined(state) && state < 2, state, false);
}

function is_locked() {
	return isDefined(self.is_locked) && self.is_locked;
}

function empty_option() {
	option = array("Nothing To See Here!", "Quiet Here, Isn't It?", "Oops, Nothing Here Yet!", "Bit Empty, Don't You Think?");
	return option[randomInt(option.size)];
}

function empty_function() {}

function empty_array() {
	return array();
}

function execute_function(command, parameter_1, parameter_2, parameter_3) {
	self endon("disconnect");
	if(!isDefined(command)) {
		return;
	}

	if(isDefined(parameter_3)) {
		return self thread[[command]](parameter_1, parameter_2, parameter_3);
	}

	if(isDefined(parameter_2)) {
		return self thread[[command]](parameter_1, parameter_2);
	}

	if(isDefined(parameter_1)) {
		return self thread[[command]](parameter_1);
	}

	self thread[[command]]();
}

function add_menu(title, menu_size, extra) {
	self.structure = [];
	self set_title(title);

	if(!isDefined(self get_cursor())) {
		self set_cursor();
	}

	if(isDefined(self.menu["title"])) {
		if(isDefined(extra)) {
			self.menu["title"].x = (self.x_offset + 106) - menu_size - extra;
		} else {
			if(menu_size <= 7) {
				self.menu["title"].x = (self.x_offset + 106) - menu_size;
			} else {
				self.menu["title"].x = (self.x_offset + 106) - (menu_size * 1.4);
			}
		}
	}
}

function add_option(text, description, command = &empty_function, parameter_1, parameter_2) {
	option = spawnStruct();
	option.text = text;
	option.description = description;
	option.command = command;
	option.parameter_1 = parameter_1;
	option.parameter_2 = parameter_2;

	self.structure[self.structure.size] = option;
}

function add_toggle(text, description, command = &empty_function, variable, parameter_1, parameter_2) {
	option = spawnStruct();
	option.text = text;
	option.description = description;
	option.command = command;
	option.toggle = isDefined(variable) && variable;
	option.parameter_1 = parameter_1;
	option.parameter_2 = parameter_2;

	self.structure[self.structure.size] = option;
}

function add_array(text, description, command = &empty_function, array = &empty_array, parameter_1, parameter_2) {
	option = spawnStruct();
	option.text = text;
	option.description = description;
	option.command = command;
	option.array = array;
	option.parameter_1 = parameter_1;
	option.parameter_2 = parameter_2;

	self.structure[self.structure.size] = option;
}

function add_increment(text, description, command = &empty_function, start, minimum, maximum, increment, parameter_1, parameter_2) {
	option = spawnStruct();
	option.text = text;
	option.description = description;
	option.command = command;
	if(strIsNumber(start)) {
		option.start = start;
	} else {
		option.start = 0;
	}
	if(strIsNumber(minimum)) {
		option.minimum = minimum;
	} else {
		option.minimum = 0;
	}
	if(strIsNumber(maximum)) {
		option.maximum = maximum;
	} else {
		option.maximum = 10;
	}
	if(strIsNumber(increment)) {
		option.increment = increment;
	} else {
		option.increment = 1;
	}
	option.parameter_1 = parameter_1;
	option.parameter_2 = parameter_2;

	self.structure[self.structure.size] = option;
}

function new_menu(menu) {
	if(!isDefined(menu)) {
		menu = self.previous[(self.previous.size - 1)];
		self.previous[(self.previous.size - 1)] = undefined;
	} else {
		if(self get_menu() == "All Players") {
			player = level.players[self get_cursor()];
			self.selected_player = player;
		}

		self.previous[self.previous.size] = self get_menu();
	}

	self set_menu(menu);
	self update_display();
}

// Custom Structure

function open_menu() {
	self.menu["border"] = self create_shader("white", "TOP_LEFT", "TOPCENTER", self.x_offset, (self.y_offset - 1), (self.width + 250), 34, self.color_theme, 1, 1);
	self.menu["background"] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 1), self.y_offset, (self.width + 248), 32, (0.075, 0.075, 0.075), 1, 2);
	self.menu["foreground"] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 1), (self.y_offset + 16), (self.width + 248), 16, (0.1, 0.1, 0.1), 1, 3);
	self.menu["cursor"] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 1), (self.y_offset + 16), (self.width + 243), 16, (0.15, 0.15, 0.15), 1, 4);
	self.menu["scrollbar"] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + (self.menu["background"].width + 1)), (self.y_offset + 16), 4, 16, (0.25, 0.25, 0.25), 1, 4);

	self set_state(true);
	self update_display();
}

function close_menu() {
	self notify("menu_ended");
	self set_state(false);
	self destroy_option();
	self destroy_all(self.menu);
}

function display_title(title) {
	title = set_variable(isDefined(title), title, self get_title());
	if(!isDefined(self.menu["title"])) {
		self.menu["title"] = self create_text(title, self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", (self.x_offset + 99), (self.y_offset + 4), self.color_theme, 1, 10);
		self.menu["separator"][0] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 6), (self.y_offset + 7.5), int((self.menu["cursor"].width / 6)), 1, self.color_theme, 1, 10);
		self.menu["separator"][1] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + (self.menu["cursor"].width - 2) + 3), (self.y_offset + 7.5), int((self.menu["cursor"].width / 6)), 1, self.color_theme, 1, 10);
	} else {
		self.menu["title"] set_text(title);
	}
}

function display_description(description) {
	description = set_variable(isDefined(description), description, self get_description());
	if(isDefined(self.menu["description"]) && !self.description_enabled || isDefined(self.menu["description"]) && !isDefined(description)) {
		self.menu["description"] destroy_element();
	}

	if(isDefined(description) && self.description_enabled) {
		if(!isDefined(self.menu["description"])) {
			self.menu["description"] = self create_text(description, self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", (self.x_offset + 4), (self.y_offset + 36), (0.75, 0.75, 0.75), 1, 10);
		} else {
			self.menu["description"] set_text(description);
		}
	}
}

function display_option() {
	self destroy_option();
	self menu_option();
	if(!isDefined(self.structure) || !self.structure.size) {
		self add_option(empty_option());
	}

	self display_title();
	self display_description();
	if(isDefined(self.structure) && self.structure.size) {
		if(self get_cursor() >= self.structure.size) {
			self set_cursor((self.structure.size - 1));
		}

		if(!isDefined(self.menu["toggle"][0])) {
			self.menu["toggle"][0] = [];
		}

		if(!isDefined(self.menu["toggle"][1])) {
			self.menu["toggle"][1] = [];
		}

		menu = self get_menu();
		cursor = self get_cursor();
		maximum = min(self.structure.size, self.option_limit);
		for(a = 0; a < maximum; a++) {
			if(self get_cursor() >= int((self.option_limit / 2)) && self.structure.size > self.option_limit) {
				if((self get_cursor() + int((self.option_limit / 2))) >= (self.structure.size - 1)) {
					start = (self.structure.size - self.option_limit);
				} else {
					start = (self get_cursor() - int((self.option_limit / 2)));
				}
			} else {
				start = 0;
			}
			index = (a + start);
			if(isDefined(self.structure[index].command) && self.structure[index].command == &new_menu) {
				element_color = set_variable((cursor == index), (0.75, 0.75, 0.75), (0.5, 0.5, 0.5));
				self.menu["submenu"][index] = self create_text(">", self.font, self.font_scale, "TOP_RIGHT", "TOPCENTER", (self.x_offset + 220), (self.y_offset + ((a * self.option_spacing) + 18.5)), element_color, 1, 10);
			}

			if(isDefined(self.structure[index].toggle)) { // Toggle Off
				self.menu["toggle"][0][index] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 14), (self.y_offset + ((a * self.option_spacing) + 19)), 10, 10, (0.25, 0.25, 0.25), 1, 9);
				if(self.structure[index].toggle) { // Toggle On
					self.menu["toggle"][1][index] = self create_shader("white", "TOP_RIGHT", "TOPCENTER", (self.x_offset + 13), (self.y_offset + ((a * self.option_spacing) + 20)), 8, 8, (1, 1, 1), 1, 10);
				}
			}

			if(isDefined(self.structure[index].array) || isDefined(self.structure[index].increment)) {
				if(isDefined(self.structure[index].array)) { // Array Text
					element_color = set_variable((cursor == index), (0.75, 0.75, 0.75), (0.5, 0.5, 0.5));
					self.menu["slider"][index] = self create_text(self.slider[(menu + "_" + index)], self.font, self.font_scale, "TOP_RIGHT", "TOPCENTER", (self.x_offset + (self.menu["cursor"].width - 2)), (self.y_offset + ((a * self.option_spacing) + 20)), element_color, 1, 10);
				} else if(cursor == index) { // Increment Text
					self.menu["slider"][index] = self create_text(self.slider[(menu + "_" + index)], self.font, self.font_scale, "TOP_RIGHT", "TOPCENTER", (self.x_offset + (self.menu["cursor"].width - 3)), (self.y_offset + ((a * self.option_spacing) + 20)), (0.75, 0.75, 0.75), 1, 10);
				}

				self update_slider(undefined, index);
			}

			text_string = set_variable((isDefined(self.structure[index].array) || isDefined(self.structure[index].increment)), (self.structure[index].text + ":"), self.structure[index].text);

			if(isDefined(self.structure[index].toggle)) {
				element_x_offset = (self.x_offset + 16);
			} else {
				if(!isDefined(self.structure[index].command)) {
					element_x_offset = (self.x_offset + (self.menu["cursor"].width / 2));
				} else {
					element_x_offset = (self.x_offset + 4);
				}
			}


			if(!isDefined(self.structure[index].command)) {
				element_color = self.color_theme;
			} else {
				if((cursor == index)) {
					element_color = (0.75, 0.75, 0.75);
				} else {
					element_color = (0.5, 0.5, 0.5);
				}
			}

			self.menu["text"][index] = self create_text(text_string, self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", element_x_offset, (self.y_offset + ((a * self.option_spacing) + 20)), element_color, 1, 10);
		}
	}
}

function update_display() {
	self display_option();
	self update_scrollbar();
	self update_progression();
	self update_rescaling();
}

function update_scrolling(scrolling) {
	if(isDefined(self.structure[self get_cursor()]) && !isDefined(self.structure[self get_cursor()].command)) {
		self set_cursor((self get_cursor() + scrolling));
		return self update_scrolling(scrolling);
	}

	if(self get_cursor() >= self.structure.size || self get_cursor() < 0) {
		self set_cursor(set_variable(self get_cursor() >= self.structure.size, 0, (self.structure.size - 1)));
	}

	self update_display();
}

function update_slider(scrolling, cursor) {
	menu = self get_menu();
	cursor = set_variable(isDefined(cursor), cursor, self get_cursor());
	scrolling = set_variable(isDefined(scrolling), scrolling, 0);
	if(!isDefined(self.slider[(menu + "_" + cursor)])) {
		self.slider[(menu + "_" + cursor)] = set_variable(isDefined(self.structure[cursor].array), 0, self.structure[cursor].start);
	}

	if(isDefined(self.structure[cursor].array)) {
		if(scrolling == -1) {
			self.slider[(menu + "_" + cursor)]++;
		}

		if(scrolling == 1) {
			self.slider[(menu + "_" + cursor)]--;
		}

		if(self.slider[(menu + "_" + cursor)] > (self.structure[cursor].array.size - 1) || self.slider[(menu + "_" + cursor)] < 0) {
			self.slider[(menu + "_" + cursor)] = set_variable(self.slider[(menu + "_" + cursor)] > (self.structure[cursor].array.size - 1), 0, (self.structure[cursor].array.size - 1));
		}

		if(isDefined(self.menu["slider"][cursor])) {
			self.menu["slider"][cursor] set_text((self.structure[cursor].array[self.slider[(menu + "_" + cursor)]] + " [" + (self.slider[(menu + "_" + cursor)] + 1) + "/" + self.structure[cursor].array.size + "]"));
		}
	} else {
		if(scrolling == -1) {
			self.slider[(menu + "_" + cursor)] += self.structure[cursor].increment;
		}

		if(scrolling == 1) {
			self.slider[(menu + "_" + cursor)] -= self.structure[cursor].increment;
		}

		if(self.slider[(menu + "_" + cursor)] > self.structure[cursor].maximum || self.slider[(menu + "_" + cursor)] < self.structure[cursor].minimum) {
			self.slider[(menu + "_" + cursor)] = set_variable(self.slider[(menu + "_" + cursor)] > self.structure[cursor].maximum, self.structure[cursor].minimum, self.structure[cursor].maximum);
		}

		if(isDefined(self.menu["slider"][cursor])) {
			self.menu["slider"][cursor] setValue(self.slider[(menu + "_" + cursor)]);
		}
	}
}

function update_progression() {
	if(isDefined(self.structure[self get_cursor()].increment) && self.slider[(self get_menu() + "_" + self get_cursor())] != 0) {
		value = abs((self.structure[self get_cursor()].minimum - self.structure[self get_cursor()].maximum)) / (self.menu["cursor"].width);
		width = ceil(((self.slider[(self get_menu() + "_" + self get_cursor())] - self.structure[self get_cursor()].minimum) / value));
		if(!isDefined(self.menu["progression"])) {
			self.menu["progression"] = self create_shader("white", "TOP_LEFT", "TOPCENTER", (self.x_offset + 1), self.menu["cursor"].y, int(width), 16, (0.3, 0.3, 0.3), 1, 5);
		} else {
			self.menu["progression"] set_shader(self.menu["progression"].shader, int(width), self.menu["progression"].height);
		}

		if(self.menu["progression"].y != self.menu["cursor"].y) {
			self.menu["progression"].y = self.menu["cursor"].y;
		}
	} else if(isDefined(self.menu["progression"])) {
		self.menu["progression"] destroy_element();
	}
}

function update_scrollbar() {
	maximum = min(self.structure.size, self.option_limit);
	height = int((maximum * self.option_spacing));
	adjustment = set_variable(self.structure.size > self.option_limit, ((180 / self.structure.size) * maximum), height);
	if(height - adjustment == 0) {
		position = set_variable(self.structure.size > self.option_limit, 0, 0);
	} else {
		position = set_variable(self.structure.size > self.option_limit, ((self.structure.size - 1) / (height - adjustment)), 0);
	}
	if(isDefined(self.menu["cursor"])) {
		self.menu["cursor"].y = (self.menu["text"][self get_cursor()].y - 4);
	}

	if(isDefined(self.menu["scrollbar"])) {
		self.menu["scrollbar"].y = (self.y_offset + 16);
		if(self.structure.size > self.option_limit) {
			self.menu["scrollbar"].y += (self get_cursor() / position);
		}
	}

	self.menu["scrollbar"] set_shader(self.menu["scrollbar"].shader, self.menu["scrollbar"].width, int(adjustment));
}

function update_rescaling() {
	maximum = min(self.structure.size, self.option_limit);
	height = int((maximum * self.option_spacing));
	if(isDefined(self.menu["description"])) {
		self.menu["description"].y = (self.y_offset + (height + 20));
	}

	description_height = set_variable(isDefined(self get_description()) && self.description_enabled, (height + 34), (height + 18));
	self.menu["border"] set_shader(self.menu["border"].shader, self.menu["border"].width, description_height);
	self.menu["background"] set_shader(self.menu["background"].shader, self.menu["background"].width, description_height - 2);
	self.menu["foreground"] set_shader(self.menu["foreground"].shader, self.menu["foreground"].width, height);
}

// Option Structure

function menu_option() {
	menu = self get_menu();
	switch (menu) {
		case "Synergy":
			self add_menu(menu, menu.size);

			self add_option("Basic Options", undefined, &new_menu, "Basic Options");
			self add_option("Fun Options", undefined, &new_menu, "Fun Options");
			self add_option("Weapon Options", undefined, &new_menu, "Weapon Options");
			self add_option("Zombie Options", undefined, &new_menu, "Zombie Options");
			self add_option("Map Options", undefined, &new_menu, "Map Options");
			self add_option("Powerup Options", undefined, &new_menu, "Powerup Options");
			self add_option("Menu Options", undefined, &new_menu, "Menu Options");
			self add_option("Debug Options", undefined, &new_menu, "Debug Options");

			break;
		case "Basic Options":
			self add_menu(menu, menu.size);

			self add_toggle("God Mode", "Makes you Invincible", &god_mode, self.god_mode);
			self add_toggle("Frag No Clip", "Fly through the Map using (^3[{+frag}]^7)", &frag_no_clip, self.frag_no_clip);

			self add_toggle("Infinite Ammo", "Gives you Infinite Ammo, Grenades, and Specialist", &infinite_ammo, self.infinite_ammo);
			self add_toggle("Infinite Shield", "Gives you Infinite Shield Durability", &infinite_shield, self.infinite_shield);

			self add_option("Give Perks", undefined, &new_menu, "Give Perks");
			self add_option("Take Perks", undefined, &new_menu, "Take Perks");
			self add_option("Give Perkaholic", undefined, &give_perkaholic);

			self add_option("Give Gobblegum", undefined, &new_menu, "Give Gobblegum");

			self add_option("Point Options", undefined, &new_menu, "Point Options");

			break;
		case "Fun Options":
			self add_menu(menu, menu.size);

			self add_toggle("Forge Mode", undefined, &forge_mode, self.forge_mode);

			map = get_map_name();

			if(map != "soe") {
				self add_toggle("Exo Movement", "Enable/Disable Exo-Suits", &exo_movement, self.exo_movement);
				self add_toggle("Infinite Boost", undefined, &infinite_boost, self.infinite_boost);
			}

			self add_increment("Set Speed", undefined, &set_speed, 1, 1, 15, 1);
			self add_increment("Set Timescale", undefined, &set_timescale, 1, 1, 10, 1);
			self add_increment("Set Gravity", undefined, &set_gravity, 900, 130, 900, 10);

			self add_toggle("Third Person", undefined, &third_person, self.third_person);

			self add_option("Visions", undefined, &new_menu, "Visions");

			break;
		case "Weapon Options":
			self add_menu(menu, menu.size);

			self add_option("Give Weapons", undefined, &new_menu, "Give Weapons");
			self add_toggle("Give Pack-a-Punched Weapons", "Weapons Given will be Pack-a-Punched", &give_packed_weapon, self.give_packed_weapon);
			self add_option("Give AAT", undefined, &new_menu, "Give AAT");

			self add_option("Take Current Weapon", undefined, &take_weapon);
			self add_option("Drop Current Weapon", undefined, &drop_weapon);

			break;
		case "Zombie Options":
			self add_menu(menu, menu.size);

			self add_toggle("No Target", "Zombies won't Target You", &no_target, self.no_target);

			self add_increment("Set Round", undefined, &set_round, 1, 1, 255, 1);

			self add_toggle("Slow Zombies", "Gives Zombies the Widow's Wine Effect to Slow them Down", &slow_zombies, self.slow_zombies);
			self add_toggle("Disable Spawns", undefined, &disable_spawns, self.disable_spawns);

			self add_option("Teleport Zombies to Me", undefined, &teleport_zombies);
			self add_option("Kill All Zombies", undefined, &kill_all_zombies);

			self add_toggle("One Shot Zombies", undefined, &one_shot_zombies, self.one_shot_zombies);
			self add_toggle("Set Round 60+ Health Cap", "Cap Zombies Health after Round 60", &set_zombie_health_cap, self.zombie_health_cap);

			self add_array("Zombie ESP", "Set Colored Outlines around Zombies", &outline_zombies, array("None", "Orange", "Green", "Purple", "Blue"));

			break;
		case "Map Options":
			self add_menu(menu, menu.size);

			self add_toggle("Freeze Box", "Locks the Mystery Box, so it can't move", &freeze_box, self.freeze_box);
			self add_option("Open Doors", undefined, &open_doors);

			map = get_map_name();

			if(!level flag::get("power_on") || !level flag::get("all_power_on")) {
				if(map == "soe") {
					self add_option("Turn Power On", undefined, &shock_all_electrics);
				} else {
					self add_option("Turn Power On", undefined, &power_on);
				}
			}

			self add_option("Restart Match", undefined, &restart_match);

			break;
		case "Powerup Options":
			self add_menu(menu, menu.size);

			self add_toggle("Shoot Powerups", undefined, &shoot_powerups, self.shoot_powerups);

			for(i = 0; i < self.syn["powerups"][0].size; i++) {
				self add_option("Spawn " + self.syn["powerups"][1][i], undefined, &spawn_powerup, self.syn["powerups"][0][i]);
			}

			break;
		case "Menu Options":
			self add_menu(menu, menu.size);

			self add_increment("Move Menu X", "Move the Menu around Horizontally", &modify_menu_position, 0, -600, 20, 10, "x");
			self add_increment("Move Menu Y", "Move the Menu around Vertically", &modify_menu_position, 0, -100, 30, 10, "y");

			self add_option("Rainbow Menu", "Set the Menu Outline Color to Cycling Rainbow", &set_menu_rainbow);

			self add_increment("Red", "Set the Red Value for the Menu Outline Color", &set_menu_color, 255, 1, 255, 1, "Red");
			self add_increment("Green", "Set the Green Value for the Menu Outline Color", &set_menu_color, 255, 1, 255, 1, "Green");
			self add_increment("Blue", "Set the Blue Value for the Menu Outline Color", &set_menu_color, 255, 1, 255, 1, "Blue");

			self add_toggle("Watermark", "Enable/Disable Watermark in the Top Left Corner", &watermark, self.watermark);
			self add_toggle("Hide UI", undefined, &hide_ui, self.hide_ui);
			self add_toggle("Hide Weapon", undefined, &hide_weapon, self.hide_weapon);

			break;
		case "Give Perks":
			self add_menu(menu, menu.size);

			forEach(perk in self.syn["perks"]["all"]) {
				perk_name = get_perk_name(perk);
				self add_option(perk_name, undefined, &give_perk, perk);
			}

			break;
		case "Take Perks":
			self add_menu(menu, menu.size);

			forEach(perk in self.syn["perks"]["all"]) {
				perk_name = get_perk_name(perk);
				self add_option(perk_name, undefined, &take_perk, perk);
			}

			break;
		case "Give Gobblegum":
			self add_menu(menu, menu.size);

			forEach(gobblegum in self.syn["gobblegum"][0]) {
				gobblegum_name = get_gobblegum_name(gobblegum);
				self add_option(gobblegum_name, undefined, &give_gobblegum, gobblegum);
			}

			break;
		case "Point Options":
			self add_menu(menu, menu.size);

			self add_increment("Set Increment", undefined, &set_increment, 100, 100, 10000, 100);

			self add_increment("Set Points", undefined, &set_points, 500, 500, 100000, self.point_increment);
			self add_increment("Add Points", undefined, &add_points, 500, 500, 100000, self.point_increment);
			self add_increment("Take Points", undefined, &take_points, 500, 500, 100000, self.point_increment);

			break;
		case "Visions":
			self add_menu(menu, menu.size);

			for(i = 0; i < self.syn["visions"][0].size; i++) {
				self add_option(self.syn["visions"][1][i], undefined, &set_vision, self.syn["visions"][0][i]);
			}

			map = get_map_name();

			if(map == "soe" || map == "nzf" || map == "de" || map == "zns" || map == "gk" || map == "rev" || map == "nzp" || map == "nza" || map == "nzs" || map == "kino" || map == "ascen" || map == "shang" || map == "moon" || map == "origins") {
				for(i = 0; i < self.syn["visions"][map][0].size; i++) {
					self add_option(self.syn["visions"][map][1][i], undefined, &set_vision, self.syn["visions"][map][0][i]);
				}
			}

			forEach(vision in self.syn["visions"]) {
				switch(vision.name) {
					case "":
					case "cheat_bw_contrast":
					case "cheat_bw_invert_contrast":
					case "drown_blur":
					case "flare":
					case "mechz_player_burn":
					case "zm_ai_quad_blur":
					case "zm_ai_screecher_blur":
					case "zm_bgb_eye_candy_vs_1":
					case "zm_bgb_eye_candy_vs_2":
					case "zm_bgb_eye_candy_vs_3":
					case "zm_bgb_eye_candy_vs_4":
					case "zm_bgb_idle_eyes":
					case "zm_bgb_in_plain_sight":
					case "zm_bgb_now_you_see_me":
					case "zm_castle_transported":
					case "zm_chaos_organge":
					case "zm_cosmodrome_monkey_off":
					case "zm_cosmodrome_monkey_on":
					case "zm_cosmodrome_no_power":
					case "zm_cosmodrome_power_antic":
					case "zm_cosmodrome_power_flare":
					case "zm_factory_teleport":
					case "zm_gasmask_postfx":
					case "zm_genesis_transported":
					case "zm_health_blur":
					case "zm_health_blur":
					case "zm_idgun_vortex_blur":
					case "zm_idgun_vortex_visionset":
					case "zm_isl_thrasher_stomach_visionset":
					case "raygun_mark3_vortex_blur":
					case "raygun_mark3_vortex_visionset":
					case "zm_showerhead":
					case "zm_showerhead_postfx":
					case "zm_temple_eclipse":
					case "zm_theater_teleport":
					case "zm_tomb_in_plain_sight":
					case "zm_transit_burn":
					case "zm_trap_electric":
					case "zm_waterfall_postfx":
					case "zm_zod_transported":
					case "zod_ritual_dim":
					case "zombie_beast_2":
					case "zombie_cosmodrome_blackhole":
					case "zombie_death":
					case "zombie_last_stand":
					case "zombie_noire":
					case "zombie_turned":
						break;
					default:
						self add_option(vision.displayName, vision.name, &set_vision, vision.name);
				}
			}

			break;
		case "Give AAT":
			self add_menu(menu, menu.size);

			for(i = 0; i < self.syn["weapons"]["aats"][0].size; i++) {
				self add_option(self.syn["weapons"]["aats"][1][i], undefined, &give_aat, self.syn["weapons"]["aats"][0][i]);
			}

			break;
		case "Give Weapons":
			self add_menu(menu, menu.size);

			for(i = 0; i < self.syn["weapons"]["category"].size; i++) {
				self add_option(self.syn["weapons"]["category"][i], undefined, &new_menu, self.syn["weapons"]["category"][i]);
			}

			break;
		case "Assault Rifles":
			self add_menu(menu, menu.size);

			load_weapons("weapon_assault");

			break;
		case "Sub Machine Guns":
			self add_menu(menu, menu.size);

			load_weapons("weapon_smg");

			break;
		case "Light Machine Guns":
			self add_menu(menu, menu.size);

			load_weapons("weapon_lmg");

			break;
		case "Sniper Rifles":
			self add_menu(menu, menu.size);

			load_weapons("weapon_sniper");

			break;
		case "Shotguns":
			self add_menu(menu, menu.size);

			load_weapons("weapon_cqb");

			break;
		case "Pistols":
			self add_menu(menu, menu.size);

			load_weapons("weapon_pistol");

			break;
		case "Launchers":
			self add_menu(menu, menu.size);

			load_weapons("weapon_launcher");

			break;
		case "Extras":
			self add_menu(menu, menu.size);

			for(i = 0; i < self.syn["weapons"]["extras"][0].size; i++) {
				self add_option(self.syn["weapons"]["extras"][1][i], undefined, &give_weapon, self.syn["weapons"]["extras"][0][i]);
			}

			map = get_map_name();

			if(map == "soe" || map == "nzf" || map == "de" || map == "zns" || map == "gk" || map == "rev" || map == "nzp" || map == "nza" || map == "nzs" || map == "kino" || map == "ascen" || map == "shang" || map == "moon" || map == "origins") {
				for(i = 0; i < self.syn["weapons"]["extras"][map][0].size; i++) {
					self add_option(self.syn["weapons"]["extras"][map][1][i], undefined, &give_weapon, self.syn["weapons"]["extras"][map][0][i]);
				}
			}

			forEach(weapon in self.syn["weapons"][7]) {
				switch(weapon.id) {
					case "ar_famas":
					case "ar_galil":
					case "ar_m14":
					case "ar_m16":
					case "ar_peacekeeper":
					case "ar_standard_upgraded_companion":
					case "ar_stg44":
					case "beacon":
					case "black_hole_bomb":
					case "bouncingbetty":
					case "bouncingbetty_devil":
					case "bouncingbetty_holly":
					case "bowie_knife":
					case "bowie_knife_widows_wine":
					case "castle_riotshield":
					case "cymbal_monkey":
					case "cymbal_monkey_upgraded":
					case "defaultweapon":
					case "dragon_gauntlet_flamethrower":
					case "dragonshield":
					case "dragonshield_upgraded":
					case "elemental_bow":
					case "elemental_bow_demongate":
					case "elemental_bow_rune_prison":
					case "elemental_bow_storm":
					case "elemental_bow_wolf_howl":
					case "frag_grenade":
					case "glaive_apothicon_0":
					case "glaive_keeper_0":
					case "hero_annihilator":
					case "hero_gravityspikes":
					case "hero_gravityspikes_melee":
					case "hero_mirg2000":
					case "hero_mirg2000_upgraded":
					case "idgun_0":
					case "idgun_1":
					case "idgun_2":
					case "idgun_3":
					case "idgun_genesis_0":
					case "island_riotshield":
					case "knife":
					case "knife_widows_wine":
					case "launcher_dragon_fire":
					case "launcher_dragon_strike":
					case "launcher_multi":
					case "lmg_mg08":
					case "lmg_rpk":
					case "melee_boneglass":
					case "melee_dagger":
					case "melee_fireaxe":
					case "melee_improvise":
					case "melee_katana":
					case "melee_mace":
					case "melee_nunchuks":
					case "melee_sword":
					case "melee_wrench":
					case "microwavegundw":
					case "minigun":
					case "nesting_dolls":
					case "octobomb":
					case "octobomb_upgraded":
					case "pistol_c96":
					case "pistol_energy":
					case "pistol_standard":
					case "quantum_bomb":
					case "ray_gun":
					case "raygun_mark2":
					case "raygun_mark3":
					case "shotgun_energy":
					case "shrink_ray":
					case "sickle_knife":
					case "skull_gun":
					case "smg_longrange":
					case "smg_mp40_1940":
					case "smg_thompson":
					case "special_crossbow_dw":
					case "staff_air":
					case "staff_fire":
					case "staff_lightning":
					case "staff_water":
					case "staff_air_upgraded":
					case "staff_fire_upgraded":
					case "staff_lightning_upgraded":
					case "staff_water_upgraded":
					case "sticky_grenade_widows_wine":
					case "tesla_gun":
					case "thundergun":
					case "tomb_shield":
					case "zod_riotshield":
					case "zod_riotshield_upgraded_zm":
						break;
					default:
						self add_option(weapon.name, "ID: " + weapon.id + " | Category: " + weapon.category, &give_weapon, weapon.id);
				}
			}

			break;
		default:
			if(!isDefined(self.selected_player)) {
				self.selected_player = self;
			}

			self player_option(menu, self.selected_player);
			break;
	}
}

function player_option(menu, player) {
	if(!isDefined(menu) || !isDefined(player) || !isplayer(player)) {
		menu = "Error";
	}

	switch (menu) {
		case "Player Option":
			self add_menu(clean_name(player get_name()));
			break;
		case "Error":
			self add_menu();
			self add_option("Oops, Something Went Wrong!", "Condition: Undefined");
			break;
		default:
			error = true;
			if(error) {
				self add_menu("Critical Error");
				self add_option("Oops, Something Went Wrong!", "Condition: Menu Index");
			}
			break;
	}
}

// Misc Options

function return_toggle(variable) {
	return isDefined(variable) && variable;
}

function close_controls_menu() {
	if(isDefined(self.controls["title"])) {
		self.controls["title"] destroy();
		self.controls["separator"][0] destroy();
		self.controls["separator"][1] destroy();
		self.controls["border"] destroy();
		self.controls["background"] destroy();
		self.controls["foreground"] destroy();

		self.controls["text"][0] destroy();
		self.controls["text"][1] destroy();
		self.controls["text"][2] destroy();
		self.controls["text"][3] destroy();
	}
}

function get_map_name() {
	if(level.script == "zm_zod") return "soe";
	if(level.script == "zm_factory") return "nzf";
	if(level.script == "zm_castle") return "de";
	if(level.script == "zm_island") return "zns";
	if(level.script == "zm_stalingrad") return "gk";
	if(level.script == "zm_genesis") return "rev";
	if(level.script == "zm_prototype") return "nzp";
	if(level.script == "zm_asylum") return "nza";
	if(level.script == "zm_sumpf") return "nzs";
	if(level.script == "zm_theater") return "kino";
	if(level.script == "zm_cosmodrome") return "ascen";
	if(level.script == "zm_temple") return "shang";
	if(level.script == "zm_moon") return "moon";
	if(level.script == "zm_tomb") return "origins";
	if(level.script == "credits") return "cred";
}

function iPrintString(string) {
  if(!isDefined(self.syn["string"])) {
    self.syn["string"] = self create_text(string, "default", 1.5, "center", "top", 0, -115, (1,1,1), 1, 9999, false);
  } else {
    self.syn["string"] set_text(string);
  }
  self.syn["string"] notify("stop_hud_fade");
  self.syn["string"].alpha = 1;
  self.syn["string"] setText(string);
  self.syn["string"] thread fade_hud(0, 4);
}

function fade_hud(alpha, time) {
	self endon("stop_hud_fade");
	self fadeOverTime(time);
	self.alpha = alpha;
	wait time;
}

function construct_string(string) {
	final = "";
	for(e = 0; e < string.size; e++) {
		if(e == 0)
			final += toUpper(string[e]);
		else if(string[e - 1] == " ")
			final += toUpper(string[e]);
		else
			final += string[e];
	}
	return final;
}

function replace_character(string, substring, replace) {
	final = "";
	for(e = 0; e < string.size; e++) {
		if(string[e] == substring)
			final += replace;
		else
			final += string[e];
	}
	return final;
}

function remove_duplicate_ent_array(name) {
	new_array = [];
	saved_array = [];
	forEach(item in getEntArray(name, "targetname")) {
		if(!isInArray(new_array, item.script_noteworthy)) {
			new_array[new_array.size] = item.script_noteworthy;
			saved_array[saved_array.size] = item;
		}
	}
	return saved_array;
}

function set_increment(value) {
	self.point_increment = value;
}

function set_variable(check, option_1, option_2) {
	if(check) {
		return option_1;
	} else {
		return option_2;
	}
}

function load_weapons(weapon_category) {
	for(i = 0; i < self.syn["weapons"].size; i++) {
		forEach(weapon in self.syn["weapons"][i]) {
			if(weapon.category == weapon_category) {
				self add_option(weapon.name, undefined, &give_weapon, weapon.id);
			}
		}
	}
}

// Menu Options

function modify_menu_position(offset, axis) {
	if(axis == "x") {
		self.x_offset = 175 + offset;
	} else {
		self.y_offset = 160 + offset;
	}
	self close_menu();
	self open_menu();
}

function set_menu_rainbow() {
	if(!isString(self.color_theme)) {
		self.color_theme = "rainbow";
		self close_menu();
		self open_menu();
	}
}

function set_menu_color(value, color) {
	if(color == "Red") {
		self.menu_color_red = value;
		iPrintString(color + " Changed to " + value);
	} else if(color == "Green") {
		self.menu_color_green = value;
		iPrintString(color + " Changed to " + value);
	} else if(color == "Blue") {
		self.menu_color_blue = value;
		iPrintString(color + " Changed to " + value);
	} else {
		iPrintString(value + " | " + color);
	}
	self.color_theme = (self.menu_color_red / 255, self.menu_color_green / 255, self.menu_color_blue / 255);
	self close_menu();
	self open_menu();
}

function watermark() {
	self.watermark = !return_toggle(self.watermark);
	if(self.watermark) {
		iPrintString("Watermark [^2ON^7]");
		if(!isDefined(self.syn["watermark"])) {
			self.syn["watermark"] = self create_text("SyndiShanX", self.font, 2, "TOP_LEFT", "TOPCENTER", -425, 10, "rainbow", 1, 3);
		} else {
			self.syn["watermark"].alpha = 1;
		}
	} else {
		iPrintString("Watermark [^1OFF^7]");
		self.syn["watermark"].alpha = 0;
	}
}

function hide_ui() {
	self.hide_ui = !return_toggle(self.hide_ui);
	setDvar("\ui_enabled", !self.hide_ui);
	setDvar("\cg_draw2d", !self.hide_ui);
}

function hide_weapon() {
	self.hide_weapon = !return_toggle(self.hide_weapon);
	setDvar("\cg_drawgun", !self.hide_weapon);
}

// Basic Options

function god_mode() {
	self.god_mode = !return_toggle(self.god_mode);
	wait .01;
	if(self.god_mode) {
		iPrintString("God Mode [^2ON^7]");
		self enableInvulnerability();
		god_mode_loop();
	} else {
		iPrintString("God Mode [^1OFF^7]");
		self notify("stop_god_mode");
		self disableInvulnerability();
	}
}

function god_mode_loop() {
	self endOn("stop_god_mode");
	self endOn("game_ended");

	for(;;) {
		self enableInvulnerability();
		wait .1;
	}
}

function frag_no_clip() {
	self endon("disconnect");
	self endon("game_ended");

	if(!isDefined(self.frag_no_clip)) {
		self.frag_no_clip = true;
		iPrintString("Frag No Clip [^2ON^7], Press ^3[{+frag}]^7 to Enter and ^3[{+melee}]^7 to Exit");
		while (isDefined(self.frag_no_clip)) {
			if(self fragButtonPressed()) {
				if(!isDefined(self.frag_no_clip_loop)) {
					self thread frag_no_clip_loop();
				}
			}
			wait .05;
		}
	} else {
		self.frag_no_clip = undefined;
		iPrintString("Frag No Clip [^1OFF^7]");
	}
}

function frag_no_clip_loop() {
	self endon("disconnect");
	self endon("noclip_end");
	self disableWeapons();
	self disableOffHandWeapons();
	self.frag_no_clip_loop = true;

	clip = spawn("script_origin", self.origin);
	self playerLinkTo(clip);
	if(!isDefined(self.god_mode) || !self.god_mode) {
		self enableInvulnerability();
		self.temp_god_mode = true;
	}

	while (true) {
		vec = anglesToForward(self getPlayerAngles());
		end = (vec[0] * 60, vec[1] * 60, vec[2] * 60);
		if(self attackButtonPressed()) {
			clip.origin = clip.origin + end;
		}
		if(self adsButtonPressed()) {
			clip.origin = clip.origin - end;
		}
		if(self meleeButtonPressed()) {
			break;
		}
		wait .05;
	}

	clip delete();
	self enableWeapons();
	self enableOffhandWeapons();

	if(isDefined(self.temp_god_mode)) {
		self disableInvulnerability();
		self.temp_god_mode = undefined;
	}

	self.frag_no_clip_loop = undefined;
}

function infinite_ammo() {
	self.infinite_ammo = !return_toggle(self.infinite_ammo);
	if(self.infinite_ammo) {
		iPrintString("Infinite Ammo [^2ON^7]");
		self thread infinite_ammo_loop();
	} else {
		iPrintString("Infinite Ammo [^1OFF^7]");
		self notify("stop_infinite_ammo");
	}
}

function infinite_ammo_loop() {
	self endOn("stop_infinite_ammo");
	self endOn("game_ended");

	for(;;) {
		weapons = self getWeaponsList();
		for(i = 0; i < weapons.size; i++) {
			self giveMaxAmmo(weapons[i]);
		}
		self setWeaponAmmoClip(self getCurrentWeapon(), 999);
		self gadgetPowerSet(0, 100);
		wait .05;
	}
}

function infinite_shield() {
	self.infinite_shield = !return_toggle(self.infinite_shield);
	if(self.infinite_shield) {
		iPrintString("Infinite Shield [^2ON^7]");
		self thread infinite_shield_loop();
	} else {
		iPrintString("Infinite Shield [^1OFF^7]");
		self notify("stop_infinite_shield");
	}
}

function infinite_shield_loop() {
	self endOn("stop_infinite_shield");
	self endOn("game_ended");

	for(;;) {
		self [[self.player_shield_reset_health]]();
		wait 2.5;
	}
}

function get_perk_name(perk) {
	for(i = 0; i < self.syn["perks"]["common"][0].size; i++) {
		if(perk == self.syn["perks"]["common"][0][i]) {
			return self.syn["perks"]["common"][1][i];
		}
	}
	return perk;
}

function give_perk(perk) {
	if(!self hasPerk(perk)) {
		self setPerk(perk);
		self zm_perks::vending_trigger_post_think(self, perk);
	}
}

function take_perk(perk) {
	if(self hasPerk(perk)) {
		self notify(perk + "_stop");
	}
}

function give_perkaholic() {
	self zm_utility::give_player_all_perks();
}

function get_gobblegum_name(gobblegum) {
	for(i = 0; i < self.syn["gobblegum"][0].size; i++) {
		if(gobblegum == self.syn["gobblegum"][0][i]) {
			return self.syn["gobblegum"][1][i];
		}
	}
	return gobblegum;
}

function give_gobblegum(gobblegum) {
	saved_weapon = self getCurrentWeapon();
	weapon = getWeapon("zombie_bgb_grab");
	self giveWeapon(weapon, self calcWeaponOptions(level.bgb[gobblegum].camo_index, 0, 0));
	self switchToWeapon(weapon);
	self playSound("zmb_bgb_powerup_default");

	event = self util::waittill_any_return("fake_death", "death", "player_downed", "weapon_change_complete", "disconnect");
	if(event == "weapon_change_complete") {
		self takeWeapon(weapon);
		self zm_weapons::switch_back_primary_weapon(saved_weapon);
		bgb::give(gobblegum);
	}
}

function set_points(value) {
	self zm_score::minus_to_player_score(9999999);
	self zm_score::add_to_player_score(value);
}

function add_points(value) {
	self zm_score::add_to_player_score(value);
}

function take_points(value) {
	self zm_score::minus_to_player_score(value);
}

// Fun Options

function forge_mode() {
	self.forge_mode = !return_toggle(self.forge_mode);
	if(self.forge_mode) {
		iPrintString("Forge Mode [^2ON^7], Press ^3[{+speed_throw}]^7 to Pick Up/Drop Objects");
		self thread forge_mode_loop();
	} else {
		iPrintString("Forge Mode [^1OFF^7]");
		self notify("stop_forge_mode");
	}
}

function forge_mode_loop() {
	self endOn("disconnect");
	self endOn("stop_forge_mode");

	while (true) {
		trace = beamTrace(self getTagOrigin("j_head"), self getTagOrigin("j_head") + anglesToForward(self getPlayerAngles()) * 1000000, 1, self);
		if(isDefined(trace["entity"])) {
			if(self adsButtonPressed()) {
				while (self adsButtonPressed()) {
					trace["entity"] forceTeleport(self getTagOrigin("j_head") + anglesToForward(self getPlayerAngles()) * 200);
					trace["entity"].origin = self getTagOrigin("j_head") + anglesToForward(self getPlayerAngles()) * 200;
					wait .01;
				}
			}
			if(self attackButtonPressed()) {
				while (self attackButtonPressed()) {
					trace["entity"] rotatePitch(1, .01);
					wait .01;
				}
			}
			if(self fragButtonPressed()) {
				while (self fragButtonPressed()) {
					trace["entity"] rotateYaw(1, .01);
					wait .01;
				}
			}
			if(self secondaryOffhandButtonPressed()) {
				while (self secondaryOffhandButtonPressed()) {
					trace["entity"] rotateRoll(1, .01);
					wait .01;
				}
			}
			if(!isPlayer(trace["entity"]) && self meleeButtonPressed()) {
				trace["entity"] delete();
				wait .2;
			}
		}
		wait .05;
	}
}

function exo_movement() {
	self.exo_movement = !return_toggle(self.exo_movement);
	if(self.exo_movement) {
		iPrintString("Exo Movement [^2ON^7]");
		setDvar("doublejump_enabled", 1);
		setDvar("juke_enabled", 1);
		setDvar("playerEnergy_enabled", 1);
		setDvar("wallrun_enabled", 1);
		setDvar("sprintLeap_enabled", 1);
		setDvar("traverse_mode", 1);
		setDvar("weaponrest_enabled", 1);
	} else {
		iPrintString("Exo Movement [^1OFF^7]");
		setDvar("doublejump_enabled", 0);
		setDvar("juke_enabled", 0);
		setDvar("playerEnergy_enabled", 0);
		setDvar("wallrun_enabled", 0);
		setDvar("sprintLeap_enabled", 0);
		setDvar("traverse_mode", 0);
		setDvar("weaponrest_enabled", 0);
	}
}

function infinite_boost() {
	if(self.exo_movement) {
		self.infinite_boost = !return_toggle(self.infinite_boost);
		if(self.infinite_boost) {
			iPrintString("Infinite Boost [^2ON^7]");
			self thread infinite_boost_loop();
		} else {
			iPrintString("Infinite Boost [^1OFF^7]");
			self notify("stop_infinite_boost");
		}
	}
}

function infinite_boost_loop() {
	self endOn("stop_infinite_boost");
	self endOn("game_ended");

	for(;;) {
		self setDoubleJumpEnergy(100);
		wait .1;
	}
}

function set_speed(value) {
	if(value == 1) {
		self.movement_speed = undefined;
	}
	self setMoveSpeedScale(value);
}

function set_timescale(value) {
	setDvar("timescale", value);
}

function set_gravity(value) {
	setDvar("bg_gravity", value);
	if(value < 900) {
		self clientField::set("low_gravity", 1);
	} else {
		self clientField::set("low_gravity", 0);
	}
}

function third_person() {
	self.third_person = !return_toggle(self.third_person);
	if(self.third_person) {
		iPrintString("Third Person [^2ON^7]");
		self setClientThirdPerson(1);
		self setClientThirdPersonAngle(354);
		self setDepthOfField(0, 128, 512, 4000, 6, 1.8);
	} else {
		iPrintString("Third Person [^1OFF^7]");
		self setClientThirdPerson(0);
		self setClientThirdPersonAngle(0);
		self setDepthOfField(0, 0, 512, 4000, 4, 0);
	}
	self resetFov();
}

function set_vision(vision) {
	if(isDefined(self.prev_vision)) {
		visionset_mgr::deactivate("visionset", self.prev_vision, self);
		visionset_mgr::deactivate("overlay", self.prev_vision, self);
		wait .25;
	}
	visionset_mgr::activate("visionset", vision, self);
	visionset_mgr::activate("overlay", vision, self);
	self.prev_vision = vision;
}

// Map Options

function freeze_box() {
	self.freeze_box = !return_toggle(self.freeze_box);
	if(self.freeze_box) {
		iPrintString("Freeze Box [^2ON^7]");
		wait 5;
		level.chest_min_move_usage = 999;
	} else {
		iPrintString("Freeze Box [^1OFF^7]");
		wait 5;
		level.chest_min_move_usage = undefined;
	}
}

function open_doors() {
	types = array("zombie_door", "zombie_airlock_buy", "zombie_debris", "zombie_airlock_hackable", "zombie_door_airlock", "electric_buyable_door", "electric_door");
	forEach(type in types) {
		zombie_doors = getEntArray(type, "targetname");
		forEach(door in zombie_doors) {
			if(type == "zombie_debris") {
        door.zombie_cost = 0;
        door notify("trigger", self);
      } else if(door._door_open != true) {
        door thread zm_blockers::door_opened(door.zombie_cost, 0);
        door._door_open = true;

        all_trigs = getEntArray(door.target, "target");
        foreach(trig in all_trigs) {
					trig zm_utility::set_hint_string(trig, "");
				}
      }
		}
	}
}

function get_power_trigger() {
	presets = array("elec", "power", "master");
	forEach(preset in presets) {
		trigger = getEnt("use_" + preset + "_switch", "targetname");
		if(isDefined(trigger)) {
			return trigger;
		}
	}
	return false;
}

function power_on() {
	if(get_map_name() == "rev") {
		for(i = 1; i < 5; i++) {
			level flag::set("power_on" + i);
		}
		level flag::set("all_power_on");
		waitTillFrameEnd;

		while(!level flag::get("apothicon_near_trap")) {
			wait .1;
		}
		trigger = struct::get("apothicon_trap_trig", "targetName");
		trigger notify("trigger_activated", self);
		return;
	}
	if(get_map_name() == "shang") {
		directions = array("power_trigger_left", "power_trigger_right");
		forEach(direction in directions) {
			switch_trigger = getEnt("power_trigger_" + direction, "targetName");
			switch_trigger notify("trigger", self);
		}
		return;
	}
	trigger = get_power_trigger();
	trigger notify("trigger", self);
}

function shock_all_electrics() {
	for(e = 0; e < 50; e++) {
		if(isDefined(level flag::get("power_on" + e))) {
			level flag::set("power_on" + e);
		}
	}
}

function restart_match() {
	self notify("menuResponse", "", "restart_level_zm");
}

// Powerup Options

function spawn_powerup(powerup) {
	zm_powerups::specific_powerup_drop(powerup, self.origin + anglesToForward(self.angles) * 115);
}

function shoot_powerups() {
	self.shoot_powerups = !return_toggle(self.shoot_powerups);
	if(self.shoot_powerups) {
		iPrintString("Shoot Powerups [^2ON^7]");
		shoot_powerups_loop();
	} else {
		iPrintString("Shoot Powerups [^1OFF^7]");
		self notify("stop_shoot_powerups");
	}
}

function shoot_powerups_loop() {
	self endOn("stop_shoot_powerups");
	self endOn("game_ended");

	for(;;) {
		while(self attackButtonPressed()) {
			powerup = self.syn["powerups"][0][randomint(self.syn["powerups"][0].size)];
			zm_powerups::specific_powerup_drop(powerup, self.origin + anglesToForward(self.angles) * 115);
			wait .5;
		}
		wait .05;
	}
}

// Weapon Options

function give_packed_weapon() {
	self.give_packed_weapon = !return_toggle(self.give_packed_weapon);
}

function give_weapon(weapon) {
	weapon = getWeapon(weapon);

	if(isDefined(self.give_packed_weapon) && self.give_packed_weapon == 1) {
		if(zm_weapons::can_upgrade_weapon(weapon)) {
			weapon = level.zombie_weapons[weapon].upgrade;
		}
	}

	if(!self hasWeapon(weapon)) {
		max_weapon_num = zm_utility::get_player_weapon_limit(self);

		switch(weapon) {
			case "beacon":
			case "black_hole_bomb":
			case "bowie_knife":
			case "bowie_knife_widows_wine":
			case "bouncingbetty":
			case "bouncingbetty_devil":
			case "bouncingbetty_holly":
			case "castle_riotshield":
			case "cymbal_monkey":
			case "cymbal_monkey_upgraded":
			case "dragon_gauntlet_flamethrower":
			case "dragonshield":
			case "dragonshield_upgraded":
			case "frag_grenade":
			case "glaive_apothicon_0":
			case "glaive_keeper_0":
			case "hero_annihilator":
			case "hero_gravityspikes":
			case "hero_gravityspikes_melee":
			case "island_riotshield":
			case "launcher_dragon_strike":
			case "knife":
			case "knife_widows_wine":
			case "nesting_dolls":
			case "octobomb":
			case "octobomb_upgraded":
			case "quantum_bomb":
			case "sickle_knife":
			case "skull_gun":
			case "sticky_grenade_widows_wine":
			case "tomb_shield":
			case "zod_riotshield":
			case "zod_riotshield_upgraded":
				saved_weapon = self getCurrentWeapon();
				self takeWeapon(self getCurrentWeapon());
				break;
			default:
				if(self getWeaponsListPrimaries().size >= max_weapon_num) {
					self takeWeapon(self getCurrentWeapon());
				}
				break;
		}

		self zm_weapons::weapon_give(weapon, undefined, undefined, undefined, true);

		if(isDefined(saved_weapon)) {
			wait .5;
			self zm_weapons::weapon_give(saved_weapon, undefined, undefined, undefined, true);
			saved_weapon = undefined;
			self switchToWeaponImmediate(saved_weapon);
		}
	} else {
		self switchToWeaponImmediate(weapon);
	}
	wait .5;
	self giveStartAmmo(weapon);
}

function give_aat(value) {
	weapon = self getCurrentWeapon();
	self thread aat::acquire(weapon, value);
}

function take_weapon() {
	self takeWeapon(self getCurrentWeapon());
	self switchToWeapon(self getWeaponsListPrimaries()[1]);
}

function drop_weapon() {
	self dropitem(self getCurrentWeapon());
}

// Zombie Options

function no_target() {
	self.no_target = !return_toggle(self.no_target);
	if(self.no_target) {
		iPrintString("No Target [^2ON^7]");
		self zm_utility::increment_ignoreMe();
	} else {
		iPrintString("No Target [^1OFF^7]");
		self zm_utility::decrement_ignoreMe();
	}
}

function set_round(value) {
	self thread zm_utility::zombie_goto_round(value);
}

function get_zombies() {
	return getaiteamarray(level.zombie_team);
}

function kill_all_zombies() {
	level.zombie_total = 0;
	forEach(zombie in get_zombies()) {
		zombie doDamage(zombie.health * 5000, (0, 0, 0), self);
		wait 0.05;
	}
}

function teleport_zombies() {
	forEach(zombie in get_zombies()) {
		zombie forceTeleport(self.origin + anglesToForward(self.angles) * 115);
	}
}

function one_shot_zombies() {
	if(!isDefined(self.one_shot_zombies)) {
		iPrintString("One Shot Zombies [^2ON^7]");
		self.one_shot_zombies = true;
		zombies = get_zombies();
		level.prev_health = zombies[0].health;
		while(isDefined(self.one_shot_zombies)) {
			forEach(zombie in get_zombies()) {
				zombie.maxHealth = 1;
				zombie.health = zombie.maxHealth;
			}
			wait 0.01;
		}
	} else {
		iPrintString("One Shot Zombies [^1OFF^7]");
		self.one_shot_zombies = undefined;
		forEach(zombie in get_zombies()) {
			zombie.maxHealth = level.prev_health;
			zombie.health = level.prev_health;
		}
	}
}

function set_zombie_health_cap() {
	if(!isDefined(self.zombie_health_cap)) {
		iPrintString("Round 60+ Health Cap [^2ON^7]");
		self.zombie_health_cap = true;
		while(isDefined(self.zombie_health_cap)) {
			forEach(zombie in get_zombies()) {
				if(zombie.maxHealth > 122086) {
					level.zombie_health = 122086;
					zombie.maxHealth = 122086;
				}
				if(zombie.health > 122086) {
					zombie.health = 122086;
				}
			}
			wait 0.01;
		}
	} else {
		iPrintString("Round 60+ Health Cap [^1OFF^7]");
		self.zombie_health_cap = undefined;
		level.zombie_health = level.zombie_vars["zombie_health_start"];
		forEach(zombie in get_zombies()) {
			zombie.maxHealth = level.zombie_vars["zombie_health_start"];
			zombie.health = level.zombie_vars["zombie_health_start"];
		}
		zombie_utility::ai_calculate_health(level.round_number);
	}
}

function slow_zombies() {
	if(!isDefined(self.slow_zombies)) {
		iPrintString("Slow Zombies [^2ON^7]");
		self.slow_zombies = true;
		while(isDefined(self.slow_zombies)) {
			forEach(zombie in get_zombies()) {
				zombie.b_widows_wine_slow = 1;
				zombie asmSetAnimationRate(0.7);
				zombie clientField::set("widows_wine_wrapping", 1);
			}
			wait 0.1;
		}
	} else {
		iPrintString("Slow Zombies [^1OFF^7]");
		self.slow_zombies = undefined;
		forEach(zombie in get_zombies()) {
			zombie.b_widows_wine_slow = 0;
			zombie asmSetAnimationRate(1);
			zombie clientField::set("widows_wine_wrapping", 0);
		}
	}
}

function disable_spawns() {
	self.disable_spawns = !return_toggle(self.disable_spawns);
	if(self.disable_spawns) {
		iPrintString("Disable Spawns [^2ON^7]");
		level flag::clear("spawn_zombies");
	} else {
		iPrintString("Disable Spawns [^1OFF^7]");
		level flag::set("spawn_zombies");
	}
}

function set_zombie_speed(value) {
	speed = toLower(value);

	if(!isDefined(self.zombie_speed)) {
		self.zombie_speed = true;
		while(isDefined(self.zombie_speed)) {
			forEach(zombie in get_zombies()) {
				zombie.zombie_move_speed = speed;
				wait .01;
			}
			wait .1;
		}
	} else {
		self.zombie_speed = undefined;
		if(level.gamedifficulty == 0) {
      level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier_easy"];
    } else {
      level.zombie_move_speed = level.round_number * level.zombie_vars["zombie_move_speed_multiplier"];
    }
	}
}

function outline_zombies(color) {
	if(color == "None") {
		value = 0;
	} else if(color == "Orange") {
		value = 1;
	} else if(color == "Green") {
		value = 2;
	} else if(color == "Purple") {
		value = 3;
	} else if(color == "Blue") {
		value = 4;
	}
	self thread clientField::set_to_player("eye_candy_render", value);
}