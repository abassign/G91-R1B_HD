#// Procedura NASAL per la gestione degli accessori
#// Adriano Bassignana  (abassign) nov. 2021

var prop = props.globals.initNode("sim/G91/accessories/LEMIR14/type",0,"INT");
var prop = props.globals.initNode("sim/G91/accessories/LEMIR14/type-cup-14",1,"INT");
var prop = props.globals.initNode("sim/G91/accessories/LEMIR14/type-cone-light",0,"INT");
var prop = props.globals.initNode("sim/G91/accessories/LEMIR14/isOperative",0,"INT");
var prop = props.globals.initNode("sim/G91/accessories/LEMIR14/runwayLong",1000.0,"DOUBLE");
var prop = props.globals.initNode("sim/G91/accessories/LEMIR14/runwayBreadth",15.0,"DOUBLE");
var prop = props.globals.initNode("sim/G91/accessories/LEMIR14/lightStep",30,"DOUBLE");
var prop = props.globals.initNode("sim/G91/accessories/LEMIR14/light/intensity",0.5,"DOUBLE");
var prop = props.globals.initNode("sim/G91/accessories/LEMIR14/light/ALSIntensity",1.0,"DOUBLE");
var prop = props.globals.initNode("sim/G91/accessories/LEMIR14/light/maxDistFromViewPoint",200.0,"DOUBLE");


var timeStep = 1;
var timeStepDivisor = 1;
var delta_time = 1;

var distHm = 0.0;
var distMax = 0.0;
var distStep = 0.0;

var light_ambient_intensity = 0.0;
var light_spot_ambient_intensity = 0.0;

var typeOfLemir = 1;


var Lemir14Light = {
    class_name: "Lemir14Light",

    new: func() {
        var obj = {
            id: nil,
            pathId: nil,
            isActive: 0,
            intensity: 0.0,
            course: 0.0,
            heading: 0.0,
            distHm: 0.0,
            distLm: 0.0,
            node: nil,
            modAI_added: nil,
            modAI_added_id: nil,
            coordinates: nil,
            distFromAirplane: 0.0,
            position: nil,
        };
        return {parents: [Lemir14Light]};
    },

    init: func(id,distHm,distLm) {
        me.id = id;
        me.isActive = 1;
        me.intensity = 1.0;
        me.distHm = distHm;
        me.distLm = distLm;
        me.node = nil;
        me.modAI_added = nil;
        me.modAI_added_id = nil;
        me.coordinates = nil;
        me.position = geo.Coord.new();
        me.pathId = "sim/G91/accessories/LEMIR14/" ~ me.id ~ "/";
        me.heading = math.atan2(distHm,distLm) * R2D;
        me.course = math.sqrt(math.pow(distLm,2) + math.pow(distHm,2));
        me.distFromViewPoint = 0.0;
    },

    addAIObject: func(aircraftPosition,heading) {
        me.position.set_latlon(aircraftPosition.lat(),aircraftPosition.lon(),0.0);
        var course = heading + me.heading;
        me.position.apply_course_distance(course,me.course);
        var alt = geo.elevation(me.position.lat(), me.position.lon());
        if (alt != nil) {
            if (typeOfLemir == 0) {
                me.node = {
                    "type": "static",
                    "model":"Aircraft/G91-R1B_HD/Models/Parts/Accessories/LEMIR14.xml",
                    "model-lowres":"Aircraft/G91-R1B_HD/Models/Parts/Accessories/LEMIR14.xml",
                    "latitude": me.position.lat(),
                    "longitude": me.position.lon(),
                    "altitude": alt*M2FT,
                    "search-order": "DATA_ONLY"
                };
                print("*** Type 0: ",position.lat()," | ",position.lon());
            } else {
                me.node = {
                    "type": "static",
                    "model":"Aircraft/G91-R1B_HD/Models/Parts/Accessories/LEMIR-Cone.xml",
                    "model-lowres":"Aircraft/G91-R1B_HD/Models/Parts/Accessories/LEMIR-Cone.xml",
                    "latitude": me.position.lat(),
                    "longitude": me.position.lon(),
                    "altitude": alt*M2FT,
                    "search-order": "DATA_ONLY"
                };
                print("*** Type 1: ",me.position.lat()," | ",me.position.lon());
            };
            if (me.node == nil) props.Node.new(me.node);
            if (me.node != nil) {
                fgcommand("add-aiobject",me.node);
                me.modAI_added = getprop("ai/models/model-added");
                me.modAI_added_id = getprop(me.modAI_added ~ "/id");
                me.coordinates = geo.Coord.new();
                me.coordinates.set_latlon(getprop(me.modAI_added ~ "/position/latitude-deg"),getprop(me.modAI_added ~ "/position/longitude-deg"),0.0);
            };
        };
    },

    removeAIObject: func() {
        if (me.node != nil) {
            fgcommand("remove-aiobject",{"id":me.modAI_added_id});
            #me.node = nil;
        };
    },

    getDistFromViewPoint: func(refGeoCoord) {
        if (me.node != nil) {
            me.distFromViewPoint = me.coordinates.direct_distance_to(refGeoCoord);
            setprop(me.modAI_added ~ "/sim/G91/accessories/LEMIR14/light/distFromViewPoint",me.distFromViewPoint);
        };
    },

    setLight: func(light) {
        setprop(me.modAI_added ~ "/sim/G91/accessories/LEMIR14/light/intensity",light);
    },

    setLightSpot: func(light) {
        setprop(me.modAI_added ~ "/sim/G91/accessories/LEMIR14/light/intensity-spot",light);
    },

    getActive: func() {
        me.isActive = getprop(me.pathId ~ "light/active");
        return me.isActive;
    },

    setAiActive: func(active) {
        setprop(me.modAI_added ~ "/sim/G91/accessories/LEMIR14/light/active",active);
        me.isActive = active;
    },

};


var Lemir14Lights = {
    class_name: "Lemir14Lights",

    new: func() {
        var obj = {
            isOperative: 0,
            minAmbientLight: 0.0,
            lemir14Lights: nil,
            minDistFromViewPoint: 0.0,
        };
        me.isOperative = 0;
        me.minAmbientLight = 0.0;
        me.minDistFromViewPoint = 0.0;
        me.lemir14Lights = {};
        return {parents: [Lemir14Lights]};
    },

    add: func(id,distHm,distLm) {
        if (!contains(me.lemir14Lights,id)) {
            me.lemir14Lights[id] = Lemir14Light.new();
            me.lemir14Lights[id].init(id,distHm,distLm);
            print("+++ id: ",id);
        };
    },

    setOperative: func(isOperative) {
        me.isOperative = isOperative;
        var aircraftPosition = geo.aircraft_position();
        if (isOperative > 0) {
            foreach(var id; keys(me.lemir14Lights)) {
                if (me.lemir14Lights[id].node == nil) {
                    me.lemir14Lights[id].addAIObject(aircraftPosition,getprop("/orientation/heading-deg"));
                    print("+-+ id: ",id);
                };
            };
        } else {
            foreach(var id; keys(me.lemir14Lights)) {
                if (me.lemir14Lights[id].node != nil) {
                    me.lemir14Lights[id].removeAIObject();
                    delete(me.lemir14Lights,id);
                    print("--- id: ",id);
                };
            };
        };
    },

    checkDisplay: func() {
        var position = geo.aircraft_position();
        me.minDistFromViewPoint = 99999999.0;
        foreach(var id; keys(me.lemir14Lights)) {
            me.lemir14Lights[id].getDistFromViewPoint(position);
            if (me.lemir14Lights[id].distFromViewPoint < me.minDistFromViewPoint) me.minDistFromViewPoint = me.lemir14Lights[id].distFromViewPoint;
        };
        if (me.minDistFromViewPoint > 100.0) {
            setprop("sim/G91/accessories/LEMIR14/light/ALSIntensity",-0.2 + math.log10(me.minDistFromViewPoint/50.0));
        };
    },

    isActive: func() {
        foreach(var id; keys(me.lemir14Lights)) {
            if (me.lemir14Lights[id].isActive != nil and me.lemir14Lights[id].isActive > 0) {
               return 1;
            };
        };
        return 0;
    },

    setLights: func(light_intensity,light_spot_intensity,active) {
        foreach(var id; keys(me.lemir14Lights)) {
            me.lemir14Lights[id].setLight(light_intensity);
            me.lemir14Lights[id].setLightSpot(light_spot_intensity);
            me.lemir14Lights[id].setAiActive(active);
        };
    },

};


var delayTimeForCanopy = DelayTime.new();
var lemir14 = Lemir14Lights.new();


var lemir = func() {

    var isWow = getprop("fdm/jsbsim/gear/wow");
    var isOperative = getprop("sim/G91/accessories/LEMIR14/isOperative");
    #// Accessories on for Ground Services
    #// One shot time set open canopy
    #// DEVE PARTIRE CON UN CERTO RITARDO!

    if (isOperative == 4 or isOperative == 5) {
        if (isOperative == 4) {
            setprop("sim/G91/accessories/LEMIR14/isOperative",5);
        } else {
            lemir14.setOperative(0);
            setprop("sim/G91/accessories/LEMIR14/isOperative",1);
        };
    } else {
        if (isOperative == 3) {
            lemir14.checkDisplay();
        } else {
            if (isWow > 0 and isOperative == 1) {
                distHm = getprop("sim/G91/accessories/LEMIR14/runwayBreadth");
                distMax = getprop("sim/G91/accessories/LEMIR14/runwayLong");
                distStep = getprop("sim/G91/accessories/LEMIR14/lightStep");
                var distLm = -distStep;
                var id = 0;
                while (distLm <= distMax) {
                    distLm = distLm + distStep;
                    id += 1;
                    lemir14.add("LT01R-" ~ int(id),distHm,distLm);
                    lemir14.add("LT01L-" ~ int(id),-distHm,distLm);
                };
                lemir14.checkDisplay();
                setprop("sim/G91/accessories/LEMIR14/isOperative",2);
                isOperative = 2;
            };
            if (isOperative == 2) {
                lemir14.setOperative(1);
                setprop("sim/G91/accessories/LEMIR14/isOperative",3);
                isOperative = 3;
            };
            if (isOperative == 9) {
                lemir14.setOperative(0);
                setprop("sim/G91/accessories/LEMIR14/isOperative",0);
            };
        };
    };

};


setlistener("sim/G91/accessories/LEMIR14/type", func {

    var type = getprop("sim/G91/accessories/LEMIR14/type");
    if (typeOfLemir != type) {
        typeOfLemir = type;
        setprop("sim/G91/accessories/LEMIR14/isOperative",4);
    };
    if (typeOfLemir == 0) {
        setprop("sim/G91/accessories/LEMIR14/type-cup-14",1);
        setprop("sim/G91/accessories/LEMIR14/type-cone-light",0);
    } else {
        if (typeOfLemir == 1) {
            setprop("sim/G91/accessories/LEMIR14/type-cup-14",0);
            setprop("sim/G91/accessories/LEMIR14/type-cone-light",1);
        };
    };

}, 0, 1);


setlistener("sim/G91/accessories/LEMIR14/runwayBreadth", func {

    var isOperative = getprop("sim/G91/accessories/LEMIR14/isOperative");
    if (getprop("sim/G91/accessories/LEMIR14/runwayBreadth") != distHm and (isOperative == 0 or isOperative == 3 or isOperative == 4)) {
        setprop("sim/G91/accessories/LEMIR14/isOperative",4);
    };

}, 0, 1);


setlistener("sim/G91/accessories/LEMIR14/runwayBreadth", func {

    var isOperative = getprop("sim/G91/accessories/LEMIR14/isOperative");
    if (getprop("sim/G91/accessories/LEMIR14/runwayLong") != distMax and (isOperative == 0 or isOperative == 3  or isOperative == 4)) {
        setprop("sim/G91/accessories/LEMIR14/isOperative",4);
    };

}, 0, 1);


setlistener("sim/G91/accessories/LEMIR14/lightStep", func {

    var isOperative = getprop("sim/G91/accessories/LEMIR14/isOperative");
    if (getprop("sim/G91/accessories/LEMIR14/lightStep") != distStep and (isOperative == 0 or isOperative == 3  or isOperative == 4)) {
        setprop("sim/G91/accessories/LEMIR14/isOperative",4);
    };

}, 0, 1);


var lemir_ctl = func() {

    lemir();

    delta_time = timeStep / timeStepDivisor;
    lemir_ctlTimer.restart(delta_time);

};


var lemir_ctlTimer = maketimer(delta_time, lemir_ctl);
lemir_ctlTimer.singleShot = 1;
lemir_ctlTimer.start();

