/*************************************************
 * Decompiled by Serious and Edited by SyndiShanX
 * Script: zm\_zm_equipment.csc
*************************************************/

#using scripts\codescripts\struct;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#namespace zm_equipment;

function autoexec __init__sytem__() {
  system::register("zm_equipment", & __init__, undefined, undefined);
}

function __init__() {
  level._equip_activated_callbacks = [];
  level.buildable_piece_count = 24;
  if(!(isdefined(level._no_equipment_activated_clientfield) && level._no_equipment_activated_clientfield)) {
    clientfield::register("scriptmover", "equipment_activated", 1, 4, "int", & equipment_activated_clientfield_cb, 1, 0);
  }
}

function add_equip_activated_callback_override(model, func) {
  level._equip_activated_callbacks[model] = func;
}

function equipment_activated_clientfield_cb(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump) {
  if(isdefined(self.model) && isdefined(level._equip_activated_callbacks[self.model])) {
    [
      [level._equip_activated_callbacks[self.model]]
    ](localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump);
  }
  if(!newval) {
    if(isdefined(self._equipment_activated_fx)) {
      for (i = 0; i < self._equipment_activated_fx.size; i++) {
        for (j = 0; j < self._equipment_activated_fx[i].size; j++) {
          deletefx(i, self._equipment_activated_fx[i][j]);
        }
      }
      self._equipment_activated_fx = undefined;
    }
  }
}

function play_fx_for_all_clients(fx, tag, storehandles = 0, forward = undefined) {
  numlocalplayers = getlocalplayers().size;
  if(!isdefined(self._equipment_activated_fx)) {
    self._equipment_activated_fx = [];
    for (i = 0; i < numlocalplayers; i++) {
      self._equipment_activated_fx[i] = [];
    }
  }
  if(isdefined(tag)) {
    for (i = 0; i < numlocalplayers; i++) {
      if(storehandles) {
        self._equipment_activated_fx[i][self._equipment_activated_fx[i].size] = playfxontag(i, fx, self, tag);
        continue;
      }
      self_for_client = getentbynum(i, self getentitynumber());
      if(isdefined(self_for_client)) {
        playfxontag(i, fx, self_for_client, tag);
      }
    }
  } else {
    for (i = 0; i < numlocalplayers; i++) {
      if(storehandles) {
        if(isdefined(forward)) {
          self._equipment_activated_fx[i][self._equipment_activated_fx[i].size] = playfx(i, fx, self.origin, forward);
        } else {
          self._equipment_activated_fx[i][self._equipment_activated_fx[i].size] = playfx(i, fx, self.origin);
        }
        continue;
      }
      if(isdefined(forward)) {
        playfx(i, fx, self.origin, forward);
        continue;
      }
      playfx(i, fx, self.origin);
    }
  }
}

function is_included(equipment) {
  if(!isdefined(level._included_equipment)) {
    return 0;
  }
  return isdefined(level._included_equipment[equipment.rootweapon]);
}

function include(equipment_name) {
  if(!isdefined(level._included_equipment)) {
    level._included_equipment = [];
  }
  equipment = getweapon(equipment_name);
  level._included_equipment[equipment] = equipment;
}