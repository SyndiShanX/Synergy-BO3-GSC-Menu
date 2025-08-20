/*************************************************
 * Decompiled by Serious and Edited by SyndiShanX
 * Script: mp\killstreaks\_airsupport.gsc
*************************************************/

#using scripts\codescripts\struct;
#using scripts\mp\_util;
#using scripts\shared\challenges_shared;
#using scripts\shared\damagefeedback_shared;
#using scripts\shared\math_shared;
#using scripts\shared\util_shared;
#using scripts\shared\weapons\_weaponobjects;
#using scripts\shared\weapons\_weapons;
#namespace airsupport;

function init() {
  if(!isdefined(level.airsupportheightscale)) {
    level.airsupportheightscale = 1;
  }
  level.airsupportheightscale = getdvarint("scr_airsupportHeightScale", level.airsupportheightscale);
  level.noflyzones = [];
  level.noflyzones = getentarray("no_fly_zone", "targetname");
  airsupport_heights = struct::get_array("air_support_height", "targetname");
  if(airsupport_heights.size > 1) {
    util::error("");
  }
  airsupport_heights = getentarray("air_support_height", "targetname");
  if(airsupport_heights.size > 0) {
    util::error("");
  }
  heli_height_meshes = getentarray("heli_height_lock", "classname");
  if(heli_height_meshes.size > 1) {
    util::error("");
  }
  initrotatingrig();
}

function finishhardpointlocationusage(location, usedcallback) {
  self notify("used");
  wait(0.05);
  if(isdefined(usedcallback)) {
    return self[[usedcallback]](location);
  }
  return 1;
}

function finishdualhardpointlocationusage(locationstart, locationend, usedcallback) {
  self notify("used");
  wait(0.05);
  return self[[usedcallback]](locationstart, locationend);
}

function endselectionongameend() {
  self endon("death");
  self endon("disconnect");
  self endon("cancel_location");
  self endon("used");
  self endon("host_migration_begin");
  level waittill("game_ended");
  self notify("game_ended");
}

function endselectiononhostmigration() {
  self endon("death");
  self endon("disconnect");
  self endon("cancel_location");
  self endon("used");
  self endon("game_ended");
  level waittill("host_migration_begin");
  self notify("cancel_location");
}

function endselectionthink() {
  assert(isplayer(self));
  assert(isalive(self));
  assert(isdefined(self.selectinglocation));
  assert(self.selectinglocation == 1);
  self thread endselectionongameend();
  self thread endselectiononhostmigration();
  event = self util::waittill_any_return("death", "disconnect", "cancel_location", "game_ended", "used", "weapon_change", "emp_jammed");
  if(event != "disconnect") {
    self.selectinglocation = undefined;
    self thread clearuplocationselection();
  }
  if(event != "used") {
    self notify("confirm_location", undefined, undefined);
  }
}

function clearuplocationselection() {
  event = self util::waittill_any_return("death", "disconnect", "game_ended", "used", "weapon_change", "emp_jammed", "weapon_change_complete");
  if(event != "disconnect") {
    self endlocationselection();
  }
}

function stoploopsoundaftertime(time) {
  self endon("death");
  wait(time);
  self stoploopsound(2);
}

function calculatefalltime(flyheight) {
  gravity = getdvarint("bg_gravity");
  time = sqrt((2 * flyheight) / gravity);
  return time;
}

function calculatereleasetime(flytime, flyheight, flyspeed, bombspeedscale) {
  falltime = calculatefalltime(flyheight);
  bomb_x = (flyspeed * bombspeedscale) * falltime;
  release_time = bomb_x / flyspeed;
  return (flytime * 0.5) - release_time;
}

function getminimumflyheight() {
  airsupport_height = struct::get("air_support_height", "targetname");
  if(isdefined(airsupport_height)) {
    planeflyheight = airsupport_height.origin[2];
  } else {
    println("");
    planeflyheight = 850;
    if(isdefined(level.airsupportheightscale)) {
      level.airsupportheightscale = getdvarint("scr_airsupportHeightScale", level.airsupportheightscale);
      planeflyheight = planeflyheight * getdvarint("scr_airsupportHeightScale", level.airsupportheightscale);
    }
    if(isdefined(level.forceairsupportmapheight)) {
      planeflyheight = planeflyheight + level.forceairsupportmapheight;
    }
  }
  return planeflyheight;
}

function callstrike(flightplan) {
  level.bomberdamagedents = [];
  level.bomberdamagedentscount = 0;
  level.bomberdamagedentsindex = 0;
  assert(flightplan.distance != 0, "");
  planehalfdistance = flightplan.distance / 2;
  path = getstrikepath(flightplan.target, flightplan.height, planehalfdistance);
  startpoint = path["start"];
  endpoint = path["end"];
  flightplan.height = path["height"];
  direction = path["direction"];
  d = length(startpoint - endpoint);
  flytime = d / flightplan.speed;
  bombtime = calculatereleasetime(flytime, flightplan.height, flightplan.speed, flightplan.bombspeedscale);
  if(bombtime < 0) {
    bombtime = 0;
  }
  assert(flytime > bombtime);
  flightplan.owner endon("disconnect");
  requireddeathcount = flightplan.owner.deathcount;
  side = vectorcross(anglestoforward(direction), (0, 0, 1));
  plane_seperation = 25;
  side_offset = vectorscale(side, plane_seperation);
  level thread planestrike(flightplan.owner, requireddeathcount, startpoint, endpoint, bombtime, flytime, flightplan.speed, flightplan.bombspeedscale, direction, flightplan.planespawncallback);
  wait(flightplan.planespacing);
  level thread planestrike(flightplan.owner, requireddeathcount, startpoint + side_offset, endpoint + side_offset, bombtime, flytime, flightplan.speed, flightplan.bombspeedscale, direction, flightplan.planespawncallback);
  wait(flightplan.planespacing);
  side_offset = vectorscale(side, -1 * plane_seperation);
  level thread planestrike(flightplan.owner, requireddeathcount, startpoint + side_offset, endpoint + side_offset, bombtime, flytime, flightplan.speed, flightplan.bombspeedscale, direction, flightplan.planespawncallback);
}

function planestrike(owner, requireddeathcount, pathstart, pathend, bombtime, flytime, flyspeed, bombspeedscale, direction, planespawnedfunction) {
  if(!isdefined(owner)) {
    return;
  }
  plane = spawnplane(owner, "script_model", pathstart);
  plane.angles = direction;
  plane moveto(pathend, flytime, 0, 0);
  thread debug_plane_line(flytime, flyspeed, pathstart, pathend);
  if(isdefined(planespawnedfunction)) {
    plane[[planespawnedfunction]](owner, requireddeathcount, pathstart, pathend, bombtime, bombspeedscale, flytime, flyspeed);
  }
  wait(flytime);
  plane notify("delete");
  plane delete();
}

function determinegroundpoint(player, position) {
  ground = (position[0], position[1], player.origin[2]);
  trace = bullettrace(ground + vectorscale((0, 0, 1), 10000), ground, 0, undefined);
  return trace["position"];
}

function determinetargetpoint(player, position) {
  point = determinegroundpoint(player, position);
  return clamptarget(point);
}

function getmintargetheight() {
  return level.spawnmins[2] - 500;
}

function getmaxtargetheight() {
  return level.spawnmaxs[2] + 500;
}

function clamptarget(target) {
  min = getmintargetheight();
  max = getmaxtargetheight();
  if(target[2] < min) {
    target[2] = min;
  }
  if(target[2] > max) {
    target[2] = max;
  }
  return target;
}

function _insidecylinder(point, base, radius, height) {
  if(isdefined(height)) {
    if(point[2] > (base[2] + height)) {
      return false;
    }
  }
  dist = distance2d(point, base);
  if(dist < radius) {
    return true;
  }
  return false;
}

function _insidenoflyzonebyindex(point, index, disregardheight) {
  height = level.noflyzones[index].height;
  if(isdefined(disregardheight)) {
    height = undefined;
  }
  return _insidecylinder(point, level.noflyzones[index].origin, level.noflyzones[index].radius, height);
}

function getnoflyzoneheight(point) {
  height = point[2];
  origin = undefined;
  for (i = 0; i < level.noflyzones.size; i++) {
    if(_insidenoflyzonebyindex(point, i)) {
      if(height < level.noflyzones[i].height) {
        height = level.noflyzones[i].height;
        origin = level.noflyzones[i].origin;
      }
    }
  }
  if(!isdefined(origin)) {
    return point[2];
  }
  return origin[2] + height;
}

function insidenoflyzones(point, disregardheight) {
  noflyzones = [];
  for (i = 0; i < level.noflyzones.size; i++) {
    if(_insidenoflyzonebyindex(point, i, disregardheight)) {
      noflyzones[noflyzones.size] = i;
    }
  }
  return noflyzones;
}

function crossesnoflyzone(start, end) {
  for (i = 0; i < level.noflyzones.size; i++) {
    point = math::closest_point_on_line(level.noflyzones[i].origin + (0, 0, 0.5 * level.noflyzones[i].height), start, end);
    dist = distance2d(point, level.noflyzones[i].origin);
    if(point[2] > (level.noflyzones[i].origin[2] + level.noflyzones[i].height)) {
      continue;
    }
    if(dist < level.noflyzones[i].radius) {
      return i;
    }
  }
  return undefined;
}

function crossesnoflyzones(start, end) {
  zones = [];
  for (i = 0; i < level.noflyzones.size; i++) {
    point = math::closest_point_on_line(level.noflyzones[i].origin, start, end);
    dist = distance2d(point, level.noflyzones[i].origin);
    if(point[2] > (level.noflyzones[i].origin[2] + level.noflyzones[i].height)) {
      continue;
    }
    if(dist < level.noflyzones[i].radius) {
      zones[zones.size] = i;
    }
  }
  return zones;
}

function getnoflyzoneheightcrossed(start, end, minheight) {
  height = minheight;
  for (i = 0; i < level.noflyzones.size; i++) {
    point = math::closest_point_on_line(level.noflyzones[i].origin, start, end);
    dist = distance2d(point, level.noflyzones[i].origin);
    if(dist < level.noflyzones[i].radius) {
      if(height < level.noflyzones[i].height) {
        height = level.noflyzones[i].height;
      }
    }
  }
  return height;
}

function _shouldignorenoflyzone(noflyzone, noflyzones) {
  if(!isdefined(noflyzone)) {
    return true;
  }
  for (i = 0; i < noflyzones.size; i++) {
    if(isdefined(noflyzones[i]) && noflyzones[i] == noflyzone) {
      return true;
    }
  }
  return false;
}

function _shouldignorestartgoalnoflyzone(noflyzone, startnoflyzones, goalnoflyzones) {
  if(!isdefined(noflyzone)) {
    return true;
  }
  if(_shouldignorenoflyzone(noflyzone, startnoflyzones)) {
    return true;
  }
  if(_shouldignorenoflyzone(noflyzone, goalnoflyzones)) {
    return true;
  }
  return false;
}

function gethelipath(start, goal) {
  startnoflyzones = insidenoflyzones(start, 1);
  thread debug_line(start, goal, (1, 1, 1));
  goalnoflyzones = insidenoflyzones(goal);
  if(goalnoflyzones.size) {
    goal = (goal[0], goal[1], getnoflyzoneheight(goal));
  }
  goal_points = calculatepath(start, goal, startnoflyzones, goalnoflyzones);
  if(!isdefined(goal_points)) {
    return undefined;
  }
  assert(goal_points.size >= 1);
  return goal_points;
}

function followpath(path, donenotify, stopatgoal) {
  for (i = 0; i < (path.size - 1); i++) {
    self setvehgoalpos(path[i], 0);
    thread debug_line(self.origin, path[i], (1, 1, 0));
    self waittill("goal");
  }
  self setvehgoalpos(path[path.size - 1], stopatgoal);
  thread debug_line(self.origin, path[i], (1, 1, 0));
  self waittill("goal");
  if(isdefined(donenotify)) {
    self notify(donenotify);
  }
}

function setgoalposition(goal, donenotify, stopatgoal = 1) {
  start = self.origin;
  goal_points = gethelipath(start, goal);
  if(!isdefined(goal_points)) {
    goal_points = [];
    goal_points[0] = goal;
  }
  followpath(goal_points, donenotify, stopatgoal);
}

function clearpath(start, end, startnoflyzone, goalnoflyzone) {
  noflyzones = crossesnoflyzones(start, end);
  for (i = 0; i < noflyzones.size; i++) {
    if(!_shouldignorestartgoalnoflyzone(noflyzones[i], startnoflyzone, goalnoflyzone)) {
      return false;
    }
  }
  return true;
}

function append_array(dst, src) {
  for (i = 0; i < src.size; i++) {
    dst[dst.size] = src[i];
  }
}

function calculatepath_r(start, end, points, startnoflyzones, goalnoflyzones, depth) {
  depth--;
  if(depth <= 0) {
    points[points.size] = end;
    return points;
  }
  noflyzones = crossesnoflyzones(start, end);
  for (i = 0; i < noflyzones.size; i++) {
    noflyzone = noflyzones[i];
    if(!_shouldignorestartgoalnoflyzone(noflyzone, startnoflyzones, goalnoflyzones)) {
      return undefined;
    }
  }
  points[points.size] = end;
  return points;
}

function calculatepath(start, end, startnoflyzones, goalnoflyzones) {
  points = [];
  points = calculatepath_r(start, end, points, startnoflyzones, goalnoflyzones, 3);
  if(!isdefined(points)) {
    return undefined;
  }
  assert(points.size >= 1);
  debug_sphere(points[points.size - 1], 10, (1, 0, 0), 1, 1000);
  point = start;
  for (i = 0; i < points.size; i++) {
    thread debug_line(point, points[i], (0, 1, 0));
    debug_sphere(points[i], 10, (0, 0, 1), 1, 1000);
    point = points[i];
  }
  return points;
}

function _getstrikepathstartandend(goal, yaw, halfdistance) {
  direction = (0, yaw, 0);
  startpoint = goal + (vectorscale(anglestoforward(direction), -1 * halfdistance));
  endpoint = goal + vectorscale(anglestoforward(direction), halfdistance);
  noflyzone = crossesnoflyzone(startpoint, endpoint);
  path = [];
  if(isdefined(noflyzone)) {
    path["noFlyZone"] = noflyzone;
    startpoint = (startpoint[0], startpoint[1], level.noflyzones[noflyzone].origin[2] + level.noflyzones[noflyzone].height);
    endpoint = (endpoint[0], endpoint[1], startpoint[2]);
  } else {
    path["noFlyZone"] = undefined;
  }
  path["start"] = startpoint;
  path["end"] = endpoint;
  path["direction"] = direction;
  return path;
}

function getstrikepath(target, height, halfdistance, yaw) {
  noflyzoneheight = getnoflyzoneheight(target);
  worldheight = target[2] + height;
  if(noflyzoneheight > worldheight) {
    worldheight = noflyzoneheight;
  }
  goal = (target[0], target[1], worldheight);
  path = [];
  if(!isdefined(yaw) || yaw != "random") {
    for (i = 0; i < 3; i++) {
      path = _getstrikepathstartandend(goal, randomint(360), halfdistance);
      if(!isdefined(path["noFlyZone"])) {
        break;
      }
    }
  } else {
    path = _getstrikepathstartandend(goal, yaw, halfdistance);
  }
  path["height"] = worldheight - target[2];
  return path;
}

function doglassdamage(pos, radius, max, min, mod) {
  wait(randomfloatrange(0.05, 0.15));
  glassradiusdamage(pos, radius, max, min, mod);
}

function entlosradiusdamage(ent, pos, radius, max, min, owner, einflictor) {
  dist = distance(pos, ent.damagecenter);
  if(ent.isplayer || ent.isactor) {
    assumed_ceiling_height = 800;
    eye_position = ent.entity geteye();
    head_height = eye_position[2];
    debug_display_time = 4000;
    trace = weapons::damage_trace(ent.entity.origin, ent.entity.origin + (0, 0, assumed_ceiling_height), 0, undefined);
    indoors = trace["fraction"] != 1;
    if(indoors) {
      test_point = trace["position"];
      debug_star(test_point, (0, 1, 0), debug_display_time);
      trace = weapons::damage_trace((test_point[0], test_point[1], head_height), (pos[0], pos[1], head_height), 0, undefined);
      indoors = trace["fraction"] != 1;
      if(indoors) {
        debug_star((pos[0], pos[1], head_height), (0, 1, 0), debug_display_time);
        dist = dist * 4;
        if(dist > radius) {
          return false;
        }
      } else {
        debug_star((pos[0], pos[1], head_height), (1, 0, 0), debug_display_time);
        trace = weapons::damage_trace((pos[0], pos[1], head_height), pos, 0, undefined);
        indoors = trace["fraction"] != 1;
        if(indoors) {
          debug_star(pos, (0, 1, 0), debug_display_time);
          dist = dist * 4;
          if(dist > radius) {
            return false;
          }
        } else {
          debug_star(pos, (1, 0, 0), debug_display_time);
        }
      }
    } else {
      debug_star(ent.entity.origin + (0, 0, assumed_ceiling_height), (1, 0, 0), debug_display_time);
    }
  }
  ent.damage = int(max + (((min - max) * dist) / radius));
  ent.pos = pos;
  ent.damageowner = owner;
  ent.einflictor = einflictor;
  return true;
}

function getmapcenter() {
  minimaporigins = getentarray("minimap_corner", "targetname");
  if(minimaporigins.size) {
    return math::find_box_center(minimaporigins[0].origin, minimaporigins[1].origin);
  }
  return (0, 0, 0);
}

function getrandommappoint(x_offset, y_offset, map_x_percentage, map_y_percentage) {
  minimaporigins = getentarray("minimap_corner", "targetname");
  if(minimaporigins.size) {
    rand_x = 0;
    rand_y = 0;
    if(minimaporigins[0].origin[0] < minimaporigins[1].origin[0]) {
      rand_x = randomfloatrange(minimaporigins[0].origin[0] * map_x_percentage, minimaporigins[1].origin[0] * map_x_percentage);
      rand_y = randomfloatrange(minimaporigins[0].origin[1] * map_y_percentage, minimaporigins[1].origin[1] * map_y_percentage);
    } else {
      rand_x = randomfloatrange(minimaporigins[1].origin[0] * map_x_percentage, minimaporigins[0].origin[0] * map_x_percentage);
      rand_y = randomfloatrange(minimaporigins[1].origin[1] * map_y_percentage, minimaporigins[0].origin[1] * map_y_percentage);
    }
    return (x_offset + rand_x, y_offset + rand_y, 0);
  }
  return (x_offset, y_offset, 0);
}

function getmaxmapwidth() {
  minimaporigins = getentarray("minimap_corner", "targetname");
  if(minimaporigins.size) {
    x = abs(minimaporigins[0].origin[0] - minimaporigins[1].origin[0]);
    y = abs(minimaporigins[0].origin[1] - minimaporigins[1].origin[1]);
    return max(x, y);
  }
  return 0;
}

function initrotatingrig() {
  level.airsupport_rotator = spawn("script_model", getmapcenter() + ((isdefined(level.rotator_x_offset) ? level.rotator_x_offset : 0), (isdefined(level.rotator_y_offset) ? level.rotator_y_offset : 0), 1200));
  level.airsupport_rotator setmodel("tag_origin");
  level.airsupport_rotator.angles = vectorscale((0, 1, 0), 115);
  level.airsupport_rotator hide();
  level.airsupport_rotator thread rotaterig();
  level.airsupport_rotator thread swayrig();
}

function rotaterig() {
  for (;;) {
    self rotateyaw(-360, 60);
    wait(60);
  }
}

function swayrig() {
  centerorigin = self.origin;
  for (;;) {
    z = randomintrange(-200, -100);
    time = randomintrange(3, 6);
    self moveto(centerorigin + (0, 0, z), time, 1, 1);
    wait(time);
    z = randomintrange(100, 200);
    time = randomintrange(3, 6);
    self moveto(centerorigin + (0, 0, z), time, 1, 1);
    wait(time);
  }
}

function stoprotation(time) {
  self endon("death");
  wait(time);
  self stoploopsound();
}

function flattenyaw(goal) {
  self endon("death");
  increment = 3;
  if(self.angles[1] > goal) {
    increment = increment * -1;
  }
  while ((abs(self.angles[1] - goal)) > 3) {
    self.angles = (self.angles[0], self.angles[1] + increment, self.angles[2]);
    wait(0.05);
  }
}

function flattenroll() {
  self endon("death");
  while (self.angles[2] < 0) {
    self.angles = (self.angles[0], self.angles[1], self.angles[2] + 2.5);
    wait(0.05);
  }
}

function leave(duration) {
  self unlink();
  self thread stoprotation(1);
  tries = 10;
  yaw = 0;
  while (tries > 0) {
    exitvector = (anglestoforward(self.angles + (0, yaw, 0))) * 20000;
    exitpoint = (self.origin[0] + exitvector[0], self.origin[1] + exitvector[1], self.origin[2] - 2500);
    exitpoint = self.origin + exitvector;
    nfz = crossesnoflyzone(self.origin, exitpoint);
    if(isdefined(nfz)) {
      if(tries != 1) {
        if((tries % 2) == 1) {
          yaw = yaw * -1;
        } else {
          yaw = yaw + 10;
          yaw = yaw * -1;
        }
      }
      tries--;
    } else {
      tries = 0;
    }
  }
  self thread flattenyaw(self.angles[1] + yaw);
  if(self.angles[2] != 0) {
    self thread flattenroll();
  }
  if(isvehicle(self)) {
    self setspeed((length(exitvector) / duration) / 17.6, 60);
    self setvehgoalpos(exitpoint, 0, 0);
  } else {
    self moveto(exitpoint, duration, 0, 0);
  }
  self notify("leaving");
}

function getrandomhelicopterstartorigin() {
  dist = -1 * getdvarint("scr_supplydropIncomingDistance", 10000);
  pathrandomness = 100;
  direction = (0, randomintrange(-2, 3), 0);
  start_origin = anglestoforward(direction) * dist;
  start_origin = start_origin + ((randomfloat(2) - 1) * pathrandomness, (randomfloat(2) - 1) * pathrandomness, 0);
  if(getdvarint("", 0)) {
    if(level.noflyzones.size) {
      index = randomintrange(0, level.noflyzones.size);
      delta = level.noflyzones[index].origin;
      delta = (delta[0] + randomint(10), delta[1] + randomint(10), 0);
      delta = vectornormalize(delta);
      start_origin = delta * dist;
    }
  }
  return start_origin;
}

function debug_no_fly_zones() {
  for (i = 0; i < level.noflyzones.size; i++) {
    debug_airsupport_cylinder(level.noflyzones[i].origin, level.noflyzones[i].radius, level.noflyzones[i].height, (1, 1, 1), undefined, 5000);
  }
}

function debug_plane_line(flytime, flyspeed, pathstart, pathend) {
  thread debug_line(pathstart, pathend, (1, 1, 1));
  delta = vectornormalize(pathend - pathstart);
  for (i = 0; i < flytime; i++) {
    thread debug_star(pathstart + (vectorscale(delta, i * flyspeed)), (1, 0, 0));
  }
}

function debug_draw_bomb_explosion(prevpos) {
  self notify("draw_explosion");
  wait(0.05);
  self endon("draw_explosion");
  self waittill("projectile_impact", weapon, position);
  thread debug_line(prevpos, position, (0.5, 1, 0));
  thread debug_star(position, (1, 0, 0));
}

function debug_draw_bomb_path(projectile, color, time) {
  self endon("death");
  level.airsupport_debug = getdvarint("", 0);
  if(!isdefined(color)) {
    color = (0.5, 1, 0);
  }
  if(isdefined(level.airsupport_debug) && level.airsupport_debug == 1) {
    prevpos = self.origin;
    while (isdefined(self.origin)) {
      thread debug_line(prevpos, self.origin, color, time);
      prevpos = self.origin;
      if(isdefined(projectile) && projectile) {
        thread debug_draw_bomb_explosion(prevpos);
      }
      wait(0.2);
    }
  }
}

function debug_print3d_simple(message, ent, offset, frames) {
  level.airsupport_debug = getdvarint("", 0);
  if(isdefined(level.airsupport_debug) && level.airsupport_debug == 1) {
    if(isdefined(frames)) {
      thread draw_text(message, vectorscale((1, 1, 1), 0.8), ent, offset, frames);
    } else {
      thread draw_text(message, vectorscale((1, 1, 1), 0.8), ent, offset, 0);
    }
  }
}

function draw_text(msg, color, ent, offset, frames) {
  if(frames == 0) {
    while (isdefined(ent) && isdefined(ent.origin)) {
      print3d(ent.origin + offset, msg, color, 0.5, 4);
      wait(0.05);
    }
  } else {
    for (i = 0; i < frames; i++) {
      if(!isdefined(ent)) {
        break;
      }
      print3d(ent.origin + offset, msg, color, 0.5, 4);
      wait(0.05);
    }
  }
}

function debug_print3d(message, color, ent, origin_offset, frames) {
  level.airsupport_debug = getdvarint("", 0);
  if(isdefined(level.airsupport_debug) && level.airsupport_debug == 1) {
    self thread draw_text(message, color, ent, origin_offset, frames);
  }
}

function debug_line(from, to, color, time, depthtest) {
  level.airsupport_debug = getdvarint("", 0);
  if(isdefined(level.airsupport_debug) && level.airsupport_debug == 1) {
    if(distancesquared(from, to) < 0.01) {
      return;
    }
    if(!isdefined(time)) {
      time = 1000;
    }
    if(!isdefined(depthtest)) {
      depthtest = 1;
    }
    line(from, to, color, 1, depthtest, time);
  }
}

function debug_star(origin, color, time) {
  level.airsupport_debug = getdvarint("", 0);
  if(isdefined(level.airsupport_debug) && level.airsupport_debug == 1) {
    if(!isdefined(time)) {
      time = 1000;
    }
    if(!isdefined(color)) {
      color = (1, 1, 1);
    }
    debugstar(origin, time, color);
  }
}

function debug_circle(origin, radius, color, time) {
  level.airsupport_debug = getdvarint("", 0);
  if(isdefined(level.airsupport_debug) && level.airsupport_debug == 1) {
    if(!isdefined(time)) {
      time = 1000;
    }
    if(!isdefined(color)) {
      color = (1, 1, 1);
    }
    circle(origin, radius, color, 1, 1, time);
  }
}

function debug_sphere(origin, radius, color, alpha, time) {
  level.airsupport_debug = getdvarint("", 0);
  if(isdefined(level.airsupport_debug) && level.airsupport_debug == 1) {
    if(!isdefined(time)) {
      time = 1000;
    }
    if(!isdefined(color)) {
      color = (1, 1, 1);
    }
    sides = int(10 * (1 + (int(radius / 100))));
    sphere(origin, radius, color, alpha, 1, sides, time);
  }
}

function debug_airsupport_cylinder(origin, radius, height, color, mustrenderheight, time) {
  level.airsupport_debug = getdvarint("", 0);
  if(isdefined(level.airsupport_debug) && level.airsupport_debug == 1) {
    debug_cylinder(origin, radius, height, color, mustrenderheight, time);
  }
}

function debug_cylinder(origin, radius, height, color, mustrenderheight, time) {
  subdivision = 600;
  if(!isdefined(time)) {
    time = 1000;
  }
  if(!isdefined(color)) {
    color = (1, 1, 1);
  }
  count = height / subdivision;
  for (i = 0; i < count; i++) {
    point = origin + (0, 0, i * subdivision);
    circle(point, radius, color, 1, 1, time);
  }
  if(isdefined(mustrenderheight)) {
    point = origin + (0, 0, mustrenderheight);
    circle(point, radius, color, 1, 1, time);
  }
}

function getpointonline(startpoint, endpoint, ratio) {
  nextpoint = (startpoint[0] + ((endpoint[0] - startpoint[0]) * ratio), startpoint[1] + ((endpoint[1] - startpoint[1]) * ratio), startpoint[2] + ((endpoint[2] - startpoint[2]) * ratio));
  return nextpoint;
}

function cantargetplayerwithspecialty() {
  if(self hasperk("specialty_nottargetedbyairsupport") || (isdefined(self.specialty_nottargetedbyairsupport) && self.specialty_nottargetedbyairsupport)) {
    if(!isdefined(self.nottargettedai_underminspeedtimer) || self.nottargettedai_underminspeedtimer < getdvarint("perk_nottargetedbyai_graceperiod")) {
      return false;
    }
  }
  return true;
}

function monitorspeed(spawnprotectiontime) {
  self endon("death");
  self endon("disconnect");
  if(self hasperk("specialty_nottargetedbyairsupport") == 0) {
    return;
  }
  getdvarstring("perk_nottargetted_graceperiod");
  graceperiod = getdvarint("perk_nottargetedbyai_graceperiod");
  minspeed = getdvarint("perk_nottargetedbyai_min_speed");
  minspeedsq = minspeed * minspeed;
  waitperiod = 0.25;
  waitperiodmilliseconds = waitperiod * 1000;
  if(minspeedsq == 0) {
    return;
  }
  self.nottargettedai_underminspeedtimer = 0;
  if(isdefined(spawnprotectiontime)) {
    wait(spawnprotectiontime);
  }
  while (true) {
    velocity = self getvelocity();
    speedsq = lengthsquared(velocity);
    if(speedsq < minspeedsq) {
      self.nottargettedai_underminspeedtimer = self.nottargettedai_underminspeedtimer + waitperiodmilliseconds;
    } else {
      self.nottargettedai_underminspeedtimer = 0;
    }
    wait(waitperiod);
  }
}

function clearmonitoredspeed() {
  if(isdefined(self.nottargettedai_underminspeedtimer)) {
    self.nottargettedai_underminspeedtimer = 0;
  }
}