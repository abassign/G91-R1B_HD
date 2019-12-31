# Pilot Impact control system for advert and resolv collision situations
#
# 2019-10-25 Adriano Bassignana
# GPL 2.0+

var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-control-active", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-control-freeze", 1, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-min-z-ft", 400.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-medium-time", 15.0, "DOUBLE");

var timeStep = 1.0;
var timeStepDivisor = 1.0;
var delta_time = 1.0;

var pitch_angle_deg = 0.0;
var speed_fps = 0.0; 
var speed_horz_fps = 0.0;
var speed_down_fps = 0.0;
var imp_min_z_ft = 0.0;
var imp_min_z_ft_lag = 0.0;
var imp_min_z_ft_lag_factor = 1.0;

var imp_medium_time = 0.0;
var imp_cnt_min_time = 0.0;
var imp_cnt_active = 0;
var imp_al = 0.0;

var intensity_calc = 0.0;
var intensity_calc_lag = 0.0;
var imp_T0_lag_int = 0.0;
var imp_T0_lag_int_factor = 0.1;
var neutre_lag = 0.0;
var neutre_lag_adv = 0.0;
var neutre_lag_n = 0;
var neutre_lag_active = 0;
var neutre_lag_factor = 1.0;
var factor_neutre = 0.0;


var radar_elev_beam = func(aAircraftPosition, aHeading, aSpeed_horz_fps, time_sec) {
    var xyz = {"x":aAircraftPosition.x(),"y":aAircraftPosition.y(),"z":aAircraftPosition.z()};
    var end = geo.Coord.new(aAircraftPosition);
    end.apply_course_distance(aHeading, aSpeed_horz_fps * time_sec * FT2M);
    return end;
}

var calculate_imp_geod = func(aAircraftPosition, aHeading, aPitch_angle_absolute) {
    var xyz = {"x":aAircraftPosition.x(),"y":aAircraftPosition.y(),"z":aAircraftPosition.z()};
    var end = geo.Coord.new(aAircraftPosition);
    end.apply_course_distance(aHeading, 1.0);
    var dir_x = end.x()-aAircraftPosition.x();
    var dir_y = end.y()-aAircraftPosition.y();
    var dir_z = math.tan(aPitch_angle_absolute * D2R);
    var dir = {"x":dir_x,"y":dir_y,"z":dir_z};
    return geod = get_cart_ground_intersection(xyz, dir);
}

var calculate_imp_elev = func(aGeod) {
    if (aGeod != nil) {
        return aGeod.elevation;
    } else {
        return -1;
    }
}

var calculate_imp_time = func(aGeod, aAircraftPosition, aElevation, aSpeed_fps) {
    if (aGeod != nil and aElevation > 0.0) {
        var end = geo.Coord.new(aAircraftPosition);
        end.set_latlon(aGeod.lat, aGeod.lon, aElevation);
        var dist = aAircraftPosition.direct_distance_to(end) * M2FT;
        var time_to_impact = dist / aSpeed_fps;
        if (time_to_impact < 0.1) time_to_impact = 0.1;
        return time_to_impact;
    } else {
        return -1;
    }
}

var setIntensty_calc_lag = func(aIntensity_calc,intensity_calc_lag_incr,intensity_calc_lag_dec) {
    var incr = intensity_calc_lag_incr * delta_time;
    var dec = intensity_calc_lag_dec * delta_time;
    if (aIntensity_calc > (intensity_calc_lag + incr / 2)) {
        intensity_calc_lag = intensity_calc_lag + intensity_calc_lag_incr * delta_time;
    } else if (aIntensity_calc < (intensity_calc_lag - dec / 2)) {
        intensity_calc_lag = intensity_calc_lag - intensity_calc_lag_dec * delta_time;
    }
}


var analyze_imp_time = func() {
    
    var debugActive = getprop("fdm/jsbsim/systems/autopilot/gui/debug-active");
    
    #
    # Min time for start the anti-impact procedure
    #
    imp_medium_time = getprop("fdm/jsbsim/systems/autopilot/gui/impact-medium-time");
    imp_cnt_min_time = imp_medium_time * (1 + intensity_calc_lag) / 2.0;
    neutre_lag_factor = imp_medium_time / 2.0;
    
    #
    # Min altitude
    #
    imp_min_z_ft = getprop("fdm/jsbsim/systems/autopilot/gui/impact-min-z-ft");
    
    #
    # Calculate aircraft position and velocity vector
    #
    pitch_angle_deg = getprop("fdm/jsbsim/systems/autopilot/pitch-angle-absolute-deg-lag");
    pitch_angle_tan = math.tan(pitch_angle_deg * 0.0174533);
    
    speed_down_fps  = getprop("velocities/speed-down-fps");
    speed_horz_fps = getprop("fdm/jsbsim/systems/autopilot/speed-true-on-terrain-fps");
    speed_fps = getprop("fdm/jsbsim/systems/autopilot/speed-true-fps");
    var heading = getprop("fdm/jsbsim/systems/autopilot/heading-true-deg");
    var imp_pitch_alpha = 0.0;
    
    #
    # Situation analisys by T0 (orizontal) T1 and T2
    #
    
    var aircraftPosition = geo.aircraft_position();
    
    var h_sl_ft = getprop("fdm/jsbsim/position/h-sl-ft");
    
    var radar_elev_geod = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0];
    var radar_elev_Hsl_ft = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0];
    var radar_elev_is_valid = [0,0,0,0,0,0,0,0,0,0,0,0,0];
    var radar_elev_time = [0.5,0.5,1,2,3,5,10,15,20,25,30,60,120];
    var radar_elev_all_valid = 1;
    var radar_elev_h_T0_ft = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0];
    var radar_elev_h_T1_ft = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0];
    var radar_elev_h_T2_ft = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0];
    var radar_elev_h_T3_ft = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0];
    var radar_prec_T0_sign = 0;
    var radar_prec_T1_sign = 0;
    var radar_prec_T2_sign = 0;
    var radar_prec_T3_sign = 0;
    var radar_chn_T0_sign = -1;
    var radar_chn_T1_sign = -1;
    var radar_chn_T2_sign = -1;
    var radar_chn_T3_sign = -1;
    var radar_elev_T0_max = -999999.0;
    var radar_elev_T1_max = -999999.0;
    var radar_elev_T2_max = -999999.0;
    var radar_elev_T3_max = -999999.0;
    var imp_T0 = 0.0;
    var imp_T1 = 0.0;
    var imp_T2 = 0.0;
    var imp_T3 = 0.0;
    
    var radar_min_alpha_tan = 0.0;
    if (speed_horz_fps > 1.0) radar_min_alpha_tan = - getprop("/position/altitude-agl-ft") / (speed_horz_fps * imp_medium_time);
    
    for (var i=1; i <= 12; i = i + 1) {
        radar_elev_geod[i] = radar_elev_beam(aircraftPosition,heading,speed_horz_fps,radar_elev_time[i]);
        if (i == 1) radar_elev_geod[0] = radar_elev_geod[1];
        if (radar_elev_geod[i] != nil) {
            radar_elev_is_valid[i] = 1;
            var h = geo.elevation(radar_elev_geod[i].lat(),radar_elev_geod[i].lon());
            if (h != nil) {
                radar_elev_Hsl_ft[i] = h / FT2M + imp_min_z_ft;
                # Calculate T0
                radar_elev_h_T0_ft[i] = h_sl_ft - radar_elev_Hsl_ft[i];
                if (radar_chn_T0_sign == -1) {
                    if (i == 1 and radar_elev_h_T0_ft[1] < 0.0) radar_prec_T0_sign = 1;
                    if (radar_elev_h_T0_ft[i] > 0) {
                        if (radar_prec_T0_sign < 0) radar_chn_T0_sign = i - 1;
                    } else {
                        if (radar_prec_T0_sign > 0) radar_chn_T0_sign = i - 1;
                    }
                    if (radar_elev_h_T0_ft[i] > 0) radar_prec_T0_sign = 1 else radar_prec_T0_sign = -1;
                    if (radar_elev_Hsl_ft[i] > radar_elev_T0_max and radar_elev_time[i] <= imp_medium_time) radar_elev_T0_max = radar_elev_Hsl_ft[i];
                }
                ## print("## radar T0 radar_elev_h_T0_ft: ",radar_elev_h_T0_ft[i]," | "," radar_elev_Hsl_ft: ", radar_elev_Hsl_ft[i], " | ",h_sl_ft," | ",i," | radar_prec_T0_sign: ",radar_prec_T0_sign, " radar_elev_T0_max: ",radar_elev_T0_max);
                # Calculate T1
                radar_elev_h_T1_ft[i] = h_sl_ft + (radar_elev_time[i] * speed_horz_fps * pitch_angle_tan) - radar_elev_Hsl_ft[i];
                if (radar_chn_T1_sign == -1) {
                    if (i == 1 and radar_elev_h_T1_ft[1] < 0.0) radar_prec_T1_sign = 1;
                    if (radar_elev_h_T1_ft[i] > 0) {
                        if (radar_prec_T1_sign < 0) radar_chn_T1_sign = i - 1;
                    } else {
                        if (radar_prec_T1_sign > 0) radar_chn_T1_sign = i - 1;
                    }
                    if (radar_elev_h_T1_ft[i] > 0) radar_prec_T1_sign = 1 else radar_prec_T1_sign = -1;
                    if (radar_elev_Hsl_ft[i] > radar_elev_T1_max and radar_elev_time[i] <= imp_medium_time) radar_elev_T1_max = radar_elev_Hsl_ft[i];
                }
                # Calculate T2 (radar_min_alpha_tan)
                radar_elev_h_T2_ft[i] = h_sl_ft + (radar_min_alpha_tan * 1.0) - radar_elev_Hsl_ft[i];
                if (radar_chn_T2_sign == -1) {
                    if (i == 1 and radar_elev_h_T2_ft[1] < 0.0) radar_prec_T2_sign = 1;
                    if (radar_elev_h_T2_ft[i] > 0) {
                        if (radar_prec_T2_sign < 0) radar_chn_T2_sign = i - 1;
                    } else {
                        if (radar_prec_T2_sign > 0) radar_chn_T2_sign = i - 1;
                    }
                    if (radar_elev_h_T2_ft[i] > 0) radar_prec_T2_sign = 1 else radar_prec_T2_sign = -1;
                    if (radar_elev_Hsl_ft[i] > radar_elev_T2_max and radar_elev_time[i] <= imp_medium_time) radar_elev_T2_max = radar_elev_Hsl_ft[i];
                }
                # Calculate T3 (+20 deg)
                radar_elev_h_T3_ft[i] = h_sl_ft + (radar_elev_time[i] * speed_horz_fps * 0.36397023426) - radar_elev_Hsl_ft[i];
                if (radar_chn_T3_sign == -1) {
                    if (i == 1 and radar_elev_h_T3_ft[1] < 0.0) radar_prec_T3_sign = 1;
                    if (radar_elev_h_T3_ft[i] > 0) {
                        if (radar_prec_T3_sign < 0) radar_chn_T3_sign = i - 1;
                    } else {
                        if (radar_prec_T3_sign > 0) radar_chn_T3_sign = i - 1;
                    }
                    if (radar_elev_h_T3_ft[i] > 0) radar_prec_T3_sign = 1 else radar_prec_T3_sign = -1;
                    if (radar_elev_Hsl_ft[i] > radar_elev_T3_max and radar_elev_time[i] <= imp_medium_time) radar_elev_T3_max = radar_elev_Hsl_ft[i];
                }
            } else {
                radar_elev_is_valid[i] = 0;
                radar_elev_all_valid = 0;
            }
        } else {
            radar_elev_is_valid[i] = 0;
            radar_elev_all_valid = 0;
        }
    }
    
    if (radar_elev_all_valid == 1) {
        print("##### H T0: ",radar_chn_T0_sign," : ",radar_elev_time[radar_chn_T0_sign]," Elev: ",radar_elev_Hsl_ft[radar_chn_T0_sign]," Max: ",radar_elev_T0_max);
        print("##### H T1: ",radar_chn_T1_sign," : ",radar_elev_time[radar_chn_T1_sign]," Elev: ",radar_elev_Hsl_ft[radar_chn_T1_sign]," Max: ",radar_elev_T1_max);
        print("##### H T2: ",radar_chn_T2_sign," : ",radar_elev_time[radar_chn_T2_sign]," Elev: ",radar_elev_Hsl_ft[radar_chn_T2_sign]," Max: ",radar_elev_T2_max);
        print("##### H T3: ",radar_chn_T3_sign," : ",radar_elev_time[radar_chn_T3_sign]," Elev: ",radar_elev_Hsl_ft[radar_chn_T3_sign]," Max: ",radar_elev_T3_max);
    }

    var elevation = 0.0;
    var elevation_max = 0.0;
    var intensity = 0.0;
    var time_impact_Min = 999999.0;
    var factor_lag = 0.0;


    if (radar_chn_T0_sign >= 0) {
        imp_T0 = radar_elev_time[radar_chn_T0_sign];
        intensity = intensity + 2.0 * (imp_cnt_min_time / imp_T0);
        if (time_impact_Min > imp_T0 * 0.25) time_impact_Min = imp_T0;
        elevation = radar_elev_T0_max;
        if (intensity > 0) {
            imp_T0_lag_int = intensity;
        }
    }
    factor_lag = imp_T0_lag_int_factor * delta_time;
    if (imp_T0_lag_int > factor_lag) {
        imp_T0_lag_int = imp_T0_lag_int - factor_lag;
    } else {
        imp_T0_lag_int = 0.0;
    }
    
    if (elevation_max < elevation and imp_T0 < imp_cnt_min_time) {
        elevation_max = elevation;
    }
    
    print("#### altitude-QFE-impact-elev T0: ",elevation," T0: ",imp_T0," Ang: 0.0"," intensity: ",intensity, " imp_T0_lag_int: ",imp_T0_lag_int);
    
    if (radar_chn_T1_sign >= 0) {
        imp_T1 = radar_elev_time[radar_chn_T1_sign];
        intensity = intensity + 1.0 * (imp_cnt_min_time / imp_T1);
        if (time_impact_Min > imp_T1 * 1.0) time_impact_Min = imp_T1;
        elevation = radar_elev_T1_max;
        if (elevation_max < elevation and imp_T1 < imp_cnt_min_time) {
            elevation_max = elevation;
        }
    }

    print("#### altitude-QFE-impact-elev T1: ",elevation," T1: ",imp_T1," Ang: ",1.0 * pitch_angle_deg, " intensity: ",intensity);
    
    if (radar_chn_T2_sign >= 0) {
        imp_T2 = radar_elev_time[radar_chn_T2_sign];
        intensity = intensity + 0.25 * (imp_cnt_min_time / imp_T2);
        if (time_impact_Min > imp_T2 * 1.0) time_impact_Min = imp_T2;
        elevation = radar_elev_T2_max;
    }
    
    if (elevation_max < elevation and imp_T2 < imp_cnt_min_time) {
        elevation_max = elevation;
    }
    print("#### altitude-QFE-impact-elev T2: ",elevation," T2: ",imp_T2," Ang: ",1.5 * pitch_angle_deg, " intensity: ",intensity);
    
    if (radar_chn_T3_sign >= 0) {
        imp_T3 = radar_elev_time[radar_chn_T3_sign];
        intensity = intensity + 4.0 * (imp_cnt_min_time / imp_T3);
        if (time_impact_Min > imp_T3 * 0.25) time_impact_Min = imp_T3;
        elevation = radar_elev_T3_max;
    }

    if (elevation_max < elevation and imp_T3 < ((imp_medium_time / 5.0) * imp_cnt_min_time)) {
        elevation_max = elevation;
    }
    print("#### altitude-QFE-impact-elev T3: ",elevation," T3: ",imp_T3," Ang: ", 20.0, " intensity: ",intensity);
    
    if (imp_T0_lag_int >= 1.0 and time_impact_Min < imp_cnt_min_time) {
        intensity_calc = 0.5 + 1.0 * math.ln(1.0 + intensity * 30.0 * (((30.0 - imp_medium_time) / 30.0) / time_impact_Min));
        neutre_lag_adv = neutre_lag_adv + intensity_calc;
        neutre_lag_n = neutre_lag_n + 1;
        neutre_lag_active = 0;
        neutre_lag = 0.0;
    } else {
        intensity_calc = 0.5;
        if (neutre_lag_active == 0 and neutre_lag_n > 0) {
            neutre_lag = neutre_lag_adv / neutre_lag_n;
            neutre_lag_active = 1;
            neutre_lag_adv = 0.0;
            neutre_lag_n = 0;
            factor_neutre = (neutre_lag * delta_time) / neutre_lag_factor;
            print("#####: ",neutre_lag_factor," | ",delta_time," | ",factor_neutre);
        } else {
            if (neutre_lag > factor_neutre) {
                neutre_lag = neutre_lag - factor_neutre;
            } else {
                neutre_lag = 0.0;
                neutre_lag_active = 0;
            }
        }
    }
        
    if (time_impact_Min > 10) {
        setIntensty_calc_lag(intensity_calc, 0.7,0.5);
    } else {
        setIntensty_calc_lag(intensity_calc, 0.7,0.5);
    }
    
    var ground_elev_m = getprop("/position/ground-elev-m");
    
    setprop("fdm/jsbsim/systems/autopilot/altitude-QFE-impact-elev-ft",elevation_max * M2FT);
    setprop("fdm/jsbsim/systems/autopilot/altitude-QFE-impact-elev-intensity",intensity_calc_lag);
    if (imp_cnt_active == 1) {
        setprop("fdm/jsbsim/systems/autopilot/altitude-QFE-impact-elev-neutre",neutre_lag);
    } else {
        setprop("fdm/jsbsim/systems/autopilot/altitude-QFE-impact-elev-neutre",0.0);
        setprop("fdm/jsbsim/systems/autopilot/pitch-output-error-coefficient-gain",2 * intensity_calc_lag);
    }
    
    print("#### altitude-QFE elevation_max: ",elevation_max * M2FT, " imp_T0_lag_int: ",imp_T0_lag_int," intensity: ", intensity_calc, " ( ",intensity, " | lag: ", intensity_calc_lag," ) imp_cnt_min_time: ",imp_cnt_min_time," | ",time_impact_Min," neutre: ",neutre_lag," | ",factor_neutre," | ",neutre_lag_active);
    
}


var pilot_imp_control = func() {
    
    imp_cnt_active = getprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active");
    analyze_imp_time();
    
    if (imp_cnt_active == 0) {
        timeStepDivisor = 1;
    } else {
        if (intensity_calc_lag < 0.7) {
            timeStepDivisor = 2;
        } else {
            timeStepDivisor = 5;
        }
    }
    delta_time = timeStep / timeStepDivisor;
    pilot_imp_controlTimer.restart(delta_time);

}


var pilot_imp_controlTimer = maketimer(delta_time, pilot_imp_control);
pilot_imp_controlTimer.singleShot = 1;
pilot_imp_controlTimer.start();
