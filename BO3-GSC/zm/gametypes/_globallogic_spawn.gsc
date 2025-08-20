/*************************************************
 * Decompiled by Serious and Edited by SyndiShanX
 * Script: zm\gametypes\_globallogic_spawn.gsc
*************************************************/

#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\hud_message_shared;
#using scripts\shared\hud_util_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_util;
#using scripts\zm\_zm_perks;
#using scripts\zm\gametypes\_globallogic;
#using scripts\zm\gametypes\_globallogic_audio;
#using scripts\zm\gametypes\_globallogic_defaults;
#using scripts\zm\gametypes\_globallogic_player;
#using scripts\zm\gametypes\_globallogic_score;
#using scripts\zm\gametypes\_globallogic_ui;
#using scripts\zm\gametypes\_globallogic_utils;
#using scripts\zm\gametypes\_hostmigration;
#using scripts\zm\gametypes\_spawning;
#using scripts\zm\gametypes\_spawnlogic;
#using scripts\zm\gametypes\_spectating;
#namespace globallogic_spawn;

function autoexec init() {
  if(!isdefined(level.givestartloadout)) {
    level.givestartloadout = & givestartloadout;
  }
}

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

function allteamshaveexisted() {
  foreach(team in level.teams) {
    if(!level.everexisted[team]) {
      return false;
    }
  }
  return true;
}

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
  if(level.numlives) {
    if(level.teambased) {
      gamehasstarted = allteamshaveexisted();
    } else {
      gamehasstarted = level.maxplayercount > 1 || (!util::isoneround() && !util::isfirstround());
    }
    if(!self.pers["lives"] && gamehasstarted) {
      return false;
    }
    if(gamehasstarted) {
      if(!level.ingraceperiod && !self.hasspawned && !level.wagermatch) {
        return false;
      }
    }
  }
  return true;
}

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

function stoppoisoningandflareonspawn() {
  self endon("disconnect");
  self.inpoisonarea = 0;
  self.inburnarea = 0;
  self.inflarevisionarea = 0;
  self.ingroundnapalm = 0;
}

function spawnplayerprediction() {
  self endon("disconnect");
  self endon("end_respawn");
  self endon("game_ended");
  self endon("joined_spectators");
  self endon("spawned");
  while (true) {
    wait(0.5);
    if(isdefined(level.onspawnplayerunified) && getdvarint("scr_disableunifiedspawning") == 0) {
      spawning::onspawnplayer_unified(1);
    } else {
      self[[level.onspawnplayer]](1);
    }
  }
}

function giveloadoutlevelspecific(team, _class) {
  pixbeginevent("giveLoadoutLevelSpecific");
  if(isdefined(level.givecustomcharacters)) {
    self[[level.givecustomcharacters]]();
  }
  if(isdefined(level.givestartloadout)) {
    self[[level.givestartloadout]]();
  }
  self flagsys::set("loadout_given");
  callback::callback("hash_33bba039");
  pixendevent();
}

function givestartloadout() {
  if(isdefined(level.givecustomloadout)) {
    self[[level.givecustomloadout]]();
  }
}

function spawnplayer() {
  pixbeginevent("spawnPlayer_preUTS");
  self endon("disconnect");
  self endon("joined_spectators");
  self notify("spawned");
  level notify("player_spawned");
  self notify("end_respawn");
  self setspawnvariables();
  self luinotifyevent(&"player_spawned", 0);
  if(!self.hasspawned) {
    self.underscorechance = 70;
    self thread globallogic_audio::sndstartmusicsystem();
  }
  self.sessionteam = self.team;
  hadspawned = self.hasspawned;
  self.sessionstate = "playing";
  self.spectatorclient = -1;
  self.killcamentity = -1;
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
      level notify("player_eliminated");
      self notify("player_eliminated");
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
  if(isdefined(level.onspawnplayerunified) && getdvarint("scr_disableunifiedspawning") == 0) {
    self[[level.onspawnplayerunified]]();
  } else {
    self[[level.onspawnplayer]](0);
  }
  if(isdefined(level.playerspawnedcb)) {
    self[[level.playerspawnedcb]]();
  }
  pixendevent();
  pixendevent();
  level thread globallogic::updateteamstatus();
  pixbeginevent("spawnPlayer_postUTS");
  self thread stoppoisoningandflareonspawn();
  assert(globallogic_utils::isvalidclass(self.curclass));
  self giveloadoutlevelspecific(self.team, self.curclass);
  if(level.inprematchperiod) {
    self util::freeze_player_controls(1);
    team = self.pers["team"];
    if(isdefined(self.pers["music"].spawn) && self.pers["music"].spawn == 0) {
      if(level.wagermatch) {
        music = "SPAWN_WAGER";
      } else {
        music = game["music"]["spawn_" + team];
      }
      self thread globallogic_audio::set_music_on_player(music, 0, 0);
      self.pers["music"].spawn = 1;
    }
    if(level.splitscreen) {
      if(isdefined(level.playedstartingmusic)) {
        music = undefined;
      } else {
        level.playedstartingmusic = 1;
      }
    }
    if(!isdefined(level.disableprematchmessages) || level.disableprematchmessages == 0) {
      thread hud_message::showinitialfactionpopup(team);
      hintmessage = util::getobjectivehinttext(self.pers["team"]);
      if(isdefined(hintmessage)) {
        self thread hud_message::hintmessage(hintmessage);
      }
      if(isdefined(game["dialog"]["gametype"]) && (!level.splitscreen || self == level.players[0])) {
        if(!isdefined(level.infinalfight) || !level.infinalfight) {
          if(level.hardcoremode) {
            self globallogic_audio::leaderdialogonplayer("gametype_hardcore");
          } else {
            self globallogic_audio::leaderdialogonplayer("gametype");
          }
        }
      }
      if(team == game["attackers"]) {
        self globallogic_audio::leaderdialogonplayer("offense_obj", "introboost");
      } else {
        self globallogic_audio::leaderdialogonplayer("defense_obj", "introboost");
      }
    }
  } else {
    self util::freeze_player_controls(0);
    self enableweapons();
    if(!hadspawned && game["state"] == "playing") {
      pixbeginevent("sound");
      team = self.team;
      if(isdefined(self.pers["music"].spawn) && self.pers["music"].spawn == 0) {
        self thread globallogic_audio::set_music_on_player("SPAWN_SHORT", 0, 0);
        self.pers["music"].spawn = 1;
      }
      if(level.splitscreen) {
        if(isdefined(level.playedstartingmusic)) {
          music = undefined;
        } else {
          level.playedstartingmusic = 1;
        }
      }
      if(!isdefined(level.disableprematchmessages) || level.disableprematchmessages == 0) {
        thread hud_message::showinitialfactionpopup(team);
        hintmessage = util::getobjectivehinttext(self.pers["team"]);
        if(isdefined(hintmessage)) {
          self thread hud_message::hintmessage(hintmessage);
        }
        if(isdefined(game["dialog"]["gametype"]) && (!level.splitscreen || self == level.players[0])) {
          if(!isdefined(level.infinalfight) || !level.infinalfight) {
            if(level.hardcoremode) {
              self globallogic_audio::leaderdialogonplayer("gametype_hardcore");
            } else {
              self globallogic_audio::leaderdialogonplayer("gametype");
            }
          }
        }
        if(team == game["attackers"]) {
          self globallogic_audio::leaderdialogonplayer("offense_obj", "introboost");
        } else {
          self globallogic_audio::leaderdialogonplayer("defense_obj", "introboost");
        }
      }
      pixendevent();
    }
  }
  if(getdvarstring("scr_showperksonspawn") == "") {
    setdvar("scr_showperksonspawn", "0");
  }
  if(level.hardcoremode) {
    setdvar("scr_showperksonspawn", "0");
  }
  if(!level.splitscreen && getdvarint("scr_showperksonspawn") == 1 && game["state"] != "postgame") {
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
  waittillframeend();
  self notify("spawned_player");
  self callback::callback("hash_bc12b61f");
  print(((((("" + self.origin[0]) + "") + self.origin[1]) + "") + self.origin[2]) + "");
  setdvar("scr_selecting_location", "");
  if(getdvarint("") > 0) {
    self thread globallogic_score::xpratethread();
  }
  self zm_perks::perk_set_max_health_if_jugg("health_reboot", 1, 0);
  if(game["state"] == "postgame") {
    assert(!level.intermission);
    self globallogic_player::freezeplayerforroundend();
  }
  self util::set_lighting_state();
  self util::set_sun_shadow_split_distance();
}

function spawnspectator(origin, angles) {
  self notify("spawned");
  self notify("end_respawn");
  in_spawnspectator(origin, angles);
}

function respawn_asspectator(origin, angles) {
  in_spawnspectator(origin, angles);
}

function in_spawnspectator(origin, angles) {
  pixmarker("BEGIN: in_spawnSpectator");
  self setspawnvariables();
  if(self.pers["team"] == "spectator") {
    self util::clearlowermessage();
  }
  self.sessionstate = "spectator";
  self.spectatorclient = -1;
  self.killcamentity = -1;
  self.archivetime = 0;
  self.psoffsettime = 0;
  self.friendlydamage = undefined;
  if(self.pers["team"] == "spectator") {
    self.statusicon = "";
  } else {
    self.statusicon = "hud_status_dead";
  }
  spectating::setspectatepermissionsformachine();
  [[level.onspawnspectator]](origin, angles);
  if(level.teambased && !level.splitscreen) {
    self thread spectatorthirdpersonness();
  }
  level thread globallogic::updateteamstatus();
  pixmarker("END: in_spawnSpectator");
}

function spectatorthirdpersonness() {
  self endon("disconnect");
  self endon("spawned");
  self notify("spectator_thirdperson_thread");
  self endon("spectator_thirdperson_thread");
  self.spectatingthirdperson = 0;
}

function forcespawn(time) {
  self endon("death");
  self endon("disconnect");
  self endon("spawned");
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

function kickifdontspawn() {
  if(getdvarint("") == 1) {
    return;
  }
  if(self ishost()) {
    return;
  }
  self kickifidontspawninternal();
}

function kickifidontspawninternal() {
  self endon("death");
  self endon("disconnect");
  self endon("spawned");
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
  kick(self getentitynumber());
}

function kickwait(waittime) {
  level endon("game_ended");
  hostmigration::waitlongdurationwithhostmigrationpause(waittime);
}

function spawninterroundintermission() {
  self notify("spawned");
  self notify("end_respawn");
  self setspawnvariables();
  self util::clearlowermessage();
  self util::freeze_player_controls(0);
  self.sessionstate = "spectator";
  self.spectatorclient = -1;
  self.killcamentity = -1;
  self.archivetime = 0;
  self.psoffsettime = 0;
  self.friendlydamage = undefined;
  self globallogic_defaults::default_onspawnintermission();
  self setorigin(self.origin);
  self setplayerangles(self.angles);
  self setdepthoffield(0, 128, 512, 4000, 6, 1.8);
}

function spawnintermission(usedefaultcallback) {
  self notify("spawned");
  self notify("end_respawn");
  self endon("disconnect");
  self setspawnvariables();
  self util::clearlowermessage();
  self util::freeze_player_controls(0);
  if(level.rankedmatch && util::waslastround()) {
    if(self.postgamemilestones || self.postgamecontracts || self.postgamepromotion) {
      if(self.postgamepromotion) {
        self playlocalsound("mus_level_up");
      } else {
        if(self.postgamecontracts) {
          self playlocalsound("mus_challenge_complete");
        } else if(self.postgamemilestones) {
          self playlocalsound("mus_contract_complete");
        }
      }
      self closeingamemenu();
      waittime = 4;
      while (waittime) {
        wait(0.25);
        waittime = waittime - 0.25;
      }
    }
  }
  self.sessionstate = "intermission";
  self.spectatorclient = -1;
  self.killcamentity = -1;
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

function default_spawnmessage() {
  util::setlowermessage(game["strings"]["spawn_next_round"]);
  self thread globallogic_ui::removespawnmessageshortly(3);
}

function showspawnmessage() {
  if(shouldshowrespawnmessage()) {
    self thread[[level.spawnmessage]]();
  }
}

function spawnclient(timealreadypassed) {
  pixbeginevent("spawnClient");
  assert(isdefined(self.team));
  assert(globallogic_utils::isvalidclass(self.curclass));
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

function waitandspawnclient(timealreadypassed) {
  self endon("disconnect");
  self endon("end_respawn");
  level endon("game_ended");
  if(!isdefined(timealreadypassed)) {
    timealreadypassed = 0;
  }
  spawnedasspectator = 0;
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
      util::setlowermessage(&"MP_FRIENDLY_FIRE_WILL_NOT", teamkilldelay);
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
        spawnpoint = spawnlogic::getrandomintermissionpoint();
        if(isdefined(spawnpoint)) {
          spawnorigin = spawnpoint.origin;
          spawnangles = spawnpoint.angles;
        }
      }
      self thread respawn_asspectator(spawnorigin, spawnangles);
    }
    spawnedasspectator = 1;
    self globallogic_utils::waitfortimeornotify(timeuntilspawn, "force_spawn");
    self notify("stop_wait_safe_spawn_button");
  }
  wavebased = level.waverespawndelay > 0;
  if(!level.playerforcerespawn && self.hasspawned && !wavebased && !self.wantsafespawn && !level.playerqueuedrespawn) {
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
  self thread[[level.spawnplayer]]();
}

function waitrespawnorsafespawnbutton() {
  self endon("disconnect");
  self endon("end_respawn");
  while (true) {
    if(self usebuttonpressed()) {
      break;
    }
    wait(0.05);
  }
}

function waitinspawnqueue() {
  self endon("disconnect");
  self endon("end_respawn");
  if(!level.ingraceperiod && !level.usestartspawns) {
    currentorigin = self.origin;
    currentangles = self.angles;
    self thread[[level.spawnspectator]](currentorigin + vectorscale((0, 0, 1), 60), currentangles);
    self waittill("queue_respawn");
  }
}

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

function setspawnvariables() {
  resettimeout();
  self stopshellshock();
  self stoprumble("damage_heavy");
}