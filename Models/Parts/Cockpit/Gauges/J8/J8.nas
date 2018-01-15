var prop = props.globals.initNode("sim/G91/gauge/J8/flag_deg", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/J8/flag_return", 0, "DOUBLE");

setlistener("instrumentation/attitude-indicator/caged-flag", func {
    var caged_flag = props.globals.getNode("instrumentation/attitude-indicator/caged-flag",1).getValue();
    var flag_return = props.globals.getNode("sim/G91/gauge/J8/flag_return",1).getValue();
    if (caged_flag == 1 and flag_return == 0.0) {
        setprop("sim/G91/gauge/J8/flag_return", 1);
    }
}, 1, 0);

var gauge_j8_Flag_Status = maketimer(0.1, func() {
    var flag_return = props.globals.getNode("sim/G91/gauge/J8/flag_return",1).getValue();
    if (flag_return > 0.05) {
        flag_return = flag_return - 0.05;
    } else {
        flag_return = 0;
        setprop("instrumentation/attitude-indicator/caged-flag", 0);
    }
    setprop("sim/G91/gauge/J8/flag_return", flag_return);
    var spin = props.globals.getNode("instrumentation/attitude-indicator/spin",1).getValue();
    var serviceable = props.globals.getNode("instrumentation/attitude-indicator/serviceable",1).getValue();
    var caged_flag = props.globals.getNode("instrumentation/attitude-indicator/caged-flag",1).getValue();
    if (spin < 0.5 or serviceable < 1) {
        var flag_deg = props.globals.getNode("sim/G91/gauge/J8/flag_deg",1).getValue();
        if (flag_deg > 0.0) {
            if (flag_deg > 0.05) {
                flag_deg = flag_deg - 0.3;
            } else {
                flag_deg = 0.0;
            }
            setprop("sim/G91/gauge/J8/flag_deg", flag_deg);
        }
    } else {
        var flag_deg = props.globals.getNode("sim/G91/gauge/J8/flag_deg",1).getValue();
        if (flag_deg < 1.0) {
            if (flag_deg < 1.0) {
                flag_deg = flag_deg + 0.2;
            } else {
                flag_deg = 1.0;
            }
            setprop("sim/G91/gauge/J8/flag_deg", flag_deg);
        }
    }
});
gauge_j8_Flag_Status.start();
