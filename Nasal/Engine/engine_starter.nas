# Starter utility for effect and autostart engine

var prop = props.globals.initNode("fdm/jsbsim/systems/starter/gui/autostart-activate", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/starter/gui/autostart-is-active", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/starter/gui/autostart-clock-time", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/starter/gui/autostart-status-is-ok", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/starter/gui/autostart-message", "", "STRING");

var timeStep = 1.0;
var timeStepEffective = timeStep;
var stepCameraRemain = 0;
var minCameraTime = 4;
var speed_up = 1.0;
var msgOutput = "";
var msgOutputStstus = "";

var nextTimeProcess = 0.0;


var ViewCamDataClass = {
    class_name: "ViewCamDataClass",

    new: func() {
        var obj = {
            view_number: 0,
            field_of_view: 0.0,
            heading_offset_deg: 0.0,
            pitch_offset_deg: 0.0,
            x_offset: 0.0,
            y_offset: 0.0,
            z_offset: 0.0,
        };
        return {parents: [ViewCamDataClass]};
    },

    init: func(view_number,field_of_view,heading_offset,pitch_offset,x_offset,y_offset,z_offset) {
        me.view_number = view_number;
        me.field_of_view = field_of_view;
        me.heading_offset_deg = heading_offset;
        me.pitch_offset_deg = pitch_offset;
        me.x_offset = x_offset;
        me.y_offset = y_offset;
        me.z_offset = z_offset;
    },

    difDegNorm: func(fromAng,toAng,stepRemain) {
        a1 = fromAng;
        a2 = toAng;
        fromAngRad = fromAng * 0.0174533;
        toAngRad = toAng * 0.0174533;
        difRad = math.asin(math.sin(toAngRad) * math.cos(fromAngRad) - math.cos(toAngRad) * math.sin(fromAngRad)) / stepRemain;
        value = math.asin(math.sin(toAngRad) * math.cos(difRad) + math.cos(toAngRad) * math.sin(difRad)) / 0.0174533;
        return value;
    },

    getView: func() {
        me.view_number = getprop("/sim/current-view/view-number");
        me.field_of_view = getprop("/sim/current-view/field-of-view");
        me.heading_offset_deg = getprop("/sim/current-view/heading-offset-deg");
        me.pitch_offset_deg = getprop("/sim/current-view/pitch-offset-deg");
        me.x_offset = getprop("/sim/current-view/x-offset-m");
        me.y_offset = getprop("/sim/current-view/y-offset-m");
        me.z_offset = getprop("/sim/current-view/z-offset-m");
    },

    setView: func() {
        setprop("/sim/current-view/view-number",me.view_number);
        setprop("/sim/current-view/field-of-view",me.field_of_view);
        setprop("/sim/current-view/heading-offset-deg",me.heading_offset_deg);
        setprop("/sim/current-view/pitch-offset-deg",me.pitch_offset_deg);
        setprop("/sim/current-view/x-offset-m",me.x_offset);
        setprop("/sim/current-view/y-offset-m",me.y_offset);
        setprop("/sim/current-view/z-offset-m",me.z_offset);
    },

    goViewTo: func(to,stepRemain) {
        me.getView();
        me.view_number = to.view_number;
        me.field_of_view = me.field_of_view + (to.field_of_view - me.field_of_view)/stepRemain;
        me.heading_offset_deg = me.difDegNorm(me.heading_offset_deg,to.heading_offset_deg,stepRemain);
        me.pitch_offset_deg = me.difDegNorm(me.pitch_offset_deg,to.pitch_offset_deg,stepRemain);
        me.x_offset = me.x_offset + (to.x_offset - me.x_offset)/stepRemain;
        me.y_offset = me.y_offset + (to.y_offset - me.y_offset)/stepRemain;
        me.z_offset = me.z_offset + (to.z_offset - me.z_offset)/stepRemain;
        me.setView();
    },
};

camera_save = ViewCamDataClass.new();
camera_position = ViewCamDataClass.new();
camera_to_position = ViewCamDataClass.new();


var timerEngine_starter = func(timeNow, factorTimeStep) {

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
            camera_save.getView();
            camera_to_position.init(0,38.28,354.6,-29.75,0.25,0.55,-2.9);
            nextTimeProcess = timeNow + minCameraTime * factorTimeStep;
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
            camera_to_position.init(0,38.28,17.59,-54.46,-0.245,0.50,-2.9);
            nextTimeProcess = timeNow + minCameraTime * factorTimeStep;
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
            camera_to_position.init(0,38.28,8.72,-47.7,-0.245,0.56,-2.6);
            nextTimeProcess = timeNow + minCameraTime * factorTimeStep;
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
            camera_to_position.init(0,51.74,3.94,-43.08,-0.246,0.55,-2.6);
            nextTimeProcess = timeNow + minCameraTime * factorTimeStep;
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
            camera_to_position.init(0,51.74,330.5,-8.62,-0.15,0.55,-2.6);
            nextTimeProcess = timeNow + minCameraTime * factorTimeStep;
            msgOutput = msgOutput ~ "Prepare the starter procedure 5";
            setprop("fdm/jsbsim/systems/starter/sw-push-togle",1);
            setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",7);
        } else if (guiAutostartIsActive == 7 and engineN2 >= 40) {
            setprop("fdm/jsbsim/systems/starter/fuel-booster-pump",0);
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
            camera_save.setView();
            nextTimeProcess = 0.0;
            msgOutput = msgOutput ~ "Prepare the starter procedure is finish";
            setprop("fdm/jsbsim/systems/starter/gui/autostart-activate",0);
            setprop("fdm/jsbsim/systems/starter/gui/autostart-is-active",0);
            msgOutputStstus = "Autostarting procedure completed";
        };
        setprop("fdm/jsbsim/systems/starter/gui/autostart-clock-time",guiAutostartClockTime);
        setprop("fdm/jsbsim/systems/starter/gui/autostart-message",msgOutputStstus);
    }

};



var timerEngine_starter_control = func() {
    
    timerEngine_starterTimer.restart(timeStep / speed_up);
    timeNow = getprop("/sim/time/elapsed-sec");
    if (timeNow >= nextTimeProcess) {
        stepCameraRemain = 0;
        timeStepEffective = timeStep / speed_up;
        timerEngine_starter(timeNow,1.0);
    } else {
        #// Camera action
        timeStepEffective = 0.01;
        if (stepCameraRemain == 0) {
            delta_sec = getprop("/sim/time/delta-sec");
            stepCameraRemain = int((nextTimeProcess - (minCameraTime * 0.7) - timeNow) / delta_sec);
        };
        if (stepCameraRemain >= 1) {
            camera_position.goViewTo(camera_to_position,stepCameraRemain);
            stepCameraRemain += -1;
        };
    };
    
}



var timerEngine_starterTimer = maketimer(timeStepEffective, timerEngine_starter_control);
timerEngine_starterTimer.singleShot = 1;
timerEngine_starterTimer.start();
