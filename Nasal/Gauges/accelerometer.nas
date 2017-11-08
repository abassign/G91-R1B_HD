var prop = props.globals.initNode("sim/G91/gauge/accelerometer/max", -9999, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/accelerometer/min", 9999, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/accelerometer/reset", 0, "DOUBLE");

setlistener("sim/G91/gauge/accelerometer/reset", func {
    var acc = props.globals.getNode("accelerations/pilot-gdamped",1).getValue();
    setprop("sim/G91/gauge/accelerometer/max", acc);
    setprop("sim/G91/gauge/accelerometer/min", acc);
}, 1, 0);

var timer_accelerometer = maketimer(0.1, func() {
    var acc = props.globals.getNode("accelerations/pilot-gdamped",1).getValue();
    var accMax = props.globals.getNode("sim/G91/gauge/accelerometer/max",1).getValue();
    var accMin = props.globals.getNode("sim/G91/gauge/accelerometer/min",1).getValue();
    if (acc > accMax) {
        setprop("sim/G91/gauge/accelerometer/max", acc);
    } else if (acc < accMin) {
        setprop("sim/G91/gauge/accelerometer/min", acc);
    }
});
timer_accelerometer.start();
