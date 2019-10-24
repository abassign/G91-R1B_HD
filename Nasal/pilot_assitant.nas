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
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-rwy-v-offset-ft", 0.0, "DOUBLE");
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

var d2r = 0.0174533;
var landing_activate_status = 0;
var take_off_activate_status = 0;
var take_off_jato_active = 0.0;
var airport_select = nil;
var rwy_select = nil;
var altitude_top_select = -1.0;
var speed_select = -1.0;

var airplane = nil;
var slope = nil;
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
var landing_landing_22_slope_target = 0.0;
var landing_landing_22_slope_target_old = 0.0;
var landing_landing_22_slope_target_step = 0;
var landing_22_slope_target_increment = 0.0;
var landing_slope_integrate = 0.0;
var landing_slope_previous_error = 0.0;
var airplane_to_holding_point_alt = 0.0;
var runway_to_airplane_dist_direct_nm_mem = 0.0;
var runway_to_airplane_dist = 0.0;
var runway_to_airplane_dist_der = 0.0;
var landing_20_dist_to_reduce_h = 0;
var landing_20_skip_to_22 = 0;
var landing_22_slope_target = 0.0;
var landing_22_subStatus = 0;
var landing_22_discending_ftm = 0.0;
var landing_22_pitch_output_error_coefficient_gain = 2.0;
var landing_22_slope_dif_adv = 0.0;
var landing_22_slope_adv = std.Vector.new([]);
var landing_22_slope_adv_acc = 0.0;
var landing_30_brake_stop = 0;
var landing_40_brake_stop = 0;

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
    
    var speed_cas = getprop("fdm/jsbsim/systems/autopilot/speed-cas-on-air");
    airplane = geo.aircraft_position();
    
    var rwy_offset_h_nm = getprop("fdm/jsbsim/systems/autopilot/gui/landing-rwy-h-offset-nm");
    var rwy_offset_v_ft = getprop("fdm/jsbsim/systems/autopilot/gui/landing-rwy-v-offset-ft");
    
    #### Provvisory replece JSBSim random generator is not work now ####
    setprop("fdm/jsbsim/systems/dragchute/rnd-number-alpha",1 - (2 * rand()));
    setprop("fdm/jsbsim/systems/dragchute/rnd-number-beta",1 - (2 * rand()));
    
    if (landig_departure_status_id == 1) {
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
        var apts = nil;
        var runway_to_airplane_dist = 0.0;
        
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
                landing_rwy_h_offset_nm = - ((2000.0 - airport_select.runways[rwy_select].length) / 8000);
            }
            setprop("fdm/jsbsim/systems/autopilot/gui/landing-rwy-h-offset-nm",landing_rwy_h_offset_nm);
            rwy_coord_start.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon);
            runway_to_airplane_dist = math.abs(airplane.distance_to(rwy_coord_start) * 0.000621371 - rwy_offset_h_nm);
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
                landing_20_skip_to_22 = 0;
                landing_20_dist_to_reduce_h = 0;
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",6.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-active",1.0);
                if (altitude_top_select > 0.0) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",math.round(altitude_top_select));
                    altitude_top_select = -1.0;
                } else {
                    setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",math.round(getprop("fdm/jsbsim/systems/autopilot/h-sl-ft-lag")));
                }
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",getprop("fdm/jsbsim/systems/autopilot/heading-true-deg"));
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/heading-control",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/wing-leveler",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/phi-heading",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",30.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/rudder-auto-coordination",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",2000.0);
                setprop("fdm/jsbsim/systems/autopilot/phase-landing",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-control",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-flap",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-throttle",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-pitch",0.0);
                if (speed_select == -1.0) {
                    if (speed_select < 2.0) {
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",1.0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",0.0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",speed_select);
                    } else {
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                        if (getprop("fdm/jsbsim/systems/autopilot/gui/speed-value") < 250) {
                            setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",250.0);
                        } else {
                            setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",speed_select);
                        }
                        speed_select = -1.0;
                    }
                } else {
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                    if (getprop("fdm/jsbsim/systems/autopilot/gui/speed-value") < 250) {
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",250.0);
                    }
                }
                setprop("fdm/jsbsim/systems/autopilot/speed-throttle-imposed",-1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",2.0);
                setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-close",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",0.0);
                setprop("fdm/jsbsim/systems/airbrake/manual-cmd",0.0);
                rwy_coord_end.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon);
                rwy_coord_end_offset = airport_select.runways[rwy_select].length;
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
        var holding_point_distance_nm = getprop("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-dist-nm");
        var holding_point_before_distance_nm = 4.0;
        var holding_point_to_airplane_delta_alt_ft = 0.0;
        var runway_to_airplane_delta_alt_ft = 0.0;
        var heading_correction_deg = 0.0;
        var heading_correct = 0.0;
        var runway_to_airplane_dist_direct_nm = 0.0;
        var gear_unit_contact = getprop("fdm/jsbsim/systems/landing-gear/on-ground");
        var altitude_agl_ft = 0.0;
        var holding_point_h_ft = getprop("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-h-ft");
        rwy_coord_end.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon);
        rwy_coord_end.apply_course_distance(airport_select.runways[rwy_select].heading,airport_select.runways[rwy_select].length);
        var runway_end_to_airplane_dist = airplane.distance_to(rwy_coord_end) * 0.000621371;
        #
        # Common eleboration
        #
        var runway_to_airplane_dist_prec = runway_to_airplane_dist;
        runway_to_airplane_dist = math.abs(airplane.distance_to(rwy_coord_start) * 0.000621371 + rwy_offset_h_nm);
        runway_to_airplane_dist_der = (runway_to_airplane_dist_prec - runway_to_airplane_dist) / (timeStep / timeStepDivisor);
        rwy_offset_v_ft = rwy_offset_v_ft - 30.0 * (airport_select.runways[rwy_select].length/3000.0);
        rwy_coord_start.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon);
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
        runway_to_airplane_dist_direct_nm = airplane.direct_distance_to(rwy_coord_start) * 0.000621371 + rwy_offset_h_nm;
        setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_delta_altitude",runway_to_airplane_delta_alt_ft);
        heading_correction_deg = (airport_select.runways[rwy_select].heading - airplane.course_to(rwy_coord_start));
        heading_correct = airport_select.runways[rwy_select].heading - heading_correction_deg;
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
            holding_point.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon);
            holding_point.apply_course_distance(airport_select.runways[rwy_select].heading + 180.0,holding_point_distance_nm * 1852.0);
            var holding_point_to_airplane_dist = airplane.distance_to(holding_point) * 0.000621371;
            var holding_point_to_airplane_dist_direct = airplane.direct_distance_to(holding_point) * 0.000621371;
            var holding_point_to_airplane_delta_alt_ft = airplane.alt() * 3.28084 - (runway_alt_m_select * 3.28084 + holding_point_h_ft);
            var altitude_for_holding_point = runway_alt_m_select * 3.28084 + holding_point_h_ft;
            var dist_to_reduce_h = (holding_point_to_airplane_delta_alt_ft * (speed_cas / 30) / 1500.0);
            if ((holding_point_to_airplane_dist < dist_to_reduce_h) or landing_20_dist_to_reduce_h == 1) {
                landing_20_dist_to_reduce_h = 1;
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",2500.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",altitude_for_holding_point);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",190.0);
                if ((speed_cas - 190) > 20.0) {
                    setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",1.0);
                } else {
                    setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-deactivate",1.0);
                }
            }
            var heading_correction_deg_for_before_dist = math.abs(geo.normdeg180(getprop("fdm/jsbsim/systems/autopilot/heading-true-deg") - airplane.course_to(rwy_coord_start)));
            if (heading_correction_deg_for_before_dist < 90) {
                holding_point_before_distance_nm = 1.8;
            } else {
                holding_point_before_distance_nm = 1.8 * (1 + ((heading_correction_deg_for_before_dist - 90.0) / 90.0));
            }
            if (holding_point_to_airplane_dist > holding_point_before_distance_nm) {
                heading_correct = airplane.course_to(holding_point);
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
                print("Landing 2.0 >"
                ,sprintf(" Hoding dist (nm): %5.1f",holding_point_to_airplane_dist_direct)
                ,sprintf(" Alt: %5.0f",altitude_for_holding_point)
                ,sprintf(" Delta: %.0f",holding_point_to_airplane_delta_alt_ft)
                ,sprintf(" Slope: %.1f",slope)
                ,sprintf(" | Heading cor: %4.1f",heading_correct)
                ,sprintf(" Heading correction: %4.1f",heading_correction_deg_for_before_dist)
                ,sprintf(" Hld. pt to plane (nm): %4.1f",holding_point_to_airplane_dist)
                ,sprintf(" Hld. pt (nm): %3.1f",holding_point_before_distance_nm)
                ,sprintf(" Dis R: %3.1f",dist_to_reduce_h)
                ,sprintf(" CAS: %6.1f",speed_cas)
                ,sprintf(" SB: %1.2f",getprop("fdm/jsbsim/systems/airbrake/position"))
                );
            } else {
                if (math.abs(holding_point_to_airplane_delta_alt_ft) < 500.0 and math.abs(speed_cas - 190) < 40.0) {
                    landing_20_skip_to_22 = 1;
                }
                landig_departure_status_id = 2.1;
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",45.0);
                setprop("fdm/jsbsim/systems/autopilot/phase-landing",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",190.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",2.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",3500.0);
                setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-deactivate",1.0);
                setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-close",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",0.0);
                setprop("fdm/jsbsim/systems/airbrake/manual-cmd",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",6.0);
                isHolding_reducing_delta = -20;
                isHolding_reducing_heading = nil;
                isHolding_reducing_distance_rel = nil;
                isHolding_reducing_terminated = 0;
            }
        } else if (landig_departure_status_id == 2.1) {
            # Fly near the holding point
            # Deley the start
            if (isHolding_reducing_delta < 0) {
                isHolding_reducing_delta = isHolding_reducing_delta + 1;
            }
            # Marc altitude by slope in the holding point
            runway_to_airplane_dist_direct_nm_mem = airplane.direct_distance_to(rwy_coord_start) * 0.000621371 + rwy_offset_h_nm;
            holding_point_h_ft = math.sin(holding_point_slope_imposed / R2D) * runway_to_airplane_dist_direct_nm_mem * 6076.12;
            setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",runway_alt_m_select * 3.28084 + holding_point_h_ft);
            # Calculate the actual slope, normaly is less than the holding_point_slope_imposed
            slope = math.asin(((runway_to_airplane_delta_alt_ft - rwy_offset_v_ft)* 0.000189394) / runway_to_airplane_dist_direct_nm) * R2D;
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope",slope);
            var runway_to_airplane_dist = airplane.distance_to(rwy_coord_start) * 0.000621371 + rwy_offset_h_nm;
            setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_distance",runway_to_airplane_dist);
            # Set the holding area dimension
            var long_circuit_distance = 3.0;
            if (isHolding_reducing_terminated == 2) {
                var long_circuit_distance = 0.5;
            }
            var rwy_point_delta_alt_ft = (airplane.alt() - runway_alt_m_select) * 3.28084 - holding_point_h_ft;
            # Calculate the difference altitude
            if (math.abs(rwy_point_delta_alt_ft) < 500 and isHolding_reducing_terminated == 0) {
                isHolding_reducing_terminated = 1;
            } else if (math.abs(rwy_point_delta_alt_ft) < 1500 and isHolding_reducing_terminated == 0) {
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",1500.0);
            } else if (math.abs(rwy_point_delta_alt_ft) > 1500 and isHolding_reducing_terminated == 0) {
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",3500.0);
                setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",1.0);
            }
            # Calculate the difference of the speed
            if ((math.abs(getprop("fdm/jsbsim/systems/autopilot/speed-cas-lag") - 190.0)) < 40.0 and isHolding_reducing_terminated == 1) {
                isHolding_reducing_terminated = 2;
                setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-deactivate",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",1500.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1.0);
            } else if (isHolding_reducing_terminated == 1) {
                setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",1.0);
            } else if (isHolding_reducing_terminated == 0) {
                setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",1.0);
            }
            # Check stop execution and exit for 2.2 phase
            if ((isHolding_reducing_terminated == 2 and isHolding_reducing_delta < 0) or landing_20_skip_to_22 == 1) {
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
                setprop("fdm/jsbsim/systems/autopilot/phase-landing",1.0);
                landing_22_slope_adv.clear();
                landing_22_slope_adv.extend([]);
                landing_22_slope_adv_acc = 0.0;
                landing_22_slope_target = -3.8;
                landing_slope_integrate = 0.0;
                landing_22_pitch_output_error_coefficient_gain = 2.0;
                landing_22_slope_dif_adv = 0.0;
                # Redefine the coordinates in function of the definitive selected rwy
                rwy_coord_end.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon);
                rwy_coord_end_offset = airport_select.runways[rwy_select].length;
                if (rwy_coord_end_offset > 1000.0) rwy_coord_end_offset = 1000.0;
                rwy_coord_end.apply_course_distance(airport_select.runways[rwy_select].heading,rwy_coord_end_offset);
                landing_22_discending_ftm = 0.0;
            }
            # Loops execution
            if (isHolding_reducing_terminated <= 2 and isHolding_reducing_delta >= 0) {
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
                        if (((getprop("fdm/jsbsim/systems/autopilot/distance-nm") - isHolding_reducing_distance_rel_stright) > long_circuit_distance))
                        {
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
                        if (((getprop("fdm/jsbsim/systems/autopilot/distance-nm") - isHolding_reducing_distance_rel_stright) > long_circuit_distance)) {
                            isHolding_reducing_heading = nil;
                            isHolding_reducing_distance_rel = nil;
                            isHolding_reducing_distance_rel_stright = nil;
                            isHolding_reducing_delta = -2;
                        }
                    }
                }
            }
            print("Landing 2.1 >"
            ,sprintf(" Dist (nm): %6.1f",runway_to_airplane_dist)
            ,sprintf(" Alt (ft): %5.0f",(runway_to_airplane_delta_alt_ft - rwy_offset_v_ft))
            ,sprintf(" Alt delta (ft): %5.0f",rwy_point_delta_alt_ft)
            ,sprintf(" Slope: %3.1f",slope)
            ,sprintf(" holding_point_h_ft (ft): %5.0f",holding_point_h_ft)
            ,sprintf(" isHolding_reducing_delta: %3.0f",isHolding_reducing_delta)
            ,sprintf(" is Term: %.0f",isHolding_reducing_terminated)
            ,sprintf(" CAS: %6.1f",speed_cas));
        } else if (landig_departure_status_id == 2.2) {
            var wind_speed = getprop("/environment/wind-speed-kt");
            var wind_from = getprop("/environment/wind-from-heading-deg");
            var wind_deviation = math.abs(geo.normdeg(wind_from - airport_select.runways[rwy_select].heading));
            var wind_frontal = wind_speed * (math.cos(wind_deviation * d2r));
            var wind_lateral = wind_speed * (math.sin(wind_deviation * d2r));
            var distance_to_leave = 0.0 + (wind_frontal * 25) / 1000.0;
            if (distance_to_leave < 0.2) distance_to_leave = 0.2;
            var altitude_agl_ft = getprop("/position/altitude-agl-ft");
            # Heading to select rwy
            if (gear_unit_contact == 0) {
                var rwy_coord_start_final = geo.Coord.new();
                var rwy_coord_end_final = geo.Coord.new();
                var ku = 15.0;
                var tu = 15.0;
                var kp = 0.6 * ku;
                var ki = 1.2 * ku / tu;
                var kd = 3.0 * ku * tu / 40;
                
                if (runway_to_airplane_dist_direct_nm > 10.0) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-flap",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",0.0);
                }
                if (runway_to_airplane_dist_direct_nm <= 10.0 and runway_to_airplane_dist_direct_nm > 8.0) {
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-flap",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",0.0);
                }
                if (runway_to_airplane_dist_direct_nm <= 8.0 and runway_to_airplane_dist > 3.0) {
                    setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-gear",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-open",1.0);
                }
                if (runway_to_airplane_dist <= 2.0) {
                    pitch_output_error_coefficient_gain = 2.0 + (wind_speed / 15);
                    setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-descent-angle-deg",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/landing-gear-set-open",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/phase-landing",2.0);
                }

                if (runway_to_airplane_dist > 2.0) {
                    rwy_coord_start_final.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon);
                    rwy_coord_start_final.apply_course_distance(airport_select.runways[rwy_select].heading,runway_to_airplane_dist * 1852.0);
                    heading_correct = airplane.course_to(rwy_coord_start_final);
                } else {
                    rwy_coord_end_final.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon);
                    rwy_coord_end_final.apply_course_distance(airport_select.runways[rwy_select].heading,(runway_to_airplane_dist * 1852.0 + rwy_coord_end_offset));
                    heading_correct = airplane.course_to(rwy_coord_end_final);
                }
                heading_correction_deg = airport_select.runways[rwy_select].heading - heading_correct;
                if (heading_correction_deg > 180) heading_correction_deg = heading_correction_deg - 360;
                if (heading_correction_deg < -180) heading_correction_deg = heading_correction_deg + 360;
                var heading_factor = 2.0;
                if (math.abs(heading_correction_deg) < 10.0 and math.abs(heading_correction_deg) > 2.0) {
                    heading_factor = 2.0 + 4 * math.abs(heading_correction_deg);
                } else if (math.abs(heading_correction_deg) <= 2 and math.abs(heading_correction_deg) > 0.05) {
                    heading_factor = 4.0 + 12 * math.abs(heading_correction_deg);
                }
                var heading_correction_deg_mod = heading_correction_deg * heading_factor;
                if (heading_correction_deg_mod > 40.0) heading_correction_deg_mod = 40;
                if (heading_correction_deg_mod < -40.0) heading_correction_deg_mod = -40;
                heading_correct = airport_select.runways[rwy_select].heading - heading_correction_deg_mod;
                if (heading_correct > 180) heading_correct = heading_correct - 360;
                if (heading_correct < -180) heading_correct = heading_correct + 360;
                setprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct",heading_correct);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",heading_correct);
                # Slope target correction
                var cas_max = 180.0;
                var wind_frontal_active = wind_frontal;
                if (wind_frontal_active < 0) wind_frontal_active = 0;
                wind_frontal_active = 0.0;
                var slopeIncrementIntegrate = 0.05;
                var delta_h_ft = runway_to_airplane_delta_alt_ft - rwy_offset_v_ft;
                var error = 0.0;
                var derivate = 0.0;
                var landing_slope = 0.0;
                var dist_direct_ft = runway_to_airplane_dist * 5280.0;
                var speed_true_fps = getprop("fdm/jsbsim/systems/autopilot/speed-true-on-air") / 3600.0 * 5280.0;
                var min_to_term = math.abs((dist_direct_ft / speed_true_fps) / 60.0);
                var pitch_output_error_coefficient_gain = 2.0;
                var weitght_norm = (10000.0 / getprop("fdm/jsbsim/inertia/weight-lbs"));
                var slope_adv = 0.0;
                if (runway_to_airplane_dist_direct_nm > 12.0) {
                    landing_22_subStatus = 1;
                    pitch_output_error_coefficient_gain = 0.5;
                    cas_max = 180.0 + wind_frontal_active;
                    if (landing_22_slope_target < -3.85) landing_22_slope_target = landing_22_slope_target + 0.002;
                    if (landing_22_slope_target > -3.75) landing_22_slope_target = landing_22_slope_target - 0.002;
                    slope = - math.asin((delta_h_ft * 0.000189394) / runway_to_airplane_dist) * R2D;
                    landing_22_slope_dif_adv = (landing_22_slope_dif_adv + slope + getprop("fdm/jsbsim/systems/autopilot/pitch-descent-angle-deg-real-lag")) / 2.0;
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",1.0);
                } else if (runway_to_airplane_dist > 2.0) {
                    landing_22_subStatus = 2;
                    pitch_output_error_coefficient_gain = 1.5 + (wind_speed / 30);
                    cas_max = 160.0 + wind_frontal_active - (15 * weitght_norm);
                    if (landing_22_slope_target < -3.30) landing_22_slope_target = landing_22_slope_target + 0.01;
                    if (landing_22_slope_target > -3.20) landing_22_slope_target = landing_22_slope_target - 0.01;
                    slope = - math.asin((delta_h_ft * 0.000189394) / runway_to_airplane_dist) * R2D;
                    landing_22_slope_dif_adv = (landing_22_slope_dif_adv + slope + getprop("fdm/jsbsim/systems/autopilot/pitch-descent-angle-deg-real-lag")) / 2.0;
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",1.0);
                } else if (runway_to_airplane_dist <= 2.0 and runway_to_airplane_dist > 0.8 and runway_to_airplane_dist_der > 0.0) {
                    landing_22_subStatus = 3;
                    pitch_output_error_coefficient_gain = 1.0 + (wind_speed / 20);
                    cas_max = 145.0 + wind_frontal_active - (15 * weitght_norm);
                    if (landing_22_slope_target < -3.05) landing_22_slope_target = landing_22_slope_target + 0.01;
                    if (landing_22_slope_target > -2.95) landing_22_slope_target = landing_22_slope_target - 0.01;
                    slope = - math.asin((delta_h_ft * 0.000189394) / (runway_to_airplane_dist + 0.1)) * R2D;
                    landing_22_slope_dif_adv = (landing_22_slope_dif_adv + slope + getprop("fdm/jsbsim/systems/autopilot/pitch-descent-angle-deg-real-lag")) / 2.0;
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",1.0);
                } else if (((runway_to_airplane_dist <= 0.8 and runway_to_airplane_dist_der > 0.0 and runway_to_airplane_delta_alt_ft > rwy_offset_v_ft and landing_22_subStatus <= 4) or (landing_22_subStatus == 4 and runway_to_airplane_dist_der > 0.0)) and min_to_term > 0.01)  {
                    landing_22_subStatus = 4;
                    pitch_output_error_coefficient_gain = 0.5 * (1 + weitght_norm) + (wind_speed / 30);
                    cas_max = 135.0 + wind_frontal_active - (5 * weitght_norm);
                    if (landing_22_slope_target < -2.80) landing_22_slope_target = landing_22_slope_target + 0.01;
                    if (landing_22_slope_target > -2.70) landing_22_slope_target = landing_22_slope_target - 0.01;
                    slope = - math.asin((delta_h_ft * 0.000189394) / (runway_to_airplane_dist + 0.2)) * R2D;
                    landing_22_slope_dif_adv = (landing_22_slope_dif_adv + slope + getprop("fdm/jsbsim/systems/autopilot/pitch-descent-angle-deg-real-lag")) / 2.0;
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",1.0);
                } else if ((runway_to_airplane_dist_der <= 0.0 or landing_22_subStatus == 5 or min_to_term <= 0.01) and altitude_agl_ft > 40.0 and speed_cas > 20.0 and landing_22_subStatus <= 5) {
                    landing_22_subStatus = 5;
                    cas_max = 130.0 + wind_frontal_active - (5 * weitght_norm);
                    slope = landing_22_slope_dif_adv - getprop("fdm/jsbsim/systems/autopilot/pitch-descent-angle-deg-real-lag");
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1.0);
                    landing_22_discending_ftm = -500 * weitght_norm;
                    setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",landing_22_discending_ftm);
                } else if ((altitude_agl_ft <= 40.0 or landing_22_subStatus == 6) and speed_cas > 20.0) {
                    landing_22_subStatus = 6;
                    cas_max = 50.0 + wind_frontal_active;
                    slope = landing_22_slope_dif_adv - getprop("fdm/jsbsim/systems/autopilot/pitch-descent-angle-deg-real-lag");
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1.0);
                    landing_22_discending_ftm = (-150.0) + (-400.0 * weitght_norm * (altitude_agl_ft / 40.0));
                    setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",landing_22_discending_ftm);
                }
                
                # Slope ADV for input filter to PID
                landing_22_slope_adv.insert(-1,slope);
                var landing_22_slope_adv_dif = slope;
                var popTest = 0.0;
                if (landing_22_slope_adv.size() > 20) {
                    popTest = landing_22_slope_adv.pop(0);
                    landing_22_slope_adv_dif = landing_22_slope_adv_dif - popTest;
                }
                landing_22_slope_adv_acc = landing_22_slope_adv_acc + landing_22_slope_adv_dif;
                slope_adv = landing_22_slope_adv_acc / landing_22_slope_adv.size();
                
                if (landing_22_subStatus < 5) {
                    if (landing_22_pitch_output_error_coefficient_gain > (pitch_output_error_coefficient_gain + 0.02)) {
                        landing_22_pitch_output_error_coefficient_gain = landing_22_pitch_output_error_coefficient_gain - 0.02;
                    } else if (landing_22_pitch_output_error_coefficient_gain < (pitch_output_error_coefficient_gain - 0.02)){
                        landing_22_pitch_output_error_coefficient_gain = landing_22_pitch_output_error_coefficient_gain + 0.02;
                    }
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",cas_max);
                    
                    # PID controller section
                    error = landing_22_slope_target - slope_adv;
                    landing_slope_integrate = landing_slope_integrate + error * (timeStep / timeStepDivisor);
                    derivate = (error - landing_slope_previous_error) / (timeStep / timeStepDivisor);
                    landing_slope = (slope_adv - (kp * error + ki * landing_slope_integrate + kd * derivate)) * landing_22_pitch_output_error_coefficient_gain;
                    landing_slope_previous_error = error;
                    # cut funtion
                    if (landing_slope > 20.0) {
                        landing_slope = 20.0;
                        landing_slope_integrate = 0.0;
                    } else if (landing_slope < -20.0) {
                        landing_slope = -20.0;
                        landing_slope_integrate = 0.0;
                    }
                }
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-hold-deg",landing_slope);
                
                print("Landing 2.2.",landing_22_subStatus,">",
                ,sprintf(" Dist: %6.1f",runway_to_airplane_dist_direct_nm)
                ,sprintf(" %6.2f",runway_to_airplane_dist)
                ,sprintf(" Dh: %5.0f",delta_h_ft)
                ,sprintf(" | %5.0f",altitude_agl_ft)
                ,sprintf(" Slp: %4.2f",landing_slope)
                ,sprintf(" (%4.2f ",slope_adv)
                ,sprintf(" %4.2f ",landing_22_slope_target)
                ,sprintf(" [%4.2f",- getprop("fdm/jsbsim/systems/autopilot/pitch-descent-angle-deg-real-lag"))
                ,sprintf(" |%4.2f]",landing_22_slope_dif_adv)
                ,sprintf(" Er: %4.2f ",error)
                ,sprintf(" %4.2f ",landing_slope_integrate)
                ,sprintf(" %4.2f ",derivate)
                ,sprintf(" %4.2f ",landing_22_pitch_output_error_coefficient_gain)
                ,sprintf(" | %4.1f ",landing_22_discending_ftm)
                ,sprintf(" %1.2f ",weitght_norm)
                ,sprintf(" %2.3f ",min_to_term)
                ,")"
                ,sprintf(" Hd: %4.1f",heading_correct)
                ,sprintf(" cr: %4.2f",heading_correction_deg)
                ,sprintf(" fct: %2.2f",heading_factor)
                ,sprintf(" dgm: %3.2f",heading_correction_deg_mod)
                ,sprintf(" Dis: %4.1f",distance_to_leave)
                ,sprintf(" off: %1.2f",rwy_offset_h_nm)
                ,sprintf(" | %3.1f",rwy_offset_v_ft)
                ,sprintf(" CAS: %6.1f",speed_cas)
                ,sprintf(" | %6.1f",cas_max)
                ,sprintf(" wd: %3.1f",wind_frontal)
                ,sprintf(" | %3.1f",wind_lateral)
                );
            } else {
                landig_departure_status_id = 3.0;
                landing_30_brake_stop = 0;
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",0.0);
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
                setprop("fdm/jsbsim/systems/autopilot/phase-landing",2.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-automatic-flap",1.0);
                if (getprop("fdm/jsbsim/systems/autopilot/gui/landing-short-profile") > 0.0) {
                    setprop("fdm/jsbsim/systems/dragchute/activate",1.0);
                }
                rwy_coord_end_offset = airport_select.runways[rwy_select].length;
                if (rwy_coord_end_offset > 1000.0) rwy_coord_end_offset = 1000.0;
                rwy_coord_end.apply_course_distance(airport_select.runways[rwy_select].heading,rwy_coord_end_offset);
            }
        } else if (landig_departure_status_id == 3.0) {
            if (getprop("fdm/jsbsim/systems/autopilot/speed-true-on-air") < 35.0) {
                landig_departure_status_id = 4;
                landing_40_brake_stop = 0;
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
                setprop("fdm/jsbsim/systems/autopilot/phase-landing",2.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/phi-heading",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/wing-leveler",0.0);
                defaultViewInTheEvent = nil;
                delayCycleGeneral = 50;
                slope = 0.0;
                rwy_coord_end_offset = airport_select.runways[rwy_select].length;
                rwy_coord_end.apply_course_distance(airport_select.runways[rwy_select].heading,rwy_coord_end_offset);
            } else {
                var rwy_coord_end_final = geo.Coord.new();
                rwy_coord_end_final.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon,rwy_offset_v_ft * 3.28084);
                rwy_coord_end_final.apply_course_distance(airport_select.runways[rwy_select].heading,(runway_to_airplane_dist_direct_nm * 1852.0 + airport_select.runways[rwy_select].length));
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
                # Dragchute camera view
                if (getprop("fdm/jsbsim/systems/dragchute/active-view") > 0.01 and defaultViewInTheEvent == nil) {
                    defaultViewInTheEvent = view.index;
                    view.setView(view.indexof("Dragchute view"));
                }
                print("Landing 3.0 >"
                ,sprintf(" Dist (nm): %6.1f",runway_to_airplane_dist)
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
        } else if (landig_departure_status_id == 4.0) {
            var rwy_coord_end_final = geo.Coord.new();
            rwy_coord_end_final.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon,rwy_offset_v_ft * 3.28084);
            rwy_coord_end_final.apply_course_distance(airport_select.runways[rwy_select].heading,(runway_to_airplane_dist_direct_nm * 1852.0 + airport_select.runways[rwy_select].length));
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
            if (delayCycleGeneral <= 0) landig_departure_status_id = 0;
            print("Landing 4.0 >"
            ,sprintf(" Dist (nm): %6.1f",runway_to_airplane_dist)
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
        var heading_correction_deg = 0.0;
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
                setprop("fdm/jsbsim/systems/autopilot/phase-landing",0.0);
            }
        } else if (landig_departure_status_id == 10.3) {
            var altitude_agl_ft = getprop("/position/altitude-agl-ft");
            rwy_coord_end.set_latlon(airport_select.runways[rwy_select].lat,airport_select.runways[rwy_select].lon); 
            rwy_coord_end.apply_course_distance(airport_select.runways[rwy_select].heading,rwy_coord_end_offset);
            runway_to_airplane_dist = airplane.distance_to(rwy_coord_end) * 0.000621371;
            heading_correction_deg = (airport_select.runways[rwy_select].heading - airplane.course_to(rwy_coord_end));
            var heading_factor = 1 / math.log10(1.05 + math.abs(heading_correction_deg));
            heading_correct = airport_select.runways[rwy_select].heading - heading_correction_deg * heading_factor;
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
                    if (isAirport_and_rw_selected == -1) {
                        altitude_top_select = getprop("fdm/jsbsim/systems/autopilot/gui/take-off-altitude-top");
                    } else {
                        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",getprop("fdm/jsbsim/systems/autopilot/gui/take-off-altitude-top"));
                    }
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
                    speed_select = getprop("fdm/jsbsim/systems/autopilot/gui/take-off-cruise-speed");
                    landig_departure_status_id = 1.0;
                    landing_activate_status = 1;
                    setprop("fdm/jsbsim/systems/autopilot/gui/landing-scan-airport",0);
                } else {
                    landig_departure_status_id = -1.0;
                    altitude_top_select = -1.0;
                    speed_select = -1.0;
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
        altitude_top_select = -1.0;
        speed_select = -1.0;
        landing_30_brake_stop = 0;
        landing_40_brake_stop = 0;
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
                    if (getprop("fdm/jsbsim/attitude/theta-deg") > 15.0) {
                        setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-deactivate",1);
                    }
                } else {
                    if (speed_cas < 220 and getprop("fdm/jsbsim/systems/autopilot/gui/speed-value") < 220) {
                        setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",220.0);
                    }
                    if (impact_ramp < 1.0 and impact_altitude_direction_der_frist > 20.0) impact_ramp = 1.0;
                    impact_ramp_delta = 0.5 + impact_altitude_grain * (0.5 / (0.1 + math.ln((1.0 + math.pow((impact_time/10),3.0))))) / timeCoefficient;
                    if (impact_allarm_solution != 1.2) impact_allarm_solution_delay = 2 + impact_altitude_grain_avg;
                    impact_allarm_solution = 1.2;
                    impact_allarm_solution_delay = impact_allarm_solution_delay - 1;
                    if (getprop("fdm/jsbsim/attitude/theta-deg") > 15.0) {
                        setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-deactivate",1);
                    }
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
                    airplane = geo.aircraft_position();
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


