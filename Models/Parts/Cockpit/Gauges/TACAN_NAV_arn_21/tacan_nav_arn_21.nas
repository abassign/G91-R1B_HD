var prop = props.globals.initNode("sim/G91/configuration/gauges/tacan-nav-active-trigger", 0, "INT");
var prop = props.globals.initNode("sim/G91/configuration/gauges/tacan-nav-active-state", -1, "INT");
var prop = props.globals.initNode("sim/G91/configuration/gauges/tacan-nav-active-desc", "", "STRING");
var prop = props.globals.initNode("sim/G91/configuration/gauges/tacan-nav-active", 0, "INT");
var prop = props.globals.initNode("sim/G91/configuration/gauges/tacan-active", 0, "INT");
var prop = props.globals.initNode("sim/G91/configuration/gauges/nav-active", 0, "INT");
var prop = props.globals.initNode("sim/G91/configuration/gauges/MBT-active", 0, "INT");
var prop = props.globals.initNode("sim/G91/configuration/gauges/frontal-central-01-active", 1, "INT");
var prop = props.globals.initNode("sim/G91/configuration/gauges/tacan-nav-active-ident", "", "STRING");


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
    
    #// TACAN-NAV Activation
    var s = getprop("sim/G91/configuration/gauges/tacan-nav-active-state");
    if (s == -1) {
        if (getprop("sim/G91/configuration/gauges/nav-active") == 1) {
            setprop("sim/G91/configuration/gauges/tacan-active",0);
            setprop("sim/G91/configuration/gauges/MBT-active",1);
            setprop("fdm/jsbsim/systems/gauges/radio/TACAN-NAV-ARN-21/TACAN-Active",0);
            setprop("fdm/jsbsim/systems/gauges/radio/TACAN-NAV-ARN-21/NAV-Active",1);
            setprop("fdm/jsbsim/systems/gauges/radio/TACAN-NAV-ARN-21/MBT-Active",1);
            setprop("sim/G91/configuration/gauges/tacan-nav-active-state",1);
            setprop("sim/G91/configuration/gauges/tacan-nav-active-desc","VOR configuration activate");
            setprop("sim/G91/configuration/gauges/frontal-central-01-active",0);
        } elsif (getprop("sim/G91/configuration/gauges/tacan-active") == 1) {
            setprop("sim/G91/configuration/gauges/nav-active",0);
            setprop("sim/G91/configuration/gauges/MBT-active",0);
            setprop("fdm/jsbsim/systems/gauges/radio/TACAN-NAV-ARN-21/TACAN-Active",1);
            setprop("fdm/jsbsim/systems/gauges/radio/TACAN-NAV-ARN-21/NAV-Active",0);
            setprop("fdm/jsbsim/systems/gauges/radio/TACAN-NAV-ARN-21/MBT-Active",0);
            setprop("sim/G91/configuration/gauges/tacan-nav-active-state",2);
            setprop("sim/G91/configuration/gauges/tacan-nav-active-desc","TACAN configuration activate");
            setprop("sim/G91/configuration/gauges/frontal-central-01-active",0);
        } else {
            setprop("sim/G91/configuration/gauges/MBT-active",0);
            setprop("fdm/jsbsim/systems/gauges/radio/TACAN-NAV-ARN-21/TACAN-Active",0);
            setprop("fdm/jsbsim/systems/gauges/radio/TACAN-NAV-ARN-21/NAV-Active",0);
            setprop("fdm/jsbsim/systems/gauges/radio/TACAN-NAV-ARN-21/MBT-Active",0);
            setprop("sim/G91/configuration/gauges/tacan-nav-active-state",0);
            setprop("sim/G91/configuration/gauges/tacan-nav-active-desc","VOR or TACAN configuration inactive");
            setprop("sim/G91/configuration/gauges/frontal-central-01-active",1);
        };
    };
    if (getprop("sim/G91/configuration/gauges/tacan-nav-active-trigger") == 1) {
        if (s == 0) {
            setprop("sim/G91/configuration/gauges/nav-active",1);
            setprop("sim/G91/configuration/gauges/MBT-active",1);
            setprop("sim/G91/configuration/gauges/tacan-active",0);
            setprop("fdm/jsbsim/systems/gauges/radio/TACAN-NAV-ARN-21/TACAN-Active",0);
            setprop("fdm/jsbsim/systems/gauges/radio/TACAN-NAV-ARN-21/NAV-Active",1);
            setprop("fdm/jsbsim/systems/gauges/radio/TACAN-NAV-ARN-21/MBT-Active",1);
            setprop("sim/G91/configuration/gauges/tacan-nav-active-state",1);
            setprop("sim/G91/configuration/gauges/tacan-nav-active-desc","VOR configuration activate");
            setprop("sim/G91/configuration/gauges/frontal-central-01-active",0);
        } elsif(s == 1) {
            setprop("sim/G91/configuration/gauges/nav-active",0);
            setprop("sim/G91/configuration/gauges/MBT-active",0);
            setprop("sim/G91/configuration/gauges/tacan-active",1);
            setprop("fdm/jsbsim/systems/gauges/radio/TACAN-NAV-ARN-21/TACAN-Active",1);
            setprop("fdm/jsbsim/systems/gauges/radio/TACAN-NAV-ARN-21/NAV-Active",0);
            setprop("fdm/jsbsim/systems/gauges/radio/TACAN-NAV-ARN-21/MBT-Active",0);
            setprop("sim/G91/configuration/gauges/tacan-nav-active-state",2);
            setprop("sim/G91/configuration/gauges/tacan-nav-active-desc","TACAN configuration activate");
            setprop("sim/G91/configuration/gauges/frontal-central-01-active",0);
        } else {
            setprop("sim/G91/configuration/gauges/MBT-active",0);
            setprop("sim/G91/configuration/gauges/nav-active",0);
            setprop("fdm/jsbsim/systems/gauges/radio/TACAN-NAV-ARN-21/TACAN-Active",0);
            setprop("fdm/jsbsim/systems/gauges/radio/TACAN-NAV-ARN-21/NAV-Active",0);
            setprop("fdm/jsbsim/systems/gauges/radio/TACAN-NAV-ARN-21/MBT-Active",0);
            setprop("sim/G91/configuration/gauges/tacan-active",0);
            setprop("sim/G91/configuration/gauges/tacan-nav-active-state",0);
            setprop("sim/G91/configuration/gauges/tacan-nav-active-desc","VOR or TACAN configuration inactive");
            setprop("sim/G91/configuration/gauges/frontal-central-01-active",1);
        };
        setprop("sim/G91/configuration/gauges/tacan-nav-active-trigger",0);
    };

    #// TACAN freq
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
 
