var prop = props.globals.initNode("sim/G91/JATO/JATO_is_mounted", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/JATO/JATO_Jettinson_Push", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/JATO/JATO_Rokets_Number", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/JATO/JATO_Rokets_Thrust", 1000, "DOUBLE");
var prop = props.globals.initNode("sim/G91/JATO/JATO_Rokets_Weitght", 158.5, "DOUBLE");
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

var jato_Jettinson_Push_release = func() {
    setprop("sim/G91/JATO/JATO_Jettinson_Push", 0);
}

setlistener("sim/G91/JATO/JATO_Jettinson_Push", func {
    var jato_Jettinson_Push = 0;
    var thrust_all_rockets = props.globals.getNode("sim/G91/JATO/JATO_thrust_all_rockets",1).getValue();
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
