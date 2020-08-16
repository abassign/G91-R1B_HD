# Self-piloting by air interception
#
# 2020-08-15 Adriano Bassignana
# GPL 2.0+
#
# http://wiki.flightgear.org/Canvas_MapStructure


var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-control-active", 0, "INT");

var timeStep = 1.0;
var timeStepDivisor = 1.0;
var delta_time = 1.0;
var timeStepSecond = 0;

var int_cnt_active = 0;
var intensity_calc_lag = 0.0;


var int_cnt = func() {
    

    
}


var pilot_imp_control = func() {
    
    int_cnt_active = getprop("fdm/jsbsim/systems/autopilot/gui/interception-control-active");
    int_cnt();
    
    if (imp_cnt_active == 0) {
        timeStepDivisor = 1;
    } else {
        if (intensity_calc_lag < 0.3) {
            timeStepDivisor = 2;
        } else {
            timeStepDivisor = 5;
        }
    }
    delta_time = timeStep / timeStepDivisor;
    pilot_intercept_timer.restart(delta_time);
    if (timeStepSecond == 1) timeStepSecond = 0;

}


var pilot_intercept_timer = maketimer(delta_time, pilot_imp_control);
pilot_intercept_timer.singleShot = 1;
pilot_intercept_timer.start();

var pilot_intercept_timerLog = maketimer(1, func() {timeStepSecond = 1;});
pilot_intercept_timerLog.start();
