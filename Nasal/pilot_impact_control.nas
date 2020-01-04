# Pilot Impact control system for advert and resolv collision situations
#
# 2019-10-25 Adriano Bassignana
# GPL 2.0+

var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-control-active", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-control-freeze", 1, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-min-z-ft", 200.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-min-z-ft-mod", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-medium-time", 10.0, "DOUBLE");

var timeStep = 1.0;
var timeStepDivisor = 1.0;
var delta_time = 1.0;

var testing_log_active = 0;

var pitch_angle_deg = 0.0;
var speed_fps = 0.0; 
var speed_horz_fps = 0.0;
var speed_down_fps = 0.0;
var imp_min_z_ft = 0.0;
var imp_min_z_ft_lag = 0.0;
var imp_min_z_ft_factor = 1.0;

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

var complex_factor = 1.0;


var radar_elv_beam = func(aAircraftPosition, aHeading, aSpeed_horz_fps, time_sec) {
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
    
    testing_log_active = getprop("sim/G91/testing/log");
    if (testing_log_active == nil) testing_log_active = 0;
    
    #
    # Min time for start the anti-impact procedure
    #
    imp_medium_time = getprop("fdm/jsbsim/systems/autopilot/gui/impact-medium-time") * complex_factor;
    imp_cnt_min_time = imp_medium_time * (1 + intensity_calc_lag) / 2.0;
    neutre_lag_factor = imp_medium_time / 2.0;
    speed_horz_fps = getprop("fdm/jsbsim/systems/autopilot/velocity-on-ground-fps-lag");
    speed_horz_mph = getprop("fdm/jsbsim/systems/autopilot/velocity-on-ground-mph-lag");

    #
    # Min altitude
    #
    imp_min_z_ft = getprop("fdm/jsbsim/systems/autopilot/gui/impact-min-z-ft") * complex_factor;
    var speed_horz_Coef = (speed_horz_mph / 160.0) - 1.0;
    if (speed_horz_Coef < 0.0) speed_horz_Coef = 0.0;
    imp_min_z_ft = imp_min_z_ft * speed_horz_Coef;
    var imp_min_z_ft_delta = imp_min_z_ft_factor * delta_time * math.ln(1.0 + 2.0 * math.abs(imp_min_z_ft - imp_min_z_ft_lag));
    if (math.abs(imp_min_z_ft - imp_min_z_ft_lag) > imp_min_z_ft_delta) {
        if (imp_min_z_ft > imp_min_z_ft_lag) {
            imp_min_z_ft_lag = imp_min_z_ft_lag + imp_min_z_ft_delta;
        } else {
            imp_min_z_ft_lag = imp_min_z_ft_lag - imp_min_z_ft_delta;
        } 
    }
    setprop("fdm/jsbsim/systems/autopilot/gui/impact-min-z-ft-mod",imp_min_z_ft_lag);
    
    #
    # Calculate aircraft position and velocity vector
    #
    pitch_angle_deg = getprop("fdm/jsbsim/systems/autopilot/pitch-angle-absolute-deg-lag");
    var pitch_ang_tan = math.tan(pitch_angle_deg * 0.0174533);
    
    speed_down_fps  = getprop("velocities/speed-down-fps");
    speed_fps = getprop("fdm/jsbsim/systems/autopilot/speed-true-fps");
    var heading = getprop("fdm/jsbsim/systems/autopilot/heading-true-deg");
    var imp_pitch_alpha = 0.0;
    
    #
    # Situation analisys by T0 (orizontal) T1 and T2
    #
    
    var aircraftPosition = geo.aircraft_position();
    
    var h_sl_ft = getprop("fdm/jsbsim/position/h-sl-ft");
    
    var radar_elv_n = 13;
    var radar_elv_geod = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0];
    var radar_elv_sum = 0.0;
    var radar_elv_min = 999999.0;
    var radar_elv_max = 0.0;
    var radar_elv_Hsl_ft = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0];
    var radar_elv_is_valid = [0,0,0,0,0,0,0,0,0,0,0,0,0];
    var radar_elv_time = [0.5,0.5,1,2,3,5,10,15,20,25,30,60,120];
    var radar_elv_all_valid = 1;
    var radar_elv_h_T0_ft = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0];
    var radar_elv_h_T1_ft = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0];
    var radar_elv_h_T2_ft = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0];
    var radar_elv_h_T3_ft = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0];
    var radar_prc_T0_sign = 0;
    var radar_prc_T1_sign = 0;
    var radar_prc_T2_sign = 0;
    var radar_prc_T3_sign = 0;
    var radar_chn_T0_sign = -1;
    var radar_chn_T1_sign = -1;
    var radar_chn_T2_sign = -1;
    var radar_chn_T3_sign = -1;
    var radar_elv_T0_max = -999999.0;
    var radar_elv_T1_max = -999999.0;
    var radar_elv_T2_max = -999999.0;
    var radar_elv_T3_max = -999999.0;
    var imp_T0 = 0.0;
    var imp_T1 = 0.0;
    var imp_T2 = 0.0;
    var imp_T3 = 0.0;
    
    var radar_min_alpha_tan = 0.0;
    if (speed_horz_fps > 1.0) radar_min_alpha_tan = - getprop("/position/altitude-agl-ft") / (speed_horz_fps * imp_medium_time);
    
    for (var i = 1; i < radar_elv_n; i = i + 1) {
        radar_elv_geod[i] = radar_elv_beam(aircraftPosition,heading,speed_horz_fps,radar_elv_time[i]);
        if (i == 1) radar_elv_geod[0] = radar_elv_geod[1];
        if (radar_elv_geod[i] != nil) {
            radar_elv_is_valid[i] = 1;
            var h = geo.elevation(radar_elv_geod[i].lat(),radar_elv_geod[i].lon());
            if (h != nil) {
                if (radar_elv_min > h) radar_elv_min = h;
                if (radar_elv_max < h) radar_elv_max = h;
                radar_elv_sum = radar_elv_sum + h;
                radar_elv_Hsl_ft[i] = h / FT2M + imp_min_z_ft_lag;
                # Calculate T0
                radar_elv_h_T0_ft[i] = h_sl_ft - radar_elv_Hsl_ft[i];
                if (radar_chn_T0_sign == -1) {
                    if (i == 1 and radar_elv_h_T0_ft[1] < 0.0) radar_prc_T0_sign = 1;
                    if (radar_elv_h_T0_ft[i] > 0) {
                        if (radar_prc_T0_sign < 0) radar_chn_T0_sign = i - 1;
                    } else {
                        if (radar_prc_T0_sign > 0) radar_chn_T0_sign = i - 1;
                    }
                    if (radar_elv_h_T0_ft[i] > 0) radar_prc_T0_sign = 1 else radar_prc_T0_sign = -1;
                    if (radar_elv_Hsl_ft[i] > radar_elv_T0_max and radar_elv_time[i] <= imp_medium_time) radar_elv_T0_max = radar_elv_Hsl_ft[i];
                }
                ## print("## radar T0 h: ",h / FT2M," radar_elv_h_T0_ft: ",radar_elv_h_T0_ft[i]," | "," radar_elv_Hsl_ft: ", radar_elv_Hsl_ft[i], " | ",h_sl_ft," | ",i," | radar_prc_T0_sign: ",radar_prc_T0_sign, " radar_elv_T0_max: ",radar_elv_T0_max);
                # Calculate T1
                radar_elv_h_T1_ft[i] = h_sl_ft + (radar_elv_time[i] * speed_horz_fps * pitch_ang_tan) - radar_elv_Hsl_ft[i];
                if (radar_chn_T1_sign == -1) {
                    if (i == 1 and radar_elv_h_T1_ft[1] < 0.0) radar_prc_T1_sign = 1;
                    if (radar_elv_h_T1_ft[i] > 0) {
                        if (radar_prc_T1_sign < 0) radar_chn_T1_sign = i - 1;
                    } else {
                        if (radar_prc_T1_sign > 0) radar_chn_T1_sign = i - 1;
                    }
                    if (radar_elv_h_T1_ft[i] > 0) radar_prc_T1_sign = 1 else radar_prc_T1_sign = -1;
                    if (radar_elv_Hsl_ft[i] > radar_elv_T1_max and radar_elv_time[i] <= imp_medium_time) radar_elv_T1_max = radar_elv_Hsl_ft[i];
                }
                # Calculate T2 (radar_min_alpha_tan)
                radar_elv_h_T2_ft[i] = h_sl_ft + (radar_min_alpha_tan * 1.0) - radar_elv_Hsl_ft[i];
                if (radar_chn_T2_sign == -1) {
                    if (i == 1 and radar_elv_h_T2_ft[1] < 0.0) radar_prc_T2_sign = 1;
                    if (radar_elv_h_T2_ft[i] > 0) {
                        if (radar_prc_T2_sign < 0) radar_chn_T2_sign = i - 1;
                    } else {
                        if (radar_prc_T2_sign > 0) radar_chn_T2_sign = i - 1;
                    }
                    if (radar_elv_h_T2_ft[i] > 0) radar_prc_T2_sign = 1 else radar_prc_T2_sign = -1;
                    if (radar_elv_Hsl_ft[i] > radar_elv_T2_max and radar_elv_time[i] <= imp_medium_time) radar_elv_T2_max = radar_elv_Hsl_ft[i];
                }
                # Calculate T3 (+20 deg)
                radar_elv_h_T3_ft[i] = h_sl_ft + (radar_elv_time[i] * speed_horz_fps * 0.36397023426) - radar_elv_Hsl_ft[i];
                if (radar_chn_T3_sign == -1) {
                    if (i == 1 and radar_elv_h_T3_ft[1] < 0.0) radar_prc_T3_sign = 1;
                    if (radar_elv_h_T3_ft[i] > 0) {
                        if (radar_prc_T3_sign < 0) radar_chn_T3_sign = i - 1;
                    } else {
                        if (radar_prc_T3_sign > 0) radar_chn_T3_sign = i - 1;
                    }
                    if (radar_elv_h_T3_ft[i] > 0) radar_prc_T3_sign = 1 else radar_prc_T3_sign = -1;
                    if (radar_elv_Hsl_ft[i] > radar_elv_T3_max and radar_elv_time[i] <= imp_medium_time) radar_elv_T3_max = radar_elv_Hsl_ft[i];
                }
            } else {
                radar_elv_is_valid[i] = 0;
                radar_elv_all_valid = 0;
            }
        } else {
            radar_elv_is_valid[i] = 0;
            radar_elv_all_valid = 0;
        }
    }
    
    radar_elv_sum = (radar_elv_sum / radar_elv_n) - radar_elv_min;
    complex_factor = math.ln(1.0 + math.abs(radar_elv_sum / 50.0));
    if (complex_factor < 1.0) complex_factor = 1.0;
    
    if (testing_log_active >= 1) {
        if (radar_elv_all_valid == 1) {
            print("##### H T0: ",radar_chn_T0_sign," : ",radar_elv_time[radar_chn_T0_sign]," Elev: ",radar_elv_Hsl_ft[radar_chn_T0_sign]," Max: ",radar_elv_T0_max);
            print("##### H T1: ",radar_chn_T1_sign," : ",radar_elv_time[radar_chn_T1_sign]," Elev: ",radar_elv_Hsl_ft[radar_chn_T1_sign]," Max: ",radar_elv_T1_max);
            print("##### H T2: ",radar_chn_T2_sign," : ",radar_elv_time[radar_chn_T2_sign]," Elev: ",radar_elv_Hsl_ft[radar_chn_T2_sign]," Max: ",radar_elv_T2_max);
            print("##### H T3: ",radar_chn_T3_sign," : ",radar_elv_time[radar_chn_T3_sign]," Elev: ",radar_elv_Hsl_ft[radar_chn_T3_sign]," Max: ",radar_elv_T3_max);
        }
    }

    var elevation = 0.0;
    var elevation_max = 0.0;
    var intensity = 0.0;
    var time_impact_Min = 999999.0;
    var factor_lag = 0.0;


    if (radar_chn_T0_sign >= 0) {
        imp_T0 = radar_elv_time[radar_chn_T0_sign];
        intensity = intensity + 4.0 * (imp_cnt_min_time / imp_T0);
        if (time_impact_Min > imp_T0 * 0.25) time_impact_Min = imp_T0;
        elevation = radar_elv_T0_max;
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
    
    if (testing_log_active >= 1) print("#### altitude-QFE-impact-elev T0: ",elevation * M2FT," T0: ",imp_T0," Ang: 0.0"," intensity: ",intensity, " imp_T0_lag_int: ",imp_T0_lag_int);
    
    if (radar_chn_T1_sign >= 0) {
        imp_T1 = radar_elv_time[radar_chn_T1_sign];
        intensity = intensity + 1.0 * (imp_cnt_min_time / imp_T1);
        if (time_impact_Min > imp_T1 * 1.0) time_impact_Min = imp_T1;
        elevation = radar_elv_T1_max;
        if (elevation_max < elevation and imp_T1 < imp_cnt_min_time) {
            elevation_max = elevation;
        }
    }
    
    if (testing_log_active >= 1) print("#### altitude-QFE-impact-elev T1: ",elevation * M2FT," T1: ",imp_T1," Ang: ",1.0 * pitch_angle_deg, " intensity: ",intensity);
    
    if (radar_chn_T2_sign >= 0) {
        imp_T2 = radar_elv_time[radar_chn_T2_sign];
        intensity = intensity + 0.25 * (imp_cnt_min_time / imp_T2);
        if (time_impact_Min > imp_T2 * 1.0) time_impact_Min = imp_T2;
        elevation = radar_elv_T2_max;
    }
    
    if (elevation_max < elevation and imp_T2 < imp_cnt_min_time) {
        elevation_max = elevation;
    }
    
    if (testing_log_active >= 1) print("#### altitude-QFE-impact-elev T2: ",elevation * M2FT," T2: ",imp_T2," Ang: ",1.5 * pitch_angle_deg, " intensity: ",intensity);
    
    if (radar_chn_T3_sign >= 0) {
        imp_T3 = radar_elv_time[radar_chn_T3_sign];
        intensity = intensity + 4.0 * (imp_cnt_min_time / imp_T3);
        if (time_impact_Min > imp_T3 * 0.25) time_impact_Min = imp_T3;
        elevation = radar_elv_T3_max;
    }

    if (elevation_max < elevation and imp_T3 < ((imp_medium_time / 5.0) * imp_cnt_min_time)) {
        elevation_max = elevation;
    }
    
    if (testing_log_active >= 1) print("#### altitude-QFE-impact-elev T3: ",elevation * M2FT," T3: ",imp_T3," Ang: ", 20.0, " intensity: ",intensity);
    
    if (imp_T0_lag_int >= 1.0 and time_impact_Min < imp_cnt_min_time and complex_factor > 1.0) {
        intensity_calc = 0.5 + 1.0 * math.ln(1.0 + (intensity * 15.0 / time_impact_Min));
        neutre_lag_adv = neutre_lag_adv + intensity_calc;
        neutre_lag_n = neutre_lag_n + 1;
        neutre_lag_active = 0;
        neutre_lag = 0.0;
    } else {
        intensity_calc = 0.5;
        if (neutre_lag_active == 0 and neutre_lag_n > 0) {
            ## neutre_lag = neutre_lag_adv / neutre_lag_n;
            neutre_lag = 1.0;
            neutre_lag_active = 1;
            neutre_lag_adv = 0.0;
            neutre_lag_n = 0;
            factor_neutre = (neutre_lag * delta_time) / neutre_lag_factor;
        } else {
            if (neutre_lag > factor_neutre) {
                neutre_lag = neutre_lag - factor_neutre;
            } else {
                neutre_lag = 0.0;
                neutre_lag_active = 0;
            }
        }
    }
        
    setIntensty_calc_lag(intensity_calc, 0.7,0.5);
    
    var ground_elev_m = getprop("/position/ground-elev-m");
    
    setprop("fdm/jsbsim/systems/autopilot/altitude-QFE-impact-elev-ft",elevation_max * M2FT);
    
    setprop("fdm/jsbsim/systems/autopilot/altitude-QFE-impact-elev-intensity",intensity_calc_lag);
    if (imp_cnt_active == 1) {
        setprop("fdm/jsbsim/systems/autopilot/altitude-QFE-impact-elev-neutre",neutre_lag);
        setprop("fdm/jsbsim/systems/autopilot/pitch-output-error-coefficient-gain",0.0);
    } else {
        setprop("fdm/jsbsim/systems/autopilot/altitude-QFE-impact-elev-neutre",0.0);
        setprop("fdm/jsbsim/systems/autopilot/pitch-output-error-coefficient-gain",2 * intensity_calc_lag);
    }
    
    if (testing_log_active >= 1) {
        print("#### altitude-QFE: "
              ,sprintf("%5.0f",elevation_max * M2FT)
              ,sprintf(" imp_T0_lag_int: %f2.2",imp_T0_lag_int)
              ,sprintf(" intensity: %f2.2", intensity_calc)
              ,sprintf(" ( %4.2f | ",intensity)
              ,sprintf(" lag: %2.2f )",intensity_calc_lag)
              ,sprintf(" imp_cnt_min_time: %2.2f",imp_cnt_min_time)
              ,sprintf(" | %3.1f ",time_impact_Min)
              ,sprintf(" neutre: %2.1f",neutre_lag)
              ,sprintf(" | %2.1f",factor_neutre)
              ,sprintf(" | %2.1f",neutre_lag_active)
              ,sprintf(" complex: %2.1f",complex_factor)
              ,sprintf(" | %5.0f",radar_elv_sum)
        )
    }
    
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
