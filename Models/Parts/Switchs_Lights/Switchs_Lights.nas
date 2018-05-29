# Setta il sistema elettrico per i test, serve solo per verificare le utenze da gestire

#var prop = props.globals.initNode("sim/G91/switchs/cockpit/lg_battery_on", 0, "DOUBLE");
#var prop = props.globals.initNode("sim/G91/switchs/cockpit/lg_battery_transparent", 0.9, "DOUBLE");

setlistener("sim/G91/switchs/cockpit/sw_battery", func {
var electrical_serviceable = props.globals.getNode("systems/electrical/serviceable",1).getValue();
var sw_battery = props.globals.getNode("sim/G91/switchs/cockpit/sw_battery",1).getValue();
    if (electrical_serviceable and sw_battery) {
        setprop("sim/G91/switchs/cockpit/lg_battery_on", 1);
        setprop("sim/G91/switchs/cockpit/lg_battery_transparent", 0.1);
    } else {
        setprop("sim/G91/switchs/cockpit/lg_battery_on", 0);
        setprop("sim/G91/switchs/cockpit/lg_battery_transparent", 0.85);
    }
}, 1, 0);

setlistener("sim/G91/switchs/cockpit/sw_generator", func {
var electrical_serviceable = props.globals.getNode("systems/electrical/serviceable",1).getValue();
var sw_generator = props.globals.getNode("sim/G91/switchs/cockpit/sw_generator",1).getValue();
    if (electrical_serviceable and sw_generator) {
        setprop("sim/G91/switchs/cockpit/lg_generator_on", 1);
        setprop("sim/G91/switchs/cockpit/lg_generator_transparent", 0.1);
    } else {
        setprop("sim/G91/switchs/cockpit/lg_generator_on", 0);
        setprop("sim/G91/switchs/cockpit/lg_generator_transparent", 0.85);
    }
}, 1, 0);

setlistener("sim/G91/switchs/cockpit/sw_inv_prim", func {
var electrical_serviceable = props.globals.getNode("systems/electrical/serviceable",1).getValue();
var sw_inv_prim = props.globals.getNode("sim/G91/switchs/cockpit/sw_inv_prim",1).getValue();
    if (electrical_serviceable and sw_inv_prim) {
        setprop("sim/G91/switchs/cockpit/lg_inv_prim_on", 1);
        setprop("sim/G91/switchs/cockpit/lg_inv_prim_transparent", 0.1);
    } else {
        setprop("sim/G91/switchs/cockpit/lg_inv_prim_on", 0);
        setprop("sim/G91/switchs/cockpit/lg_inv_prim_transparent", 0.85);
    }
}, 1, 0);

setlistener("sim/G91/switchs/cockpit/sw_inv_sec", func {
var electrical_serviceable = props.globals.getNode("systems/electrical/serviceable",1).getValue();
var sw_inv_sec = props.globals.getNode("sim/G91/switchs/cockpit/sw_inv_sec",1).getValue();
    if (electrical_serviceable and sw_inv_sec) {
        setprop("sim/G91/switchs/cockpit/lg_inv_sec_on", 1);
        setprop("sim/G91/switchs/cockpit/lg_inv_sec_transparent", 0.1);
    } else {
        setprop("sim/G91/switchs/cockpit/lg_inv_sec_on", 0);
        setprop("sim/G91/switchs/cockpit/lg_inv_sec_transparent", 0.85);
    }
}, 1, 0);

setlistener("sim/G91/switchs/cockpit/sw_collect_tank_2_all_tank", func {
var electrical_serviceable = props.globals.getNode("systems/electrical/serviceable",1).getValue();
var sw_collect_tank = props.globals.getNode("sim/G91/switchs/cockpit/sw_collect_tank_2_all_tank",1).getValue();
    if (electrical_serviceable and sw_collect_tank) {
        setprop("sim/G91/switchs/cockpit/lg_collect_tank_2_all_tank_on", 1);
        setprop("sim/G91/switchs/cockpit/lg_collect_tank_2_all_tank_transparent", 0.1);
    } else {
        setprop("sim/G91/switchs/cockpit/lg_collect_tank_2_all_tank_on", 0);
        setprop("sim/G91/switchs/cockpit/lg_collect_tank_2_all_tank_transparent", 0.85);
    }
}, 1, 0);
