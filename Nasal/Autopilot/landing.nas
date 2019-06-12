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
var airport_searcher_min_range = 12.0;
var airport_searcher_max_heading = 45.0;
var airport_searcher_min_delta_altitude = 3000.0;
var airport_searcher_max_slope = 15.0;

var timer_delay = 1.0;

var airport_select_info = 0.0;
var runway_select_rwy = 0.0;
var runway_alt_m = 0.0;
var landig_status_id = -1;
var isHolding_reducing_start_distance = 12.0;
var isHolding_reducing_delta = 0;
var isHolding_reducing_heading = 0.0;
var isHolding_reducing_distance = 0.0;
var isHolding_reducing_distance_rel = 0.0;

var rwy_coord_start = geo.Coord.new();
var rwy_coord_end = geo.Coord.new();
var rwy_coord_end_offset = 3000.0;
var heading_target_active = 0.0;
var heading_target = 0.0;

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
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",200.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-brake",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-flap",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",0.0);
        setprop("fdm/jsbsim/systems/autopilot/landing-gear-activate-blocked",0.0);
        setprop("fdm/jsbsim/systems/autopilot/phase-landing",0.0);
        setprop("fdm/jsbsim/systems/autopilot/steer-brake",0.0);
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

    var slope = 0.0;
    
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
        if (heading_dist_min < 999.0) {
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id",airport_select.id);
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_name",airport_select.name);
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_id",airport_select.runways[rwy_select].id);
            runway_alt_m = geo.elevation(airport_select.runways[rwy_select].lat, airport_select.runways[rwy_select].lon);
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_distance",runway_to_airplane_dist);
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope",slope);
            if (landing_activate_status == 1) {
                # Find an airport
                landig_status_id = 2;
                setprop("fdm/jsbsim/systems/autopilot/phase-landing",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",3000.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",30.0);
                setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-close",1.0);
                rwy_coord_start.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon);
                rwy_coord_end.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon); 
                rwy_coord_end.apply_course_distance(airport_select.runways[rwy_select].heading,rwy_coord_end_offset);
                timer_delay = 0.1;
            } else {
                landig_status_id = 1;
                timer_delay = 1.0;
            }
        } else {
            runway_alt_m = 0;
        }
    }
    
    if (landig_status_id >= 1) {
        ## print("Autopilot - airport_searcher - Airport found");
        var runway_to_airplane_dist = 0;
        var holding_point = geo.Coord.new();
        var holding_point_distance_nm = getprop("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-dist-nm");
        var holding_point_h_ft = getprop("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-h-ft");
        var holding_point_to_airplane_dist = 0.0;
        var holding_point_to_airplane_dist_direct = 0.0;
        var holding_point_to_airplane_delta_alt_ft = 0.0;
        var airplane = geo.aircraft_position();
        var runway_to_airplane_delta_alt_ft = 0.0;
        var heading_correction = 0.0;
        var heading_correct = 0.0;
        var runway_to_airplane_dist_direct = 0.0;
        var gear_unit_contact = getprop("fdm/jsbsim/systems/landing-gear/on-ground");
        var altitude_agl_ft = 0.0;
        var rwy_offset_h_nm = getprop("fdm/jsbsim/systems/autopilot/gui/landing-rwy-h-offset-nm");
        var rwy_offset_v_ft = getprop("fdm/jsbsim/systems/autopilot/gui/landing-rwy-v-offset-ft");
        #
        # Common eleboration
        #
        if (landig_status_id >= 2.0 and landig_status_id < 3.0) {
            runway_to_airplane_dist = airplane.distance_to(rwy_coord_start) * 0.000621371 + rwy_offset_h_nm;
        } else if (landig_status_id >= 3.0) {
            runway_to_airplane_dist = airplane.distance_to(rwy_coord_start) * 0.000621371;
        } else {
            runway_to_airplane_dist = 0;
        }
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_distance",runway_to_airplane_dist);
        if (landig_status_id >= 2.0) {
            runway_to_airplane_delta_alt_ft = (airplane.alt() - runway_alt_m) * 3.28084;
        } else {
            runway_to_airplane_delta_alt_ft = 0;
        }
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_delta_altitude",runway_to_airplane_delta_alt_ft);
        if (runway_to_airplane_dist > 0.1) {
            slope = math.atan((runway_to_airplane_delta_alt_ft * 0.000189394) / runway_to_airplane_dist) * R2D;
        } else {
            slope = 0.0;
        }
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope",slope);
        #
        # Select and elabotare the landing phase
        #
        if (landig_status_id == 2.0) {
            # Fly to the holding point
            holding_point.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon,rwy_offset_v_ft * 3.28084);
            holding_point.apply_course_distance(airport_select.runways[rwy_select].heading + 180.0,holding_point_distance_nm * 1852.0);
            holding_point_to_airplane_dist = airplane.distance_to(holding_point) * 0.000621371;
            holding_point_to_airplane_dist_direct = airplane.direct_distance_to(holding_point) * 0.000621371;
            holding_point_to_airplane_delta_alt_ft = airplane.alt() * 3.28084 - (runway_alt_m * 3.28084 + holding_point_h_ft);
            if (holding_point_to_airplane_dist > 5.0) {
                heading_correct = airplane.course_to(holding_point);
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
                slope = math.asin((holding_point_to_airplane_delta_alt_ft * 0.000189394) / holding_point_to_airplane_dist_direct) * R2D;
                if (slope > 3.0) {
                    setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-active",1.0);
                } else {
                    setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-active",0.0);
                }
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",holding_point_h_ft + runway_alt_m * 3.28084);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
                print(" 2.0 > ", holding_point_to_airplane_dist_direct, " ", holding_point_to_airplane_delta_alt_ft, " ", slope);
            } else {
                landig_status_id = 2.1;
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",45.0);
                setprop("fdm/jsbsim/systems/autopilot/phase-landing",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",180.0);
                isHolding_reducing_delta = 0;
            }
        } else if (landig_status_id == 2.1) {
            # Fly near the holding point
            runway_to_airplane_dist_direct = airplane.direct_distance_to(rwy_coord_start) * 0.000621371 + rwy_offset_h_nm;
            slope = math.asin(((runway_to_airplane_delta_alt_ft - rwy_offset_v_ft)* 0.000189394) / runway_to_airplane_dist_direct) * R2D;
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope",slope);
            runway_to_airplane_dist = airplane.distance_to(rwy_coord_start) * 0.000621371 + rwy_offset_h_nm;
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_distance",runway_to_airplane_dist);
            var rwy_point_delta_alt_ft = (airplane.alt() - (runway_alt_m + 914.0)) * 3.28084;
            if ((runway_to_airplane_dist <= isHolding_reducing_start_distance and rwy_point_delta_alt_ft > 500.0 and slope > 4.5) or isHolding_reducing_delta > 0) {
                # Set approch point
                # Direct landing
                # 3000 ft - 10 nm slope 3-4°
                # Is near the airport verify the delta
                # Is necesary the quote reduction
                if (isHolding_reducing_delta == 0) {
                    isHolding_reducing_delta = 1;
                    setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",3000.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",(runway_alt_m + 914.0) * 3.28084);
                    isHolding_reducing_heading = airplane.course_to(rwy_coord_start);
                    var isHolding_reducing_heading_clipto = isHolding_reducing_heading + 90.0;
                    if (isHolding_reducing_heading_clipto >= 360.0) isHolding_reducing_heading_clipto = isHolding_reducing_heading_clipto - 360.0;
                    setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",math.abs(isHolding_reducing_heading_clipto));
                    isHolding_reducing_distance = getprop("fdm/jsbsim/systems/autopilot/distance-nm");
                } else if (isHolding_reducing_delta == 1) {
                    isHolding_reducing_distance_rel = getprop("fdm/jsbsim/systems/autopilot/distance-nm") - isHolding_reducing_distance;
                    if (isHolding_reducing_distance_rel > 0.5 and math.abs(getprop("fdm/jsbsim/systems/autopilot/turn-radius-nm-lag")) < 0.1) {
                        # End turn
                        isHolding_reducing_delta = 2;
                        isHolding_reducing_distance = getprop("fdm/jsbsim/systems/autopilot/distance-nm");
                    }
                } else if (isHolding_reducing_delta == 2) {
                    isHolding_reducing_distance_rel = getprop("fdm/jsbsim/systems/autopilot/distance-nm") - isHolding_reducing_distance;
                    if (isHolding_reducing_distance_rel > 0.2)  {
                        # Turn
                        isHolding_reducing_delta = 3;
                        var isHolding_reducing_heading_clipto = isHolding_reducing_heading + 180.0;
                        if (isHolding_reducing_heading_clipto >= 360.0) isHolding_reducing_heading_clipto = isHolding_reducing_heading_clipto - 360.0;
                        setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",math.abs(isHolding_reducing_heading_clipto));
                        isHolding_reducing_distance = getprop("fdm/jsbsim/systems/autopilot/distance-nm");
                    }
                } else if (isHolding_reducing_delta == 3) {
                    isHolding_reducing_distance_rel = getprop("fdm/jsbsim/systems/autopilot/distance-nm") - isHolding_reducing_distance;
                    if (isHolding_reducing_distance_rel > 0.5 and math.abs(getprop("fdm/jsbsim/systems/autopilot/turn-radius-nm-lag")) < 0.1) {
                        # End turn
                        isHolding_reducing_delta = 4;
                        isHolding_reducing_distance = getprop("fdm/jsbsim/systems/autopilot/distance-nm");
                    }
                } else if (isHolding_reducing_delta == 4) {
                    isHolding_reducing_distance_rel = getprop("fdm/jsbsim/systems/autopilot/distance-nm") - isHolding_reducing_distance;
                    if (isHolding_reducing_distance_rel > 3.0)  {
                        # Turn
                        isHolding_reducing_delta = 5;
                        var isHolding_reducing_heading_clipto = isHolding_reducing_heading + 270.0;
                        if (isHolding_reducing_heading_clipto >= 360.0) isHolding_reducing_heading_clipto = isHolding_reducing_heading_clipto - 360.0;
                        setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",math.abs(isHolding_reducing_heading_clipto));
                        isHolding_reducing_distance = getprop("fdm/jsbsim/systems/autopilot/distance-nm");
                    }
                } else if (isHolding_reducing_delta == 5) {
                    isHolding_reducing_distance_rel = getprop("fdm/jsbsim/systems/autopilot/distance-nm") - isHolding_reducing_distance;
                    if (isHolding_reducing_distance_rel > 0.5 and math.abs(getprop("fdm/jsbsim/systems/autopilot/turn-radius-nm-lag")) < 0.1) {
                        # End turn
                        isHolding_reducing_delta = 6;
                        isHolding_reducing_distance = getprop("fdm/jsbsim/systems/autopilot/distance-nm");
                    }
                } else if (isHolding_reducing_delta == 6) {
                    isHolding_reducing_distance_rel = getprop("fdm/jsbsim/systems/autopilot/distance-nm") - isHolding_reducing_distance;
                    if (isHolding_reducing_distance_rel > 0.2)  {
                        # Turn
                        isHolding_reducing_delta = 7;
                        setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",math.abs(isHolding_reducing_heading));
                        isHolding_reducing_distance = getprop("fdm/jsbsim/systems/autopilot/distance-nm");
                    }
                } else if (isHolding_reducing_delta == 7) {
                    isHolding_reducing_distance_rel = getprop("fdm/jsbsim/systems/autopilot/distance-nm") - isHolding_reducing_distance;
                    if (isHolding_reducing_distance_rel > 3.0 or runway_to_airplane_dist <= isHolding_reducing_start_distance)  {
                        # End holding
                        isHolding_reducing_delta = 0;
                    }
                }
            } else if (runway_to_airplane_dist > isHolding_reducing_start_distance) {
                heading_correction = (airport_select.runways[rwy_select].heading - airplane.course_to(rwy_coord_start)) * 5.0;
                heading_correct = airport_select.runways[rwy_select].heading - heading_correction;
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
            } else {
                landig_status_id = 2.2;
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",30.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",160.0);
                setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-active",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",1.0);
                setprop("fdm/jsbsim/systems/autopilot/landing-gear-activate-blocked",1.0);
                setprop("controls/flight/flaps",1.0);
            }
            print(" 2.1 > ",runway_to_airplane_dist," ", holding_point_to_airplane_delta_alt_ft, " ", slope, " ", airplane.course_to(rwy_coord_start), " ",isHolding_reducing_delta," ",isHolding_reducing_heading, " ",math.abs(getprop("fdm/jsbsim/systems/autopilot/turn-radius-nm-lag"))," ",isHolding_reducing_distance_rel);
        } else if (landig_status_id == 2.2) {
            runway_to_airplane_dist_direct = airplane.direct_distance_to(rwy_coord_start) * 0.000621371 + rwy_offset_h_nm;
            if ((airplane.distance_to(rwy_coord_start) * 0.000621371) > 0.4) {
                slope = math.asin(((runway_to_airplane_delta_alt_ft - rwy_offset_v_ft)* 0.000189394) / runway_to_airplane_dist_direct) * R2D;
                heading_correction = (airport_select.runways[rwy_select].heading - airplane.course_to(rwy_coord_start)) * 5.0;
                heading_correct = airport_select.runways[rwy_select].heading - heading_correction;
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
                # Slope correction
                if (slope < 4) {
                    slope = slope + (slope - 4) * 2.5;
                } else if (slope > 4) {
                    slope = slope + (slope - 4) * 1.5;
                }
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",-slope);
                print(" 2.2 > ", runway_to_airplane_dist_direct, " ", runway_to_airplane_delta_alt_ft, " ", slope);
            } else {
                landig_status_id = 2.5;
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",50.0);
                setprop("fdm/jsbsim/systems/autopilot/steer-brake",1.0);
            }
        } else if (landig_status_id == 2.5) {
            runway_to_airplane_dist_direct = airplane.direct_distance_to(rwy_coord_start) * 0.000621371 + rwy_offset_h_nm;
            if (gear_unit_contact >= 1) {
                landig_status_id = 3.0;
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",-2.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",50.0);
                setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-active",1.0);
            } else {
                var rwy_coord_end_to_airplane_dist_direct = airplane.direct_distance_to(rwy_coord_end) * 0.000621371;
                slope = math.asin((runway_to_airplane_delta_alt_ft * 0.000189394) / rwy_coord_end_to_airplane_dist_direct) * R2D;
                var factor_reducing_slope = 4.0;
                altitude_agl_ft = getprop("/position/altitude-agl-ft");
                if (altitude_agl_ft <= 100.0 and altitude_agl_ft > 20) {
                    slope = ((1+math.atan(slope/100.0))*factor_reducing_slope-factor_reducing_slope);
                } else {
                    slope = 2.0;
                }
                heading_correction = (airport_select.runways[rwy_select].heading - airplane.course_to(rwy_coord_end)) * 8.0;
                heading_correct = airport_select.runways[rwy_select].heading - heading_correction;
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",-slope);
                print(" 2.5 > ", altitude_agl_ft, " ",runway_to_airplane_delta_alt_ft, " ", slope, " Ground: ", gear_unit_contact, " ",heading_correction," ",runway_to_airplane_dist);
                
            }
        } else if (landig_status_id == 3.0) {
            if (getprop("fdm/jsbsim/systems/autopilot/speed-true-on-air") < 50.0) {
                landig_status_id = 4;
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",-5.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",0.0);
                setprop("fdm/jsbsim/systems/autopilot/speed-throttle-imposed",0.2);
                setprop("fdm/jsbsim/systems/autopilot/steer-brake",1.0);
                timer_delay = 0.5;
                slope = 0.0;
            } else {
                heading_correction = (airport_select.runways[rwy_select].heading - airplane.course_to(rwy_coord_end)) * 8.0;
                heading_correct = airport_select.runways[rwy_select].heading - heading_correction;
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
                print(" 3.0 > ", getprop("fdm/jsbsim/systems/autopilot/steer-brake-modulated"), " ", getprop("fdm/jsbsim/systems/brake/left-steer-brake-intensity"), " contact: ",gear_unit_contact, " ",heading_correction," ",runway_to_airplane_dist);
            }
        } else if (landig_status_id == 4.0) {
            heading_correction = (airport_select.runways[rwy_select].heading - airplane.course_to(rwy_coord_end)) * 5.0;
            heading_correct = airport_select.runways[rwy_select].heading - heading_correction;
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
            setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
            print(" 4.0 > ",getprop("fdm/jsbsim/systems/autopilot/steer-brake-modulated"), " ",getprop("fdm/jsbsim/systems/brake/left-steer-brake-intensity"), " ",heading_correction," ",runway_to_airplane_dist);
        }
        #
        # Output
        #
        var landing_status = airport_select.id ~ " | " ~ airport_select.name ~ " | " ~ airport_select.runways[rwy_select].id;
        if (landig_status_id == 1) {
            landing_status = "Airport found " ~ landing_status;
        } else if (landig_status_id == 2)  {
            landing_status = "Airport select " ~ landing_status;
        } else if (landig_status_id == 2.1 or landig_status_id == 2.2)  {
            landing_status = "Airport approach " ~ landing_status;
        } else if (landig_status_id == 2.5)  {
            landing_status = "Final landing " ~ landing_status;
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
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",0.0);
            setprop("fdm/jsbsim/systems/autopilot/landing-gear-activate-blocked",0.0);
            setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-close",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1000.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",6.0);
            if (landing_activate_status == 1) {
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_landing_status","No airport for landing");
            } else {
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_landing_status","Autolanding inactive");
            }
        }
    }

});

airport_searcher.start();


