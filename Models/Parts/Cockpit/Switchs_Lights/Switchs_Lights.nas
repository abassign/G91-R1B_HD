var timer_cockpit_switch_lights = maketimer(0.2, func() {

    var battery_V = props.globals.getNode("fdm/jsbsim/systems/electric/bus[0]/battery-V",1).getValue();
    var light_by_tension_battery = battery_V / 24.0;
    var primaryBus_V = props.globals.getNode("fdm/jsbsim/systems/electric/bus[1]/V",1).getValue();
    var light_by_tension_primaryBus = primaryBus_V / 24.0;
    
    var sw_inv_prim = props.globals.getNode("fdm/jsbsim/systems/electric/bus[2]/primary-inverter/sw",1).getValue();
    if (sw_inv_prim > 0 and light_by_tension_primaryBus > 0.2) {
        setprop("sim/G91/switchs/cockpit/lg_inv_prim_on", light_by_tension_primaryBus);
        setprop("sim/G91/switchs/cockpit/lg_inv_prim_transparent", 0.1);
    } else {
        setprop("sim/G91/switchs/cockpit/lg_inv_prim_on", 0);
        setprop("sim/G91/switchs/cockpit/lg_inv_prim_transparent", 0.85);
    }
    
    var sw_inv_sec = props.globals.getNode("fdm/jsbsim/systems/electric/bus[1]/secondary-inverter/sw",1).getValue();
    if (sw_inv_sec > 0 and light_by_tension_primaryBus > 0.2) {
        setprop("sim/G91/switchs/cockpit/lg_inv_sec_on", light_by_tension_primaryBus);
        setprop("sim/G91/switchs/cockpit/lg_inv_sec_transparent", 0.1);
    } else {
        setprop("sim/G91/switchs/cockpit/lg_inv_sec_on", 0);
        setprop("sim/G91/switchs/cockpit/lg_inv_sec_transparent", 0.85);
    }
    
    var sw_collect_tank = props.globals.getNode("fdm/jsbsim/systems/electric/bus[1]/fuel-level-indicator/sw",1).getValue();
    if (sw_collect_tank > 0 and light_by_tension_primaryBus > 0.2) {
        setprop("sim/G91/switchs/cockpit/lg_collect_tank_2_all_tank_on", light_by_tension_primaryBus);
        setprop("sim/G91/switchs/cockpit/lg_collect_tank_2_all_tank_transparent", 0.2);
    } else {
        setprop("sim/G91/switchs/cockpit/lg_collect_tank_2_all_tank_on", 0);
        setprop("sim/G91/switchs/cockpit/lg_collect_tank_2_all_tank_transparent", 0.85);
    }
    
});
timer_cockpit_switch_lights.start();

