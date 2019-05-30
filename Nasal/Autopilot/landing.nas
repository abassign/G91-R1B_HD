# http://wiki.flightgear.org/Nasal_library#Positioned_Object_Queries
# http://wiki.flightgear.org/Nasal_library#findAirportsWithinRange.28.29

var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_name", 1, "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_id", 1, "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_id", 1, "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_landing_status", 1, "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_landing_status_id", 1, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_distance", 1, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_delta_altitude", 1, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct", 1, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope", 1, "DOUBLE");

var landing_activate_status = 0;
var airport_select = 0;
var rwy_select = 0;

var airport_searcher_range = 30.0;
var airport_searcher_min_range = 8.0;
var airport_searcher_max_heading = 45.0;
var airport_searcher_min_delta_altitude = 3000.0;
var airport_searcher_max_slope = 15.0;

var timer_delay = 1.0;

var airport_select_info = 0.0;
var runway_select_rwy = 0.0;
var landig_status_id = -1;


setlistener("fdm/jsbsim/systems/autopilot/gui/landing-activate", func {
    landing_activate_status = getprop("fdm/jsbsim/systems/autopilot/gui/landing-activate");
    if (landing_activate_status == 1) {
        setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",getprop("fdm/jsbsim/systems/autopilot/heading-true-deg"));
        setprop("fdm/jsbsim/systems/autopilot/gui/true-heading",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/heading-control",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/wing-leveler",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/phi-heading",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/rudder-auto-coordination",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-active",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-control",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-throttle",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-pitch",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",160.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-brake",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-flap",1.0);
        setprop("fdm/jsbsim/systems/autopilot/phase-landing",0.0);
    } else {
        if (landig_status_id > 0) {
            landig_status_id = 0;
            timer_delay = 1.0;
        } else {
            landig_status_id = -1;
            timer_delay = 1.0;
        }
    }
}, 1, 0);


var airport_searcher = maketimer(timer_delay, func() {
    
    if (landig_status_id <= 1) {
        var apts = findAirportsWithinRange(airport_searcher_range);
        var heading_dist_min = 999.0;
        foreach(var apt; apts) {
            var airport_info = airportinfo(apt.id);
            foreach(var rwy; keys(airport_info.runways)) {
                # Select the minimum runway lenght
                if (airport_info.runways[rwy].length > 1500.0) {
                    var airplane = geo.aircraft_position();
                    var rwy_coord = geo.Coord.new();
                    rwy_coord.set_latlon(airport_info.runways[rwy].lat,airport_info.runways[rwy].lon);
                    var runway_to_airplane_dist = airplane.distance_to(rwy_coord) * 0.000621371;
                    var runway_to_airplane_delta_alt_ft = (airplane.alt() - airport_info.elevation) * 3.28084;
                    # Search the rwy with minimal heading
                    var heading_dist = math.abs(airport_info.runways[rwy].heading - airplane.course_to(rwy_coord));
                    var slope = 0.0;
                    var runway_to_airplane_dist_direct = airplane.direct_distance_to(rwy_coord) * 0.000621371;
                    if (runway_to_airplane_dist_direct > 0.1) {
                        slope = math.asin((runway_to_airplane_delta_alt_ft * 0.000189394) / runway_to_airplane_dist_direct) * R2D;
                    }
                    if (heading_dist < airport_searcher_max_heading and heading_dist_min > heading_dist and runway_to_airplane_delta_alt_ft >= airport_searcher_min_delta_altitude and runway_to_airplane_dist > airport_searcher_min_range and slope <= airport_searcher_max_slope) {
                        heading_dist_min = heading_dist;
                        airport_select = airport_info;
                        rwy_select = rwy;
                    }
                }
            }
        }
        if (landing_activate_status == 1 and heading_dist_min < 999.0) {
            # Find an airport
            landig_status_id = 2;
            timer_delay = 0.1;
        } else if (heading_dist_min < 999.0) {
            landig_status_id = 1;
            timer_delay = 1.0;
        }
    }
    
    if (landig_status_id >= 1) {
        ## print("Autopilot - airport_searcher - Airport found");
        var runway_to_airplane_dist = 0;
        var rwy_coord = geo.Coord.new();
        var airplane = geo.aircraft_position();
        var airplane_speed = 0.0;
        var runway_to_airplane_delta_alt_ft = 0;
        var runway_alt_m = 0;
        var heading_correction = 0;
        var heading_dist = 0;
        var heading_correct = 0;
        var runway_to_airplane_dist_direct = 0;
        var slope = 0;
        var gear_unit_contact = getprop("fdm/jsbsim/systems/landing-gear/on-ground");
        var altitude_agl_ft = 0;
        var rwy_offset = getprop("fdm/jsbsim/systems/autopilot/gui/landing-rwy-offset");
        # Calculate the landing data
        airplane_speed = getprop("fdm/jsbsim/systems/autopilot/speed-value-lag");
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id",airport_select.id);
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_name",airport_select.name);
        rwy_coord.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon);
        runway_to_airplane_dist = airplane.distance_to(rwy_coord) * 0.000621371 + rwy_offset;
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_distance",runway_to_airplane_dist);
        runway_to_airplane_dist_direct = airplane.direct_distance_to(rwy_coord) * 0.000621371 + rwy_offset;
        runway_alt_m = geo.elevation(airport_select.runways[rwy_select].lat, airport_select.runways[rwy_select].lon);
        runway_to_airplane_delta_alt_ft = (airplane.alt() - runway_alt_m) * 3.28084;
        slope = math.asin((runway_to_airplane_delta_alt_ft * 0.000189394) / runway_to_airplane_dist_direct) * R2D;
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_delta_altitude",runway_to_airplane_delta_alt_ft);
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_id",airport_select.runways[rwy_select].id);
        if (runway_to_airplane_dist < 0.4 or landig_status_id > 2.0) {
            if (landig_status_id == 2) {
                landig_status_id = 2.5;
            }
            heading_correction = getprop("fdm/jsbsim/systems/autopilot/heading-true-deg") - airport_select.runways[rwy_select].heading;
            if (slope > 4.0) {
                slope = 3.0;
            }
        } else {
            heading_correction = (airport_select.runways[rwy_select].heading - airplane.course_to(rwy_coord)) * 5.0;
        }
        heading_dist = math.abs(heading_correction);
        heading_correct = airport_select.runways[rwy_select].heading - heading_correction;
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
        altitude_agl_ft = getprop("/position/altitude-agl-ft");
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope",slope);
        #
        # Configure landing phase
        #
        if (landig_status_id >= 2 and landig_status_id < 3.0) {
            timer_delay = 0.1;
            setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",45.0);
            var vertical_speed_fpm = getprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm");
            # Landing phase
            if (runway_to_airplane_delta_alt_ft <= 5000.0) {
                if (landig_status_id == 2.5) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",130.0);
                } else {
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",155.0);
                }
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",1.0);
                if (math.abs(slope) < 4.0) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",-slope / 1.5);
                } else {
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",-slope);
                }
                setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-active",1.0);
                setprop("fdm/jsbsim/systems/autopilot/phase-landing",1.0);
                setprop("controls/flight/flaps",1.0);
                if (airplane_speed < 185.0) {
                    setprop("fdm/jsbsim/systems/landing-gear/gear-down-command",1.0);
                }
            } else if (runway_to_airplane_delta_alt_ft > 5000.0 and slope < 6.0) {
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",175.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft", 5000.0 + (runway_alt_m * 3.28084));
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",3000.0);
                setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-active",0.0);
                setprop("fdm/jsbsim/systems/autopilot/phase-landing",0.0);
                setprop("fdm/jsbsim/systems/landing-gear/gear-down-command",-1.0);
            } else if (runway_to_airplane_delta_alt_ft > 5000.0 and slope >= 6.0) {
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",170.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",-slope);
                setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-active",1.0);
                setprop("fdm/jsbsim/systems/autopilot/phase-landing",0.0);
                setprop("fdm/jsbsim/systems/landing-gear/gear-down-command",-1.0);
            }
            setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
        }
        if (((landig_status_id == 2 or landig_status_id == 2.5) and (gear_unit_contact == 1 or altitude_agl_ft < 20.0)) or landig_status_id == 3) {
            if (landig_status_id < 3.0) {
                # Final phase
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",0.0);
                setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-active",1.0);
                landig_status_id = 3;
                timer_delay = 0.1;
            }
            setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",airport_select.runways[rwy_select].heading);
            if (gear_unit_contact == 1) {
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",-5.0);
                setprop("fdm/jsbsim/systems/autopilot/steer-brake",1.0);
            }
            if (getprop("fdm/jsbsim/systems/autopilot/speed-true-on-air") < 50.0) {
                landig_status_id = 4;
                timer_delay = 0.5;
            }
        }
        if (landig_status_id == 4) {
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-control",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-throttle",0.0);
            setprop("fdm/jsbsim/systems/autopilot/speed-throttle-automatic",0.2);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",0.0);
            setprop("fdm/jsbsim/systems/autopilot/steer-brake",1.0);
        }
        # Output
        var landing_status = airport_select.id ~ " | " ~ airport_select.name ~ " | " ~ airport_select.runways[rwy_select].id;
        if (landig_status_id == 1) {
            landing_status = "Airport found " ~ landing_status;
        } else if (landig_status_id == 2)  {
            landing_status = "Airport select " ~ landing_status;
        } else if (landig_status_id == 2.5)  {
            landing_status = "Prelanding " ~ landing_status;
        } else if (landig_status_id == 3) {
            landing_status = "Landed " ~ landing_status;
        } else if (landig_status_id == 4) {
            landing_status = "Stopped " ~ landing_status;
        }
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_landing_status",landing_status);
    } else {
        if (landig_status_id == 0) {
            # Stop the landing phase
            landig_status_id = -1;
            # Reset the landing data
            timer_delay = 1.0;
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_landing_status","No airport found");
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id","");
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_name","");
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_id","");
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_distance",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_delta_altitude",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-control",1.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-throttle",1.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-pitch",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",math.round(getprop("fdm/jsbsim/systems/autopilot/speed-cas-on-air")));
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-brake",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-flap",0.0);
            setprop("fdm/jsbsim/systems/autopilot/phase-landing",0.0);
            setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-active",0.0);
        }
        if (landing_activate_status == 1) {
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_landing_status","No airport for landing");
        } else {
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_landing_status","Autolanding inactive");
        }
    }

});
airport_searcher.start();


