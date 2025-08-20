/*******************************************************
 * Decompiled by Serious and Edited by SyndiShanX
 * Script: shared\ai\systems\behavior_tree_utility.gsc
*******************************************************/

#namespace behaviortreenetwork;

function registerbehaviortreescriptapiinternal(functionname, functionptr) {
  if(!isdefined(level._behaviortreescriptfunctions)) {
    level._behaviortreescriptfunctions = [];
  }
  functionname = tolower(functionname);
  assert(isdefined(functionname) && isdefined(functionptr), "");
  assert(!isdefined(level._behaviortreescriptfunctions[functionname]), "");
  level._behaviortreescriptfunctions[functionname] = functionptr;
}

function registerbehaviortreeactioninternal(actionname, startfuncptr, updatefuncptr, terminatefuncptr) {
  if(!isdefined(level._behaviortreeactions)) {
    level._behaviortreeactions = [];
  }
  actionname = tolower(actionname);
  assert(isstring(actionname), "");
  assert(!isdefined(level._behaviortreeactions[actionname]), ("" + actionname) + "");
  level._behaviortreeactions[actionname] = array();
  if(isdefined(startfuncptr)) {
    assert(isfunctionptr(startfuncptr), "");
    level._behaviortreeactions[actionname]["bhtn_action_start"] = startfuncptr;
  }
  if(isdefined(updatefuncptr)) {
    assert(isfunctionptr(updatefuncptr), "");
    level._behaviortreeactions[actionname]["bhtn_action_update"] = updatefuncptr;
  }
  if(isdefined(terminatefuncptr)) {
    assert(isfunctionptr(terminatefuncptr), "");
    level._behaviortreeactions[actionname]["bhtn_action_terminate"] = terminatefuncptr;
  }
}

#namespace behaviortreenetworkutility;

function registerbehaviortreescriptapi(functionname, functionptr) {
  behaviortreenetwork::registerbehaviortreescriptapiinternal(functionname, functionptr);
}

function registerbehaviortreeaction(actionname, startfuncptr, updatefuncptr, terminatefuncptr) {
  behaviortreenetwork::registerbehaviortreeactioninternal(actionname, startfuncptr, updatefuncptr, terminatefuncptr);
}