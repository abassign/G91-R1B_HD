# Self-piloting by air interception
#
# 2020-08-15 Adriano Bassignana
# GPL 2.0+
#
# http://wiki.flightgear.org/Canvas_MapStructure

var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-control-active", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-control-mod", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-control-active-level", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-control-msg", "Idle", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-distance", 100, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-id-select", -1, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-id-mod",0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-callsign-select", "", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-callsign-mod",0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/interception-target-dist-nm",0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/interception-target-speed-mph",0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/interception-target-speed-dif-mph",0, "DOUBLE");

var timeStep = 1.0;
var timeStepDivisor = 1.0;
var delta_time = 1.0;
var timeStepSecond = 0;

var target_dist_adv_vector = std.Vector.new([]);
var target_dist_adv_acc = 0.0;

var int_cnt_active = 0;
var active_level = 0;
var int_id_select = -1;
var int_callsign_select = "";
var targets_scan = {};

var int_cnt_min_speed_mph = 150.0;
var int_cnt_max_speed_mph = 450.0;
var int_cnt_max_h_ft = 32000.0;

var int_dist_max = 100.0;

var target_coord = geo.Coord.new();
var target_coord_mod = geo.Coord.new();
var airplane = nil;

var min_target_dist = 0.1;
var speed_mph_target = 0.0;
var speed_mph_coefficient = 2.0;
var speed_mph = 0.0;


var searchCmd = func() {
    #// The algoritm i described in this link:
    #// http://wiki.flightgear.org/index.php?title=Howto:Working_with_AI_and_MP_properties&mobileaction=toggle_view_desktop
    #// /instrumentation/radar/range set the distance
    #// /ai/models/aircraft[n]/radar if the range permit to discover the airplane the system return the correct information
           
    airplane = geo.aircraft_position();
    var list = props.globals.getNode("/ai/models/").getChildren("aircraft");
    var total = size(list);
    var nearest_id = -1;
    var nearest_nm = 999.0;
    print("----[",total,"]----");
    targets_scan = {};
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
            var course_to_deg = airplane.course_to(target_coord);
            targets_scan[callsign] = [i,callsign,true_airspeed_kt,target_dist_nm,target_h_ft,course_to_deg];
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


var target_dist_adv = func(distance, size) {
    
    var distance_dif = distance;
    target_dist_adv_vector.insert(-1,distance);
    while (target_dist_adv_vector.size() > size) {
        distance_dif = distance_dif - target_dist_adv_vector.pop(0);
    }
    target_dist_adv_acc = target_dist_adv_acc + distance_dif;
    return target_dist_adv_acc / target_dist_adv_vector.size();
    
}


var interception_cnt = func() {
    
    if (int_id_select >= 0) {
        var list = props.globals.getNode("/ai/models/").getChildren("aircraft");
        var radar = list[int_id_select].getNode("radar");
        if (radar != nil) {
            setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active-level",1);
            var in_range = radar.getNode("in-range").getValue();
            var speed_mph_target = list[int_id_select].getNode("velocities").getNode("true-airspeed-kt").getValue();
            var me_airplane_speed = getprop("fdm/jsbsim/systems/autopilot/speed-true-on-air");
            var speed_dif_mph_target = speed_mph_target - me_airplane_speed;
            var vertical_speed_best_by_altitude = getprop("fdm/jsbsim/systems/autopilot/vertical-speed-optimize-by-altitude");
            var altitude_selected_ft_dif = getprop("fdm/jsbsim/systems/autopilot/altitude-selected-ft-dif");
            var speed_min_by_alt = getprop("fdm/jsbsim/systems/autopilot/speed-best-by-altitude") * 0.7;
            if (in_range and speed_mph_target >= int_cnt_min_speed_mph and speed_mph_target <= int_cnt_max_speed_mph) {
                var distFromTarget = 0.0;
                var callsign = list[int_id_select].getNode("callsign").getValue();
                var position = list[int_id_select].getNode("position");
                var orientation = list[int_id_select].getNode("orientation");
                var target_h_ft =  position.getNode("altitude-ft").getValue();
                var target_true_heading_deg = orientation.getNode("true-heading-deg").getValue();
                target_coord.set_latlon(position.getNode("latitude-deg").getValue(),position.getNode("longitude-deg").getValue());
                var target_dist_nm = target_dist_adv(math.abs(airplane.distance_to(target_coord) * 0.000621371),20);
                
                #// Calculate dist min_target_dist
                var min_target_dist_increment = target_dist_nm + (altitude_selected_ft_dif * speed_dif_mph_target) / (vertical_speed_best_by_altitude * 60.0);
                if (min_target_dist_increment > 0) {
                    min_target_dist_increment = 0.0;
                }
                
                #// set speed and active_level
                if (target_dist_nm > (10.0 - min_target_dist_increment)) {
                    speed_mph = 520.0;
                    active_level = 2;
                    distFromTarget = 5.0 + 2.0 * math.log10(target_dist_nm);
                } else if (target_dist_nm > (min_target_dist - min_target_dist_increment)) {
                    active_level = 3;
                    speed_mph = speed_mph_target + speed_mph_coefficient * (100.0 / (10.0 - target_dist_nm));
                    distFromTarget = target_dist_nm - (10.0 - min_target_dist_increment);
                } else {
                    active_level = 4;
                    speed_mph = speed_mph_target - speed_mph_coefficient * (100.0 / (10.0 - target_dist_nm));
                    distFromTarget = target_dist_nm - (10.0 - min_target_dist_increment);
                }
                if (speed_mph < speed_min_by_alt) speed_mph = speed_min_by_alt;
                target_coord_mod = target_coord.apply_course_distance(target_true_heading_deg, -distFromTarget * 1852.0);
                var course_to_deg = airplane.course_to(target_coord_mod);
                print(
                    sprintf("*** active_level: %1.0f",active_level),
                    sprintf(" target_dist_nm: %3.1f",target_dist_nm),
                    sprintf(" distFromTarget: %3.1f",distFromTarget),
                    sprintf(" target_true_heading_deg: %3.1f",target_dist_nm),
                    sprintf(" course_to_deg: %3.1f",course_to_deg),
                    sprintf(" dif_deg: %3.1f",(target_true_heading_deg - course_to_deg)),
                    sprintf(" VS bt Alt: %4.0f",vertical_speed_best_by_altitude),
                    sprintf(" Speed dif: %3.1f",speed_dif_mph_target),
                    sprintf(" dif ft: %5.0f",altitude_selected_ft_dif),
                    sprintf(" T. speed inc: %5.1f",min_target_dist_increment)
                );
                if (active_level > 2) {
                    var heading_correction_deg = target_true_heading_deg - course_to_deg;
                    if (heading_correction_deg > 180) heading_correction_deg = heading_correction_deg - 360;
                    if (heading_correction_deg < -180) heading_correction_deg = heading_correction_deg + 360;
                    var heading_factor = 2.0;
                    if (math.abs(heading_correction_deg) < 10.0 and math.abs(heading_correction_deg) > 2.0) {
                        heading_factor = 2.0 + 4 * math.abs(heading_correction_deg);
                    } else if (math.abs(heading_correction_deg) <= 2 and math.abs(heading_correction_deg) > 0.05) {
                        heading_factor = 4.0 + 12 * math.abs(heading_correction_deg);
                    }
                    var heading_correction_deg_mod = heading_correction_deg * heading_factor * 0.6;
                    if (heading_correction_deg_mod > 30.0) heading_correction_deg_mod = 30;
                    if (heading_correction_deg_mod < -30.0) heading_correction_deg_mod = -30;
                    course_to_deg = target_true_heading_deg - heading_correction_deg_mod;
                    if (course_to_deg > 180) course_to_deg = course_to_deg - 360;
                    if (course_to_deg < -180) course_to_deg = course_to_deg + 360;
                    # print("*** active_level > 2 ", active_level, " ",heading_correction_deg," ",course_to_deg);
                }
                setprop("fdm/jsbsim/systems/autopilot/gui/vertical-speed-fpm",vertical_speed_best_by_altitude);
                setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active-level",active_level);
                setprop("fdm/jsbsim/systems/autopilot/interception-target-dist-nm",target_dist_nm);
                setprop("fdm/jsbsim/systems/autopilot/interception-target-speed-mph",speed_mph_target);
                setprop("fdm/jsbsim/systems/autopilot/interception-target-speed-dif-mph",speed_dif_mph_target);
                setprop("fdm/jsbsim/systems/autopilot/interception-true-heading-deg",target_true_heading_deg);
                setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",speed_mph);
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",course_to_deg);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",target_h_ft);
                
                
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
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-value",math.round(speed_cas_prec));
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-set-best-by-altitude",speed_set_best_prec);
            setprop("fdm/jsbsim/systems/autopilot/gui/interception-id-select",-1);
            setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active-level",active_level);
            setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active",0);
        }
    }
    
}


var pilot_imp_control = func() {
    
    active_level = getprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active-level");
    if (active_level == 0 or active_level == 1) {
        timeStepDivisor = 1;
    } else {
        if (active_level == 2) {
            timeStepDivisor = 2;
        } else {
            timeStepDivisor = 4;
        }
    }
    delta_time = timeStep / timeStepDivisor;
    pilot_intercept_timer.restart(delta_time);

    if (int_cnt_active) {
        if (timeStepSecond == 1 and active_level == 1) {
            searchCmd_result = searchCmd();
        }
        interception_cnt();
    }
    
    if (timeStepSecond == 1) timeStepSecond = 0;

}


setlistener("fdm/jsbsim/systems/autopilot/gui/landig-sub-status-id", func {
    
    var landig_sub_status_id = getprop("fdm/jsbsim/systems/autopilot/gui/landig-sub-status-id");
    if (landig_sub_status_id > 0.0 and (landig_sub_status_id < 11.0 and landig_sub_status_id >= 12.0)) {
        int_cnt_active = 0;
        active_level = 0;
        setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active",int_cnt_active);
        setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active-level",active_level);
        setprop("fdm/jsbsim/systems/autopilot/gui/interception-id-select",-1);
        setprop("fdm/jsbsim/systems/autopilot/gui/interception-callsign-select","");
    }
    
}, 1, 1);


setlistener("fdm/jsbsim/systems/autopilot/gui/interception-control-mod", func {

    var int_cnt_mod = getprop("fdm/jsbsim/systems/autopilot/gui/interception-control-mod");
    if (int_cnt_mod == 1) {
        int_cnt_active = getprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active");
        if (int_cnt_active == 1) {
            var landig_sub_status_id = getprop("fdm/jsbsim/systems/autopilot/gui/landig-sub-status-id");
            if (landig_sub_status_id == 0 or (landig_sub_status_id >= 11.0 and landig_sub_status_id < 12.0)) {
                active_level = 1;
                setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active-level",1);
                setprop("/instrumentation/radar/range",int_dist_max);
            } else {
                int_cnt_active = 0;
                active_level = 0;
            }
        }
        if (int_cnt_active == 0) {
            setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active",0);
            setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-msg","Idle");
            setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active-level",0);
            setprop("fdm/jsbsim/systems/autopilot/gui/interception-id-select",-1);
            setprop("fdm/jsbsim/systems/autopilot/gui/interception-callsign-select","");
            #// Heading
            setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",math.round(getprop("fdm/jsbsim/systems/autopilot/heading-true-deg")));
            setprop("fdm/jsbsim/systems/autopilot/gui/true-heading",1.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/heading-control",1.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/wing-leveler",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/phi-heading",0.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/rudder-auto-coordination",1.0);
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
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-throttle",1.0);
            setprop("fdm/jsbsim/systems/autopilot/gui/speed-pitch",0.0);
        } else {
            if (active_level == 1) {
                #// Heading
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading-deg",math.round(getprop("fdm/jsbsim/systems/autopilot/heading-true-deg")));
                setprop("fdm/jsbsim/systems/autopilot/gui/true-heading",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/heading-control",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/wing-leveler",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/phi-heading",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/rudder-auto-coordination",1.0);
                #// Altitude
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-active",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-hold-ft",math.round(getprop("fdm/jsbsim/systems/autopilot/h-sl-ft-lag")));
                setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active",1.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/altitude-QFE",0.0);
                setprop("fdm/jsbsim/systems/autopilot/gui/pitch-angle-deg",6.0);
                #// Speed
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
            }
            setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-msg","Active");
        }
        setprop("fdm/jsbsim/systems/autopilot/gui/interception-control-mod",0);
    }

}, 1, 1);


setlistener("fdm/jsbsim/systems/autopilot/gui/interception-id-mod", func {
    
    var id_mod = getprop("fdm/jsbsim/systems/autopilot/gui/interception-id-mod");
    if (int_cnt_active == 1 and id_mod == 1) {
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
    setprop("fdm/jsbsim/systems/autopilot/gui/interception-id-mod",0);
    
}, 1, 1);


setlistener("fdm/jsbsim/systems/autopilot/gui/interception-callsign-mod", func {
    
    var callsign_mod = getprop("fdm/jsbsim/systems/autopilot/gui/interception-callsign-mod");
    if (int_cnt_active == 1 and callsign_mod == 1) {
        var callsign_to_test = getprop("fdm/jsbsim/systems/autopilot/gui/interception-callsign-select");
        var id = isCallsign(callsign_to_test);
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
    setprop("fdm/jsbsim/systems/autopilot/gui/interception-callsign-mod",0);
    
}, 1, 1);


setlistener("fdm/jsbsim/systems/autopilot/gui/interception-distance", func {

    int_dist_max = getprop("fdm/jsbsim/systems/autopilot/gui/interception-distance");
    setprop("/instrumentation/radar/range",int_dist_max);

}, 1, 1);


var pilot_intercept_timer = maketimer(delta_time, pilot_imp_control);
pilot_intercept_timer.singleShot = 1;
pilot_intercept_timer.start();

var pilot_intercept_timerLog = maketimer(1, func() {timeStepSecond = 1;});
pilot_intercept_timerLog.start();


