var prop = props.globals.initNode("sim/G91/gauge/clock/stopwatch_seconds", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/clock/stopwatch_seconds_start", 0, "DOUBLE");

setlistener("sim/G91/gauge/clock/stopwatch", func {
    var stopwatch_status = props.globals.getNode("sim/G91/gauge/clock/stopwatch",1).getValue();
    if (stopwatch_status == 1) {
        var seconds_start = props.globals.getNode("instrumentation/clock/indicated-sec",1).getValue();
        setprop("sim/G91/gauge/clock/stopwatch_seconds_start", seconds_start);
    } else if (stopwatch_status == 0){
        setprop("sim/G91/gauge/clock/stopwatch_seconds", 0);
    }
}, 1, 0);

var timer_clock_stopwatch = maketimer(0.1, func() {
    var stopwatch_status = props.globals.getNode("sim/G91/gauge/clock/stopwatch",1).getValue();
    if (stopwatch_status == 1) {
        var seconds_start = props.globals.getNode("sim/G91/gauge/clock/stopwatch_seconds_start",1).getValue();
        var seconds_now = props.globals.getNode("instrumentation/clock/indicated-sec",1).getValue();
        if (seconds_now <= seconds_start) {
            seconds_now = seconds_now + 86400;
        }
        setprop("sim/G91/gauge/clock/stopwatch_seconds", seconds_now - seconds_start);
    }
});
timer_clock_stopwatch.start();
