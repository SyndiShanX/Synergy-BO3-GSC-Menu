/*************************************************
 * Decompiled by Serious and Edited by SyndiShanX
 * Script: cp\gametypes\_loadout.gsc
*************************************************/

#using scripts\codescripts\struct;
#using scripts\cp\_challenges;
#using scripts\cp\_util;
#using scripts\cp\cybercom\_cybercom_util;
#using scripts\cp\gametypes\_dev;
#using scripts\cp\gametypes\_save;
#using scripts\cp\teams\_teams;
#using scripts\shared\abilities\_ability_util;
#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\challenges_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\loadout_shared;
#using scripts\shared\player_shared;
#using scripts\shared\system_shared;
#using scripts\shared\tweakables_shared;
#using scripts\shared\util_shared;
#namespace loadout;

function autoexec __init__sytem__() {
  system::register("loadout", & __init__, undefined, undefined);
}

function __init__() {
  level.player_interactive_model = "c_usa_cia_masonjr_viewbody";
  callback::on_start_gametype( & init);
  callback::on_connect( & on_connect);
  callback::on_disconnect( & function_ef129246);
  level thread function_adca0ced();
}

function on_connect() {}

function init() {
  level.classmap["class_smg"] = "CLASS_SMG";
  level.classmap["class_cqb"] = "CLASS_CQB";
  level.classmap["class_assault"] = "CLASS_ASSAULT";
  level.classmap["class_lmg"] = "CLASS_LMG";
  level.classmap["class_sniper"] = "CLASS_SNIPER";
  level.classmap["custom0"] = "CLASS_CUSTOM1";
  level.classmap["custom1"] = "CLASS_CUSTOM2";
  level.classmap["custom2"] = "CLASS_CUSTOM3";
  level.classmap["custom3"] = "CLASS_CUSTOM4";
  level.classmap["custom4"] = "CLASS_CUSTOM5";
  level.classmap["custom5"] = "CLASS_CUSTOM6";
  level.classmap["custom6"] = "CLASS_CUSTOM7";
  level.classmap["custom7"] = "CLASS_CUSTOM8";
  level.classmap["custom8"] = "CLASS_CUSTOM9";
  level.classmap["custom9"] = "CLASS_CUSTOM10";
  level.maxkillstreaks = 4;
  level.maxspecialties = 6;
  level.maxbonuscards = 3;
  level.maxallocation = getgametypesetting("maxAllocation");
  level.loadoutkillstreaksenabled = getgametypesetting("loadoutKillstreaksEnabled");
  level.prestigenumber = 5;
  level.defaultclass = "CLASS_CUSTOM1";
  if(tweakables::gettweakablevalue("weapon", "allowfrag")) {
    level.weapons["frag"] = getweapon("frag_grenade");
  } else {
    level.weapons["frag"] = "";
  }
  if(tweakables::gettweakablevalue("weapon", "allowsmoke")) {
    level.weapons["smoke"] = getweapon("smoke_grenade");
  } else {
    level.weapons["smoke"] = "";
  }
  if(tweakables::gettweakablevalue("weapon", "allowflash")) {
    level.weapons["flash"] = getweapon("flash_grenade");
  } else {
    level.weapons["flash"] = "";
  }
  level.weapons["concussion"] = getweapon("concussion_grenade");
  if(tweakables::gettweakablevalue("weapon", "allowsatchel")) {
    level.weapons["satchel_charge"] = getweapon("satchel_charge");
  } else {
    level.weapons["satchel_charge"] = "";
  }
  if(tweakables::gettweakablevalue("weapon", "allowbetty")) {
    level.weapons["betty"] = getweapon("mine_bouncing_betty");
  } else {
    level.weapons["betty"] = "";
  }
  if(tweakables::gettweakablevalue("weapon", "allowrpgs")) {
    level.weapons["rpg"] = getweapon("rpg");
  } else {
    level.weapons["rpg"] = "";
  }
  create_class_exclusion_list();
  cac_init();
  load_default_loadout("CLASS_SMG", 10);
  load_default_loadout("CLASS_CQB", 11);
  load_default_loadout("CLASS_ASSAULT", 12);
  load_default_loadout("CLASS_LMG", 13);
  load_default_loadout("CLASS_SNIPER", 14);
  level.primary_weapon_array = [];
  level.side_arm_array = [];
  level.grenade_array = [];
  level.inventory_array = [];
  max_weapon_num = 99;
  for (i = 0; i < max_weapon_num; i++) {
    if(!isdefined(level.tbl_weaponids[i]) || level.tbl_weaponids[i]["group"] == "") {
      continue;
    }
    if(!isdefined(level.tbl_weaponids[i]) || level.tbl_weaponids[i]["reference"] == "") {
      continue;
    }
    weapon_type = level.tbl_weaponids[i]["group"];
    weapon = level.tbl_weaponids[i]["reference"];
    attachment = level.tbl_weaponids[i]["attachment"];
    weapon_class_register(weapon, weapon_type);
    if(isdefined(attachment) && attachment != "") {
      attachment_tokens = strtok(attachment, " ");
      if(isdefined(attachment_tokens)) {
        if(attachment_tokens.size == 0) {
          weapon_class_register((weapon + "_") + attachment, weapon_type);
          continue;
        }
        for (k = 0; k < attachment_tokens.size; k++) {
          weapon_class_register((weapon + "_") + attachment_tokens[k], weapon_type);
        }
      }
    }
  }
  level thread onplayerconnecting();
}

function function_adca0ced() {
  level flag::wait_till("all_players_spawned");
  savegame::function_37ae30c6();
}

function function_ef129246() {
  self savegame::set_player_data("playerClass", undefined);
  self savegame::set_player_data("altPlayerID", undefined);
  self savegame::set_player_data("saved_weapon", undefined);
  self savegame::set_player_data("saved_weapondata", undefined);
  self savegame::set_player_data("lives", undefined);
  self savegame::set_player_data("saved_rig1", undefined);
  self savegame::set_player_data("saved_rig1_upgraded", undefined);
  self savegame::set_player_data("saved_rig2", undefined);
  self savegame::set_player_data("saved_rig2_upgraded", undefined);
}

function create_class_exclusion_list() {
  currentdvar = 0;
  level.itemexclusions = [];
  while (getdvarint("item_exclusion_" + currentdvar)) {
    level.itemexclusions[currentdvar] = getdvarint("item_exclusion_" + currentdvar);
    currentdvar++;
  }
  level.attachmentexclusions = [];
  for (currentdvar = 0;
    (getdvarstring("attachment_exclusion_" + currentdvar)) != ""; currentdvar++) {
    level.attachmentexclusions[currentdvar] = getdvarstring("attachment_exclusion_" + currentdvar);
  }
}

function is_attachment_excluded(attachment) {
  numexclusions = level.attachmentexclusions.size;
  for (exclusionindex = 0; exclusionindex < numexclusions; exclusionindex++) {
    if(attachment == level.attachmentexclusions[exclusionindex]) {
      return true;
    }
  }
  return false;
}

function set_statstable_id() {
  if(!isdefined(level.statstableid)) {
    level.statstableid = tablelookupfindcoreasset(util::getstatstablename());
  }
}

function get_item_count(itemreference) {
  set_statstable_id();
  itemcount = int(tablelookup(level.statstableid, 4, itemreference, 5));
  if(itemcount < 1) {
    itemcount = 1;
  }
  return itemcount;
}

function getdefaultclassslotwithexclusions(classname, slotname) {
  itemreference = getdefaultclassslot(classname, slotname);
  set_statstable_id();
  itemindex = int(tablelookup(level.statstableid, 4, itemreference, 0));
  if(is_item_excluded(itemindex)) {
    itemreference = tablelookup(level.statstableid, 0, 0, 4);
  }
  return itemreference;
}

function load_default_loadout(weaponclass, classnum) {
  level.classtoclassnum[weaponclass] = classnum;
}

function weapon_class_register(weaponname, weapon_type) {
  if(issubstr("weapon_smg weapon_cqb weapon_assault weapon_lmg weapon_sniper weapon_shotgun weapon_launcher weapon_special", weapon_type)) {
    level.primary_weapon_array[getweapon(weaponname)] = 1;
  } else {
    if(issubstr("weapon_pistol", weapon_type)) {
      level.side_arm_array[getweapon(weaponname)] = 1;
    } else {
      if(weapon_type == "weapon_grenade") {
        level.grenade_array[getweapon(weaponname)] = 1;
      } else {
        if(weapon_type == "weapon_explosive") {
          level.inventory_array[getweapon(weaponname)] = 1;
        } else {
          if(weapon_type == "weapon_rifle") {
            level.inventory_array[getweapon(weaponname)] = 1;
          } else {
            assert(0, "" + weapon_type);
          }
        }
      }
    }
  }
}

function cac_init() {
  level.tbl_weaponids = [];
  set_statstable_id();
  for (i = 0; i < 256; i++) {
    itemrow = tablelookuprownum(level.statstableid, 0, i);
    if(itemrow > -1) {
      group_s = tablelookupcolumnforrow(level.statstableid, itemrow, 2);
      if(issubstr(group_s, "weapon_") || group_s == "hero") {
        reference_s = tablelookupcolumnforrow(level.statstableid, itemrow, 4);
        if(reference_s != "") {
          weapon = getweapon(reference_s);
          level.tbl_weaponids[i]["reference"] = reference_s;
          level.tbl_weaponids[i]["group"] = group_s;
          level.tbl_weaponids[i]["count"] = int(tablelookupcolumnforrow(level.statstableid, itemrow, 5));
          level.tbl_weaponids[i]["attachment"] = tablelookupcolumnforrow(level.statstableid, itemrow, 8);
        }
      }
    }
  }
  level.perknames = [];
  for (i = 0; i < 256; i++) {
    itemrow = tablelookuprownum(level.statstableid, 0, i);
    if(itemrow > -1) {
      group_s = tablelookupcolumnforrow(level.statstableid, itemrow, 2);
      if(group_s == "specialty") {
        reference_s = tablelookupcolumnforrow(level.statstableid, itemrow, 4);
        if(reference_s != "") {
          perkicon = tablelookupcolumnforrow(level.statstableid, itemrow, 6);
          perkname = tablelookupistring(level.statstableid, 0, i, 3);
          level.perknames[perkicon] = perkname;
        }
      }
    }
  }
  level.killstreaknames = [];
  level.killstreakicons = [];
  level.killstreakindices = [];
  for (i = 0; i < 256; i++) {
    itemrow = tablelookuprownum(level.statstableid, 0, i);
    if(itemrow > -1) {
      group_s = tablelookupcolumnforrow(level.statstableid, itemrow, 2);
      if(group_s == "killstreak") {
        reference_s = tablelookupcolumnforrow(level.statstableid, itemrow, 4);
        if(reference_s != "") {
          level.tbl_killstreakdata[i] = reference_s;
          level.killstreakindices[reference_s] = i;
          icon = tablelookupcolumnforrow(level.statstableid, itemrow, 6);
          name = tablelookupistring(level.statstableid, 0, i, 3);
          level.killstreaknames[reference_s] = name;
          level.killstreakicons[reference_s] = icon;
          level.killstreakindices[reference_s] = i;
        }
      }
    }
  }
}

function getclasschoice(response) {
  assert(isdefined(level.classmap[response]));
  return level.classmap[response];
}

function getattachmentstring(weaponnum, attachmentnum) {
  attachmentstring = getitemattachment(weaponnum, attachmentnum);
  if(attachmentstring != "none" && !is_attachment_excluded(attachmentstring)) {
    attachmentstring = attachmentstring + "_";
  } else {
    attachmentstring = "";
  }
  return attachmentstring;
}

function getattachmentsdisabled() {
  if(!isdefined(level.attachmentsdisabled)) {
    return 0;
  }
  return level.attachmentsdisabled;
}

function getkillstreakindex(weaponclass, killstreaknum) {
  killstreaknum++;
  killstreakstring = "killstreak" + killstreaknum;
  if(getdvarint("custom_killstreak_mode") == 2) {
    return getdvarint("custom_" + killstreakstring);
  }
  return self getloadoutitem(weaponclass, killstreakstring);
}

function isperkgroup(perkname) {
  return isdefined(perkname) && isstring(perkname);
}

function reset_specialty_slots(class_num) {
  self.specialty = [];
}

function initstaticweaponstime() {
  self.staticweaponsstarttime = gettime();
}

function isequipmentallowed(equipment_name) {
  if(equipment_name == level.weapontacticalinsertion.name && level.disabletacinsert) {
    return false;
  }
  return true;
}

function isleagueitemrestricted(item) {
  if(level.leaguematch) {
    return isitemrestricted(item);
  }
  return 0;
}

function function_db96b564(var_dc236bc8) {
  if(level.gametype === "coop") {
    self thread cybercom::function_674d724c(0, !(isdefined(var_dc236bc8) && var_dc236bc8));
  }
}

function giveloadoutlevelspecific(team, weaponclass) {
  pixbeginevent("giveLoadoutLevelSpecific");
  if(isdefined(level.givecustomcharacters)) {
    self[[level.givecustomcharacters]]();
  }
  if(isdefined(level.givecustomloadout)) {
    self[[level.givecustomloadout]]();
  }
  pixendevent();
}

function giveloadout(team, weaponclass, var_dc236bc8, altplayer) {
  pixbeginevent("giveLoadout");
  self takeallweapons();
  primaryindex = 0;
  self.specialty = [];
  self.killstreak = [];
  self notify("give_map");
  class_num_for_global_weapons = 0;
  primaryweaponoptions = 0;
  secondaryweaponoptions = 0;
  playerrenderoptions = 0;
  primarygrenadecount = 0;
  iscustomclass = 0;
  if(issubstr(weaponclass, "CLASS_CUSTOM")) {
    pixbeginevent("custom class");
    class_num = (int(weaponclass[weaponclass.size - 1])) - 1;
    if(-1 == class_num) {
      class_num = 9;
    }
    self.class_num = class_num;
    if(isdefined(altplayer)) {
      self.var_6f9a6c8e = 1;
    } else {
      self.var_6f9a6c8e = undefined;
    }
    self reset_specialty_slots(class_num);
    playerrenderoptions = self calcplayeroptions(class_num);
    class_num_for_global_weapons = class_num;
    iscustomclass = 1;
    pixendevent();
  } else {
    pixbeginevent("default class");
    assert(isdefined(self.pers[""]), "");
    class_num = level.classtoclassnum[weaponclass];
    if(!isdefined(class_num)) {
      if(self util::is_bot()) {
        class_num = array::random(level.classtoclassnum);
      } else {
        assert(0, ("" + weaponclass) + "");
      }
    }
    self.class_num = class_num;
    pixendevent();
  }
  knifeweaponoptions = self calcweaponoptions(class_num, 2);
  println(((("" + self.name) + "") + level.weaponbasemelee.name) + "");
  self giveweapon(level.weaponbasemelee, knifeweaponoptions);
  self.specialty = self getloadoutperks(class_num);
  if(level.leaguematch) {
    for (i = 0; i < self.specialty.size; i++) {
      if(isleagueitemrestricted(self.specialty[i])) {
        arrayremoveindex(self.specialty, i);
        i--;
      }
    }
  }
  self setplayerstateloadoutweapons(class_num);
  self register_perks();
  self setactionslot(3, "altMode");
  self setactionslot(4, "");
  spawnweapon = "";
  initialweaponcount = 0;
  if(isdefined(self.pers["weapon"]) && self.pers["weapon"] != level.weaponnone && !self.pers["weapon"].iscarriedkillstreak) {
    primaryweapon = self.pers["weapon"];
  } else {
    primaryweapon = self getloadoutweapon(class_num, "primary");
    if(isdefined(altplayer)) {
      primaryweapon = altplayer getloadoutweapon(class_num, "primary");
    }
  }
  if(primaryweapon.iscarriedkillstreak) {
    primaryweapon = level.weaponnull;
  }
  sidearm = self getloadoutweapon(class_num, "secondary");
  if(isdefined(altplayer)) {
    sidearm = altplayer getloadoutweapon(class_num, "secondary");
  }
  if(sidearm.iscarriedkillstreak) {
    sidearm = level.weaponnull;
  }
  self.primaryweaponkill = 0;
  self.secondaryweaponkill = 0;
  if(sidearm != level.weaponnull) {
    secondaryweaponoptions = self calcweaponoptions(class_num, 1);
    if(isdefined(altplayer)) {
      secondaryweaponoptions = altplayer calcweaponoptions(class_num, 1);
    }
    println(((("" + self.name) + "") + sidearm.name) + "");
    acvi = self getattachmentcosmeticvariantforweapon(class_num, "secondary");
    if(isdefined(altplayer)) {
      acvi = altplayer getattachmentcosmeticvariantforweapon(class_num, "secondary");
    }
    self giveweapon(sidearm, secondaryweaponoptions, acvi);
    self.secondaryloadoutweapon = sidearm;
    self.secondaryloadoutaltweapon = sidearm.altweapon;
    self.secondaryloadoutgunsmithvariantindex = self getloadoutgunsmithvariantindex(self.class_num, 1);
    if(isdefined(altplayer)) {
      self.secondaryloadoutgunsmithvariantindex = altplayer getloadoutgunsmithvariantindex(self.class_num, 1);
    }
    self givemaxammo(sidearm);
    spawnweapon = sidearm;
    initialweaponcount++;
  }
  self.pers["primaryWeapon"] = primaryweapon;
  if(primaryweapon != level.weaponnull) {
    primaryweaponoptions = self calcweaponoptions(class_num, 0);
    if(isdefined(altplayer)) {
      primaryweaponoptions = altplayer calcweaponoptions(class_num, 0);
    }
    println(((("" + self.name) + "") + primaryweapon.name) + "");
    acvi = self getattachmentcosmeticvariantforweapon(class_num, "primary");
    if(isdefined(altplayer)) {
      acvi = altplayer getattachmentcosmeticvariantforweapon(class_num, "primary");
    }
    self giveweapon(primaryweapon, primaryweaponoptions, acvi);
    self.primaryloadoutweapon = primaryweapon;
    self.primaryloadoutaltweapon = primaryweapon.altweapon;
    self.primaryloadoutgunsmithvariantindex = self getloadoutgunsmithvariantindex(self.class_num, 0);
    if(isdefined(altplayer)) {
      self.primaryloadoutgunsmithvariantindex = altplayer getloadoutgunsmithvariantindex(self.class_num, 0);
    }
    self givemaxammo(primaryweapon);
    spawnweapon = primaryweapon;
    initialweaponcount++;
  }
  if(isdefined(self.var_82325a18)) {
    var_82325a18 = strtok(self.var_82325a18, ",");
    foreach(weaponname in var_82325a18) {
      heroweapon = getweapon(weaponname);
      self giveweapon(heroweapon);
      self givemaxammo(heroweapon);
    }
  }
  if(!self hasmaxprimaryweapons()) {
    if(!isusingt7melee()) {
      println(((("" + self.name) + "") + level.weaponbasemeleeheld.name) + "");
      self giveweapon(level.weaponbasemeleeheld, knifeweaponoptions);
    }
    if(initialweaponcount == 0) {
      spawnweapon = level.weaponbasemeleeheld;
    }
  }
  if(!isdefined(self.spawnweapon) && isdefined(self.pers["spawnWeapon"])) {
    self.spawnweapon = self.pers["spawnWeapon"];
  }
  if(isdefined(self.spawnweapon) && doesweaponreplacespawnweapon(self.spawnweapon, spawnweapon) && !self.pers["changed_class"]) {
    spawnweapon = self.spawnweapon;
  }
  changedclass = self.pers["changed_class"];
  roundbased = !util::isoneround();
  firstround = util::isfirstround();
  self.pers["changed_class"] = 0;
  self.spawnweapon = spawnweapon;
  self.pers["spawnWeapon"] = self.spawnweapon;
  self setspawnweapon(spawnweapon);
  self.grenadetypeprimary = level.weaponnone;
  self.grenadetypeprimarycount = 0;
  self.grenadetypesecondary = level.weaponnone;
  self.grenadetypesecondarycount = 0;
  primaryoffhand = level.weaponnone;
  primaryoffhandcount = 0;
  secondaryoffhand = level.weaponnone;
  secondaryoffhandcount = 0;
  specialoffhand = level.weaponnone;
  specialoffhandcount = 0;
  if(getdvarint("gadgetEnabled") == 1 || getdvarint("equipmentAsGadgets") == 1) {
    primaryoffhand = self getloadoutweapon(class_num, "primaryGadget");
    if(isdefined(altplayer)) {
      primaryoffhand = altplayer getloadoutweapon(class_num, "primaryGadget");
    }
    primaryoffhandcount = primaryoffhand.startammo;
  } else {
    primaryoffhandname = self getloadoutitemref(class_num, "primarygrenade");
    if(isdefined(altplayer)) {
      primaryoffhandname = altplayer getloadoutitemref(class_num, "primarygrenade");
    }
    if(primaryoffhandname != "" && primaryoffhandname != "weapon_null") {
      primaryoffhand = getweapon(primaryoffhand);
      primaryoffhandcount = self getloadoutitem(class_num, "primarygrenadecount");
      if(isdefined(altplayer)) {
        primaryoffhandcount = altplayer getloadoutitem(class_num, "primarygrenadecount");
      }
    }
  }
  if(isleagueitemrestricted(primaryoffhand.name) || !isequipmentallowed(primaryoffhand.name)) {
    primaryoffhand = level.weaponnone;
    primaryoffhandcount = 0;
  }
  if(primaryoffhand == level.weaponnone) {
    primaryoffhand = level.weapons["frag"];
    primaryoffhandcount = 0;
  }
  if(primaryoffhand != level.weaponnull) {
    println(((("" + self.name) + "") + primaryoffhand.name) + "");
    self giveweapon(primaryoffhand);
    self setweaponammoclip(primaryoffhand, primaryoffhandcount);
    self switchtooffhand(primaryoffhand);
    self.grenadetypeprimary = primaryoffhand;
    self.grenadetypeprimarycount = primaryoffhandcount;
    self ability_util::gadget_reset(primaryoffhand, changedclass, roundbased, firstround);
  }
  if(getdvarint("gadgetEnabled") == 1 || getdvarint("equipmentAsGadgets") == 1) {
    secondaryoffhand = self getloadoutweapon(class_num, "secondaryGadget");
    if(isdefined(altplayer)) {
      secondaryoffhand = altplayer getloadoutweapon(class_num, "secondaryGadget");
    }
    secondaryoffhandcount = secondaryoffhand.startammo;
  } else {
    secondaryoffhandname = self getloadoutitemref(class_num, "specialgrenade");
    if(isdefined(altplayer)) {
      secondaryoffhandname = altplayer getloadoutitemref(class_num, "specialgrenade");
    }
    if(secondaryoffhandname != "" && secondaryoffhandname != "weapon_null") {
      secondaryoffhand = getweapon(secondaryoffhand);
      secondaryoffhandcount = self getloadoutitem(class_num, "specialgrenadecount");
      if(isdefined(altplayer)) {
        secondaryoffhandcount = altplayer getloadoutitem(class_num, "specialgrenadecount");
      }
    }
  }
  if(isleagueitemrestricted(secondaryoffhand.name) || !isequipmentallowed(secondaryoffhand.name)) {
    secondaryoffhand = level.weaponnone;
    secondaryoffhandcount = 0;
  }
  if(secondaryoffhand == level.weaponnone) {
    secondaryoffhand = level.weapons["flash"];
    secondaryoffhandcount = 0;
  }
  if(secondaryoffhand != level.weaponnull) {
    println(((("" + self.name) + "") + secondaryoffhand.name) + "");
    self giveweapon(secondaryoffhand);
    self setweaponammoclip(secondaryoffhand, secondaryoffhandcount);
    self switchtooffhand(secondaryoffhand);
    self.grenadetypesecondary = secondaryoffhand;
    self.grenadetypesecondarycount = secondaryoffhandcount;
    self ability_util::gadget_reset(secondaryoffhand, changedclass, roundbased, firstround);
  }
  if(getdvarint("gadgetEnabled") == 1 || getdvarint("equipmentAsGadgets") == 1) {
    specialoffhand = self getloadoutweapon(class_num, "specialGadget");
    if(isdefined(altplayer)) {
      specialoffhand = altplayer getloadoutweapon(class_num, "specialGadget");
    }
    specialoffhandcount = specialoffhand.startammo;
  }
  if(isleagueitemrestricted(specialoffhand.name) || !isequipmentallowed(specialoffhand.name)) {
    specialoffhand = level.weaponnone;
    specialoffhandcount = 0;
  }
  if(specialoffhand == level.weaponnone) {
    specialoffhand = level.weaponnull;
    specialoffhandcount = 0;
  }
  if(specialoffhand != level.weaponnull) {
    println(((("" + self.name) + "") + specialoffhand.name) + "");
    self giveweapon(specialoffhand);
    self setweaponammoclip(specialoffhand, specialoffhandcount);
    self switchtooffhand(specialoffhand);
    self.grenadetypespecial = specialoffhand;
    self.grenadetypespecialcount = specialoffhandcount;
    self ability_util::gadget_reset(specialoffhand, changedclass, roundbased, firstround);
  }
  if(level.gametype === "coop") {
    cybercom::function_4b8ac464(class_num, class_num_for_global_weapons, !(isdefined(var_dc236bc8) && var_dc236bc8), altplayer);
  }
  self bbclasschoice(class_num, primaryweapon, sidearm);
  for (i = 0; i < 3; i++) {
    if(level.loadoutkillstreaksenabled && isdefined(self.killstreak[i]) && isdefined(level.killstreakindices[self.killstreak[i]])) {
      killstreaks[i] = level.killstreakindices[self.killstreak[i]];
      continue;
    }
    killstreaks[i] = 0;
  }
  self recordloadoutperksandkillstreaks(primaryweapon, sidearm, self.grenadetypeprimary, self.grenadetypesecondary, killstreaks[0], killstreaks[1], killstreaks[2]);
  self teams::set_player_model(team, primaryweapon);
  self initstaticweaponstime();
  self thread initweaponattachments(spawnweapon);
  self setplayerrenderoptions(playerrenderoptions);
  if(isdefined(self.movementspeedmodifier)) {
    self setmovespeedscale(self.movementspeedmodifier * self getmovespeedscale());
  }
  if(isdefined(level.givecustomloadout)) {
    spawnweapon = self[[level.givecustomloadout]]();
    if(isdefined(spawnweapon)) {
      self thread initweaponattachments(spawnweapon);
    }
  }
  self cac_selector();
  if(!isdefined(self.firstspawn)) {
    if(isdefined(spawnweapon)) {
      self initialweaponraise(spawnweapon);
    } else {
      self initialweaponraise(primaryweapon);
    }
  } else {
    self seteverhadweaponall(1);
  }
  var_f0b98892 = self savegame::get_player_data("saved_weapon", undefined);
  if(isdefined(var_f0b98892) && (!(isdefined(level.is_safehouse) && level.is_safehouse))) {
    self player::take_weapons();
    self._current_weapon = util::get_weapon_by_name(var_f0b98892);
    self._weapons = self savegame::get_player_data("saved_weapondata", undefined);
    self.lives = self savegame::get_player_data("lives", 0);
    self player::give_back_weapons(0);
  }
  self.firstspawn = 0;
  self.switchedteamsresetgadgets = 0;
  if(system::is_system_running("cybercom")) {
    self flagsys::wait_till("cybercom_init");
  }
  self.initialloadoutgiven = 1;
  self flagsys::set("loadout_given");
  callback::callback("hash_33bba039");
  pixendevent();
}

function setweaponammooverall(weapon, amount) {
  if(weapon.iscliponly) {
    self setweaponammoclip(weapon, amount);
  } else {
    self setweaponammoclip(weapon, amount);
    diff = amount - self getweaponammoclip(weapon);
    assert(diff >= 0);
    self setweaponammostock(weapon, diff);
  }
}

function onplayerconnecting() {
  for (;;) {
    level waittill("connecting", player);
    if(!level.oldschool) {
      if(!isdefined(player.pers["class"])) {
        player.pers["class"] = "";
      }
      player.curclass = player.pers["class"];
      player.lastclass = "";
    }
    player.detectexplosives = 0;
    player.bombsquadicons = [];
    player.bombsquadids = [];
    player.reviveicons = [];
    player.reviveids = [];
  }
}

function fadeaway(waitdelay, fadedelay) {
  wait(waitdelay);
  self fadeovertime(fadedelay);
  self.alpha = 0;
}

function setclass(newclass) {
  self.curclass = newclass;
}

function initperkdvars() {
  level.cac_armorpiercing_data = getdvarint("perk_armorpiercing", 40) / 100;
  level.cac_bulletdamage_data = getdvarint("perk_bulletDamage", 35);
  level.cac_fireproof_data = getdvarint("perk_fireproof", 95);
  level.cac_armorvest_data = getdvarint("perk_armorVest", 80);
  level.cac_flakjacket_data = getdvarint("perk_flakJacket", 35);
  level.cac_flakjacket_hardcore_data = getdvarint("perk_flakJacket_hardcore", 9);
}

function cac_selector() {
  perks = self.specialty;
  self.detectexplosives = 0;
  for (i = 0; i < perks.size; i++) {
    perk = perks[i];
    if(perk == "specialty_detectexplosive") {
      self.detectexplosives = 1;
    }
  }
}

function register_perks() {
  perks = self.specialty;
  self clearperks();
  for (i = 0; i < perks.size; i++) {
    perk = perks[i];
    if(perk == "specialty_null" || issubstr(perk, "specialty_weapon_") || perk == "weapon_null") {
      continue;
    }
    if(!level.perksenabled) {
      continue;
    }
    println(((("" + self.name) + "") + perk) + "");
    self setperk(perk);
  }
  dev::giveextraperks();
}

function cac_modified_vehicle_damage(victim, attacker, damage, meansofdeath, weapon, inflictor) {
  if(!isdefined(victim) || !isdefined(attacker) || !isplayer(attacker)) {
    return damage;
  }
  if(!isdefined(damage) || !isdefined(meansofdeath) || !isdefined(weapon)) {
    return damage;
  }
  old_damage = damage;
  final_damage = damage;
  if(attacker hasperk("specialty_bulletdamage") && isprimarydamage(meansofdeath)) {
    final_damage = (damage * (100 + level.cac_bulletdamage_data)) / 100;
    if(getdvarint("")) {
      println(("" + attacker.name) + "");
    }
  } else {
    final_damage = old_damage;
  }
  if(getdvarint("")) {
    println((((("" + (final_damage / old_damage)) + "") + old_damage) + "") + final_damage);
  }
  return int(final_damage);
}

function cac_modified_damage(victim, attacker, damage, mod, weapon, inflictor, hitloc) {
  assert(isdefined(victim));
  assert(isdefined(attacker));
  assert(isplayer(victim));
  if(damage <= 0) {
    return damage;
  }
  debug = 0;
  if(getdvarint("")) {
    debug = 1;
  }
  final_damage = damage;
  if(isplayer(attacker) && attacker hasperk("specialty_bulletdamage") && isprimarydamage(mod)) {
    if(victim hasperk("specialty_armorvest") && !isheaddamage(hitloc)) {
      if(debug) {
        println(((("" + victim.name) + "") + attacker.name) + "");
      }
    } else {
      final_damage = (damage * (100 + level.cac_bulletdamage_data)) / 100;
      if(debug) {
        println((("" + attacker.name) + "") + victim.name);
      }
    }
  } else {
    if(victim hasperk("specialty_armorvest") && isprimarydamage(mod) && !isheaddamage(hitloc)) {
      final_damage = damage * (level.cac_armorvest_data * 0.01);
      if(debug) {
        println((("" + attacker.name) + "") + victim.name);
      }
    } else {
      if(victim hasperk("specialty_fireproof") && isfiredamage(weapon, mod)) {
        final_damage = damage * ((100 - level.cac_fireproof_data) / 100);
        if(debug) {
          println((("" + attacker.name) + "") + victim.name);
        }
      } else if(victim hasperk("specialty_flakjacket") && isexplosivedamage(mod) && !weapon.ignoresflakjacket && !victim grenadestuck(inflictor)) {
        cac_data = (level.hardcoremode ? level.cac_flakjacket_hardcore_data : level.cac_flakjacket_data);
        if(level.teambased && attacker.team != victim.team) {
          victim thread challenges::flakjacketprotected(weapon, attacker);
        } else if(attacker != victim) {
          victim thread challenges::flakjacketprotected(weapon, attacker);
        }
        final_damage = int(damage * (cac_data / 100));
        if(debug) {
          println(((("" + victim.name) + "") + attacker.name) + "");
        }
      }
    }
  }
  victim.cac_debug_damage_type = tolower(mod);
  victim.cac_debug_original_damage = damage;
  victim.cac_debug_final_damage = final_damage;
  victim.cac_debug_location = tolower(hitloc);
  victim.cac_debug_weapon = tolower(weapon.name);
  victim.cac_debug_range = int(distance(attacker.origin, victim.origin));
  if(debug) {
    println((((("" + (final_damage / damage)) + "") + damage) + "") + final_damage);
  }
  final_damage = int(final_damage);
  if(final_damage < 1) {
    final_damage = 1;
  }
  return final_damage;
}

function isexplosivedamage(meansofdeath) {
  switch (meansofdeath) {
    case "MOD_EXPLOSIVE":
    case "MOD_GRENADE":
    case "MOD_GRENADE_SPLASH":
    case "MOD_PROJECTILE_SPLASH": {
      return true;
    }
  }
  return false;
}

function hastacticalmask(player) {
  return player hasperk("specialty_stunprotection") || player hasperk("specialty_flashprotection") || player hasperk("specialty_proximityprotection");
}

function isprimarydamage(meansofdeath) {
  return meansofdeath == "MOD_RIFLE_BULLET" || meansofdeath == "MOD_PISTOL_BULLET";
}

function isfiredamage(weapon, meansofdeath) {
  if(weapon.doesfiredamage && (meansofdeath == "MOD_BURNED" || meansofdeath == "MOD_GRENADE" || meansofdeath == "MOD_GRENADE_SPLASH")) {
    return true;
  }
  return false;
}

function isheaddamage(hitloc) {
  return hitloc == "helmet" || hitloc == "head" || hitloc == "neck";
}

function grenadestuck(inflictor) {
  return isdefined(inflictor) && isdefined(inflictor.stucktoplayer) && inflictor.stucktoplayer == self;
}