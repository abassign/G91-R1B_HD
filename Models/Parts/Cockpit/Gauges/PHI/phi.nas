# PHI - Route manager binding
#
# Adriano Bassignana - Bergamo 2019
#

var isRouteActivate = 0;
var isRouteActivated = 0;

var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual", "1", "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop", "0", "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-left", "0", "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-right", "0", "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/declination-automatic", "1", "INT");

var timer_phi_get_route_data = maketimer(1.0, func() {

    isRouteActivate = getprop("/autopilot/route-manager/active");
    var routeNum = getprop("/autopilot/route-manager/route/num");
    var alt = getprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft");
    
    # Load data from route manager
    
    if (isRouteActivate == 1 and isRouteActivated == 0) {
        for (var i=1; i <= 5; i = i + 1) {
            if (i < routeNum) {
                setprop("/fdm/jsbsim/systems/gauges/PHI/program/route[" ~ i ~ "]/dist",math.round(getprop("/autopilot/route-manager/route/wp[" ~ i ~ "]/leg-distance-nm")));
                setprop("/fdm/jsbsim/systems/gauges/PHI/program/route[" ~ i ~ "]/phi",math.round(getprop("/autopilot/route-manager/route/wp[" ~ i ~ "]/leg-bearing-true-deg")));
                setprop("/fdm/jsbsim/systems/gauges/PHI/program/route[" ~ i ~ "]/altitude-hold-ft",alt);
            } else {
                setprop("/fdm/jsbsim/systems/gauges/PHI/program/route[" ~ i ~ "]/dist",0.0);
                setprop("/fdm/jsbsim/systems/gauges/PHI/program/route[" ~ i ~ "]/phi",0.0);
                setprop("/fdm/jsbsim/systems/gauges/PHI/program/route[" ~ i ~ "]/altitude-hold-ft",0.0);
            }
        }
        isRouteActivated = 1;
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-left",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-right",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/declination-automatic",1);
    } else if (isRouteActivate == 0 and isRouteActivated == 1) {
        for (var i=1; i <= 5; i = i + 1) {
            setprop("/fdm/jsbsim/systems/gauges/PHI/program/route[" ~ i ~ "]/dist",0.0);
            setprop("/fdm/jsbsim/systems/gauges/PHI/program/route[" ~ i ~ "]/phi",0.0);
            setprop("/fdm/jsbsim/systems/gauges/PHI/program/route[" ~ i ~ "]/altitude-hold-ft",0.0);
        }
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop",1);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-left",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-right",0);
        isRouteActivated = 0;
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

});
timer_phi_get_route_data.start();


setlistener("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop", func {
    var route_automatic_loop = getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop");
    if (route_automatic_loop == 1 and getprop("/autopilot/route-manager/active") == 0) {
        var heading_true_deg = math.round(getprop("fdm/jsbsim/systems/autopilot/heading-true-deg"));
        var altitudeHold = math.round(getprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft"));
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[1]/dist",25);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[1]/phi",heading_true_deg);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[1]/altitude-hold-ft",altitudeHold);
        var heading_true_deg_90 = math.round(heading_true_deg + 90.0);
        if (heading_true_deg_90 > 360) heading_true_deg_90 = heading_true_deg_90 - 360;
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[2]/dist",5);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[2]/phi",heading_true_deg_90);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[2]/altitude-hold-ft",altitudeHold);
        var heading_true_deg_180 = math.round(heading_true_deg + 180.0);
        if (heading_true_deg_180 > 360) heading_true_deg_180 = heading_true_deg_180 - 360;
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[3]/dist",5);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[3]/phi",heading_true_deg_180);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[3]/altitude-hold-ft",altitudeHold);
        var heading_true_deg_270 = math.round(heading_true_deg + 270.0);
        if (heading_true_deg_270 > 360) heading_true_deg_270 = heading_true_deg_270 - 360;
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[4]/dist",5);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[4]/phi",heading_true_deg_270);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[4]/altitude-hold-ft",altitudeHold);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[5]/dist",5);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[5]/phi",heading_true_deg_180);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[5]/altitude-hold-ft",altitudeHold);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route-altitude-hold-ft",altitudeHold);
    }
}, 1, 0);


setlistener("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-left", func {
    var route_automatic_circuit_left = getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-left");
    if (route_automatic_circuit_left == 1 and getprop("/autopilot/route-manager/active") == 0) {
        var heading_true_deg = math.round(getprop("fdm/jsbsim/systems/autopilot/heading-true-deg"));
        var altitudeHold = math.round(getprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft"));
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[1]/dist",25);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[1]/phi",heading_true_deg);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[1]/altitude-hold-ft",altitudeHold);
        var heading_true_deg_90 = math.round(heading_true_deg - 90.0);
        if (heading_true_deg_90 < 0) heading_true_deg_90 = heading_true_deg_90 + 360;
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[2]/dist",5);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[2]/phi",heading_true_deg_90);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[2]/altitude-hold-ft",altitudeHold);
        var heading_true_deg_180 = math.round(heading_true_deg - 180.0);
        if (heading_true_deg_180 < 0) heading_true_deg_180 = heading_true_deg_180 + 360;
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[3]/dist",50);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[3]/phi",heading_true_deg_180);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[3]/altitude-hold-ft",altitudeHold);
        var heading_true_deg_270 = math.round(heading_true_deg - 270.0);
        if (heading_true_deg_270 < 0) heading_true_deg_270 = heading_true_deg_270 + 360;
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[4]/dist",5);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[4]/phi",heading_true_deg_270);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[4]/altitude-hold-ft",altitudeHold);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[5]/dist",5);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[5]/phi",heading_true_deg);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[5]/altitude-hold-ft",altitudeHold);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route-altitude-hold-ft",altitudeHold);
    }
}, 1, 0);


setlistener("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-right", func {
    var route_automatic_circuit_right = getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-circuit-right");
    if (route_automatic_circuit_right == 1 and getprop("/autopilot/route-manager/active") == 0) {
        var heading_true_deg = math.round(getprop("fdm/jsbsim/systems/autopilot/heading-true-deg"));
        var altitudeHold = math.round(getprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft"));
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[1]/dist",25);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[1]/phi",heading_true_deg);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[1]/altitude-hold-ft",altitudeHold);
        var heading_true_deg_90 = math.round(heading_true_deg + 90.0);
        if (heading_true_deg_90 > 360) heading_true_deg_90 = heading_true_deg_90 - 360;
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[2]/dist",5);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[2]/phi",heading_true_deg_90);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[2]/altitude-hold-ft",altitudeHold);
        var heading_true_deg_180 = math.round(heading_true_deg - 180.0);
        if (heading_true_deg_180 < 0) heading_true_deg_180 = heading_true_deg_180 + 360;
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[3]/dist",50);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[3]/phi",heading_true_deg_180);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[3]/altitude-hold-ft",altitudeHold);
        var heading_true_deg_270 = math.round(heading_true_deg - 90.0);
        if (heading_true_deg_270 < 360) heading_true_deg_270 = heading_true_deg_270 + 360;
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[4]/dist",5);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[4]/phi",heading_true_deg_270);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[4]/altitude-hold-ft",altitudeHold);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[5]/dist",5);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[5]/phi",heading_true_deg);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[5]/altitude-hold-ft",altitudeHold);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route-altitude-hold-ft",altitudeHold);
    }
}, 1, 0);


setlistener("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual", func {
    var route_manual = getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual");
    if (route_manual == 1 and getprop("/autopilot/route-manager/active") == 0) {
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
    }
}, 1, 0);
