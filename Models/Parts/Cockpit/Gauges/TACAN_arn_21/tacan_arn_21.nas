
var timer_tacan_arn_21 = maketimer(0.5, func() {
    var isServiceable = props.globals.getNode("fdm/jsbsim/systems/gauges/radio/TACAN-ARN-21/isServiceable",1).getValue();
    if (isServiceable == 1) {
        setprop("/instrumentation/tacan/serviceable", 1);
        var chan = props.globals.getNode("fdm/jsbsim/systems/gauges/radio/TACAN-ARN-21/freq-chan",1).getValue();
        setprop("/instrumentation/tacan/frequencies/selected-channel", chan);
        var selectedChannelY = props.globals.getNode("fdm/jsbsim/systems/gauges/radio/TACAN-ARN-21/selected-channel-Y",1).getValue();
        var selectedChannelX = props.globals.getNode("fdm/jsbsim/systems/gauges/radio/TACAN-ARN-21/selected-channel-X",1).getValue();
        if (selectedChannelY) {
            setprop("/instrumentation/tacan/frequencies/selected-channel[4]", "Y");
        }
        if (selectedChannelX) {
            setprop("/instrumentation/tacan/frequencies/selected-channel[4]", "X");
        }
    } else {
        setprop("/instrumentation/tacan/serviceable", 0);
    }
});
timer_tacan_arn_21.start();
 
