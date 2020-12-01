# PHI - Route manager binding
#
# Adriano Bassignana - Bergamo 2019
#

var delta_time_standard = 1.0;
var delta_time = delta_time_standard;

var isRouteActivate = 0;
var isRouteActivated = 0;
var set_activate_new_route = 0;
var heading_true_deg = 0.0;
var isRepeat = 0;

var convergency_initialized = 0;
var convergency_route_geo = {};
var convergency_frist = 0;
var convergency_last = 0;

var phi_indicator_switch_turned = 0;


var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual", "1", "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual-mod", "1", "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop", "0", "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-mod", "0", "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/declination-automatic", "0", "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/doppler/switch-terrain-sea-description","","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/doppler/allarm-description","","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/program/route-from-text","","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-true-heading-start","0.0","DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-long-section-slider","10","DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-long-section","10.0","DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-short-section-slider","10.0","DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-short-section","10.0","DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-versus","0","INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-versus-description","Left","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-repeat","0","INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/indicator/switch-description","Hold","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/convergency/lat-mid-deg-mod","-1","INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/convergency/status","-10","INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/convergency/airport-start","0","INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/convergency/route-1","0","INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/convergency/route-2","0","INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/convergency/route-3","0","INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/convergency/route-4","0","INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/PHI/convergency/route-5","0","INT");


var set_phi_program_lat_lon = func() {
    
    var route_manager_active = getprop("/autopilot/route-manager/active");
    if (route_manager_active == 1) {
        var num_routes = getprop("autopilot/route-manager/route/num");
        var departure = getprop("autopilot/route-manager/route/wp[0]/departure");
        var start_id = 1;
        if (departure == nil) start_id = 0;
        for (var i = 1; i <= 5; i = i + 1) {
            if (i < num_routes) {
                convergency_route_geo[i] = geo.Coord.new().set_latlon(getprop("autopilot/route-manager/route/wp[" ~ (i - start_id) ~ "]/latitude-deg"), 
                                                                      getprop("autopilot/route-manager/route/wp[" ~ (i - start_id) ~ "]/longitude-deg"));
            } else {
                convergency_route_geo[i] = nil;
            }
        };
    } else {
        for (var i = 1; i <= 5; i = i + 1) {
            if (getprop("fdm/jsbsim/systems/gauges/PHI/program/route[" ~ i ~ "]/dist") > 0.0) {
                convergency_route_geo[i] = convergency_route_geo[0].apply_course_distance(getprop("fdm/jsbsim/systems/gauges/PHI/program/route[" ~ i ~ "]/phi"),getprop("fdm/jsbsim/systems/gauges/PHI/program/route[" ~ i ~ "]/dist") * 1609.34);
            } else {
                convergency_route_geo[i] = nil;
            }
        }
    }
    for (var i = 1; i <= 5; i = i + 1) {
        if (convergency_route_geo[i] != nil) {
            setprop("/fdm/jsbsim/systems/gauges/PHI/program/route[" ~ i ~ "]/lat",convergency_route_geo[i].lat());
            setprop("/fdm/jsbsim/systems/gauges/PHI/program/route[" ~ i ~ "]/lon",convergency_route_geo[i].lon());
        } else {
            setprop("/fdm/jsbsim/systems/gauges/PHI/program/route[" ~ i ~ "]/lat",0.0);
            setprop("/fdm/jsbsim/systems/gauges/PHI/program/route[" ~ i ~ "]/lon",0.0);
        }
    }
}


var phi_get_route_data = func() {
    
    #// PHI phi_indicator_switch_turned status
    
    if (getprop("fdm/jsbsim/systems/gauges/PHI/program/route-manager/autopush-end") == 1) {
        #// Set PS mode when finish the cycle
        if (getprop("fdm/jsbsim/systems/gauges/PHI/indicator/switch-turn") == 1) {
            setprop("fdm/jsbsim/systems/gauges/PHI/program/reset",2.0);
        }
    }
    phi_indicator_switch_turned = getprop("fdm/jsbsim/systems/gauges/PHI/indicator/switch-turned");
    if (phi_indicator_switch_turned == 0) {
        setprop("fdm/jsbsim/systems/autopilot/gui/phi-heading",0);
    } elsif (phi_indicator_switch_turned == 1) {
        setprop("fdm/jsbsim/systems/autopilot/gui/phi-heading",1);
    } elsif (phi_indicator_switch_turned == 2) {
        setprop("fdm/jsbsim/systems/autopilot/gui/phi-heading",0);
    }
    
    #// Declination
    
    if (getprop("fdm/jsbsim/systems/gauges/PHI/programmer/declination-automatic") >= 1.0) {
        setprop("fdm/jsbsim/systems/gauges/PHI/indicator/var-deg",math.round(getprop("/instrumentation/heading-indicator/offset-deg")));
    }
    
    #// Wind system
    
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
        delta_time = 0.3;
        if (getprop("fdm/jsbsim/systems/gauges/PHI/program/reset") == 0) {
            setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",40.0);
            setprop("fdm/jsbsim/systems/gauges/PHI/wind/automatic-wind-sw",1);
            if (set_activate_new_route < 10) {
                setprop("fdm/jsbsim/systems/gauges/PHI/program/route-manager/autopush-active",1);
                setprop("fdm/jsbsim/systems/gauges/PHI/doppler/switch-turn",2);
                setprop("fdm/jsbsim/systems/gauges/PHI/doppler/switch-terrain-sea",1);
                setprop("fdm/jsbsim/systems/gauges/PHI/programmer/declination-automatic",1);
                setprop("fdm/jsbsim/systems/gauges/PHI/wind/automatic-wind-sw",1);
            } else {
                setprop("fdm/jsbsim/systems/gauges/PHI/doppler/switch-turn",1);
                setprop("fdm/jsbsim/systems/gauges/PHI/doppler/switch-terrain-sea",1);
                setprop("fdm/jsbsim/systems/gauges/PHI/programmer/declination-automatic",0);
                setprop("fdm/jsbsim/systems/gauges/PHI/wind/automatic-wind-sw",0);
            }
            set_activate_new_route = 0;
        }
        if (set_activate_new_route == 2) {
            if (getprop("fdm/jsbsim/systems/autopilot/gui/landing-activate") == 0) {
                setprop("fdm/jsbsim/systems/autopilot/gui/landing-activate",1);
            }
            set_activate_new_route = 0;
        }
    } else {
        delta_time = delta_time_standard;
    }
};


var repeat_route = func() {
    if (getprop("fdm/jsbsim/systems/gauges/PHI/program/route-manager/autopush-finished") == 1.0) {
        if (getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-repeat") == 1) {
            isRepeat += 1;
            if (isRepeat == 1) {
                setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-mod",1);
            };
        } elsif (getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-manual-repeat") == 1) {
            isRepeat += 1;
            if (isRepeat == 1) {
                setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual-mod",1);
            };
        }
    } else {
        isRepeat = 0;
    }
};


var convergency_set = func() {
    #// For the G91 the convergence is set on the ground by adjusting a special multiturn potentiometer inserted in the PHI junction box
    #// located behind the camera compartment.
    #// This means that the PHI adjustment technician must evaluate the correct latitude value that
    #// best approximates the convergence in the established range.
    #// Therefore, if there is no particular information, the convergence is adjusted to the latitude of the departure airport.
    #// status = -10 is reset function
    #// status = 0..5 if set convergency test points
    #// status = 9 Route manager mode set
    #// status = 10 Periodic recalc the convergency
    #// status = 20 manual convergency
    
    var route_manager_active = getprop("/autopilot/route-manager/active");
    var status = getprop("fdm/jsbsim/systems/gauges/PHI/convergency/status");
    
    if (status == -10 or convergency_initialized == 0) {
        #// convergency reset for initial phase o change the route program
        if (route_manager_active == 0) {
            setprop("fdm/jsbsim/systems/gauges/PHI/convergency/airport-start",1);
        } else {
            setprop("fdm/jsbsim/systems/gauges/PHI/convergency/airport-start",0);
        }
        setprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-1",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-2",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-3",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-4",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-5",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/convergency/status",0);
        convergency_route_geo[0] = geo.aircraft_position();
        set_phi_program_lat_lon();
        convergency_frist = 0;
        convergency_last = 0;
        convergency_initialized = 1;
    }
    
    if (status >= 0) {
        if (status < 9) {
            convergency_frist = 5;
            if (route_manager_active == 1) {
                var num_routes = getprop("autopilot/route-manager/route/num");
                var departure = getprop("autopilot/route-manager/route/wp[0]/departure");
                if (departure != nil) print("***** IS Departure airport") else print("***** NOT Departure airport");
            }
            if (getprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-1") == 1 and convergency_frist > 1) convergency_frist = 1;
            if (getprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-2") == 1 and convergency_frist > 2) convergency_frist = 2;
            if (getprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-3") == 1 and convergency_frist > 3) convergency_frist = 3;
            if (getprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-4") == 1 and convergency_frist > 4) convergency_frist = 4;
            if (getprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-5") == 1 and convergency_frist > 5) convergency_frist = 5;
            convergency_last = 0;
            if (route_manager_active == 1) convergency_last = 1;
            if (getprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-5") == 1 and convergency_last < 5) convergency_last = 5;
            if (getprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-4") == 1 and convergency_last < 4) convergency_last = 4;
            if (getprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-3") == 1 and convergency_last < 3) convergency_last = 3;
            if (getprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-2") == 1 and convergency_last < 2) convergency_last = 2;
            if (getprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-1") == 1 and convergency_last < 1) convergency_last = 1;
            if (convergency_frist != 0 and convergency_last != 0) setprop("fdm/jsbsim/systems/gauges/PHI/convergency/airport-start",0);
            if (convergency_frist != 1 and convergency_last != 1) setprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-1",0);
            if (convergency_frist != 2 and convergency_last != 2) setprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-2",0);
            if (convergency_frist != 3 and convergency_last != 3) setprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-3",0);
            if (convergency_frist != 4 and convergency_last != 4) setprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-4",0);
            if (convergency_frist != 5 and convergency_last != 5) setprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-5",0);
            
            if (convergency_frist > convergency_last) {
                setprop("fdm/jsbsim/systems/gauges/PHI/convergency/airport-start",1);
                convergency_frist = 0;
                convergency_last = 0;
            };
        } elsif (status == 9) {
            #// Route manager mode def auto check route
            var coord = geo.Coord.new().set_latlon(0, 0);
            convergency_frist = 1;
            var max_dist = 0.0;
            for (var i = 2; i <= 5; i = i + 1) {
                var distance = coord.apply_course_distance(getprop("fdm/jsbsim/systems/gauges/PHI/program/route[" ~ i ~ "]/phi"),getprop("fdm/jsbsim/systems/gauges/PHI/program/route[" ~ i ~ "]/dist") * 1609.34).distance_to(geo.Coord.new().set_latlon(0, 0));
                if (distance > max_dist) {
                    max_dist = distance;
                    convergency_last = i;
                }
            };
            setprop("fdm/jsbsim/systems/gauges/PHI/convergency/airport-start",0);
            for (var i = 1; i <= 5; i = i + 1) {
                if (i == convergency_frist or i == convergency_last) {
                    setprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-" ~ i,1);
                } else {
                    setprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-" ~ i,0);
                }
            };
        }
        
        if (status <= 10) {
            var lat_mid_deg = 0.0;
            
            set_phi_program_lat_lon();

            print("***** convergency_frist: ",convergency_frist," convergency_last: ",convergency_last);
            lat_mid_deg += (convergency_route_geo[convergency_frist].lat() + convergency_route_geo[convergency_last].lat()) / 2.0;
            print("***** lat_mid_deg: ",sprintf("%2.1f",lat_mid_deg)," convergency_frist: ",convergency_frist," convergency_last: ",convergency_last);
            
            setprop("fdm/jsbsim/systems/gauges/PHI/convergency/lat-mid-deg",sprintf("%2.1f",lat_mid_deg));
            
            if (status != 10) setprop("fdm/jsbsim/systems/gauges/PHI/convergency/status",-1);
        } else {
            #// The convergence in manualy inserted mode
            if (status == 20) {
                setprop("fdm/jsbsim/systems/gauges/PHI/convergency/airport-start",0);
                setprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-1",0);
                setprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-2",0);
                setprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-3",0);
                setprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-4",0);
                setprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-5",0);
                setprop("fdm/jsbsim/systems/gauges/PHI/convergency/status",-1);
            }
        }
    }
}


setlistener("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-mod", func {
    var mod = getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-mod");
    if (mod == 2) {
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-long-section",getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-long-section-slider"));
    } elsif (mod == 3) {
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-long-section-slider",getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-long-section"));
    } elsif (mod == 4) {
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-short-section",getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-short-section-slider"));
    } elsif (mod == 5) {
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-short-section-slider",getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-short-section"));
    };
    if (mod == 1 or mod == 2 or mod == 3 or mod == 4 or mod == 5) {
        var long_section = math.round(getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-long-section"));
        var short_section = math.round(getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-short-section"));
        setprop("fdm/jsbsim/systems/gauges/PHI/indicator/digit-inc-stop",1);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[1]/dist",long_section);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[2]/dist",short_section);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[3]/dist",long_section);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[4]/dist",short_section);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[5]/dist",0.0);
    };
    if (mod == 1 or mod == 6) {
        var versus = getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-versus");
        if (mod == 1) {
            if (isRepeat == 0) {
                heading_true_deg = math.round(getprop("fdm/jsbsim/systems/autopilot/heading-true-deg"));
            };
            setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-true-heading-start",heading_true_deg);
        } else {
            heading_true_deg = getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-true-heading-start");
        }
        var heading_true_deg_90 = 0.0;
        var heading_true_deg_180 = 0.0;
        var heading_true_deg_270 = 0.0;
        if (versus == 0) {
            setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-versus-description","Left");
        } else {
            setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-versus-description","Right");
        }
        if (versus == 0) {
            heading_true_deg_90 = math.round(heading_true_deg - 90.0);
            if (heading_true_deg_90 < 0.0) heading_true_deg_90 = heading_true_deg_90 + 360.0;
        } else {
            heading_true_deg_90 = math.round(heading_true_deg + 90.0);
            if (heading_true_deg_90 >= 360.0) heading_true_deg_90 = heading_true_deg_90 - 360.0;
        }
        heading_true_deg_180 = math.round(heading_true_deg - 180.0);
        if (heading_true_deg_180 < 0.0) heading_true_deg_180 = heading_true_deg_180 + 360.0;
        if (versus == 0) {
            heading_true_deg_270 = math.round(heading_true_deg - 270.0);
        } else {
            heading_true_deg_270 = math.round(heading_true_deg - 90.0);
        }
        if (heading_true_deg_270 < 0.0) heading_true_deg_270 = heading_true_deg_270 + 360.0;
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[1]/phi",heading_true_deg);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[2]/phi",heading_true_deg_90);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[3]/phi",heading_true_deg_180);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[4]/phi",heading_true_deg_270);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[5]/phi",heading_true_deg);
    };
    if (mod == 1 and getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop") == 1) {
        setprop("/autopilot/route-manager/active",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/reset",1);
        setprop("fdm/jsbsim/systems/gauges/PHI/indicator/digit-inc-stop",1);
        var altitudeHold = math.round(getprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft"));
        var altitude_actual = math.round(getprop("fdm/jsbsim/systems/autopilot/h-sl-ft-lag"));
        if (altitudeHold <= (altitude_actual + 6000.0)) altitudeHold = altitude_actual + 6000.0;
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[1]/altitude-hold-ft",altitudeHold);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[2]/altitude-hold-ft",altitudeHold);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[3]/altitude-hold-ft",altitudeHold);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[4]/altitude-hold-ft",altitudeHold);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route[5]/altitude-hold-ft",altitudeHold);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route-altitude-hold-ft",altitudeHold);
        #// Activate the new route
        set_activate_new_route = 1;
        setprop("fdm/jsbsim/systems/gauges/PHI/convergency/status",-10);
        setprop("fdm/jsbsim/systems/gauges/PHI/convergency/status",9);
    } else if (mod <= 0) {
        setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",30.0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/reset",2);
    }
    setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop-mod",0);
}, 1, 0);


setlistener("/autopilot/route-manager/active", func {
    if (getprop("/autopilot/route-manager/active") == 1) {
        
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop",0);
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
        setprop("fdm/jsbsim/systems/gauges/PHI/indicator/digit-inc-stop",1);
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
            setprop("sim/gui/dialogs/airports/selected-airport/id",airport_id);
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_system_selector",1);
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw",getprop("/autopilot/route-manager/destination/runway"));
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw_select",1);
            set_activate_new_route = 2;
        } else {
            set_activate_new_route = 1;
        }
        setprop("fdm/jsbsim/systems/gauges/PHI/convergency/status",-10);
        setprop("fdm/jsbsim/systems/gauges/PHI/convergency/status",9);
        #// Start the PHI system
        setprop("fdm/jsbsim/systems/gauges/PHI/indicator/switch-turn",1);
    } else {
        setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",30.0);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/reset",2);
    }
}, 1, 0);


setlistener("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual-mod", func {
    if (getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual-mod") >= 1.0
        and getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual") == 1.0) { 
        
        if (getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual-mod") < 2.0) {
            setprop("fdm/jsbsim/systems/gauges/PHI/program/reset",1);
        }
        setprop("/autopilot/route-manager/active",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-automatic-loop",0);
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route-manager/autopush-active",0);
        var altitudeHold = math.round(getprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft"));
        setprop("fdm/jsbsim/systems/gauges/PHI/indicator/dist-set",0.0);
        setprop("fdm/jsbsim/systems/gauges/PHI/indicator/brg-imposed",0.0);
        setprop("fdm/jsbsim/systems/gauges/PHI/indicator/digit-inc-stop",1);
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
        setprop("fdm/jsbsim/systems/gauges/PHI/convergency/status",-10);
        setprop("fdm/jsbsim/systems/gauges/PHI/convergency/status",0);
        set_activate_new_route = 10;
    } else {
        setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",30.0);
        setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual",0);
    }
    setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual-mod",0);
}, 1, 0);


setlistener("fdm/jsbsim/systems/gauges/PHI/program/reset-after", func {
        
    if (getprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual") == 0.0 and
        getprop("fdm/jsbsim/systems/gauges/PHI/program/reset-after") == 1.0) {
        
        print("***** Reset reset-after 1: ",getprop("fdm/jsbsim/systems/gauges/PHI/program/reset")," after: ",getprop("fdm/jsbsim/systems/gauges/PHI/program/reset-after")," type: ",getprop("fdm/jsbsim/systems/gauges/PHI/program/reset-type"));
        if (getprop("fdm/jsbsim/systems/gauges/PHI/program/reset-type") >= 2.0) {
            print("***** Reset reset-after 2: ",getprop("fdm/jsbsim/systems/gauges/PHI/program/reset-type"));
            setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual",1.0);
            setprop("fdm/jsbsim/systems/gauges/PHI/programmer/route-manual-mod",2.0);
            setprop("fdm/jsbsim/systems/gauges/PHI/indicator/switch-turn",2);
            setprop("fdm/jsbsim/systems/autopilot/gui/true-heading",1.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/heading-control",1.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",math.round(getprop("fdm/jsbsim/systems/autopilot/h-sl-ft-lag")));
            setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",1.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/wing-leveler",0.0);
            setprop("fdm/jsbsim/systems/gauges/PHI/convergency/status",-10);
        } else {
            print("***** Reset reset-after 2: ",getprop("fdm/jsbsim/systems/gauges/PHI/program/reset-type"));
            setprop("fdm/jsbsim/systems/gauges/PHI/program/route-manager/autopush-active",1.0);
            setprop("fdm/jsbsim/systems/gauges/PHI/indicator/switch-turn",1);
            setprop("fdm/jsbsim/systems/autopilot/gui/true-heading",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/wing-leveler",0.0);
            setprop("fdm/jsbsim/systems/gauges/PHI/convergency/status",-10);
        }
        
        #// remove the automatic pilot-radio-assistant system
        if (getprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/mode") == 1) {
            setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/mode",2);
        }
    }

}, 1, 0);


setlistener("fdm/jsbsim/systems/gauges/PHI/doppler/switch-terrain-sea", func {
        
    if (getprop("fdm/jsbsim/systems/gauges/PHI/doppler/switch-terrain-sea") == 1.0) {
        setprop("fdm/jsbsim/systems/gauges/PHI/doppler/switch-terrain-sea-description","Land");
    } else {
        setprop("fdm/jsbsim/systems/gauges/PHI/doppler/switch-terrain-sea-description","Sea");
    }

}, 1, 0);


setlistener("fdm/jsbsim/systems/gauges/PHI/doppler/allarm", func {
        
    if (getprop("fdm/jsbsim/systems/gauges/PHI/doppler/allarm") == 1.0) {
        setprop("fdm/jsbsim/systems/gauges/PHI/doppler/allarm-description","Doppler allarm");
    } else {
        setprop("fdm/jsbsim/systems/gauges/PHI/doppler/allarm-description","");
    }

}, 1, 0);


setlistener("fdm/jsbsim/systems/gauges/PHI/doppler/switch-turn", func {
        
    var tag = getprop("fdm/jsbsim/systems/gauges/PHI/doppler/switch-turn");
    if (tag == 0) {
        setprop("fdm/jsbsim/systems/gauges/PHI/doppler/switch-turn-text","OFF");
    } elsif (tag == 1) {
        setprop("fdm/jsbsim/systems/gauges/PHI/doppler/switch-turn-text","Rec only");
    } elsif (tag == 2) {
        setprop("fdm/jsbsim/systems/gauges/PHI/doppler/switch-turn-text","ON");
    } else {
        setprop("fdm/jsbsim/systems/gauges/PHI/doppler/switch-turn-text","Test");
    }

}, 1, 0);


setlistener("fdm/jsbsim/systems/gauges/PHI/program/route-from", func {
        
    var tag = getprop("fdm/jsbsim/systems/gauges/PHI/program/route-from");
    if (tag == 0) {
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route-from-text","To");
    } elsif (tag == 1) {
        setprop("fdm/jsbsim/systems/gauges/PHI/program/route-from-text","From");
    }

}, 1, 0);


setlistener("fdm/jsbsim/systems/gauges/PHI/indicator/switch-turned", func {

    phi_indicator_switch_turned = getprop("fdm/jsbsim/systems/gauges/PHI/indicator/switch-turned");
    if (phi_indicator_switch_turned == 0) {
        setprop("fdm/jsbsim/systems/gauges/PHI/indicator/switch-description","hold");
    } elsif (phi_indicator_switch_turned == 1) {
        setprop("fdm/jsbsim/systems/gauges/PHI/indicator/switch-description","PHI on");
    } elsif (phi_indicator_switch_turned == 2) {
        setprop("fdm/jsbsim/systems/gauges/PHI/indicator/switch-description","PS");
    }

}, 1, 0);


setlistener("fdm/jsbsim/systems/autopilot/gui/phi-heading-button-on-off", func {

    var phi_heading_button_on_off = getprop("fdm/jsbsim/systems/autopilot/gui/phi-heading-button-on-off");
    if (phi_heading_button_on_off >= 1) {
        if (phi_indicator_switch_turned == 0 or phi_indicator_switch_turned == 2) {
            setprop("fdm/jsbsim/systems/gauges/PHI/indicator/switch-turn",1);
        } else {
            setprop("fdm/jsbsim/systems/gauges/PHI/indicator/switch-turn",2);
        };
        setprop("fdm/jsbsim/systems/autopilot/gui/phi-heading-button-on-off",0);
    }
    
}, 1, 0);


setlistener("fdm/jsbsim/systems/gauges/PHI/indicator/switch-turn", func {
    
    if (getprop("fdm/jsbsim/systems/gauges/PHI/indicator/switch-turn") == 2) {
        #// Remove the PHI automatic control with PS mode
        setprop("fdm/jsbsim/systems/autopilot/gui/true-heading",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/heading-control",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",math.round(getprop("fdm/jsbsim/systems/autopilot/h-sl-ft-lag")));
        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/wing-leveler",0.0);
        setprop("fdm/jsbsim/systems/gauges/PHI/convergency/status",-10);
    };
    
}, 1, 0);

setlistener("fdm/jsbsim/systems/gauges/PHI/convergency/lat-mid-deg-mod", func {
    
    var tag = getprop("fdm/jsbsim/systems/gauges/PHI/convergency/lat-mid-deg-mod");
    if (tag == 0) {
        if (getprop("fdm/jsbsim/systems/gauges/PHI/convergency/airport-start") == 1) {
            #// Airport start for convergency set
            #// It is always present by definition as it is necessary for the calculation
            #// of the latitudes on the points of the route
        }
        setprop("fdm/jsbsim/systems/gauges/PHI/convergency/status",0);
    } elsif (tag == 1) {
        if (getprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-1") == 1) {
            #// Route 1 for convergency calc
            if (getprop("fdm/jsbsim/systems/gauges/PHI/program/route[1]/dist") == 0.0)
                setprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-1",0);
        }
        setprop("fdm/jsbsim/systems/gauges/PHI/convergency/status",1) 
    } elsif (tag == 2) {
        #// Route 2 for convergency calc
        if (getprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-2") == 1) {
            #// Route 2 for convergency calc
            if (getprop("fdm/jsbsim/systems/gauges/PHI/program/route[2]/dist") == 0.0)
                setprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-2",0);
        }
        setprop("fdm/jsbsim/systems/gauges/PHI/convergency/status",2) 
    } elsif (tag == 3) {
        #// Route 3 for convergency calc
        if (getprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-3") == 1) {
            #// Route 3 for convergency calc
            if (getprop("fdm/jsbsim/systems/gauges/PHI/program/route[3]/dist") == 0.0)
                setprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-3",0);
        }
        setprop("fdm/jsbsim/systems/gauges/PHI/convergency/status",3) 
    } elsif (tag == 4) {
        #// Route 4 for convergency calc
        if (getprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-4") == 1) {
            #// Route 4 for convergency calc
            if (getprop("fdm/jsbsim/systems/gauges/PHI/program/route[4]/dist") == 0.0)
                setprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-4",0);
        }
        setprop("fdm/jsbsim/systems/gauges/PHI/convergency/status",4) 
    } elsif (tag == 5) {
        #// Route 5 for convergency calc
        if (getprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-5") == 1) {
            #// Route 5 for convergency calc
            if (getprop("fdm/jsbsim/systems/gauges/PHI/program/route[5]/dist") == 0.0)
                setprop("fdm/jsbsim/systems/gauges/PHI/convergency/route-5",0);
        }
        setprop("fdm/jsbsim/systems/gauges/PHI/convergency/status",5) 
    } elsif (tag == 20) {
        #// Manual convergency, activate the convergency
        setprop("fdm/jsbsim/systems/gauges/PHI/convergency/status",20);
    }
    setprop("fdm/jsbsim/systems/gauges/PHI/convergency/lat-mid-deg-mod",-1);
}, 1, 0);


var phi_get_route_data_control = func() {
    phi_get_route_data();
    activate_new_route();
    repeat_route();
    convergency_set();
    phi_get_route_data_controlTimer.restart(delta_time);
}


var phi_get_route_data_controlTimer = maketimer(delta_time, phi_get_route_data_control);
phi_get_route_data_controlTimer.singleShot = 1;
phi_get_route_data_controlTimer.start();
