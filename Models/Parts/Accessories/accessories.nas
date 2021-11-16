#// Procedura NASAL per la gestione degli accessori
#// Adriano Bassignana  (abassign) nov. 2021

var prop = props.globals.initNode("sim/G91/accessories/illuminators/isParkingStartStop",0,"INT");
var prop = props.globals.initNode("sim/G91/accessories/illuminators/sx/x-m",-7.0,"DOUBLE");
var prop = props.globals.initNode("sim/G91/accessories/illuminators/sx/y-m",-7.0,"DOUBLE");
var prop = props.globals.initNode("sim/G91/accessories/illuminators/dx/x-m",-7.0,"DOUBLE");
var prop = props.globals.initNode("sim/G91/accessories/illuminators/dx/y-m",7.0,"DOUBLE");

var timeStep = 1;
var timeStepDivisor = 1;
var delta_time = 1;

var canopy_isFristTimeSetup = 1;
var isParkingStop = 1;


var DelayTime = {
    class_name: "DelayTime",

    new: func() {
        var obj = {
            timeStart: 0.0,
            sysTime: 0.0,
            lastDelayTime: 0.0,
            timeExceededSet: 0.0,
            isActive: 0,
            stop: 0,
        };
        me.sysTime = 0.0;
        me.timeStart = 0.0;
        me.lastDelayTime = 0.0;
        me.timeExceededSet = 0.0;
        me.isActive = 0;
        me.stop = 0;
        return {parents: [DelayTime]};
    },

    reset: func() {
        me.isActive = 0;
        me.stop = 0;
    },

    setStop: func(value = 1) {
        me.stop = value;
    },

    isTimeExceeded: func(delayTime) {
        me.timeExceededSet = delayTime;
        if (me.stop == 1) return 0;
        me.sysTime = systime();
        if (me.isActive == 0) {
            me.timeStart = me.sysTime;
            me.isActive = 1;
            me.lastDelayTime = 0.0;
        };
        if ((me.sysTime - (me.timeStart + me.lastDelayTime)) >= me.timeExceededSet) {
            me.lastDelayTime = me.timeExceededSet;
            return 1;
        } else {
            return 0;
        };
    },

    getTimeDelay: func() {
        return (me.sysTime - (me.timeStart + me.lastDelayTime));
    },
};


var StdIlluminator = {
    class_name: "StdIlluminator",

    new: func() {
        var obj = {
            id: nil,
            pathId: nil,
            isActive: 0,
            intensity: 0.0,
            pitch: 0.0,
            yaw: 0.0,
            course: 0.0,
            heading: 0.0,
            aiNode: nil,
        };
        return {parents: [StdIlluminator]};
    },

    init: func(id,course,heading) {
        me.id = id;
        me.course = course;
        me.heading = heading;
        me.aiNode = nil;
        me.pathId = "sim/G91/accessories/illuminators/" ~ me.id ~ "/";
    },

    addAIObject: func() {
        var position = geo.aircraft_position();
        var course = getprop("/orientation/heading-deg") + me.heading;
        position.apply_course_distance(course,me.course);
        var alt = geo.elevation(position.lat(), position.lon());
        if (alt != nil) {
            me.aiNode = props.Node.new({
                "type": "static",
                "model":"Aircraft/G91-R1B_HD/Models/Parts/Accessories/StandIlluminator-" ~ me.id ~ ".xml",
                "model-lowres":"Aircraft/G91-R1B_HD/Models/Parts/Accessories/StandIlluminator-" ~ me.id ~ ".xml",
                "latitude": position.lat(),
                "longitude": position.lon(),
                "altitude": alt*M2FT,
                "search-order": "DATA_ONLY"
            });
        };

        if (me.aiNode != nil) {
            fgcommand("add-aiobject",me.aiNode);
        };
    },

    removeAIObject: func() {
        if (me.aiNode != nil) {
            fgcommand("remove-aiobject",me.aiNode);
            me.aiNode = nil;
        };
    },

    getParams: func() {
        me.isActive = getprop(me.pathId ~ "active");
        me.intensity = getprop(me.pathId ~ "intensity");
        me.pitch = getprop(me.pathId ~ "pitch");
        me.yaw = getprop(me.pathId ~ "yaw");
        me.x = nil;
        me.y = nil;
    },

    set: func(isActive) {
        setprop(me.pathId ~ "active",isActive);
        me.isActive = isActive;
    },
};


var StdIlluminators = {
    class_name: "StdIlluminators",

    new: func() {
        var obj = {
            isOperative: 0,
            minAmbientLight: 0.0,
            illuminators: nil,
        };
        me.illuminators = {};
        return {parents: [StdIlluminators]};
    },

    getParams: func() {
        me.isOperative = getprop("sim/G91/accessories/illuminators/isOperative");
        me.minAmbientLight = getprop("sim/G91/accessories/illuminators/minAmbientLight");
        foreach(var id; keys(me.illuminators)) {
            me.illuminators[id].getParams();
        }
    },

    externalLghtConditionsIsOk: func() {
        if (getprop("fdm/jsbsim/systems/lightning/ambient-light") <= me.minAmbientLight) {
            return 1;
        } else {
            return 0;
        };
    },

    add: func(id,x0,y0) {
        me.illuminators[id] = StdIlluminator.new();
        me.illuminators[id].init(id,x0,y0);
    },

    set: func(isActive = 0) {
        foreach(var id; keys(me.illuminators)) {
            me.illuminators[id].set(isActive);
        };
    },

};


var delayTimeForCanopy = DelayTime.new();
var stdIlluminators = StdIlluminators.new();
stdIlluminators.add("sx",10,-50.0);
stdIlluminators.add("dx",10,50.0);


var accessories = func() {

    var isWow = getprop("fdm/jsbsim/gear/wow");

    #// Accessories on for Ground Services

    if (isWow) {
        timeStepDivisor = 2;
    } else {
        timeStepDivisor = 0.5;
    };

    #// StdIlluminators
    stdIlluminators.getParams();

    #// One shot time set open canopy
    if ((isWow) > 0 and (canopy_isFristTimeSetup or getprop("sim/G91/accessories/illuminators/isParkingStartStop") > 0)) {
        if (getprop("sim/G91/accessories/canopy/isOpenWhenStart") > 0) {
            if (getprop("fdm/jsbsim/systems/canopy/position-deg") < 1.0) {
                if (delayTimeForCanopy.isTimeExceeded(0.0)) {
                    setprop("fdm/jsbsim/systems/autopilot/handle-brake-activate",1);
                    setprop("fdm/jsbsim/systems/canopy/lever-trigger",0);
                };
                if (delayTimeForCanopy.isTimeExceeded(2.0)) {
                    setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-canopy-trigger",1);
                };
                if (delayTimeForCanopy.isTimeExceeded(4.0)) {
                    setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-canopy-trigger",0);
                    delayTimeForCanopy.setStop();
                    canopy_isFristTimeSetup = 0;
                    setprop("sim/G91/accessories/illuminators/isParkingStartStop",0);
                };
            };
        };
    } else {
        delayTimeForCanopy.reset();
    };

    if (isWow) {
        if (stdIlluminators.externalLghtConditionsIsOk()) {
            stdIlluminators.set(1);
        } else {
            stdIlluminators.set(0);
        };
    } else {
        stdIlluminators.set(0);
    };

};


setlistener("sim/G91/accessories/illuminators/sx/active", func {

    if (getprop("sim/G91/accessories/illuminators/sx/active") > 0) {
        if (stdIlluminators.illuminators["sx"].aiNode == nil) {
            stdIlluminators.illuminators["sx"].addAIObject();
        };
    } else {
        if (stdIlluminators.illuminators["sx"].aiNode == nil) {
            stdIlluminators.illuminators["sx"].removeAIObject();
        };
    };

}, 0, 1);


setlistener("sim/G91/accessories/illuminators/dx/active", func {

    if (getprop("sim/G91/accessories/illuminators/dx/active") > 0) {
        if (stdIlluminators.illuminators["dx"].aiNode == nil) {
            stdIlluminators.illuminators["dx"].addAIObject();
        };
    } else {
        if (stdIlluminators.illuminators["dx"].aiNode == nil) {
            stdIlluminators.illuminators["dx"].removeAIObject();
        };
    };

}, 0, 1);


var accessories_control = func() {

    accessories();

    delta_time = timeStep / timeStepDivisor;
    pilot_imp_controlTimer.restart(delta_time);

}


var pilot_imp_controlTimer = maketimer(delta_time, accessories_control);
pilot_imp_controlTimer.singleShot = 1;
pilot_imp_controlTimer.start();

