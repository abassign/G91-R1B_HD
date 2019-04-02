setlistener("/instrumentation/tacan/frequencies/selected-channel[4]", func {
    var freqChanManual = props.globals.getNode("fdm/jsbsim/systems/gauges/radio/TACAN-ARN-21/freq-chan-manual",0).getValue();
    if (freqChanManual == 0) {
        var setMode = props.globals.getNode("/instrumentation/tacan/frequencies/selected-channel[4]",0).getValue();
        if (setMode == "X") {
            setprop("fdm/jsbsim/systems/gauges/radio/TACAN-ARN-21/switch-turn",2);
        } else {
            setprop("fdm/jsbsim/systems/gauges/radio/TACAN-ARN-21/switch-turn",3);
        }
    }
}, 1, 0);

setlistener("/instrumentation/tacan/frequencies/selected-channel", func {
    var freqChanManual = props.globals.getNode("fdm/jsbsim/systems/gauges/radio/TACAN-ARN-21/freq-chan-manual",0).getValue();
    if (freqChanManual == 0) {
        var setChan = props.globals.getNode("/instrumentation/tacan/frequencies/selected-channel",0).getValue();
        setprop("fdm/jsbsim/systems/gauges/radio/TACAN-ARN-21/selector-lever",setChan);
    }
}, 1, 0);

var timer_tacan_arn_21 = maketimer(0.5, func() {

    var freqChanManual = props.globals.getNode("fdm/jsbsim/systems/gauges/radio/TACAN-ARN-21/freq-chan-manual",0).getValue();
    if (freqChanManual > 0) {
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
    }
    
    if (freqChanManual >= 1) {
        setprop("fdm/jsbsim/systems/gauges/radio/TACAN-ARN-21/freq-chan-manual",freqChanManual + 1);
        if (freqChanManual > 3) {
            setprop("fdm/jsbsim/systems/gauges/radio/TACAN-ARN-21/freq-chan-manual",0);
        }
    }
    
    var isServiceable = props.globals.getNode("fdm/jsbsim/systems/gauges/radio/TACAN-ARN-21/isServiceable",1).getValue();
    if (isServiceable == 1) {
        setprop("/instrumentation/tacan/serviceable", 1);
    } else {
        setprop("/instrumentation/tacan/serviceable", 0);
    }
});
timer_tacan_arn_21.start();
 
