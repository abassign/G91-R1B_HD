# Starter utility for effect and autostart engine

var prop = props.globals.initNode("fdm/jsbsim/systems/starter/gui/autostart-activate", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/starter/gui/autostart-is-active", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/starter/gui/autostart-clock-time", 0, "INT");


var timerEngine_starter = maketimer(1.0, func() {

    var guiAutostartActivate = getprop("fdm/jsbsim/systems/starter/gui/autostart-activate");
    if (guiAutostartActivate == 1) {
        var guiAutostartIsActive = getprop("fdm/jsbsim/systems/starter/gui/autostart-is-active");
        var guiAutostartClockTime = getprop("fdm/jsbsim/systems/starter/gui/autostart-clock-time");
        guiAutostartClockTime = guiAutostartClockTime + 1;
        var engineN2 = getprop("fdm/jsbsim/propulsion/engine[0]/n2");
        var startProcessActive = getprop("fdm/jsbsim/systems/starter/start-process-active");
        
        if (guiAutostartIsActive == 0 and engineN2 < 10.0 and startProcessActive == 0.0) {
            print("timerEngine_starter: Autostarting engine procedure ok");
            setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",1);
            guiAutostartIsActive = 1; 
            setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-bus0-bus1-battery-trigger",1);
            setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-internal-power-generator",0);
            setprop("fdm/jsbsim/systems/electric/bus[2]/primary-inverter/sw",0);
            setprop("fdm/jsbsim/systems/electric/bus[1]/secondary-inverter/sw",0);
        } else if (guiAutostartIsActive == 1) {
            print("timerEngine_starter: Second step activate battery");
            setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-bus0-bus1-battery-trigger",0);
            setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-bus0-bus1-battery",1);
            setprop("fdm/jsbsim/systems/starter/fuel-shut-off-valve-lock",1);
            setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",2);
        } else if (guiAutostartIsActive == 2) {
            print("timerEngine_starter: Prepare the starter procedure 1");
            setprop("fdm/jsbsim/systems/starter/emerg-engine",0);
            setprop("fdm/jsbsim/systems/starter/fuel-booster-pump",1);
            setprop("fdm/jsbsim/systems/starter/drop-tank-press",0);
            setprop("fdm/jsbsim/systems/starter/fuel-shut-off-valve",0);
            setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",3);
        } else if (guiAutostartIsActive == 3) {
            print("timerEngine_starter: Prepare the starter procedure 2");
            setprop("fdm/jsbsim/systems/starter/fuel-shut-off-valve-lock",0);
            setprop("fdm/jsbsim/systems/starter/fuel-shut-off-valve-lock",0);
            setprop("fdm/jsbsim/systems/starter/engine-JPTL",1);
            setprop("fdm/jsbsim/systems/starter/NE",1);
            setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",4);
        } else if (guiAutostartIsActive == 4) {
            print("timerEngine_starter: Prepare the starter procedure 3");
            setprop("fdm/jsbsim/systems/starter/ignition-on-throttle-togle",1);
            guiAutostartClockTime = 0;
            setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",5);
        } else if (guiAutostartIsActive == 5 and guiAutostartClockTime == 2) {
            print("timerEngine_starter: Prepare the starter procedure 4");
            var swCoverTogle = getprop("fdm/jsbsim/systems/starter/sw-cover-togle");
            if (swCoverTogle == 0) {
                setprop("fdm/jsbsim/systems/starter/sw-cover-togle",1);
            } else {
                setprop("fdm/jsbsim/systems/starter/sw-cover-togle",0);
            }
            setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",6);
            guiAutostartClockTime = 0;
        } else if (guiAutostartIsActive == 6 and guiAutostartClockTime == 2) {
            print("timerEngine_starter: Prepare the starter procedure 5");
            setprop("fdm/jsbsim/systems/starter/sw-push-togle",1);
            setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",7);
        } else if (guiAutostartIsActive == 7 and engineN2 >= 30) {
            print("timerEngine_starter: Prepare the starter procedure 6");
            guiAutostartClockTime = 0;
            setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",8);
        } else if (guiAutostartIsActive == 8 and guiAutostartClockTime > 5) {
            print("timerEngine_starter: Prepare the starter procedure 7");
            setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-internal-power-generator",1);
            guiAutostartClockTime = 0;
            setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",9);
        } else if (guiAutostartIsActive == 9 and guiAutostartClockTime > 5) {
            print("timerEngine_starter: Prepare the starter procedure 7");
            setprop("fdm/jsbsim/systems/electric/bus[2]/primary-inverter/sw",1);
            setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",10);
        } else if (guiAutostartIsActive == 10) {
            print("timerEngine_starter: Prepare the starter procedure 7");
            setprop("fdm/jsbsim/systems/electric/bus[1]/secondary-inverter/sw",1);
            setprop("fdm/jsbsim/systems/canopy/lever-trigger",1);
            setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",100);
        } else if (guiAutostartIsActive >= 100) {
            print("timerEngine_starter: End autostarter procedure");
            setprop("fdm/jsbsim/systems/starter/gui/autostart-activate",0);
            setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",0);
        }
        setprop("fdm/jsbsim/systems/starter/gui/autostart-clock-time",guiAutostartClockTime);
    }

});

timerEngine_starter.start();
