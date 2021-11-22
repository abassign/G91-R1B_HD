#// Procedura NASAL per la gestione degli accessori
#// Adriano Bassignana  (abassign) nov. 2021

var prop = props.globals.initNode("sim/G91/accessories/standIlluminators/isParkingStartStop",1,"INT");
var prop = props.globals.initNode("sim/G91/accessories/standIlluminators/isOperative",0,"INT");
var prop = props.globals.initNode("sim/G91/accessories/standIlluminators/light/intensity",0,"DOUBLE");


var timeStep = 1;
var timeStepDivisor = 1;
var delta_time = 1;

var canopy_isStartRestart = 0;
var isParkingStop = 1;

var light_ambient_intensity = 0.0;
var light_spot_ambient_intensity = 0.0;


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
            node: nil,
            modAI_added: nil,
            modAI_added_id: nil,
            coordinates: nil,
            manualTraking: 0,
        };
        return {parents: [StdIlluminator]};
    },

    init: func(id) {
        me.id = id;
        me.isActive = 0;
        me.course = nil;
        me.heading = nil;
        me.node = nil;
        me.modAI_added = nil;
        me.modAI_added_id = nil;
        me.coordinates = nil;
        me.autotraking = 1;
        me.pathId = "sim/G91/accessories/standIlluminators/" ~ me.id ~ "/";
        me.manualTraking = 0;
    },

    getParams: func() {
        me.isActive = getprop(me.pathId ~ "light/active");
        me.intensity = getprop(me.pathId ~ "light/intensity");
        me.pitch = getprop(me.pathId ~ "pitch");
        me.yaw = getprop(me.pathId ~ "yaw");
        me.course = getprop(me.pathId ~ "course");
        me.heading = getprop(me.pathId ~ "heading");
    },

    addAIObject: func() {
        if (me.node == nil) {
            var position = geo.aircraft_position();
            var course = getprop("/orientation/heading-deg") + me.heading;
            position.apply_course_distance(course,me.course);
            var alt = geo.elevation(position.lat(), position.lon());
            if (alt != nil) {
                me.node = {
                    "type": "static",
                    #//"model":"Aircraft/G91-R1B_HD/Models/Parts/Accessories/StandIlluminator-" ~ me.id ~ ".xml",
                    "model":"Aircraft/G91-R1B_HD/Models/Parts/Accessories/StandIlluminator.xml",
                    "model-lowres":"Aircraft/G91-R1B_HD/Models/Parts/Accessories/StandIlluminator.xml",
                    "latitude": position.lat(),
                    "longitude": position.lon(),
                    "altitude": alt*M2FT,
                    "search-order": "DATA_ONLY"
                };
                props.Node.new(me.node);
                if (me.node != nil) {
                    fgcommand("add-aiobject",me.node);
                    me.modAI_added = getprop("ai/models/model-added");
                    me.modAI_added_id = getprop(me.modAI_added ~ "/id");
                    me.coordinates = geo.Coord.new();
                    me.coordinates.set_latlon(getprop(me.modAI_added ~ "/position/latitude-deg"),getprop(me.modAI_added ~ "/position/longitude-deg"),0.0);
                };
            };
        };
    },

    checkChange: func() {
        var isChange = 0;
        if (me.modAI_added != nil) {
            isChange = getprop(me.modAI_added ~ "/sim/G91/accessories/standIlluminators/manual-change");
            if (isChange == 1 or isChange == 2) {
                me.manualTraking = 1;
                setprop("sim/G91/accessories/standIlluminators/autotraking",0);
                setprop(me.modAI_added ~ "/sim/G91/accessories/standIlluminators/manual-change",0);
            };
        };
        return isChange;
    },

    removeAIObject: func() {
        if (me.node != nil) {
            fgcommand("remove-aiobject",{"id":me.modAI_added_id});
            me.node = nil;
        };
    },

    setYaw: func() {
        var yawAddr = me.modAI_added ~ "/sim/G91/accessories/standIlluminators/yaw";
        if (me.manualTraking == 0) {
            if (me.coordinates != nil) {
                me.yaw = geo.normdeg(me.coordinates.course_to(geo.aircraft_position()) - 180.0);
            };
            setprop(yawAddr,me.yaw);
        } else {
            me.yaw = getprop(yawAddr);
        };
    },

    setPitch: func() {
        var pitchAddr = me.modAI_added ~ "/sim/G91/accessories/standIlluminators/pitch";
        if (me.manualTraking == 0) {
            setprop(pitchAddr,me.pitch);
        } else {
            me.pitch = getprop(pitchAddr);
        };
    },

    setLightIntensity: func() {
        var intensityAddr = me.modAI_added ~ "/sim/G91/accessories/standIlluminators/light/intensity";
        if (me.manualTraking == 0) {
            setprop(intensityAddr,me.intensity);
        } else {
            me.intensity = getprop(intensityAddr);
        };
    },

    setLight: func(light) {
        setprop(me.modAI_added ~ "/sim/G91/accessories/standIlluminators/light/intensity",light);
    },

    setLightSpot: func(light) {
        setprop(me.modAI_added ~ "/sim/G91/accessories/standIlluminators/light/intensity-spot",light);
    },

    getActive: func() {
        me.isActive = getprop(me.pathId ~ "light/active");
        return me.isActive;
    },

    setAiActive: func(active) {
        setprop(me.modAI_added ~ "/sim/G91/accessories/standIlluminators/light/active",active);
        me.isActive = active;
    },

};


var StdIlluminators = {
    class_name: "StdIlluminators",

    new: func() {
        var obj = {
            isOperative: 0,
            minAmbientLight: 0.0,
            illuminators: nil,
            autotraking: 0,
        };
        me.isOperative = 0;
        me.minAmbientLight = 0.0;
        me.illuminators = {};
        me.autotraking = 0;
        return {parents: [StdIlluminators]};
    },

    getParams: func() {
        me.minAmbientLight = getprop("sim/G91/accessories/standIlluminators/minAmbientLight");
        me.autotraking = getprop("sim/G91/accessories/standIlluminators/autotraking");
        foreach(var id; keys(me.illuminators)) {
            me.illuminators[id].getParams();
            me.manualTraking = 0;
        }
    },

    externalLghtConditionsIsOk: func() {
        if (getprop("fdm/jsbsim/systems/lightning/ambient-light") <= me.minAmbientLight) {
            return 1;
        } else {
            return 0;
        };
    },

    add: func(id) {
        me.illuminators[id] = StdIlluminator.new();
        me.illuminators[id].init(id);
    },

    setOperative: func(isOperative) {
        me.isOperative = isOperative;
        if (isOperative > 0) {
            foreach(var id; keys(me.illuminators)) {
                if (me.illuminators[id].getActive() > 0) {
                    if (me.illuminators[id].node == nil) {
                        me.illuminators[id].addAIObject();
                    };
                } else {
                    if (me.illuminators[id].node != nil) {
                        me.illuminators[id].removeAIObject();
                    };
                };
            };
        } else {
            foreach(var id; keys(me.illuminators)) {
                if (me.illuminators[id].node != nil) {
                    me.illuminators[id].removeAIObject();
                };
            };
        };
    },

    checkChanges: func() {
        foreach(var id; keys(me.illuminators)) {
            me.illuminators[id].checkChange();
        };
    },

    isActive: func() {
        foreach(var id; keys(me.illuminators)) {
            if (me.illuminators[id].isActive != nil and me.illuminators[id].isActive > 0) {
               return 1;
            };
        };
        return 0;
    },

    rersetAutotraking: func() {
        if (getprop("sim/G91/accessories/standIlluminators/autotraking") > 0) {
            foreach(var id; keys(me.illuminators)) {
                me.illuminators[id].manualTraking = 0;
            };
        };
    },

    setYawPitchIntensity: func() {
        foreach(var id; keys(me.illuminators)) {
            me.illuminators[id].setYaw();
            me.illuminators[id].setPitch();
            me.illuminators[id].setLightIntensity();
        };
    },

    setLights: func(light_intensity,light_spot_intensity,active) {
        foreach(var id; keys(me.illuminators)) {
            me.illuminators[id].setLight(light_intensity);
            me.illuminators[id].setLightSpot(light_spot_intensity);
            me.illuminators[id].setAiActive(active);
        };
    },

};


var delayTimeForCanopy = DelayTime.new();
var stdIlluminators = StdIlluminators.new();


var accessories = func() {

    var isWow = getprop("fdm/jsbsim/gear/wow");
    canopy_isStartRestart = getprop("sim/G91/accessories/standIlluminators/isParkingStartStop")

    #// Accessories on for Ground Services
    #// One shot time set open canopy
    #// DEVE PARTIRE CON UN CERTO RITARDO!

    if (isWow > 0 and canopy_isStartRestart == 1) {
        stdIlluminators.add("I01");
        stdIlluminators.add("I02");
        stdIlluminators.add("I03");
        stdIlluminators.add("I04");
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
                    canopy_isStartRestart = 0;
                    setprop("sim/G91/accessories/standIlluminators/isParkingStartStop",0);
                };
            };
        };
    } else if (isWow > 0 canopy_isStartRestart == 2) {
        stdIlluminators.add("I01");
        stdIlluminators.add("I02");
        stdIlluminators.add("I03");
        stdIlluminators.add("I04");
    } else {
        delayTimeForCanopy.reset();
    };

    #// Intensity light control

    if (isWow) {
        stdIlluminators.getParams();
        if (stdIlluminators.externalLghtConditionsIsOk() and stdIlluminators.isActive()) {
            stdIlluminators.checkChanges();
            stdIlluminators.setOperative(1);
            stdIlluminators.setYawPitchIntensity();
            timeStepDivisor = 10.0;
            light_ambient_intensity = getprop("/fdm/jsbsim/systems/lightning/accessories/standIlluminators/light/intensity");
            light_spot_ambient_intensity = getprop("/fdm/jsbsim/systems/lightning/accessories/standIlluminators/light/intensity-spot");
            stdIlluminators.setLights(light_ambient_intensity,light_spot_ambient_intensity,1);
        } else {
            stdIlluminators.setOperative(0);
            timeStepDivisor = 1.0;
        };
    } else {
        stdIlluminators.setOperative(0);
        timeStepDivisor = 0.5;
    };

};


setlistener("sim/G91/accessories/standIlluminators/autotraking", func {

    if (getprop("sim/G91/accessories/standIlluminators/autotraking") > 0) {
        stdIlluminators.rersetAutotraking();
    };

}, 0, 1);


var accessories_control = func() {

    accessories();

    delta_time = timeStep / timeStepDivisor;
    pilot_imp_controlTimer.restart(delta_time);

};


var pilot_imp_controlTimer = maketimer(delta_time, accessories_control);
pilot_imp_controlTimer.singleShot = 1;
pilot_imp_controlTimer.start();

