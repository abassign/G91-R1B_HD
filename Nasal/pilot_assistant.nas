#// http://wiki.flightgear.org/Nasal_library#Positioned_Object_Queries
#// http://wiki.flightgear.org/Nasal_library#findAirportsWithinRange.28.29

var timeStep = 1.0;
var timeStepDivisor = 1.0;
var delta_time = 1.0;
var speed_up = 1;
var timeStepSecond = 0;

var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_system_selector",0,"INT");
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
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct_max_distance",1300,"DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_name_direct_extended","", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_nearest_runway", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_landing_status", "Autolanding inactive", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_landing_status_id", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/take-off-status", "Take off inactive", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/take-off-jato-active", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_distance", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_delta_altitude", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-control-geo-is-nil","");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-minimal-length-m", 1000, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/dragchute/active-view", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-dist-nm", 15, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-h-ft", 5000, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-activate-prepare", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-activate", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-activate-status", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landig-status-id", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landig-sub-status-id", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-rwy-search-max-heading", 75.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-rwy-search-distance-max", 50.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-short-profile", 1.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-max-lateral-wind", 10.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-holding-altitude-min", 10.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/take-off-activate", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/take-off-altitude-top", 15000.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/take-off-altitude-top-active", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/take-off-to-heading", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/take-off-to-heading-active", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/take-off-cruise-speed", 350.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/take-off-cruise-speed-active", 0.0, "DOUBLE");

#// Landig PID parameters
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-rwy-h-offset-nm", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-rwy-v-offset-ft", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing-PID-kp", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing-PID-ki", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing-PID-kd", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing-PID-ku", 15.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing-PID-tu", 120.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing-PID-gain", 1.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing22-dif-dh-dt", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing-slope-target", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing-slope-error", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing-altitude_agl_ft", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing22-pid-p", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing22-pid-i", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing22-pid-d", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing22-landing-slope", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing21-holding_point-dist", 0.0, "DOUBLE");

var delayCycleGeneral = 0;
var delayLandingSearch = 0.0;

var d2r = 0.0174533;
var airplane_efficenty = 20.0;
var airplane_distance_speed_reduction_nm = 5.0;
var landing_activate_status = 0;
var take_off_activate_status = 0;
var take_off_jato_active = 0.0;
var airport_select = nil;
var rwy_select = nil;
var altitude_top_select = -1.0;
var speed_select = -1.0;

var apts = nil;

var airplane = nil;
var slope = nil;
var airport_select_info = 0.0;
var airport_select_id_direct = nil;
var airport_select_id_direct_rw = nil;
var runway_select_rwy = 0.0;
var runway_alt_m_select = 0.0;
var runway_alt_m_complete_select = 0;
var pilot_ass_status_id = -1;
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
var landing_22_slope_target_increment = 0.0;
var landing_slope_integrate = 0.0;
var landing_slope_previous_error = 0.0;
var airplane_to_holding_point_alt = 0.0;
var runway_to_airplane_dist_nm_direct_nm_mem = 0.0;
var runway_to_airplane_dist_nm = 0.0;
var runway_to_airplane_dist_nm_der = 0.0;
var runway_to_airplane_dist_nm_prec = 0.0;
var dist_to_reduce_h = 0.0;
var landing_20_dist_to_reduce_h = 0;
var landing_20_dist_to_reduce_v = 0;
var landing_20_app_v = 250.0;
var landing_20_dist_to_reduce_h_fpm = 0.0;
var landing_20_dist_to_reduce_step = 0;
var landing_20_dist_to_reduce_v_cas = 0.0;
var landing_20_skip_to_22 = 0;
var landing_22_alt_start = 0.0;
var landing_22_slope = 0.0;
var landing_22_slope_adv_value = 0.0;
var landing_22_slope_target = 0.0;
var landing_22_subStatus = 0;
var landing_22_subStatus_slope_start_coeff = 0;
var landing_22_discending_ftm = 0.0;
var landing_22_slope_adv = std.Vector.new([]);
var landing_22_slope_adv_acc = 0.0;
var landing_22_slope_pitch_adv = std.Vector.new([]);
var landing_22_slope_pitch_acc = 0.0;
var landing_22_dif_dh_dt = std.Vector.new([]);
var landing_22_dif_dh_dt_acc = 0.0;
var landing_22_dif_dh_dt_value = 0.0;
var landing_22_slope_target_proposed = 0.0;
var landing_22_pitch_slope = 0.0;
var landing_22_subStatus_error_lag = 0.0;

var landing_slope_adv = 0.0;
var landing_22_set_cas_lag = 0.0;
var landing_30_brake_stop = 0;
var landing_40_brake_stop = 0;

var apt_coord = geo.Coord.new();
var rwy_coord_start = geo.Coord.new();
var rwy_coord_end = geo.Coord.new();
var rwy_coord_end_offset = 3000.0;
var heading_target_active = 0.0;
var heading_target = 0.0;

var defaultViewInTheEvent = nil;

var testing_log_active = 0;
var testing_level = 0;


var geodetic_airplane_distance_nm = func(lat_B,lon_B) {
    var geo_A = geo.aircraft_position();
    var latA = geo_A.lat() * d2r;
    var lonA = geo_A.lon() * d2r;
    var latB = lat_B * d2r;
    var lonB = lon_B * d2r;
    var phi = lonA - lonB;
    var p = math.acos(math.sin(latB) * math.sin(latA) + math.cos(latB) * math.cos(latA) * math.cos(phi));
    return p * 3440.1;
}


var runway_to_airplane_dist = func(airport, rwy) {
    var airplane = geo.aircraft_position();
    if (rwy != nil) {
        # return airplane.distance_to(geo.Coord.new().set_latlon(airport.runways[rwy].lat,airport.runways[rwy].lon)) * 0.000621371;
        return geodetic_airplane_distance_nm(airport.runways[rwy].lat,airport.runways[rwy].lon);
    } else {
        return nil;
    }
}


var runway_finder = func(airport, all_direction) {
    #// Select the airport nearest in the frontal direction or direct
    apt_coord.set_latlon(airport.lat,airport.lon);
    var airplane = geo.aircraft_position();
    var heading_true_deg = getprop("fdm/jsbsim/systems/autopilot/heading-true-deg");
    var landing_rwy_search_max_heading = getprop("fdm/jsbsim/systems/autopilot/gui/landing-rwy-search-max-heading");
    var airport_heading = math.abs(geo.normdeg(heading_true_deg - airplane.course_to(apt_coord)));
    var landing_minimal_length_m = getprop("fdm/jsbsim/systems/autopilot/gui/landing-minimal-length-m");
    var airport_nearest_runway = getprop("fdm/jsbsim/systems/autopilot/gui/airport_nearest_runway");
    var distance_to_airport_min = 9999.0;
    var landing_max_lateral_wind = getprop("fdm/jsbsim/systems/autopilot/gui/landing-max-lateral-wind");
    var wind_speed = getprop("/environment/wind-speed-kt");
    var wind_from = getprop("/environment/wind-from-heading-deg");
    var rwy_coord = geo.Coord.new();
    var runway_to_airplane_dist_nm = 0.0;
    if (airport_heading <= landing_rwy_search_max_heading
        or getprop("fdm/jsbsim/systems/autopilot/gui/landing-scan-airport") == 0
        or all_direction == 1) {
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
                    runway_to_airplane_dist_nm = runway_to_airplane_dist(airport,rwy);
                    if (runway_to_airplane_dist_nm != nil and distance_to_airport_min > runway_to_airplane_dist_nm) {
                        distance_to_airport_min = runway_to_airplane_dist_nm;
                        print("runway_finder: Landing 1.0 > "
                            ,airport.id,
                            ,sprintf(" Dist (nm): %2.1f",runway_to_airplane_dist_nm)
                            ,sprintf(" H: %2.0f",airport_heading)
                            ," RW: ",airport.runways[rwy].id
                            ,sprintf(" L: %4.0f",airport.runways[rwy].length)
                        );
                        return rwy;
                    } else {
                        return nil;
                    }
                } else {
                    return nil;
                }
            }
        }
    }
}


var pilot_assistant = func() {
    
    testing_log_active = getprop("sim/G91/testing/log");
    if (testing_log_active == nil) testing_log_active = 0;
    testing_level = getprop("sim/G91/testing/level");
    if (testing_level == nil) testing_level = 0;
    speed_up = getprop("/sim/speed-up");
    
    var speed_cas = getprop("fdm/jsbsim/systems/autopilot/speed-cas-on-air");
    airplane = geo.aircraft_position();
    
    var rwy_offset_h_nm = getprop("fdm/jsbsim/systems/autopilot/gui/landing-rwy-h-offset-nm");
    var rwy_offset_v_ft = getprop("fdm/jsbsim/systems/autopilot/gui/landing-rwy-v-offset-ft");
    var gear_unit_contact = getprop("fdm/jsbsim/context/gears/on-ground");
    var speed_true_nmh = getprop("fdm/jsbsim/systems/autopilot/speed-true-on-air");
    var speed_true_fps = speed_true_nmh / 3600.0 * 5280.0;
    if (pilot_ass_status_id == 1) {
        var landing_rwy_search_distance_max = getprop("fdm/jsbsim/systems/autopilot/gui/landing-rwy-search-distance-max");
        var landing_rwy_search_max_heading = getprop("fdm/jsbsim/systems/autopilot/gui/landing-rwy-search-max-heading");
        var landing_minimal_length_m = getprop("fdm/jsbsim/systems/autopilot/gui/landing-minimal-length-m");
        var landing_max_lateral_wind = getprop("fdm/jsbsim/systems/autopilot/gui/landing-max-lateral-wind");
        var airport_nearest_runway = getprop("fdm/jsbsim/systems/autopilot/gui/airport_nearest_runway");
        var distance_to_airport_min = 9999.0;
        var heading_true_deg = getprop("fdm/jsbsim/systems/autopilot/heading-true-deg");
        var wind_speed = getprop("/environment/wind-speed-kt");
        var wind_from = getprop("/environment/wind-from-heading-deg");
        var rwy_coord = geo.Coord.new();
        var runway_to_airplane_dist_nm = 0.0;
        
        if (landing_activate_status == 0 and delayLandingSearch <= 0.5) {
            delayLandingSearch = 1.0;
            var airport_system_selector = getprop("fdm/jsbsim/systems/autopilot/gui/airport_system_selector");
            var airport_system_selector_id = nil;
            if (airport_system_selector > 0) {
                airport_system_selector_id = getprop("sim/gui/dialogs/airports/selected-airport/id");
                if (airport_system_selector_id != nil) {
                    var runway_id = getprop("sim/gui/dialogs/airports/selected-airport/rwy");
                    setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_name_direct",airport_system_selector_id);
                    if (runway_id != nil and size(runway_id > 0)) {
                        setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rws",runway_id);
                    } else {
                        setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rws","");
                    };
                    airport_select_id_direct = airportinfo(airport_system_selector_id);
                }
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_system_selector",0);
            }
            if (airport_select_id_direct != nil) {
                apts = [airport_select_id_direct];
            } else {
                apts = findAirportsWithinRange(landing_rwy_search_distance_max,"airport");
            }
            rwy_select = nil;
            foreach(var apt; apts) {
                var airport = airportinfo(apt.id);
                #// Select the airport nearest in the frontal direction or direct
                apt_coord.set_latlon(airport.lat,airport.lon);
                if (getprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw_select") == 0) {
                    var airport_heading = math.abs(geo.normdeg(heading_true_deg - airplane.course_to(apt_coord)));
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
                                    runway_to_airplane_dist_nm = airplane.distance_to(rwy_coord) * 0.000621371;
                                    if (distance_to_airport_min > runway_to_airplane_dist_nm) {
                                        distance_to_airport_min = runway_to_airplane_dist_nm;
                                        airport_select = airport;
                                        rwy_select = rwy;
                                    }
                                    print("Landing 1.0 > "
                                        ,apt.id,
                                        ,sprintf(" Dist (nm): %2.1f",runway_to_airplane_dist_nm)
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
        } else if (delayLandingSearch > 0.5) {
            delayLandingSearch = delayLandingSearch - 1.0;
        }
            
        if (landing_activate_status == 0 and apts != nil and airplane != nil) {
            if (airport_select != nil and airport_select.id != getprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw_airport_select")) {
                var apt_coord = geo.Coord.new();
                apt_coord.set_latlon(airport_select.lat,airport_select.lon);
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_name_direct",airport_select.id);
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_name_direct_extended",airport_select.name ~ " (" ~ math.round(airplane.distance_to(apt_coord) * 0.000621371) ~ ")");
                #// Create the runway list for manual selection
                #// Cleaning the list
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw_airport_select",airport_select.id);
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw_select",0);
                var airport_select_id_direct_node = props.globals.getNode("/fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct", 1);
                var rws_node = airport_select_id_direct_node.getNode("rws", 1);
                rws_node.removeChildren("value");
                #// Create the Runway list
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
            
            #// Manual Runway select
            if (airport_select != nil and getprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw_select") == 1) {
                rwy_select = string.trim(substr(getprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw"),0,3));
            }
        }
        if (airport_select != nil and rwy_select != nil and airport_select.runways[rwy_select] != nil and size(rwy_select) <= 3) {
            isAirport_and_rw_selected = 1;
            var landing_rwy_h_offset_nm = - 0.1;
            if (airport_select.runways[rwy_select].length > 1000) {
                landing_rwy_h_offset_nm = - ((2000.0 - airport_select.runways[rwy_select].length) / 8000);
            }
            setprop("fdm/jsbsim/systems/autopilot/gui/landing-rwy-h-offset-nm",landing_rwy_h_offset_nm);
            rwy_coord_start.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon);
            runway_to_airplane_dist_nm = math.abs(airplane.distance_to(rwy_coord_start) * 0.000621371 - rwy_offset_h_nm);
            var runway_to_airplane_delta_alt_ft = (airplane.alt() - airport_select.elevation) * 3.28084;
            if (math.abs(runway_to_airplane_dist_nm > 0.1)) {
                slope = math.atan((runway_to_airplane_delta_alt_ft * 0.000189394) / runway_to_airplane_dist_nm) * R2D;
            } else {
                slope = 0.0;
            }
            runway_alt_m_complete_select = 0;
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id",airport_select.id);
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_name",airport_select.name);
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_id",airport_select.runways[rwy_select].id);
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_distance",runway_to_airplane_dist_nm);
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope",slope);
            if (landing_activate_status == 1
                and ((getprop("fdm/jsbsim/systems/gauges/PHI/program/route-manager/autopush-last") == 1 and getprop("fdm/jsbsim/systems/gauges/PHI/program/route-manager/autopush-active") == 1)
                    or getprop("fdm/jsbsim/systems/gauges/PHI/program/route-manager/autopush-active") == 0)
                and pilot_ass_status_id < 10.0 
                and pilot_ass_status_id > 0.0
                and gear_unit_contact == 0) {
                #
                #// Find an airport
                #
                pilot_ass_status_id = 2;
                airport_select_id_direct = nil;
                airport_select_id_direct_rw = nil;
                landing_20_skip_to_22 = 0;
                landing_20_dist_to_reduce_h = 0;
                landing_20_dist_to_reduce_v = 0;
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-active",1.0);
                if (altitude_top_select > 0.0) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",math.round(altitude_top_select));
                    setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/altitude-QFE",0.0);
                    altitude_top_select = -1.0;
                } else {
                    if (getprop("/jsbsim/systems/autopilot/gui/altitude-hold") == 0 and getprop("fdm/jsbsim/systems/autopilot/gui/altitude-QFE") == 0) {
                        setprop("/jsbsim/systems/autopilot/gui/altitude-hold",1);
                        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",100 * math.round(getprop("fdm/jsbsim/systems/autopilot/h-sl-ft-lag") / 100.0));
                    }
                }
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",getprop("fdm/jsbsim/systems/autopilot/heading-true-deg"));
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/heading-control",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/wing-leveler",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",30.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/rudder-auto-coordination",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",2500.0);
                setprop("fdm/jsbsim/systems/autopilot/phase-landing",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-control",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-flap",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-throttle",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-pitch",0.0);
                setprop("fdm/jsbsim/systems/autopilot/speed-best-by-altitude-set",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",1.0);
                if (getprop("fdm/jsbsim/systems/autopilot/gui/impact-medium-time") < 30.0) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/impact-medium-time",30.0);
                }
                if (speed_select <= 0.0) {
                    if (speed_select < 2.0 and speed_select > 0.0) {
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",1.0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",0.0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",speed_select);
                    } else {
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                        if (getprop("fdm/jsbsim/systems/autopilot/gui/speed-value") < 350) {
                            setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",350.0);
                        } else {
                            setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",getprop("fdm/jsbsim/systems/autopilot/gui/speed-value"));
                        }
                    }
                } else {
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                    if (getprop("fdm/jsbsim/systems/autopilot/gui/speed-value") < 250) {
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",250.0);
                    } else {
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",speed_select);
                    } 
                }
                setprop("fdm/jsbsim/systems/autopilot/speed-throttle-imposed",-1.0);
                setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-close",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",0.0);
                setprop("fdm/jsbsim/systems/airbrake/manual-cmd",0.0);
                rwy_coord_end.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon);
                rwy_coord_end_offset = airport_select.runways[rwy_select].length;
                rwy_coord_end.apply_course_distance(airport_select.runways[rwy_select].heading,rwy_coord_end_offset);
                airplane_to_holding_point_alt = airplane.alt() * 3.28084;
            } else {
                pilot_ass_status_id = 1;
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",1.0);
            }
        } else {
            isAirport_and_rw_selected = 0;
            landing_activate_status = 0;
        }
    }
    if (pilot_ass_status_id == 1 and pilot_ass_status_id < 10 and airport_select == nil) {
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_landing_status","No airport for landing");
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope",0.0);
    } else if (pilot_ass_status_id >= 1 
            and pilot_ass_status_id < 10 
            and airport_select != nil 
            and rwy_select != nil 
            and size(rwy_select) <= 3) {
        var holding_point_before_distance_nm = 4.0;
        var holding_point_to_airplane_delta_alt_ft = 0.0;
        var runway_to_airplane_delta_alt_ft = 0.0;
        var heading_correction_deg = 0.0;
        var heading_correct = 0.0;
        var runway_to_airplane_dist_nm_direct_nm = 0.0;
        var altitude_agl_ft = 0.0;
        var runways_delta_length = 0.0;
        var holding_point_h_ft = getprop("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-h-ft");
        rwy_coord_end.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon);
        rwy_coord_end.apply_course_distance(airport_select.runways[rwy_select].heading,airport_select.runways[rwy_select].length);
        var runway_end_to_airplane_dist = airplane.distance_to(rwy_coord_end) * 0.000621371;
        #// Impact complex factor modificator section
        var impact_ctl_active = getprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active");
        var impact_ctl_speed_increment_norm = 0.0;
        var complex_factor = getprop("fdm/jsbsim/systems/autopilot/altitude-QFE-impact-elev-complex-factor");
        var impact_ctl_attention = 0.0;
        var selector_complex_set = getprop("fdm/jsbsim/systems/autopilot/altitude-type-selector-complex-set");
        var pilot_impact_control_t1 = getprop("fdm/jsbsim/systems/autopilot/pilot-impact-control-t1");
        
        #// Impact control system
        
        if (impact_ctl_active > 0 and complex_factor >= selector_complex_set and runway_to_airplane_dist_nm > 4.0) {
            if (pilot_impact_control_t1 > 0.1) {
                impact_ctl_speed_increment_norm = complex_factor / selector_complex_set;
            } else {
                complex_factor = 0.0;
            }
        }
        if (impact_ctl_active > 0 and complex_factor >= selector_complex_set and getprop("fdm/jsbsim/systems/autopilot/altitude-hold-error-norm") > 0.15) {
            impact_ctl_attention = 1.0;
        }
        
        #// Common eleboration
        
        runways_delta_length = (airport_select.runways[rwy_select].length / 1852.0) / ((airport_select.runways[rwy_select].length / 1000.0) * 3.0);
        rwy_coord_start.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon);
        var holding_point = geo.Coord.new();
        holding_point.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon);
        var heading_correction_deg_for_before_dist = math.abs(geo.normdeg180(getprop("fdm/jsbsim/systems/autopilot/heading-true-deg") - airplane.course_to(rwy_coord_start)));
        var holding_point_distance_nm = getprop("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-dist-nm");
        holding_point.apply_course_distance(airport_select.runways[rwy_select].heading + 180.0,holding_point_distance_nm * 1852.0);
        runway_to_airplane_dist_nm_direct_nm = airplane.direct_distance_to(rwy_coord_start) * 0.000621371 + rwy_offset_h_nm + runways_delta_length;
        var holding_point_to_airplane_dist_nm = airplane.distance_to(holding_point) * 0.000621371;
        if (heading_correction_deg_for_before_dist < 90 and holding_point_to_airplane_dist_nm > 1.8) {
            holding_point_before_distance_nm = 1.8;
        } else if (heading_correction_deg_for_before_dist >= 90 and holding_point_to_airplane_dist_nm > 1.8) {
            holding_point_before_distance_nm = 1.8 * (1 + ((heading_correction_deg_for_before_dist - 90.0) / 90.0));
        } else {
            holding_point_before_distance_nm = 0.0;
        }
        runway_to_airplane_dist_nm = geo.aircraft_position().distance_to(rwy_coord_start) * 0.000539957 + rwy_offset_h_nm + runways_delta_length;
        runway_to_airplane_dist_nm_der = (runway_to_airplane_dist_nm_prec - runway_to_airplane_dist_nm) / delta_time;
        runway_to_airplane_dist_nm_prec = runway_to_airplane_dist_nm;
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_distance",runway_to_airplane_dist_nm);
        if (runway_alt_m_complete_select <= 1) { 
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
        heading_correction_deg = (airport_select.runways[rwy_select].heading - airplane.course_to(rwy_coord_start));
        heading_correct = airport_select.runways[rwy_select].heading - heading_correction_deg;
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
        setprop("fdm/jsbsim/systems/autopilot/landing-slope-target",0.0);
        #
        #// Select and elaborate the effective landing phase
        #
        if (pilot_ass_status_id == 2.0) {
            if (runway_to_airplane_dist_nm > 0.1) {
                slope = math.atan((runway_to_airplane_delta_alt_ft * 0.000189394) / runway_to_airplane_dist_nm) * R2D;
            } else {
                slope = 0.0;
            }
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope",slope);
            setprop("fdm/jsbsim/systems/autopilot/landing21-holding_point-dist",holding_point_to_airplane_dist_nm);
            #// Fly to the holding point
            var holding_point_to_airplane_dist_nm_direct = airplane.direct_distance_to(holding_point) * 0.000621371;
            var holding_point_to_airplane_delta_alt_ft = airplane.alt() * 3.28084 - (runway_alt_m_select * 3.28084 + holding_point_h_ft);
            var altitude_for_holding_point = runway_alt_m_select * 3.28084 + holding_point_h_ft;
            if (landing_20_dist_to_reduce_h == 0) {
                dist_to_reduce_h = (holding_point_to_airplane_delta_alt_ft / 5280.0) * airplane_efficenty * 1.2 + 3.0;
            }
            #// Speed reduction section
            if (landing_20_dist_to_reduce_v == 0 and holding_point_to_airplane_dist_nm_direct < ((speed_cas / landing_20_app_v) * airplane_distance_speed_reduction_nm)) {
                landing_20_dist_to_reduce_v = 1;
                landing_20_dist_to_reduce_v_cas = landing_20_app_v;
            }
            if (landing_20_dist_to_reduce_v == 1) {
                setprop("fdm/jsbsim/systems/autopilot/speed-best-by-altitude-set",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",landing_20_dist_to_reduce_v_cas);
                if ((speed_cas - landing_20_dist_to_reduce_v_cas) > 20.0) {
                    setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",1.0);
                } else {
                    setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-deactivate",1.0);
                }
            }
            #// Altitude reduction section
            if (landing_20_dist_to_reduce_h == 1 or (holding_point_to_airplane_dist_nm < dist_to_reduce_h)) {
                if (landing_20_dist_to_reduce_h == 0) {
                    landing_20_dist_to_reduce_h = 1;
                }
                if (math.abs(holding_point_to_airplane_dist_nm) > 5.0) {
                    if (timeStepSecond == 1 and landing_20_dist_to_reduce_step <= 0) {
                        if (holding_point_to_airplane_dist_nm > 5.0) {
                            landing_20_dist_to_reduce_h_fpm = holding_point_to_airplane_delta_alt_ft / ((holding_point_to_airplane_dist_nm / speed_true_nmh) * 60.0);
                            if (landing_20_dist_to_reduce_h_fpm > 3500.0) {
                                landing_20_dist_to_reduce_h_fpm = 3500.0;
                            }
                        }
                        landing_20_dist_to_reduce_step = 10;
                    } else {
                        landing_20_dist_to_reduce_step = landing_20_dist_to_reduce_step - 1;
                    }
                } else if (math.abs(holding_point_to_airplane_dist_nm) > 5.0) {
                    landing_20_dist_to_reduce_h_fpm = 500.0;
                } else {
                    landing_20_dist_to_reduce_h_fpm = 1000.0;
                }
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle-deg",6.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1.0);
                if (impact_ctl_attention == 0.0) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",landing_20_dist_to_reduce_h_fpm * 1.2);
                } else {
                    setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",2500 * (1 + complex_factor));
                }
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",altitude_for_holding_point);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-QFE",0.0);
            }
            if (holding_point_to_airplane_dist_nm > holding_point_before_distance_nm and holding_point_before_distance_nm > 0.0) {
                heading_correct = airplane.course_to(holding_point);
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
                if (testing_log_active >= 1 and timeStepSecond == 1) {
                    print(
                     sprintf("Landing %2.1f",pilot_ass_status_id)
                    ,sprintf(" Hoding dist (nm): %5.1f",holding_point_to_airplane_dist_nm_direct)
                    ,sprintf(" Alt: %5.0f",altitude_for_holding_point)
                    ,sprintf(" Delta: %.0f",holding_point_to_airplane_delta_alt_ft)
                    ,sprintf(" Slope: %.1f",slope)
                    ,sprintf(" | Heading cor: %4.1f",heading_correct)
                    ,sprintf(" Heading correction: %4.1f",heading_correction_deg_for_before_dist)
                    ,sprintf(" Hld. pt to plane (nm): %4.1f",holding_point_to_airplane_dist_nm)
                    ,sprintf(" Hld. pt (nm): %3.1f",holding_point_before_distance_nm)
                    ,sprintf(" Dis R: %3.1f",dist_to_reduce_h)
                    ,sprintf(" Dist red fpm: %5.0f",landing_20_dist_to_reduce_h_fpm)
                    ,sprintf(" CAS: %6.0f",speed_cas)
                    ,sprintf(" SB: %1.2f",getprop("fdm/jsbsim/systems/airbrake/position"))
                    ,sprintf(" Reduce H: %1.0f",landing_20_dist_to_reduce_h)
                    ,sprintf(" V: %1.0f",landing_20_dist_to_reduce_v)
                    );
                }
            } else {
                if (math.abs(holding_point_to_airplane_delta_alt_ft) < 500.0 and math.abs(speed_cas - 190) < 40.0) {
                    landing_20_skip_to_22 = 1;
                }
                pilot_ass_status_id = 2.1;
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",45.0);
                setprop("fdm/jsbsim/systems/autopilot/phase-landing",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",landing_20_app_v);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",2500.0);
                setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-deactivate",1.0);
                setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-close",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",0.0);
                setprop("fdm/jsbsim/systems/airbrake/manual-cmd",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle-deg",9.0);
                setprop("fdm/jsbsim/systems/autopilot/speed-best-by-altitude-set",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",1.0);
                if (getprop("fdm/jsbsim/systems/autopilot/gui/impact-medium-time") < 30.0) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/impact-medium-time",30.0);
                }
                isHolding_reducing_delta = -20;
                isHolding_reducing_heading = nil;
                isHolding_reducing_distance_rel = nil;
                isHolding_reducing_terminated = 0;
            }
        } else if (pilot_ass_status_id == 2.1) {
            #// Fly near the holding point
            #// Deley the start
            if (isHolding_reducing_delta < 0) {
                isHolding_reducing_delta = isHolding_reducing_delta + 1;
            }
            #// Marc altitude by slope in the holding point
            setprop("fdm/jsbsim/systems/autopilot/landing21-holding_point-dist",holding_point_to_airplane_dist_nm);
            setprop("fdm/jsbsim/systems/autopilot/altitude-QFE-set-active-stop",1);
            setprop("fdm/jsbsim/systems/autopilot/pitch-output-error-coefficient-gain",1.5);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",1.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/altitude-QFE",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",runway_alt_m_select * 3.28084 + holding_point_h_ft);
            setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",45.0 - 10.0 * (getprop("fdm/jsbsim/systems/autopilot/h-sl-ft-lag") / 30000));
            #// Calculate the actual slope, normaly is less than the holding_point_slope_imposed
            if (runway_to_airplane_dist_nm > 0.1) {
                slope = - math.atan(((runway_to_airplane_delta_alt_ft - rwy_offset_v_ft)* 0.000189394) / runway_to_airplane_dist_nm) * R2D;
            } else {
                slope = 0.0;
            }
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope",slope);
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_distance",runway_to_airplane_dist_nm);
            #// Set the holding area dimension
            var long_circuit_distance = 3.0;
            var short_circuit_distance = 0.5;
            if (isHolding_reducing_terminated == 2) {
                var long_circuit_distance = 0.5;
            }
            var rwy_point_delta_alt_ft = (airplane.alt() - runway_alt_m_select) * 3.28084 - holding_point_h_ft;
            #// Calculate the difference altitude
            if (rwy_point_delta_alt_ft < 1000.0 and rwy_point_delta_alt_ft >= 0.0 and isHolding_reducing_terminated == 0) {
                isHolding_reducing_terminated = 1;
            } else if (rwy_point_delta_alt_ft > -500.0 and rwy_point_delta_alt_ft < 0.0 and isHolding_reducing_terminated == 0) {
                isHolding_reducing_terminated = 1;
            } else if (math.abs(rwy_point_delta_alt_ft) < 1500 and isHolding_reducing_terminated == 0) {
                if (impact_ctl_attention == 0) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",1500.0);
                } else {
                    setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",2500 * (1 + complex_factor));
                }
            } else if (math.abs(rwy_point_delta_alt_ft) > 1500 and isHolding_reducing_terminated == 0) {
                if (impact_ctl_attention == 0) {
                    if (rwy_point_delta_alt_ft > 0.0) {
                        setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",1.0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",3500.0);
                    } else {
                        setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",0.0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",2500.0);
                    }
                } else {
                    setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",2500 * (1 + complex_factor));
                }
            }
            if (impact_ctl_attention == 0.0) {
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",landing_20_dist_to_reduce_h_fpm * 1.2);
            } else {
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",2500 * (1 + complex_factor));
            }
            #// Calculate the difference of the speed
            if ((math.abs(getprop("fdm/jsbsim/systems/autopilot/speed-cas-lag") - 250.0)) < 40.0 and isHolding_reducing_terminated == 1) {
                isHolding_reducing_terminated = 2;
                setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-deactivate",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",1500.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1.0);
            }
            #// Check stop execution and exit for 2.2 phase
            if ((isHolding_reducing_terminated == 2 and isHolding_reducing_delta < 0) or landing_20_skip_to_22 == 1) {
                pilot_ass_status_id = 2.2;
                landing_22_alt_start = math.round(getprop("fdm/jsbsim/systems/autopilot/h-sl-ft-lag"));
                setprop("fdm/jsbsim/systems/autopilot/landing21-holding_point-dist",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",190.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",40.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",2500.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle-deg",6.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-flap",0.0);
                setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-close",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",0.0);
                setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-deactivate",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-brake",0.0);
                setprop("fdm/jsbsim/systems/airbrake/manual-cmd",0.0);
                setprop("fdm/jsbsim/systems/autopilot/phase-landing",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",1.0);
                if (getprop("fdm/jsbsim/systems/autopilot/gui/impact-medium-time") < 30.0) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/impact-medium-time",30.0);
                }
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-QFE-impact-ft",600.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-QFE-ft",600.0);
                landing_22_subStatus = 0;
                landing_22_slope_adv.clear();
                landing_22_slope_adv.extend([]);
                landing_22_slope_adv_acc = 0.0;
                landing_22_slope_pitch_acc = 0.0;
                landing_22_set_cas_lag = getprop("fdm/jsbsim/systems/autopilot/speed-cas-on-air-lag");
                landing_slope_integrate = 0.0;
                #// Redefine the coordinates in function of the definitive selected rwy
                rwy_coord_end.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon);
                rwy_coord_end_offset = airport_select.runways[rwy_select].length;
                if (rwy_coord_end_offset > 1000.0) rwy_coord_end_offset = 1000.0;
                rwy_coord_end.apply_course_distance(airport_select.runways[rwy_select].heading,rwy_coord_end_offset);
                landing_22_discending_ftm = 0.0;
            }
            #// Loops execution
            if (isHolding_reducing_terminated <= 2 and isHolding_reducing_delta >= 0) {
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",2500.0);
                #// Set approch point
                #// Direct landing
                #// holding_point_h_ft ft - 10 nm slope 3-4°
                #// Is near the airport verify the delta
                #// Is necesary the quote reduction
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
                        if ((getprop("fdm/jsbsim/systems/autopilot/distance-nm") - isHolding_reducing_distance_rel) > short_circuit_distance) {
                            if (math.abs(getprop("fdm/jsbsim/systems/autopilot/true-heading-deg-delta")) < 0.5) {
                                isHolding_reducing_distance_rel_stright = getprop("fdm/jsbsim/systems/autopilot/distance-nm");
                            }
                        }
                    } else {
                        if ((getprop("fdm/jsbsim/systems/autopilot/distance-nm") - isHolding_reducing_distance_rel_stright) > short_circuit_distance) {
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
                        if ((getprop("fdm/jsbsim/systems/autopilot/distance-nm") - isHolding_reducing_distance_rel) > short_circuit_distance) {
                            if (math.abs(getprop("fdm/jsbsim/systems/autopilot/true-heading-deg-delta")) < 0.5) {
                                isHolding_reducing_distance_rel_stright = getprop("fdm/jsbsim/systems/autopilot/distance-nm");
                            }
                        }
                    } else {
                        if (((getprop("fdm/jsbsim/systems/autopilot/distance-nm") - isHolding_reducing_distance_rel_stright) > long_circuit_distance)) {
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
                        if ((getprop("fdm/jsbsim/systems/autopilot/distance-nm") - isHolding_reducing_distance_rel) > short_circuit_distance) {
                            if (math.abs(getprop("fdm/jsbsim/systems/autopilot/true-heading-deg-delta")) < 0.5) {
                                isHolding_reducing_distance_rel_stright = getprop("fdm/jsbsim/systems/autopilot/distance-nm");
                            }
                        }
                    } else {
                        if ((getprop("fdm/jsbsim/systems/autopilot/distance-nm") - isHolding_reducing_distance_rel_stright) > short_circuit_distance) {
                            isHolding_reducing_distance_rel = nil;
                            isHolding_reducing_distance_rel_stright = nil;
                            isHolding_reducing_delta = 3;
                        }
                    }
                } else if (isHolding_reducing_delta == 3) {
                    if (isHolding_reducing_terminated == 2) {
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",190.0);
                    }
                    isHolding_reducing_heading_clipto = isHolding_reducing_heading + 360.0;
                    if (isHolding_reducing_heading_clipto >= 360.0) isHolding_reducing_heading_clipto = isHolding_reducing_heading_clipto - 360.0;
                    setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",math.abs(isHolding_reducing_heading_clipto));
                    if (isHolding_reducing_distance_rel == nil) {
                        isHolding_reducing_distance_rel = getprop("fdm/jsbsim/systems/autopilot/distance-nm");
                    } else if (isHolding_reducing_distance_rel_stright == nil) {
                        if ((getprop("fdm/jsbsim/systems/autopilot/distance-nm") - isHolding_reducing_distance_rel) > short_circuit_distance) {
                            if (math.abs(getprop("fdm/jsbsim/systems/autopilot/true-heading-deg-delta")) < 0.5) {
                                isHolding_reducing_distance_rel_stright = getprop("fdm/jsbsim/systems/autopilot/distance-nm");
                            }
                        }
                    } else {
                        if (((getprop("fdm/jsbsim/systems/autopilot/distance-nm") - isHolding_reducing_distance_rel_stright) > long_circuit_distance)) {
                            isHolding_reducing_heading = nil;
                            isHolding_reducing_distance_rel = nil;
                            isHolding_reducing_distance_rel_stright = nil;
                            isHolding_reducing_delta = -2;
                        }
                    }
                }
            }
            if (testing_log_active >= 1 and timeStepSecond == 1) {
                print(
                    sprintf("Landing %2.1f",pilot_ass_status_id)
                    ,sprintf(" Dist (nm): %6.1f",runway_to_airplane_dist_nm)
                    ,sprintf(" Alt (ft): %5.0f",(runway_to_airplane_delta_alt_ft - rwy_offset_v_ft))
                    ,sprintf(" Alt delta (ft): %5.0f",rwy_point_delta_alt_ft)
                    ,sprintf(" Slope: %3.1f",slope)
                    ,sprintf(" holding_point_h_ft (ft): %5.0f",holding_point_h_ft)
                    ,sprintf(" isHolding_reducing_delta: %3.0f",isHolding_reducing_delta)
                    ,sprintf(" is Term: %.0f",isHolding_reducing_terminated)
                    ,sprintf(" CAS: %6.1f",speed_cas)
                );
            }
        } else if (pilot_ass_status_id == 2.2) {
            setprop("fdm/jsbsim/systems/autopilot/altitude-QFE-set-active-stop",1);
            setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle",1.0);
            setprop("fdm/jsbsim/systems/autopilot/pitch-output-error-coefficient-gain",1.0);
            var wind_speed = getprop("/environment/wind-speed-kt");
            var wind_from = getprop("/environment/wind-from-heading-deg");
            var wind_deviation = math.abs(geo.normdeg(wind_from - airport_select.runways[rwy_select].heading));
            var wind_frontal = wind_speed * (math.cos(wind_deviation * d2r));
            var wind_lateral = wind_speed * (math.sin(wind_deviation * d2r));
            var distance_to_leave = 0.0 + (wind_frontal * 25) / 1000.0;
            if (distance_to_leave < 0.2) distance_to_leave = 0.2;
            var altitude_agl_ft = getprop("/position/altitude-agl-ft");
            setprop("fdm/jsbsim/systems/autopilot/landing-altitude_agl_ft",altitude_agl_ft);
            var landing_22_subStatus_2_1_dist_nm = 12.0;
            var landing_22_subStatus_2_2_dist_nm = 7.0;
            var landing_22_subStatus_2_3_dist_nm = 4.0;
            
            #// Heading to select rwy
            if (gear_unit_contact == 0) {
                var rwy_coord_start_final = geo.Coord.new();
                var rwy_coord_end_final = geo.Coord.new();
                if (runway_to_airplane_dist_nm > landing_22_subStatus_2_1_dist_nm) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-flap",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-brake",1.0);
                    if (getprop("fdm/jsbsim/systems/autopilot/gui/impact-medium-time") < 20.0) {
                        setprop("fdm/jsbsim/systems/autopilot/gui/impact-medium-time",20.0);
                    }
                    setprop("fdm/jsbsim/systems/autopilot/gui/altitude-QFE-impact-ft",400.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/altitude-QFE-ft",400.0);
                }
                if (runway_to_airplane_dist_nm <= landing_22_subStatus_2_1_dist_nm and runway_to_airplane_dist_nm > landing_22_subStatus_2_2_dist_nm) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-flap",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-brake",0.0);
                    if (impact_ctl_attention == 0.0) {
                        setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",1.0);
                    } else {
                        setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",0.0);
                    }
                }
                if (runway_to_airplane_dist_nm <= landing_22_subStatus_2_2_dist_nm and runway_to_airplane_dist_nm > landing_22_subStatus_2_3_dist_nm) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-open",1.0);
                    if (impact_ctl_attention == 0.0) {
                        setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",1.0);
                    } else {
                        setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",0.0);
                    }
                    if (getprop("fdm/jsbsim/systems/autopilot/gui/impact-medium-time") < 15.0) {
                        setprop("fdm/jsbsim/systems/autopilot/gui/impact-medium-time",15.0);
                    }
                    setprop("fdm/jsbsim/systems/autopilot/gui/altitude-QFE-impact-ft",200.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/altitude-QFE-ft",200.0);
                }
                if (runway_to_airplane_dist_nm <= landing_22_subStatus_2_3_dist_nm) {
                    setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-open",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/phase-landing",2.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-brake",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",0.0);
                }

                if (runway_to_airplane_dist_nm > 2.0) {
                    rwy_coord_start_final.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon);
                    rwy_coord_start_final.apply_course_distance(airport_select.runways[rwy_select].heading,runway_to_airplane_dist_nm * 1852.0);
                    heading_correct = airplane.course_to(rwy_coord_start_final);
                } else {
                    rwy_coord_end_final.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon);
                    rwy_coord_end_final.apply_course_distance(airport_select.runways[rwy_select].heading,(runway_to_airplane_dist_nm * 1852.0 + rwy_coord_end_offset));
                    heading_correct = airplane.course_to(rwy_coord_end_final);
                }
                var heading_runway = geo.normdeg180(airport_select.runways[rwy_select].heading);
                heading_correction_deg = geo.normdeg180(heading_runway - heading_correct);
                var heading_factor = 2.0;
                if (math.abs(heading_correction_deg) < 10.0 and math.abs(heading_correction_deg) > 2.0) {
                    heading_factor = 2.0 + 4 * math.abs(heading_correction_deg);
                } else if (math.abs(heading_correction_deg) <= 2 and math.abs(heading_correction_deg) > 0.05) {
                    heading_factor = 4.0 + 12 * math.abs(heading_correction_deg);
                }
                var heading_correction_deg_mod = heading_correction_deg * heading_factor;
                if (heading_correction_deg_mod > 40.0) heading_correction_deg_mod = 40;
                if (heading_correction_deg_mod < -40.0) heading_correction_deg_mod = -40;
                heading_correct = geo.normdeg180(heading_runway - heading_correction_deg_mod);
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
                #// Slope target correction
                var landing_22_set_cas = 180.0;
                var wind_frontal_active = wind_frontal;
                if (wind_frontal_active < 0) wind_frontal_active = 0;
                wind_frontal_active = 0.0;
                var slopeIncrementIntegrate = 0.05;
                var delta_h_ft = runway_to_airplane_delta_alt_ft - rwy_offset_v_ft;
                var error = 0.0;
                var derivate = 0.0;
                var dist_direct_ft = runway_to_airplane_dist_nm * 5280.0;
                var pitch_output_error_coefficient_gain = 1.0;
                var weitght_norm = (getprop("fdm/jsbsim/inertia/weight-lbs") / 10000.0) - 1;
                var delta_h_vs_dist_ft = 0.0;
                var landing_22_slope_adv_size = 100;
                var landing_22_dif_dh_dt_size = 50;
                var ku = getprop("fdm/jsbsim/systems/autopilot/landing-PID-ku");
                var tu = getprop("fdm/jsbsim/systems/autopilot/landing-PID-tu");
                var gain_landing = getprop("fdm/jsbsim/systems/autopilot/landing-PID-gain");
                var gain_landing_mod = gain_landing;
                
                if (landing_22_subStatus <= 1) {
                    if ((runway_to_airplane_dist_nm <= landing_22_subStatus_2_1_dist_nm or landing_22_slope_adv_value <= -3.5) and landing_22_slope_adv.size() >= (landing_22_slope_adv_size / speed_up)) {
                        landing_22_subStatus = 2;
                        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",0.0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/landig-sub-status-id",landing_22_subStatus);
                        landing_22_slope_target_proposed = -3.5;
                        landing_22_slope_target = landing_22_slope_adv_value;
                    } else {
                        if (landing_22_subStatus < 1) {
                            landing_22_subStatus = 1;
                            setprop("fdm/jsbsim/systems/autopilot/gui/landig-sub-status-id",landing_22_subStatus);
                            landing_slope_previous_error = 0.0;
                            landing_22_slope_target = 0.0;
                            landing_22_set_cas_lag = speed_cas;
                            landing_22_subStatus_error_lag = 0.0;
                            setprop("fdm/jsbsim/systems/autopilot/gui/impact-medium-time",30);
                        }
                        pitch_output_error_coefficient_gain = 1.0;
                        landing_22_h_nm = delta_h_ft * 0.000189394;
                        delta_h_vs_dist_ft = delta_h_ft;
                        landing_22_slope = - math.atan(landing_22_h_nm / runway_to_airplane_dist_nm_direct_nm) * R2D;
                        landing_22_set_cas = 180.0 + 50 * impact_ctl_speed_increment_norm;
                        if (landing_22_set_cas > 230.0) landing_22_set_cas = 230.0;
                        if (landing_22_set_cas_lag < (landing_22_set_cas - 2)) landing_22_set_cas_lag = landing_22_set_cas_lag + 2.0 * delta_time;
                        if (landing_22_set_cas_lag > (landing_22_set_cas + 2)) landing_22_set_cas_lag = landing_22_set_cas_lag - 2.0 * delta_time;
                        error = 0.0;
                        landing_slope_integrate = 0.0;
                        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",1.0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",landing_22_alt_start);
                    }
                }
                
                if (landing_22_subStatus == 2) {
                    if (runway_to_airplane_dist_nm_der < 0.0 and delta_h_ft < 200.0) {
                        landing_22_subStatus = 3;
                        setprop("fdm/jsbsim/systems/autopilot/gui/landig-sub-status-id",landing_22_subStatus);
                    } else {
                        pitch_output_error_coefficient_gain = 1.0;
                        delta_slope_rate = 0.10 - 0.09 * (runway_to_airplane_dist_nm / landing_22_subStatus_2_1_dist_nm);
                        landing_22_h_nm = delta_h_ft * 0.000189394;
                        delta_h_vs_dist_ft = - runway_to_airplane_dist_nm * math.tan(landing_22_slope_target_proposed/R2D)/0.000189394;
                        landing_22_slope_adv_size = 20 + 100 * (runway_to_airplane_dist_nm / landing_22_subStatus_2_1_dist_nm);
                        landing_22_slope = - math.atan(landing_22_h_nm / runway_to_airplane_dist_nm_direct_nm) * R2D;
                        if (landing_22_slope_target < (landing_22_slope_target_proposed - 0.1)) landing_22_slope_target = landing_22_slope_target + delta_slope_rate * delta_time;
                        if (landing_22_slope_target > (landing_22_slope_target_proposed + 0.1)) landing_22_slope_target = landing_22_slope_target - delta_slope_rate * delta_time;
                        if (runway_to_airplane_dist_nm > landing_22_subStatus_2_2_dist_nm) {
                            landing_22_set_cas = 155.0 + 25 * impact_ctl_speed_increment_norm;
                            if (landing_22_set_cas > 200.0) landing_22_set_cas = 200.0;
                        } else {
                            ### landing_22_set_cas = 120 + 35.0 * (runway_to_airplane_dist_nm / landing_22_subStatus_2_2_dist_nm);
                            landing_22_set_cas = 120 + 35.0 * (runway_to_airplane_dist_nm / landing_22_subStatus_2_2_dist_nm) + (50.0 * weitght_norm);
                            ku = ku * ( 0.08 + 0.92 * (runway_to_airplane_dist_nm / landing_22_subStatus_2_2_dist_nm));
                            tu = tu * ( 0.5 + 0.5 * (runway_to_airplane_dist_nm / landing_22_subStatus_2_2_dist_nm));
                            gain_landing_mod = gain_landing * ( 0.3 + 0.7 * (runway_to_airplane_dist_nm / landing_22_subStatus_2_2_dist_nm));
                        }
                        if (runway_to_airplane_dist_nm < 1.5) {
                            error = landing_22_slope_target - (landing_22_slope_adv_value * (1 + landing_22_dif_dh_dt_value / 500.0));
                        } else {
                            error = landing_22_slope_target - landing_22_slope_adv_value;
                        }
                        if (landing_22_set_cas_lag < (landing_22_set_cas - 1)) landing_22_set_cas_lag = landing_22_set_cas_lag + 2.0 * delta_time;
                        if (landing_22_set_cas_lag > (landing_22_set_cas + 1)) landing_22_set_cas_lag = landing_22_set_cas_lag - 2.0 * delta_time;
                    }
                }
                
                if (landing_22_subStatus == 3) {
                    if (delta_h_ft > 80) {
                        var delta_slope_rate = 1.0;
                        ### landing_22_set_cas = 115.0 + (20 * weitght_norm);
                        landing_22_set_cas = 125.0 + (50.0 * weitght_norm);
                        pitch_output_error_coefficient_gain = 1.5;
                        landing_22_slope_target_proposed = -2.5 - 1.8 * delta_h_ft / 80.0;
                        if (landing_22_slope_target_proposed < -2.5) landing_22_slope_target_proposed = -2.5;
                        delta_h_vs_dist_ft = delta_h_ft;
                        if (landing_22_set_cas_lag < (landing_22_set_cas - 3)) landing_22_set_cas_lag = landing_22_set_cas_lag + 5.0 * delta_time;
                        if (landing_22_set_cas_lag > (landing_22_set_cas + 3)) landing_22_set_cas_lag = landing_22_set_cas_lag - 5.0 * delta_time;
                        if (landing_22_slope_target < (landing_22_slope_target_proposed - 0.1)) landing_22_slope_target = landing_22_slope_target + delta_slope_rate * delta_time;
                        if (landing_22_slope_target > (landing_22_slope_target_proposed + 0.1)) landing_22_slope_target = landing_22_slope_target - delta_slope_rate * delta_time;
                        landing_22_pitch_slope = landing_22_slope_target;
                        setprop("fdm/jsbsim/systems/autopilot/pitch-output-error-coefficient-gain",pitch_output_error_coefficient_gain);
                        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle-deg",landing_22_slope_target);
                        landing_22_subStatus_error_lag = landing_22_slope_target - landing_22_slope_adv_value;
                        setprop("fdm/jsbsim/systems/autopilot/landing-slope-error",landing_22_subStatus_error_lag);
                        setprop("fdm/jsbsim/systems/autopilot/landing-slope-target",landing_22_slope_target);
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",landing_22_set_cas_lag);
                    } else {
                        landing_22_subStatus = 4;
                        setprop("fdm/jsbsim/systems/autopilot/gui/landig-sub-status-id",landing_22_subStatus);
                    }
                }
                
                if (landing_22_subStatus == 4) {
                    var delta_slope_rate = 0.5;
                    var slope_target_speed = 0.1;
                    if (altitude_agl_ft > 15) {
                        landing_22_slope_target_proposed = -3.0 - 6.0 * altitude_agl_ft / 80.0;
                    } else {
                        slope_target_speed = 0.2;
                        landing_22_slope_target_proposed = -2.5 - 0.8 * altitude_agl_ft / 10.0;
                    }
                    ### landing_22_set_cas = 115.0;
                    landing_22_set_cas = 125.0 + (50.0 * weitght_norm);
                    pitch_output_error_coefficient_gain = 1.5;
                    delta_h_vs_dist_ft = delta_h_ft;
                    if (landing_22_set_cas_lag < (landing_22_set_cas - 3)) landing_22_set_cas_lag = landing_22_set_cas_lag + 5.0 * delta_time;
                    if (landing_22_set_cas_lag > (landing_22_set_cas + 3)) landing_22_set_cas_lag = landing_22_set_cas_lag - 5.0 * delta_time;
                    if (landing_22_slope_target < (landing_22_slope_target_proposed - slope_target_speed)) landing_22_slope_target = landing_22_slope_target + delta_slope_rate * delta_time;
                    if (landing_22_slope_target > (landing_22_slope_target_proposed + slope_target_speed)) landing_22_slope_target = landing_22_slope_target - delta_slope_rate * delta_time;
                    landing_22_pitch_slope = landing_22_slope_target;
                    setprop("fdm/jsbsim/systems/autopilot/pitch-output-error-coefficient-gain",pitch_output_error_coefficient_gain);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle-deg",landing_22_slope_target);
                    landing_22_subStatus_error_lag = landing_22_slope_target - landing_22_slope_adv_value;
                    setprop("fdm/jsbsim/systems/autopilot/landing-slope-error",landing_22_subStatus_error_lag);
                    setprop("fdm/jsbsim/systems/autopilot/landing-slope-target",landing_22_slope_target);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",landing_22_set_cas_lag);
                }
                
                #// Slope ADV for input filter to PID
                landing_22_slope_adv.insert(-1,landing_22_slope);
                var landing_22_slope_adv_dif = landing_22_slope;
                while (landing_22_slope_adv.size() > (landing_22_slope_adv_size / speed_up)) {
                    landing_22_slope_adv_dif = landing_22_slope_adv_dif - landing_22_slope_adv.pop(0);
                }
                landing_22_slope_adv_acc = landing_22_slope_adv_acc + landing_22_slope_adv_dif;
                landing_22_slope_adv_value = landing_22_slope_adv_acc / landing_22_slope_adv.size();
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope",landing_22_slope_adv_value);
                
                var dif_delta_dh_dt = delta_h_ft - delta_h_vs_dist_ft;
                landing_22_dif_dh_dt.insert(-1,dif_delta_dh_dt);
                var landing_22_dif_dh_dt_dif = dif_delta_dh_dt;
                while (landing_22_dif_dh_dt.size() > (landing_22_dif_dh_dt_size / speed_up)) {
                    landing_22_dif_dh_dt_dif = landing_22_dif_dh_dt_dif - landing_22_dif_dh_dt.pop(0);
                }
                landing_22_dif_dh_dt_acc = landing_22_dif_dh_dt_acc + landing_22_dif_dh_dt_dif;
                landing_22_dif_dh_dt_value = landing_22_dif_dh_dt_acc / landing_22_dif_dh_dt.size();
                setprop("fdm/jsbsim/systems/autopilot/landing22-dif-dh-dt",landing_22_dif_dh_dt_value);
                
                if (landing_22_subStatus == 2) {
                    
                    var kp = 0.6 * ku;
                    var ki = 1.2 * ku / tu;
                    var kd = 3 * ku * tu / 40.0;
                    if (kd > 2.5) kd = 2.5;
                    
                    setprop("fdm/jsbsim/systems/autopilot/landing-PID-kp",kp);
                    setprop("fdm/jsbsim/systems/autopilot/landing-PID-ki",ki);
                    setprop("fdm/jsbsim/systems/autopilot/landing-PID-kd",kd);

                    #// PID controller section
                    landing_22_subStatus_error_lag = error;
                    
                    setprop("fdm/jsbsim/systems/autopilot/landing-slope-error",landing_22_subStatus_error_lag);
                    setprop("fdm/jsbsim/systems/autopilot/landing-slope-target",landing_22_slope_target);
                    
                    landing_slope_integrate = landing_slope_integrate + landing_22_subStatus_error_lag * delta_time;
                    derivate = (landing_22_subStatus_error_lag - landing_slope_previous_error) / delta_time;
                    landing_slope_previous_error = landing_22_subStatus_error_lag;
                    
                    #// For testing
                    setprop("fdm/jsbsim/systems/autopilot/landing22-pid-p",(kp * landing_22_subStatus_error_lag));
                    setprop("fdm/jsbsim/systems/autopilot/landing22-pid-i",(ki * landing_slope_integrate));
                    setprop("fdm/jsbsim/systems/autopilot/landing22-pid-d",(kd * derivate));
                    
                    #// PID controller processor
                    landing_22_pitch_slope = landing_22_slope_target - (kp * landing_22_subStatus_error_lag + ki * landing_slope_integrate + kd * derivate) * gain_landing_mod;
                    
                    #// Filter cut function
                    if (landing_22_pitch_slope > 6.0) {
                        landing_22_pitch_slope = 6.0;
                        landing_slope_integrate = 0.0;
                    } else if (landing_22_pitch_slope < -15.0) {
                        landing_22_pitch_slope = -15.0;
                        landing_slope_integrate = 0.0;
                    }
                    
                    #// Impact control gain
                    var impact_elev_intensity = getprop("fdm/jsbsim/systems/autopilot/altitude-QFE-impact-elev-intensity-lag");
                    pitch_output_error_coefficient_gain = pitch_output_error_coefficient_gain + 0.5 * impact_elev_intensity;
                    
                    setprop("fdm/jsbsim/systems/autopilot/landing22-landing-slope",landing_22_pitch_slope);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",landing_22_set_cas_lag);
                    if (getprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active") > 0.5) {
                        #// Collision control is active and operational
                        if (getprop("fdm/jsbsim/systems/autopilot/altitude-QFE-impact-elev-intensity-lag") < 0.2) {
                            setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",0.0);
                            setprop("fdm/jsbsim/systems/autopilot/pitch-output-error-coefficient-gain",pitch_output_error_coefficient_gain);
                            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle",1.0);
                            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle-deg",landing_22_pitch_slope);
                        } else {
                            #// Activate the Collision control system
                            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle",1.0);
                            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle-deg",9.0);
                            setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",1.0);
                            var altitude_hold_ft = runway_alt_m_select * 3.28084 + rwy_offset_v_ft + runway_to_airplane_dist_nm * math.abs(math.tan(landing_22_slope_target / R2D) / 0.000189394);
                            setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",altitude_hold_ft);
                        }
                    } else {
                        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",0.0);
                        setprop("fdm/jsbsim/systems/autopilot/pitch-output-error-coefficient-gain",pitch_output_error_coefficient_gain);
                        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle",1.0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle-deg",landing_22_pitch_slope);
                    }
                }
                
                if (testing_log_active >= 1 and timeStepSecond == 1) {
                    print(
                         sprintf("Landing %2.1f",pilot_ass_status_id)
                        ,sprintf(".%1.0f",landing_22_subStatus)
                        ,sprintf(" Dist: %6.1f",runway_to_airplane_dist_nm_direct_nm)
                        ,sprintf(" %6.2f",runway_to_airplane_dist_nm)
                        ,sprintf(" Der: %2.3f",runway_to_airplane_dist_nm_der)
                        ,sprintf(" Dh: %5.0f",delta_h_ft)
                        ,sprintf(" dt: %5.0f ",delta_h_vs_dist_ft)
                        ,sprintf(" agl: %5.0f",altitude_agl_ft)
                        ,sprintf(" Slp: %4.2f",landing_22_pitch_slope)
                        ,sprintf(" PID sl: %4.2f ",landing_22_slope_adv_value)
                        ,sprintf(" stp %4.2f ",landing_22_slope_target_proposed)
                        ,sprintf(" st %4.2f ",landing_22_slope_target)
                        ,sprintf(" Er: %5.2f ",landing_22_subStatus_error_lag)
                        #,sprintf(" ku %4.2f",ku)
                        #,sprintf(" tu %4.2f",tu)
                        #,sprintf(" kp %4.2f",kp)
                        #,sprintf(" ki %4.2f",ki)
                        #,sprintf(" kd %4.2f",kd)
                        #,sprintf(" [%4.2f",- getprop("fdm/jsbsim/systems/autopilot/pitch-angle-absolute-deg-lag"))
                        #,sprintf(" |%4.2f]",landing_22_slope_dif_adv)
                        #,sprintf(" I %4.2f ",landing_slope_integrate)
                        #,sprintf(" D %4.2f ",derivate)
                        #,sprintf(" | %4.1f ",landing_22_discending_ftm)
                        #,sprintf(" %1.2f ",weitght_norm)
                        #,sprintf(" %2.3f",min_to_term)
                        ,sprintf(" Hd: %5.1f",heading_correct)
                        ,sprintf(" cr: %5.2f",heading_correction_deg)
                        ,sprintf(" fct: %2.1f",heading_factor)
                        ,sprintf(" Hcdm: %3.2f",heading_correction_deg_mod)
                        #,sprintf(" Dis: %4.1f",distance_to_leave)
                        #,sprintf(" off: %1.2f",rwy_offset_h_nm)
                        #,sprintf(" | %3.1f",rwy_offset_v_ft)
                        ,sprintf(" CAS: %3.0f",speed_cas)
                        ,sprintf(" | %3.0f",landing_22_set_cas)
                        ,sprintf(" | %3.0f",landing_22_set_cas_lag)
                        #,sprintf(" wd: %3.1f",wind_frontal)
                        #,sprintf(" | %3.1f",wind_lateral)
                        ,sprintf(" Thr: pid %2.2f",getprop("fdm/jsbsim/systems/autopilot/speed-throttle-pid-gain"))
                        ,sprintf(" | %2.2f",getprop("fdm/jsbsim/systems/autopilot/speed-pid-output-throttle"))
                        ,sprintf(" |stm %2.2f",getprop("fdm/jsbsim/systems/autopilot/speed-throttle-max"))
                        ,sprintf(" |sti %4.1f",getprop("fdm/jsbsim/systems/autopilot/speed-throttle-imposed"))
                        ,sprintf(" |sd %4.2f",getprop("fdm/jsbsim/systems/autopilot/speed-difference"))
                        ,sprintf(" Gl: %2.2f",gain_landing)
                        ,sprintf(" | %2.2f",gain_landing_mod)
                        #,sprintf(" DT: %1.2f",delta_time)
                        #,sprintf(" | %2.1f",timeStepDivisor)
                        ,sprintf(" Imp: %1.0f",getprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active"))
                        ,sprintf(" | %1.0f",getprop("fdm/jsbsim/systems/autopilot/altitude-QFE-impact-elev-intensity-active"))
                        ,sprintf(" | %1.0f",getprop("fdm/jsbsim/systems/autopilot/altitude-hold-limitator-active"))
                        ,sprintf(" . %1.0f",getprop("fdm/jsbsim/systems/autopilot/pitch-angle-active"))
                        ,sprintf(" | %1.0f",getprop("fdm/jsbsim/systems/autopilot/vertical-speed-active"))
                        ,sprintf(" | %1.0f",getprop("fdm/jsbsim/systems/autopilot/altitude-hold-active"))
                        ,sprintf(" . %1.0f",getprop("fdm/jsbsim/systems/autopilot/altitude-hold-QFE-active"))
                        ,sprintf(" | %5.0f",getprop("fdm/jsbsim/systems/autopilot/altitude-QFE-impact-elev-ft-lag"))
                        ,sprintf(" | %2.1f",getprop("fdm/jsbsim/systems/autopilot/altitude-QFE-impact-elev-intensity-lag"))
                    );
                }
            } else {
                pilot_ass_status_id = 3.0;
                setprop("fdm/jsbsim/systems/autopilot/gui/landig-sub-status-id",0);
                landing_30_brake_stop = 0;
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",0.0);
                setprop("fdm/jsbsim/systems/autopilot/altitude-QFE-active",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle-deg",-9.0);
                setprop("fdm/jsbsim/systems/autopilot/landing-slope-target",-9.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",30.0);
                setprop("fdm/jsbsim/systems/autopilot/steer-brake-active",2);
                setprop("fdm/jsbsim/systems/dragchute/activate",1.0);
                setprop("fdm/jsbsim/systems/autopilot/phase-landing",2.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-flap",1.0);
                setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",1.0);
                if (getprop("fdm/jsbsim/systems/autopilot/gui/landing-short-profile") > 0.0) {
                    setprop("fdm/jsbsim/systems/dragchute/activate",1.0);
                }
                rwy_coord_end_offset = airport_select.runways[rwy_select].length;
                if (rwy_coord_end_offset > 1000.0) rwy_coord_end_offset = 1000.0;
                rwy_coord_end.apply_course_distance(airport_select.runways[rwy_select].heading,rwy_coord_end_offset);
            }
        } else if (pilot_ass_status_id == 3.0) {
            setprop("fdm/jsbsim/systems/autopilot/altitude-QFE-set-active-stop",1);
            setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",1);
            if (getprop("fdm/jsbsim/systems/autopilot/speed-true-on-air") < 35.0) {
                pilot_ass_status_id = 4;
                landing_40_brake_stop = 0;
                setprop("fdm/jsbsim/systems/autopilot/gui/landig-sub-status-id",0);
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle-deg",0.0);
                setprop("fdm/jsbsim/systems/autopilot/landing-slope-target",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",0.0);
                setprop("fdm/jsbsim/systems/autopilot/steer-brake-active",2);
                setprop("fdm/jsbsim/systems/autopilot/speed-throttle-imposed",0.1);
                setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-open",1.0);
                setprop("fdm/jsbsim/systems/autopilot/phase-landing",2.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/wing-leveler",0.0);
                setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",1.0);
                defaultViewInTheEvent = nil;
                delayCycleGeneral = 50;
                slope = 0.0;
                rwy_coord_end_offset = airport_select.runways[rwy_select].length;
                rwy_coord_end.apply_course_distance(airport_select.runways[rwy_select].heading,rwy_coord_end_offset);
            } else {
                var rwy_coord_end_final = geo.Coord.new();
                rwy_coord_end_final.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon,rwy_offset_v_ft * 3.28084);
                rwy_coord_end_final.apply_course_distance(airport_select.runways[rwy_select].heading,(runway_to_airplane_dist_nm_direct_nm * 1852.0 + airport_select.runways[rwy_select].length));
                var heading_correction_deg_mod = (airport_select.runways[rwy_select].heading - airplane.course_to(rwy_coord_end));
                if (heading_correction_deg_mod > 180) heading_correction_deg_mod = heading_correction_deg_mod - 360;
                if (heading_correction_deg_mod < -180) heading_correction_deg_mod = heading_correction_deg_mod + 360;
                var heading_factor = 1 / math.log10(1.05 + math.abs(heading_correction_deg_mod));
                heading_correct = airport_select.runways[rwy_select].heading - heading_correction_deg_mod * heading_factor;
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
                setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-open",1.0);
                if (landing_30_brake_stop == 0) {
                    if (runway_end_to_airplane_dist < 0.3 and getprop("fdm/jsbsim/velocities/vtrue-kts") > 10 and getprop("fdm/jsbsim/systems/autopilot/gui/landing-short-profile") > 0.0) {
                        setprop("/controls/gear/brake-parking",1);
                        landing_30_brake_stop = 1;
                    }
                }
                #// Dragchute activate
                if (gear_unit_contact >= 2 and getprop("fdm/jsbsim/systems/dragchute/status") == 0.0) {
                    setprop("fdm/jsbsim/systems/handle-switches/sw-handle-brake-activate",1);
                }
                #// Dragchute camera view
                if (getprop("fdm/jsbsim/systems/dragchute/active-view") > 0.01 and defaultViewInTheEvent == nil) {
                    defaultViewInTheEvent = view.index;
                    view.setView(view.indexof("Dragchute view"));
                }
                if (testing_log_active >= 1 and timeStepSecond == 1) {
                    print("Landing 3.0 >"
                    ,sprintf(" Dist (nm): %6.1f",runway_to_airplane_dist_nm)
                    ,sprintf(" | %6.1f",runway_end_to_airplane_dist)
                    ,sprintf(" Heading: %7.1f",heading_correct)
                    ,sprintf(" H. cor: %6.2f",heading_correction_deg_mod)
                    ,sprintf(" H. factor: %6.2f",heading_factor)
                    ,sprintf(" Gear contact: %.0f",gear_unit_contact)
                    ,sprintf(" Gear brake antiskid: %6.2f",getprop("fdm/jsbsim/systems/autopilot/steer-brake-antiskid"))
                    ,sprintf(" heading norm: %6.2f",getprop("fdm/jsbsim/systems/autopilot/true-heading-deg-delta-norm"))
                    ,sprintf(" (%6.0f kts)",getprop("fdm/jsbsim/velocities/vtrue-kts"))
                    ,sprintf(" left int: %6.2f",getprop("fdm/jsbsim/systems/brake/left-steer-brake-intensity"))
                    ,sprintf(" (%6.2f)",getprop("fdm/jsbsim/systems/autopilot/left-steer-brake"))
                    ,sprintf(" right int: %6.2f",getprop("fdm/jsbsim/systems/brake/right-steer-brake-intensity"))
                    ,sprintf(" (%6.2f)",getprop("fdm/jsbsim/systems/autopilot/right-steer-brake"))
                    ,sprintf(" Dragchute: %0f",getprop("fdm/jsbsim/systems/dragchute/magnitude"))
                    ,sprintf(" | BS: %1.0f",getprop("/controls/gear/brake-parking"))
                    );
                }
            }
        } else if (pilot_ass_status_id == 4.0) {
            setprop("fdm/jsbsim/systems/autopilot/altitude-QFE-set-active-stop",1);
            setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",1);
            var rwy_coord_end_final = geo.Coord.new();
            rwy_coord_end_final.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon,rwy_offset_v_ft * 3.28084);
            rwy_coord_end_final.apply_course_distance(airport_select.runways[rwy_select].heading,(runway_to_airplane_dist_nm_direct_nm * 1852.0 + airport_select.runways[rwy_select].length));
            var heading_correction_deg_mod = (airport_select.runways[rwy_select].heading - airplane.course_to(rwy_coord_end));
            if (heading_correction_deg_mod > 180) heading_correction_deg_mod = heading_correction_deg_mod - 360;
            if (heading_correction_deg_mod < -180) heading_correction_deg_mod = heading_correction_deg_mod + 360;
            var heading_factor = 1 / math.log10(1.05 + math.abs(heading_correction_deg_mod));
            heading_correct = airport_select.runways[rwy_select].heading - heading_correction_deg_mod * heading_factor;
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
            setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",1.0);
            if (landing_40_brake_stop == 0) {
                if (runway_end_to_airplane_dist < 0.3 and getprop("fdm/jsbsim/velocities/vtrue-kts") > 10 and getprop("fdm/jsbsim/systems/autopilot/gui/landing-short-profile") > 0.0) {
                    setprop("/controls/gear/brake-parking",1);
                    landing_40_brake_stop = 1;
                }
            }
            delayCycleGeneral = delayCycleGeneral - 1;
            if (delayCycleGeneral <= 0) {
                pilot_ass_status_id = 0;
                setprop("fdm/jsbsim/systems/autopilot/gui/heading-control",0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-active",0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-control",0);
            }
            if (testing_log_active >= 1 and timeStepSecond == 1) {
                print("Landing 4.0 >"
                ,sprintf(" Dist (nm): %6.1f",runway_to_airplane_dist_nm)
                ,sprintf(" | %6.1f",runway_end_to_airplane_dist)
                ,sprintf(" Heading: %7.1f",heading_correct)
                ,sprintf(" H. cor: %6.1f",heading_correction_deg_mod)
                ,sprintf(" Gear contact: %.0f",gear_unit_contact)
                ,sprintf(" Gear brake antiskid: % 6.2f",getprop("fdm/jsbsim/systems/autopilot/steer-brake-antiskid"))
                ,sprintf(" heading norm: %6.2f",getprop("fdm/jsbsim/systems/autopilot/true-heading-deg-delta-norm"))
                ,sprintf(" (%6.0f kts)",getprop("fdm/jsbsim/velocities/vtrue-kts"))
                ,sprintf(" left int: %6.2f",getprop("fdm/jsbsim/systems/brake/left-steer-brake-intensity"))
                ,sprintf(" (%6.2f)",getprop("fdm/jsbsim/systems/autopilot/left-steer-brake"))
                ,sprintf(" right int: %6.2f",getprop("fdm/jsbsim/systems/brake/right-steer-brake-intensity"))
                ,sprintf(" (%6.2f)",getprop("fdm/jsbsim/systems/autopilot/right-steer-brake"))
                ,sprintf(" | BS: %1.0f",getprop("/controls/gear/brake-parking"))
                );
            }
        }
        #
        #// Output
        #
        var landing_status = airport_select.id ~ " | " ~ airport_select.name ~ " | " ~ airport_select.runways[rwy_select].id;
        if (pilot_ass_status_id == 1) {
            landing_status = "Airport found " ~ landing_status;
        } else if (pilot_ass_status_id == 2)  {
            landing_status = "Airport to land " ~ landing_status;
        } else if (pilot_ass_status_id == 2.1) {
            landing_status = "Airport approach " ~ landing_status;
        } else if (pilot_ass_status_id == 2.2) {
            landing_status = "Airport final " ~ landing_status;
        } else if (pilot_ass_status_id == 2.5)  {
            landing_status = "Final landing " ~ landing_status;
        } else if (pilot_ass_status_id == 3) {
            landing_status = "Landed " ~ landing_status;
        } else if (pilot_ass_status_id == 4) {
            landing_status = "Stopping " ~ landing_status;
        } else {
            landing_status = "Stopped " ~ landing_status;
        }
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_landing_status",landing_status);
    } else {
        #// No landing
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope",0.0);
    }
    
    #// Jato system
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
    
    if (pilot_ass_status_id >= 10.0 and pilot_ass_status_id < 11.0) {
        if (isAirport_and_rw_selected == 1) {
            isAirport_and_rw_selected = -1;
            isAirport_airport_id_save = airport_select;
            isAirport_airport_rw_save = rwy_select;
        }
        var heading_correction_deg = 0.0;
        var heading_correct = 0.0;
        var gear_unit_contact = getprop("fdm/jsbsim/context/gears/on-ground");
        var runway_to_airplane_dist_nm = 0;
        var departure_msg = "";
        setprop("fdm/jsbsim/systems/autopilot/altitude-QFE-set-active-stop",1);
        
        #// Normal departure procedure
        if (pilot_ass_status_id == 10.0) {
            var apt_coord = geo.Coord.new();
            airport_select = nil;
            var heading_true_deg = getprop("fdm/jsbsim/systems/autopilot/heading-true-deg");
            var apt_id = getprop("sim/airport/closest-airport-id");
            var rwy_coord = geo.Coord.new();
            var distance_to_airport_min = 9999.0;
            if (airplane != nil and apt_id != nil) {
                var airport = airportinfo(apt_id);
                #// Select the airport in the frontal direction
                apt_coord.set_latlon(airport.lat,airport.lon);
                foreach(var rwy; keys(airport.runways)) {
                    print("Departure 10.0 > Airport is select: ",airport.id,
                        " ",airport.runways[rwy].id,
                        " ",airport.runways[rwy].length);
                    #// Select the runway lenght
                    if (airport.runways[rwy].length >= 1.0) {
                        rwy_coord.set_latlon(airport.runways[rwy].lat,airport.runways[rwy].lon);
                        runway_to_airplane_dist_nm = airplane.distance_to(rwy_coord) * 0.000621371;
                        #// Search the rwy with minimal condition
                        if (distance_to_airport_min > runway_to_airplane_dist_nm) {
                            distance_to_airport_min = runway_to_airplane_dist_nm;
                            airport_select = airport;
                            rwy_select = rwy;
                        }
                    }
                }
            }
            
            if (airport_select != nil) {
                if (testing_level >= 1) {
                    #// Bypass the switch-on phase
                    pilot_ass_status_id = 10.1;
                } else {
                    pilot_ass_status_id = 10.1;
                }
                if (airport_select.runways[rwy_select].length < 1500.0) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/take-off-jato-active",1);
                } else {
                    setprop("fdm/jsbsim/systems/autopilot/gui/take-off-jato-active",0);
                }
            }

            setprop("fdm/jsbsim/systems/starter/gui/autostart-activate",1);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",1.0);
            setprop("fdm/jsbsim/systems/handle-switches/sw-handle-brake-activate",1);
        } else if (pilot_ass_status_id == 10.1) {
            departure_msg = "Motor and electric starting";
            print("Departure 10.1 > Motor and electric starting phase");
            if (getprop("fdm/jsbsim/systems/starter/gui/autostart-status-is-ok") == 1) {
                pilot_ass_status_id = 10.2;
            }
            #// Oxigen refill, is faster and non in logical sequence, but is only for initialize the Oxygen system
            setprop("fdm/jsbsim/systems/oxygen/cylinder-refilled-flow-rate",20);
            setprop("fdm/jsbsim/systems/oxygen/pilot-loss-of-consciousness-blackout-active",1);
        } else if (pilot_ass_status_id == 10.2) {
            departure_msg = "Motor acc. N2:" ~ sprintf(" %3.0f",getprop("fdm/jsbsim/propulsion/engine[0]/n2"));
            print("Departure 10.2 > ", departure_msg);
            setprop("fdm/jsbsim/systems/starter/gui/autostart-activate",0);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-control",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-throttle",0.0);
            setprop("/controls/flight/flaps",0.33);
            setprop("fdm/jsbsim/systems/autopilot/speed-throttle-imposed",0.97);
            setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",1.0);
            if (getprop("fdm/jsbsim/propulsion/engine[0]/n2") > 85 
                and getprop("fdm/jsbsim/systems/gauges/cockpit-jet-temperature-display-C") > 680.0) {
                pilot_ass_status_id = 10.3;
                heading_target_active = 0;
                heading_target = 0.0;
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle-deg",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/heading-control",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/wing-leveler",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/rudder-auto-coordination",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-active",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",10000.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-pitch",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",250.0);
                setprop("fdm/jsbsim/systems/autopilot/steer-brake-active",1);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-flap",0.0);
                setprop("fdm/jsbsim/systems/handle-switches/sw-handle-brake-release",1);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",1.0);
                setprop("fdm/jsbsim/systems/autopilot/phase-landing",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",0.0);
                setprop("fdm/jsbsim/systems/autopilot/phi-heading-suspended",1.0);
            }
        } else if (pilot_ass_status_id >= 10.3 and pilot_ass_status_id <= 10.39) {
            var altitude_agl_ft = getprop("/position/altitude-agl-ft");
            if (pilot_ass_status_id == 10.3) {
                if (airport_select == nil) {
                    heading_target_active = 1;
                    heading_target = getprop("fdm/jsbsim/systems/autopilot/heading-true-deg");
                    rwy_coord_end_offset = 3000.0;
                    var ac_pos = geo.aircraft_position();
                    rwy_coord_end.set_latlon(ac_pos.lat(),ac_pos.lon());
                    rwy_coord_end.apply_course_distance(getprop("fdm/jsbsim/systems/autopilot/heading-true-deg"),rwy_coord_end_offset);
                    pilot_ass_status_id = 10.31
                } else {
                    rwy_coord_end_offset = airport_select.runways[rwy_select].length;
                    rwy_coord_end.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon);
                    heading_target_active = 1;
                    heading_target = airport_select.runways[rwy_select].heading;
                    rwy_coord_end.apply_course_distance(heading_target,rwy_coord_end_offset);
                    pilot_ass_status_id = 10.32
                }
            }
            runway_to_airplane_dist_nm = airplane.distance_to(rwy_coord_end) * 0.000621371;
            if (gear_unit_contact > 0) {
                heading_correction_deg = (heading_target - airplane.course_to(rwy_coord_end));
            } else {
                heading_correction_deg = 0.0;
            }
            var heading_factor = 1 / math.log10(1.05 + math.abs(heading_correction_deg));
            heading_correct = heading_target - heading_correction_deg * heading_factor;
            var speed_cas = getprop("fdm/jsbsim/systems/autopilot/speed-cas-on-air");
            var isJatoOn = getprop("fdm/jsbsim/systems/jato/combustion-on");
            var isJatoActive = getprop("fdm/jsbsim/systems/autopilot/gui/take-off-jato-active");
            var factorGain = 0.0;
            var pitchDeg = 0.0;
            setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
            setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
            setprop("fdm/jsbsim/systems/autopilot/steer-brake-active",1);
            setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-deactivate",1.0);
            if (isJatoActive == 1 and altitude_agl_ft > 10.0) {
                setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-close",1.0);
            }
            
            if (pilot_ass_status_id == 10.32) {
                pilot_ass_status_id = 10.33;
            }

            if (pilot_ass_status_id == 10.33) {
                if (speed_cas >= 130.0 or runway_to_airplane_dist_nm < 0.2) {
                    pilot_ass_status_id = 10.34;
                } else {
                    if (isJatoActive == 1) {
                        factorGain = 10.0;
                        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle",0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle-deg",10.0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1);
                        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",-2000.0);
                    } else {
                        factorGain = 10.0;
                        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle",0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle-deg",6.0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1);
                        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",-1000.0);
                    }
                }
            }

            if (pilot_ass_status_id == 10.34) {
                if (altitude_agl_ft > 10.0) {
                    pilot_ass_status_id = 10.35;
                } else {
                    if (isJatoActive == 1) {
                        factorGain = 1.0 + 2.0 * getprop("fdm/jsbsim/systems/jato/thrust-lbs-total") / 4000.0;
                        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle",0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle-deg",10.0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1);
                        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",100.0 * (speed_cas - 50.0) / 50.0);
                    } else {
                        var weitght_norm = getprop("fdm/jsbsim/inertia/weight-lbs") / 10000.0;
                        factorGain = 1.5;
                        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle",0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle-deg",6.0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1);
                        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",3500.0 * weitght_norm * weitght_norm);
                    };
                }
            }
            
            if (pilot_ass_status_id == 10.35) {
                if (altitude_agl_ft > 30.0) {
                    pilot_ass_status_id = 10.36;
                } else {
                    setprop("fdm/jsbsim/systems/autopilot/speed-throttle-imposed",0.95);
                    if (isJatoActive == 1) {
                        factorGain = 0.0;
                        setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-close",1.0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle",0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle-deg",10.0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1);
                        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",150.0 * (speed_cas - 50.0) / 50.0);
                    } else {
                        factorGain = 0.0;
                        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle",0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle-deg",6.0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1);
                        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",2500.0);
                    }
                }
            }
            
            if (pilot_ass_status_id == 10.36) {
                if (altitude_agl_ft > 1000.0) {
                    pilot_ass_status_id = 10.5;
                    factorGain = 0.0;
                    setprop("fdm/jsbsim/systems/autopilot/speed-throttle-imposed",-1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-control",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-throttle",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
                    setprop("/controls/flight/flaps",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/phi-heading-suspended",0.0);
                } else {
                    factorGain = 0.0;
                    if (altitude_agl_ft > 500.0) {
                        setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-close",1.0);
                    }
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle",0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle-deg",6.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1);
                    setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",2500.0);
                }
            }
            
            setprop("fdm/jsbsim/systems/autopilot/pitch-output-error-coefficient-gain",factorGain);
            
            if (testing_log_active >= 1 and timeStepSecond == 1) {
                print(sprintf("Departure %2.2f > ",pilot_ass_status_id)
                ,sprintf(" Dist to end (nm): %6.1f",runway_to_airplane_dist_nm)
                ,sprintf(" Heading: %7.1f",heading_correct)
                ,sprintf(" cor: %6.1f",heading_correction_deg)
                ,sprintf(" norm: %6.2f",getprop("fdm/jsbsim/systems/autopilot/true-heading-deg-delta-norm"))
                ,sprintf(" Gear cnt: %.0f",gear_unit_contact)
                ,sprintf(" ABS: %6.2f",getprop("fdm/jsbsim/systems/autopilot/steer-brake-antiskid"))
                ,sprintf(" (%6.0f kts)",getprop("fdm/jsbsim/velocities/vtrue-kts"))
                ,sprintf(" left int: %6.2f",getprop("fdm/jsbsim/systems/brake/left-steer-brake-intensity"))
                ,sprintf(" (%6.2f)",getprop("fdm/jsbsim/systems/autopilot/left-steer-brake"))
                ,sprintf(" right int: %6.2f",getprop("fdm/jsbsim/systems/brake/right-steer-brake-intensity"))
                ,sprintf(" (%6.2f)",getprop("fdm/jsbsim/systems/autopilot/right-steer-brake"))
                ,sprintf(" Alt agl: %4.0f",altitude_agl_ft)
                ,sprintf(" Pitch: %3.1f",getprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle-deg"))
                ,sprintf(" | %2.0f",getprop("fdm/jsbsim/systems/autopilot/pitch-reset-integrator"))
                ,sprintf(" fcs/pitch-deg: %2.2f",getprop("fdm/jsbsim/fcs/pitch-deg"))
                ,sprintf(" | %2.2f",getprop("fdm/jsbsim/fcs/pitch-autopilot-rapid-rad-lag") * 57.2958)
                ,sprintf(" Pitch deg: %2.1f",pitchDeg)
                ,sprintf(" | %1.2f",factorGain)
                );
            }
        } else if (pilot_ass_status_id == 10.5) {
            var cas_on_air_lag = getprop("fdm/jsbsim/systems/autopilot/speed-cas-on-air-lag");
            var altitude_agl_ft = getprop("/position/altitude-agl-ft");
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle-deg",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/pitch-alpha",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",2500.0);
            if (altitude_agl_ft >= 1500.0 and cas_on_air_lag > 130.0) {
                #// Take-Off procedure end
                setprop("fdm/jsbsim/systems/oxygen/oxygen-supply-togle",1);
                if (getprop("fdm/jsbsim/systems/autopilot/gui/take-off-altitude-top-active") > 0) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/altitude-QFE",0.0);
                    if (isAirport_and_rw_selected == -1) {
                        altitude_top_select = getprop("fdm/jsbsim/systems/autopilot/gui/take-off-altitude-top");
                    } else {
                        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",getprop("fdm/jsbsim/systems/autopilot/gui/take-off-altitude-top"));
                    }
                    setprop("fdm/jsbsim/systems/autopilot/gui/take-off-altitude-top-active",0.0);
                } else {
                    if (getprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft") < 10000.0) setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",10000.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",1.0);
                }
                if (getprop("fdm/jsbsim/systems/autopilot/gui/take-off-to-heading-active") > 0) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/true-heading",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",getprop("fdm/jsbsim/systems/autopilot/gui/take-off-to-heading"));
                    setprop("fdm/jsbsim/systems/autopilot/gui/take-off-to-heading-active",0.0);
                } else if (heading_target_active == 1) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_target);
                } else {
                    setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",math.round(getprop("fdm/jsbsim/systems/autopilot/heading-true-deg")));
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
                } else {
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-control",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",250.0);
                }
                heading_target_active = 0;
                heading_target = 0.0;
                if (isAirport_and_rw_selected == -1) {
                    airport_select = isAirport_airport_id_save;
                    rwy_select = isAirport_airport_rw_save;
                    speed_select = getprop("fdm/jsbsim/systems/autopilot/gui/take-off-cruise-speed");
                    pilot_ass_status_id = 1.0;
                    landing_activate_status = 1;
                    setprop("fdm/jsbsim/systems/autopilot/gui/landing-scan-airport",0);
                } else {
                    pilot_ass_status_id = -1.0;
                    altitude_top_select = -1.0;
                    speed_select = -1.0;
                }
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",0.0);
                setprop("fdm/jsbsim/systems/autopilot/speed-best-by-altitude-set",1.0);
            }
        }
        #
        #// Output
        #
        var take_off_status = "";
        if (pilot_ass_status_id >= 10.1) {
            if (airport_select == nil) {
                take_off_status = "[No airport] " ~ departure_msg;
            } else {
                take_off_status = "[" ~ airport_select.id ~ "|" ~ airport_select.runways[rwy_select].id ~ "] " ~ departure_msg ~ sprintf(" (%2.2f) ",pilot_ass_status_id);
            }
        }
        if (pilot_ass_status_id == 10) {
            take_off_status = "Search airport";
        } else if (pilot_ass_status_id == 10.1)  {
            take_off_status = "Swich on " ~ take_off_status;
        } else if (pilot_ass_status_id == 10.2)  {
            take_off_status = "Swich on " ~ take_off_status;
        } else if (pilot_ass_status_id >= 10.30 and pilot_ass_status_id <= 10.39)  {
            take_off_status = "Leave airport " ~ take_off_status;
        } else if (pilot_ass_status_id == 10.5) {
            take_off_status = "Take off completed";
        } else {
            take_off_status = "Take off inactive";
        }
        setprop("fdm/jsbsim/systems/autopilot/gui/take-off-status",take_off_status);
    }
    
    if (pilot_ass_status_id >= 11.0 and pilot_ass_status_id < 12.0) {
        #// Self-piloting by air interception
        #// From https://forum.flightgear.org/viewtopic.php?f=71&t=23299&sid=81e474c9d78a5ed150627461cbf37d44&start=15
        if (pilot_ass_status_id == 11) {
            #// Select the target
            setprop("fdm/jsbsim/systems/autopilot/gui/landig-sub-status-id",11);
            setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active",1);
        }
    }
    
    if (pilot_ass_status_id == 0) {
        #// Stop the landing-departure phase
        pilot_ass_status_id = -1;
        airport_select = nil;
        airport_select_id_direct = nil;
        altitude_top_select = -1.0;
        speed_select = -1.0;
        landing_30_brake_stop = 0;
        landing_40_brake_stop = 0;
        #// Reset the landing data
        setprop("fdm/jsbsim/systems/autopilot/gui/landig-sub-status-id",0);
        setprop("fdm/jsbsim/systems/autopilot/gui/heading-control",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/wing-leveler",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",2500.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-active",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-QFE",0.0);
        if (getprop("fdm/jsbsim/systems/autopilot/h-sl-ft-lag") > getprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft")) {
            setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",math.round(getprop("fdm/jsbsim/systems/autopilot/h-sl-ft-lag")));
        }
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-control",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-throttle",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-pitch",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",getprop("fdm/jsbsim/systems/autopilot/speed-cas-on-air"));
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-brake",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-flap",0.0);
        setprop("fdm/jsbsim/systems/autopilot/speed-throttle-imposed",-1.0);
        setprop("fdm/jsbsim/systems/autopilot/phase-landing",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",1.0);
        setprop("fdm/jsbsim/systems/autopilot/steer-brake-active",0);
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
        setprop("fdm/jsbsim/systems/autopilot/speed-best-by-altitude-set",0.0);
        setprop("fdm/jsbsim/systems/autopilot/phi-heading-suspended",0.0);
    }
    setprop("fdm/jsbsim/systems/autopilot/gui/landig-status-id",pilot_ass_status_id);

};


setlistener("fdm/jsbsim/systems/autopilot/gui/landing-activate", func {
    print("### B0 vertical-speed: ", getprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed"));
    if (getprop("fdm/jsbsim/systems/autopilot/gui/landing-activate") == 1) {
        if (pilot_ass_status_id <= 0) {
            pilot_ass_status_id = 1;
        } else if (pilot_ass_status_id == 1 and isAirport_and_rw_selected == 1 and landing_activate_status == 0) {
            landing_activate_status = 1;
        } else {
            landing_activate_status = 0;
            pilot_ass_status_id = 0;
        }
        take_off_activate_status = 0;
    }
    setprop("fdm/jsbsim/systems/autopilot/gui/landing-activate",0);
    setprop("fdm/jsbsim/systems/autopilot/gui/landing-activate-status",landing_activate_status);
    print("### B1 vertical-speed: ", getprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed"));
}, 1, 0);


setlistener("fdm/jsbsim/systems/autopilot/gui/take-off-activate", func {
    if (getprop("fdm/jsbsim/systems/autopilot/gui/take-off-activate") == 1) {
        if (pilot_ass_status_id <= 10 or pilot_ass_status_id >= 11) {
            pilot_ass_status_id = 10;
        } else {
            take_off_activate_status = 0;
            pilot_ass_status_id = 0;
        }
        landing_activate_status = 0;
    }
    setprop("fdm/jsbsim/systems/autopilot/gui/take-off-activate",0);
}, 1, 0);


setlistener("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/status", func {
    if (getprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/status") == 1) {
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_system_selector",0);
        setprop("fdm/jsbsim/systems/autopilot/gui/landing-scan-airport",0);
        if (getprop("fdm/jsbsim/systems/autopilot/gui/landing-scan-airport") == 1 and airport_select != nil) {
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_name_direct",airport_select.id);
            airport_select_id_direct = nil;
        } else {
            var airport_name = string.uc(getprop("fdm/jsbsim/systems/autopilot/gui/airport_select_name_direct"));
            if (size(airport_name) == 4) {
                airport_select_id_direct = nil;
                var airport = airportinfo(airport_name);
                if (airport != nil) {
                    var rwy = runway_finder(airport,1);
                    var distance = runway_to_airplane_dist(airport,rwy);
                    var maxDistance = getprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct_max_distance");
                    if (distance <= maxDistance) {
                        airport_select_id_direct = airport;
                        pilot_ass_status_id = 1.0;
                        if (getprop("fdm/jsbsim/systems/autopilot/gui/airport_select_name_direct") != airport_select_id_direct.id) {
                            setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_name_direct",airport_select_id_direct.id);
                        }
                        setprop("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw_select",0);
                    } else {
                        setprop("fdm/jsbsim/systems/autopilot/gui/airport_landing_status",sprintf("Airport too far %4.0f",distance) ~ sprintf(" the maximum range is %4.0f",maxDistance));
                    }
                }
            } else {
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_landing_status","");
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
        elev = dist * 0.105 * 6076.12; #// tan(4.0) deg
        setprop("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-h-ft",elev);
    }
    setprop("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-slope",4.0);
}, 1, 0);
    

setlistener("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-h-ft", func {
    var dist = getprop("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-dist-nm");
    var elev = getprop("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-h-ft");
    holding_point_slope_imposed = math.atan((elev / 6076.12) / dist)*R2D;
    if (holding_point_slope_imposed > 5.0) {
        dist = (elev / 6076.12) * 9.514; #// tan(86.0) deg
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


setlistener("fdm/jsbsim/systems/autopilot/gui/interception-control-active", func {
    var interception_active = getprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active");
    if (interception_active == 1) {
        pilot_ass_status_id = 11;
    } else {
        pilot_ass_status_id = -1;
    }
}, 1, 0);


var pilot_assistant_control = func() {

    if ((pilot_ass_status_id >= 2 and pilot_ass_status_id < 4) or (pilot_ass_status_id >= 10.3 and pilot_ass_status_id < 11.0)) {
        timeStepDivisor = 10;
    } else if (pilot_ass_status_id >= 10.0 and pilot_ass_status_id < 10.3) {
        timeStepDivisor = 2;
    } else if (pilot_ass_status_id >= 4 and pilot_ass_status_id < 5.0) {
        timeStepDivisor = 3;
    } else {
        timeStepDivisor = 1;
    }
    
    delta_time = (timeStep / timeStepDivisor) * speed_up;
    pilot_assistantTimer.restart(timeStep / timeStepDivisor);

    pilot_assistant();
    
    if (timeStepSecond == 1) timeStepSecond = 0;

}

var pilot_assistantTimer = maketimer(timeStep, pilot_assistant_control);
pilot_assistantTimer.singleShot = 1;
pilot_assistantTimer.start();

var pilot_imp_timerLog = maketimer(1, func() {timeStepSecond = 1;});
pilot_imp_timerLog.start();

