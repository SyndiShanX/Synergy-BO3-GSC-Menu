// Decompiled by Serious. Credits to Scoba for his original tool, Cerberus, which I heavily upgraded to support remaining features, other games, and other platforms.
#using scripts\cp\_util;
#using scripts\cp\gametypes\_globallogic;
#using scripts\cp\gametypes\_globallogic_defaults;
#using scripts\cp\gametypes\_globallogic_player;
#using scripts\cp\gametypes\_globallogic_score;
#using scripts\cp\gametypes\_globallogic_ui;
#using scripts\cp\gametypes\_globallogic_utils;
#using scripts\cp\gametypes\_loadout;
#using scripts\cp\gametypes\_save;
#using scripts\cp\gametypes\_spawning;
#using scripts\cp\gametypes\_spawnlogic;
#using scripts\cp\gametypes\_spectating;
#using scripts\cp\gametypes\coop;
#using scripts\shared\callbacks_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\hostmigration_shared;
#using scripts\shared\hud_message_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#namespace globallogic_spawn;

/*
	Name: timeuntilspawn
	Namespace: globallogic_spawn
	Checksum: 0xD5CABBD
	Offset: 0x5D0
	Size: 0x178
	Parameters: 1
	Flags: Linked
*/
function timeuntilspawn(includeteamkilldelay) {
  if(level.ingraceperiod && !self.hasspawned) {
    return 0;
  }
  respawndelay = 0;
  if(self.hasspawned) {
    result = self[[level.onrespawndelay]]();
    if(isdefined(result)) {
      respawndelay = result;
    } else {
      respawndelay = level.playerrespawndelay;
    }
    if(isdefined(self.suicide) && self.suicide && level.suicidespawndelay > 0) {
      respawndelay = respawndelay + level.suicidespawndelay;
    }
    if(isdefined(self.teamkilled) && self.teamkilled && level.teamkilledspawndelay > 0) {
      respawndelay = respawndelay + level.teamkilledspawndelay;
    }
    if(includeteamkilldelay && (isdefined(self.teamkillpunish) && self.teamkillpunish)) {
      respawndelay = respawndelay + globallogic_player::teamkilldelay();
    }
  }
  wavebased = level.waverespawndelay > 0;
  if(wavebased) {
    return self timeuntilwavespawn(respawndelay);
  }
  return respawndelay;
}

/*
	Name: allteamshaveexisted
	Namespace: globallogic_spawn
	Checksum: 0x99110292
	Offset: 0x750
	Size: 0x8E
	Parameters: 0
	Flags: Linked
*/
function allteamshaveexisted() {
  foreach(team in level.teams) {
    if(!level.everexisted[team]) {
      return false;
    }
  }
  return true;
}

/*
	Name: mayspawn
	Namespace: globallogic_spawn
	Checksum: 0xC5F7DFF9
	Offset: 0x7E8
	Size: 0x148
	Parameters: 0
	Flags: Linked
*/
function mayspawn() {
  if(isdefined(level.playermayspawn) && !self[[level.playermayspawn]]()) {
    return false;
  }
  if(level.inovertime) {
    return false;
  }
  if(level.playerqueuedrespawn && !isdefined(self.allowqueuespawn) && !level.ingraceperiod && !level.usestartspawns) {
    return false;
  }
  if(isdefined(self.inhibit_respawn) && self.inhibit_respawn) {
    return false;
  }
  if(level.numlives) {
    if(level.teambased) {
      gamehasstarted = allteamshaveexisted();
    } else {
      gamehasstarted = level.maxplayercount > 1 || (!util::isoneround() && !util::isfirstround());
    }
    if(!self.pers["lives"]) {
      return false;
    }
    if(gamehasstarted) {
      if(!level.ingraceperiod && !self.hasspawned) {
        return false;
      }
    }
  }
  return true;
}

/*
	Name: timeuntilwavespawn
	Namespace: globallogic_spawn
	Checksum: 0xAFEF8E4D
	Offset: 0x938
	Size: 0x122
	Parameters: 1
	Flags: Linked
*/
function timeuntilwavespawn(minimumwait) {
  earliestspawntime = gettime() + (minimumwait * 1000);
  lastwavetime = level.lastwave[self.pers["team"]];
  wavedelay = level.wavedelay[self.pers["team"]] * 1000;
  if(wavedelay == 0) {
    return 0;
  }
  numwavespassedearliestspawntime = (earliestspawntime - lastwavetime) / wavedelay;
  numwaves = ceil(numwavespassedearliestspawntime);
  timeofspawn = lastwavetime + (numwaves * wavedelay);
  if(isdefined(self.wavespawnindex)) {
    timeofspawn = timeofspawn + (50 * self.wavespawnindex);
  }
  return (timeofspawn - gettime()) / 1000;
}

/*
	Name: stoppoisoningandflareonspawn
	Namespace: globallogic_spawn
	Checksum: 0xD023CC41
	Offset: 0xA68
	Size: 0x3C
	Parameters: 0
	Flags: Linked
*/
function stoppoisoningandflareonspawn() {
  self endon(# "disconnect");
  self.inpoisonarea = 0;
  self.inburnarea = 0;
  self.inflarevisionarea = 0;
  self.ingroundnapalm = 0;
}

/*
	Name: spawnplayerprediction
	Namespace: globallogic_spawn
	Checksum: 0xAD1F51DC
	Offset: 0xAB0
	Size: 0x68
	Parameters: 0
	Flags: None
*/
function spawnplayerprediction() {
  self endon(# "disconnect");
  self endon(# "end_respawn");
  self endon(# "game_ended");
  self endon(# "joined_spectators");
  self endon(# "spawned");
  while (true) {
    wait(0.5);
    self[[level.onspawnplayer]](1);
  }
}

/*
	Name: doinitialspawnmessaging
	Namespace: globallogic_spawn
	Checksum: 0x585CC3C8
	Offset: 0xB20
	Size: 0xBC
	Parameters: 0
	Flags: Linked
*/
function doinitialspawnmessaging() {
  self endon(# "disconnect");
  if(isdefined(level.disableprematchmessages) && level.disableprematchmessages) {
    return;
  }
  team = self.pers["team"];
  thread hud_message::showinitialfactionpopup(team);
  while (level.inprematchperiod) {
    wait(0.05);
  }
  hintmessage = util::getobjectivehinttext(team);
  if(isdefined(hintmessage)) {
    self thread hud_message::hintmessage(hintmessage);
  }
}

/*
	Name: spawnplayer
	Namespace: globallogic_spawn
	Checksum: 0x7EBC10A7
	Offset: 0xBE8
	Size: 0x9D4
	Parameters: 0
	Flags: Linked
*/
function spawnplayer() {
  pixbeginevent("spawnPlayer_preUTS");
  self endon(# "disconnect");
  self endon(# "joined_spectators");
  self notify(# "spawned");
  level notify(# "player_spawned");
  self notify(# "end_respawn");
  self setspawnvariables();
  self luinotifyevent( & "player_spawned", 0);
  self util::clearlowermessage(0);
  self.sessionteam = self.team;
  hadspawned = self.hasspawned;
  self.sessionstate = "playing";
  self.spectatorclient = -1;
  self.archivetime = 0;
  self.psoffsettime = 0;
  self.statusicon = "";
  self.damagedplayers = [];
  if(getdvarint("scr_csmode") > 0) {
    self.maxhealth = getdvarint("scr_csmode");
  } else {
    self.maxhealth = level.playermaxhealth;
  }
  self.health = self.maxhealth;
  self.friendlydamage = undefined;
  self.hasspawned = 1;
  self.spawntime = gettime();
  self.afk = 0;
  if(self.pers["lives"] && (!isdefined(level.takelivesondeath) || level.takelivesondeath == 0)) {
    self.pers["lives"]--;
    if(self.pers["lives"] == 0) {
      level notify(# "player_eliminated");
      self notify(# "player_eliminated");
    }
  }
  self.laststand = undefined;
  self.revivingteammate = 0;
  self.burning = undefined;
  self.nextkillstreakfree = undefined;
  self.activeuavs = 0;
  self.activecounteruavs = 0;
  self.activesatellites = 0;
  self.deathmachinekills = 0;
  self.disabledweapon = 0;
  self util::resetusability();
  self globallogic_player::resetattackerlist();
  self.diedonvehicle = undefined;
  if(!self.wasaliveatmatchstart) {
    if(level.ingraceperiod || globallogic_utils::gettimepassed() < 20000) {
      self.wasaliveatmatchstart = 1;
    }
  }
  self setdepthoffield(0, 0, 512, 512, 4, 0);
  self resetfov();
  pixbeginevent("onSpawnPlayer");
  self[[level.onspawnplayer]](0);
  if(isdefined(level.playerspawnedcb)) {
    self[[level.playerspawnedcb]]();
  }
  pixendevent();
  pixendevent();
  globallogic::updateteamstatus();
  pixbeginevent("spawnPlayer_postUTS");
  self thread stoppoisoningandflareonspawn();
  self.sensorgrenadedata = undefined;
  /#
  assert(globallogic_utils::isvalidclass(self.curclass) || util::is_bot());
  # /
    self loadout::setclass(self.curclass);
  var_4fbe10c = self savegame::get_player_data("altPlayerID", undefined);
  altplayer = undefined;
  if(isdefined(var_4fbe10c)) {
    foreach(var_388ffcfb in level.players) {
      if(var_388ffcfb getxuid() === var_4fbe10c) {
        altplayer = var_388ffcfb;
        break;
      }
    }
    if(!isdefined(altplayer)) {
      self savegame::set_player_data("altPlayerID", undefined);
    }
  }
  self thread loadout::giveloadout(self.team, self.curclass, level.var_dc236bc8, altplayer);
  if(isdefined(self.var_c8430b0a) && self.var_c8430b0a) {
    self.var_c8430b0a = undefined;
  } else {
    self lui::screen_close_menu();
  }
  if(level.inprematchperiod) {
    self util::freeze_player_controls(1);
    team = self.pers["team"];
    self thread doinitialspawnmessaging();
  } else {
    self util::freeze_player_controls(0);
    self enableweapons();
    if(!hadspawned && game["state"] == "playing") {
      pixbeginevent("sound");
      team = self.team;
      self thread doinitialspawnmessaging();
      pixendevent();
    }
  }
  if(getdvarstring("scr_showperksonspawn") == "") {
    setdvar("scr_showperksonspawn", "0");
  }
  if(level.hardcoremode) {
    setdvar("scr_showperksonspawn", "0");
  }
  if(getdvarint("scr_showperksonspawn") == 1 && game["state"] != "postgame") {
    pixbeginevent("showperksonspawn");
    if(level.perksenabled == 1) {
      self hud::showperks();
    }
    pixendevent();
  }
  if(isdefined(self.pers["momentum"])) {
    self.momentum = self.pers["momentum"];
  }
  pixendevent();
  wait(0.05);
  self notify(# "spawned_player");
  if(!getdvarint("art_review", 0)) {
    callback::callback(# "hash_bc12b61f");
  }
  /#
  print(((((("" + self.origin[0]) + "") + self.origin[1]) + "") + self.origin[2]) + "");
  # /
    setdvar("scr_selecting_location", "");
  self thread vehicledeathwaiter();
  /#
  if(getdvarint("") > 0) {
    self thread globallogic_score::xpratethread();
  }
  # /
    if(game["state"] == "postgame") {
      /#
      assert(!level.intermission);
      # /
        self globallogic_player::freezeplayerforroundend();
    }
  self util::set_lighting_state();
  self util::set_sun_shadow_split_distance();
  self util::streamer_wait(undefined, 0, 5);
  self flag::set("initial_streamer_ready");
}

/*
	Name: vehicledeathwaiter
	Namespace: globallogic_spawn
	Checksum: 0xFBF44B2D
	Offset: 0x15C8
	Size: 0x74
	Parameters: 0
	Flags: Linked
*/
function vehicledeathwaiter() {
  self notify(# "vehicledeathwaiter");
  self endon(# "vehicledeathwaiter");
  self endon(# "disconnect");
  while (true) {
    self waittill(# "vehicle_death", vehicle_died);
    if(vehicle_died) {
      self.diedonvehicle = 1;
    } else {
      self.diedonturret = 1;
    }
  }
}

/*
	Name: spawnspectator
	Namespace: globallogic_spawn
	Checksum: 0x878688CC
	Offset: 0x1648
	Size: 0x54
	Parameters: 2
	Flags: Linked
*/
function spawnspectator(origin, angles) {
  self notify(# "spawned");
  self notify(# "end_respawn");
  self notify(# "spawned_spectator");
  in_spawnspectator(origin, angles);
}

/*
	Name: respawn_asspectator
	Namespace: globallogic_spawn
	Checksum: 0x91571FB1
	Offset: 0x16A8
	Size: 0x2C
	Parameters: 2
	Flags: Linked
*/
function respawn_asspectator(origin, angles) {
  in_spawnspectator(origin, angles);
}

/*
	Name: in_spawnspectator
	Namespace: globallogic_spawn
	Checksum: 0xE7D33722
	Offset: 0x16E0
	Size: 0x164
	Parameters: 2
	Flags: Linked
*/
function in_spawnspectator(origin, angles) {
  pixmarker("BEGIN: in_spawnSpectator");
  self setspawnvariables();
  if(self.pers["team"] == "spectator") {
    self util::clearlowermessage();
  }
  self.sessionstate = "spectator";
  self.spectatorclient = -1;
  self.archivetime = 0;
  self.psoffsettime = 0;
  self.friendlydamage = undefined;
  if(self.pers["team"] == "spectator") {
    self.statusicon = "";
  } else {
    self.statusicon = "hud_status_dead";
  }
  spectating::set_permissions_for_machine();
  [
    [level.onspawnspectator]
  ](origin, angles);
  if(level.teambased && !level.splitscreen) {
    self thread spectatorthirdpersonness();
  }
  pixmarker("END: in_spawnSpectator");
}

/*
	Name: spectatorthirdpersonness
	Namespace: globallogic_spawn
	Checksum: 0x33E06797
	Offset: 0x1850
	Size: 0x3C
	Parameters: 0
	Flags: Linked
*/
function spectatorthirdpersonness() {
  self endon(# "disconnect");
  self endon(# "spawned");
  self notify(# "spectator_thirdperson_thread");
  self endon(# "spectator_thirdperson_thread");
  self.spectatingthirdperson = 0;
}

/*
	Name: forcespawn
	Namespace: globallogic_spawn
	Checksum: 0x66230DFB
	Offset: 0x1898
	Size: 0xF4
	Parameters: 1
	Flags: None
*/
function forcespawn(time) {
  self endon(# "death");
  self endon(# "disconnect");
  self endon(# "spawned");
  if(!isdefined(time)) {
    time = 60;
  }
  wait(time);
  if(self.hasspawned) {
    return;
  }
  if(self.pers["team"] == "spectator") {
    return;
  }
  if(!globallogic_utils::isvalidclass(self.pers["class"])) {
    self.pers["class"] = "CLASS_CUSTOM1";
    self.curclass = self.pers["class"];
  }
  self globallogic_ui::closemenus();
  self thread[[level.spawnclient]]();
}

/*
	Name: kickifdontspawn
	Namespace: globallogic_spawn
	Checksum: 0x937ECB7B
	Offset: 0x1998
	Size: 0x5C
	Parameters: 0
	Flags: Linked
*/
function kickifdontspawn() {
  /#
  if(getdvarint("") == 1) {
    return;
  }
  # /
    if(self ishost()) {
      return;
    }
  self kickifidontspawninternal();
}

/*
	Name: kickifidontspawninternal
	Namespace: globallogic_spawn
	Checksum: 0xA7DB9A16
	Offset: 0x1A00
	Size: 0x1D4
	Parameters: 0
	Flags: Linked
*/
function kickifidontspawninternal() {
  self endon(# "death");
  self endon(# "disconnect");
  self endon(# "spawned");
  waittime = 90;
  if(getdvarstring("scr_kick_time") != "") {
    waittime = getdvarfloat("scr_kick_time");
  }
  mintime = 45;
  if(getdvarstring("scr_kick_mintime") != "") {
    mintime = getdvarfloat("scr_kick_mintime");
  }
  starttime = gettime();
  kickwait(waittime);
  timepassed = (gettime() - starttime) / 1000;
  if(timepassed < (waittime - 0.1) && timepassed < mintime) {
    return;
  }
  if(self.hasspawned) {
    return;
  }
  if(sessionmodeisprivate()) {
    return;
  }
  if(self.pers["team"] == "spectator") {
    return;
  }
  if(!mayspawn()) {
    return;
  }
  globallogic::gamehistoryplayerkicked();
  kick(self getentitynumber());
}

/*
	Name: kickwait
	Namespace: globallogic_spawn
	Checksum: 0x7D954656
	Offset: 0x1BE0
	Size: 0x2C
	Parameters: 1
	Flags: Linked
*/
function kickwait(waittime) {
  level endon(# "game_ended");
  hostmigration::waitlongdurationwithhostmigrationpause(waittime);
}

/*
	Name: spawninterroundintermission
	Namespace: globallogic_spawn
	Checksum: 0x11736237
	Offset: 0x1C18
	Size: 0x124
	Parameters: 0
	Flags: None
*/
function spawninterroundintermission() {
  self notify(# "spawned");
  self notify(# "end_respawn");
  self setspawnvariables();
  self util::clearlowermessage();
  self util::freeze_player_controls(0);
  self.sessionstate = "spectator";
  self.spectatorclient = -1;
  self.archivetime = 0;
  self.psoffsettime = 0;
  self.friendlydamage = undefined;
  self globallogic_defaults::default_onspawnintermission();
  self setorigin(self.origin);
  self setplayerangles(self.angles);
  self setdepthoffield(0, 128, 512, 4000, 6, 1.8);
}

/*
	Name: spawnintermission
	Namespace: globallogic_spawn
	Checksum: 0xD704249
	Offset: 0x1D48
	Size: 0x114
	Parameters: 1
	Flags: Linked
*/
function spawnintermission(usedefaultcallback) {
  self notify(# "spawned");
  self notify(# "end_respawn");
  self endon(# "disconnect");
  self setspawnvariables();
  self util::clearlowermessage();
  self util::freeze_player_controls(0);
  self.sessionstate = "intermission";
  self.spectatorclient = -1;
  self.archivetime = 0;
  self.psoffsettime = 0;
  self.friendlydamage = undefined;
  if(isdefined(usedefaultcallback) && usedefaultcallback) {
    globallogic_defaults::default_onspawnintermission();
  } else {
    [
      [level.onspawnintermission]
    ]();
  }
  self setdepthoffield(0, 128, 512, 4000, 6, 1.8);
}

/*
	Name: spawnqueuedclientonteam
	Namespace: globallogic_spawn
	Checksum: 0xD5C8A72B
	Offset: 0x1E68
	Size: 0xD8
	Parameters: 1
	Flags: Linked
*/
function spawnqueuedclientonteam(team) {
  player_to_spawn = undefined;
  for (i = 0; i < level.deadplayers[team].size; i++) {
    player = level.deadplayers[team][i];
    if(player.waitingtospawn) {
      continue;
    }
    player_to_spawn = player;
    break;
  }
  if(isdefined(player_to_spawn)) {
    player_to_spawn.allowqueuespawn = 1;
    player_to_spawn globallogic_ui::closemenus();
    player_to_spawn thread[[level.spawnclient]]();
  }
}

/*
	Name: spawnqueuedclient
	Namespace: globallogic_spawn
	Checksum: 0x3129746B
	Offset: 0x1F48
	Size: 0x152
	Parameters: 2
	Flags: Linked
*/
function spawnqueuedclient(dead_player_team, killer) {
  if(!level.playerqueuedrespawn) {
    return;
  }
  util::waittillslowprocessallowed();
  spawn_team = undefined;
  if(isdefined(killer) && isdefined(killer.team) && isdefined(level.teams[killer.team])) {
    spawn_team = killer.team;
  }
  if(isdefined(spawn_team)) {
    spawnqueuedclientonteam(spawn_team);
    return;
  }
  foreach(team in level.teams) {
    if(team == dead_player_team) {
      continue;
    }
    spawnqueuedclientonteam(team);
  }
}

/*
	Name: allteamsnearscorelimit
	Namespace: globallogic_spawn
	Checksum: 0x7D719336
	Offset: 0x20A8
	Size: 0xC4
	Parameters: 0
	Flags: Linked
*/
function allteamsnearscorelimit() {
  if(!level.teambased) {
    return false;
  }
  if(level.scorelimit <= 1) {
    return false;
  }
  foreach(team in level.teams) {
    if(!game["teamScores"][team] >= (level.scorelimit - 1)) {
      return false;
    }
  }
  return true;
}

/*
	Name: shouldshowrespawnmessage
	Namespace: globallogic_spawn
	Checksum: 0xD76D3B53
	Offset: 0x2178
	Size: 0x6E
	Parameters: 0
	Flags: Linked
*/
function shouldshowrespawnmessage() {
  if(util::waslastround()) {
    return false;
  }
  if(util::isoneround()) {
    return false;
  }
  if(isdefined(level.livesdonotreset) && level.livesdonotreset) {
    return false;
  }
  if(allteamsnearscorelimit()) {
    return false;
  }
  return true;
}

/*
	Name: default_spawnmessage
	Namespace: globallogic_spawn
	Checksum: 0x991D966C
	Offset: 0x21F0
	Size: 0x44
	Parameters: 0
	Flags: Linked
*/
function default_spawnmessage() {
  util::setlowermessage(game["strings"]["spawn_next_round"]);
  self thread globallogic_ui::removespawnmessageshortly(3);
}

/*
	Name: showspawnmessage
	Namespace: globallogic_spawn
	Checksum: 0xEB76F3D2
	Offset: 0x2240
	Size: 0x28
	Parameters: 0
	Flags: Linked
*/
function showspawnmessage() {
  if(shouldshowrespawnmessage()) {
    self thread[[level.spawnmessage]]();
  }
}

/*
	Name: spawnclient
	Namespace: globallogic_spawn
	Checksum: 0xA32493BE
	Offset: 0x2270
	Size: 0x17C
	Parameters: 1
	Flags: Linked
*/
function spawnclient(timealreadypassed) {
  pixbeginevent("spawnClient");
  /#
  assert(isdefined(self.team));
  # /
    /#
  assert(globallogic_utils::isvalidclass(self.curclass));
  # /
    if(!self mayspawn()) {
      currentorigin = self.origin;
      currentangles = self.angles;
      self showspawnmessage();
      self thread[[level.spawnspectator]](currentorigin + vectorscale((0, 0, 1), 60), currentangles);
      pixendevent();
      return;
    }
  if(self.waitingtospawn) {
    pixendevent();
    return;
  }
  self.waitingtospawn = 1;
  self.allowqueuespawn = undefined;
  self waitandspawnclient(timealreadypassed);
  if(isdefined(self)) {
    self.waitingtospawn = 0;
  }
  pixendevent();
}

/*
	Name: waitandspawnclient
	Namespace: globallogic_spawn
	Checksum: 0x1D25E8A2
	Offset: 0x23F8
	Size: 0x79C
	Parameters: 1
	Flags: Linked
*/
function waitandspawnclient(timealreadypassed) {
  self endon(# "disconnect");
  self endon(# "end_respawn");
  level endon(# "game_ended");
  if(!isdefined(timealreadypassed)) {
    timealreadypassed = 0;
  }
  spawnedasspectator = 0;
  if(isdefined(level.var_3a9f9a38) && level.var_3a9f9a38 && (isdefined(self.var_ebd83169) && self.var_ebd83169)) {
    self thread coop::function_44e35f1a();
  }
  if(isdefined(self.teamkillpunish) && self.teamkillpunish) {
    teamkilldelay = globallogic_player::teamkilldelay();
    if(teamkilldelay > timealreadypassed) {
      teamkilldelay = teamkilldelay - timealreadypassed;
      timealreadypassed = 0;
    } else {
      timealreadypassed = timealreadypassed - teamkilldelay;
      teamkilldelay = 0;
    }
    if(teamkilldelay > 0) {
      util::setlowermessage( & "MP_FRIENDLY_FIRE_WILL_NOT", teamkilldelay);
      self thread respawn_asspectator(self.origin + vectorscale((0, 0, 1), 60), self.angles);
      spawnedasspectator = 1;
      wait(teamkilldelay);
    }
    self.teamkillpunish = 0;
  }
  if(!isdefined(self.wavespawnindex) && isdefined(level.waveplayerspawnindex[self.team])) {
    self.wavespawnindex = level.waveplayerspawnindex[self.team];
    level.waveplayerspawnindex[self.team]++;
  }
  timeuntilspawn = timeuntilspawn(0);
  if(timeuntilspawn > timealreadypassed) {
    timeuntilspawn = timeuntilspawn - timealreadypassed;
    timealreadypassed = 0;
  } else {
    timealreadypassed = timealreadypassed - timeuntilspawn;
    timeuntilspawn = 0;
  }
  if(timeuntilspawn > 0) {
    if(level.playerqueuedrespawn) {
      util::setlowermessage(game["strings"]["you_will_spawn"], timeuntilspawn);
    } else {
      if(self issplitscreen()) {
        util::setlowermessage(game["strings"]["waiting_to_spawn_ss"], timeuntilspawn, 1);
      } else {
        util::setlowermessage(game["strings"]["waiting_to_spawn"], timeuntilspawn);
      }
    }
    if(!spawnedasspectator) {
      spawnorigin = self.origin + vectorscale((0, 0, 1), 60);
      spawnangles = self.angles;
      if(isdefined(level.useintermissionpointsonwavespawn) && [
          [level.useintermissionpointsonwavespawn]
        ]() == 1) {
        spawnpoint = spawnlogic::get_random_intermission_point();
        if(isdefined(spawnpoint)) {
          spawnorigin = spawnpoint.origin;
          spawnangles = spawnpoint.angles;
        }
      }
      self thread respawn_asspectator(spawnorigin, spawnangles);
    }
    spawnedasspectator = 1;
    self globallogic_utils::waitfortimeornotify(timeuntilspawn, "force_spawn");
    self notify(# "stop_wait_safe_spawn_button");
  }
  if(isdefined(level.gametypespawnwaiter)) {
    if(isdefined(level.var_bdd4d5c2) && !spawnedasspectator) {
      spawnedasspectator = self[[level.var_bdd4d5c2]]();
    }
    if(!spawnedasspectator) {
      self thread respawn_asspectator(self.origin + vectorscale((0, 0, 1), 60), self.angles);
    }
    spawnedasspectator = 1;
    if(!self[[level.gametypespawnwaiter]]()) {
      self.waitingtospawn = 0;
      self util::clearlowermessage();
      self.wavespawnindex = undefined;
      self.respawntimerstarttime = undefined;
      return;
    }
  }
  system::wait_till("all");
  level flag::wait_till("all_players_connected");
  if(level.players.size > 0) {
    if(scene::should_spectate_on_join()) {
      if(!spawnedasspectator) {
        self thread respawn_asspectator(self.origin + vectorscale((0, 0, 1), 60), self.angles);
      }
      spawnedasspectator = 1;
      scene::wait_until_spectate_on_join_completes();
    }
  }
  wavebased = level.waverespawndelay > 0;
  if(!level.playerforcerespawn && self.hasspawned && !wavebased && !self.wantsafespawn && !level.playerqueuedrespawn && !spawnedasspectator) {
    util::setlowermessage(game["strings"]["press_to_spawn"]);
    if(!spawnedasspectator) {
      self thread respawn_asspectator(self.origin + vectorscale((0, 0, 1), 60), self.angles);
    }
    spawnedasspectator = 1;
    self waitrespawnorsafespawnbutton();
  }
  self.waitingtospawn = 0;
  self util::clearlowermessage();
  self.wavespawnindex = undefined;
  self.respawntimerstarttime = undefined;
  if(isdefined(self.var_acfedf1c) && self.var_acfedf1c) {
    self waittill(# "end_killcam");
  }
  self notify(# "hash_1528244e");
  if(isdefined(self.var_ee8c475a)) {
    self.var_ee8c475a.alpha = 0;
  }
  self.var_ebd83169 = undefined;
  self.var_acfedf1c = undefined;
  self.var_1b7a74aa = undefined;
  self.var_ca78829f = undefined;
  self.killcamweapon = getweapon("none");
  self.var_8c0347ee = undefined;
  self.var_2b1ad8b = undefined;
  if(isdefined(level.var_ee7cb602) && level.var_ee7cb602) {
    level waittill(# "forever");
  }
  if(!isdefined(self.firstspawn)) {
    self.firstspawn = 1;
    savegame::checkpoint_save();
  }
  self thread[[level.spawnplayer]]();
}

/*
	Name: waitrespawnorsafespawnbutton
	Namespace: globallogic_spawn
	Checksum: 0x9406A479
	Offset: 0x2BA0
	Size: 0x48
	Parameters: 0
	Flags: Linked
*/
function waitrespawnorsafespawnbutton() {
  self endon(# "disconnect");
  self endon(# "end_respawn");
  while (true) {
    if(self usebuttonpressed()) {
      break;
    }
    wait(0.05);
  }
}

/*
	Name: waitinspawnqueue
	Namespace: globallogic_spawn
	Checksum: 0x82E3850C
	Offset: 0x2BF0
	Size: 0x90
	Parameters: 0
	Flags: None
*/
function waitinspawnqueue() {
  self endon(# "disconnect");
  self endon(# "end_respawn");
  if(!level.ingraceperiod && !level.usestartspawns) {
    currentorigin = self.origin;
    currentangles = self.angles;
    self thread[[level.spawnspectator]](currentorigin + vectorscale((0, 0, 1), 60), currentangles);
    self waittill(# "queue_respawn");
  }
}

/*
	Name: setthirdperson
	Namespace: globallogic_spawn
	Checksum: 0x363A78E7
	Offset: 0x2C88
	Size: 0xEC
	Parameters: 1
	Flags: Linked
*/
function setthirdperson(value) {
  if(!level.console) {
    return;
  }
  if(!isdefined(self.spectatingthirdperson) || value != self.spectatingthirdperson) {
    self.spectatingthirdperson = value;
    if(value) {
      self setclientthirdperson(1);
      self setdepthoffield(0, 128, 512, 4000, 6, 1.8);
    } else {
      self setclientthirdperson(0);
      self setdepthoffield(0, 0, 512, 4000, 4, 0);
    }
    self resetfov();
  }
}

/*
	Name: setspawnvariables
	Namespace: globallogic_spawn
	Checksum: 0x2B418482
	Offset: 0x2D80
	Size: 0x4C
	Parameters: 0
	Flags: Linked
*/
function setspawnvariables() {
  resettimeout();
  self stopshellshock();
  self stoprumble("damage_heavy");
}