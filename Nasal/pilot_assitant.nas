# http://wiki.flightgear.org/Nasal_library#Positioned_Object_Queries
# http://wiki.flightgear.org/Nasal_library#findAirportsWithinRange.28.29

var timeStep = 1.0;
var timeStepDivisor = 1.0;
var delayCycleGeneral = 0;

var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_name", "", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_id", "", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_id", "", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-scan-airport", 1, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_name_direct","","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_name_direct_old","","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/status",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rws","", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw_select",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw_airport_select","", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct_max_distance",900,"DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_name_direct_extended","", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_nearest_runway", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_landing_status", "Autolanding inactive", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_landing_status_id", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/take-off-status", "Take off inactive", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/take-off-jato-active", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_distance", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_delta_altitude", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-control-geo-is-nil","");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-minimal-length-m", 1000, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/dragchute/active-view", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-dist-nm", 12, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-h-ft", 5000, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-control-active", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-min-z-ft", 200, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-medium-time", 15, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-activate", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landig-status-id", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-rwy-search-max-heading", 60.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-rwy-search-distance-max", 50.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-rwy-h-offset-nm", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-rwy-v-offset-ft", -20.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-short-profile", 1.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-max-lateral-wind", 10.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-holding-altitude-min", 10.0, "DOUBLE");

var d2r = 0.0174533;
var landing_activate_status = 0;
var take_off_activate_status = 0;
var take_off_jato_active = 0.0;
var airport_select = nil;
var rwy_select = nil;

var airport_select_info = 0.0;
var airport_select_id_direct = nil;
var airport_select_id_direct_rw = nil;
var runway_select_rwy = 0.0;
var runway_alt_m_select = 0.0;
var runway_alt_m_complete_select = 0;
var landig_departure_status_id = -1;
var isAirport_and_rw_selected = 0;
var isAirport_airport_id_save = "";
var isAirport_airport_rw_save = "";
var isHolding_reducing_heading = 0.0;
var isHolding_reducing_heading_clipto = 0.0;
var isHolding_reducing_delta = 0;
var isHolding_reducing_distance = 0.0;
var isHolding_reducing_distance_rel = nil;
var isHolding_reducing_distance_rel_stright = nil;
var isHolding_reducing_terminated = 0;
var holding_point_slope_imposed = 0;
var landing_slope_target = 0.0;
var landing_slope_target_integrate = 0.0;
var landing_slope_integrate = 0.0;
var landing_slope_previous_error = 0.0;
var airplane_to_holding_point_alt = 0.0;
var landing_slope_delta = 0.0;
var landing_slope_delta_old = 0.0;
var runway_to_airplane_dist_direct_mem = 0.0;

var apt_coord = geo.Coord.new();
var rwy_coord_start = geo.Coord.new();
var rwy_coord_end = geo.Coord.new();
var rwy_coord_end_offset = 3000.0;
var heading_target_active = 0.0;
var heading_target = 0.0;

var impact_allarm_solution = 0.0;
var impact_allarm_solution_delay = 0;
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
var impact_altitude_grain_media = 1.0;
var impact_altitude_direction_der_frist = 0.0;
var impact_altitude_grain_media = [];
var impact_altitude_grain_media_media = [];
var impact_altitude_grain_media_size = 100;
var impact_altitude_grain_media_media_size = 100;
var impact_altitude_grain_avg = 0.0;
setsize(impact_altitude_grain_media,impact_altitude_grain_media_size);
forindex(var i; impact_altitude_grain_media) impact_altitude_grain_media[i] = 0.0;
setsize(impact_altitude_grain_media_media,impact_altitude_grain_media_media_size);
forindex(var i; impact_altitude_grain_media_media) impact_altitude_grain_media_media[i] = 0.0;
var impact_altitude_grain_media_pivot = 0;
var impact_altitude_grain_media_media_pivot = 0;
var defaultViewInTheEvent = nil;


var pilot_assistant = func {

    if ((landig_departure_status_id >= 2 and landig_departure_status_id < 5) or (landig_departure_status_id >= 10 and landig_departure_status_id < 11)) {
        timeStepDivisor = 10;
    } else {
        if (impact_control_active > 0) {
            timeStepDivisor = 5;
        } else {
            timeStepDivisor = 1;
        }
    }
    pilot_assistantTimer.restart(timeStep / timeStepDivisor);
    
    var slope = 0.0;
    var runway_to_airplane_dist = 0.0;
    
    if (landig_departure_status_id == 1) {
        var landing_rwy_search_distance_max = getprop("fdm/jsbsim/systems/autopilot/gui/landing-rwy-search-distance-max");
        var landing_rwy_search_max_heading = getprop("fdm/jsbsim/systems/autopilot/gui/landing-rwy-search-max-heading");
        var landing_minimal_length_m = getprop("fdm/jsbsim/systems/autopilot/gui/landing-minimal-length-m");
        var landing_max_lateral_wind = getprop("fdm/jsbsim/systems/autopilot/gui/landing-max-lateral-wind");
        var airport_nearest_runway = getprop("fdm/jsbsim/systems/autopilot/gui/airport_nearest_runway");
        var distance_to_airport_min = 9999.0;
        var airplane = geo.aircraft_position();
        var heading_true_deg = getprop("fdm/jsbsim/systems/autopilot/heading-true-deg");
        var wind_speed = getprop("/local-weather/METAR/wind-strength-kt"); print("###1: ", wind_speed);
        var wind_from = getprop("/local-weather/METAR/wind-direction-deg"); print("###2: ", wind_from);
        var rwy_coord = geo.Coord.new();
        var apts = nil;
        
        if (landing_activate_status == 0) {
            if (airport_select_id_direct != nil) {
                apts = [airport_select_id_direct];
                print("## 2 airport_select_id_direct: ",airport_select_id_direct.id);
            } else {
                apts = findAirportsWithinRange(landing_rwy_search_distance_max);
            }
            if (apts != nil and airplane != nil) {
                rwy_select = nil;
                foreach(var apt; apts) {
                    var airport = airportinfo(apt.id);
                    # Select the airport nearest in the frontal direction or direct
                    apt_coord.set_latlon(airport.lat,airport.lon);
                    if (getprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw_select") == 0) {
                        var airport_heading = math.abs(geo.normdeg(heading_true_deg-airplane.course_to(apt_coord)));
                        if (airport_heading <= landing_rwy_search_max_heading
                            or getprop("fdm/jsbsim/systems/autopilot/gui/landing-scan-airport") == 0) {
                            foreach(var rwy; keys(airport.runways)) {
                                if (airport.runways[rwy].length >= landing_minimal_length_m) {
                                    var wind_compatibility_ok = 1;
                                    if (airport_nearest_runway == 0) {
                                        var wind_deviation = math.abs(geo.normdeg(wind_from - airport.runways[rwy].heading));
                                        if (wind_speed * (1 - math.cos(wind_deviation * d2r)) > landing_max_lateral_wind) {
                                            wind_compatibility_ok = 0;
                                        }
                                    }
                                    if (wind_compatibility_ok) {
                                        rwy_coord.set_latlon(airport.runways[rwy].lat,airport.runways[rwy].lon);
                                        runway_to_airplane_dist = airplane.distance_to(rwy_coord) * 0.000621371;
                                        if (distance_to_airport_min > runway_to_airplane_dist) {
                                            distance_to_airport_min = runway_to_airplane_dist;
                                            airport_select = airport;
                                            rwy_select = rwy;
                                        }
                                        print("Landing 1.0 > "
                                            ,apt.id,
                                            ,sprintf(" Dist (nm): %2.1f",runway_to_airplane_dist)
                                            ,sprintf(" H: %2.0f",airport_heading)
                                            ," RW: ",airport.runways[rwy].id
                                            ,sprintf(" L: %4.0f",airport.runways[rwy].length)
                                        );
                                    }
                                }
                            }
                        }
                    }
                }
                if (airport_select != nil and airport_select.id != getprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw_airport_select")) {
                    print("## 4 : ",airport_select.id);
                    var apt_coord = geo.Coord.new();
                    apt_coord.set_latlon(airport_select.lat,airport_select.lon);
                    setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_name_direct",airport_select.id);
                    setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_name_direct_extended",airport_select.name ~ " (" ~ math.round(airplane.distance_to(apt_coord) * 0.000621371) ~ ")");
                    # Create the runway list for manual selection
                    # Cleaning the list
                    setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw_airport_select",airport_select.id);
                    setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw_select",0);
                    var airport_select_id_direct_node = props.globals.getNode("/fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct", 1);
                    var rws_node = airport_select_id_direct_node.getNode("rws", 1);
                    rws_node.removeChildren("value");
                    # Create the Runway list
                    var index = -1;
                    foreach(var rwy; keys(airport_select.runways)) {
                        if (airport_select.runways[rwy].length >= landing_minimal_length_m) {
                            index = index + 1;
                            var wind_compatibility_ok = "W ok";
                            if (airport_nearest_runway == 0) {
                                var wind_deviation = math.abs(geo.normdeg(wind_from - airport_select.runways[rwy].heading));
                                if (wind_speed * (1 - math.cos(wind_deviation * d2r)) > landing_max_lateral_wind) {
                                    wind_compatibility_ok = "---";
                                }
                            }
                            setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rws/value[" ~ index ~ "]",airport_select.runways[rwy].id ~ " " ~ airport_select.runways[rwy].length ~ " " ~ wind_compatibility_ok);
                        }
                    }
                    gui.dialog_update("pilot-assistant");
                } else if (airport_select == nil) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw_airport_select","");
                    var airport_select_id_direct_node = props.globals.getNode("/fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct", 1);
                    var rws_node = airport_select_id_direct_node.getNode("rws", 1);
                    rws_node.removeChildren("value");
                    gui.dialog_update("pilot-assistant");
                    setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_name_direct_extended","-- No Airport --");
                }
                
                # Manual Runway select
                if (airport_select != nil and getprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw_select") == 1) {
                    rwy_select = string.trim(substr(getprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw"),0,3));
                }
            }
        }
     
        if (airport_select != nil and rwy_select != nil and airport_select.runways[rwy_select] != nil and size(rwy_select) <= 3) {
            isAirport_and_rw_selected = 1;
            var landing_rwy_h_offset_nm = - 0.1;
            if (airport_select.runways[rwy_select].length > 1000) {
                landing_rwy_h_offset_nm = - ((2000.0 - airport_select.runways[rwy_select].length) / 10000);
            }
            setprop("fdm/jsbsim/systems/autopilot/gui/landing-rwy-h-offset-nm",landing_rwy_h_offset_nm);
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
                airport_select_id_direct = nil;
                airport_select_id_direct_rw = nil;
                landig_departure_status_id = 2;
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",6.0);
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
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-flap",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-throttle",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-pitch",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                if (getprop("fdm/jsbsim/systems/autopilot/speed-cas-on-air") < 250) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",250.0);
                }
                setprop("fdm/jsbsim/systems/autopilot/speed-throttle-imposed",-1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",2.0);
                setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-close",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",0.0);
                setprop("fdm/jsbsim/systems/airbrake/manual-cmd",0.0);
                rwy_coord_end.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon); 
                rwy_coord_end.apply_course_distance(airport_select.runways[rwy_select].heading,rwy_coord_end_offset);
                airplane_to_holding_point_alt = airplane.alt() * 3.28084;
            } else {
                landig_departure_status_id = 1;
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",1.0);
            }
        } else {
            isAirport_and_rw_selected = 0;
            landing_activate_status = 0;
        }
    }
    
    if (landig_departure_status_id == 1 and landig_departure_status_id < 10 and airport_select == nil) {
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_landing_status","No airport for landing");
    } else if (landig_departure_status_id >= 1 
            and landig_departure_status_id < 10 
            and airport_select != nil 
            and rwy_select != nil 
            and size(rwy_select) <= 3) {
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
        var holding_point_slope_max = holding_point_slope_imposed + 1;
        var holding_point_slope_min = holding_point_slope_imposed - 1;
        var holding_point_slope_avg = (holding_point_slope_max + holding_point_slope_min) / 2;
        #
        # Common eleboration
        #
        rwy_coord_start.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon,rwy_offset_v_ft * 3.28084);
        if (landig_departure_status_id >= 2.0 and landig_departure_status_id < 3.0) {
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
        if (landig_departure_status_id == 2.0) {
            # Fly to the holding point
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",0.0);
            var holding_point = geo.Coord.new();
            holding_point.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon,rwy_offset_v_ft * 3.28084);
            holding_point.apply_course_distance(airport_select.runways[rwy_select].heading + 180.0,holding_point_distance_nm * 1852.0);
            var holding_point_to_airplane_dist = airplane.distance_to(holding_point) * 0.000621371;
            var holding_point_to_airplane_dist_direct = airplane.direct_distance_to(holding_point) * 0.000621371;
            var holding_point_to_airplane_delta_alt_ft = airplane.alt() * 3.28084 - (runway_alt_m_select * 3.28084 + holding_point_h_ft);
            var altitude_min_for_holding_point = runway_alt_m_select * 3.28084 + holding_point_h_ft;
            if (altitude_min_for_holding_point > getprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft")) {
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",3000.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",altitude_min_for_holding_point);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",1.0);
            } else {
                var dist_to_reduce_h = (holding_point_to_airplane_delta_alt_ft * (getprop("fdm/jsbsim/systems/autopilot/speed-true-on-air") * 5280.0 / 60) / 3000.0) / 5280;
                if (holding_point_to_airplane_dist < dist_to_reduce_h) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",3000.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",altitude_min_for_holding_point);
                    setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",180.0);
                }
            }
            if (holding_point_to_airplane_dist < (10.0 * getprop("fdm/jsbsim/systems/autopilot/speed-cas-on-air") / 180.0)) {
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",180.0);
            }
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
                landig_departure_status_id = 2.1;
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",45.0);
                setprop("fdm/jsbsim/systems/autopilot/phase-landing",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",200.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",2.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",0.0);
                setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-deactivate",1.0);
                setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-close",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",0.0);
                setprop("fdm/jsbsim/systems/airbrake/manual-cmd",0.0);
                isHolding_reducing_delta = -20;
                isHolding_reducing_heading = nil;
                isHolding_reducing_distance_rel = nil;
                isHolding_reducing_terminated = 0;
                runway_to_airplane_dist_direct_mem = airplane.direct_distance_to(rwy_coord_start) * 0.000621371 + rwy_offset_h_nm;
            }
        } else if (landig_departure_status_id == 2.1) {
            # Fly near the holding point
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",200.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",1.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",6.0);
            holding_point_h_ft = math.sin(holding_point_slope_avg / R2D) * runway_to_airplane_dist_direct_mem * 6076.12;
            slope = math.asin(((runway_to_airplane_delta_alt_ft - rwy_offset_v_ft)* 0.000189394) / runway_to_airplane_dist_direct_mem) * R2D;
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope",slope);
            runway_to_airplane_dist = airplane.distance_to(rwy_coord_start) * 0.000621371 + rwy_offset_h_nm;
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_distance",runway_to_airplane_dist);
            
            var exit_21 = 0;
            var rwy_point_delta_alt_ft = (airplane.alt() - runway_alt_m_select) * 3.28084 - holding_point_h_ft;
            if (rwy_point_delta_alt_ft < -100) {
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",9.0);
            } else{
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",4.0);
            } 
            if (isHolding_reducing_terminated == 0) {
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",runway_alt_m_select * 3.28084 + holding_point_h_ft);
                if (slope > 4.0) {
                    setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",1.0);
                }
            } else {
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",6.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",0.0);
            }
            if (isHolding_reducing_delta < 0) {
                # Delay
                isHolding_reducing_delta = isHolding_reducing_delta + 1;
            }
            if ((math.abs(slope - holding_point_slope_avg)) < 1.0 and (getprop("fdm/jsbsim/systems/autopilot/speed-cas-on-air") <= 190.0) and isHolding_reducing_terminated == 0) {
                isHolding_reducing_terminated = 1;
                if (getprop("fdm/jsbsim/systems/autopilot/gui/landing-short-profile") > 0.0) {
                    exit_21 = 1;
                } else {
                    setprop("fdm/jsbsim/systems/airbrake/manual-cmd",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",40.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",3000.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",math.round(getprop("fdm/jsbsim/systems/autopilot/h-sl-ft-lag")));
                }
            }
            if ((isHolding_reducing_terminated == 0 or isHolding_reducing_delta >= 0) and exit_21 == 0) {
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
                landig_departure_status_id = 2.2;
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",2.0); ## Verify the correct condition for proximity ostacle (?)
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",40.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-flap",0.0);
                setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-close",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",0.0);
                setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-deactivate",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-brake",1.0);
                setprop("fdm/jsbsim/systems/airbrake/manual-cmd",0.0);
                runway_to_airplane_dist_direct = airplane.direct_distance_to(rwy_coord_start) * 0.000621371 + rwy_offset_h_nm;
                landing_slope_target_integrate = - 3.5;
                landing_slope_integrate = 0.0;
            }
            print("Landing 2.1 >"
            ,sprintf(" Dist (nm): % 6.1f",runway_to_airplane_dist)
            ,sprintf(" Alt (ft): % 6.0f",(runway_to_airplane_delta_alt_ft - rwy_offset_v_ft))
            ,sprintf(" Alt delta (ft): % 5.0f",rwy_point_delta_alt_ft)
            ,sprintf(" Slope: % 6.1f",slope)
            ,sprintf(" holding_point_h_ft (ft): % 6.0f",holding_point_h_ft)
            ,sprintf(" isHolding_reducing_delta: % 3.0f",isHolding_reducing_delta)
            ,sprintf(" is Term: %.0f",isHolding_reducing_terminated));
        } else if (landig_departure_status_id == 2.2) {
            runway_to_airplane_dist_direct = airplane.direct_distance_to(rwy_coord_start) * 0.000621371 + rwy_offset_h_nm;
            var altitude_agl_ft = getprop("/position/altitude-agl-ft");
            # PID controller section
            var kp = getprop("fdm/jsbsim/systems/autopilot/pid-test-kp"); kp = 30.0;
            var ki = getprop("fdm/jsbsim/systems/autopilot/pid-test-ki"); ki = 1.0;
            var kd = getprop("fdm/jsbsim/systems/autopilot/pid-test-kd"); kd = 0.5;
            if (((airplane.distance_to(rwy_coord_start) * 0.000621371) < 0.8 and altitude_agl_ft < 250.0) == 0) {
                if (runway_to_airplane_dist_direct > 10.0) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",1.0);
                }
                if (runway_to_airplane_dist_direct <= 10.0 and runway_to_airplane_dist_direct > 8.0) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-flap",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",1.0);
                }
                if (runway_to_airplane_dist_direct <= 8.0 and runway_to_airplane_dist_direct > 2.0) {

                    setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-open",1.0);
                }
                if (runway_to_airplane_dist_direct <= 2.0) {
                    setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-open",1.0);
                }
                var rwy_coord_start_final = geo.Coord.new();
                rwy_coord_start_final.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon);
                rwy_coord_start_final.apply_course_distance(airport_select.runways[rwy_select].heading - 180,(runway_to_airplane_dist_direct - 3) * 1852.0);
                heading_correction = geo.normdeg180(airport_select.runways[rwy_select].heading - airplane.course_to(rwy_coord_start_final));
                var heading_factor = 0.2;
                if (runway_to_airplane_dist_direct < 12.0) {
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
                # Slope target correction
                var speed_cas = getprop("fdm/jsbsim/systems/autopilot/speed-cas-on-air");
                var cas_max = 180.0;
                var slope_target = - 3.8;
                if (runway_to_airplane_dist_direct > 8.0) {
                    cas_max = 180.0;
                    if (speed_cas > cas_max) {
                        if (landing_slope_target_integrate > -4.3) {
                            landing_slope_target_integrate = landing_slope_target_integrate - (speed_cas - cas_max) / 3000;
                        }
                    } else if (speed_cas < cas_max) {
                        if (landing_slope_target_integrate < -3.3) {
                            landing_slope_target_integrate = landing_slope_target_integrate + (cas_max - speed_cas) / 3000;
                        }
                    }
                } else if (runway_to_airplane_dist_direct > 2.0) {
                    slope_target = - 3.8;
                    cas_max = 160.0;
                    if (speed_cas > cas_max) {
                        if (landing_slope_target_integrate > -4.2) {
                            landing_slope_target_integrate = landing_slope_target_integrate - (speed_cas - cas_max) / 3000;
                        }
                    } else if (speed_cas < cas_max) {
                        if (landing_slope_target_integrate < -3.4) {
                            landing_slope_target_integrate = landing_slope_target_integrate + (cas_max - speed_cas) / 3000;
                        }
                    }
                } else {
                    slope_target = - 3.8;
                    cas_max = 140.0;
                    if (speed_cas > cas_max) {
                        if (landing_slope_target_integrate > -4.0) {
                            landing_slope_target_integrate = landing_slope_target_integrate - (speed_cas - cas_max) / 3000;
                        }
                    } else if (speed_cas < cas_max) {
                        if (landing_slope_target_integrate < -3.6) {
                            landing_slope_target_integrate = landing_slope_target_integrate + (cas_max - speed_cas) / 3000;
                        }
                    }
                }
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",cas_max);
                slope = - math.asin(((runway_to_airplane_delta_alt_ft + rwy_offset_v_ft) * 0.000189394) / runway_to_airplane_dist_direct) * R2D;
                var error = landing_slope_target_integrate - slope;
                landing_slope_integrate = landing_slope_integrate + error * (timeStep / timeStepDivisor);
                var derivate = (error - landing_slope_previous_error) / (timeStep / timeStepDivisor);
                var landing_slope = landing_slope_target_integrate - (kp * error + ki * landing_slope_integrate + kd * derivate);
                landing_slope_previous_error = error;
                # cut funtion
                if (landing_slope > 9.0) {
                    landing_slope = 9.0;
                    landing_slope_integrate = 0.0;
                    if ()
                } else if (landing_slope < -9.0) {
                    landing_slope = -9.0;
                    if (speed_cas < 160.0) {
                        landing_slope =  landing_slope * (1 + (160 - speed_cas) / 40.0);
                    }
                    landing_slope_integrate = 0.0;
                }
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",landing_slope);
                print("Landing 2.2 >"
                ,sprintf(" Dist (nm): % 6.1f",runway_to_airplane_dist_direct)
                ,sprintf(" Delta h (ft): % 5.0f",runway_to_airplane_delta_alt_ft)
                ,sprintf(" Slope: % 7.2f",landing_slope)
                ,sprintf(" (% 7.2f ",landing_slope_target_integrate)
                ,sprintf("% 7.2f ",slope)
                ,sprintf("% 6.2f ",error)
                ,sprintf("% 7.2f ",landing_slope_integrate)
                ,sprintf("% 7.2f ",derivate)
                ,sprintf("% 6.1f ",kp)
                ,sprintf("% 6.1f ",ki)
                ,sprintf("% 6.1f)",kd)
                ,sprintf(" Heading: % 7.1f",heading_correct)
                ,sprintf(" H. cor: % 7.2f",heading_correction)
                ,sprintf(" H. factor: % 6.2f",heading_factor)
                ,sprintf(" LG:% 1.0f",getprop("fdm/jsbsim/systems/autopilot/landing-gear-set-close"))
                ,sprintf(" | % 1.0f",getprop("fdm/jsbsim/systems/autopilot/landing-gear-set-close-blocked"))
                ,sprintf(" | % 1.0f",getprop("fdm/jsbsim/systems/autopilot/landing-gear-set-open"))
                ,sprintf(" | % 1.0f",getprop("fdm/jsbsim/systems/autopilot/landing-gear-set-open-blocked"))
                );
            } else {
                landig_departure_status_id = 2.5;
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",110.0);
                setprop("fdm/jsbsim/systems/autopilot/steer-brake-active",0);
                landing_slope_integrate = 0.0;
            }
        } else if (landig_departure_status_id == 2.5) {
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",1.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",0.0);
            setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-open",1.0);
            setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",1.0);
            runway_to_airplane_dist_direct = airplane.direct_distance_to(rwy_coord_start) * 0.000621371 + rwy_offset_h_nm;
            if (gear_unit_contact >= 1) {
                landig_departure_status_id = 3.0;
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",-3.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",30.0);
                setprop("fdm/jsbsim/systems/autopilot/steer-brake-active",2);
                setprop("fdm/jsbsim/systems/dragchute/activate",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-flap",1.0);
                if (getprop("fdm/jsbsim/systems/autopilot/gui/landing-short-profile") > 0.0) {
                    setprop("fdm/jsbsim/systems/dragchute/activate",1.0);
                }
                
            } else {
                var runway_end_to_airplane_dist_direct = airplane.direct_distance_to(rwy_coord_end) * 0.000621371;
                var slope_target = 2.5;
                slope = getprop("fdm/jsbsim/attitude/theta-deg");
                altitude_agl_ft = getprop("/position/altitude-agl-ft");
                if (altitude_agl_ft <= 300.0 and altitude_agl_ft > 30.0) {
                    slope_target = 2.5 - 7.0 * (altitude_agl_ft / 300.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",100.0);
                } else if (altitude_agl_ft <= 30.0) {
                    slope_target = 4.5 - 2 * (altitude_agl_ft / 30.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",50.0);
                }
                landing_slope_delta = slope - slope_target;
                if (landing_slope_delta > 0.1) {
                    if (landing_slope_delta_old < -0.1) landing_slope_integrate = 0.0;
                    landing_slope_delta = (landing_slope_delta) * 0.25 * math.ln(1.6 + landing_slope_delta);
                    landing_slope_integrate = landing_slope_integrate + landing_slope_delta;
                } else if (landing_slope_delta < -0.1) {
                    if (landing_slope_delta_old > 0.1) landing_slope_integrate = 0.0;
                    landing_slope_delta = (landing_slope_delta) * 0.1 * math.ln(1.2 - landing_slope_delta);
                    landing_slope_integrate = landing_slope_integrate + landing_slope_delta;
                }
                landing_slope_delta_old = landing_slope_delta;
                var speed_cas = getprop("fdm/jsbsim/systems/autopilot/speed-cas-on-air");
                if (landing_slope_integrate < -3.0) landing_slope_integrate = -3.0;
                if (landing_slope_integrate > 4.0) landing_slope_integrate = 4.0;
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg", slope_target + landing_slope_integrate);
                var rwy_coord_start_final = geo.Coord.new();
                rwy_coord_start_final.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon);
                rwy_coord_start_final.apply_course_distance(airport_select.runways[rwy_select].heading - 180,(runway_to_airplane_dist_direct - 3) * 1852.0);
                heading_correction = geo.normdeg180(airport_select.runways[rwy_select].heading - airplane.course_to(rwy_coord_end));
                var heading_factor = 1.0;
                if (math.abs(heading_correction) >= 10) {
                    heading_factor = (18 / runway_end_to_airplane_dist_direct);
                } else {
                    heading_factor = (10 - math.abs(heading_correction)) * (3.0 / runway_end_to_airplane_dist_direct);
                }
                heading_correct = geo.normdeg180(airport_select.runways[rwy_select].heading - heading_correction * heading_factor);
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
                print("Landing 2.5 >"
                ,sprintf(" Dist (nm): %6.1f",runway_to_airplane_dist_direct)
                ,sprintf(" to end (nm): %6.1f",runway_end_to_airplane_dist_direct)
                ,sprintf(" CAS : %3.0f",speed_cas)
                ,sprintf(" Delta h (ft): %5.0f",altitude_agl_ft)
                ,sprintf(" Slope: %7.2f",slope_target + landing_slope_integrate)
                ,sprintf(" (%7.2f|",slope)
                ,sprintf(" %7.2f ",slope_target)
                ,sprintf(" %7.2f ",landing_slope_integrate)
                ,sprintf(" %7.2f)",landing_slope_delta)
                ,sprintf(" Heading: %7.1f",heading_correct)
                ,sprintf(" H. cor: %7.2f",heading_correction)
                ,sprintf(" H. factor: %6.2f",heading_factor)
                ,sprintf(" Gear contact: %.0f",gear_unit_contact));
            }
        } else if (landig_departure_status_id == 3.0) {
            if (getprop("fdm/jsbsim/systems/autopilot/speed-true-on-air") < 35.0) {
                landig_departure_status_id = 4;
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",-5.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",0.0);
                setprop("fdm/jsbsim/systems/autopilot/steer-brake-active",2);
                setprop("fdm/jsbsim/systems/autopilot/speed-throttle-imposed",0.1);
                setprop("fdm/jsbsim/systems/autopilot/handle-brake-activate",1);
                setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-open",1.0);
                defaultViewInTheEvent = nil;
                delayCycleGeneral = 50;
                slope = 0.0;
            } else {
                heading_correction = (airport_select.runways[rwy_select].heading - airplane.course_to(rwy_coord_end));
                var heading_factor = 1 / math.log10(1.05 + math.abs(heading_correction));
                heading_correct = airport_select.runways[rwy_select].heading - heading_correction * heading_factor;
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
                setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-open",1.0);
                # Dragchute camera view
                if (getprop("fdm/jsbsim/systems/dragchute/active-view") > 0.01 and defaultViewInTheEvent == nil) {
                    defaultViewInTheEvent = view.index;
                    view.setView(view.indexof("Dragchute view"));
                }
                print("Landing 3.0 >"
                ,sprintf(" Dist (nm): % 6.1f",runway_to_airplane_dist)
                ,sprintf(" Heading: % 7.1f",heading_correct)
                ,sprintf(" H. cor: % 6.2f",heading_correction)
                ,sprintf(" H. factor: % 6.2f",heading_factor)
                ,sprintf(" Gear contact: %.0f",gear_unit_contact)
                ,sprintf(" Gear brake antiskid: % 6.2f",getprop("fdm/jsbsim/systems/autopilot/steer-brake-antiskid"))
                ,sprintf(" heading norm: % 6.2f",getprop("fdm/jsbsim/systems/autopilot/true-heading-deg-delta-norm"))
                ,sprintf(" (% 6.0f kts)",getprop("fdm/jsbsim/velocities/vtrue-kts"))
                ,sprintf(" left int: % 6.2f",getprop("fdm/jsbsim/systems/brake/left-steer-brake-intensity"))
                ,sprintf(" (% 6.2f)",getprop("fdm/jsbsim/systems/autopilot/left-steer-brake"))
                ,sprintf(" right int: % 6.2f",getprop("fdm/jsbsim/systems/brake/right-steer-brake-intensity"))
                ,sprintf(" (% 6.2f)",getprop("fdm/jsbsim/systems/autopilot/right-steer-brake"))
                ,sprintf(" Dragchute: %.0f",getprop("fdm/jsbsim/systems/dragchute/magnitude"))
                );
            }
        } else if (landig_departure_status_id == 4.0) {
            heading_correction = (airport_select.runways[rwy_select].heading - airplane.course_to(rwy_coord_end)) * 5.0;
            heading_correct = airport_select.runways[rwy_select].heading - heading_correction;
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
            setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",1.0);
            delayCycleGeneral = delayCycleGeneral - 1;
            if (delayCycleGeneral <= 0) landig_departure_status_id = 0;
            print("Landing 4.0 >"
            ,sprintf(" Dist (nm): % 6.1f",runway_to_airplane_dist)
            ,sprintf(" Heading: % 7.1f",heading_correct)
            ,sprintf(" H. cor: % 6.1f",heading_correction)
            ,sprintf(" Gear contact: %.0f",gear_unit_contact)
            ,sprintf(" Gear brake antiskid: % 6.2f",getprop("fdm/jsbsim/systems/autopilot/steer-brake-antiskid"))
            ,sprintf(" heading norm: % 6.2f",getprop("fdm/jsbsim/systems/autopilot/true-heading-deg-delta-norm"))
            ,sprintf(" (% 6.0f kts)",getprop("fdm/jsbsim/velocities/vtrue-kts"))
            ,sprintf(" left int: % 6.2f",getprop("fdm/jsbsim/systems/brake/left-steer-brake-intensity"))
            ,sprintf(" (% 6.2f)",getprop("fdm/jsbsim/systems/autopilot/left-steer-brake"))
            ,sprintf(" right int: % 6.2f",getprop("fdm/jsbsim/systems/brake/right-steer-brake-intensity"))
            ,sprintf(" (% 6.2f)",getprop("fdm/jsbsim/systems/autopilot/right-steer-brake"))
            );
        }
        #
        # Output
        #
        var landing_status = airport_select.id ~ " | " ~ airport_select.name ~ " | " ~ airport_select.runways[rwy_select].id;
        if (landig_departure_status_id == 1) {
            landing_status = "Airport found " ~ landing_status;
        } else if (landig_departure_status_id == 2)  {
            landing_status = "Airport to land " ~ landing_status;
        } else if (landig_departure_status_id == 2.1) {
            landing_status = "Airport approach " ~ landing_status;
        } else if (landig_departure_status_id == 2.2) {
            landing_status = "Airport final " ~ landing_status;
        } else if (landig_departure_status_id == 2.5)  {
            landing_status = "Final landing " ~ landing_status;
        } else if (landig_departure_status_id == 3) {
            landing_status = "Landed " ~ landing_status;
        } else if (landig_departure_status_id == 4) {
            landing_status = "Stopping " ~ landing_status;
        } else {
            landing_status = "Stopped " ~ landing_status;
        }
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_landing_status",landing_status);
    }
    
    # Jato system
    if (take_off_jato_active == 0 and getprop("fdm/jsbsim/systems/autopilot/gui/take-off-jato-active") == 1) {
        setprop("fdm/jsbsim/systems/jato/request-to-mount",4);
        take_off_jato_active = 1;
    } else if (take_off_jato_active == 1 and getprop("fdm/jsbsim/systems/jato/electric-active") == 1) {
        take_off_jato_active = 2;
    } else if (take_off_jato_active >= 2 and take_off_jato_active < 3) {
        take_off_jato_active = take_off_jato_active + (timeStep / 2);
    } else if (take_off_jato_active >= 3 and take_off_jato_active < 4) {
        setprop("fdm/jsbsim/systems/manual-switches/jato/sw-ready-togle",1);
        setprop("fdm/jsbsim/systems/jato/autostart-speed",40);
        setprop("fdm/jsbsim/systems/jato/autostart-ok",1);
        take_off_jato_active = 4;
    } else if (take_off_jato_active == 4) {
        if (getprop("fdm/jsbsim/systems/jato/combustion-off") == 1) {
            take_off_jato_active = 5;
        }
    } else if (take_off_jato_active >= 5 and take_off_jato_active < 6) {
        take_off_jato_active = take_off_jato_active + (timeStep / 3);
    } else if (take_off_jato_active > 6) {
        setprop("fdm/jsbsim/systems/manual-switches/jato/sw-jettinson-togle",1);
        setprop("fdm/jsbsim/systems/jato/reset",1);
        take_off_jato_active = 0;
        setprop("fdm/jsbsim/systems/autopilot/gui/take-off-jato-active",0);
    }
    
    if (landig_departure_status_id >= 10.0 and landig_departure_status_id < 11.0) {
        if (isAirport_and_rw_selected == 1) {
            isAirport_and_rw_selected = -1;
            isAirport_airport_id_save = airport_select;
            isAirport_airport_rw_save = rwy_select;
        }
        var airplane = geo.aircraft_position();
        var heading_correction = 0.0;
        var heading_correct = 0.0;
        var gear_unit_contact = getprop("fdm/jsbsim/systems/landing-gear/on-ground");
        var runway_to_airplane_dist = 0;
        var departure_msg = "";
        # Normal departure procedure
        if (landig_departure_status_id == 10.0) {
            airport_select = nil;
            var heading_true_deg = getprop("fdm/jsbsim/systems/autopilot/heading-true-deg");
            var apts = findAirportsWithinRange(3.0);
            var rwy_coord = geo.Coord.new();
            var distance_to_airport_min = 9999.0;
            if (apts != nil and airplane != nil) {
                foreach(var apt; apts) {
                    var airport = airportinfo(apt.id);
                    # Select the airport in the frontal direction
                    apt_coord.set_latlon(airport.lat,airport.lon);
                    if (math.abs(geo.normdeg180(heading_true_deg-airplane.course_to(apt_coord))) <= 30.0) {
                        foreach(var rwy; keys(airport.runways)) {
                            print("Departure 10.0 > Airport is select: ",airport.id,
                                " ",airport.runways[rwy].id,
                                " ",airport.runways[rwy].length);
                            # Select the runway lenght
                            if (airport.runways[rwy].length >= 1.0) {
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
            } else {
                landig_departure_status_id = -1.0;
            } 
            if (airport_select != nil) {
                landig_departure_status_id = 10.1;
                setprop("fdm/jsbsim/systems/starter/gui/autostart-activate",1);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",1.0);
            } else {
                departure_msg = "Search airport and runway";
                print("Departure 10.0 > Search airport and runway");
            }
        } else if (landig_departure_status_id == 10.1) {
            departure_msg = "Motor and electric starting";
            setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",1.0);
            print("Departure 10.1 > Motor and electric starting phase");
            if (getprop("fdm/jsbsim/systems/starter/gui/autostart-status-is-ok") == 1) {
                landig_departure_status_id = 10.2;
                setprop("fdm/jsbsim/systems/starter/gui/autostart-activate",0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",1.0);
                setprop("/controls/flight/flaps",0.33);
            }
        } else if (landig_departure_status_id == 10.2) {
            departure_msg = "Motor acc. N2:" ~ sprintf(" %3.0f",getprop("/jsbsim/propulsion/engine[0]/n2"));
            print("Departure 10.2 > ", departure_msg);
            setprop("controls/engines/engine/throttle",0.9);
            setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",1.0);
            if (getprop("fdm/jsbsim/propulsion/engine[0]/n2") > 85) {
                landig_departure_status_id = 10.3;
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",3000.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/heading-control",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/wing-leveler",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/phi-heading",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/rudder-auto-coordination",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-active",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",10000.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-control",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-throttle",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-pitch",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",250.0);
                setprop("fdm/jsbsim/systems/autopilot/steer-brake-active",1);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-flap",0.0);
                setprop("fdm/jsbsim/systems/autopilot/handle-brake-release",1);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",1.0);
            }
        } else if (landig_departure_status_id == 10.3) {
            var altitude_agl_ft = getprop("/position/altitude-agl-ft");
            rwy_coord_end.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon); 
            rwy_coord_end.apply_course_distance(airport_select.runways[rwy_select].heading,rwy_coord_end_offset);
            runway_to_airplane_dist = airplane.distance_to(rwy_coord_end) * 0.000621371;
            heading_correction = (airport_select.runways[rwy_select].heading - airplane.course_to(rwy_coord_end));
            var heading_factor = 1 / math.log10(1.05 + math.abs(heading_correction));
            heading_correct = airport_select.runways[rwy_select].heading - heading_correction * heading_factor;
            var speed_cas = getprop("fdm/jsbsim/systems/autopilot/speed-cas-on-air");
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
            setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
            setprop("fdm/jsbsim/systems/autopilot/steer-brake-active",1);
            setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-deactivate",1.0);
            setprop("/controls/flight/flaps",0.33);
            if (getprop("fdm/jsbsim/systems/jato/combustion-on") == 1) {
                var factorGain = getprop("fdm/jsbsim/systems/jato/thrust-lbs-total") / 3000.0;
                setprop("fdm/jsbsim/systems/autopilot/pitch-output-error-coefficient-gain",10.0 * factorGain);
            }
            if (speed_cas < 60) {
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",0.0);
            } else {
                if (speed_cas < 160) {
                    var pitchDeg = 10 - ((160 - speed_cas) / 10.0);
                    if (altitude_agl_ft < 20) {
                        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg", pitchDeg);
                        setprop("fdm/jsbsim/systems/autopilot/pitch-output-error-coefficient-gain",30.0);
                    } else {
                        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg", pitchDeg);
                    }
                }
            }
            if (getprop("fdm/jsbsim/systems/autopilot/gui/take-off-jato-active") == 1 and altitude_agl_ft > 10.0) {
                setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-close",1.0);
            }
            if (altitude_agl_ft > 400.0 and speed_cas > 160) {
                landig_departure_status_id = 10.5;
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",6.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",2000.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",6.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
                setprop("/controls/flight/flaps",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",1.0);
                setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-close",1.0);
            }
            print("Departure 10.3 >"
            ,sprintf(" Dist (nm): %6.1f",runway_to_airplane_dist)
            ,sprintf(" Heading: %7.1f",heading_correct)
            ,sprintf(" cor: %6.1f",heading_correction)
            ,sprintf(" norm: %6.2f",getprop("fdm/jsbsim/systems/autopilot/true-heading-deg-delta-norm"))
            ,sprintf(" Gear cnt: %.0f",gear_unit_contact)
            ,sprintf(" ABS: %6.2f",getprop("fdm/jsbsim/systems/autopilot/steer-brake-antiskid"))
            ,sprintf(" (%6.0f kts)",getprop("fdm/jsbsim/velocities/vtrue-kts"))
            ,sprintf(" left int: %6.2f",getprop("fdm/jsbsim/systems/brake/left-steer-brake-intensity"))
            ,sprintf(" (%6.2f)",getprop("fdm/jsbsim/systems/autopilot/left-steer-brake"))
            ,sprintf(" right int: %6.2f",getprop("fdm/jsbsim/systems/brake/right-steer-brake-intensity"))
            ,sprintf(" (%6.2f)",getprop("fdm/jsbsim/systems/autopilot/right-steer-brake"))
            ,sprintf(" Alt agl: %4.0f",altitude_agl_ft)
            ,sprintf(" Pitch: %3.1f",getprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg"))
            ,sprintf(" Er: %1.2f",getprop("fdm/jsbsim/systems/autopilot/pitch-rad-error"))
            ,sprintf(" | %2.0f",getprop("fdm/jsbsim/systems/autopilot/pitch-reset-integrator"))
            ,sprintf(" | %1.2f",getprop("fdm/jsbsim/systems/autopilot/pitch-error"))
            );
        } else if (landig_departure_status_id == 10.5) {
            var altitude_agl_ft = getprop("/position/altitude-agl-ft");
            if (altitude_agl_ft > 200 and getprop("fdm/jsbsim/systems/autopilot/speed-cas-on-air-lag") > 185) {
                if (getprop("fdm/jsbsim/systems/autopilot/gui/take-off-altitude-top-active") > 0) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",getprop("fdm/jsbsim/systems/autopilot/gui/take-off-altitude-top"));
                    setprop("fdm/jsbsim/systems/autopilot/gui/take-off-altitude-top-active",0.0);
                }
                if (getprop("fdm/jsbsim/systems/autopilot/gui/take-off-to-heading-active") > 0) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/true-heading",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",getprop("fdm/jsbsim/systems/autopilot/gui/take-off-to-heading"));
                    setprop("fdm/jsbsim/systems/autopilot/gui/take-off-to-heading-active",0.0);
                }
                if (getprop("fdm/jsbsim/systems/autopilot/gui/take-off-cruise-speed-active") > 0) {
                    if (getprop("fdm/jsbsim/systems/autopilot/gui/take-off-cruise-speed") <= 1 and getprop("fdm/jsbsim/systems/autopilot/gui/take-off-cruise-speed") > 0.0) {
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",1.0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",0.0);
                    } else {
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                    }
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-control",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-throttle",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-pitch",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",getprop("fdm/jsbsim/systems/autopilot/gui/take-off-cruise-speed"));
                    setprop("fdm/jsbsim/systems/autopilot/gui/take-off-cruise-speed-active",0.0);
                }
                if (isAirport_and_rw_selected == -1) {
                    airport_select = isAirport_airport_id_save;
                    rwy_select = isAirport_airport_rw_save;
                    landig_departure_status_id = 1.0;
                    landing_activate_status = 1;
                    setprop("fdm/jsbsim/systems/autopilot/gui/landing-scan-airport",0);
                    print("#### 10.5> ",airport_select.id," ",rwy_select);
                } else {
                    landig_departure_status_id = -1.0;
                }
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",1.0);
            }
        }
        #
        # Output
        #
        var take_off_status = "";
        if (landig_departure_status_id >= 10.1) {
            take_off_status = airport_select.id ~ " | " ~ airport_select.runways[rwy_select].id ~ " | " ~ departure_msg;
        }
        if (landig_departure_status_id == 10) {
            take_off_status = "Airport not found";
        } else if (landig_departure_status_id == 10.1)  {
            take_off_status = "Find airport " ~ take_off_status;
        } else if (landig_departure_status_id == 10.2)  {
            take_off_status = "Start from airport " ~ take_off_status;
        } else if (landig_departure_status_id == 10.3)  {
            take_off_status = "Leave airport " ~ take_off_status;
        } else if (landig_departure_status_id == 10.5) {
            take_off_status = "Take off completed";
        } else {
            take_off_status = "Take off inactive";
        }
        setprop("fdm/jsbsim/systems/autopilot/gui/take-off-status",take_off_status);
    }
    
    if (landig_departure_status_id == 0) {
        # Stop the landing-departure phase
        landig_departure_status_id = -1;
        airport_select = nil;
        airport_select_id_direct = nil;
        # Reset the landing data
        setprop("fdm/jsbsim/systems/autopilot/gui/heading-control",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/wing-leveler",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-active",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",math.round(getprop("fdm/jsbsim/systems/autopilot/h-sl-ft-lag")));
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
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-brake",0.0);
        setprop("fdm/jsbsim/systems/autopilot/speed-throttle-imposed",-1.0);
        setprop("fdm/jsbsim/systems/autopilot/phase-landing",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",1.0);
        setprop("fdm/jsbsim/systems/autopilot/steer-brake-active",0);
        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",3000.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",6.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id","");
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_name","");
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_id","");
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_distance",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_delta_altitude",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_landing_status","Autolanding inactive");
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/status",0);
        setprop("fdm/jsbsim/systems/autopilot/gui/take-off-jato-active",0);
    }
    
    #
    # Impact control
    #
    
    impact_control_active = getprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active");
    if (impact_control_active > 0.0 and (getprop("velocities/speed-east-fps") != 0 or getprop("velocities/speed-north-fps") != 0)) {
        var timeCoefficient = math.round(0.5 + timeStepDivisor / 2.0);
        var impact_medium_time_gui = getprop("fdm/jsbsim/systems/autopilot/gui/impact-medium-time");
        var impact_ramp_min = - (21 - impact_medium_time_gui);
        impact_altitude_grain_media_size = math.round(0.5 + impact_medium_time_gui / timeCoefficient);
        impact_altitude_grain_media_media_size = math.round(0.5 + 3 * impact_medium_time_gui / timeCoefficient);
        if (impact_altitude_grain_media_size < 5) impact_altitude_grain_media_size = 5;
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
        var speed_horz_fps = math.sqrt((speed_east_fps*speed_east_fps)+(speed_north_fps * speed_north_fps));
        var speed_down_fps = getprop("velocities/speed-down-fps") + speed_horz_fps * math.tan(impact_ramp / R2D);
        var speed_down_10_fps = getprop("velocities/speed-down-fps") + speed_horz_fps * math.tan((impact_ramp - 30.0) / R2D);
        var speed_fps = math.sqrt((speed_horz_fps*speed_horz_fps) + (speed_down_fps*speed_down_fps));
        var heading = 0;
        var impact_ramp_delta = 0.0;
        var impact_ramp_max = 12.0 * (speed_cas / 160.0);
        var future_time = 1 + (speed_cas / 120.0);
        var end_alt = 0.0;
        var end_future_alt =0.0;
        var descent_angle_deg_offset = 1.0;
        
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

        if (geod != nil and speed_fps > 1.0) {
            end.set_latlon(geod.lat, geod.lon, geod.elevation);
            if (geod_future != nil) end_future.set_latlon(geod_future.lat, geod_future.lon, geod_future.elevation);
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
            if (geod_future != nil) {
                if (impact_altitude_future_prec_ft <= -100000.0) {
                    impact_altitude_future_prec_ft = (end_future.alt() * M2FT);
                }
            }
            if (geod_future != nil) {
                impact_altitude_grain_media[impact_altitude_grain_media_pivot] = (((end.alt() * M2FT ) - impact_altitude_prec_ft) + ((end_future.alt() * M2FT ) - impact_altitude_future_prec_ft)) / 2;
            } else {
                impact_altitude_grain_media[impact_altitude_grain_media_pivot] = ((end.alt() * M2FT ) - impact_altitude_prec_ft);
            }
            impact_altitude_grain_media_pivot = impact_altitude_grain_media_pivot + 1;
            if (impact_altitude_grain_media_pivot > impact_altitude_grain_media_size) {
                impact_altitude_grain_media_pivot = 0;
            }
            impact_altitude_grain = 0.0;
            impact_altitude_direction_der_frist = 0.0;
            for (var i=0; i < impact_altitude_grain_media_size; i = i+1) {
                impact_altitude_grain = impact_altitude_grain + abs(impact_altitude_grain_media[i]);
                impact_altitude_direction_der_frist = impact_altitude_direction_der_frist + impact_altitude_grain_media[i];
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
                impact_altitude_grain = 1.0 * (1 + math.log10(impact_altitude_grain));
            }
            impact_altitude_grain_media_media_pivot = impact_altitude_grain_media_media_pivot + 1;
            if (impact_altitude_grain_media_media_pivot > impact_altitude_grain_media_media_size) {
                impact_altitude_grain_media_media_pivot = 0;
            }
            impact_altitude_grain_media_media[impact_altitude_grain_media_media_pivot] = impact_altitude_grain;
            impact_altitude_grain_avg = 0.0;
            for (var i=0; i < (impact_altitude_grain_media_media_size); i = i+1) {
                impact_altitude_grain_avg = impact_altitude_grain_avg + abs(impact_altitude_grain_media_media[i]);
            }
            impact_altitude_grain_avg = impact_altitude_grain_avg / impact_altitude_grain_media_media_size;
            impact_altitude_prec_ft = end.alt() * M2FT;
            if (geod_future != nil) {
                impact_altitude_future_prec_ft = end_future.alt() * M2FT;
            }
            descent_angle_deg_offset = (impact_altitude_grain_avg * 1.0 - 0.5);
            # calculate the impact_medium_time
            impact_time_delta = impact_time_prec - impact_time;
            impact_time_prec = impact_time;
        } else {
            impact_dist = 0.0;
            impact_time = -1.0;
        }
        
        setprop("fdm/jsbsim/systems/autopilot/impact-dist",impact_dist);
        setprop("fdm/jsbsim/systems/autopilot/impact-time",impact_time);

        var altitude_delta = altitude_actual - (end.alt() * M2FT);
        impact_is_in_security_zone = (altitude_hold_inserted == 1)
            and (altitude_hold_inserted_ft > (end.alt() * M2FT + ( 2.0 * impact_min_z_ft)))
            and (altitude_actual > (end.alt() * M2FT));
        
        if (impact_control_active > 0 and geod != nil) {
            if ((impact_allarm_solution_delay > 0) 
                or (((impact_time < 5.0) and (impact_time_dif_0_10 > -0.25) and (impact_is_in_security_zone == 0 or (impact_is_in_security_zone == 1 and impact_time_dif_0_10 < 1.0)))
                    and ((((impact_time / impact_altitude_grain) < 0.8) and math.abs(impact_altitude_direction_der_frist) > 1) or (impact_altitude_direction_der_frist > 5.0)))) {
                if (((impact_time < 3.0) and (abs(impact_time_dif_0_10) < 4.0))
                    or ((impact_time < 5.0) and (abs(impact_time_dif_0_10) < 0.5))) {
                    if (speed_cas < 270 and getprop("fdm/jsbsim/systems/autopilot/gui/speed-value") < 270) {
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",270.0);
                    }
                    if (impact_ramp < 1.0) impact_ramp = 1.0;
                    impact_ramp_delta = impact_altitude_grain * (0.5 / (0.1 + math.ln((1.0 + math.pow((impact_time/10),2.0))))) / timeCoefficient;
                    if (impact_allarm_solution != 1.1) impact_allarm_solution_delay = 2 + impact_altitude_grain_avg;
                    impact_allarm_solution = 1.1;
                    impact_allarm_solution_delay = impact_allarm_solution_delay - 1;
                    setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-deactivate",1);
                } else {
                    if (speed_cas < 220 and getprop("fdm/jsbsim/systems/autopilot/gui/speed-value") < 220) {
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",220.0);
                    }
                    if (impact_ramp < 1.0 and impact_altitude_direction_der_frist > 20.0) impact_ramp = 1.0;
                    impact_ramp_delta = 0.5 + impact_altitude_grain * (0.5 / (0.1 + math.ln((1.0 + math.pow((impact_time/10),3.0))))) / timeCoefficient;
                    if (impact_allarm_solution != 1.2) impact_allarm_solution_delay = 2 + impact_altitude_grain_avg;
                    impact_allarm_solution = 1.2;
                    impact_allarm_solution_delay = impact_allarm_solution_delay - 1;
                    setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-deactivate",1);
                }
                if (impact_time_delta > 0.05) {
                    impact_ramp = impact_ramp + (impact_altitude_grain_avg * 0.15) * impact_ramp_delta / impact_medium_time_gui;
                } else if (impact_time_delta < -0.02 and math.abs(impact_time_dif_0_10) > 0.2) {
                    impact_ramp = impact_ramp - (impact_altitude_grain_avg * 0.1) * impact_ramp_delta / impact_medium_time_gui;
                }
                if (impact_ramp > impact_ramp_max) impact_ramp = impact_ramp_max;
                if (impact_ramp < 0) descent_angle_deg_offset = descent_angle_deg_offset * -0.5;
                impact_ramp = impact_ramp + descent_angle_deg_offset;
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",0.0);
                setprop("fdm/jsbsim/systems/autopilot/altitude-hold-suspended",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",impact_ramp);
                impact_altitude_hold_inserted_delay = impact_altitude_hold_inserted_delay_max;
                if (impact_vertical_speed_max_fpm >= 0) {
                    impact_vertical_speed_fpm = 0.0;
                    setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",impact_vertical_speed_max_fpm);
                    impact_vertical_speed_max_fpm = -100000.0;
                }
                # Debug
                print(sprintf("## Impact CTRL: %.1f",impact_allarm_solution)," (",impact_altitude_hold,")",sprintf(" IR: %.2f",impact_ramp),sprintf(" | %.2f",descent_angle_deg_offset),sprintf(" IR Delta: %.2f",impact_ramp_delta),sprintf(" impact_time: %.2f",impact_time),sprintf(" | %.2f",impact_time_dif_0_10),sprintf(" | %.2f",impact_time_delta),sprintf(" IAG: %.2f",impact_altitude_grain)," | ",impact_altitude_grain_media_size,sprintf(" | %.2f",impact_altitude_grain_avg),sprintf(" IAD: %.2f",impact_altitude_direction_der_frist),sprintf(" A: %.2f",impact_time / impact_altitude_grain),sprintf(" B: %.2f",impact_medium_time_gui)," alt:",math.round(end.alt() * M2FT)," alt delta: ",math.round(altitude_delta),sprintf(" Sec: %.0f",impact_is_in_security_zone),sprintf(" ImpZ: %.0f",impact_min_z_ft));
            } else if (impact_control_active == 1) {
                impact_allarm_solution_delay = 0;
                # If is altitude_hold_inserted is True is necessary verify is convenient violate the rule
                # Is work only impact_control_active == 1, the type 2 no.
                if (impact_is_in_security_zone) {
                    if (impact_altitude_hold_inserted_delay == 1) {
                        impact_altitude_hold = 1;
                        if (impact_vertical_speed_max_fpm <= -100000.0) {
                            impact_vertical_speed_max_fpm = getprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm");
                            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",0.0);
                            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
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
                    if (impact_time < impact_time_dif_0_10) {
                        if (impact_ramp > 0.2) {
                            impact_ramp = impact_ramp - 0.1;
                        } else if (impact_ramp < -0.2) {
                            impact_ramp = impact_ramp + 0.1;
                        } else {
                            impact_ramp = 0.0;
                        }
                    } else {
                        if (impact_ramp < 0) descent_angle_deg_offset = descent_angle_deg_offset * -0.5;
                        impact_ramp = impact_ramp + descent_angle_deg_offset;
                    }
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/altitude-hold-suspended",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",impact_ramp);
                    if (impact_vertical_speed_max_fpm >= 0) {
                        impact_vertical_speed_fpm = 0.0;
                        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",impact_vertical_speed_max_fpm);
                        impact_vertical_speed_max_fpm = -100000.0;
                    }
                }
                # Debug
                print(sprintf("## Impact CTRL: %.1f",impact_allarm_solution)," (",impact_altitude_hold,")",sprintf(" IR: %.2f",impact_ramp),sprintf(" | %.2f",descent_angle_deg_offset),sprintf(" IR Delta: %.2f",impact_ramp_delta),sprintf(" impact_time: %.2f",impact_time),sprintf(" | %.2f",impact_time_dif_0_10),sprintf(" IAG: %.2f",impact_altitude_grain)," | ",impact_altitude_grain_media_size,sprintf(" | %.2f",impact_altitude_grain_avg),sprintf(" IAD: %.2f",impact_altitude_direction_der_frist),sprintf(" A: %.2f",impact_time / impact_altitude_grain),sprintf(" B: %.2f",impact_medium_time_gui)," alt:",math.round(end.alt() * M2FT)," alt delta: ",math.round(altitude_delta),sprintf(" alpha: %.2f",alpha),sprintf(" VVSp: %.2f",impact_vertical_speed_fpm),sprintf(" VVSpMx: %.1f",impact_vertical_speed_max_fpm),sprintf(" D: %.1f",impact_altitude_hold_inserted_delay),sprintf(" Sec: %.0f",impact_is_in_security_zone),sprintf(" ImpZ: %.0f",impact_min_z_ft));
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
    
    setprop("fdm/jsbsim/systems/autopilot/gui/landig-status-id",landig_departure_status_id);
    
};

setlistener("fdm/jsbsim/systems/autopilot/gui/landing-activate", func {
    if (getprop("fdm/jsbsim/systems/autopilot/gui/landing-activate") == 1) {
        if (landig_departure_status_id <= 0) {
            landig_departure_status_id = 1;
        } else if (landig_departure_status_id == 1 and airport_select != nil and rwy_select != nil) {
            landing_activate_status = 1;
        } else {
            landing_activate_status = 0;
            landig_departure_status_id = 0;
        }
        take_off_activate_status = 0;
    }
    setprop("fdm/jsbsim/systems/autopilot/gui/landing-activate",0);
}, 1, 0);

setlistener("fdm/jsbsim/systems/autopilot/gui/take-off-activate", func {
    if (getprop("fdm/jsbsim/systems/autopilot/gui/take-off-activate") == 1) {
        if (landig_departure_status_id <= 10 or landig_departure_status_id >= 11) {
            landig_departure_status_id = 10;
        } else {
            take_off_activate_status = 0;
            landig_departure_status_id = 0;
        }
        landing_activate_status = 0;
    }
    setprop("fdm/jsbsim/systems/autopilot/gui/take-off-activate",0);
}, 1, 0);

setlistener("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/status", func {
    if (getprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/status") == 1) {
        if (getprop("fdm/jsbsim/systems/autopilot/gui/landing-scan-airport") == 1 and airport_select != nil) {
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_name_direct",airport_select.id);
            airport_select_id_direct = nil;
        } else {
            var airport_name = string.uc(getprop("fdm/jsbsim/systems/autopilot/gui/airport_select_name_direct"));
            if (size(airport_name) == 4) {
                airport_select_id_direct = nil;
                var airport = airportinfo(airport_name);
                if (airport != nil) {
                    var apt_coord = geo.Coord.new();
                    apt_coord.set_latlon(airport.lat,airport.lon);
                    var airplane = geo.aircraft_position();
                    if (airplane.distance_to(apt_coord) * 0.000621371 <= getprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct_max_distance")) {
                        airport_select_id_direct = airport;
                        landig_departure_status_id = 1.0;
                        if (getprop("fdm/jsbsim/systems/autopilot/gui/airport_select_name_direct") != airport_select_id_direct.id) {
                            setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_name_direct",airport_select_id_direct.id);
                        }
                        print("## 1 airport_select_id_direct: ",airport_select_id_direct.id);
                        setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw_select",0);
                    }
                }
            }
        }
    }
    setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/status",0);
}, 1, 0);   

setlistener("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-dist-nm", func {
    var dist = getprop("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-dist-nm");
    var elev = getprop("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-h-ft");
    holding_point_slope_imposed = math.atan((elev / 6076.12) / dist)*R2D;
    if (holding_point_slope_imposed > 5.0) {
        elev = dist * 0.105 * 6076.12; # tan(4.0) deg
        setprop("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-h-ft",elev);
    }
    setprop("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-slope",4.0);
}, 1, 0);
    
setlistener("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-h-ft", func {
    var dist = getprop("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-dist-nm");
    var elev = getprop("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-h-ft");
    holding_point_slope_imposed = math.atan((elev / 6076.12) / dist)*R2D;
    if (holding_point_slope_imposed > 5.0) {
        dist = (elev / 6076.12) * 9.514; # tan(86.0) deg
        setprop("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-dist-nm",dist);
    }
    setprop("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-slope",4.0);
}, 1, 0);

setlistener("fdm/jsbsim/systems/autopilot/gui/landing-scan-airport", func {
    var scan = getprop("fdm/jsbsim/systems/autopilot/gui/landing-scan-airport");
    if (scan == 1) {
        airport_select_id_direct = nil;
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw_select",0);
    } else {
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw_select",0);
    }
}, 1, 0);

pilot_assistantTimer = maketimer(timeStep, pilot_assistant);
pilot_assistantTimer.simulatedTime = 1;
pilot_assistantTimer.start();


