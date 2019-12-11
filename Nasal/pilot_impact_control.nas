# Pilot Impact control system for advert and resolv collision situations
#
# 2019-10-25 Adriano Bassignana
# GPL 2.0+

var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-control-active", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-control-freeze", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-al-lag", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-time", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-time-array-dim", 30, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-time-derivate", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-time-time-delayed", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-rugosity-value", 0, "DOUBLE");

var speed_fps = 0.0; 
var speed_horz_fps = 0.0;
var speed_down_fps = 0.0;
var min_z_ft = 0.0;
var min_z_ft_lag = 0.0;
var min_z_ft_lag_factor = 1.0;

var impact_cnt_med_time = 0.0;

var timeStep = 1.0;
var timeStepDivisor = 1.0;
var delayCycleGeneral = 0;

var impact_cnt_active = 0;
var impact_cnt_freeze = 1;
var impact_al = 0.0;
var impact_al_lag = 0.0;
var impact_al_reduction_coeff = 2.0;

var delta_time = 0.0;
var impact_T_calc_time_delayed = 0.0;

var impact_T_calc = 0.0;
var impact_T_calc_avr = 0.0;
var impact_T_calc_ist_avr = 0.0;
var impact_T_calc_array = std.Vector.new();
var impact_T_calc_array_dim = 0.0;
var impact_T_calc_der = 0.0;
var impact_T_calc_rugosity = 0.0;

var impact_T0 = 0.0;
var impact_T1 = 0.0;
var impact_T2 = 0.0;


var calculate_impact_time = func(aircraftPosition, heading, aSpeed_down_fps) {
    var end = geo.Coord.new(aircraftPosition);
    end.apply_course_distance(heading, speed_horz_fps * FT2M);
    end.set_alt(end.alt() - aSpeed_down_fps * FT2M);
    
    var dir_x = end.x()-aircraftPosition.x();
    var dir_y = end.y()-aircraftPosition.y();
    var dir_z = end.z()-aircraftPosition.z();
    var zMod = aircraftPosition.z() - min_z_ft_lag * FT2M;
    var xyz = {"x":aircraftPosition.x(),"y":aircraftPosition.y(),"z":zMod};
    var dir = {"x":dir_x,"y":dir_y,"z":dir_z};

    var geod = get_cart_ground_intersection(xyz, dir);
    if (geod != nil and math.abs(speed_fps) > 0.1) {
        var elevationCorrect = geod.elevation;
        end.set_latlon(geod.lat, geod.lon, elevationCorrect);
        var dist = aircraftPosition.direct_distance_to(end) * M2FT;
        var time_to_impact = dist / speed_fps;
        if (time_to_impact < 0.1) time_to_impact = 0.1;
        return time_to_impact;
    } else {
        return -1;
    }
}


var analyze_impact_time = func() {
    
    impact_cnt_med_time = getprop("fdm/jsbsim/systems/autopilot/gui/impact-medium-time");
    impact_T_calc_array_dim = getprop("fdm/jsbsim/systems/autopilot/gui/impact-time-array-dim");
    
    impact_T_calc_array_dim = impact_cnt_med_time; ## Test, verificare
    
    
    min_z_ft = getprop("fdm/jsbsim/systems/autopilot/gui/impact-min-z-ft");
    if (math.abs(min_z_ft_lag - min_z_ft) > (1.2 * min_z_ft_lag_factor)) {
        min_z_ft_lag = min_z_ft;
    } else if (min_z_ft_lag > min_z_ft) {
        min_z_ft_lag = min_z_ft_lag - min_z_ft_lag_factor;
    } else {
        min_z_ft_lag = min_z_ft_lag + min_z_ft_lag_factor;
    }
    
    #
    # Calculate aircraft position and velocity vector
    #
    
    var aircraftPosition = geo.aircraft_position();
    speed_down_fps  = getprop("velocities/speed-down-fps");
    var speed_east_fps  = getprop("velocities/speed-east-fps");
    var speed_north_fps = getprop("velocities/speed-north-fps");
    speed_horz_fps  = math.sqrt((speed_east_fps * speed_east_fps) + (speed_north_fps * speed_north_fps));
    speed_fps = math.sqrt((speed_horz_fps * speed_horz_fps) + (speed_down_fps * speed_down_fps));
    var heading = 0;
    var impact_al_lag_mod = 0.0;
    if (speed_horz_fps > 0.1 or speed_horz_fps < -0.1) {
        if (speed_north_fps >= 0) {
            heading -= math.acos(speed_east_fps/speed_horz_fps)*R2D - 90;
        } else {
            heading -= -math.acos(speed_east_fps/speed_horz_fps)*R2D - 90;
        }
    }
    heading = geo.normdeg(heading);
    
    #
    # Situation analisys
    #
    
    impact_T1 = calculate_impact_time(aircraftPosition, heading, speed_down_fps);
    if (impact_T1 < 0.0) impact_T1 = 0.0;
    
    impact_T0 = calculate_impact_time(aircraftPosition, heading, 0);
    if (impact_T0 < 0.0) impact_T0 = 0.0;
    
    impact_T2 = calculate_impact_time(aircraftPosition, heading, speed_down_fps * 1.5);
    if (impact_T2 < 0.0) impact_T2 = 0.0;
    
    impact_T_calc_ist_avr = (impact_T0 + impact_T1 + impact_T2) / 3;
    if (impact_T0 < impact_cnt_med_time) {
        impact_T_calc = (0.0 + impact_T1 + impact_T2) / 3;
    } else {
        impact_T_calc = (impact_T1 + impact_T2) / 2;
    }
    if (impact_T_calc < 0.5 and impact_T0 > 0.0 and impact_T0 < impact_cnt_med_time) impact_T_calc = impact_T0;
    
    print("#### impact_T0: ",impact_T0," impact_T1: ",impact_T1," impact_T2: ",impact_T2, " impact_T_calc: ",impact_T_calc);
    
    #
    # Calculate derivate and rugosity
    #
    impact_T_calc_der = 0.0;
    impact_T_calc_rugosity = 0.0;
    impact_cnt_freeze = 0;
    impact_al = 0.0;
    impact_T_calc_avr = 0.0;
    
    if (impact_T_calc > 0) {
        while(impact_T_calc_array.size() >= impact_T_calc_array_dim and impact_T_calc_array.size() >= 2) {
            var j = impact_T_calc_array.pop(0);
        }
        impact_T_calc_array.append(impact_T_calc);
        if (impact_T_calc_array.size() >= 2) {
            var i = 0;
            var impact_T_calc_der_val_prec = 0.0;
            foreach (var value; impact_T_calc_array.vector) {
                if (i == 0) {
                    impact_T_calc_der_val_prec = value;
                } else {
                    impact_T_calc_der = impact_T_calc_der + (value - impact_T_calc_der_val_prec) / delta_time;
                    impact_T_calc_der_val_prec = value;
                    impact_T_calc_rugosity = impact_T_calc_rugosity + math.log10(1 + math.abs(impact_T_calc_der));
                    impact_T_calc_avr = impact_T_calc_avr + value;
                }
                i = i + 1;
            }
            impact_T_calc_avr = impact_T_calc_avr / impact_T_calc_array.size();
            impact_T_calc_der = impact_T_calc_der / impact_T_calc_array.size();
            impact_T_calc_rugosity = impact_T_calc_rugosity / impact_T_calc_array.size();
        }
    } else {
        if (impact_T_calc_array.size() > 0) impact_T_calc_array.clear();
        impact_cnt_freeze = 1;
    }
    
    if (impact_cnt_freeze == 0 and impact_T_calc_avr >= 0) {
        if (impact_T_calc_avr < impact_cnt_med_time * 3.0) {
            impact_al = (10 / (5 * math.ln((impact_T_calc_avr + 0.81) * 1.6 - 0.2)));
        } else {
            impact_al = 0.0;
        }
        var impact_al_mod = impact_al * ( 1 + 2 * impact_T_calc_rugosity);
        if (math.abs(impact_al_mod) <= (impact_al_reduction_coeff * delta_time * (1 + impact_T_calc_rugosity))) {
            impact_al_lag = impact_al_mod;
        } else if (impact_al_lag > impact_al_mod) {
            impact_al_lag = impact_al_lag - (impact_al_reduction_coeff * delta_time * (1 + impact_T_calc_rugosity));
        } else {
            impact_al_lag = impact_al_lag + (impact_al_reduction_coeff * delta_time * (1 + impact_T_calc_rugosity));
        }
        if (impact_T_calc_der < -1.0) {
            impact_al_lag_mod = impact_al_lag * (1 + math.log10(-impact_T_calc_der));
        } else {
            impact_al_lag_mod = impact_al_lag;
        }
    } else {
        impact_al_lag = 0.0;
        impact_al_lag_mod = 0.0;
    }
    
    if ((math.abs(impact_T0 - impact_T_calc_ist_avr) < 0.1) or (impact_T1 < 0.5 and impact_T2 < 0.5)) {
        impact_al_lag_mod = impact_al_lag_mod * 4.0;
    } else {
        if (math.abs(impact_T0 - impact_T_calc_ist_avr) < 3.0) {
            impact_al_lag_mod = impact_al_lag_mod * (1 + 3/(math.abs(impact_T0 - impact_T_calc_avr)));
        } else {
            impact_al_lag_mod = impact_al_lag_mod * (1 + 1/(math.abs(impact_T0 - impact_T_calc_avr)));
        }
    }
    if (impact_al_lag_mod > 20.0) impact_al_lag_mod = 20;
    
    #
    # Report the response
    #
    setprop("fdm/jsbsim/systems/autopilot/gui/impact-al-lag",impact_al_lag_mod);
    setprop("fdm/jsbsim/systems/autopilot/gui/impact-time",impact_T_calc_avr);
    setprop("fdm/jsbsim/systems/autopilot/gui/impact-time-derivate",impact_T_calc_der);
    setprop("fdm/jsbsim/systems/autopilot/gui/impact-time-rugosity",impact_T_calc_rugosity);
    setprop("fdm/jsbsim/systems/autopilot/gui/impact-time-time-delayed",impact_T_calc_time_delayed);
    setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-freeze",impact_cnt_freeze);
    
    print(sprintf("Pilot Impact ctl > ")
        ,sprintf(" DT: %1.2f",delta_time)
        ,sprintf(" Dim: %2d",impact_T_calc_array.size())
        ,sprintf(" is freeze: %1d",impact_cnt_freeze)
        ,sprintf(" impact T: %3.1f",impact_T_calc)
        ,sprintf(" allert: %3.1f",impact_al)
        ,sprintf(" (imp lag: %3.1f",impact_al_lag)
        ,sprintf(" | alpha: %3.1f)",impact_al_lag_mod)
        ,sprintf(" der: %3.1f",impact_T_calc_der)
        ,sprintf(" rug: %3.1f",impact_T_calc_rugosity)
        ,sprintf(" | Super: %1d",getprop("fdm/jsbsim/systems/autopilot/pitch-alpha-super-active"))
        ,sprintf(" C1: %3.1f",getprop("fdm/jsbsim/systems/autopilot/pitch-alpha-input-lag-C1"))
    );
    
}


var pilot_impact_control = func() {
    
    impact_cnt_active = getprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active");
    analyze_impact_time();
    
    if (impact_cnt_active == 0) {
        timeStepDivisor = 1;
    } else {
        if (impact_al >= 1.0) {
            timeStepDivisor = 5;
        } else {
            timeStepDivisor = 2;
        }
    }
    delta_time = timeStep / timeStepDivisor;
    pilot_impact_controlTimer.restart(delta_time);

}


var pilot_impact_controlTimer = maketimer(delta_time, pilot_impact_control);
pilot_impact_controlTimer.singleShot = 1;
pilot_impact_controlTimer.start();
