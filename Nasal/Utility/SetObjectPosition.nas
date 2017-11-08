# Object position set coordinates

var prop = props.globals.initNode("sim/G91/set_object_position_x", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/set_object_position_y", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/set_object_position_z", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/set_object_initial_position_x", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/set_object_initial_position_y", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/set_object_initial_position_z", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/set_object_incremental_position_x", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/set_object_incremental_position_y", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/set_object_incremental_position_z", 0, "DOUBLE");

var SetObjectPosition = maketimer(0.1, func() {
    var set_x = 0.0;
    var set_y = 0.0;
    var set_z = 0.0;
    set_x = getprop("sim/G91/set_object_initial_position_x") + getprop("sim/G91/set_object_incremental_position_x");
    set_y = getprop("sim/G91/set_object_initial_position_y") + getprop("sim/G91/set_object_incremental_position_y");
    set_z = getprop("sim/G91/set_object_initial_position_z") + getprop("sim/G91/set_object_incremental_position_z");
    setprop("sim/G91/set_object_position_x",set_x);
    setprop("sim/G91/set_object_position_y",set_y);
    setprop("sim/G91/set_object_position_y",set_z);
});

SetObjectPosition.start();
