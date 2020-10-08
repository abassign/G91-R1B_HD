# PHI - Route manager binding
#
# Adriano Bassignana - Bergamo 2019
#

var delta_time_standard = 1.0;
var delta_time = delta_time_standard;

var isRouteActivate = 0;
var isRouteActivated = 0;
var set_activate_new_route = 0;

var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual", "0", "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual-mod", "0", "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop", "0", "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-mod", "0", "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-left", "0", "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-left-mod", "0", "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-right", "0", "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-right-mod", "0", "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/declination-automatic", "1", "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/phi-heading-to-activate", "0", "INT");


var phi_get_route_data = func() {

    if (getprop("fdm/jsbsim/systems/autopilot/gui/phi-heading-to-activate") > 0) {
        #// phi-heading is activate only some time after
        setprop("fdm/jsbsim/systems/gauges/PHI/indicator/switch-turn",1);
        setprop("fdm/jsbsim/systems/autopilot/gui/phi-heading",1);
        setprop("fdm/jsbsim/systems/autopilot/gui/phi-heading-to-activate",0);
    }
    
    if (getprop("fdm/jsbsim/systems/gauges/PHI/programmer/declination-automatic") >= 1.0) {
        setprop("fdm/jsbsim/systems/gauges/PHI/indicator/var-deg",math.round(getprop("/instrumentation/heading-indicator/offset-deg")));
    }
    
    # Wind system
    
    var automatic_wind_sw = getprop("/fdm/jsbsim/systems/gauges/PHI/wind/automatic-wind-sw");
    
    if (automatic_wind_sw == 1) {
        var wind_direction = getprop("/environment/wind-from-heading-deg");
        var wind_speed = getprop("/environment/wind-speed-kt");
        setprop("/fdm/jsbsim/systems/gauges/PHI/wind/wd",wind_direction);
        setprop("/fdm/jsbsim/systems/gauges/PHI/wind/ws",wind_speed);
    }

};


var activate_new_route = func() {
    if (set_activate_new_route >= 1) {
        delta_time = 0.5;
        if (getprop("fdm/jsbsim/systems/gauges/PHI/program/reset") == 0) {
            setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",40.0);
            setprop("fdm/jsbsim/systems/gauges/PHI/wind/automatic-wind-sw",1);
            setprop("fdm/jsbsim/systems/gauges/PHI/program/route-manager/autopush-active",1);
            if (set_activate_new_route < 10) {
                setprop("fdm/jsbsim/systems/gauges/PHI/indicator/switch-turn",1);
                setprop("fdm/jsbsim/systems/autopilot/gui/phi-heading-to-activate",1);
            }
        }
        if (set_activate_new_route == 2) {
            if (getprop("fdm/jsbsim/systems/autopilot/gui/landing-activate") == 0) {
                setprop("fdm/jsbsim/systems/autopilot/gui/landing-activate",1);
            }
        }
        set_activate_new_route = 0;
    } else {
        delta_time = delta_time_standard;
    }
}


setlistener("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-mod", func {
    var route_automatic_loop = getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop");
    if (getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-mod") == 1
        and getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop") == 1) {
        setprop("/autopilot/route-manager/active",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-left",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-right",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/reset",1);
        var heading_true_deg = math.round(getprop("fdm/jsbsim/systems/autopilot/heading-true-deg"));
        var altitudeHold = math.round(getprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft"));
        if (altitudeHold <= 0.0) altitudeHold = 15000.0;
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[1]/dist",10);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[1]/phi",heading_true_deg);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[1]/altitude-hold-ft",altitudeHold);
        var heading_true_deg_90 = math.round(heading_true_deg + 90.0);
        if (heading_true_deg_90 > 360) heading_true_deg_90 = heading_true_deg_90 - 360;
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[2]/dist",10);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[2]/phi",heading_true_deg_90);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[2]/altitude-hold-ft",altitudeHold);
        var heading_true_deg_180 = math.round(heading_true_deg + 180.0);
        if (heading_true_deg_180 > 360) heading_true_deg_180 = heading_true_deg_180 - 360;
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[3]/dist",10);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[3]/phi",heading_true_deg_180);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[3]/altitude-hold-ft",altitudeHold);
        var heading_true_deg_270 = math.round(heading_true_deg + 270.0);
        if (heading_true_deg_270 > 360) heading_true_deg_270 = heading_true_deg_270 - 360;
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[4]/dist",10);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[4]/phi",heading_true_deg_270);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[4]/altitude-hold-ft",altitudeHold);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[5]/dist",10);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[5]/phi",heading_true_deg);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[5]/altitude-hold-ft",altitudeHold);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route-altitude-hold-ft",altitudeHold);
        set_activate_new_route = 1;
    } else {
        setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",30.0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop",0);
    }
    setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-mod",0);
}, 1, 0);


setlistener("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-left-mod", func {
    if (getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-left-mod") == 1
        and getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-left") == 1) {
        setprop("/autopilot/route-manager/active",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-right",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/reset",1);
        var heading_true_deg = math.round(getprop("fdm/jsbsim/systems/autopilot/heading-true-deg"));
        var altitudeHold = math.round(getprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft"));
        if (altitudeHold <= 0.0) altitudeHold = 15000.0;
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[1]/dist",25);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[1]/phi",heading_true_deg);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[1]/altitude-hold-ft",altitudeHold);
        var heading_true_deg_90 = math.round(heading_true_deg - 90.0);
        if (heading_true_deg_90 < 0) heading_true_deg_90 = heading_true_deg_90 + 360;
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[2]/dist",8);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[2]/phi",heading_true_deg_90);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[2]/altitude-hold-ft",altitudeHold);
        var heading_true_deg_180 = math.round(heading_true_deg - 180.0);
        if (heading_true_deg_180 < 0) heading_true_deg_180 = heading_true_deg_180 + 360;
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[3]/dist",50);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[3]/phi",heading_true_deg_180);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[3]/altitude-hold-ft",altitudeHold);
        var heading_true_deg_270 = math.round(heading_true_deg - 270.0);
        if (heading_true_deg_270 < 0) heading_true_deg_270 = heading_true_deg_270 + 360;
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[4]/dist",8);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[4]/phi",heading_true_deg_270);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[4]/altitude-hold-ft",altitudeHold);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[5]/dist",8);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[5]/phi",heading_true_deg);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[5]/altitude-hold-ft",altitudeHold);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route-altitude-hold-ft",altitudeHold);
        #// Activate the new route
        set_activate_new_route = 1;
    } else {
        setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",30.0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-left",0);
    }
    setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-left-mod",0);
}, 1, 0);


setlistener("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-right-mod", func {
    if (getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-right-mod") == 1 
        and getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-right") == 1) {
        setprop("/autopilot/route-manager/active",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-left",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/reset",1);
        var heading_true_deg = math.round(getprop("fdm/jsbsim/systems/autopilot/heading-true-deg"));
        var altitudeHold = math.round(getprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft"));
        if (altitudeHold <= 0.0) altitudeHold = 15000.0;
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[1]/dist",25);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[1]/phi",heading_true_deg);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[1]/altitude-hold-ft",altitudeHold);
        var heading_true_deg_90 = math.round(heading_true_deg + 90.0);
        if (heading_true_deg_90 > 360) heading_true_deg_90 = heading_true_deg_90 - 360;
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[2]/dist",8);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[2]/phi",heading_true_deg_90);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[2]/altitude-hold-ft",altitudeHold);
        var heading_true_deg_180 = math.round(heading_true_deg - 180.0);
        if (heading_true_deg_180 < 0) heading_true_deg_180 = heading_true_deg_180 + 360;
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[3]/dist",50);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[3]/phi",heading_true_deg_180);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[3]/altitude-hold-ft",altitudeHold);
        var heading_true_deg_270 = math.round(heading_true_deg - 90.0);
        if (heading_true_deg_270 < 360) heading_true_deg_270 = heading_true_deg_270 + 360;
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[4]/dist",8);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[4]/phi",heading_true_deg_270);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[4]/altitude-hold-ft",altitudeHold);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[5]/dist",8);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[5]/phi",heading_true_deg);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[5]/altitude-hold-ft",altitudeHold);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route-altitude-hold-ft",altitudeHold);
        #// Activate the new route
        set_activate_new_route = 1;
    } else {
        setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",30.0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-right",0);
    }
    setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-right-mod",0);
}, 1, 0);


setlistener("/autopilot/route-manager/active", func {
    if (getprop("/autopilot/route-manager/active") == 1) {
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-left",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-right",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual",0);
        #// Load the route data from route manager
        var routeNum = getprop("/autopilot/route-manager/route/num");
        var altitudeHold = getprop("/autopilot/route-manager/cruise/altitude-ft");
        if (altitudeHold <= 0.0) altitudeHold = 15000.0;
        var speed_cas = getprop("/autopilot/route-manager/cruise/speed-kts");
        if (speed_cas > 150.0) {
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-best-by-altitude",0);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",speed_cas);
        }
        for (var i=1; i <= 5; i = i + 1) {
            if (i < routeNum) {
                setprop("/fdm/jsbsim/systems/gauges/PHI/program/route[" ~ i ~ "]/dist",math.round(getprop("/autopilot/route-manager/route/wp[" ~ i ~ "]/leg-distance-nm")));
                setprop("/fdm/jsbsim/systems/gauges/PHI/program/route[" ~ i ~ "]/phi",math.round(getprop("/autopilot/route-manager/route/wp[" ~ i ~ "]/leg-bearing-true-deg")));
                setprop("/fdm/jsbsim/systems/gauges/PHI/program/route[" ~ i ~ "]/altitude-hold-ft",altitudeHold);
            } else {
                setprop("/fdm/jsbsim/systems/gauges/PHI/program/route[" ~ i ~ "]/dist",0.0);
                setprop("/fdm/jsbsim/systems/gauges/PHI/program/route[" ~ i ~ "]/phi",0.0);
                setprop("/fdm/jsbsim/systems/gauges/PHI/program/route[" ~ i ~ "]/altitude-hold-ft",0.0);
            }
        }
        var airport_id = getprop("/autopilot/route-manager/destination/airport");
        if (airport_id != nil and size(airport_id) > 0) {
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_name_direct",airport_id);
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_system_selector",0);
            setprop("fdm/jsbsim/systems/autopilot/gui/landing-scan-airport",0);
            if (getprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/status") == 0) {
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/status",1);
            }
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw",getprop("/autopilot/route-manager/destination/runway"));
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw_select",1);
            set_activate_new_route = 2;
        } else {
            set_activate_new_route = 1;
        }
    } else {
        setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",30.0);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/reset",1);
        setprop("fdm/jsbsim/systems/autopilot/gui/phi-heading",0);
        setprop("fdm/jsbsim/systems/autopilot/gui/true-heading",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/wing-leveler",1.0);
    }
}, 1, 0);


setlistener("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual-mod", func {
    if (getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual-mod") == 1 
        and getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual") == 1) { 
        setprop("/autopilot/route-manager/active",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-left",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-right",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route-manager/autopush-active",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/reset",1);
        var altitudeHold = math.round(getprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft"));
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[1]/dist",0.0);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[1]/phi",0.0);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[1]/altitude-hold-ft",altitudeHold);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[2]/dist",0.0);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[2]/phi",0.0);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[2]/altitude-hold-ft",altitudeHold);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[3]/dist",0.0);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[3]/phi",0.0);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[3]/altitude-hold-ft",altitudeHold);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[4]/dist",0.0);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[4]/phi",0.0);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[4]/altitude-hold-ft",altitudeHold);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[5]/dist",0.0);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[5]/phi",0.0);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[5]/altitude-hold-ft",altitudeHold);
        setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",40.0);
        #// Disactivate the route, from now is manual
        set_activate_new_route = 10;
    } else {
        setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",30.0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual",0);
    }
    setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual-mod",0);
}, 1, 0);


var phi_get_route_data_control = func() {
    phi_get_route_data();
    activate_new_route();
    phi_get_route_data_controlTimer.restart(delta_time);
}


var phi_get_route_data_controlTimer = maketimer(delta_time, phi_get_route_data_control);
phi_get_route_data_controlTimer.singleShot = 1;
phi_get_route_data_controlTimer.start();
