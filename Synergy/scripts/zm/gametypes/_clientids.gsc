#using scripts\codescripts\struct;

#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\math_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\hud_message_shared;
#using scripts\shared\hud_shared;
#using scripts\shared\array_shared;
#using scripts\shared\aat_shared;
#using scripts\shared\rank_shared;
#using scripts\shared\ai\zombie_utility;
#using scripts\shared\ai\systems\gib;
#using scripts\shared\tweakables_shared;
#using scripts\shared\ai\systems\shared;
#using scripts\shared\ai\systems\blackboard;
#using scripts\shared\ai\systems\ai_interface;
#using scripts\shared\flag_shared;
#using scripts\shared\scoreevents_shared;
#using scripts\shared\audio_shared;
#using scripts\shared\music_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\vehicle_ai_shared;
#using scripts\shared\vehicle_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\ai_shared;
#using scripts\shared\doors_shared;
#using scripts\shared\gameskill_shared;
#using scripts\shared\weapons_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\spawner_shared;
#using scripts\shared\visionset_mgr_shared;
#using scripts\shared\laststand_shared;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_zonemgr;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_magicbox;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_power;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_blockers;
#using scripts\zm\_zm;
#using scripts\zm\gametypes\_globallogic;
#using scripts\zm\gametypes\_globallogic_score;
#using scripts\zm\_zm_weapons;
#using scripts\zm\craftables\_zm_craftables;
#using scripts\shared\ai\zombie_death;
#using scripts\shared\ai\zombie_shared;
#using scripts\zm\_zm_unitrigger;
#using scripts\zm\_zm_traps;
#using scripts\zm\_util;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_melee_weapon;

#insert scripts\shared\shared.gsh;

#namespace clientids;

REGISTER_SYSTEM("clientids", &__init__, undefined)
	
function __init__() {
	callback::on_start_gametype(&init);
	callback::on_connect(&on_player_connect);
	callback::on_spawned(&on_player_spawned); 
}	

function init() {
	setup();
}

function return_toggle(variable) {
	return isDefined(variable) && variable;
}

function really_alive() {
	return isAlive(self) && !return_toggle(self.lastStand);
}

function get_menu() {
	return self.syn["menu"];
}

function get_cursor() {
	return self.cursor[self get_menu()];
}

function get_title() {
	return self.syn["title"];
}

function set_menu(menu) {
	if(isDefined(menu)) {
		self.syn["menu"] = menu;
	}
}

function set_cursor(cursor, menu) {
	if(isDefined(cursor)) {
		if(isDefined(menu)) {
			self.cursor[menu] = cursor;
		} else {
			self.cursor[self get_menu()] = cursor;
		}
	}
}

function set_title(title) {
	if(isDefined(title)) {
		self.syn["title"] = title;
	}
}

function has_menu() {
	return return_toggle(self.syn["user"].has_menu);
}

function in_menu() {
	return return_toggle(self.syn["utility"].in_menu);
}

function set_state() {
	self.syn["utility"].in_menu = !return_toggle(self.syn["utility"].in_menu);
}

function execute_function(func, argument_1, argument_2, argument_3, argument_4) {
	if(!isDefined(func)) {
		return;
	}
	
	if(isDefined(argument_4)) {
		return self thread [[func]](argument_1, argument_2, argument_3, argument_4);
	}
	
	if(isDefined(argument_3)) {
		return self thread [[func]](argument_1, argument_2, argument_3);
	}
	
	if(isDefined(argument_2)) {
		return self thread [[func]](argument_1, argument_2);
	}
	
	if(isDefined(argument_1)) {
		return self thread [[func]](argument_1);
	}
	
	return self thread [[func]]();
}

function set_slider(scrolling, index) {
	menu = self get_menu();
	if(!isDefined(index)) {
		index = self get_cursor();
	}
	storage = (menu + "_" + index);
	if(!isDefined(self.slider[storage])) {
		if(isDefined(self.structure[index].array)) {
			self.slider[storage] = 0;
		} else {
			self.slider[storage] = self.structure[index].start;
		}
	}
	
	if(!isDefined(self.structure[index].array)) {
		self notify("increment_slider");
		if(scrolling == -1)
			self.slider[storage] += self.structure[index].increment;
		
		if(scrolling == 1)
			self.slider[storage] -= self.structure[index].increment;
		
		if(self.slider[storage] > self.structure[index].maximum)
			self.slider[storage] = self.structure[index].minimum;
		
		if(self.slider[storage] < self.structure[index].minimum)
			self.slider[storage] = self.structure[index].maximum;
		
		position = abs((self.structure[index].maximum - self.structure[index].minimum)) / ((50 - 8));
		
		if(!self.structure[index].text_slider) {
			self.syn["hud"]["slider"][0][index] setValue(self.slider[storage]);
		} else {
			self.syn["hud"]["slider"][0][index].x = self.syn["utility"].x_offset + 85;
		}
		self.syn["hud"]["slider"][2][index].x = (self.syn["hud"]["slider"][1][index].x + (abs((self.slider[storage] - self.structure[index].minimum)) / position));
	}
}

function clear_option() {
	clear_all(self.syn["hud"]["text"]);
	clear_all(self.syn["hud"]["subMenu"]);
	clear_all(self.syn["hud"]["toggle"]);
	clear_all(self.syn["hud"]["category"]);
	clear_all(self.syn["hud"]["slider"]);
	self.syn["hud"]["text"] = [];
	self.syn["hud"]["subMenu"] = [];
	self.syn["hud"]["toggle"] = [];
	self.syn["hud"]["category"] = [];
	self.syn["hud"]["slider"] = [];
}

function check_option(player, menu, cursor) {
	if(isDefined(self.structure) && self.structure.size) {
		for(i = 0; i < self.structure.size; i++) {
			if(player.structure[cursor].text == self.structure[i].text && self get_menu() == menu) {
				return true;
			}
		}
	}

	return false;
}

function fade_hud(alpha, time) {
	self endon("stop_hud_fade");
	self fadeOverTime(time);
	self.alpha = alpha;
	wait time;
}

function create_text(text, font, font_scale, align_x, align_y, x, y, color, alpha, z_index, hide_when_in_menu, archive) {
	textElement = self hud::createFontString(font, font_scale);
	textElement.alpha = alpha;
	textElement.sort = z_index;
	textElement.foreground = true;
	
	if(isDefined(hide_when_in_menu)) {
		textElement.hidewheninmenu = hide_when_in_menu;
	} else {
		textElement.hidewheninmenu = true;
	}
	
	if(isDefined(archive)) {
		textElement.archived = archive;
	} else {
		textElement.archived = false;
	}
	
	if(color != "rainbow") {
		textElement.color = color;
	} else {
		textElement.color = level.rainbow_color;
		textElement thread start_rainbow();
	}
	
	textElement hud::setPoint(align_x, align_y, x, y);
	
	if(strisnumber(text)) {
		textElement setValue(text);
	} else {
		textElement set_text(text);
	}
	
	return textElement;
}

function set_text(text) {
	if(!isDefined(self) || !isDefined(text)) {
		return;
	}
	
	self.text = text;
	self setText(text);
}

function create_shader(shader, align_x, align_y, x, y, width, height, color, alpha, z_index) {
	shaderElement = hud::createIcon(shader, width, height);
	shaderElement.elemType = "icon";
	shaderElement.children = [];
	shaderElement.alpha = alpha;
	shaderElement.sort = z_index;
	shaderElement.archived = true;
	shaderElement.foreground = true;
	shaderElement.hidden = false;
	shaderElement.hideWhenInMenu = true;
	
	if(color != "rainbow") {
		shaderElement.color = color;
	} else {
		shaderElement.color = level.rainbow_color;
		shaderElement thread start_rainbow();
	}
	
	shaderElement hud::setPoint(align_x, align_y, x, y);
	
	return shaderElement;
}

function clear_all(array) {
	if(!isDefined(array)) {
		return;
	}
	
	keys = getArrayKeys(array);
	for(a = 0; a < keys.size; a++) {
		if(isArray(array[keys[a]])) {
			forEach(value in array[keys[a]])
				if(isDefined(value)) {
					value destroy();
				}
		} else {
			if(isDefined(array[keys[a]])) {
				array[keys[a]] destroy();
			}
		}
	}
}

function add_menu(title, menu_size, extra) {
	if(isDefined(title)) {
		self set_title(title);
		if(isDefined(extra)) {
			self.syn["hud"]["title"][0].x = self.syn["utility"].x_offset + 86 - menu_size - extra;
		} else {
			self.syn["hud"]["title"][0].x = self.syn["utility"].x_offset + 86 - menu_size;
		}
	}

	self.structure = [];
}

function add_option(text, func, argument_1, argument_2, argument_3) {
	option = spawnStruct();
	option.text = text;
	option.func = func;
	option.argument_1 = argument_1;
	option.argument_2 = argument_2;
	option.argument_3 = argument_3;
	
	self.structure[self.structure.size] = option;
}

function add_toggle(text, func, toggle, array, argument_1, argument_2, argument_3) {
	option = spawnStruct();
	option.text = text;
	option.func = func;
	option.toggle = return_toggle(toggle);
	option.argument_1 = argument_1;
	option.argument_2 = argument_2;
	option.argument_3 = argument_3;
	
	if(isDefined(array)) {
		option.slider = true;
		option.array  = array;
	}
	
	self.structure[self.structure.size] = option;
}

function add_string(text, func, array, argument_1, argument_2, argument_3) {
	option = spawnStruct();
	option.text = text;
	option.func = func;
	option.slider = true;
	option.array = array;
	option.argument_1 = argument_1;
	option.argument_2 = argument_2;
	option.argument_3 = argument_3;
	
	self.structure[self.structure.size] = option;
}

function add_increment(text, func, start, minimum, maximum, increment, text_slider, slider_text, argument_1, argument_2, argument_3) {
	option = spawnStruct();
	option.text = text;
	option.func = func;
	option.slider = true;
	option.text_slider = text_slider;
	option.slider_text = slider_text;
	option.start = start;
	option.minimum = minimum;
	option.maximum = maximum;
	option.increment = increment;
	option.argument_1 = argument_1;
	option.argument_2 = argument_2;
	option.argument_3 = argument_3;
	
	self.structure[self.structure.size] = option;
}

function add_category(text) {
	option = spawnStruct();
	option.text = text;
	option.category = true;
	
	self.structure[self.structure.size] = option;
}

function new_menu(menu) {
	if(!isDefined(menu)) {
		menu = self.previous[(self.previous.size - 1)];
		self.previous[(self.previous.size - 1)] = undefined;
	} else {
		self.previous[self.previous.size] = self get_menu();
	}
	
	self set_menu(menu);
	self clear_option();
	self create_option();
}

function initial_variable() {
	self.syn["utility"] = spawnStruct();
	self.syn["utility"].font = "objective";
	self.syn["utility"].font_scale = 1;
	self.syn["utility"].option_limit = 10;
	self.syn["utility"].option_spacing = 14;
	self.syn["utility"].x_offset = 160;
	self.syn["utility"].y_offset = -60;
	self.syn["utility"].element_list = strTok("text|subMenu|toggle|category|slider", "|");

	self.syn["weapons"]["category"][0] = strTok("assault_rifles|sub_machine_guns|sniper_rifles|shotguns|light_machine_guns|pistols|launchers", "|");
	self.syn["weapons"]["category"][1] = strTok("Assault Rifles|Sub Machine Guns|Sniper Rifles|Shotguns|Light Machine Guns|Pistols|Launchers", "|");
	
	self.syn["weapons"]["assault_rifles"][0] =     strTok("ar_standard|ar_cqb|ar_accurate|ar_damage|ar_marksman|ar_longburst", "|");
	self.syn["weapons"]["sub_machine_guns"][0] =   strTok("smg_standard|smg_versatile|smg_capacity|smg_fastfire|smg_burst|smg_longrange", "|");
	self.syn["weapons"]["sniper_rifles"][0] =      strTok("sniper_fastsemi|sniper_fastbolt|sniper_powerbolt", "|");
	self.syn["weapons"]["shotguns"][0] =           strTok("shotgun_pump|shotgun_semiauto|shotgun_fullauto|shotgun_precision", "|");
	self.syn["weapons"]["light_machine_guns"][0] = strTok("lmg_light|lmg_cqb|lmg_slowfire|lmg_heavy", "|");
	self.syn["weapons"]["pistols"][0] =            strTok("pistol_standard|pistol_burst|pistol_fullauto", "|");
	self.syn["weapons"]["launchers"][0] =          strTok("launcher_standard|", "|");
	
	self.syn["weapons"]["assault_rifles"][1] =     strTok("KN-44|HVK-30|ICR-1|Man-O-War|Sheiva|M8A7", "|");
	self.syn["weapons"]["sub_machine_guns"][1] =   strTok("Kuda|VMP|Weevil|Vesper|Pharo|Razorback", "|");
	self.syn["weapons"]["sniper_rifles"][1] =      strTok("Drakon|Locus|SVG-100", "|");
	self.syn["weapons"]["shotguns"][1] =           strTok("KRM-262|205 Brecci|Haymaker 12|Argus", "|");
	self.syn["weapons"]["light_machine_guns"][1] = strTok("BRM|Dingo|Gorgon|48 Dredge", "|");
	self.syn["weapons"]["pistols"][1] =            strTok("MR6|RK5|L-CAR 9", "|");
	self.syn["weapons"]["launchers"][1] =          strTok("XM-53|", "|");
	
	self.syn["weapons"]["aats"][0] = strTok("zm_aat_blast_furnace|zm_aat_dead_wire|zm_aat_fire_works|zm_aat_thunder_wall|zm_aat_turned", "|");
	self.syn["weapons"]["aats"][1] = strTok("Blast Furnace|Dead Wire|Fireworks|Thunder Wall|Turned", "|");
	
	self.syn["perks"]["common"][0] = strTok("specialty_quickrevive|specialty_armorvest|specialty_doubletap2|specialty_staminup|specialty_fastreload|specialty_additionalprimaryweapon|specialty_deadshot|specialty_widowswine|specialty_electriccherry|specialty_phdflopper|specialty_whoswho", "|");
	self.syn["perks"]["common"][1] = strTok("Quick Revive|Juggernog|Double Tap|Stamin-Up|Speed Cola|Mule Kick|Deadshot|Widow's Wine|Electric Cherry|PhD Slider|Who's Who", "|");
	
	self.syn["perks"]["all"] = getArrayKeys(level._custom_perks);
	
	self.syn["utility"].interaction = true;
	
	self.syn["utility"].color[0] = (0.752941176, 0.752941176, 0.752941176);
	self.syn["utility"].color[1] = (0.074509804, 0.070588235, 0.078431373);
	self.syn["utility"].color[2] = (0.074509804, 0.070588235, 0.078431373);
	self.syn["utility"].color[3] = (0.243137255, 0.22745098, 0.247058824);
	self.syn["utility"].color[4] = (1, 1, 1);
	self.syn["utility"].color[5] = "rainbow";
	
	self.cursor = [];
	self.previous = [];
	
	self set_menu("Synergy");
	self set_title(self get_menu());
}

function initial_monitor() {
	self endOn("disconnect");
	level endOn("game_ended");
	while(true) {
		if(self really_alive()) {
			if(!self in_menu()) {
				if(self adsButtonPressed() && self meleeButtonPressed()) {
					if(return_toggle(self.syn["utility"].interaction)) {
						self playSoundToPlayer("uin_main_bootup", self);
					}
					
					close_controls_menu();
					
					self open_menu();
					wait .15;
				}
			} else {
				menu = self get_menu();
				cursor = self get_cursor();
				if(self meleeButtonPressed()) {
					if(return_toggle(self.syn["utility"].interaction)) {
						self playSoundToPlayer("uin_lobby_leave", self);
					}
					
					if(isDefined(self.previous[(self.previous.size - 1)])) {
						self new_menu(self.previous[menu]);
					} else {
						self close_menu();
					}
					
					wait .75;
				}
				else if(self adsButtonPressed() && !self attackButtonPressed() || self attackButtonPressed() && !self adsButtonPressed()) {
					if(isDefined(self.structure) && self.structure.size >= 2) {
						if(return_toggle(self.syn["utility"].interaction)) {
							self playSoundToPlayer("uin_main_nav", self);
						}
						
						if(self attackButtonPressed()) {
							scrolling = 1;
						} else {
							scrolling = -1;
						}
						
						self set_cursor((cursor + scrolling));
						self update_scrolling(scrolling);
					}
					wait .25;
				}
				else if(self fragButtonPressed() && !self secondaryOffhandButtonPressed() || self secondaryOffhandButtonPressed() && !self fragButtonPressed()) {
					if(return_toggle(self.structure[cursor].slider)) {
						if(return_toggle(self.syn["utility"].interaction)) {
							self playSoundToPlayer("uin_main_nav", self);
						}
						
						if(self secondaryOffhandButtonPressed()) {
							scrolling = 1;
						} else {
							scrolling = -1;
						}
						
						self set_slider(scrolling);
					}
					wait .07;
				}
				else if(self useButtonPressed()) {
					if(isDefined(self.structure[cursor].func)) {
						if(return_toggle(self.syn["utility"].interaction)) {
							self playSoundToPlayer("uin_main_pause", self);
						}
						
						if(return_toggle(self.structure[cursor].slider)) {
							if(isDefined(self.structure[cursor].array)) {
								cursor_array = self.structure[cursor].array[self.slider[menu + "_" + cursor]];
							} else {
								cursor_array = self.slider[menu + "_" + cursor];
							}
							self thread execute_function(self.structure[cursor].func, cursor_array, self.structure[cursor].argument_1, self.structure[cursor].argument_2, self.structure[cursor].argument_3);
						} else {
							self thread execute_function(self.structure[cursor].func, self.structure[cursor].argument_1, self.structure[cursor].argument_2, self.structure[cursor].argument_3);
						}
						
						if(isDefined(self.structure[cursor].toggle)) {
							self update_menu(menu, cursor);
						}
					}
					wait .2;
				}
			}
		}
		wait .05;
	}
}

function open_menu(menu) {	
	if(!isDefined(menu)) {
		if(isDefined(self get_menu()) && self get_menu() != "Synergy") {
			menu = self get_menu();
		} else {
			menu = "Synergy";
		}
	}
	
	self.syn["hud"] = [];
	self.syn["hud"]["title"][0] = self create_text(self get_title(), self.syn["utility"].font, self.syn["utility"].font_scale, "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 86), (self.syn["utility"].y_offset + 2), self.syn["utility"].color[4], 1, 10);
	self.syn["hud"]["title"][1] = self create_text("______                                   ______", self.syn["utility"].font, self.syn["utility"].font_scale * 1.5, "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 4), (self.syn["utility"].y_offset - 4), self.syn["utility"].color[5], 1, 10);
	
	self.syn["hud"]["background"][0] = self create_shader("white", "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset - 1), (self.syn["utility"].y_offset - 1), 202, 30, self.syn["utility"].color[5], 1, 1);
	self.syn["hud"]["background"][1] = self create_shader("white", "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset), self.syn["utility"].y_offset, 200, 28, self.syn["utility"].color[1], 1, 2);
	self.syn["hud"]["foreground"][1] = self create_shader("white", "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset), (self.syn["utility"].y_offset + 14), 194, 14, self.syn["utility"].color[3], 1, 4);
	self.syn["hud"]["foreground"][2] = self create_shader("white", "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 195), (self.syn["utility"].y_offset + 14), 4, 14, self.syn["utility"].color[3], 1, 4);
	
	self set_menu(menu);
	self create_option();
	self set_state();
}

function close_menu() {
	self clear_option();
	self clear_all(self.syn["hud"]);
	self set_state();
}

function create_title(title) {
	if(isDefined(title)) {
		self.syn["hud"]["title"][0] set_text(title);
	} else {
		self.syn["hud"]["title"][0] set_text(self get_title());
	}
}

function create_option() {
	self clear_option();
	self menu_index();
	if(!isDefined(self.structure) || !self.structure.size) {
		self add_option("Currently No Options To Display");
	}
	
	if(!isDefined(self get_cursor())) {
		self set_cursor(0);
	}
	
	start = 0;
	if((self get_cursor() > int(((self.syn["utility"].option_limit - 1) / 2))) && (self get_cursor() < (self.structure.size - int(((self.syn["utility"].option_limit + 1) / 2)))) && (self.structure.size > self.syn["utility"].option_limit)) {
		start = (self get_cursor() - int((self.syn["utility"].option_limit - 1) / 2));
	}
	
	if((self get_cursor() > (self.structure.size - (int(((self.syn["utility"].option_limit + 1) / 2)) + 1))) && (self.structure.size > self.syn["utility"].option_limit)) {
		start = (self.structure.size - self.syn["utility"].option_limit);
	}
	
	self create_title();
	if(isDefined(self.structure) && self.structure.size) {
		limit = min(self.structure.size, self.syn["utility"].option_limit);
		for(i = 0; i < limit; i++) {
			index = (i + start);
			cursor = (self get_cursor() == index);
			if(cursor) {
				color[0] = self.syn["utility"].color[0];
			} else {
				color[0] = self.syn["utility"].color[4];
			}
			
			if(return_toggle(self.structure[index].toggle)) {
				if(cursor) {
					color[1] = self.syn["utility"].color[0];
				} else {
					color[1] = self.syn["utility"].color[4];
				}
			} else {
				if(cursor) {
					color[1] = self.syn["utility"].color[2];
				} else {
					color[1] = self.syn["utility"].color[3];
				}
			}
			
			if(isDefined(self.structure[index].func) && self.structure[index].func == &new_menu) {
				self.syn["hud"]["subMenu"][index] = self create_text(">", self.syn["utility"].font, self.syn["utility"].font_scale, "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 185), (self.syn["utility"].y_offset + ((i * self.syn["utility"].option_spacing) + 16)), self.syn["utility"].color[4], 1, 10);
			}
			
			if(isDefined(self.structure[index].toggle)) {
				self.syn["hud"]["toggle"][1][index] = self create_shader("white", "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 4), (self.syn["utility"].y_offset + ((i * self.syn["utility"].option_spacing) + 17)), 8, 8, color[1], 1, 10);
			}
			
			for(x = 0; x < 15; x++) {
				if(x != self get_cursor()) {
					if(isDefined(self.syn["hud"]["arrow"][0][x])) {
						self.syn["hud"]["arrow"][0][x] destroy();
						self.syn["hud"]["arrow"][1][x] destroy();
					}
				}
			}
			
			if(return_toggle(self.structure[index].slider)) {
				if(isDefined(self.structure[index].array)) {
					self.syn["hud"]["slider"][0][index] = self create_text(self.structure[index].array[self.slider[self get_menu() + "_" + index]], self.syn["utility"].font, self.syn["utility"].font_scale, "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 155), (self.syn["utility"].y_offset + ((i * self.syn["utility"].option_spacing) + 16)), color[0], 1, 10);
				} else {
					if(cursor) {
						self.syn["hud"]["slider"][0][index] = self create_text(self.slider[self get_menu() + "_" + index], self.syn["utility"].font, self.syn["utility"].font_scale, "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 155), (self.syn["utility"].y_offset + ((i * self.syn["utility"].option_spacing) + 16)), self.syn["utility"].color[4], 1, 10);
						self.syn["hud"]["arrow"][0][self get_cursor()] = self create_text("<", self.syn["utility"].font, self.syn["utility"].font_scale, "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 129), (self.syn["utility"].y_offset + ((i * self.syn["utility"].option_spacing) + 16)), self.syn["utility"].color[4], 1, 10);
						self.syn["hud"]["arrow"][1][self get_cursor()] = self create_text(">", self.syn["utility"].font, self.syn["utility"].font_scale, "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 185), (self.syn["utility"].y_offset + ((i * self.syn["utility"].option_spacing) + 16)), self.syn["utility"].color[4], 1, 10);
					} else {
						self.syn["hud"]["arrow"][0][index] destroy();
						self.syn["hud"]["arrow"][1][index] destroy();
					}
					
					if(cursor) {
						color_1 = self.syn["utility"].color[2];
						color_2 = self.syn["utility"].color[0];
					} else {
						color_1 = self.syn["utility"].color[1];
						color_2 = self.syn["utility"].color[3];
					}
					
					self.syn["hud"]["slider"][1][index] = self create_shader("white", "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 135), (self.syn["utility"].y_offset + ((i * self.syn["utility"].option_spacing) + 17)), 50, 8, color_1, 1, 8);
					self.syn["hud"]["slider"][2][index] = self create_shader("white", "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 149), (self.syn["utility"].y_offset + ((i * self.syn["utility"].option_spacing) + 17)), 8, 8, color_2, 1, 9);
				}
				
				self set_slider(undefined, index);
			}
			
			if(return_toggle(self.structure[index].category)) {
				self.syn["hud"]["category"][0][index] = self create_text(self.structure[index].text, self.syn["utility"].font, self.syn["utility"].font_scale, "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 88), (self.syn["utility"].y_offset + ((i * self.syn["utility"].option_spacing) + 17)), self.syn["utility"].color[0], 1, 10);
				self.syn["hud"]["category"][1][index] = self create_text("______                                   ______", self.syn["utility"].font, self.syn["utility"].font_scale * 1.5, "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 4), (self.syn["utility"].y_offset + ((i * self.syn["utility"].option_spacing) + 11)), self.syn["utility"].color[5], 1, 10);
			}
			else {
				if(return_toggle(self.shader_option[self get_menu()])) {
					if(isDefined(self.structure[index].text)) {
						shader = self.structure[index].text;
					} else {
						shader = "white";
					}
					
					if(isDefined(self.structure[index].argument_2)) {
						width = self.structure[index].argument_2;
					} else {
						width = 18;
					}
					
					if(isDefined(self.structure[index].argument_3)) {
						height = self.structure[index].argument_3;
					} else {
						height = 18;
					}
					
					if(isDefined(self.structure[index].argument_1)) {
						color = self.structure[index].argument_1;
					} else {
						color = (1, 1, 1);
					}
					
					if(cursor) {
						alpha = 1;
					} else {
						alpha = 0.2;
					}
					
					self.syn["hud"]["text"][index] = self create_shader(shader, "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + ((i * 20) - ((limit * 10) - 110))), (self.syn["utility"].y_offset + 27), width, height, color, alpha, 10);
				} else {
					if(return_toggle(self.structure[index].slider)) {
						text = self.structure[index].text + ":";
					} else {
						text = self.structure[index].text;
					}
					
					if(isDefined(self.structure[index].toggle)) {
						x_position = (self.syn["utility"].x_offset + 15);
					} else {
						x_position = (self.syn["utility"].x_offset + 4);
					}
					
					self.syn["hud"]["text"][index] = self create_text(text, self.syn["utility"].font, self.syn["utility"].font_scale, "TOP_LEFT", "CENTER", x_position, (self.syn["utility"].y_offset + ((i * self.syn["utility"].option_spacing) + 16)), color[0], 1, 10);
				}
			}
		}
		
		if(!isDefined(self.syn["hud"]["text"][self get_cursor()])) {
			self set_cursor((self.structure.size - 1));
		}
	}
	self update_resize();
}

function update_scrolling(scrolling) {	
	if(return_toggle(self.structure[self get_cursor()].category)) {
		self set_cursor((self get_cursor() + scrolling));
		return self update_scrolling(scrolling);
	}
	
	if((self.structure.size > self.syn["utility"].option_limit) || (self get_cursor() >= 0) || (self get_cursor() <= 0)) {
		if((self get_cursor() >= self.structure.size) || (self get_cursor() < 0)) {
			if((self get_cursor() >= self.structure.size)) {
				cursor_position = 0;
			} else {
				cursor_position = (self.structure.size - 1);
			}
			
			self set_cursor(cursor_position);
		}
		self create_option();
	}
	self update_resize();
}

function update_resize() {
	limit = min(self.structure.size, self.syn["utility"].option_limit);
	height = int((limit * self.syn["utility"].option_spacing));
	
	if(self.structure.size > self.syn["utility"].option_limit) {
		adjust = int(((94 / self.structure.size) * limit));
	} else {
		adjust = height;
	}
	
	position = (self.structure.size - 1) / (height - adjust);
	
	if(!return_toggle(self.shader_option[self get_menu()])) {
		if(!isDefined(self.syn["hud"]["foreground"][1])) {
			self.syn["hud"]["foreground"][1] = self create_shader("white", "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset), (self.syn["utility"].y_offset + 14), 194, 14, self.syn["utility"].color[3], 1, 4);
		}
		
		if(!isDefined(self.syn["hud"]["foreground"][2])) {
			self.syn["hud"]["foreground"][2] = self create_shader("white", "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 195), (self.syn["utility"].y_offset + 14), 4, 14, self.syn["utility"].color[3], 1, 4);
		}
	}
	
	self.syn["hud"]["background"][0] setShader("white", self.syn["hud"]["background"][0].width, (height + 16));
	self.syn["hud"]["background"][1] setShader("white", self.syn["hud"]["background"][1].width, (height + 14));
	self.syn["hud"]["foreground"][0] setShader("white", self.syn["hud"]["foreground"][0].width, height);
	self.syn["hud"]["foreground"][2] setShader("white", self.syn["hud"]["foreground"][2].width, adjust);
	
	if(isDefined(self.syn["hud"]["foreground"][1])) {
		self.syn["hud"]["foreground"][1].y = (self.syn["hud"]["text"][self get_cursor()].y - 2);
	}
	
	self.syn["hud"]["foreground"][2].y = (self.syn["utility"].y_offset + 14);
	if(self.structure.size > self.syn["utility"].option_limit) {
	    self.syn["hud"]["foreground"][2].y += (self get_cursor() / position);
	}
}

function update_menu(menu, cursor) {
	if(isDefined(menu) && !isDefined(cursor) || !isDefined(menu) && isDefined(cursor)) {
		return;
	}
	
	if(isDefined(menu) && isDefined(cursor)) {
		forEach(player in level.players) {
			if(!isDefined(player) || !player in_menu()) {
				continue;
			}
		
			if(player get_menu() == menu || self != player && player check_option(self, menu, cursor)) {
				if(isDefined(player.syn["hud"]["text"][cursor]) || player == self && player get_menu() == menu && isDefined(player.syn["hud"]["text"][cursor]) || self != player && player check_option(self, menu, cursor)) {
					player create_option();
				}
			}
		}
	} else {
		if(isDefined(self) && self in_menu()) {
			self create_option();
		}
	}
}

function create_rainbow_color() {
	x = 0; y = 0;
	r = 0; g = 0; b = 0;
	level.rainbow_color = (0, 0, 0);
	
	while(true) {
		if (y >= 0 && y < 258) {
			r = 255;
			g = 0;
			b = x;
		} else if (y >= 258 && y < 516) {
			r = 255 - x;
			g = 0;
			b = 255;
		} else if (y >= 516 && y < 774) {
			r = 0;
			g = x;
			b = 255;
		} else if (y >= 774 && y < 1032) {
			r = 0;
			g = 255;
			b = 255 - x;
		} else if (y >= 1032 && y < 1290) {
			r = x;
			g = 255;
			b = 0;
		} else if (y >= 1290 && y < 1545) {
			r = 255;
			g = 255 - x;
			b = 0;
		}
		
		x += 3;
		if (x > 255)
			x = 0;
		
		y += 3;
		if (y > 1545)
			y = 0;
		
		level.rainbow_color = (r/255, g/255, b/255);
		wait .05;
	}
}

function start_rainbow() {
	while(isDefined(self)) {
		self fadeOverTime(.05);
		self.color = level.rainbow_color;
		wait .05;
	}
}

function setup() {
	level thread on_player_connect();
	level thread create_rainbow_color();
}

function on_event() {
	self endOn("disconnect");
	self.syn = [];
	self.syn["user"] = spawnStruct();
	while (true) {
		if(!isDefined(self.syn["user"].has_menu)) {
			self.syn["user"].has_menu = true;
			
			self initial_variable();
			self thread initial_monitor();
		}
		break;
	}
}

function on_ended() {
	level waitTill("game_ended");
	if(self in_menu()) {
		self close_menu();
	}
}

function on_player_connect() {
	setDvar("sv_cheats", "1");
	setDvar("/developer", "2");
	self freezeControls(false);
}

function on_player_spawned() {
	level flag::wait_till("initial_blackscreen_passed");
	
	level.player_out_of_playable_area_monitor = false;
	
	self thread on_event();
	self thread on_ended();

	self.syn["controls-hud"] = [];
	self.syn["controls-hud"]["title"][0] = self create_text("Controls", self.syn["utility"].font, self.syn["utility"].font_scale, "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 86), (self.syn["utility"].y_offset + 2), self.syn["utility"].color[4], 1, 10);
	self.syn["controls-hud"]["title"][1] = self create_text("______                                   ______", self.syn["utility"].font, self.syn["utility"].font_scale * 1.5, "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 4), (self.syn["utility"].y_offset - 4), self.syn["utility"].color[5], 1, 10);
	
	self.syn["controls-hud"]["background"][0] = self create_shader("white", "TOP_LEFT", "CENTER", self.syn["utility"].x_offset - 1, (self.syn["utility"].y_offset - 1), 202, 97, self.syn["utility"].color[5], 1, 1);
	self.syn["controls-hud"]["background"][1] = self create_shader("white", "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset), self.syn["utility"].y_offset, 200, 95, self.syn["utility"].color[1], 1, 2);
	
	self.syn["controls-hud"]["controls"][0] = self create_text("Open: ^3[{+speed_throw}] ^7and ^3[{+melee}]", self.syn["utility"].font, self.syn["utility"].font_scale, "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 5), (self.syn["utility"].y_offset + 15), self.syn["utility"].color[4], 1, 10);
	self.syn["controls-hud"]["controls"][1] = self create_text("Scroll: ^3[{+speed_throw}] ^7and ^3[{+attack}]", self.syn["utility"].font, self.syn["utility"].font_scale, "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 5), (self.syn["utility"].y_offset + 35), self.syn["utility"].color[4], 1, 10);
	self.syn["controls-hud"]["controls"][2] = self create_text("Select: ^3[{+activate}] ^7Back: ^3[{+melee}]", self.syn["utility"].font, self.syn["utility"].font_scale, "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 5), (self.syn["utility"].y_offset + 55), self.syn["utility"].color[4], 1, 10);
	self.syn["controls-hud"]["controls"][3] = self create_text("Sliders: ^3[{+smoke}] ^7and ^3[{+frag}]", self.syn["utility"].font, self.syn["utility"].font_scale, "TOP_LEFT", "CENTER", (self.syn["utility"].x_offset + 5), (self.syn["utility"].y_offset + 75), self.syn["utility"].color[4], 1, 10);
	
	wait 8;
	
	close_controls_menu();
	self.syn["watermark"] = self create_text("SyndiShanX", "default", 2, "TOP_LEFT", "CENTER", -425, -240, "rainbow", 1, 3);
}

function close_controls_menu() {
	self.syn["controls-hud"] destroy();
	self.syn["controls-hud"]["title"][0] destroy();
	self.syn["controls-hud"]["title"][1] destroy();
	
	self.syn["controls-hud"]["background"][0] destroy();
	self.syn["controls-hud"]["background"][1] destroy();
	
	self.syn["controls-hud"]["controls"][0] destroy();
	self.syn["controls-hud"]["controls"][1] destroy();
	self.syn["controls-hud"]["controls"][2] destroy();
	self.syn["controls-hud"]["controls"][3] destroy();
}

function menu_index() {
	menu = self get_menu();
	if(!isDefined(menu)) {
		menu = "Empty Menu";
	}
	
	switch(menu) {
		case "Synergy":
			self add_menu(menu, menu.size, menu.size);
			
			self.syn["hud"]["title"][0].x = self.syn["utility"].x_offset + 86;
			
			self add_option("Basic Options", &new_menu, "Basic Options");
			self add_option("Fun Options", &new_menu, "Fun Options");
			self add_option("Weapon Options", &new_menu, "Weapon Options");
			self add_option("Zombie Options", &new_menu, "Zombie Options");
			self add_option("Menu Options", &new_menu, "Menu Options");
			
			break;
		case "Basic Options":
			self add_menu(menu, menu.size, 1);
			
			self add_toggle("God Mode", &god_mode, self.god_mode);
			self add_toggle("No Clip", &no_clip, self.no_clip);
			self add_toggle("UFO", &ufo_mode, self.ufo_mode);
			self add_toggle("Infinite Ammo", &infinite_ammo, self.infinite_ammo);
			self add_toggle("Infinite Shield", &infinite_shield, self.infinite_shield);
			
			self add_option("Give Perks", &new_menu, "Give Perks");
			self add_option("Take Perks", &new_menu, "Take Perks");
			self add_option("Give Perkaholic", &give_perkaholic);
			
			self add_increment("Set Points", &set_points, 100, 100, 100000, 100);
			
			self add_option("Off-Host Options", &new_menu, "Off-Host Options");
		
			break;
		case "Weapon Options":
			self add_menu(menu, menu.size);
			
			self add_option("Give Weapons", &new_menu, "Give Weapons");
			self add_toggle("Give Pack-a-Punched Weapons", &give_packed_weapon, self.give_packed_weapon);
			self add_option("Give AAT", &new_menu, "Give AAT");
			
			self add_option("Take Current Weapon", &take_weapon);
			self add_option("Drop Current Weapon", &drop_weapon);
			
			break;
		case "Fun Options":
			self add_menu(menu, menu.size);
			
			self add_toggle("Forge Mode", &forge_mode, self.forge_mode);
			self add_toggle("Exo Movement", &exo_movement, self.exo_movement);
			self add_toggle("Infinite Boost", &infinite_boost, self.infinite_boost);
			self add_increment("Set Speed", &set_speed, 1, 1, 15, 1);
			
			self add_toggle("Freeze Box", &freeze_box, self.freeze_box);
			self add_option("Open Doors", &open_doors);
			
			self add_toggle("Third Person", &third_person, self.third_person);
			
			break;
		case "Menu Options":
			self add_menu(menu, menu.size);
		
			self add_increment("Move Menu X", &modify_x_position, 0, -580, 60, 10);
			self add_increment("Move Menu Y", &modify_y_position, 0, -170, 130, 10);
			self add_toggle("Watermark", &watermark, self.watermark);
			
			break;
		case "Zombie Options":
			self add_menu(menu, menu.size);
			
			self add_toggle("No Target", &no_target, self.no_target);
			
			self add_increment("Set Round", &set_round, 1, 1, 255, 1);
			
			self add_option("Kill All Zombies", &kill_all_zombies);
			self add_toggle("One Shot Zombies", &one_shot_zombies, self.one_shot_zombies);
			self add_toggle("Slow Zombies", &slow_zombies, self.slow_zombies);
			
			break;
		case "Off-Host Options":
			self add_menu(menu, menu.size);
			
			self add_toggle("Demi God Mode", &demi_god_mode, self.demi_god_mode);
			self add_toggle("Spectator No Clip", &spectator_no_clip, self.spectator_no_clip);
			
			break;
		case "Give Perks":
			self add_menu(menu, menu.size, 5);
			
			map = get_map_name();
			
			forEach(perk in self.syn["perks"]["all"]) {
				perk_name = get_perk_name(perk);
				self add_option(perk_name, &give_perk, perk);
			}

			break;
		case "Take Perks":
			self add_menu(menu, menu.size, 5);
			
			map = get_map_name();
			
			forEach(perk in self.syn["perks"]["all"]) {
				perk_name = get_perk_name(perk);
				self add_option(perk_name, &take_perk, perk);
			}

			break;
		case "Give AAT":
			self add_menu(menu, menu.size);
			
			for(i = 0; i < self.syn["weapons"]["aats"][0].size; i++) {
				self add_option(self.syn["weapons"]["aats"][1][i], &give_aat, self.syn["weapons"]["aats"][0][i]);
			}
			
			break;
		case "Give Weapons":
			self add_menu(menu, menu.size);
			
			for(i = 0; i < self.syn["weapons"]["category"][0].size; i++) {
				self add_option(self.syn["weapons"]["category"][1][i], &new_menu, self.syn["weapons"]["category"][1][i]);
			}
			
			break;
		case "Assault Rifles":
			self add_menu(menu, menu.size);
			
			category = "assault_rifles";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], &give_weapon, self.syn["weapons"][category][0][i]);
			}
			
			break;
		case "Sub Machine Guns":
			self add_menu(menu, menu.size);
			
			category = "sub_machine_guns";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], &give_weapon, self.syn["weapons"][category][0][i]);
			}
			
			break;
		case "Light Machine Guns":
			self add_menu(menu, menu.size);
			
			category = "light_machine_guns";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], &give_weapon, self.syn["weapons"][category][0][i]);
			}
			
			break;
		case "Sniper Rifles":
			self add_menu(menu, menu.size);
			
			category = "sniper_rifles";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], &give_weapon, self.syn["weapons"][category][0][i]);
			}
			
			break;
		case "Shotguns":
			self add_menu(menu, menu.size);
			
			category = "shotguns";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], &give_weapon, self.syn["weapons"][category][0][i]);
			}
			
			break;
		case "Pistols":
			self add_menu(menu, menu.size);
			
			category = "pistols";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], &give_weapon, self.syn["weapons"][category][0][i]);
			}
			
			break;
		case "Launchers":
			self add_menu(menu, menu.size);
			
			category = "launchers";
			
			for(i = 0; i < self.syn["weapons"][category][0].size; i++) {
				self add_option(self.syn["weapons"][category][1][i], &give_weapon, self.syn["weapons"][category][0][i]);
			}
			
			break;
		case "Empty Menu":
			self add_menu(menu, menu.size);
			
			self add_option("Unassigned Menu");
			break;
	}
}

function get_map_name() {
  if(level.script == "zm_prototype") return "nzp";
  if(level.script == "zm_asylum") return "nza";
  if(level.script == "zm_sumpf") return "nzs";
  if(level.script == "credits") return "cred";
  if(level.script == "zm_factory") return "nzf";
  if(level.script == "zm_castle") return "de";
  if(level.script == "zm_island") return "zns";
  if(level.script == "zm_genesis") return "rev";
  if(level.script == "zm_stalingrad") return "gk";
  if(level.script == "zm_zod") return "soe";
  if(level.script == "zm_tomb") return "origins";
  if(level.script == "zm_moon") return "moon";
  if(level.script == "zm_cosmodrome") return "ascen";
  if(level.script == "zm_theater") return "kino";
  if(level.script == "zm_temple") return "shang";
}

function iPrintString(string) {
	if(!isDefined(self.syn["string"])) {
		self.syn["string"] = self create_text(string, "default", 1, "center", "top", 0, -115, (1,1,1), 1, 9999, false, true);
	} else {
		self.syn["string"] set_text(string);
	}
	self.syn["string"] notify("stop_hud_fade");
	self.syn["string"].alpha = 1;
	self.syn["string"] setText(string);
	self.syn["string"] thread fade_hud(0, 4);
}

function modify_x_position(offset) {
	self.syn["utility"].x_offset = 160 + offset;
	for(x = 0; x < 15; x++) {
		if(isDefined(self.syn["hud"]["arrow"][0][x])) {
			self.syn["hud"]["arrow"][0][x] destroy();
			self.syn["hud"]["arrow"][1][x] destroy();
		}
	}
	self close_menu();
	open_menu("Menu Options");
}

function modify_y_position(offset) {
	self.syn["utility"].y_offset = -60 + offset;
	for(x = 0; x < 15; x++) {
		if(isDefined(self.syn["hud"]["arrow"][0][x])) {
			self.syn["hud"]["arrow"][0][x] destroy();
			self.syn["hud"]["arrow"][1][x] destroy();
		}
	}
	self close_menu();
	open_menu("Menu Options");
}

function watermark() {
	self.watermark = !return_toggle(self.watermark);
	if(!self.watermark) {
		iPrintString("Watermark [^2ON^7]");
		self.syn["watermark"] = self create_text("SyndiShanX", "default", 2, "TOP_LEFT", "CENTER", -425, -240, "rainbow", 1, 3);
	} else {
		iPrintString("Watermark [^1OFF^7]");
		self.syn["watermark"] destroy();
	}
}

function god_mode() {
	self.god_mode = !return_toggle(self.god_mode);
	wait .01;
	if(self.god_mode) {
		iPrintString("God Mode [^2ON^7]");
		self enableInvulnerability();
	} else {
		iPrintString("God Mode [^1OFF^7]");
		self disableInvulnerability();
	}
}

function no_clip() {
  self endon("disconnect");
  self endon("game_ended");

  if(!isDefined(self.no_clip)) {
    self.no_clip = true;
    while (isDefined(self.no_clip)) {
      if(self fragButtonPressed()) {
        if(!isDefined(self.no_clip_loop))
          self thread no_clip_loop();
      }
      wait .05;
    }
  } else
    self.no_clip = undefined;
}

function no_clip_loop() {
  self endon("disconnect");
  self endon("noclip_end");
  self disableWeapons();
  self disableOffHandWeapons();
  self.no_clip_loop = true;

  clip = spawn("script_origin", self.origin);
  self playerLinkTo(clip);
  self enableInvulnerability();
  self animMode("noclip");

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

  if(!isDefined(self.godmode))
    self DisableInvulnerability();
  self animmode("noclip", true);

  self.no_clip_loop = undefined;
}

function ufo_mode() {
  if(isDefined(self.no_clip)) {
		iPrintString("[^1Error^7] Disable Noclip before Enabling UFO Mode");
		return;
	}
	
	self close_menu();

  self enableInvulnerability();
  self disableWeapons();
  self disableOffHandWeapons();
  clip = spawn("script_origin", self.origin);
  self playerLinkTo(clip);
  self animMode("noclip");

  while (1) {
    vec = anglesToForward(self getPlayerAngles());
    vecU = anglesToUp(self getPlayerAngles());
    end = (vec[0] * 35, vec[1] * 35, vec[2] * 35);
    endU = (vecU[0] * 30, vecU[1] * 30, vecU[2] * 30);
    if(self attackButtonPressed()) {
      clip.origin = clip.origin - endU;
    }
    if(self adsButtonPressed()) {
      clip.origin = clip.origin + endU;
    }
    if(self fragButtonPressed()) {
      clip.origin = clip.origin + end;
    }
    if(self meleeButtonPressed()) {
			open_menu("Basic Options");
      break;
    }
    wait .05;
  }
  clip delete();
  self enableWeapons();
  self enableOffHandWeapons();
  if(!isDefined(self.god_mode)) {
    self disableInvulnerability();
  }

  self animMode("noclip", true);
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
		self setWeaponAmmoClip(self getCurrentWeapon(), 999);
		if(self getCurrentOffhand() != "none") {
			self giveMaxAmmo(self getCurrentOffhand());
		}
		wait .1;
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

function self_revive() {
	self.self_revive = !return_toggle(self.self_revive);
	if(self.self_revive) {
		self iPrintln("Self Revive [^2ON^7]");
		self thread self_revive_loop();
	} else {
		self iPrintln("Self Revive [^1OFF^7]");
		self notify("stop_self_revive");
	}
}

function self_revive_loop() {
	self endOn("stop_self_revive");
	self endOn("game_ended");
	
	for(;;) {
		level.solo_game_free_player_quickrevive = 1;
		wait 5;
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
	} else {
		self take_perk(perk);
	}		
}

function take_perk(perk) {
	self notify(perk + "_stop"); 
}

function give_perkaholic() {
	self zm_utility::give_player_all_perks();
}

function set_points(value) {
	self zm_score::minus_to_player_score(9999999);
	self zm_score::add_to_player_score(value);
}

function demi_god_mode() {
	self.demi_god_mode = !return_toggle(self.demi_god_mode);
	if(self.demi_god_mode) {
		self iPrintln("Demi God Mode [^2ON^7]");
		demi_god_mode_loop();
	} else {
		self iPrintln("Demi God Mode [^1OFF^7]");
		self notify("stop_demi_god_mode");
	}
}

function demi_god_mode_loop() {
	self endOn("stop_demi_god_mode");
	self endOn("game_ended");
	
	for(;;) {
		self.health = self.maxHealth;
		wait .05;
	}
}

function spectator_no_clip() {
	self.spectator_no_clip = !return_toggle(self.spectator_no_clip);
	if(self.spectator_no_clip) {
		self iPrintln("Spectator No Clip [^2ON^7]");
		player.sessionstate ="spectator";
	} else {
		self iPrintln("Spectator No Clip [^1OFF^7]");
		player.sessionstate = "playing";
	}
}

function set_speed(value) {
	if(value == 1) {
		self.movement_speed = undefined;
	}
	self setMoveSpeedScale(value);
}

function forge_mode() {
	self.forge_mode = !return_toggle(self.forge_mode);
	if(self.forge_mode) {
		self iPrintln("Forge Mode [^2ON^7]");
		self thread forge_mode_loop();
		wait 1;
		self iPrintln("Press [{+speed_throw}] To Pick Up/Drop Objects");
	} else {
		self iPrintln("Forge Mode [^1OFF^7]");
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

function freeze_box() {
	self.freeze_box = !return_toggle(self.freeze_box);
	if(self.freeze_box) {
		iPrintString("Freeze Box [^2ON^7]");
		wait 5;
		level.chest_min_move_usage = 999;
	} else {
		iPrintString("Freeze Box [^1OFF^7] (^1Not Working^7)");
		wait 5;
		level.chest_min_move_usage = 0;
	}
}

function third_person() {
	self.third_person = !return_toggle(self.third_person);
	if(self.third_person) {
		iPrintString("Third Person [^2ON^7]");
		self setClientThirdPerson(1);
	} else {
		iPrintString("Third Person [^1OFF^7]");
		self setClientThirdPerson(0);
	}
}

function open_doors() {
	types = strTok("zombie_door|zombie_airlock_buy|zombie_debris|zombie_airlock_hackable|zombie_door_airlock|electric_buyable_door|electric_door", "|");
	forEach(type in types) {
		zombie_doors = getEntArray(type, "targetname");
		forEach(door in zombie_doors) {
			door.zombie_cost=0;
			door thread zm_blockers::door_opened(door.zombie_cost, 0);
			door._door_open = true;
			door notify("trigger", self);
			door notify("trigger", self, true);
	
			all_trigs = getEntArray(door.target, "target");
			forEach(trig in all_trigs) {
				trig thread zm_utility::set_hint_string(trig, "");
			}
	
			door._door_open = 1;
		}
	}
	level._doors_done = true;
}

function give_packed_weapon() {
	self.give_packed_weapon = !return_toggle(self.give_packed_weapon);
}

function give_weapon(weapon) {
	weapon = getWeapon(weapon);
	
	if(weapon.name != "smg_longrange") {
		if(isDefined(self.give_packed_weapon) && self.give_packed_weapon == 1) {
			weapon = level.zombie_weapons[weapon].upgrade;
		}
	}
	
	if(!self hasWeapon(weapon)) {
		max_weapon_num = zm_utility::get_player_weapon_limit(self);
		if(self getWeaponsListPrimaries().size >= max_weapon_num) {
			self takeWeapon(self getCurrentWeapon());
		}
		
		self zm_weapons::weapon_give(weapon, undefined, undefined, undefined, true);
	} else {
		self switchToWeaponImmediate(weapon);
	}
	wait 1;
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

function no_target() {
	self.no_target = !return_toggle(self.no_target);
	if(self.no_target) {
		self zm_utility::increment_ignoreme()
		iPrintString("No Target [^2ON^7]");
	} else {
		self zm_utility::decrement_ignoreme();
		iPrintString("No Target [^1OFF^7]");
	}
}

function set_round(value) {
	self thread zm_utility::zombie_goto_round(value);
}

function get_zombies() {
	return getAITeamArray(level.zombie_team);
}

function kill_all_zombies() {
	level.zombie_total = 0;
	forEach(zombie in get_zombies()) {
		zombie dodamage(zombie.health * 5000, (0, 0, 0), self);
		wait 0.05;
	}
}

function one_shot_zombies() {
	if(!isDefined(self.one_shot_zombies)) {
		self iPrintln("One Shot Zombies [^2ON^7]");
		self.one_shot_zombies = true;
		zombies = get_zombies();
		level.prev_health = zombies[0].health;
		while(isDefined(self.one_shot_zombies)) {
			forEach(zombie in get_zombies()) {
				zombie.maxHealth = 1;
				zombie.health	= zombie.maxHealth;
			}
			wait 0.01;
		}
	} else {
		self iPrintln("One Shot Zombies [^1OFF^7]");
		self.one_shot_zombies = undefined;
		forEach(zombie in get_zombies()) {
			zombie.maxHealth = level.prev_health;
			zombie.health	= level.prev_health;
		}
	}
}

function slow_zombies() {
	if(!isDefined(self.slow_zombies)) {
		self iPrintln("Slow Zombies [^2ON^7]");
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
		self iPrintln("Slow Zombies [^1OFF^7]");
		self.slow_zombies = undefined;
		forEach(zombie in get_zombies()) {
			zombie.b_widows_wine_slow = 0;
			zombie asmSetAnimationRate(1);
			zombie clientField::set("widows_wine_wrapping", 0);
		}
	}
}