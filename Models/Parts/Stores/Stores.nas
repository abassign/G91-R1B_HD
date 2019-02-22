var prop = props.globals.initNode("sim/G91/stores/sw-emergency-release", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/handleRequestToDrop", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/handle/handleRequestToDropPosition", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/startStoreView", -1, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/lastStoreBalObj", "", "STRING");
var prop = props.globals.initNode("sim/G91/stores/lastStoreBalObjDataPath", "", "STRING");

# Drop trigger for store in the station
var prop = props.globals.initNode("sim/G91/stores/stationSxExternalDropFromStation", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/stationSxInternalDropFromStation", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/stationDxInternalDropFromStation", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/stationDxExternalDropFromStation", 0, "DOUBLE");

# Weight for fuel thank (lbs)
var prop = props.globals.initNode("sim/G91/stores/stationSxExternalContent/level-lbs", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/stationSxInternalContent/level-lbs", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/stationDxInternalContent/level-lbs", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/stationDxExternalContent/level-lbs", 0, "DOUBLE");

# ----------
# LOADER end REMOVE loads
#
# Loader binding to parameters:
# handleRequestToLoadStation - station number
# handleRequestToLoadType - type store 
# stationDxExternalTypeLoad define the load stationDxExternalTypeLoad
# 0 - nothing
# 10 - Thank type 450 lb (260 lit)
# 11 - PAN Smoking Thank
# 20 - Single MK82
# ----------

var prop = props.globals.initNode("sim/G91/stores/handleRequestToLoadStation", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/handleRequestToLoadType", 0, "DOUBLE");

var prop = props.globals.initNode("sim/G91/stores/stationSxExternalTypeLoad", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/stationSxInternalTypeLoad", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/stationDxInternalTypeLoad", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/stationDxExternalTypeLoad", 0, "DOUBLE");

# Generic listener for load/unload all type stations and load

setlistener("sim/G91/stores/handleRequestToLoadStation", func {
    var handleRequestToLoadStation = props.globals.getNode("sim/G91/stores/handleRequestToLoadStation",1).getValue();
    var isLoadStation = 0;
    var isUnLoadStation = 0;
    var loadType = 0;
    if (handleRequestToLoadStation > 0)  {
        # Load station
        isLoadStation = handleRequestToLoadStation;
        loadType = props.globals.getNode("sim/G91/stores/handleRequestToLoadType",1).getValue();
        print("Stores: load handleRequestToLoadStation id = ",isLoadStation," loadType = ",loadType);
        if (isLoadStation == 1) {
            stationSxExternalTypeLoad(loadType);
        } else if (isLoadStation == 2) {
            stationSxInternalTypeLoad(loadType);
        } else if (isLoadStation == 3) {
            stationDxInternalTypeLoad(loadType);
        } else if (isLoadStation == 4) {
            stationDxExternalTypeLoad(loadType);
        }
    } else if (handleRequestToLoadStation < 0)  {
        # Unload station
        isUnLoadStation = -handleRequestToLoadStation;
        print("Stores: unload handleRequestToLoadStation id = ",isUnLoadStation);
        if (isUnLoadStation == 1) {
            stationSxExternalTypeLoadDrop();
        } else if (isUnLoadStation == 2) {
            stationSxInternalTypeLoadDrop();
        } else if (isUnLoadStation == 3) {
            stationDxInternalTypeLoadDrop();
        } else if (isUnLoadStation == 4) {
            stationDxExternalTypeLoadDrop();
        }
    }
    # The load-unload station command is terminated, remove the action
    if (handleRequestToLoadStation != 0) {
        setprop("sim/G91/stores/handleRequestToLoadStation", 0);
    }
}, 1, 0);

# ----------
# Functions for definine the load stations for types
# ----------

var stationSxExternalTypeLoad = func(typeLoad = 0) {
    
}

var stationSxInternalTypeLoad = func(typeLoad = 0) {
    if (typeLoad == 10) {
        print("Stores: stationSxInternalTypeLoad : ",10);
        setprop("sim/G91/stores/stationSxInternalTypeLoad", 10);
        setprop("/fdm/jsbsim/systems/stations/stationSxInternal/TypeLoad",10);
        setprop("/fdm/jsbsim/systems/stations/stationSxInternal/typeHook",1);
        setprop("/fdm/jsbsim/systems/stations/stationSxInternal/typeHardpoint",1);
        setprop("consumables/fuel/tank[4]/selected",1);
        setprop("consumables/fuel/tank[4]/level-norm", 1);
        setprop("sim/G91/stores/startStoreView", -1);
        setprop("/fdm/jsbsim/systems/stations/stationSxInternal/Count",1);
        setprop("/fdm/jsbsim/systems/stations/stationSxInternal/Weight",70);
        setprop("/fdm/jsbsim/systems/stations/stationSxInternal/Cd",0.2);
        setprop("/fdm/jsbsim/systems/stations/hardPointSxInternal/Count",1);
        print("Stores: stationSxExternalTypeLoad loadType = 10");
    } else if (typeLoad == 11) {
        print("Stores: stationSxInternalTypeLoad : ",11);
        setprop("sim/G91/stores/stationSxInternalTypeLoad", 11);
        setprop("/fdm/jsbsim/systems/stations/stationSxInternal/TypeLoad",11);
        setprop("/fdm/jsbsim/systems/stations/stationSxInternal/typeHook",2);
        setprop("/fdm/jsbsim/systems/stations/stationSxInternal/typeHardpoint",2);
        setprop("consumables/fuel/tank[4]/selected",0);
        setprop("consumables/fuel/tank[4]/level-norm", 0);
        setprop("sim/G91/stores/startStoreView", -1);
        setprop("/fdm/jsbsim/systems/stations/stationSxInternal/Count",1);
        setprop("/fdm/jsbsim/systems/stations/stationSxInternal/Weight",50);
        setprop("/fdm/jsbsim/systems/stations/stationSxInternal/Cd",0.15);
        setprop("/fdm/jsbsim/systems/stations/hardPointSxInternal/Count",1);
        print("Stores: stationSxExternalTypeLoad loadType = 11");
    }
}

var stationDxInternalTypeLoad = func(typeLoad = 0) {
    if (typeLoad == 10) {
        print("Stores: stationDxInternalTypeLoad : ",10);
        setprop("sim/G91/stores/stationDxInternalTypeLoad", 10);
        setprop("/fdm/jsbsim/systems/stations/stationDxInternal/TypeLoad",10);
        setprop("/fdm/jsbsim/systems/stations/stationDxInternal/typeHook",1);
        setprop("/fdm/jsbsim/systems/stations/stationDxInternal/typeHardpoint",1);
        setprop("consumables/fuel/tank[3]/selected",1);
        setprop("consumables/fuel/tank[3]/level-norm", 1);
        setprop("sim/G91/stores/startStoreView", -1);
        setprop("/fdm/jsbsim/systems/stations/stationDxInternal/Count",1);
        setprop("/fdm/jsbsim/systems/stations/stationDxInternal/Weight",70);
        setprop("/fdm/jsbsim/systems/stations/stationDxInternal/Cd",0.2);
        setprop("/fdm/jsbsim/systems/stations/hardPointDxInternal/Count",1);
        print("Stores: stationDxInternalTypeLoad loadType = 10");
    } else if (typeLoad == 11) {
        print("Stores: stationDxInternalTypeLoad : ",11);
        setprop("sim/G91/stores/stationDxInternalTypeLoad", 11);
        setprop("/fdm/jsbsim/systems/stations/stationDxInternal/TypeLoad",11);
        setprop("/fdm/jsbsim/systems/stations/stationDxInternal/typeHook",2);
        setprop("/fdm/jsbsim/systems/stations/stationDxInternal/typeHardpoint",2);
        setprop("consumables/fuel/tank[3]/selected",0);
        setprop("consumables/fuel/tank[3]/level-norm", 0);
        setprop("sim/G91/stores/startStoreView", -1);
        setprop("/fdm/jsbsim/systems/stations/stationDxInternal/Count",1);
        setprop("/fdm/jsbsim/systems/stations/stationDxInternal/Weight",50);
        setprop("/fdm/jsbsim/systems/stations/stationDxInternal/Cd",0.15);
        setprop("/fdm/jsbsim/systems/stations/hardPointDxInternal/Count",1);
        print("Stores: stationDxInternalTypeLoad loadType = 11");
    }
}

var stationDxExternalTypeLoad = func(typeLoad = 0) {
    
}

# ----------
# Functions for definine the unload stations for types
# ----------

var stationSxExternalTypeLoadDrop = func() {
    
}

var stationSxInternalTypeLoadDrop = func() {
    var typeLoad = props.globals.getNode("sim/G91/stores/stationSxInternalTypeLoad",1).getValue();
    if (typeLoad == 10) {
        print("Stores: stationSxInternalTypeLoadDrop : ",typeLoad);
        setprop("consumables/fuel/tank[4]/level-norm", 0);
        setprop("consumables/fuel/tank[4]/selected",0);
        setprop("sim/G91/stores/stationSxInternalTypeLoad", 0);
        setprop("sim/G91/stores/startStoreView", 0);
        setprop("sim/G91/stores/lastStoreBalObj","stationSxInternal_Tank260lit");
        setprop("/fdm/jsbsim/systems/stations/stationSxInternal/TypeLoad",0);
        setprop("/fdm/jsbsim/systems/stations/stationSxInternal/Count",0);
        setprop("/fdm/jsbsim/systems/stations/stationSxInternal/Weight",0);
        setprop("/fdm/jsbsim/systems/stations/stationSxInternal/Cd",0);
        setprop("/fdm/jsbsim/systems/stations/hardPointSxInternal/Count",0);
    } else if (typeLoad == 11) {
        print("Stores: stationSxInternalTypeLoadDrop : ",typeLoad);
        setprop("sim/G91/stores/stationSxInternalTypeLoad", 0);
        setprop("sim/G91/stores/startStoreView", 0);
        setprop("sim/G91/stores/lastStoreBalObj","stationSxInternal_Tank260lit");
        setprop("/fdm/jsbsim/systems/stations/stationSxInternal/TypeLoad",0);
        setprop("/fdm/jsbsim/systems/stations/stationSxInternal/Count",0);
        setprop("/fdm/jsbsim/systems/stations/stationSxInternal/Weight",0);
        setprop("/fdm/jsbsim/systems/stations/stationSxInternal/Cd",0);
        setprop("/fdm/jsbsim/systems/stations/hardPointSxInternal/Count",0);
    }
}

var stationDxInternalTypeLoadDrop = func() {
    var typeLoad = props.globals.getNode("sim/G91/stores/stationDxInternalTypeLoad",1).getValue();
    if (typeLoad == 10) {
        print("Stores: stationDxInternalTypeLoadDrop : ",typeLoad);
        setprop("consumables/fuel/tank[3]/level-norm", 0);
        setprop("consumables/fuel/tank[3]/selected",0);
        setprop("sim/G91/stores/stationDxInternalTypeLoad", 0);
        setprop("sim/G91/stores/startStoreView", 0);
        setprop("sim/G91/stores/lastStoreBalObj","stationDxInternal_Tank260lit");
        setprop("/fdm/jsbsim/systems/stations/stationDxInternal/TypeLoad",0);
        setprop("/fdm/jsbsim/systems/stations/stationDxInternal/Count",0);
        setprop("/fdm/jsbsim/systems/stations/stationDxInternal/Weight",0);
        setprop("/fdm/jsbsim/systems/stations/stationDxInternal/Cd",0);
        setprop("/fdm/jsbsim/systems/stations/hardPointDxInternal/Count",0);
    } else if (typeLoad == 11) {
        print("Stores: stationDxInternalTypeLoadDrop : ",typeLoad);
        setprop("sim/G91/stores/stationDxInternalTypeLoad", 0);
        setprop("sim/G91/stores/startStoreView", 0);
        setprop("sim/G91/stores/lastStoreBalObj","stationDxInternal_Tank260lit");
        setprop("/fdm/jsbsim/systems/stations/stationDxInternal/TypeLoad",0);
        setprop("/fdm/jsbsim/systems/stations/stationDxInternal/Count",0);
        setprop("/fdm/jsbsim/systems/stations/stationDxInternal/Weight",0);
        setprop("/fdm/jsbsim/systems/stations/stationDxInternal/Cd",0);
        setprop("/fdm/jsbsim/systems/stations/hardPointDxInternal/Count",0);
    }
    
}

var stationDxExternalTypeLoadDrop = func() {
    
}

# ----------
# Emergency remove all in external station by Handle_Store or the push_button
# ----------

var return_Handle_Stores = func() {

    var handleRequestToDrop = props.globals.getNode("sim/G91/stores/handleRequestToDrop",1).getValue();
    var emergency_release = props.globals.getNode("sim/G91/stores/sw-emergency-release",1).getValue();
    if (handleRequestToDrop > 0) {
        setprop("sim/G91/stores/handleRequestToDrop", 0);
        setprop("sim/G91/handle/handleRequestToDropPosition", 1);
        stationSxExternalTypeLoadDrop();
        stationSxInternalTypeLoadDrop();
        stationDxInternalTypeLoadDrop();
        stationDxExternalTypeLoadDrop();
        var handleRequestToDropPosition = props.globals.getNode("sim/G91/handle/handleRequestToDropPosition",1).getValue();
        if (handleRequestToDropPosition > 0) {
            handleRequestToDropPosition = handleRequestToDropPosition - 0.05;
            setprop("sim/G91/handle/handleRequestToDropPosition", handleRequestToDropPosition);
            settimer(return_Handle_Stores,0.05);
        } else if (handleRequestToDropPosition < 0.1) {
            handleRequestToDropPosition = 0;
            setprop("sim/G91/handle/handleRequestToDropPosition", handleRequestToDropPosition);
            setprop("sim/G91/handle/handle_stores_block_flag",0);
        }
    } else if (emergency_release > 0) {
        print("Stores: emergency_release");
        stationSxExternalTypeLoadDrop();
        stationSxInternalTypeLoadDrop();
        stationDxInternalTypeLoadDrop();
        stationDxExternalTypeLoadDrop();
    }
}

setlistener("sim/G91/stores/handleRequestToDrop", func {
    return_Handle_Stores();
}, 1, 0);

setlistener("sim/G91/stores/sw-emergency-release", func {
    return_Handle_Stores();
}, 1, 0);

# ----------
# Transform the phisical static store object in balistic object
# Fuel external tank from equipment fuel menu check
# If consumables/fuel/tank[x]/selected is nil, remove the tank
# ----------

var storesTank = maketimer(1, func() {

    var tankSx_Selected = props.globals.getNode("consumables/fuel/tank[4]/selected",1).getValue();
    if (tankSx_Selected == nil) {
        setprop("consumables/fuel/tank[4]/selected", 0);
        setprop("consumables/fuel/tank[4]/level-norm", 0);
        tankSx_Selected = 0;
    }
    var tankDx_Selected = props.globals.getNode("consumables/fuel/tank[3]/selected",1).getValue();
    if (tankDx_Selected == nil) {
        setprop("consumables/fuel/tank[3]/selected", 0);
        setprop("consumables/fuel/tank[3]/level-norm", 0);
        tankDx_Selected = 0;
    }
    
    var typeLoadSx = props.globals.getNode("sim/G91/stores/stationSxInternalTypeLoad",1).getValue();
    var typeLoadDx = props.globals.getNode("sim/G91/stores/stationDxInternalTypeLoad",1).getValue();
    
    if (tankSx_Selected == 0 and typeLoadSx == 10) {
        setprop("sim/G91/stores/stationSxInternalDropFromStation", 1);
        setprop("sim/G91/stores/handleRequestToLoadStation", -2);
    }
    if (tankSx_Selected > 0 and typeLoadSx != 10) {
        setprop("sim/G91/stores/handleRequestToLoadType", 10);
        setprop("sim/G91/stores/handleRequestToLoadStation", 2);
        setprop("sim/G91/stores/stationSxInternalDropFromStation", 0);
    }
    if (tankSx_Selected > 0 and typeLoadSx == 10) {
        var content = props.globals.getNode("/consumables/fuel/tank[4]/level-lbs",1).getValue();
        setprop("sim/G91/stores/stationSxInternalContent/level-lbs", content);
    }
    if (tankDx_Selected == 0 and typeLoadDx == 10) {
        setprop("sim/G91/stores/stationDxInternalDropFromStation", 1);
        setprop("sim/G91/stores/handleRequestToLoadStation", -3)
    }
    if (tankDx_Selected > 0 and typeLoadDx != 10) {
        setprop("sim/G91/stores/handleRequestToLoadType", 10);
        setprop("sim/G91/stores/handleRequestToLoadStation", 3);
        setprop("sim/G91/stores/stationDxInternalDropFromStation", 0);
    }
    if (tankDx_Selected > 0 and typeLoadDx == 10) {
        var content = props.globals.getNode("/consumables/fuel/tank[3]/level-lbs",1).getValue();
        setprop("sim/G91/stores/stationDxInternalContent/level-lbs", content);
    }

});
storesTank.start();

# ----------
# Put the camera on the last model added
# The /ai/models/model-added report the last model insert
# ----------

var transportToView = maketimer(0.0, func() {
    var startStoreView = props.globals.getNode("sim/G91/stores/startStoreView",1).getValue();
    if (startStoreView < 0) {
        var latitude_deg = props.globals.getNode("position/latitude-deg",1).getValue();
        var longitude_deg = props.globals.getNode("position/longitude-deg",1).getValue();
        var altitude_ft = props.globals.getNode("position/altitude-ft",1).getValue();
        var roll_deg = props.globals.getNode("orientation/roll-deg",1).getValue();
        var pitch_deg = props.globals.getNode("orientation/pitch-deg",1).getValue();
        var heading_deg = props.globals.getNode("orientation/heading-deg",1).getValue();
        setprop("sim/G91/views/view_submodel/latitude-deg", latitude_deg);
        setprop("sim/G91/views/view_submodel/longitude-deg", longitude_deg);
        setprop("sim/G91/views/view_submodel/altitude-ft", altitude_ft);
        setprop("sim/G91/views/view_submodel/roll-deg", roll_deg);
        setprop("sim/G91/views/view_submodel/pitch-deg", pitch_deg);
        setprop("sim/G91/views/view_submodel/heading-deg", heading_deg);
    } else {
        var latitude_deg = props.globals.getNode("ai/models/ballistic/position/latitude-deg",1).getValue();
        var longitude_deg = props.globals.getNode("ai/models/ballistic/position/longitude-deg",1).getValue();
        var altitude_ft = props.globals.getNode("ai/models/ballistic/position/altitude-ft",1).getValue();
        var roll_deg = props.globals.getNode("ai/models/ballistic/orientation/roll-deg",1).getValue();
        var pitch_deg = props.globals.getNode("ai/models/ballistic/orientation/pitch-deg",1).getValue();
        var heading_deg = props.globals.getNode("ai/models/ballistic/orientation/hdg-deg",1).getValue();
        if (typeof(latitude_deg) == "scalar") {
            setprop("sim/G91/views/view_submodel/latitude-deg", latitude_deg);
            setprop("sim/G91/views/view_submodel/longitude-deg", longitude_deg);
            setprop("sim/G91/views/view_submodel/altitude-ft", altitude_ft);
            setprop("sim/G91/views/view_submodel/roll-deg", roll_deg);
            setprop("sim/G91/views/view_submodel/pitch-deg", pitch_deg);
            setprop("sim/G91/views/view_submodel/heading-deg", heading_deg);
        }
    }
});
transportToView.start();

setlistener("ai/models/model-added", func {
    var lastStoreBalObj = getprop("sim/G91/stores/lastStoreBalObj");
    var a = props.globals.getNode("/ai/models/model-added").getValue();
    if (a != nil) {
        var sub = props.globals.getNode(a);
        if (sub != nil) {
            var subName = sub.getValue("name");
            if (subName != nil) {
                print("Stores: setlistener ai/models/model-added:", subName);
                if (string.imatch(lastStoreBalObj,subName)) {
                    setprop("sim/G91/stores/lastStoreBalObjDataPath", props.globals.getNode("/ai/models/model-added").getValue());
                    print("Stores: MATCH");
                }
            }
        }
    }
}, 1, 0);

setlistener("ai/models/model-impact", func {
    print("Stores: setlistener ai/models/model-impact");
    var lastStoreBalObj = getprop("sim/G91/stores/lastStoreBalObj");
    var sub = props.globals.getNode(props.globals.getNode("/ai/models/model-impact").getValue());
    if (sub != nil) {
        var subName = sub.getValue("name");
        if (subName != nil) {
            print("Stores: setlistener ai/models/model-impact:", subName, " : ", lastStoreBalObj);
            if (string.imatch(lastStoreBalObj,subName)) {
                setprop("sim/G91/stores/lastStoreBalObjDataPath", "");
                setprop("sim/G91/stores/startStoreView", -1);
            }
        }
    }
}, 1, 0);

setlistener("ai/models/model-removed", func {
# ...
}, 1, 0);
