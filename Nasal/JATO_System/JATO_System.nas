var prop = props.globals.initNode("sim/G91/JATO/JATO_is_mounted", 1, "DOUBLE");
var prop = props.globals.initNode("sim/G91/JATO/JATO_Ignition_Push", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/JATO/JATO_Jettinson_Push", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/JATO/JATO_Ready_Switch", 1, "BOOL");
var prop = props.globals.initNode("sim/G91/JATO/JATO_Ready_Light_Transparent", 0.85, "DOUBLE");
var prop = props.globals.initNode("sim/G91/JATO/JATO_Ready_Light_On", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/JATO/JATO_Fire", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/JATO/JATO_Rokets_Number", 4, "DOUBLE");
var prop = props.globals.initNode("sim/G91/JATO/JATO_Rokets_Thrust", 1000, "DOUBLE");
var prop = props.globals.initNode("sim/G91/JATO/JATO_Rokets_Weitght", 158.5, "DOUBLE");

# Remove from Throttle control the rockets JATO engine
var prop = props.globals.initNode("sim/input/selected/engine[1]", 0, "BOOL");
var prop = props.globals.initNode("sim/input/selected/engine[2]", 0, "BOOL");
var prop = props.globals.initNode("sim/input/selected/engine[3]", 0, "BOOL");
var prop = props.globals.initNode("sim/input/selected/engine[4]", 0, "BOOL");

# Dialog configuration
var prop = props.globals.initNode("sim/G91/gui/dialogs/JATO/no-jato-system", 0, "BOOL");
var prop = props.globals.initNode("sim/G91/dialogs/JATO/install-jato-system-2-rocket", 0, "BOOL");
var prop = props.globals.initNode("sim/G91/dialogs/JATO/install-jato-system-4-rocket", 1, "BOOL");

var jato_Ignition_Push_release = func() {
    setprop("sim/G91/JATO/JATO_Ignition_Push", 0);
}

var jato_Jettinson_Push_release = func() {
    setprop("sim/G91/JATO/JATO_Jettinson_Push", 0);
}

var jato_fire = func() {
    setprop("sim/G91/JATO/JATO_Fire", 0);
}

setlistener("sim/G91/JATO/JATO_is_mounted", func {
     var JATO_is_mounted = props.globals.getNode("sim/G91/JATO/JATO_is_mounted",1).getValue();
     var JATO_Rokets_Number = 0;
     if (JATO_is_mounted > 0) {
        if (JATO_is_mounted <= 2) {
            setprop("sim/G91/JATO/JATO_Rokets_Number", 2);
            JATO_Rokets_Number = 2;
        } else {
            setprop("sim/G91/JATO/JATO_Rokets_Number", 4);
            JATO_Rokets_Number = 4;
        }
     } else {
        setprop("sim/G91/JATO/JATO_Rokets_Number", 0);
     }
}, 1, 0);

setlistener("sim/G91/JATO/JATO_Ready_Switch", func {
    var JATO_Ready_Switch = props.globals.getNode("sim/G91/JATO/JATO_Ready_Switch",1).getValue();
    var bus_primary_on = props.globals.getNode("sim/G91/electric/bus_primary_on",1).getValue();
    if (!(bus_primary_on and JATO_Ready_Switch)) {
        JATO_Ready_Switch = 0;
    }
    if (JATO_Ready_Switch == 0) {
        setprop("sim/G91/JATO/JATO_Ready_Switch", 0);
        setprop("sim/G91/JATO/JATO_Ready_Light_On", 0);
        setprop("sim/G91/JATO/JATO_Ready_Light_Transparent", 0.85);
    } else {
        setprop("sim/G91/JATO/JATO_Ready_Switch", 1);
        setprop("sim/G91/JATO/JATO_Ready_Light_On", 1);
        setprop("sim/G91/JATO/JATO_Ready_Light_Transparent", 0.1);
    }
}, 1, 0);

setlistener("sim/G91/JATO/JATO_Ignition_Push", func {
    var jato_Ignition_Push = props.globals.getNode("sim/G91/JATO/JATO_Ignition_Push",1).getValue();
    var JATO_Ready_Switch = props.globals.getNode("sim/G91/JATO/JATO_Ready_Switch",1).getValue();
    var bus_primary_on = props.globals.getNode("sim/G91/electric/bus_primary_on",1).getValue();
    var JATO_is_mounted = props.globals.getNode("sim/G91/JATO/JATO_is_mounted",1).getValue();
    var JATO_Rokets_Number = props.globals.getNode("sim/G91/JATO/JATO_Rokets_Number",1).getValue();
    # The JATO Roket M8 burn for 16 sec
    # Thrust 1000 lib
    # Weight 158.5 lib
    # Thust Direction 25°
    if (JATO_Ready_Switch and jato_Ignition_Push >= 1 and bus_primary_on and JATO_is_mounted > 0) {
        if (JATO_Rokets_Number > 0) {
            setprop("controls/engines/engine[1]/throttle", 1);
            setprop("controls/engines/engine[4]/throttle", 1);
        }
        if (JATO_Rokets_Number > 2) {
            setprop("controls/engines/engine[2]/throttle", 1);
            setprop("controls/engines/engine[3]/throttle", 1);
        }
    }
    if (jato_Ignition_Push >= 1) {
        settimer(jato_Ignition_Push_release, 0.5);
    }
}, 1, 0);

setlistener("sim/G91/JATO/JATO_Jettinson_Push", func {
    var jato_Jettinson_Push = 0;
    jato_Ignition_Push = props.globals.getNode("sim/G91/JATO/JATO_Jettinson_Push",1).getValue();
    if (jato_Ignition_Push >= 1) {
        settimer(jato_Jettinson_Push_release, 0.5);
    }
    setprop("sim/G91/JATO/JATO_is_mounted", 0);
}, 1, 0);
