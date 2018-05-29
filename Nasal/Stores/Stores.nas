var prop = props.globals.initNode("sim/G91/stores/handleRequestToLoadStation", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/handleRequestToLoadType", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/handleRequestToDrop", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/handle/handleRequestToDropPosition", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/startStoreView", -1, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/lastStoreBalObj", "", "STRING");
var prop = props.globals.initNode("sim/G91/stores/lastStoreBalObjDataPath", "", "STRING");

# stationDxExternalTypeLoad define the load stationDxExternalTypeLoad
# 0 - nothing
# 10 - Thank type 450 lb (260 lit)
# 20 - Single MK82
var prop = props.globals.initNode("sim/G91/stores/stationSxExternalTypeLoad", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/stationSxInternalTypeLoad", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/stationDxInternalTypeLoad", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/stationDxExternalTypeLoad", 0, "DOUBLE");

var prop = props.globals.initNode("sim/G91/stores/stationSxExternalCount", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/stationSxInternalCount", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/stationDxInternalCount", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/stationDxExternalCount", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/stationSxExternalDropFromStation", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/stationSxInternalDropFromStation", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/stationDxInternalDropFromStation", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/stationDxExternalDropFromStation", 0, "DOUBLE");

var prop = props.globals.initNode("sim/G91/stores/stationSxExternalContent/level-lbs", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/stationSxInternalContent/level-lbs", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/stationDxInternalContent/level-lbs", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/stores/stationDxExternalContent/level-lbs", 0, "DOUBLE");

setlistener("sim/G91/stores/handleRequestToLoadStation", func {
    var handleRequestToLoadStation = props.globals.getNode("sim/G91/stores/handleRequestToLoadStation",1).getValue();
    var isLoadStation = 0;
    var isUnLoadStation = 0;
    var loadType = 0;
    if (handleRequestToLoadStation > 0)  {
        # Load station
        isLoadStation = handleRequestToLoadStation;
        loadType = props.globals.getNode("sim/G91/stores/handleRequestToLoadType",1).getValue();
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
        # unload station
        isUnLoadStation = -handleRequestToLoadStation;
        loadType = props.globals.getNode("sim/G91/stores/handleRequestToLoadType",1).getValue();
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
    if (handleRequestToLoadStation != 0) {
        setprop("sim/G91/stores/handleRequestToLoadStation", 0);
    }
}, 1, 0);

var stationSxExternalTypeLoad = func(typeLoad = 0) {
    
}

var stationSxInternalTypeLoad = func(typeLoad = 0) {
    if (typeLoad = 10) {
        setprop("sim/G91/stores/stationSxInternalTypeLoad", typeLoad);
        setprop("consumables/fuel/tank[4]/selected",1);
        setprop("consumables/fuel/tank[4]/level-norm", 1);
        setprop("sim/G91/stores/startStoreView", -1);
    }
}

var stationDxInternalTypeLoad = func(typeLoad = 0) {
    if (typeLoad = 10) {
        setprop("sim/G91/stores/stationDxInternalTypeLoad", typeLoad);
        setprop("consumables/fuel/tank[3]/selected",1);
        setprop("consumables/fuel/tank[3]/level-norm", 1);
        setprop("sim/G91/stores/startStoreView", -1);
    }
}

var stationDxExternalTypeLoad = func(typeLoad = 0) {
    
}

var stationSxExternalTypeLoadDrop = func() {
    
}

var stationSxInternalTypeLoadDrop = func() {
    var typeLoad = props.globals.getNode("sim/G91/stores/stationSxInternalTypeLoad",1).getValue();
    if (typeLoad = 10) {
        setprop("sim/G91/stores/stationSxInternalTypeLoad", 0);
        setprop("consumables/fuel/tank[4]/level-norm", 0);
        setprop("consumables/fuel/tank[4]/selected",0);
        setprop("sim/G91/stores/startStoreView", 0);
        setprop("sim/G91/stores/lastStoreBalObj","stationSxInternal_Tank260lit");
    }
}

var stationDxInternalTypeLoadDrop = func() {
    var typeLoad = props.globals.getNode("sim/G91/stores/stationDxInternalTypeLoad",1).getValue();
    if (typeLoad = 10) {
        setprop("sim/G91/stores/stationDxInternalTypeLoad", 0);
        setprop("consumables/fuel/tank[3]/level-norm", 0);
        setprop("consumables/fuel/tank[3]/selected",0);
        setprop("sim/G91/stores/startStoreView", 0);
        setprop("sim/G91/stores/lastStoreBalObj","stationDxInternal_Tank260lit");
    }
    
}

var stationDxExternalTypeLoadDrop = func() {
    
}

# Auxiliary funtions

# Remove all in external station

var return_Handle_Stores = func() {

    var handleRequestToDrop = props.globals.getNode("sim/G91/stores/handleRequestToDrop",1).getValue();
    if (handleRequestToDrop > 0) {
        setprop("sim/G91/stores/handleRequestToDrop", 0);
        setprop("sim/G91/handle/handleRequestToDropPosition", 1);
        stationSxExternalTypeLoadDrop();
        stationSxInternalTypeLoadDrop();
        stationDxInternalTypeLoadDrop();
        stationDxExternalTypeLoadDrop();
    }
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
}

setlistener("sim/G91/stores/handleRequestToDrop", func {
    return_Handle_Stores();
}, 1, 0);

# Fuel external tank from equipment fuel menu check
# If consumables/fuel/tank[x]/selected is nil, remove the tank

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

# Put the camera on the last model added
# The /ai/models/model-added report the last model insert

var transportToView = maketimer(0.01, func() {
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
    print(a);
    var sub = props.globals.getNode(a);
    var subName = sub.getChild("name").getValue();
    print(subName);
    if (string.imatch(lastStoreBalObj,subName)) {
        setprop("sim/G91/stores/lastStoreBalObjDataPath", props.globals.getNode("/ai/models/model-added").getValue());
    }
}, 1, 0);

setlistener("ai/models/model-impact", func {
    var lastStoreBalObj = getprop("sim/G91/stores/lastStoreBalObj");
    var sub = props.globals.getNode(props.globals.getNode("/ai/models/model-impact").getValue());
    var subName = sub.getChild("name").getValue();
    if (string.imatch(lastStoreBalObj,subName)) {
#        setprop("sim/G91/stores/lastStoreBalObjDataPath", "");
    }
}, 1, 0);

setlistener("ai/models/model-removed", func {
# ...
}, 1, 0);
