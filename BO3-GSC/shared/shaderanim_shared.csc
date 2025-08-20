/*************************************************
 * Decompiled by Serious and Edited by SyndiShanX
 * Script: shared\shaderanim_shared.csc
*************************************************/

#namespace shaderanim;

function animate_crack(localclientnum, vectorname, delay, duration, start, end) {
  self endon("entityshutdown");
  delayseconds = delay / 60;
  wait(delayseconds);
  direction = 1;
  if(start > end) {
    direction = -1;
  }
  durationseconds = duration / 60;
  valstep = 0;
  if(durationseconds > 0) {
    valstep = (end - start) / (durationseconds / 0.01);
  }
  timestep = 0.01 * direction;
  value = start;
  self mapshaderconstant(localclientnum, 0, vectorname, value, 0, 0, 0);
  i = 0;
  while (i < durationseconds) {
    value = value + valstep;
    wait(0.01);
    self mapshaderconstant(localclientnum, 0, vectorname, value, 0, 0, 0);
    i = i + timestep;
  }
  self mapshaderconstant(localclientnum, 0, vectorname, end, 0, 0, 0);
}

function shaderanim_update_opacity(entity, localclientnum, opacity) {
  entity mapshaderconstant(localclientnum, 0, "scriptVector0", opacity, 0, 0, 0);
}