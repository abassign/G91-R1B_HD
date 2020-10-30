# Self-piloting by air interception
#
# 2020-08-15 Adriano Bassignana
# GPL 2.0+
#
# http://wiki.flightgear.org/Canvas_MapStructure

var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-ai-mp",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-ai-mp-mod",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-ai-mp-msg","Type AI","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-control-mod",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-control-active-level",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-control-msg","Idle","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-distance",100, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-id-select",-1, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-id-mod",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-callsign-select","","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-callsign-mod",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-speed-mph-coefficient",32.0,"DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-altitude-offset",200.0,"DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-target-min-dist",0.1,"DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/interception-target-dist-nm",0,"DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/interception-target-speed-mph",0,"DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/interception-target-speed-max-mph",520,"DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/interception-target-speed-dif-mph",0,"DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/interception-target-total-found",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/interception-target-total-select",0,"INT");

var type_ai_mp = 0;
var type_ai_mp_msg = "";

var timeStep = 1.0;
var timeStepDivisor = 1.0;
var delta_time = 1.0;
var timeStepSecond = 0;

var target_near_dist_nm = -9999.0;
var target_near_dist_adv_vector = std.Vector.new([]);
var target_near_dist_adv_acc = 0.0;
var target_near_dist_change = 5.0;
var course_to_deg = 0.0;
var course_to_deg_adv_vector = std.Vector.new([]);
var course_to_deg_adv_acc = 0.0;
var dif_course_deg = nil;

var active_level = 0;
var int_id_select = -1;
var int_callsign_select = "";

var targets_scan = {};
var targets_scan_sorter = {};

var int_cnt_min_speed_mph = 130.0;
var int_cnt_max_speed_mph = 450.0;
var int_cnt_max_h_ft = 40000.0;

var int_dist_max = 100.0;

var target_coord = geo.Coord.new();
var target_coord_mod = geo.Coord.new();
var airplane = nil;

var min_target_dist = 0.1;
var target_speed_mph = 0.0;
var speed_mph = 0.0;
var speed_max_mph = 0.0;

var pi2 = math.pi * 0.5;


var main = func() {
    
    print("pilot_intercept.nas load module");
    
}


var unload = func() {
    
    print("pilot_intercept.nas unload module");

}


var operateOn_Targets_Scan = func(aFunction) {
    if (aFunction == 0) {
        #// Clear
        var targets_scan_node = props.globals.getNode("/fdm/jsbsim/systems/autopilot/gui/interception-list");
        if (targets_scan_node != nil) {
            targets_scan_node.removeChild("airplanes",0);
            targets_scan_node.setValue("airplane","");
        }
        targets_scan = {};
        targets_scan_sorter = {};
        setprop("fdm/jsbsim/systems/autopilot/gui/interception-callsign-select","");
        setprop("fdm/jsbsim/systems/autopilot/gui/interception-callsign-mod",1);
    } elsif (aFunction == 1) {
        #// Sort funtion
        var j = size(targets_scan_sorter) - 1;
        while(j > 0) {
            for(var i = 0; i < j; i += 1) {
                if(targets_scan_sorter[i][0] > targets_scan_sorter[i+1][0]) {
                    var temp = targets_scan_sorter[i]; 
                    targets_scan_sorter[i] = targets_scan_sorter[i+1];
                    targets_scan_sorter[i+1] = temp;
                }
            }
            j -= 1; 
        }
        ## debug.dump(targets_scan_sorter);
    } elsif (aFunction == 2) {
        #// Insert in the gui/interception-list
        var counter = 1;
        while (counter <= 10 and counter < size(targets_scan_sorter)) {
            #//targets_scan[i,callsign,true_airspeed_kt,target_dist_nm,target_h_ft,target_true_heading_deg,course_to_deg];
            var target_scan = targets_scan[targets_scan_sorter[counter - 1][1]];
            var s =               
                sprintf("[%3u]",target_scan[0]) ~ " " ~ 
                sprintf("%15s",target_scan[1]) ~ " " ~ 
                sprintf("T v %3.0f",target_scan[2]) ~ " " ~ 
                sprintf("Dist %3.1f",target_scan[3]) ~ " " ~
                sprintf("T h %5.0f",target_scan[4]) ~ " " ~
                sprintf("T Hd %3.1f",target_scan[5]) ~ " " ~
                sprintf("to T %3.1f",target_scan[6]);
            print("### interception_list_airplanes: ",s);
            setprop("fdm/jsbsim/systems/autopilot/gui/interception-list/airplanes/value[" ~ counter ~ "] ",s);
            counter = counter + 1;
        }
    } elsif (aFunction == 3) {
        #// Select id
        var s = getprop("fdm/jsbsim/systems/autopilot/gui/interception-list/airplane");
        if (s != nil) {
            int_id_select = string.trim(substr(s,1,3));
            if (int_id_select == nil) {
                int_id_select = -1;
            } else {
                int_id_select = num(int_id_select);
            }
            setprop("fdm/jsbsim/systems/autopilot/gui/interception-id-select",int_id_select);
            setprop("fdm/jsbsim/systems/autopilot/gui/interception-id-mod",1);
        }
    } elsif (aFunction == 9) {
        #// Print data for log

    }
}


var searchCmd = func() {
    #// The algoritm i described in this link:
    #// http://wiki.flightgear.org/index.php?title=Howto:Working_with_AI_and_MP_properties&mobileaction=toggle_view_desktop
    #// /instrumentation/radar/range set the distance
    #// /ai/models/aircraft[n]/radar if the range permit to discover the airplane the system return the correct information
           
    airplane = geo.aircraft_position();
    var list = nil;
    var num_players = 0;
    var total = 0;
    var total_select = 0;
    if (type_ai_mp == 0) {
        list = props.globals.getNode("/ai/models/").getChildren("aircraft");
        if (list != nil) total = size(list);
    } else {
        num_players = getprop("/ai/models/num-players");
        if (num_players > 0) {
            list = props.globals.getNode("/ai/models/").getChildren("multiplayer");
            if (list != nil) total = size(list);
        }
    }
    setprop("fdm/jsbsim/systems/autopilot/interception-target-total-found",total);
    if (total > 0 and getprop("fdm/jsbsim/systems/autopilot/gui/interception-list/rw_select") == 0) {
        var nearest_id = -1;
        var nearest_nm = 999.0;
        operateOn_Targets_Scan(0);
        target_near_dist_adv_vector = std.Vector.new([]);
        target_near_dist_adv_acc = 0.0;
        target_near_dist_change = 5.0;
        dif_course_deg = nil;
        target_near_dist_nm = -9999.0;
        if (type_ai_mp == 0) {
            print("----[ AI ",total," ]----");
        } else {
            print("----[ MP ",num_players," : ",total," ]----");
        }
        active_level = 0;
        var index = -1;
        for(var i = 0; i < total; i += 1) {
            var callsign = list[i].getNode("callsign").getValue();
            var velocities = list[i].getNode("velocities");
            var true_airspeed_kt = velocities.getNode("true-airspeed-kt").getValue();
            var position = list[i].getNode("position");
            var orientation = list[int_id_select].getNode("orientation");
            target_coord.set_latlon(position.getNode("latitude-deg").getValue(),position.getNode("longitude-deg").getValue());
            var target_dist_nm = math.abs(airplane.distance_to(target_coord) * 0.000621371);
            var target_h_ft =  position.getNode("altitude-ft").getValue();
            var target_true_heading_deg = orientation.getNode("true-heading-deg").getValue();
            if (target_dist_nm <= int_dist_max and target_h_ft <= int_cnt_max_h_ft and true_airspeed_kt > int_cnt_min_speed_mph) {
                if (target_dist_nm < nearest_nm) {
                    nearest_nm = target_dist_nm;
                    nearest_id = i;
                }
                index += 1;
                total_select += 1;
                var course_to_deg = airplane.course_to(target_coord);
                targets_scan[callsign] = [i,callsign,true_airspeed_kt,target_dist_nm,target_h_ft,target_true_heading_deg,course_to_deg];
                targets_scan_sorter[index] = [target_dist_nm, callsign];
                var nearest_flag = "  ";
                if (nearest_id == i) nearest_flag = "* ";
                print(nearest_flag,i," ",
                    callsign,
                    sprintf(" V: %3.0f",true_airspeed_kt),
                    sprintf(" T dist: %3.1f",target_dist_nm),
                    sprintf(" T h: %5.0f",target_h_ft),
                    sprintf(" T dir deg: %3.1f",target_true_heading_deg),
                    sprintf(" C to deg: %3.1f",course_to_deg)
                );
            }
        }
        operateOn_Targets_Scan(1);
        operateOn_Targets_Scan(2);
        gui.dialog_update("militar-pilot-assistant");
    } else {
        operateOn_Targets_Scan(0);
        int_id_select = -1;
        gui.dialog_update("militar-pilot-assistant");
    }
    setprop("fdm/jsbsim/systems/autopilot/interception-target-total-select",total_select);
}


var isId = func(anId) {
    
    if (size(targets_scan) > 0) {
        foreach (var hash_key; keys(targets_scan)) {
            data = targets_scan[hash_key];
            if (data[0] == anId) {
                print("### ",data[0]," ",data[1]);
                return data[0];
            }
        }
    }
    return nil;
    
}


var isCallsign = func(anCallsign) {
    
    if (size(targets_scan) > 0) {
        foreach (var hash_key; keys(targets_scan)) {
            data = targets_scan[hash_key];
            if (string.imatch(data[1],anCallsign)) {
                print("### ",data[0]," ",data[1]);
                return data[0];
            }
        }
    }
    return nil;
    
}


var getCallsign = func(anId) {
    
    if (size(targets_scan) > 0) {
        foreach (var hash_key; keys(targets_scan)) {
            data = targets_scan[hash_key];
            if (data[0] == anId) {
                return data[1];
            }
        }
    }
    return "";
    
}

var getCallsignDescription = func(anId) {
    
    if (size(targets_scan) > 0) {
        foreach (var hash_key; keys(targets_scan)) {
            data = targets_scan[hash_key];
            if (data[0] == anId) {
                return data[2];
            }
        }
    }
    return "";
    
}


var target_near_dist_adv = func(distance, size) {
    
    var distance_dif = distance;
    target_near_dist_adv_vector.insert(-1,distance);
    while (target_near_dist_adv_vector.size() > size) {
        distance_dif = distance_dif - target_near_dist_adv_vector.pop(0);
    }
    target_near_dist_adv_acc = target_near_dist_adv_acc + distance_dif;
    return target_near_dist_adv_acc / target_near_dist_adv_vector.size();
    
}


var course_to_deg_adv = func(degree, size) {
    
    var degree_dif = degree;
    course_to_deg_adv_vector.insert(-1,degree);
    while (course_to_deg_adv_vector.size() > size) {
        degree_dif = degree_dif - course_to_deg_adv_vector.pop(0);
    }
    course_to_deg_adv_acc = course_to_deg_adv_acc + degree_dif;
    return course_to_deg_adv_acc / course_to_deg_adv_vector.size();
    
}


var interception_cnt = func() {
    
    if (int_id_select >= 0) {
        var list = nil;
        var num_players = 0;
        var total = 0;
        if (type_ai_mp == 0) {
            list = props.globals.getNode("/ai/models/").getChildren("aircraft");
            total = size(list);
        } else {
            num_players = getprop("/ai/models/num-players");
            if (num_players > 0) {
                list = props.globals.getNode("/ai/models/").getChildren("multiplayer");
                total = size(list);
            }
        }
        if (list != nil) {
            var radar = list[int_id_select].getNode("radar");
            if (radar != nil) {
                airplane = geo.aircraft_position();
                setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active-level",1);
                var in_range = radar.getNode("in-range").getValue();
                var target_speed_mph = list[int_id_select].getNode("velocities").getNode("true-airspeed-kt").getValue();
                var airplane_speed_mph = getprop("fdm/jsbsim/systems/autopilot/speed-true-on-air");
                if (in_range and target_speed_mph >= int_cnt_min_speed_mph and target_speed_mph <= int_cnt_max_speed_mph and airplane_speed_mph > 0.1) {
                    #// Is ok, is possible start the interception phase
                    #// "airplane" is the pilot's aircraft
                    speed_max_mph = getprop("fdm/jsbsim/systems/autopilot/interception-target-speed-max-mph");
                    var speed_dif_mph_target = target_speed_mph - airplane_speed_mph;
                    var vertical_speed_best_by_altitude = getprop("fdm/jsbsim/systems/autopilot/vertical-speed-optimize-by-altitude") * 0.8;
                    var speed_min_by_alt = getprop("fdm/jsbsim/systems/autopilot/speed-best-by-altitude");
                    var ramp_max_by_alt_deg = math.atan((vertical_speed_best_by_altitude * 0.01136363333) / speed_min_by_alt) * R2D;
                    var speed_mph_coefficient = getprop("fdm/jsbsim/systems/autopilot/gui/interception-speed-mph-coefficient");
                    var altitude_offset = getprop("fdm/jsbsim/systems/autopilot/gui/interception-altitude-offset");
                    var target_dist_min = getprop("fdm/jsbsim/systems/autopilot/gui/interception-target-min-dist");
                    var distFromTarget = 0.0;
                    var target_orientation = list[int_id_select].getNode("orientation");
                    var target_true_heading_deg = target_orientation.getNode("true-heading-deg").getValue();
                    var target_position = list[int_id_select].getNode("position");
                    var target_h_ft =  target_position.getNode("altitude-ft").getValue();
                    target_coord.set_latlon(target_position.getNode("latitude-deg").getValue(),target_position.getNode("longitude-deg").getValue(),target_h_ft * 0.3048);
                    var target_dist_nm = airplane.distance_to(target_coord) * 0.000621371;
                    if (target_dist_nm == nil or (target_dist_nm < 0.001 and target_dist_nm > -0.001)) target_dist_nm = 0.0;
                    var airplane_course_to_target_deg = geo.normdeg180(airplane.course_to(target_coord));
                    var target_course_to_future_nm = target_speed_mph * (target_dist_nm / airplane_speed_mph);
                    var altitude_selected_ft_dif = getprop("fdm/jsbsim/systems/autopilot/altitude-selected-ft-dif");
                    var ramp_target_by_alt_deg = nil;
                    if (target_dist_nm != 0.0) {
                        ramp_target_by_alt_deg = math.atan(altitude_selected_ft_dif / (target_dist_nm * 5280.0)) * R2D;
                    }
                    #// set speed and active_level
                    #// level = 1 activate the search AI or MP aircraft
                    #// level = 2 phase of approaching a point behind the target
                    #// level = 3 target tracking phase
                    #// level = 4 if the target is exceeded, a remittance phase is performed
                    if (target_near_dist_nm <= -9999.0) target_near_dist_nm = target_dist_nm;
                    var heading_factor = 0.2 + math.abs(math.atan(target_near_dist_nm)) / pi2;
                    #// Calculation of the ascent ramp
                    if (ramp_target_by_alt_deg != nil and dif_course_deg != nil) {
                        if (target_near_dist_nm > target_near_dist_change and active_level <= 2) {
                            active_level = 2;
                            speed_mph = speed_max_mph;
                            distFromTarget = 8.0 + 2.0 * math.log10(target_near_dist_nm);
                            if (ramp_target_by_alt_deg > ramp_max_by_alt_deg) {
                                speed_mph = speed_min_by_alt * 1.1;
                            }
                            setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",40.0);
                        } elsif (math.abs(dif_course_deg) < 90.0) {
                            active_level = 3;
                            target_near_dist_change = 8.0;
                            if (target_dist_nm < target_near_dist_change) {
                                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",20.0);
                                if (ramp_target_by_alt_deg < ramp_max_by_alt_deg) {
                                    speed_mph = target_speed_mph + speed_mph_coefficient * (target_dist_nm - target_dist_min);
                                    if (speed_mph < speed_min_by_alt) speed_mph = speed_min_by_alt;
                                    if (airplane_speed_mph > 1.1 * speed_mph) setprop("fdm/jsbsim/systems/autopilot/speed-brake-set-activate",1.0);
                                } else {
                                    speed_mph = target_speed_mph + speed_mph_coefficient * (target_dist_nm - target_dist_min);
                                    if (target_speed_mph < speed_min_by_alt) speed_mph = speed_min_by_alt;
                                }
                            } else {
                                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",40.0);
                                speed_mph = speed_max_mph;
                            }
                            if (speed_mph < speed_min_by_alt) {
                                active_level = 2;
                                target_near_dist_change = 5.0;
                                speed_mph = speed_max_mph;
                            }
                            distFromTarget = target_near_dist_nm - target_near_dist_change;
                        } else {
                            active_level = 4;
                            speed_mph = target_speed_mph - 2.0 * speed_mph_coefficient * (target_dist_nm - target_dist_min);
                            if (speed_mph > speed_min_by_alt) {
                                distFromTarget = target_near_dist_nm - target_near_dist_change;
                            } else {
                                speed_mph = speed_max_mph;
                                active_level = 2;
                            }
                        }
                    }
                    if (active_level <= 2) {
                        var distance = (-distFromTarget + target_course_to_future_nm) * 1852.0;
                        ## if (distance > (-2.0 * 1852.0)) distance = 5.0 * 1852.0;
                        target_coord_mod = target_coord.apply_course_distance(target_true_heading_deg, distance);
                    } else {
                        target_coord_mod = target_coord.apply_course_distance(target_true_heading_deg, 5.0 + 1852);
                    }
                    
                    ## target_coord_mod = target_coord.apply_course_distance(target_true_heading_deg, (-distFromTarget + target_course_to_future_nm) * 1852.0);
                    
                    target_near_dist_nm = target_near_dist_adv(airplane.distance_to(target_coord_mod) * 0.000621371,20);
                    var course_to_deg = airplane.course_to(target_coord_mod);
                    course_to_deg_avd = course_to_deg_adv(course_to_deg,20);
                    dif_course_deg = geo.normdeg(target_true_heading_deg - airplane_course_to_target_deg);
                    if (dif_course_deg > 180.0) dif_course_deg = dif_course_deg - 360.0;

                    if (active_level > 2) {
                        var max_wing_slope = 10.0 * (1 + math.ln(1.0 + math.abs(dif_course_deg)));
                        setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",max_wing_slope);
                        var dif_course_deg_lim = dif_course_deg;
                        if (dif_course_deg > 10.0) {
                            dif_course_deg_lim = 10.0;
                        } elsif (dif_course_deg < -10.0) {
                            dif_course_deg_lim = -10.0;
                        }
                        var heading_correction_deg_mod = dif_course_deg_lim * heading_factor;
                        setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",target_true_heading_deg - heading_correction_deg_mod);
                        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",target_h_ft + altitude_offset);
                        var vertical_speed_max = 0.8 * math.tan(ramp_max_by_alt_deg * D2R) * speed_min_by_alt * 5280.0 / 60.0;
                        if (altitude_selected_ft_dif > 0.0) {
                            if (vertical_speed_max < vertical_speed_best_by_altitude) vertical_speed_best_by_altitude = speed_min_by_alt;
                        } else {
                            vertical_speed_best_by_altitude = 4000.0;
                        }
                        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",vertical_speed_best_by_altitude);
                    } else {
                        #// Verify the vertical situation for direct interception
                        if (altitude_selected_ft_dif > 1000.0) {
                            
                        }
                        setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",course_to_deg_avd);
                        if (altitude_offset > 0.0) {
                            altitude_offset = altitude_offset * 1.5 + 1000.0;
                        } elsif (altitude_offset < 0.0) {
                            altitude_offset = 1000.0;
                        }
                        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",target_h_ft + altitude_offset);
                        if (altitude_selected_ft_dif < 0.0) vertical_speed_best_by_altitude = 4000.0;
                        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",vertical_speed_best_by_altitude);
                    }
                    
                    print(
                        sprintf("*** level: %1.0f",active_level),
                        sprintf(" target dist: %3.1f",target_dist_nm),
                        sprintf(" mod near nm: %3.1f",target_near_dist_nm),
                        sprintf(" distFromTarget: %3.1f",distFromTarget),
                        sprintf(" T coursem fut: %3.0f", target_course_to_future_nm),
                        sprintf(" course to T: %3.1f",airplane_course_to_target_deg),
                        sprintf(" heading fc: %2.1f",heading_factor),
                        sprintf(" dif deg: %3.1f",dif_course_deg),
                        sprintf(" VS by Alt: %4.0f",vertical_speed_best_by_altitude),
                        sprintf(" Speed: %3.1f",speed_mph),
                        sprintf(" dif: %3.1f",speed_dif_mph_target),
                        sprintf(" min: %3.1f",speed_min_by_alt),
                        sprintf(" dif ft: %5.0f",altitude_selected_ft_dif),
                        sprintf(" Ramp max: %2.2f",ramp_max_by_alt_deg),
                        sprintf(" / %2.2f",ramp_target_by_alt_deg)
                    );
                    
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-control",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",1.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
                    setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",speed_mph);
                    setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active-level",active_level);
                    setprop("fdm/jsbsim/systems/autopilot/interception-target-dist-nm",target_dist_nm);
                    setprop("fdm/jsbsim/systems/autopilot/interception-target-speed-mph",target_speed_mph);
                    setprop("fdm/jsbsim/systems/autopilot/interception-target-speed-dif-mph",speed_dif_mph_target);
                    setprop("fdm/jsbsim/systems/autopilot/interception-true-heading-deg",target_true_heading_deg);
                    
                    
                } else {
                    #// Exit from interception mode
                    int_id_select = -2;
                }
            }
            if (int_id_select == -2) {
                int_id_select = -1;
                active_level = 0;
                setprop("fdm/jsbsim/systems/autopilot/gui/interception-id-select",int_id_select);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-best-by-altitude",1);
                setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active-level",active_level);
                setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active",0);
            }
        } else {
            int_id_select = -1;
        }
    }
    
}


setlistener("fdm/jsbsim/systems/autopilot/gui/landig-sub-status-id", func {
    
    var landig_sub_status_id = getprop("fdm/jsbsim/systems/autopilot/gui/landig-sub-status-id");
    if (landig_sub_status_id > 0.0 and (landig_sub_status_id < 11.0 and landig_sub_status_id >= 12.0)) {
        setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active-level",0);
        setprop("fdm/jsbsim/systems/autopilot/gui/interception-id-select",-1);
        setprop("fdm/jsbsim/systems/autopilot/gui/interception-callsign-select","");
    }
    
}, 0, 1);


setlistener("fdm/jsbsim/systems/autopilot/gui/interception-control-active-level", func {
    
    active_level = getprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active-level");

    if (active_level == 0) {
        setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-msg","Idle");
        #// Set system status for appropriate active_level
        setprop("fdm/jsbsim/systems/autopilot/gui/interception-id-select",-1);
        setprop("fdm/jsbsim/systems/autopilot/gui/interception-callsign-select","");
        #// Heading
        setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",math.round(getprop("fdm/jsbsim/systems/autopilot/heading-true-deg")));
        setprop("fdm/jsbsim/systems/autopilot/gui/true-heading",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/heading-control",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/wing-leveler",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/phi-heading",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/rudder-auto-coordination",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",30.0);
        #// Altitude
        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-active",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",math.round(getprop("fdm/jsbsim/systems/autopilot/h-sl-ft-lag")));
        setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-QFE",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle-deg",6.0);
        #// Speed
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-best-by-altitude",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-throttle",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-pitch",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle-deg",6.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",2500);
    } elsif (active_level == 1) {
        setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-msg","Search mode");
        #// Set system status for appropriate active_level
        #// Heading
        setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",math.round(getprop("fdm/jsbsim/systems/autopilot/heading-true-deg")));
        setprop("fdm/jsbsim/systems/autopilot/gui/true-heading",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/heading-control",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/wing-leveler",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/phi-heading",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/rudder-auto-coordination",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-max-wing-slope-deg",45.0);
        #// Altitude
        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-active",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",math.round(getprop("fdm/jsbsim/systems/autopilot/h-sl-ft-lag")));
        setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/altitude-QFE",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle-deg",6.0);
        #// Speed
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-control",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mph",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-cas",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-mach",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",350.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-best-by-altitude",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle",0.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle-deg",6.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",4000);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-throttle",1.0);
        setprop("fdm/jsbsim/systems/autopilot/gui/speed-pitch",0.0);
    } elsif (active_level == 2) {
        setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-msg","Interception");
    } elsif (active_level == 3) {
        setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-msg","Near target");
    } elsif (active_level == 4) {
        setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-msg","Return to target");
    }
    
}, 0, 1);


setlistener("fdm/jsbsim/systems/autopilot/gui/interception-control-mod", func {

    var int_cnt_mod = getprop("fdm/jsbsim/systems/autopilot/gui/interception-control-mod");
    active_level = getprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active-level");
    if (int_cnt_mod >= 1) {
        if (active_level == 0 or (active_level >= 1 and int_cnt_mod == 2)) {
            var landig_sub_status_id = getprop("fdm/jsbsim/systems/autopilot/gui/landig-sub-status-id");
            if (landig_sub_status_id == 0 or (landig_sub_status_id >= 11.0 and landig_sub_status_id < 12.0)) {
                setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active-level",1);
                setprop("/instrumentation/radar/range",int_dist_max);
            } else {
                setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active-level",0);
            }
        } elsif (active_level >= 1) {
            setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active-level",0);
        }
        setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-mod",0);
    }

}, 0, 1);


setlistener("fdm/jsbsim/systems/autopilot/gui/interception-id-mod", func {
    
    var id_mod = getprop("fdm/jsbsim/systems/autopilot/gui/interception-id-mod");
    if (id_mod == 1) {
        active_level = getprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active-level");
        if (active_level >= 1) {
            var id_to_test = getprop("fdm/jsbsim/systems/autopilot/gui/interception-id-select");
            var id = isId(id_to_test);
            if (id != nil) {
                int_id_select = id;
                int_callsign_select = getCallsign(id);
                setprop("fdm/jsbsim/systems/autopilot/gui/interception-callsign-select",int_callsign_select);
            } else {
                int_id_select = -1;
                int_callsign_select = "";
                setprop("fdm/jsbsim/systems/autopilot/gui/interception-callsign-select","");
            }
            setprop("fdm/jsbsim/systems/autopilot/gui/interception-id-select",int_id_select);
        }
    }
    setprop("fdm/jsbsim/systems/autopilot/gui/interception-id-mod",0);
    
}, 0, 1);


setlistener("fdm/jsbsim/systems/autopilot/gui/interception-ai-mp-mod", func {
    
    var ai_mp_mod = getprop("fdm/jsbsim/systems/autopilot/gui/interception-ai-mp-mod");
    if (ai_mp_mod == 1) {
        type_ai_mp = getprop("fdm/jsbsim/systems/autopilot/gui/interception-ai-mp");
        if (type_ai_mp == 1) {
            type_ai_mp_msg = "select type multiplayer airplane";
            setprop("fdm/jsbsim/systems/autopilot/gui/interception-ai-mp-msg",type_ai_mp_msg);
        } else {
            type_ai_mp_msg = "select type AI airplane";
            setprop("fdm/jsbsim/systems/autopilot/gui/interception-ai-mp-msg",type_ai_mp_msg);
        }
        setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-mod",2);
        setprop("fdm/jsbsim/systems/autopilot/gui/interception-ai-mp-mod",0);
    }
    
}, 0, 1);


setlistener("fdm/jsbsim/systems/autopilot/gui/interception-callsign-mod", func {
    
    var callsign_mod = getprop("fdm/jsbsim/systems/autopilot/gui/interception-callsign-mod");
    active_level = getprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active-level");
    if (active_level >= 1 and callsign_mod == 1) {
        var callsign_to_test = getprop("fdm/jsbsim/systems/autopilot/gui/interception-callsign-select");
        var id = isCallsign(callsign_to_test);
        if (id != nil) {
            int_id_select = id;
            int_callsign_select = getCallsign(id);
            setprop("fdm/jsbsim/systems/autopilot/gui/interception-callsign-select",int_callsign_select);
            setprop("fdm/jsbsim/systems/autopilot/gui/interception-list/airplane",getCallsignDescription(id));
        } else {
            int_id_select = -1;
            int_callsign_select = "";
            setprop("fdm/jsbsim/systems/autopilot/gui/interception-callsign-select","");
            setprop("fdm/jsbsim/systems/autopilot/gui/interception-list/airplane","");
        }
        setprop("fdm/jsbsim/systems/autopilot/gui/interception-id-select",int_id_select);
    }
    setprop("fdm/jsbsim/systems/autopilot/gui/interception-callsign-mod",0);
    
}, 0, 1);


setlistener("fdm/jsbsim/systems/autopilot/gui/interception-distance", func {

    int_dist_max = getprop("fdm/jsbsim/systems/autopilot/gui/interception-distance");
    setprop("/instrumentation/radar/range",int_dist_max);

}, 0, 1);


setlistener("fdm/jsbsim/systems/autopilot/gui/interception-list/rw_select", func {

    operateOn_Targets_Scan(3);
    setprop("fdm/jsbsim/systems/autopilot/gui/interception-list/rw_select",0);

}, 0, 1);


var pilot_imp_control = func() {
    
    active_level = getprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active-level");
    if (active_level == 0 or active_level == 1) {
        timeStepDivisor = 1;
    } else {
        if (active_level == 2) {
            timeStepDivisor = 3;
        } else {
            timeStepDivisor = 5;
        }
    }
    delta_time = timeStep / timeStepDivisor;
    pilot_intercept_timer.restart(delta_time);

    if (active_level >= 1) {
        if (timeStepSecond == 1 and active_level == 1) {
            searchCmd_result = searchCmd();
        }
        interception_cnt();
    }
    
    if (timeStepSecond == 1) timeStepSecond = 0;

}


var pilot_intercept_timer = maketimer(delta_time, pilot_imp_control);
pilot_intercept_timer.singleShot = 1;
pilot_intercept_timer.start();

var pilot_intercept_timerLog = maketimer(1, func() {timeStepSecond = 1;});
pilot_intercept_timerLog.start();


