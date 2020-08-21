# Starter utility for effect and autostart engine

var prop = props.globals.initNode("fdm/jsbsim/systems/starter/gui/autostart-activate", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/starter/gui/autostart-is-active", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/starter/gui/autostart-clock-time", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/starter/gui/autostart-status-is-ok", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/starter/gui/autostart-message", "", "STRING");

var timeStep = 1.0;
var speed_up = 1;
var msgOutput = "";
var msgOutputStstus = "";

    
var timerEngine_starter = func() {

    var engineN1 = getprop("fdm/jsbsim/propulsion/engine[0]/n1");
    var engineN2 = getprop("fdm/jsbsim/propulsion/engine[0]/n2");
    var bus0V = getprop("fdm/jsbsim/systems/electric/bus[0]/V");
    var bus1V = getprop("fdm/jsbsim/systems/electric/bus[1]/V");
    var bus2V = getprop("fdm/jsbsim/systems/electric/bus[2]/V");
    var inverterPrimaryV = getprop("fdm/jsbsim/systems/electric/inv-primary/V");
    var inverterSecondaryV = getprop("fdm/jsbsim/systems/electric/inv-secondary/V");
    var autostart_status_is_ok = 0;
    speed_up = getprop("/sim/speed-up");
    
    if (engineN1 >= 0.38 and engineN2 >= 0.38 and bus0V >= 0.26 and bus1V >= 0.26 and bus2V >= 0.26 and inverterPrimaryV >= 110 and inverterSecondaryV >= 110) {
        setprop("fdm/jsbsim/systems/starter/gui/autostart-status-is-ok",1);
        autostart_status_is_ok = 1;
    } else {
        setprop("fdm/jsbsim/systems/starter/gui/autostart-status-is-ok",0);
        autostart_status_is_ok = 0;
    }
    
    var guiAutostartActivate = getprop("fdm/jsbsim/systems/starter/gui/autostart-activate");
    
    if (guiAutostartActivate >= 1 and autostart_status_is_ok == 0) {
        var guiAutostartIsActive = getprop("fdm/jsbsim/systems/starter/gui/autostart-is-active");
        var guiAutostartClockTime = getprop("fdm/jsbsim/systems/starter/gui/autostart-clock-time");
        guiAutostartClockTime = guiAutostartClockTime + 1;
        var startProcessActive = getprop("fdm/jsbsim/systems/starter/start-process-active");
        msgOutput = "Engine starter: ";
        
        if (guiAutostartIsActive == 0 and startProcessActive == 0.0) {
            msgOutput = msgOutput ~ "Autostarting engine procedure start";
            msgOutputStstus = "Autostarting engine start the procedure";
            if (getprop("fdm/jsbsim/systems/landing-gear/on-ground")) {
                setprop("fdm/jsbsim/systems/autopilot/handle-brake-activate",1);
            } else {
                setprop("fdm/jsbsim/systems/autopilot/handle-brake-activate",0);
            }
            setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",1);
            guiAutostartIsActive = 1;
            setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-bus0-bus1-battery-trigger",1);
            setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-internal-power-generator",0);
            setprop("fdm/jsbsim/systems/electric/bus[2]/primary-inverter/sw",0);
            setprop("fdm/jsbsim/systems/electric/bus[1]/secondary-inverter/sw",0);
        } else if (guiAutostartIsActive == 1) {
            msgOutput = msgOutput ~ "Activate battery";
            setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-bus0-bus1-battery-trigger",0);
            setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-bus0-bus1-battery",1);
            setprop("fdm/jsbsim/systems/starter/fuel-shut-off-valve-lock",1);
            setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",2);
            msgOutputStstus = "Activate battery";
        } else if (guiAutostartIsActive == 2) {
            msgOutput = msgOutput ~ "Prepare the starter procedure 1";
            setprop("fdm/jsbsim/systems/starter/emerg-engine",0);
            setprop("fdm/jsbsim/systems/starter/fuel-booster-pump",1);
            setprop("fdm/jsbsim/systems/starter/drop-tank-press",0);
            setprop("fdm/jsbsim/systems/starter/fuel-shut-off-valve",0);
            setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",3);
            msgOutputStstus = "Fuel booster pump on";
        } else if (guiAutostartIsActive == 3) {
            msgOutput = msgOutput ~ "Prepare the starter procedure 2";
            setprop("fdm/jsbsim/systems/starter/fuel-shut-off-valve-lock",0);
            setprop("fdm/jsbsim/systems/starter/engine-JPTL",1);
            setprop("fdm/jsbsim/systems/starter/NE",1);
            setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",4);
            msgOutputStstus = "Engine JPTL on";
        } else if (guiAutostartIsActive == 4) {
            if (engineN2 < 10) {
                msgOutput = msgOutput ~ "Prepare the starter procedure 3";
                setprop("fdm/jsbsim/systems/starter/ignition-on-throttle-togle",1);
                guiAutostartClockTime = 0;
                setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",5);
                msgOutputStstus = "Ignition push starter on throttle";
            } else {
                guiAutostartClockTime = 0;
                setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",8);
            }
        } else if (guiAutostartIsActive == 5 and guiAutostartClockTime == 2) {
            msgOutput = msgOutput ~ "Prepare the starter procedure 4";
            var swCoverTogle = getprop("fdm/jsbsim/systems/starter/sw-cover-togle");
            if (swCoverTogle == 0) {
                setprop("fdm/jsbsim/systems/starter/sw-cover-togle",1);
            } else {
                setprop("fdm/jsbsim/systems/starter/sw-cover-togle",0);
            }
            setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",6);
            msgOutputStstus = "Push starter";
            guiAutostartClockTime = 0;
        } else if (guiAutostartIsActive == 6 and guiAutostartClockTime == 2) {
            msgOutput = msgOutput ~ "Prepare the starter procedure 5";
            setprop("fdm/jsbsim/systems/starter/sw-push-togle",1);
            setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",7);
        } else if (guiAutostartIsActive == 7 and engineN2 >= 40) {
            msgOutput = msgOutput ~ "Prepare the starter procedure 6";
            guiAutostartClockTime = 0;
            setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",8);
            msgOutputStstus = "Engine N2 > 40%";
        } else if (guiAutostartIsActive == 8 and guiAutostartClockTime > 5) {
            msgOutput = msgOutput ~ "Prepare the starter procedure 7";
            setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-internal-power-generator",1);
            guiAutostartClockTime = 0;
            setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",9);
            msgOutputStstus = "Switch internal power generator on";
        } else if (guiAutostartIsActive == 9 and guiAutostartClockTime > 10) {
            msgOutput = msgOutput ~ "Prepare the starter procedure 8";
            setprop("fdm/jsbsim/systems/electric/bus[2]/primary-inverter/sw",1);
            setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",10);
            msgOutputStstus = "Switch primary inverter on";
        } else if (guiAutostartIsActive == 10) {
            msgOutput = msgOutput ~ "Prepare the starter procedure 9";
            setprop("fdm/jsbsim/systems/electric/bus[1]/secondary-inverter/sw",1);
            setprop("fdm/jsbsim/systems/canopy/lever-trigger",1);
            setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",100);
            msgOutputStstus = "Switch secondary inverter on";
        } else if (guiAutostartIsActive >= 100) {
            msgOutput = msgOutput ~ "Prepare the starter procedure is finish";
            setprop("fdm/jsbsim/systems/starter/gui/autostart-activate",0);
            setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",0);
            msgOutputStstus = "Autostarting procedure completed";
        }
        setprop("fdm/jsbsim/systems/starter/gui/autostart-clock-time",guiAutostartClockTime);
        setprop("fdm/jsbsim/systems/starter/gui/autostart-message",msgOutputStstus);
        print(msgOutput," clk: ",guiAutostartClockTime," is Active: ",guiAutostartIsActive," N1: ",engineN1," N2: ",engineN2," Bus0 V: ",bus0V," Bus1 V: ",bus1V," Bus2 V: ",bus2V," inv 1 V: ",inverterPrimaryV," inv 2 V: ",inverterSecondaryV);
    }

};


var timerEngine_starter_control = func() {
    
    timerEngine_starterTimer.restart(timeStep / speed_up);
    timerEngine_starter();
    
}

var timerEngine_starterTimer = maketimer(timeStep, timerEngine_starter_control);
timerEngine_starterTimer.singleShot = 1;
timerEngine_starterTimer.start();
