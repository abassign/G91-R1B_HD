var prop = props.globals.initNode("sim/G91/JATO/JATO_is_mounted", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/JATO/JATO_Ignition_Push", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/JATO/JATO_Jettinson_Push", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/JATO/JATO_Fire", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/JATO/JATO_Rokets_Number", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/JATO/JATO_Rokets_Thrust", 1000, "DOUBLE");
var prop = props.globals.initNode("sim/G91/JATO/JATO_Rokets_Weitght", 158.5, "DOUBLE");
var prop = props.globals.initNode("sim/G91/JATO/JATO_Sound_Factor", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/JATO/JATO_Flame_Size[1]", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/JATO/JATO_Flame_Size[2]", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/JATO/JATO_Flame_Size[3]", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/JATO/JATO_Flame_Size[4]", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/JATO/JATO_thrust_all_rockets", 0, "DOUBLE");

# Remove from Throttle control the rockets JATO engine
var prop = props.globals.initNode("sim/input/selected/engine[1]", 0, "BOOL");
var prop = props.globals.initNode("sim/input/selected/engine[2]", 0, "BOOL");
var prop = props.globals.initNode("sim/input/selected/engine[3]", 0, "BOOL");
var prop = props.globals.initNode("sim/input/selected/engine[4]", 0, "BOOL");

# Dialog configuration
var prop = props.globals.initNode("sim/G91/dialogs/JATO/install-2-jato-rocket", 0, "BOOL");
var prop = props.globals.initNode("sim/G91/dialogs/JATO/install-4-jato-rocket", 0, "BOOL");

var jato_Ignition_Push_release = func() {
    setprop("sim/G91/JATO/JATO_Ignition_Push", 0);
}

var jato_Jettinson_Push_release = func() {
    setprop("sim/G91/JATO/JATO_Jettinson_Push", 0);
}

var jato_fire = func() {
    setprop("sim/G91/JATO/JATO_Fire", 0);
}



setlistener("sim/G91/JATO/JATO_Ignition_Push", func {
    var jato_Ignition_Push = props.globals.getNode("sim/G91/JATO/JATO_Ignition_Push",1).getValue();
    var JATO_Ready_Switch = props.globals.getNode("fdm/jsbsim/systems/jato/sw-ready",1).getValue();
    var electric-active = props.globals.getNode("fdm/jsbsim/systems/jato/electric-active",1).getValue();
    var JATO_is_mounted = props.globals.getNode("sim/G91/JATO/JATO_is_mounted",1).getValue();
    var JATO_Rokets_Number = props.globals.getNode("sim/G91/JATO/JATO_Rokets_Number",1).getValue();
    var JATO_Sound_Factor = 0;
    # The JATO Roket M8 burn for 16 sec
    # Thrust 1000 lib
    # Weight 158.5 lib
    # Thust Direction 25°
    if (JATO_Ready_Switch and jato_Ignition_Push >= 1 and electric-active and JATO_is_mounted > 0) {
        jato_flame_effect.start();
        if (JATO_Rokets_Number > 0) {
            setprop("controls/engines/engine[1]/throttle", 1);
            setprop("controls/engines/engine[4]/throttle", 1);
            JATO_Sound_Factor = 0.5;
        }
        if (JATO_Rokets_Number > 2) {
            setprop("controls/engines/engine[2]/throttle", 1);
            setprop("controls/engines/engine[3]/throttle", 1);
            JATO_Sound_Factor = 1.0;
        }
    }
    if (jato_Ignition_Push >= 1) {
        settimer(jato_Ignition_Push_release, 0.5);
    }
}, 1, 0);

var jato_flame_effect = maketimer(0.1, func() {
    var thrust_lb_1 = props.globals.getNode("engines/engine[1]/thrust_lb",1).getValue();
    var thrust_lb_2 = props.globals.getNode("engines/engine[2]/thrust_lb",1).getValue();
    var thrust_lb_3 = props.globals.getNode("engines/engine[3]/thrust_lb",1).getValue();
    var thrust_lb_4 = props.globals.getNode("engines/engine[4]/thrust_lb",1).getValue();
    var thrust_all_rockets = 0;
    if ((thrust_lb_1 != nil) and (thrust_lb_2 != nil) and (thrust_lb_3 != nil) and (thrust_lb_4 != nil)) {
        thrust_all_rockets = thrust_lb_1 + thrust_lb_2 + thrust_lb_3 + thrust_lb_4;
    }
    setprop("sim/G91/JATO/JATO_thrust_all_rockets",thrust_all_rockets);
    if (thrust_all_rockets > 0) {
        setprop("sim/G91/JATO/JATO_Flame_Size[1]",thrust_lb_1 * 0.001);
        setprop("sim/G91/JATO/JATO_Flame_Size[2]",thrust_lb_2 * 0.001);
        setprop("sim/G91/JATO/JATO_Flame_Size[3]",thrust_lb_3 * 0.001);
        setprop("sim/G91/JATO/JATO_Flame_Size[4]",thrust_lb_4 * 0.001);
    }
});

setlistener("sim/G91/JATO/JATO_Jettinson_Push", func {
    var jato_Jettinson_Push = 0;
    var thrust_all_rockets = props.globals.getNode("sim/G91/JATO/JATO_thrust_all_rockets",1).getValue();
    jato_Ignition_Push = props.globals.getNode("sim/G91/JATO/JATO_Jettinson_Push",1).getValue();
    if (jato_Ignition_Push >= 1) {
        settimer(jato_Jettinson_Push_release, 0.5);
    }
    if (thrust_all_rockets < 10) {
        jato_flame_effect.stop();
        setprop("sim/G91/dialogs/JATO/install-2-jato-rocket",0);
        setprop("sim/G91/dialogs/JATO/install-4-jato-rocket",0);
        setprop("sim/G91/JATO/JATO_Rokets_Number",0);
        setprop("sim/G91/JATO/JATO_is_mounted",0);
        setprop("fdm/jsbsim/systems/jato/rocket_number_1",0);
        setprop("fdm/jsbsim/systems/jato/rocket_number_2",0);
        setprop("fdm/jsbsim/systems/jato/rocket_number_3",0);
        setprop("fdm/jsbsim/systems/jato/rocket_number_4",0);
    }
}, 1, 0);
