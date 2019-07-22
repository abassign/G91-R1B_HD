# http://wiki.flightgear.org/Nasal_library#Positioned_Object_Queries
# http://wiki.flightgear.org/Nasal_library#findAirportsWithinRange.28.29

var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_name", "", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_id", "", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_id", "", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_landing_status", "Autolanding inactive", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_landing_status_id", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_distance", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_delta_altitude", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope", 0, "DOUBLE");

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
var isHolding_reducing_distance_rel = 0.0;
var airplane_to_holding_point_alt = 0.0;

var apt_coord = geo.Coord.new();
var rwy_coord_start = geo.Coord.new();
var rwy_coord_end = geo.Coord.new();
var rwy_coord_end_offset = 3000.0;
var heading_target_active = 0.0;
var heading_target = 0.0;

var impact_ramp = 0.0;
var impact_allarm = 0.0;
var impact_dist = 0.0;
var impact_dist_10 = 0.0;
var impact_time = 1.0;
var impact_time_10 = 1.0;
var impact_time_dif_0_10 = 100000.0;
var impact_time_prec = 1.0;
var impact_altitude_hold_inserted_delay_time = 10;
var impact_altitude_hold_inserted_delay = impact_altitude_hold_inserted_delay_time;
var impact_altitude_prec_ft = -100000.0;
var impact_altitude_prec_10_ft = -100000.0;
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


var airport_searcher = maketimer(0.5, func() {

    var slope = 0.0;
    var runway_to_airplane_dist = 0.0;
    
    if (landig_status_id == 1) {
        var landing_rwy_search_distance_max = getprop("fdm/jsbsim/systems/autopilot/gui/landing-rwy-search-distance-max");
        var landing_rwy_search_max_heading = getprop("fdm/jsbsim/systems/autopilot/gui/landing-rwy-search-max-heading");
        var landing_minimal_length_m = getprop("fdm/jsbsim/systems/autopilot/gui/landing-minimal-length-m");
        var landing_max_lateral_wind = getprop("fdm/jsbsim/systems/autopilot/gui/landing-max-lateral-wind");
        var apts = findAirportsWithinRange(landing_rwy_search_distance_max);
        var distance_to_airport_min = 9999.0;
        var airplane = geo.aircraft_position();
        var heading_true_deg = getprop("fdm/jsbsim/systems/autopilot/heading-true-deg");
        var wind_speed = getprop("/local-weather/METAR/windspeed-kt");
        var wind_from = getprop("/local-weather/METAR/wind-direction-deg");
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
                        print("Airport: ",airport.id,
                            " ",airport.runways[rwy].id,
                            " ",airport.runways[rwy].length,
                            " Wind speed: ",wind_speed, " Wind direction: ",wind_from, "Wind deviation: ",wind_deviation, " compatibility: ",wind_compatibility_ok,
                            " Lat wind: ", wind_speed * (1 - math.cos(wind_deviation * d2r)));
                        # Select the sufficient runway lenght
                        if (airport.runways[rwy].length >= landing_minimal_length_m and wind_compatibility_ok) {
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
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",getprop("fdm/jsbsim/systems/autopilot/heading-true-deg"));
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/heading-control",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/wing-leveler",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/phi-heading",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",30.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/rudder-auto-coordination",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-active",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",3000.0);
                setprop("fdm/jsbsim/systems/autopilot/phase-landing",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-control",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-flap",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-throttle",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-pitch",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",250.0);
                setprop("fdm/jsbsim/systems/autopilot/speed-throttle-imposed",-1.0);
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
        ## print("Autopilot - airport_searcher - Airport found");
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
        # Select and elabotare the landing phase
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
            if (slope < 5) {
                var holding_point_to_airplane_dist_for_slope = holding_point_to_airplane_dist - (holding_point_to_airplane_delta_alt_ft/math.tan(slope / R2D));
            }
            var heading_correction_for_before_dist = math.abs(geo.normdeg180(getprop("fdm/jsbsim/systems/autopilot/heading-true-deg") - airplane.course_to(rwy_coord_start)));
            if (heading_correction_for_before_dist < 90) {
                holding_point_before_distance_nm = 1.8;
            } else {
                holding_point_before_distance_nm = 1.8 * (1 + ((heading_correction_for_before_dist - 90.0) / 90.0));
            }
            if (holding_point_to_airplane_dist > holding_point_before_distance_nm) {
                if (slope > 3.0) {
                    setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-active",1.0);
                } else {
                    setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-active",0.0);
                }
                if (holding_point_to_airplane_dist_for_slope < holding_point_to_airplane_dist * 0.1) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",holding_point_h_ft + runway_alt_m_select * 3.28084);
                } else {
                    if (airplane_to_holding_point_alt < (runway_alt_m_select * 3.28084 + holding_point_h_ft)) {
                        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",runway_alt_m_select * 3.28084 + holding_point_h_ft); 
                    } else {
                        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",airplane_to_holding_point_alt);
                    }
                }
                heading_correct = airplane.course_to(holding_point);
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
                print(" 2.0 > ", holding_point_to_airplane_dist_direct, " ", holding_point_to_airplane_delta_alt_ft, " ",heading_correct," ",slope," : ",heading_correction_for_before_dist," ",holding_point_before_distance_nm);
            } else {
                landig_status_id = 2.1;
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",45.0);
                setprop("fdm/jsbsim/systems/autopilot/phase-landing",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",180.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",1.0);
                isHolding_reducing_delta = 0;
                isHolding_reducing_heading = nil;
            }
        } else if (landig_status_id == 2.1) {
            # Fly near the holding point
            runway_to_airplane_dist_direct = airplane.direct_distance_to(rwy_coord_start) * 0.000621371 + rwy_offset_h_nm;
            slope = math.asin(((runway_to_airplane_delta_alt_ft - rwy_offset_v_ft)* 0.000189394) / runway_to_airplane_dist_direct) * R2D;
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope",slope);
            runway_to_airplane_dist = airplane.distance_to(rwy_coord_start) * 0.000621371 + rwy_offset_h_nm;
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_distance",runway_to_airplane_dist);
            var rwy_point_delta_alt_ft = (airplane.alt() - runway_alt_m_select) * 3.28084 + holding_point_h_ft;
            if ((rwy_point_delta_alt_ft > 500.0 and slope > 5.0) or isHolding_reducing_delta > 0) {
                # Set approch point
                # Direct landing
                # holding_point_h_ft ft - 10 nm slope 3-4°
                # Is near the airport verify the delta
                # Is necesary the quote reduction
                if (isHolding_reducing_delta == 0) {
                    isHolding_reducing_delta = 1;
                    setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",2000.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",runway_alt_m_select * 3.28084 + holding_point_h_ft);
                    if (isHolding_reducing_heading == nil) {
                        isHolding_reducing_heading = airplane.course_to(rwy_coord_start);
                    }
                    isHolding_reducing_heading_clipto = isHolding_reducing_heading + 90.0;
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
                        isHolding_reducing_heading_clipto = isHolding_reducing_heading + 180.0;
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
                        isHolding_reducing_heading_clipto = isHolding_reducing_heading + 270.0;
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
                    if (isHolding_reducing_distance_rel > 3.0 or runway_to_airplane_dist <= holding_point_distance_nm)  {
                        # End holding
                        isHolding_reducing_delta = 0;
                    }
                }
            } else {
                landig_status_id = 2.2;
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",30.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",160.0);
                setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-active",1.0);
                setprop("fdm/jsbsim/systems/autopilot/landing-gear-activate-blocked",1.0);
                setprop("controls/flight/flaps",1.0);
            }
            print(" 2.1 > ",runway_to_airplane_dist, " ", slope, " ", airplane.course_to(rwy_coord_start), " ",isHolding_reducing_delta," Holding: ",heading_correct," ",isHolding_reducing_heading_clipto," ",isHolding_reducing_heading, " Radius: ",math.abs(getprop("fdm/jsbsim/systems/autopilot/turn-radius-nm-lag"))," ",isHolding_reducing_distance_rel);
        } else if (landig_status_id == 2.2) {
            runway_to_airplane_dist_direct = airplane.direct_distance_to(rwy_coord_start) * 0.000621371 + rwy_offset_h_nm;
            if ((airplane.distance_to(rwy_coord_start) * 0.000621371) > 0.4) {
                slope = math.asin(((runway_to_airplane_delta_alt_ft - rwy_offset_v_ft)* 0.000189394) / runway_to_airplane_dist_direct) * R2D;
                heading_correction = geo.normdeg180(airport_select.runways[rwy_select].heading - airplane.course_to(rwy_coord_start));
                var heading_factor = 1.0;
                if (math.abs(heading_correction) < 10) {
                    heading_factor = 10 - math.abs(heading_correction);
                }            
                heading_correct = geo.normdeg180(airport_select.runways[rwy_select].heading - heading_correction * heading_factor);
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
                # Slope correction
                if (slope < 4) {
                    slope = slope + (slope - 4) * 2.5;
                } else if (slope > 4) {
                    slope = slope + (slope - 4) * 1.5;
                }
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",-slope);
                print(" 2.2 > ", runway_to_airplane_dist_direct, " ", runway_to_airplane_delta_alt_ft, " ", slope, " Heading cor: ", heading_correct, " (",heading_correction," : ",heading_factor,")");
            } else {
                landig_status_id = 2.5;
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",50.0);
                setprop("fdm/jsbsim/systems/autopilot/steer-brake",1.0);
            }
        } else if (landig_status_id == 2.5) {
            runway_to_airplane_dist_direct = airplane.direct_distance_to(rwy_coord_start) * 0.000621371 + rwy_offset_h_nm;
            if (gear_unit_contact >= 1) {
                landig_status_id = 3.0;
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",-2.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",50.0);
                setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-active",1.0);
            } else {
                var heading_factor = 10.0;
                var rwy_coord_end_to_airplane_dist_direct = airplane.direct_distance_to(rwy_coord_end) * 0.000621371;
                slope = math.asin((runway_to_airplane_delta_alt_ft * 0.000189394) / rwy_coord_end_to_airplane_dist_direct) * R2D;
                var factor_reducing_slope = 4.0;
                altitude_agl_ft = getprop("/position/altitude-agl-ft");
                if (altitude_agl_ft <= 100.0 and altitude_agl_ft > 20) {
                    slope = ((1+math.atan(slope/100.0))*factor_reducing_slope-factor_reducing_slope);
                } else {
                    slope = 2.0;
                }
                heading_correction = geo.normdeg180(airport_select.runways[rwy_select].heading - airplane.course_to(rwy_coord_end));
                if (math.abs(heading_correction > 2)) {
                    heading_factor = 1 + (1 / (heading_correction / 180) / 10.0);
                }    
                heading_correct = airport_select.runways[rwy_select].heading - heading_correction * heading_factor;
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",-slope);
                print(" 2.5 > ", altitude_agl_ft, " ",runway_to_airplane_delta_alt_ft, " ", slope, " Ground: ", gear_unit_contact, " ",heading_correct," (",heading_factor,") ",runway_to_airplane_dist);
            }
        } else if (landig_status_id == 3.0) {
            if (getprop("fdm/jsbsim/systems/autopilot/speed-true-on-air") < 50.0) {
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
                var heading_factor = 20.0;
                heading_correction = geo.normdeg180(airport_select.runways[rwy_select].heading - airplane.course_to(rwy_coord_end));
                if (math.abs(heading_correction > 1)) {
                    heading_factor = 1 + (1 / (heading_correction / 180) / 10.0);
                }    
                heading_correct = airport_select.runways[rwy_select].heading - heading_correction * heading_factor * 2;
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
            setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1000.0);
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
    
    # Impact control
    
    if (getprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active") and (getprop("velocities/speed-east-fps") != 0 or getprop("velocities/speed-north-fps") != 0)) {
        var impact_medium_time_gui = getprop("fdm/jsbsim/systems/autopilot/gui/impact-medium-time");
        var impact_ramp_min = -(21 - impact_medium_time_gui);
        var impact_ramp_max = 24.0;
        var impact_min_z_ft = getprop("fdm/jsbsim/systems/autopilot/gui/impact-min-z-ft") * impact_altitude_grain;
        var impact_time_delta = 0.0;
        var altitude_hold = getprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold");
        var altitude_hold_inserted = altitude_hold;
        var altitude_hold_inserted_ft = getprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft");
        var altitude_actual = getprop("fdm/jsbsim/systems/autopilot/h-sl-ft-lag");
        var start = geo.aircraft_position();
        var speed_east_fps  = getprop("velocities/speed-east-fps");
        var speed_north_fps = getprop("velocities/speed-north-fps");
        var speed_horz_fps  = math.sqrt((speed_east_fps*speed_east_fps)+(speed_north_fps*speed_north_fps));
        var speed_down_fps  = getprop("velocities/speed-down-fps") + speed_horz_fps * math.tan(impact_ramp / R2D);
        var speed_down_10_fps  = getprop("velocities/speed-down-fps") + speed_horz_fps * math.tan((impact_ramp - 30.0) / R2D);
        var speed_fps       = math.sqrt((speed_horz_fps*speed_horz_fps)+(speed_down_fps*speed_down_fps));
        var heading = 0;
        var impact_allarm_solution = 0;
        var impact_ramp_delta = 0.0;
        if (speed_north_fps >= 0) {
            heading -= math.acos(speed_east_fps/speed_horz_fps)*R2D - 90;
        } else {
            heading -= -math.acos(speed_east_fps/speed_horz_fps)*R2D - 90;
        }
        heading = geo.normdeg(heading);

        var end = geo.Coord.new(start);
        end.apply_course_distance(heading, speed_horz_fps*FT2M);
        end.set_alt(end.alt() - (impact_min_z_ft * FT2M) - speed_down_fps*FT2M);
        var end_10 = geo.Coord.new(start);
        end_10.apply_course_distance(heading, speed_horz_fps*FT2M);
        end_10.set_alt(end_10.alt() - (impact_min_z_ft * FT2M) - speed_down_10_fps*FT2M);
        
        var dir_x = end.x()-start.x();
        var dir_y = end.y()-start.y();
        var dir_z = end.z()-start.z();
        var dir_10_z = end_10.z()-start.z();
        var xyz = {"x":start.x(),  "y":start.y(),  "z":start.z()};
        var dir = {"x":dir_x,      "y":dir_y,      "z":dir_z};
        var dir_10 = {"x":dir_x,      "y":dir_y,      "z":dir_10_z};

        var geod = get_cart_ground_intersection(xyz, dir);
        var geod_10 = get_cart_ground_intersection(xyz, dir_10);
        
        if (geod != nil and speed_fps > 1.0) {
            end.set_latlon(geod.lat, geod.lon, geod.elevation);
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
                impact_altitude_prec_10_ft = impact_altitude_prec_ft;
            }
            impact_altitude_grain_media[impact_altitude_grain_media_pivot] = (end.alt() * M2FT ) - impact_altitude_prec_ft;
            impact_altitude_grain_media_pivot = impact_altitude_grain_media_pivot + 1;
            if (impact_altitude_grain_media_pivot >= impact_altitude_grain_media_size) {
                impact_altitude_grain_media_pivot = 0;
            }
            impact_altitude_grain = 0.0;
            impact_altitude_direction_der_frist = 0.0;
            for (var i=0; i < impact_altitude_grain_media_size; i = i+1) {
                impact_altitude_grain = impact_altitude_grain + abs(impact_altitude_grain_media[i]);
                impact_altitude_direction_der_frist = impact_altitude_direction_der_frist + impact_altitude_grain_media[i];
            }
            impact_altitude_grain = impact_altitude_grain / impact_altitude_grain_media_size;
            impact_altitude_direction_der_frist = impact_altitude_direction_der_frist / impact_altitude_grain_media_size;
            if (impact_altitude_grain <= 1.0) {
                impact_altitude_grain = 1.0;
            } else {
                impact_altitude_grain = 1.0 * (1 + math.ln(impact_altitude_grain));
            }
            impact_altitude_prec_ft = end.alt() * M2FT;
            # calculate the impact_medium_time
            var impact_time_delta = impact_time_prec - impact_time;
            impact_time_prec = impact_time;
            if (impact_time  < 5.0) {
                altitude_hold_inserted = 0;
                impact_altitude_hold_inserted_delay = impact_altitude_hold_inserted_delay_time;
            } else {
                if (altitude_hold_inserted) {
                    if ((altitude_hold_inserted_ft + impact_min_z_ft) < (end.alt() * M2FT)) {
                        altitude_hold_inserted = 0;
                        impact_altitude_hold_inserted_delay = impact_altitude_hold_inserted_delay_time;
                    } else {
                        impact_altitude_hold_inserted_delay = impact_altitude_hold_inserted_delay - 1;
                        if (impact_altitude_hold_inserted_delay <= 0) {
                            altitude_hold_inserted = 1;
                        } else {
                            altitude_hold_inserted = 0;
                        }
                    }
                } else {
                    impact_altitude_hold_inserted_delay = impact_altitude_hold_inserted_delay_time;
                }
            }
        } else {
            impact_dist = 0.0;
            impact_time = -1.0;
        }
        
        setprop("fdm/jsbsim/systems/autopilot/impact-dist",impact_dist);
        setprop("fdm/jsbsim/systems/autopilot/impact-time",impact_time);
        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",0.0);
        
        var altitude_delta = altitude_actual - (end.alt() * M2FT);

        if (((impact_time / impact_altitude_grain) < 0.6 and (impact_altitude_direction_der_frist > 2.0)) 
        or (impact_altitude_direction_der_frist > 10.0) 
        or ((abs(impact_time_dif_0_10) < impact_altitude_grain) and (impact_altitude_direction_der_frist > 2.0))) {
            if (impact_time < 5.0 and abs(impact_time_dif_0_10) < 5.0) {
                if (impact_ramp < 1.0) impact_ramp = 1.0;
                impact_ramp_delta = impact_altitude_grain * (0.3 / (0.1 + math.ln((1.0 + math.pow((impact_time/10),2)))));
                impact_allarm_solution = 1.1;
            } else {
                if (impact_ramp < 1.0 and impact_altitude_direction_der_frist > 20.0) impact_ramp = 1.0;
                impact_ramp_delta = impact_altitude_grain * (0.1 / (0.1 + math.ln((1.0 + math.pow((impact_time/10),3)))));
                impact_allarm_solution = 1.2;
            }
            if (impact_time_delta > 0.05) {
                impact_ramp = impact_ramp + impact_ramp_delta / (0.5 * impact_medium_time_gui);
            } else if (impact_time_delta < -0.05) {
                impact_ramp = impact_ramp + 10.0 * (impact_time_delta / impact_medium_time_gui);
            }
            if (impact_ramp > impact_ramp_max) impact_ramp = impact_ramp_max;
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",1.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",impact_ramp);
            # Debug
            print(sprintf("##: %.1f",impact_allarm_solution)," : ",altitude_hold_inserted,sprintf(" IR: %.2f",impact_ramp),sprintf(" IR Delta: %.2f",impact_ramp_delta),sprintf(" impact_time: %.2f",impact_time),sprintf(" | %.2f",impact_time_dif_0_10),sprintf(" IAG: %.2f",impact_altitude_grain),sprintf(" IAD: %.2f",impact_altitude_direction_der_frist),sprintf(" A: %.2f",impact_time / impact_altitude_grain),sprintf(" B: %.2f",impact_medium_time_gui)," alt: ", math.round((end.alt() * M2FT))," alt:",math.round(end.alt() * M2FT)," alt delta: ",math.round(altitude_delta));
        } else {
            var alpha = 0.0;
            if (altitude_delta > impact_min_z_ft) {
                alpha = (altitude_delta - impact_min_z_ft) / speed_fps;
                impact_ramp_delta = alpha * 30 / impact_medium_time_gui;
                impact_allarm_solution = 2.1;
            } else {
                alpha = (altitude_delta - impact_min_z_ft) / speed_fps;
                impact_ramp_delta = alpha * 15 / impact_medium_time_gui;
                impact_allarm_solution = 2.2;
            }
            impact_ramp = - impact_ramp_delta;
            if (impact_ramp < impact_ramp_min) impact_ramp = impact_ramp_min;
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",1.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",impact_ramp);
            # Debug
            print(sprintf("##: %.1f",impact_allarm_solution)," : ",altitude_hold_inserted,sprintf(" IR: %.2f",impact_ramp),sprintf(" IR Delta: %.2f",impact_ramp_delta),sprintf(" impact_time: %.2f",impact_time),sprintf(" | %.2f",impact_time_dif_0_10),sprintf(" IAG: %.2f",impact_altitude_grain),sprintf(" IAD: %.2f",impact_altitude_direction_der_frist),sprintf(" A: %.2f",impact_time / impact_altitude_grain),sprintf(" B: %.2f",impact_medium_time_gui)," alt: ", math.round((end.alt() * M2FT))," alt:",math.round(end.alt() * M2FT)," alt delta: ",math.round(altitude_delta)," alpha: ",alpha);
        }
    } else {
        impact_factor_ramp_integral = 1.0;
        impact_factor_ramp_old = 0.0;
        impact_altitude_grain_media_pivot = 0;
        impact_altitude_prec_ft = -100000.0
    }

});

airport_searcher.start();


