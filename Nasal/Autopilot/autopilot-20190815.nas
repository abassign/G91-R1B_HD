# http://wiki.flightgear.org/Nasal_library#Positioned_Object_Queries
# http://wiki.flightgear.org/Nasal_library#findAirportsWithinRange.28.29

var timeStep = 0.5;

var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_name", "", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_id", "", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_id", "", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_nearest_runway", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_landing_status", "Autolanding inactive", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_landing_status_id", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_distance", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_delta_altitude", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-control-geo-is-nil","");

var d2r = 0.0174533;
var landing_activate_status = 0;
var airport_select = nil;
var rwy_select = 0;

var airport_select_info = 0.0;
var runway_select_rwy = 0.0;
var runway_alt_m_select = 0.0;
var runway_alt_m_complete_select = 0;
var landig_status_id = -1;
var isHolding_reducing_heading = 0.0;
var isHolding_reducing_heading_clipto = 0.0;
var isHolding_reducing_delta = 0;
var isHolding_reducing_distance = 0.0;
var isHolding_reducing_distance_rel = nil;
var isHolding_reducing_distance_rel_stright = nil;
var isHolding_reducing_terminated = 0;
var landing_slope_target = -4.0;
var landing_slope_integrate = 0.0;
var airplane_to_holding_point_alt = 0.0;
var landing_slope_delta = 0.0;
var landing_slope_delta_old = 0.0;

var apt_coord = geo.Coord.new();
var rwy_coord_start = geo.Coord.new();
var rwy_coord_end = geo.Coord.new();
var rwy_coord_end_offset = 3000.0;
var heading_target_active = 0.0;
var heading_target = 0.0;

var impact_control_active = 0;
var impact_is_in_security_zone = 1;
var impact_ramp = 0.0;
var impact_allarm = 0.0;
var impact_dist = 0.0;
var impact_dist_10 = 0.0;
var impact_time = 1.0;
var impact_time_10 = 1.0;
var impact_time_dif_0_10 = 100000.0;
var impact_time_prec = 1.0;
var impact_altitude_hold = 0;
var impact_vertical_speed_max_fpm = -100000.0;
var impact_vertical_speed_fpm = 0.0;
var impact_altitude_hold_inserted_delay_max = 10;
var impact_altitude_hold_inserted_delay = impact_altitude_hold_inserted_delay_max;
var impact_altitude_prec_ft = -100000.0;
var impact_altitude_future_prec_ft = -100000.0;
var impact_altitude_grain = 1.0;
var impact_altitude_direction_der_frist = 0.0;
var impact_altitude_grain_media = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0];
var impact_altitude_grain_media_size = 10;
var impact_altitude_grain_media_pivot = 0;


setlistener("fdm/jsbsim/systems/autopilot/gui/landing-activate", func {
    if (getprop("fdm/jsbsim/systems/autopilot/gui/landing-activate") == 1) {
        if (landig_status_id <= 0) {
            landig_status_id = 1;
        } else if (landig_status_id == 1 and airport_select != nil) {
            landing_activate_status = 1;
        } else {
            landing_activate_status = 0;
            landig_status_id = 0;
        }
    }
    setprop("fdm/jsbsim/systems/autopilot/gui/landing-activate",0);
}, 1, 0);


var pilot_assistant = maketimer(timeStep, func() {

    var slope = 0.0;
    var runway_to_airplane_dist = 0.0;
    
    if (landig_status_id == 1) {
        var landing_rwy_search_distance_max = getprop("fdm/jsbsim/systems/autopilot/gui/landing-rwy-search-distance-max");
        var landing_rwy_search_max_heading = getprop("fdm/jsbsim/systems/autopilot/gui/landing-rwy-search-max-heading");
        var landing_minimal_length_m = getprop("fdm/jsbsim/systems/autopilot/gui/landing-minimal-length-m");
        var landing_max_lateral_wind = getprop("fdm/jsbsim/systems/autopilot/gui/landing-max-lateral-wind");
        var airport_nearest_runway = getprop("fdm/jsbsim/systems/autopilot/gui/airport_nearest_runway");
        var apts = findAirportsWithinRange(landing_rwy_search_distance_max);
        var distance_to_airport_min = 9999.0;
        var airplane = geo.aircraft_position();
        var heading_true_deg = getprop("fdm/jsbsim/systems/autopilot/heading-true-deg");
        var wind_speed = getprop("/local-weather/METAR/wind-strength-kt"); print("###1: ", wind_speed);
        var wind_from = getprop("/local-weather/METAR/wind-direction-deg"); print("###2: ", wind_from);
        var rwy_coord = geo.Coord.new();
        airport_select = nil;
        if (apts != nil and airplane != nil) {
            foreach(var apt; apts) {
                var airport = airportinfo(apt.id);
                # Select the airport in the frontal direction
                apt_coord.set_latlon(airport.lat,airport.lon);
                if (math.abs(geo.normdeg(heading_true_deg-airplane.course_to(apt_coord))) <= landing_rwy_search_max_heading) {
                    foreach(var rwy; keys(airport.runways)) {
                        var wind_deviation = math.abs(geo.normdeg(wind_from - airport.runways[rwy].heading));
                        var wind_compatibility_ok = 1;
                        if (wind_speed * (1 - math.cos(wind_deviation * d2r)) > landing_max_lateral_wind) {
                            wind_compatibility_ok = 0;
                        }
                        print("Landing 1.0 > Airport: ",airport.id,
                            " ",airport.runways[rwy].id,
                            " ",airport.runways[rwy].length,
                            " Wind speed: ",wind_speed, " Wind direction: ",wind_from, " Wind deviation: ",wind_deviation, " compatibility: ",wind_compatibility_ok,
                            " Lat wind: ", wind_speed * (1 - math.cos(wind_deviation * d2r)));
                        # Select the sufficient runway lenght
                        if (airport.runways[rwy].length >= landing_minimal_length_m and (wind_compatibility_ok or airport_nearest_runway)) {
                            rwy_coord.set_latlon(airport.runways[rwy].lat,airport.runways[rwy].lon);
                            runway_to_airplane_dist = airplane.distance_to(rwy_coord) * 0.000621371;
                            # Search the rwy with minimal condition
                            if (distance_to_airport_min > runway_to_airplane_dist) {
                                distance_to_airport_min = runway_to_airplane_dist;
                                airport_select = airport;
                                rwy_select = rwy;
                            }
                        }
                    }
                }
            }
        }
        if (airport_select != nil) {
            rwy_coord_start.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon);
            runway_to_airplane_dist = airplane.distance_to(rwy_coord_start) * 0.000621371;
            var runway_to_airplane_delta_alt_ft = (airplane.alt() - airport_select.elevation) * 3.28084;
            if (math.abs(runway_to_airplane_dist > 0.1)) {
                slope = math.atan((runway_to_airplane_delta_alt_ft * 0.000189394) / runway_to_airplane_dist) * R2D;
            }
            runway_alt_m_complete_select = 0;
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id",airport_select.id);
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_name",airport_select.name);
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_id",airport_select.runways[rwy_select].id);
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_distance",runway_to_airplane_dist);
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope",slope);
            if (landing_activate_status == 1) {
                # Find an airport
                landig_status_id = 2;
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-active",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",math.round(getprop("fdm/jsbsim/systems/autopilot/h-sl-ft-lag")));
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",getprop("fdm/jsbsim/systems/autopilot/heading-true-deg"));
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/heading-control",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/wing-leveler",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/phi-heading",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",30.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/rudder-auto-coordination",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",3000.0);
                setprop("fdm/jsbsim/systems/autopilot/phase-landing",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-control",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-flap",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-throttle",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-pitch",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                if (getprop("fdm/jsbsim/systems/autopilot/speed-cas-on-air") < 250) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",250.0);
                } else {
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",getprop("fdm/jsbsim/systems/autopilot/speed-cas-on-air"));
                }
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",250.0);
                setprop("fdm/jsbsim/systems/autopilot/speed-throttle-imposed",-1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",2.0);
                rwy_coord_end.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon); 
                rwy_coord_end.apply_course_distance(airport_select.runways[rwy_select].heading,rwy_coord_end_offset);
                airplane_to_holding_point_alt = airplane.alt() * 3.28084;
            } else {
                landig_status_id = 1;
            }
        }
    }
    
    if (landig_status_id == 1 and airport_select == nil) {
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_landing_status","No airport for landing");
    } else if (landig_status_id >= 1 and airport_select != nil) {
        ## print("Autopilot - pilot_assistant - Airport found");
        var runway_to_airplane_dist = 0;
        var holding_point_distance_nm = getprop("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-dist-nm");
        var holding_point_before_distance_nm = 4.0;
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
        var holding_point_h_ft = getprop("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-h-ft");
        var holding_point_slope_max = 5.0;
        var holding_point_slope_min = 3.0;
        var holding_point_slope_avg = (holding_point_slope_max + holding_point_slope_min) / 2;
        #
        # Common eleboration
        #
        if (landig_status_id >= 2.0 and landig_status_id < 3.0) {
            runway_to_airplane_dist = airplane.distance_to(rwy_coord_start) * 0.000621371 + rwy_offset_h_nm;
        } else {
            runway_to_airplane_dist = airplane.distance_to(rwy_coord_start) * 0.000621371;
        }
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_distance",runway_to_airplane_dist);
        if (runway_alt_m_complete_select == 0) { 
            var test_runway_alt_m_select = geo.elevation(airport_select.runways[rwy_select].lat, airport_select.runways[rwy_select].lon);
            if (test_runway_alt_m_select != nil) {
                runway_alt_m_select = test_runway_alt_m_select;
                runway_alt_m_complete_select = 1;
            } else {
                runway_alt_m_select = airport_select.elevation;
            }
        }
        runway_to_airplane_delta_alt_ft = (airplane.alt() - runway_alt_m_select) * 3.28084;
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_delta_altitude",runway_to_airplane_delta_alt_ft);
        heading_correction = (airport_select.runways[rwy_select].heading - airplane.course_to(rwy_coord_start));
        heading_correct = airport_select.runways[rwy_select].heading - heading_correction;
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
        if (runway_to_airplane_dist > 0.1) {
            slope = math.atan((runway_to_airplane_delta_alt_ft * 0.000189394) / runway_to_airplane_dist) * R2D;
        } else {
            slope = 0.0;
        }
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope",slope);
        #
        # Select and elaborate the effective landing phase
        #
        if (landig_status_id == 2.0) {
            # Fly to the holding point
            var holding_point = geo.Coord.new();
            holding_point.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon,rwy_offset_v_ft * 3.28084);
            holding_point.apply_course_distance(airport_select.runways[rwy_select].heading + 180.0,holding_point_distance_nm * 1852.0);
            var holding_point_to_airplane_dist = airplane.distance_to(holding_point) * 0.000621371;
            var holding_point_to_airplane_dist_direct = airplane.direct_distance_to(holding_point) * 0.000621371;
            var holding_point_to_airplane_delta_alt_ft = airplane.alt() * 3.28084 - (runway_alt_m_select * 3.28084 + holding_point_h_ft);
            slope = math.asin((holding_point_to_airplane_delta_alt_ft * 0.000189394) / holding_point_to_airplane_dist_direct) * R2D;
            var holding_point_to_airplane_dist_for_slope = 0.0;
            if (slope < holding_point_slope_max) {
                holding_point_to_airplane_dist_for_slope = holding_point_to_airplane_dist - (holding_point_to_airplane_delta_alt_ft/math.tan(slope / R2D));
            }
            var heading_correction_for_before_dist = math.abs(geo.normdeg180(getprop("fdm/jsbsim/systems/autopilot/heading-true-deg") - airplane.course_to(rwy_coord_start)));
            if (heading_correction_for_before_dist < 90) {
                holding_point_before_distance_nm = 1.8;
            } else {
                holding_point_before_distance_nm = 1.8 * (1 + ((heading_correction_for_before_dist - 90.0) / 90.0));
            }
            if (holding_point_to_airplane_dist > holding_point_before_distance_nm) {
                heading_correct = airplane.course_to(holding_point);
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
                print("Landing 2.0 >"
                ,sprintf(" Hoding dist (nm): %.1f",holding_point_to_airplane_dist_direct)
                ,sprintf(" Alt to hld (ft): %.0f",holding_point_to_airplane_delta_alt_ft)
                ,sprintf(" Slope: %.1f",slope)
                ,sprintf(" Heading correct: %.1f",heading_correct)
                ,sprintf(" Heading correction: %.1f",heading_correction_for_before_dist)
                ,sprintf(" Hld. pt to plane (nm): %.1f",holding_point_to_airplane_dist)
                ,sprintf(" Hld. pt (nm): %.1f",holding_point_before_distance_nm));
            } else {
                landig_status_id = 2.1;
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",45.0);
                setprop("fdm/jsbsim/systems/autopilot/phase-landing",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",180.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",2.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",3000.0);
                isHolding_reducing_delta = -20;
                isHolding_reducing_heading = nil;
                isHolding_reducing_distance_rel = nil;
                isHolding_reducing_terminated = 0;
                runway_to_airplane_dist_direct = airplane.direct_distance_to(rwy_coord_start) * 0.000621371 + rwy_offset_h_nm;
                holding_point_h_ft = math.sin(holding_point_slope_avg / R2D) * runway_to_airplane_dist_direct * 6076.12;
                setprop("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-h-ft",holding_point_h_ft);
            }
        } else if (landig_status_id == 2.1) {
            # Fly near the holding point
            runway_to_airplane_dist_direct = airplane.direct_distance_to(rwy_coord_start) * 0.000621371 + rwy_offset_h_nm;
            slope = math.asin(((runway_to_airplane_delta_alt_ft - rwy_offset_v_ft)* 0.000189394) / runway_to_airplane_dist_direct) * R2D;
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope",slope);
            runway_to_airplane_dist = airplane.distance_to(rwy_coord_start) * 0.000621371 + rwy_offset_h_nm;
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_distance",runway_to_airplane_dist);
            var rwy_point_delta_alt_ft = (airplane.alt() - runway_alt_m_select) * 3.28084 + holding_point_h_ft;
            if (isHolding_reducing_terminated == 0) {
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",3000.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",runway_alt_m_select * 3.28084 + holding_point_h_ft);
            }
            if (isHolding_reducing_delta < 0) {
                # Delay
                isHolding_reducing_delta = isHolding_reducing_delta + 1;
            }
            if ((math.abs(slope - holding_point_slope_avg)) < 1.0 and isHolding_reducing_terminated == 0) {
                isHolding_reducing_terminated = 1;
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",math.round(getprop("fdm/jsbsim/systems/autopilot/h-sl-ft-lag")));
            }
            if (isHolding_reducing_terminated == 0 or isHolding_reducing_delta >= 0) {
                # Set approch point
                # Direct landing
                # holding_point_h_ft ft - 10 nm slope 3-4°
                # Is near the airport verify the delta
                # Is necesary the quote reduction
                if (isHolding_reducing_delta == 0) {
                    if (isHolding_reducing_heading == nil) {
                        isHolding_reducing_heading = airplane.course_to(rwy_coord_start);
                    }
                    isHolding_reducing_heading_clipto = isHolding_reducing_heading + 90.0;
                    if (isHolding_reducing_heading_clipto >= 360.0) isHolding_reducing_heading_clipto = isHolding_reducing_heading_clipto - 360.0;
                    setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",math.abs(isHolding_reducing_heading_clipto));
                    if (isHolding_reducing_distance_rel == nil) {
                        isHolding_reducing_distance_rel = getprop("fdm/jsbsim/systems/autopilot/distance-nm");
                    } else if (isHolding_reducing_distance_rel_stright == nil) {
                        if ((getprop("fdm/jsbsim/systems/autopilot/distance-nm") - isHolding_reducing_distance_rel) > 0.5) {
                            if (math.abs(getprop("fdm/jsbsim/systems/autopilot/true-heading-deg-delta")) < 0.5) {
                                isHolding_reducing_distance_rel_stright = getprop("fdm/jsbsim/systems/autopilot/distance-nm");
                            }
                        }
                    } else {
                        if ((getprop("fdm/jsbsim/systems/autopilot/distance-nm") - isHolding_reducing_distance_rel_stright) > 0.5) {
                            isHolding_reducing_distance_rel = nil;
                            isHolding_reducing_distance_rel_stright = nil;
                            isHolding_reducing_delta = 1;
                        }
                    }
                } else if (isHolding_reducing_delta == 1) {
                    isHolding_reducing_heading_clipto = isHolding_reducing_heading + 180.0;
                    if (isHolding_reducing_heading_clipto >= 360.0) isHolding_reducing_heading_clipto = isHolding_reducing_heading_clipto - 360.0;
                    setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",math.abs(isHolding_reducing_heading_clipto));
                    if (isHolding_reducing_distance_rel == nil) {
                        isHolding_reducing_distance_rel = getprop("fdm/jsbsim/systems/autopilot/distance-nm");
                    } else if (isHolding_reducing_distance_rel_stright == nil) {
                        if ((getprop("fdm/jsbsim/systems/autopilot/distance-nm") - isHolding_reducing_distance_rel) > 0.5) {
                            if (math.abs(getprop("fdm/jsbsim/systems/autopilot/true-heading-deg-delta")) < 0.5) {
                                isHolding_reducing_distance_rel_stright = getprop("fdm/jsbsim/systems/autopilot/distance-nm");
                            }
                        }
                    } else {
                        if ((getprop("fdm/jsbsim/systems/autopilot/distance-nm") - isHolding_reducing_distance_rel_stright) > 3.0) {
                            isHolding_reducing_distance_rel = nil;
                            isHolding_reducing_distance_rel_stright = nil;
                            isHolding_reducing_delta = 2;
                        }
                    }
                } else if (isHolding_reducing_delta == 2) {
                    isHolding_reducing_heading_clipto = isHolding_reducing_heading + 270.0;
                    if (isHolding_reducing_heading_clipto >= 360.0) isHolding_reducing_heading_clipto = isHolding_reducing_heading_clipto - 360.0;
                    setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",math.abs(isHolding_reducing_heading_clipto));
                    if (isHolding_reducing_distance_rel == nil) {
                        isHolding_reducing_distance_rel = getprop("fdm/jsbsim/systems/autopilot/distance-nm");
                    } else if (isHolding_reducing_distance_rel_stright == nil) {
                        if ((getprop("fdm/jsbsim/systems/autopilot/distance-nm") - isHolding_reducing_distance_rel) > 0.5) {
                            if (math.abs(getprop("fdm/jsbsim/systems/autopilot/true-heading-deg-delta")) < 0.5) {
                                isHolding_reducing_distance_rel_stright = getprop("fdm/jsbsim/systems/autopilot/distance-nm");
                            }
                        }
                    } else {
                        if ((getprop("fdm/jsbsim/systems/autopilot/distance-nm") - isHolding_reducing_distance_rel_stright) > 0.5) {
                            isHolding_reducing_distance_rel = nil;
                            isHolding_reducing_distance_rel_stright = nil;
                            isHolding_reducing_delta = 3;
                        }
                    }
                } else if (isHolding_reducing_delta == 3) {
                    isHolding_reducing_heading_clipto = isHolding_reducing_heading + 360.0;
                    if (isHolding_reducing_heading_clipto >= 360.0) isHolding_reducing_heading_clipto = isHolding_reducing_heading_clipto - 360.0;
                    setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",math.abs(isHolding_reducing_heading_clipto));
                    if (isHolding_reducing_distance_rel == nil) {
                        isHolding_reducing_distance_rel = getprop("fdm/jsbsim/systems/autopilot/distance-nm");
                    } else if (isHolding_reducing_distance_rel_stright == nil) {
                        if ((getprop("fdm/jsbsim/systems/autopilot/distance-nm") - isHolding_reducing_distance_rel) > 0.5) {
                            if (math.abs(getprop("fdm/jsbsim/systems/autopilot/true-heading-deg-delta")) < 0.5) {
                                isHolding_reducing_distance_rel_stright = getprop("fdm/jsbsim/systems/autopilot/distance-nm");
                            }
                        }
                    } else {
                        if ((getprop("fdm/jsbsim/systems/autopilot/distance-nm") - isHolding_reducing_distance_rel_stright) > 3.0) {
                            isHolding_reducing_heading = nil;
                            isHolding_reducing_distance_rel = nil;
                            isHolding_reducing_distance_rel_stright = nil;
                            isHolding_reducing_delta = -2;
                        }
                    }
                }
            } else {
                landig_status_id = 2.2;
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",2.0); ## Verify the correct condition for proximity ostacle (?)
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",30.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",1.0);
                setprop("fdm/jsbsim/systems/autopilot/landing-gear-activate-blocked",0.0);
                landing_slope_integrate = 0.0;
            }
            print("Landing 2.1 >"
            ,sprintf(" Dist (nm): %.1f",runway_to_airplane_dist)
            ,sprintf(" Alt (ft): %.1f",(runway_to_airplane_delta_alt_ft - rwy_offset_v_ft)* 0.000189394)
            ,sprintf(" Alt delta (ft): %.1f",rwy_point_delta_alt_ft)
            ,sprintf(" Slope: %.1f",slope)
            ,sprintf(" holding_point_h_ft (ft): %.0f",holding_point_h_ft)
            ,sprintf(" isHolding_reducing_delta: %.0f",isHolding_reducing_delta)
            ,sprintf(" is Term: %.0f",isHolding_reducing_terminated));
        } else if (landig_status_id == 2.2) {
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",1.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",0.0);
            runway_to_airplane_dist_direct = airplane.direct_distance_to(rwy_coord_start) * 0.000621371 + rwy_offset_h_nm;
            if ((airplane.distance_to(rwy_coord_start) * 0.000621371) > 0.8) {
                if (runway_to_airplane_dist_direct <= 12.0 and runway_to_airplane_dist_direct >= 8.0) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",180.0);
                    setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-active",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-flap",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",2.0);
                }
                if (runway_to_airplane_dist_direct < 8.0) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",160.0);
                    setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-active",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-flap",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/landing-gear-activate-blocked",1.0);
                }
                var rwy_coord_start_final = geo.Coord.new();
                rwy_coord_start_final.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon);
                rwy_coord_start_final.apply_course_distance(airport_select.runways[rwy_select].heading - 180,(runway_to_airplane_dist_direct - 3) * 1852.0);
                heading_correction = geo.normdeg180(airport_select.runways[rwy_select].heading - airplane.course_to(rwy_coord_start_final));
                var heading_factor = 1.8;
                if (runway_to_airplane_dist_direct < 10.0) {
                    if (math.abs(heading_correction) >= 10) {
                        heading_factor = (18 / runway_to_airplane_dist_direct);
                    } else {
                        heading_factor = (10 - math.abs(heading_correction)) * (1.8 / runway_to_airplane_dist_direct);
                    }
                }
                if (heading_factor > 50.0) heading_factor = 50.0;
                heading_correct = geo.normdeg180(airport_select.runways[rwy_select].heading - heading_correction * heading_factor);
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
                # Slope correction
                var slope_target = - 4.0;
                if (runway_to_airplane_dist_direct < 10.0 and runway_to_airplane_dist_direct > 6.0) {
                    if (runway_to_airplane_dist_direct < 10.0 and runway_to_airplane_dist_direct > 6.0) {
                        slope_target = - 4.0 + (10.0 - runway_to_airplane_dist_direct) / 4.0;
                    } else slope_target = -3.5;
                } else if (runway_to_airplane_dist_direct <= 4.0) {
                    if (runway_to_airplane_dist_direct <= 4.0 and runway_to_airplane_dist_direct > 2.0) {
                        slope_target = - 3.5 + (4.0 - runway_to_airplane_dist_direct) / 2.0;
                    } else slope_target = -2.5;
                }
                slope = - math.asin(((runway_to_airplane_delta_alt_ft + rwy_offset_v_ft)* 0.000189394) / runway_to_airplane_dist_direct) * R2D;
                landing_slope_delta = slope - slope_target;
                if (math.abs(landing_slope_delta) < 1.0) {
                    
                }
                if (landing_slope_delta > 0.1) {
                    if (landing_slope_delta_old < -0.1) landing_slope_integrate = 0.0;
                    landing_slope_delta = (landing_slope_delta) * 3.0 * math.ln(1.8 + landing_slope_delta);
                    landing_slope_integrate = landing_slope_integrate + landing_slope_delta;
                } else if (landing_slope_delta < -0.1) {
                    if (landing_slope_delta_old > 0.1) landing_slope_integrate = 0.0;
                    landing_slope_delta = (landing_slope_delta) * 0.5 * math.ln(1.5 - landing_slope_delta);
                    landing_slope_integrate = landing_slope_integrate + landing_slope_delta;
                }
                landing_slope_delta_old = landing_slope_delta;
                var speed_cas = getprop("fdm/jsbsim/systems/autopilot/speed-cas-on-air");
                if (runway_to_airplane_dist_direct <= 6.0 and speed_cas < 175.0) {
                    if (landing_slope_integrate < -4.5) landing_slope_integrate = -4.5;
                    if (landing_slope_integrate > 4.5) landing_slope_integrate = 4.5;
                } else {
                    if (speed_cas < 185.0) {
                        if (landing_slope_integrate < -5.5) landing_slope_integrate = -5.5;
                    } else {
                        if (landing_slope_integrate < -4.0) landing_slope_integrate = -4.0;
                    }
                }
                if (landing_slope_integrate > 10.0) landing_slope_integrate = 10.0;
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg", slope_target + landing_slope_integrate);
                print("Landing 2.2 >"
                ,sprintf(" Dist (nm): %.1f",runway_to_airplane_dist_direct)
                ,sprintf(" Delta h (ft): %.0f",runway_to_airplane_delta_alt_ft)
                ,sprintf(" Slope: %.2f",slope_target + landing_slope_integrate)
                ,sprintf(" (%.2f|",slope)
                ,sprintf("%.2f|",slope_target)
                ,sprintf("%.2f|",landing_slope_integrate)
                ,sprintf("%.2f)",landing_slope_delta)
                ,sprintf(" Heading: %.1f",heading_correct)
                ,sprintf(" H. cor: %.2f",heading_correction)
                ,sprintf(" H. factor: %.2f",heading_factor));
            } else {
                landig_status_id = 2.5;
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",50.0);
                setprop("fdm/jsbsim/systems/autopilot/steer-brake",1.0);
            }
        } else if (landig_status_id == 2.5) {
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",1.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",0.0);
            runway_to_airplane_dist_direct = airplane.direct_distance_to(rwy_coord_start) * 0.000621371 + rwy_offset_h_nm;
            if (gear_unit_contact >= 1) {
                landig_status_id = 3.0;
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",-3.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",30.0);
                setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-active",1.0);
                setprop("fdm/jsbsim/systems/dragchute/activate",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-flap",1.0);
                if (getprop("fdm/jsbsim/systems/autopilot/gui/landing-short-profile") > 0.0) {
                    setprop("fdm/jsbsim/systems/dragchute/activate",1.0);
                }
                
            } else {
                var runway_end_to_airplane_dist_direct = airplane.direct_distance_to(rwy_coord_end) * 0.000621371;
                var slope_target = 2.5;
                altitude_agl_ft = getprop("/position/altitude-agl-ft");
                if (altitude_agl_ft >= 200.0) {
                    slope = getprop("fdm/jsbsim/systems/autopilot/pitch-descent-angle-deg");
                } else {
                    slope = getprop("fdm/jsbsim/attitude/theta-deg");
                    slope_target = 2.0 - 6.0 * (altitude_agl_ft / 200.0);
                }
                landing_slope_delta = slope - slope_target;
                if (landing_slope_delta > 0.1) {
                    if (landing_slope_delta_old < -0.1) landing_slope_integrate = 0.0;
                    landing_slope_delta = (landing_slope_delta) * 0.2 * math.ln(1.5 + landing_slope_delta);
                    landing_slope_integrate = landing_slope_integrate + landing_slope_delta;
                } else if (landing_slope_delta < -0.1) {
                    if (landing_slope_delta_old > 0.1) landing_slope_integrate = 0.0;
                    landing_slope_delta = (landing_slope_delta) * 0.1 * math.ln(1.2 - landing_slope_delta);
                    landing_slope_integrate = landing_slope_integrate + landing_slope_delta;
                }
                landing_slope_delta_old = landing_slope_delta;
                var speed_cas = getprop("fdm/jsbsim/systems/autopilot/speed-cas-on-air");
                if (landing_slope_integrate < -3.0) landing_slope_integrate = -3.0;
                if (landing_slope_integrate > 2.0) landing_slope_integrate = 2.0;
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg", slope_target + landing_slope_integrate);
                var rwy_coord_start_final = geo.Coord.new();
                rwy_coord_start_final.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon);
                rwy_coord_start_final.apply_course_distance(airport_select.runways[rwy_select].heading - 180,(runway_to_airplane_dist_direct - 3) * 1852.0);
                heading_correction = geo.normdeg180(airport_select.runways[rwy_select].heading - airplane.course_to(rwy_coord_start_final));
                var heading_factor = 1.8;
                heading_factor = (10 - math.abs(heading_correction)) * (1.8 / runway_to_airplane_dist_direct);
                if (heading_factor > 50.0) heading_factor = 50.0;
                heading_correct = geo.normdeg180(airport_select.runways[rwy_select].heading - heading_correction * heading_factor);
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
                print("Landing 2.5 >"
                ,sprintf(" Dist (nm): %.1f",runway_to_airplane_dist_direct)
                ,sprintf(" Delta h (ft): %.0f",altitude_agl_ft)
                ,sprintf(" Slope: %.2f",slope_target + landing_slope_integrate)
                ,sprintf(" (%.2f|",slope)
                ,sprintf("%.2f|",slope_target)
                ,sprintf("%.2f|",landing_slope_integrate)
                ,sprintf("%.2f)",landing_slope_delta)
                ,sprintf(" Heading: %.1f",heading_correct)
                ,sprintf(" H. cor: %.2f",heading_correction)
                ,sprintf(" H. factor: %.2f",heading_factor)
                ,sprintf(" Gear contact: %.0f",gear_unit_contact));
            }
        } else if (landig_status_id == 3.0) {
            if (getprop("fdm/jsbsim/systems/autopilot/speed-true-on-air") < 35.0) {
                landig_status_id = 4;
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",-5.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",0.0);
                setprop("fdm/jsbsim/systems/autopilot/steer-brake",1.0);
                setprop("fdm/jsbsim/systems/autopilot/speed-throttle-imposed",0.1);
                setprop("fdm/jsbsim/systems/autopilot/handle-brake-activate",1);
                slope = 0.0;
            } else {
                heading_correction = (airport_select.runways[rwy_select].heading - airplane.course_to(rwy_coord_end));
                var heading_factor = 1 / math.log10(1.05 + math.abs(heading_correction));
                heading_correct = airport_select.runways[rwy_select].heading - heading_correction * heading_factor;
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
                print("Landing 3.0 >"
                ,sprintf(" Dist (nm): %.1f",runway_to_airplane_dist)
                ,sprintf(" Heading: %.1f",heading_correct)
                ,sprintf(" H. cor: %.2f",heading_correction)
                ,sprintf(" H. factor: %.2f",heading_factor)
                ,sprintf(" Gear contact: %.0f",gear_unit_contact)
                ,sprintf(" Gear brake mod: %.0f",getprop("fdm/jsbsim/systems/autopilot/steer-brake-modulated"))
                ,sprintf(" Gear brake int: %.0f",getprop("fdm/jsbsim/systems/brake/left-steer-brake-intensity"))
                ,sprintf(" Dragchute: %.0f",getprop("fdm/jsbsim/systems/dragchute/magnitude"))
                );
            }
        } else if (landig_status_id == 4.0) {
            heading_correction = (airport_select.runways[rwy_select].heading - airplane.course_to(rwy_coord_end)) * 5.0;
            heading_correct = airport_select.runways[rwy_select].heading - heading_correction;
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
            setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
            print("Landing 4.0 >"
            ,sprintf(" Dist (nm): %.1f",runway_to_airplane_dist)
            ,sprintf(" Heading: %.1f",heading_correct)
            ,sprintf(" H. cor: %.1f",heading_correction)
            ,sprintf(" Gear contact: %.0f",gear_unit_contact)
            ,sprintf(" Gear brake mod: %.0f",getprop("fdm/jsbsim/systems/autopilot/steer-brake-modulated"))
            ,sprintf(" Gear brake int: %.0f",getprop("fdm/jsbsim/systems/brake/left-steer-brake-intensity")));
        }
        #
        # Output
        #
        var landing_status = airport_select.id ~ " | " ~ airport_select.name ~ " | " ~ airport_select.runways[rwy_select].id;
        if (landig_status_id == 1) {
            landing_status = "Airport found " ~ landing_status;
        } else if (landig_status_id == 2)  {
            landing_status = "Airport to land " ~ landing_status;
        } else if (landig_status_id == 2.1) {
            landing_status = "Airport approach " ~ landing_status;
        } else if (landig_status_id == 2.2) {
            landing_status = "Airport final " ~ landing_status;
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
            airport_select = nil;
            # Reset the landing data
            setprop("fdm/jsbsim/systems/autopilot/gui/heading-control",1.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/true-heading",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/wing-leveler",1.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/altitude-active",1.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",1.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-control",1.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-throttle",1.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-pitch",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",getprop("fdm/jsbsim/systems/autopilot/speed-cas-on-air"));
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-brake",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-flap",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",0.0);
            setprop("fdm/jsbsim/systems/autopilot/speed-throttle-imposed",-1.0);
            setprop("fdm/jsbsim/systems/autopilot/phase-landing",0.0);
            setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-active",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",0.0);
            setprop("fdm/jsbsim/systems/autopilot/landing-gear-activate-blocked",0.0);
            setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-close",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",1000.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",6.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id","");
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_name","");
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_id","");
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_distance",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_delta_altitude",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_landing_status","Autolanding inactive");
        }
    }
    
    #
    # Impact control
    #
    
    impact_control_active = getprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active");
    if (impact_control_active > 0.0 and (getprop("velocities/speed-east-fps") != 0 or getprop("velocities/speed-north-fps") != 0)) {
        var impact_medium_time_gui = getprop("fdm/jsbsim/systems/autopilot/gui/impact-medium-time");
        var impact_ramp_min = -(21 - impact_medium_time_gui);
        impact_altitude_grain_media_size = impact_medium_time_gui;
        impact_altitude_hold_inserted_delay_max = math.round(0.5 + impact_medium_time_gui);
        var impact_min_z_ft = getprop("fdm/jsbsim/systems/autopilot/gui/impact-min-z-ft") * impact_altitude_grain * 1.2;
        var impact_time_delta = 0.0;
        var altitude_hold_inserted = getprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold");
        var altitude_hold_inserted_ft = getprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft");
        var altitude_actual = getprop("fdm/jsbsim/systems/autopilot/h-sl-ft-lag");
        var start = geo.aircraft_position();
        var speed_cas = getprop("fdm/jsbsim/systems/autopilot/speed-cas-on-air");
        var speed_east_fps = getprop("velocities/speed-east-fps");
        var speed_north_fps = getprop("velocities/speed-north-fps");
        var speed_horz_fps = math.sqrt((speed_east_fps*speed_east_fps)+(speed_north_fps*speed_north_fps));
        var speed_down_fps = getprop("velocities/speed-down-fps") + speed_horz_fps * math.tan(impact_ramp / R2D);
        var speed_down_10_fps = getprop("velocities/speed-down-fps") + speed_horz_fps * math.tan((impact_ramp - 30.0) / R2D);
        var speed_fps = math.sqrt((speed_horz_fps*speed_horz_fps) + (speed_down_fps*speed_down_fps));
        var heading = 0;
        var impact_allarm_solution = 0;
        var impact_ramp_delta = 0.0;
        var impact_ramp_max = 24.0 * (speed_cas / 200.0);
        var future_time = 1 + (speed_cas / 120.0);
        var end_alt = 0.0;
        var end_future_alt =0.0;
        
        setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-geo-is-nil","");
        
        if (speed_north_fps >= 0) {
            heading -= math.acos(speed_east_fps/speed_horz_fps)*R2D - 90;
        } else {
            heading -= -math.acos(speed_east_fps/speed_horz_fps)*R2D - 90;
        }
        heading = geo.normdeg(heading);

        # Define impact_min_z_ft in the landing phase
        if (impact_control_active == 2) {
            impact_min_z_ft = math.tan(getprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope") / R2D) * getprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_distance") * 6076.12;
        }
        
        var end = geo.Coord.new(start);
        var end_future = geo.Coord.new(start);
        end.apply_course_distance(heading, speed_horz_fps * FT2M);
        end_future.apply_course_distance(heading, future_time * speed_horz_fps * FT2M);
        end.set_alt(end.alt() - (impact_min_z_ft * FT2M) - speed_down_fps * FT2M);
        end_future.set_alt(end_future.alt() - (impact_min_z_ft * FT2M) - future_time * speed_down_fps * FT2M);
        var end_10 = geo.Coord.new(start);
        end_10.apply_course_distance(heading, speed_horz_fps * FT2M);
        end_10.set_alt(end_10.alt() - (impact_min_z_ft * FT2M) - speed_down_10_fps * FT2M);
        
        var dir_x = end.x()-start.x();
        var dir_y = end.y()-start.y();
        var dir_z = end.z()-start.z();
        var dir_future_x = end_future.x()-start.x();
        var dir_future_y = end_future.y()-start.y();
        var dir_future_z = end_future.z()-start.z();
        var dir_10_z = end_10.z()-start.z();
        var xyz = {"x":start.x(),"y":start.y(),"z":start.z()};
        var dir = {"x":dir_x,"y":dir_y,"z":dir_z};
        var dir_future = {"x":dir_future_x,"y":dir_future_y,"z":dir_future_z};
        var dir_10 = {"x":dir_x,"y":dir_y,"z":dir_10_z};

        var geod = get_cart_ground_intersection(xyz, dir);
        var geod_future = get_cart_ground_intersection(xyz, dir_future);
        var geod_10 = get_cart_ground_intersection(xyz, dir_10);
        
        if (geod != nil and geod_future != nil and speed_fps > 1.0) {
            end.set_latlon(geod.lat, geod.lon, geod.elevation);
            end_future.set_latlon(geod_future.lat, geod_future.lon, geod_future.elevation);
            impact_dist = start.direct_distance_to(end) * M2FT;
            impact_time = impact_dist / speed_fps;
            if (geod_10 != nil) {
                end_10.set_latlon(geod_10.lat, geod_10.lon, geod_10.elevation);
                impact_dist_10 = start.direct_distance_to(end_10) * M2FT;
                impact_time_10 = impact_dist_10 / speed_fps;
                impact_time_dif_0_10 = impact_time_10 - impact_time;
            } else {
                impact_dist_10 = -1.0;
                impact_time_10 = -1.0;
                impact_time_dif_0_10 = 100000.0;
            }
            # Calculate the derivate avg n seconds
            if (impact_altitude_prec_ft <= -100000.0) {
                impact_altitude_prec_ft = (end.alt() * M2FT);
            }
            if (impact_altitude_future_prec_ft <= -100000.0) {
                impact_altitude_future_prec_ft = (end_future.alt() * M2FT);
            }
            impact_altitude_grain_media[impact_altitude_grain_media_pivot] = (((end.alt() * M2FT ) - impact_altitude_prec_ft) + ((end_future.alt() * M2FT ) - impact_altitude_future_prec_ft)) / 2;
            ## print("###: ",speed_horz_fps," ",speed_down_fps," ",future_time," ", end.alt() * M2FT ," ",end_future.alt() * M2FT," ",((end.alt() * M2FT ) - impact_altitude_prec_ft)," ", ((end_future.alt() * M2FT ) - impact_altitude_future_prec_ft));
            impact_altitude_grain_media_pivot = impact_altitude_grain_media_pivot + 1;
            if (impact_altitude_grain_media_pivot >= impact_altitude_grain_media_size) {
                impact_altitude_grain_media_pivot = 0;
            }
            impact_altitude_grain = 0.0;
            impact_altitude_direction_der_frist = 0.0;
            for (var i=0; i < impact_altitude_grain_media_size; i = i+1) {
                impact_altitude_grain = impact_altitude_grain + abs(impact_altitude_grain_media[i]);
                impact_altitude_direction_der_frist = impact_altitude_direction_der_frist + impact_altitude_grain_media[i];
                ### print("###: ",i,sprintf(" IAG: %.1f",impact_altitude_grain_media[i]),sprintf(" IAD: %.1f",impact_altitude_direction_der_frist));
            }
            impact_altitude_direction_der_frist = impact_altitude_direction_der_frist / impact_altitude_grain_media_size;
            
            if (impact_altitude_direction_der_frist >= 0) {
                impact_altitude_grain = (impact_altitude_grain / impact_altitude_grain_media_size) * (3.0 * math.log10(1 + math.abs(impact_altitude_direction_der_frist)));
            } else {
                impact_altitude_grain = (impact_altitude_grain / impact_altitude_grain_media_size) * (3.0 * math.log10(2));
            }
            
            if (impact_altitude_grain <= 1.0) {
                impact_altitude_grain = 1.0;
            } else {
                impact_altitude_grain = 1.0 * (1 + math.ln(impact_altitude_grain));
            }
            impact_altitude_prec_ft = end.alt() * M2FT;
            impact_altitude_future_prec_ft = end_future.alt() * M2FT;
            # calculate the impact_medium_time
            impact_time_delta = impact_time_prec - impact_time;
            impact_time_prec = impact_time;
        } else {
            impact_dist = 0.0;
            impact_time = -1.0;
        }
        
        setprop("fdm/jsbsim/systems/autopilot/impact-dist",impact_dist);
        setprop("fdm/jsbsim/systems/autopilot/impact-time",impact_time);
        ### setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",0.0);

        var altitude_delta = altitude_actual - (end.alt() * M2FT);
        impact_is_in_security_zone = (altitude_hold_inserted == 1)
        and (altitude_hold_inserted_ft > (end.alt() * M2FT + ( 2.0 * impact_min_z_ft)))
        and (altitude_actual > (end.alt() * M2FT));
        
        if (impact_control_active > 0 and geod != nil) {
            if (((impact_time < 8.0) and (impact_time_dif_0_10 > -0.25) and (impact_is_in_security_zone == 0 or (impact_is_in_security_zone == 1 and impact_time_dif_0_10 < 1.0)))
            and ((((impact_time / impact_altitude_grain) < 0.9) and math.abs(impact_altitude_direction_der_frist) > 1)
            or (impact_altitude_direction_der_frist > 5.0) 
            or ((abs(impact_time_dif_0_10) < impact_altitude_grain) and (impact_altitude_direction_der_frist > 2.0)))) {
                if (((impact_time < 5.0) and (abs(impact_time_dif_0_10) < 4.0))
                or ((impact_time < 7.0) and (abs(impact_time_dif_0_10) < 0.5))) {
                    if (speed_cas < 270 and getprop("fdm/jsbsim/systems/autopilot/gui/speed-value") < 270) {
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",270.0);
                        setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-active",0.0);
                    }
                    if (impact_ramp < 1.0) impact_ramp = 1.0;
                    impact_ramp_delta = impact_altitude_grain * (0.3 / (0.1 + math.ln((1.0 + math.pow((impact_time/10),2.0)))));
                    impact_allarm_solution = 1.1;
                } else {
                    if (speed_cas < 220 and getprop("fdm/jsbsim/systems/autopilot/gui/speed-value") < 220) {
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",220.0);
                        setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-active",0.0);
                    }
                    if (impact_ramp < 1.0 and impact_altitude_direction_der_frist > 20.0) impact_ramp = 1.0;
                    impact_ramp_delta = impact_altitude_grain * (0.3 / (0.1 + math.ln((1.0 + math.pow((impact_time/10),3.0)))));
                    impact_allarm_solution = 1.2;
                }
                if (impact_time_delta > 0.05) {
                    impact_ramp = impact_ramp + 1.0 * impact_ramp_delta / (0.5 * impact_medium_time_gui);
                } else if (impact_time_delta < -0.02) {
                    impact_ramp = impact_ramp - 1.0 * impact_ramp_delta / (0.5 * impact_medium_time_gui);
                }
                if (impact_ramp > impact_ramp_max) impact_ramp = impact_ramp_max;
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",impact_ramp);
                impact_altitude_hold_inserted_delay = impact_altitude_hold_inserted_delay_max;
                if (impact_vertical_speed_max_fpm >= 0) {
                    impact_vertical_speed_fpm = 0.0;
                    setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",impact_vertical_speed_max_fpm);
                    impact_vertical_speed_max_fpm = -100000.0;
                }
                # Debug
                print(sprintf("## Impact CTRL: %.1f",impact_allarm_solution)," (",impact_altitude_hold,")",sprintf(" IR: %.2f",impact_ramp),sprintf(" IR Delta: %.2f",impact_ramp_delta),sprintf(" impact_time: %.2f",impact_time),sprintf(" | %.2f",impact_time_dif_0_10),sprintf(" | %.2f",impact_time_delta),sprintf(" IAG: %.2f",impact_altitude_grain),sprintf(" IAD: %.2f",impact_altitude_direction_der_frist),sprintf(" A: %.2f",impact_time / impact_altitude_grain),sprintf(" B: %.2f",impact_medium_time_gui)," alt:",math.round(end.alt() * M2FT)," alt delta: ",math.round(altitude_delta),sprintf(" Sec: %.0f",impact_is_in_security_zone),sprintf(" ImpZ: %.0f",impact_min_z_ft));
            } else if (impact_control_active == 1) {
                # If is altitude_hold_inserted is True is necessary verify is convenient violate the rule
                # Is work only impact_control_active == 1, the type 2 no.
                if (impact_is_in_security_zone) {
                    if (impact_altitude_hold_inserted_delay == 1) {
                        impact_altitude_hold = 1;
                        if (impact_vertical_speed_max_fpm <= -100000.0) {
                            impact_vertical_speed_max_fpm = getprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm");
                            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
                            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",0);
                            impact_vertical_speed_fpm = getprop("fdm/jsbsim/systems/autopilot/v-up-fpm-lag");
                        }
                        if (impact_vertical_speed_fpm < impact_vertical_speed_max_fpm) {
                            impact_vertical_speed_fpm = impact_vertical_speed_fpm + 100;
                            setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",impact_vertical_speed_fpm);
                        } else {
                            impact_vertical_speed_fpm = impact_vertical_speed_fpm - 100;
                            setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",impact_vertical_speed_fpm);
                        }
                    } else {
                        if (impact_altitude_hold_inserted_delay > 1) impact_altitude_hold_inserted_delay = impact_altitude_hold_inserted_delay - 1;
                    }
                } else {
                    impact_altitude_hold = 0;
                    impact_vertical_speed_fpm = 0.0;
                    if (impact_altitude_hold_inserted_delay > 1) impact_altitude_hold_inserted_delay = impact_altitude_hold_inserted_delay - 1;
                }
                var alpha = 0.0;
                if (impact_altitude_hold == 0) {
                    if (altitude_delta > impact_min_z_ft) {
                        alpha = (impact_min_z_ft - altitude_delta) / speed_fps;
                        impact_ramp_delta = (alpha * 10 / impact_medium_time_gui) / impact_altitude_hold_inserted_delay;
                        impact_allarm_solution = 2.1;
                    } else {
                        alpha = (impact_min_z_ft - altitude_delta) / speed_fps;
                        impact_ramp_delta = (alpha * 30 / impact_medium_time_gui) / impact_altitude_hold_inserted_delay;
                        impact_allarm_solution = 2.2;
                    }
                    impact_ramp = impact_ramp_delta;
                    if (impact_ramp < impact_ramp_min) impact_ramp = impact_ramp_min;
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",impact_ramp);
                    if (impact_vertical_speed_max_fpm >= 0) {
                        impact_vertical_speed_fpm = 0.0;
                        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",impact_vertical_speed_max_fpm);
                        impact_vertical_speed_max_fpm = -100000.0;
                    }
                }
                # Debug
                print(sprintf("## Impact CTRL: %.1f",impact_allarm_solution)," (",impact_altitude_hold,")",sprintf(" IR: %.2f",impact_ramp),sprintf(" IR Delta: %.2f",impact_ramp_delta),sprintf(" impact_time: %.2f",impact_time),sprintf(" | %.2f",impact_time_dif_0_10),sprintf(" IAG: %.2f",impact_altitude_grain),sprintf(" IAD: %.2f",impact_altitude_direction_der_frist),sprintf(" A: %.2f",impact_time / impact_altitude_grain),sprintf(" B: %.2f",impact_medium_time_gui)," alt:",math.round(end.alt() * M2FT)," alt delta: ",math.round(altitude_delta),sprintf(" alpha: %.2f",alpha),sprintf(" VVSp: %.2f",impact_vertical_speed_fpm),sprintf(" VVSpMx: %.1f",impact_vertical_speed_max_fpm),sprintf(" D: %.1f",impact_altitude_hold_inserted_delay),sprintf(" Sec: %.0f",impact_is_in_security_zone),sprintf(" ImpZ: %.0f",impact_min_z_ft));
            } else {
                impact_allarm_solution = 3.0;
                if (impact_control_active == 1) {
                    print(sprintf("## Impact CTRL: %.1f",impact_allarm_solution));
                }
            }
        } else {
            if (impact_control_active > 0 and geod == nil) {
                print("## Impact CTRL: ERROR no data GEO (geod is nill)");
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-geo-is-nil","No data GEO");
            }
        }
    } else {
        impact_factor_ramp_integral = 1.0;
        impact_factor_ramp_old = 0.0;
        impact_altitude_grain_media_pivot = 0;
        impact_altitude_prec_ft = -100000.0;
        impact_altitude_hold_inserted_delay = impact_altitude_hold_inserted_delay_max;
        impact_vertical_speed_fpm = 0.0;
        if (impact_vertical_speed_max_fpm >= 0) {
            setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",impact_vertical_speed_max_fpm);
            impact_vertical_speed_max_fpm = -100000.0;
        }
    }
    
    setprop("fdm/jsbsim/systems/autopilot/gui/landig-status-id",landig_status_id);
    
});

pilot_assistant.start();


