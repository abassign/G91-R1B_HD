# PHI - Route manager binding
#
# Adriano Bassignana - Bergamo 2019
#

var prop = props.globals.initNode("/fdm/jsbsim/systems/gauges/PHI/program/route-manager/starting-route-num", 1, "DOUBLE");

var timer_phi_get_route_data = maketimer(1.0, func() {

    var isRouteActivate = getprop("/autopilot/route-manager/active");
    var routeNum = getprop("/autopilot/route-manager/route/num");
    var startingRouteNum = getprop("/fdm/jsbsim/systems/gauges/PHI/program/route-manager/starting-route-num");
    
    if (isRouteActivate and routeNum > 1) {
        var routeNumStart = startingRouteNum;
        if (routeNumStart > (routeNum - 1)) routeNumStart = routeNum - 1;
        var routeNumStop = routeNumStart + 3;
        if (routeNumStop > (routeNum - 1)) routeNumStop = routeNum - 1;
        var j = 1;
        for (var i=routeNumStart; i <= routeNumStop; i = i+1) {
            j = j + 1;
            setprop("/fdm/jsbsim/systems/gauges/PHI/program/route[" ~ j ~ "]/dist",getprop("/autopilot/route-manager/route/wp[" ~ i ~ "]/leg-distance-nm"));
            setprop("/fdm/jsbsim/systems/gauges/PHI/program/route[" ~ j ~ "]/phi",getprop("/autopilot/route-manager/route/wp[" ~ i ~ "]/leg-bearing-true-deg"));
        }
        if (j < 5) {
            for (var i=j+1; i <= 5; i = i+1) {
                setprop("/fdm/jsbsim/systems/gauges/PHI/program/route[" ~ i ~ "]/dist",0.0);
                setprop("/fdm/jsbsim/systems/gauges/PHI/program/route[" ~ i ~ "]/phi",0.0);
            }
        }
    }
    
    var automatic_wind_sw = getprop("/fdm/jsbsim/systems/gauges/PHI/wind/automatic-wind-sw");
    
    if (automatic_wind_sw == 1) {
        var wind_direction = getprop("/environment/wind-from-heading-deg");
        var wind_speed = getprop("/environment/wind-speed-kt");
        setprop("/fdm/jsbsim/systems/gauges/PHI/wind/wd",wind_direction);
        setprop("/fdm/jsbsim/systems/gauges/PHI/wind/ws",wind_speed);
    }

});
timer_phi_get_route_data.start();
