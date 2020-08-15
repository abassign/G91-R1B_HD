# From: http://wiki.flightgear.org/Howto:Dynamic_Liveries_via_Canvas

setprop("sim/G91/liveries/active/name_short","");
setprop("sim/G91/liveries/active/name_long","");
setprop("sim/G91/liveries/active/livery_001","");
setprop("sim/G91/liveries/active/livery_002","");
setprop("sim/G91/liveries/active/dirty_001","");
setprop("sim/G91/liveries/active/dirty_002","");
setprop("sim/G91/liveries/active/anti_reflective","");
setprop("sim/G91/liveries/active/PANR1",0);
setprop("sim/G91/liveries/active/diffuse",0.0);
setprop("sim/G91/liveries/active/specular",0.0);
setprop("sim/G91/liveries/active/dirty_set",0);
setprop("sim/G91/liveries/active/normalmap_enabled",0);
setprop("sim/G91/liveries/active/version",0);

var inExecution = 0;
var isMultiPlayer = 0; # The value, is different to 0, set the reselution
var target_module_id = nil;
var target_module_id_associated = nil;

var resolutionSet = -1;
var resolutionSetPrec = -1;
var resolutionSetChanged = 0;
var canvasSetChanged = 0;

var id_prec = 0;
var dirty_prec = -1;
var resolution = 0;
var ca_size = 0;
var cw_size = 0;

var layers_001 = {};
var layers_001_create = 0;
var ca = nil;
var ca_root = nil;
var layers_002 = {};
var layers_002_create = 0;
var cw = nil;
var cw_root = nil;

var anti_reflective_area = {};
var ar = nil;
var ar_root = nil;

var dirty_set = 0;
var normalmap_enabled = 0;

var livery_001 = "";
var livery_002 = "";
var dirty_001 = "";
var dirty_002 = "";
var anti_reflective = "";


var objectsNodes_ca = [
    # Fuselage
    "A__G91_fuselage_int.weapon.door.001",
    "m00_door_01.1",
    "m00_door_02",
    "m00_door_dx01",
    "m00_door_dx03",
    "m00_door_sx01",
    "m00_door_sx03",
    "m00_platelight",
    "m00_door_sx03.001",
    "m00_door_dx03.001",
    "F__door_02",
    "F__door_03",
    "F__door_02.001",
    "F__door_03",
    "F__door_03.002",
    "F__door_em_canopy01",
    "F__door_em_canopy01.002",
    "F_door_em_canopyDX.000",
    "F_door_em_canopyDX.001",
    "F_door_em_canopyDX.002",
    "F_door_em_canopyDX.004",
    "F_door_em_canopyDX.004a",
    "F_door_em_canopyDX.004a.001",
    "F_door_em_canopyDX.005",
    "F_door_em_canopySX.000",
    "F_door_em_canopySX.001",
    "F_door_em_canopySX.002",
    "F_door_em_canopySX.004",
    "F_door_em_canopySX.004a",
    "F_door_em_canopySX.005",
    "F_handle_armydoorDX",
    "F_handle_armydoorSX",
    "B00_sx_door_01.001",
    "B00_dx_door_01.000",
    "B00_Asse_dx_door_bis",
    "B00_sx_door_bis.002",
    "A__G91_fuselage_int.weapon.door.007",
    "A__G91_fuselage_int.weapon.door.008",
    "m00_door_01.2",
    "m00_door_dx03.002",
    "tank_cap1",
    "tank_cap",
    # tail
    "A__G91_fuselage_coda.002",
    "A__G91_fuselage_coda.005",
    "A__G91_fuselage_coda.006",
    "A__G91_door_sx_coda.000",
    "A__G91_door_dx_coda.001",
    "A__G91_fuselage_coda.007",
    "A__G91_fuselage_coda.009",
    "A__G91_fuselage_coda.010",
    "exit_smoke_001_cover",
    "exit_smoke_001",
    "exit_smoke",
    "fin_small.001",
    "fin_small.002",
    "fin_small.003",
    "fin_small.004",
    "fin_small.005",
    "fin_small.006",
    "fin_small.007",
    "fin_small.008",
    "fin_small.009",
    "fin_small.010",
    "D_timone_coda",
    "D_timone_coda.001",
    "D_timone_coda.002",
    "D_timone_coda.003",
    "D_aletta_correttrice",
    "M_tail_component_01",
    "vent_tail",
    # Canopy
    "A__G91_fuselage_canopy",
    "F_canopY_ant",
    "F_CANPOPY.005",
    # Fuselage A0
    "A__G91_fuselage_muso_1.001",
    "A__G91_fuselage_muso_1.000",
    "A__G91_fuselage_muso_1.008",
    "A__G91_fuselage_muso_1.009",
    "A_antenna_cover",
    "panR1b__G91_fuselage_muso_1.000",
    "panR1b__G91_fuselage_muso_1.024",
    # Fuselage B0
    "A__G91_fuselage_weapon_door_dx.003",
    "A__G91_fuselage_weapon_door_sx.003",
    "A__G91r3_fuselage_weapon_door_sx.",
    "A__G91r3_fuselage_weapon_door_dx",

    # Airbrake
    "C00_dx_airbrake_door.002",
    "C00_sx_airbrake_door.004",

    # Landing gear frontal
    "PlanLight.front.001",
    "gear_door_sx.000",
    "gear_door_dx.001"
];

var objectsNodes_cw = [
    # Wing
    "A_wing_dx.000",
    "A_wing_sx.000",
    "A_wing_dx.001",
    "A_wing_sx.001",
    "A_wing_dx.002",
    "A_wing_sx.002",
    "A_wing_dx.004",
    "A_wing_sx.004",
    "A_wing_dx.005",
    "A_wing_sx.005",
    "A_wing_dx.006",
    "A00_wing_dx_part.001",
    "A00_wing_dx_part.002",
    "A00_wing_dx_part.003",
    "A_flap_dx",
    "A_flap_sx",
    "A_alettone_sx.001",
    "A_alettone_dx.002",
    "A_alettone_sx",
    "A_alettone_dx",
    "A_wing_border_sx",
    "A_wing_border_dx.001",
    "A_door_wing_dx.001",
    "A_door_wing_dx.004",
    "A_door_wing_dx.005",
    "A_door_wing_sx.000",
    "A_door_wing_sx.002",
    "A_door_wing_sx.003",
    "B00_dx_door_02.002",
    "B00_dx_door_02",
    "A00_pitot_dx",
    "A00_pitot_dx.001",
    # Tail
    "D_wing_sx_.001",
    "D_wing_sx.000",
    "D_wing_dx_.000",
    "D_wing_dx.007",
    "D_equilibratore_dx",
    "D_equilibratore_sx.002",
    # Hard points
    "hp_dx_int_01_external",
    "hp_dx_int_PAN_external",
    "hp_sx_int_01_external",
    "hp_sx_int_PAN_external",
    # Stores
    "tank_260lb_sub_01",
    "tank_260lb_sup_01",
    "tank_260lb_tail_01",
    "PAN_tank_sx.004",
    "PAN_tank_sx_003",
    # Tank 900lb
    "tank_cover_top",
    "tank_cover_downa",
    "orizontal-pin (Meshed)",
    "vertical-pin-dx (Meshed)",
    "vertical-pin-sx (Meshed)",
    # Fuselage extra
    "A__G91r3_fuselage_weapon.door"
];

var objectsNodes_ar = [
    # Anti-reflective
    "panR1b__G91_fuselage_muso_1.000",
    "A__G91_fuselage_muso_1.008",
    "A__G91_fuselage_muso_1.009",
    "A__G91_fuselage_int.weapon.door.004",
    "A__G91_fuselage_canopy.004"
];


var set_MP_ModuleId = func(aModule_id) {
    
    if (aModule_id != nil) {
        target_module_id = aModule_id;
        print("set_livery.nas setLivery, load airplane as multiplayer mode, target_module_id: ",target_module_id);
    } else {
        print("set_livery.nas setLivery, load airplane single player mode");
    }
    
}


var setCanvas = func() {
    
    # see: http://wiki.flightgear.org/Howto:Creating_fullscreen_Canvas_applications
    # see: http://wiki.flightgear.org/Canvas_Nasal_API

    canvasSetChanged = canvasSetChanged + 1;
    if (canvasSetChanged > 1) {
        print("set_livery.nas setCanvas, the canvas is not changed, nothing to do");
        return;
        # ca.del();
        # cw.del();
        # ar.del();
        # target_module_id_associated = nil;
    }

    if (target_module_id_associated == nil) {
        
        target_module_id_associated = target_module_id;
        print("set_livery.nas setCanvas: ca_size = ",ca_size," cw_size = ",cw_size, "module id: ",target_module_id_associated);
        
        ca = canvas.new({"name": "Fuselage",
                    "size": [ca_size,ca_size],
                    "view": [ca_size,ca_size],
                    "mipmapping": 1});
    
        cw = canvas.new({"name": "Wing",
                        "size": [cw_size,cw_size],
                        "view": [cw_size,cw_size],
                        "mipmapping": 1});
        
        ar = canvas.new({"name": "Anti-reflective-area",
                        "size": [128,128],
                        "view": [128,128],
                        "mipmapping": 1});
        
        if (target_module_id == nil) {
            print("set_livery.nas setCanvas, single player");
            foreach(var node; objectsNodes_ca) { ca.addPlacement({"node": node}) };
            foreach(var node; objectsNodes_cw) { cw.addPlacement({"node": node}) };
            foreach(var node; objectsNodes_cw) { ar.addPlacement({"node": node}) };
        } else {
            print("set_livery.nas setCanvas, multi player with module-id: ",target_module_id);
            foreach(var node; objectsNodes_ca) { ca.addPlacement({"module-id": target_module_id, type: "scenery-object","node": node}) };
            foreach(var node; objectsNodes_cw) { cw.addPlacement({"module-id": target_module_id, type: "scenery-object","node": node}) };
            foreach(var node; objectsNodes_cw) { ar.addPlacement({"module-id": target_module_id, type: "scenery-object","node": node}) };
        }
        
        ca_root = ca.createGroup();
        cw_root = cw.createGroup();
        ar_root = ar.createGroup();
        
    } else {
        
        if (target_module_id_associated == nil) {
            print("set_livery.nas setCanvas, the canvas is not to module-id");
        } else {
            print("set_livery.nas setCanvas, the canvas is associated, module-id: ", target_module_id_associated);
        }
        
    }

};


var setLivery = func() {
    
    inExecution = 1;

    if (resolution == 0) {
        print("set_livery.nas setLivery, error: resolution == 0, exit");
        inExecution = 0;
        return;
    }

    if (size(dirty_001) == 0) {
        setprop("sim/G91/liveries/active/dirtyMsg","No dirty file");
        print("set_livery.nas setLivery, No dirty file (",dirty_001,")");
    } else {
        if (dirty_set == 0) {
            setprop("sim/G91/liveries/active/dirtyMsg","Dirty inactive");
            print("set_livery.nas setLivery, Dirty inactive");
        } else {
            setprop("sim/G91/liveries/active/dirtyMsg","Dirty active");
            print("set_livery.nas setLivery, Dirty active");
        }
    }

    if (normalmap_enabled == 0) {
        setprop("sim/G91/liveries/active/normalmap_enabled_Msg","No normal map");
        print("set_livery.nas setLivery, normalmap_enabled inactive");
    } else {
        setprop("sim/G91/liveries/active/normalmap_enabled_Msg","Yes Normal map");
        print("set_livery.nas setLivery, normalmap_enabled active");
    }

    if (ca_root != nil) {
        var id = 0;
        #foreach(var image; [livery_001, dirty_001]) {
            var image = livery_001;
            print("set_livery.nas setLivery, ca_root show image: ",image," (",size(image),")");
            # Insert the layer
            if (size(image) > 0 and resolutionSet > 0) {
                ## layers_001[id] = ca_root.createChild("image")
                if (canvasSetChanged <= 20) {
                    ca_root.createChild("image")
                        .setFile(image)
                        .setSize(ca_size,ca_size);
                } else {
                    ca_root.setFile(image);
                }
                id = id + 1;
                #if (image == dirty_001) {
                #    if (dirty_set == 1) {
                #        print("set_livery.nas setLivery, dirty show: ",dirty_001);
                #        layers_001[image].show();
                #    } else {
                #        print("set_livery.nas setLivery, dirty hide: ",dirty_001);
                #        layers_001[image].hide();
                #    }
                #}
            }
        #}
    }

    if (cw_root != nil) {
        var id = 0;
        #foreach(var image; [livery_002, dirty_002]) {
            var image = livery_002;
            print("set_livery.nas setLivery, cw_root show image: ",image," (",size(image),")");
            # Insert the layer
            if (size(image) > 0 and resolutionSet > 0) {
                ## layers_002[id] = cw_root.createChild("image")
                if (canvasSetChanged <= 20) {
                    cw_root.createChild("image")
                        .setFile(image)
                        .setSize(cw_size,cw_size);
                } else {
                    cw_root.setFile(image);
                }
                id = id + 1;
                #if (image == dirty_002) {
                #    if (dirty_set == 1) {
                #        print("set_livery.nas setLivery, dirty show: ",dirty_002);
                #        layers_002[image].show();
                #    } else {
                #        print("set_livery.nas setLivery, dirty hide: ",dirty_002);
                #        layers_002[image].hide();
                #    }
                #}
            }
        #}
    }

    if (ar_root != nil) {
        foreach(var image; [anti_reflective]) {
            print("set_livery.nas setLivery, anti-reflective: ",image," (",size(image),")");
            # Insert the layer
            var image = anti_reflective;
            if (size(image) > 0 and resolutionSet > 0) {
                if (canvasSetChanged <= 20) {
                    ## anti_reflective_area[image] = ar_root.createChild("image")
                    #ar_root.createChild("image")
                    #    .setFile(image)
                    #    .setSize(128,128);
                } else {
                    #ar_root.setFile(image);
                }
            }
        }
    }

    inExecution = 0;
};


var getActiveData = func() {

    var name_short = "";
    var name_long = "";
    var PANR1 = 0;
    var diffuse = 0.0;
    var specular = 0.0;
    var version = 0;

    isMultiPlayer = getprop("sim/G91/liveries/active/isMultiPlayer");
    if (isMultiPlayer == nil) {
        print("set_livery.nas getActiveData isMultiPlayer set to 0");
        setprop("sim/G91/liveries/active/isMultiPlayer",0);
        isMultiPlayer = 0;
    }

    if (isMultiPlayer > 0) {
        resolutionSet = 2;
    } else {
        #// Resolution change only une time
        if (resolutionSet < 0) resolutionSet = getprop("sim/G91/liveries/active/next-resolution");
    }

    if (resolutionSet == 1) {
        resolution = 512; }
    else if (resolutionSet == 2) {
        resolution = 1024; }
    else if (resolutionSet == 3) {
        resolution = 2048; }
    else if (resolutionSet == 4) {
        resolution = 4096; }
    else {
        print("set_livery.nas changeResolution resolutionSet error but change in 1 (",resolutionSet,")");
        resolutionSet = 2;
        resolution = 1024;
        setprop("sim/G91/liveries/active/next-resolution",resolutionSet);
    }

    print("set_livery.nas getActiveData resolution id: ",resolutionSet," pixel: ",resolution);
    setprop("sim/G91/liveries/active/setResolution",resolutionSet);
    setprop("sim/G91/liveries/active/resolution",resolution);

    ca_size = resolution;
    cw_size = resolution;

    resolutionSetPrec = resolutionSet;

    if (isMultiPlayer == 0) {
        
        print("set_livery.nas getActiveData, read data from G91_Params.xml");

        var idSelect = getprop("sim/G91/liveries/active/id");
        ### idSelect = getprop("sim/multiplay/generic/int[0]");
        if (idSelect == nil) {
            print("set_livery.nas getActiveData, error read ID, set ID to 1");
            setprop("sim/G91/liveries/active/id",1);
            idSelect = 1;
        } else {
            print("set_livery.nas getActiveData, idSelect: ",idSelect);
        }

        resolutionSet = getprop("sim/G91/liveries/active/setResolution");
        if (resolutionSet == nil) {
            print("set_livery.nas getActiveData, error read resolutionSet");
            resolutionSet = 0;
        }

        if (resolutionSetPrec > 0 and resolutionSetPrec != resolutionSet) {
            print("set_livery.nas getActiveData, resolutionSet: change resolution is only for one time");
            resolutionSet = resolutionSetPrec;
            setprop("sim/G91/liveries/active/setResolution",resolutionSet);
            return;
        }

        if (idSelect == 0 or resolutionSet == 0) {
            print("set_livery.nas getActiveData, error file liveries/active not found");
            return;
        } else {
            print("set_livery.nas getActiveData, set resolution: ", resolutionSet);
        }

        var liverys = props.globals.getNode("sim/G91/liveries").getChildren("livery");

        var id = -1;
        forindex(i; liverys) {
            if (liverys[i].getNode("id").getValue() == idSelect) {
                print("set_livery.nas getActiveData, id select: ", idSelect, "(",i,")");
                id = i;
                break;
            }
        }

        if (id == -1) {
            id = 0;
            print("set_livery.nas getActiveData error: id not found, set default id = 0");
        } else {
            print("set_livery.nas getActiveData id: ",id);
        }

        livery_001 = liverys[id].getNode("livery_001").getValue();
        livery_002 = liverys[id].getNode("livery_002").getValue();
        dirty_001 = liverys[id].getNode("dirty_001").getValue();
        dirty_002 = liverys[id].getNode("dirty_002").getValue();
        anti_reflective = liverys[id].getNode("anti_reflective").getValue();
        name_short = liverys[id].getNode("name_short").getValue();
        name_long = liverys[id].getNode("name_long").getValue();
        PANR1 = liverys[id].getNode("PANR1").getValue();
        diffuse = liverys[id].getNode("diffuse").getValue();
        specular = liverys[id].getNode("specular").getValue();
        dirty_set = liverys[id].getNode("dirty_set").getValue();
        normalmap_enabled = liverys[id].getNode("normalmap_enabled").getValue();
        version = liverys[id].getNode("version").getValue();

    } else {

        # Is in multiplayer mode
        
        print("set_livery.nas getActiveData, read data from multiplayer");

        isMultiPlayer_StartPhase = 1;

        # Read data from multiplayer
        
        print("set_livery.nas getActiveData in Multiplayer mode, cmdarg().getPath(): ",cmdarg().getPath());

        idSelect = getprop("/ai/models/multiplayer/sim/G91/liveries/active/id");
        name_short = "Multiplayer";
        name_long = "Multiplayer";
        livery_001 = getprop("/ai/models/multiplayer/sim/G91/liveries/active/livery_001");
        livery_002 = getprop("/ai/models/multiplayer/sim/G91/liveries/active/livery_002");
        dirty_001 = getprop("/ai/models/multiplayer/sim/G91/liveries/active/dirty_001");
        dirty_002 = getprop("/ai/models/multiplayer/sim/G91/liveries/active/dirty_002");
        anti_reflective = getprop("/ai/models/multiplayer/sim/G91/liveries/active/anti_reflective");
        PANR1 = getprop("/ai/models/multiplayer/sim/G91/liveries/active/PANR1");
        diffuse = getprop("/ai/models/multiplayer/sim/G91/liveries/active/diffuse");
        specular = getprop("/ai/models/multiplayer/sim/G91/liveries/active/specular");
        dirty_set = getprop("/ai/models/multiplayer/sim/G91/liveries/active/dirty_set");
        normalmap_enabled = getprop("/ai/models/multiplayer/sim/G91/liveries/active/normalmap_enabled");
        version = getprop("/ai/models/multiplayer/sim/G91/liveries/active/version");

    }

    setprop("sim/G91/liveries/active/id",idSelect);
    setprop("sim/G91/liveries/active/name_short",name_short);
    setprop("sim/G91/liveries/active/name_long",name_long);
    setprop("sim/G91/liveries/active/livery_001",livery_001);
    setprop("sim/G91/liveries/active/livery_002",livery_002);
    setprop("sim/G91/liveries/active/dirty_001",dirty_001);
    setprop("sim/G91/liveries/active/dirty_002",dirty_002);
    setprop("sim/G91/liveries/active/anti_reflective",anti_reflective);
    setprop("sim/G91/liveries/active/PANR1",PANR1);
    setprop("sim/G91/liveries/active/diffuse",diffuse);
    setprop("sim/G91/liveries/active/specular",specular);
    setprop("sim/G91/liveries/active/dirty_set",dirty_set);
    setprop("sim/G91/liveries/active/normalmap_enabled",normalmap_enabled);
    setprop("sim/G91/liveries/active/version",version);

    print("set_livery.nas getActiveData setLivery  id: ",idSelect);
    print("set_livery.nas getActiveData setLivery  name_short: ",name_short);
    print("set_livery.nas getActiveData setLivery  name_long: ",name_long);
    print("set_livery.nas getActiveData setLivery  livery_001: ",livery_001);
    print("set_livery.nas getActiveData setLivery  livery_002: ",livery_002);
    print("set_livery.nas getActiveData setLivery  dirty_001: ",dirty_001);
    print("set_livery.nas getActiveData setLivery  dirty_002: ",dirty_002);
    print("set_livery.nas getActiveData setLivery  PANR1: ",PANR1);
    print("set_livery.nas getActiveData setLivery  diffuse: ",diffuse);
    print("set_livery.nas getActiveData setLivery  specular: ",specular);
    print("set_livery.nas getActiveData setLivery  dirty_set: ",dirty_set);
    print("set_livery.nas getActiveData setLivery  normalmap_enabled: ",normalmap_enabled);
    print("set_livery.nas getActiveData setLivery  version: ",version);

    id_prec = idSelect;
    dirty_prec = dirty_set;

    setCanvas();
    setLivery(target_module_id);

}


setlistener("sim/G91/liveries/active/isMultiPlayer", func {

    isMultiPlayer = getprop("sim/G91/liveries/active/isMultiPlayer");
    if (isMultiPlayer == nil) isMultiPlayer = 0;
    print("set_livery.nas setlistener isMultiPlayer: ",isMultiPlayer);

}, 1, 1);


setlistener("sim/G91/liveries/active/id", func {
    if (isMultiPlayer == 0) {
        var id = getprop("sim/G91/liveries/active/id");
        if (id == 0) {
            print("set_livery.nas setlistener error ID: ",id," MP: 0 the ID is forced to 1");
            setprop("sim/G91/liveries/active/id",1);
            id = 1;
        }
        print("set_livery.nas setlistener ID: ",id," MP: ",isMultiPlayer);
        if (id != nil and id != 0 and id_prec != id and isMultiPlayer == 0) {
            if(inExecution == 0) {
                getActiveData();
            }
        }
    }
}, 1, 1);


setlistener("sim/G91/liveries/active/dirty_set", func {

    if (inExecution == 0) {
        dirty_set = props.globals.getNode("sim/G91/liveries/active/dirty_set",1).getValue();
        print("set_livery.nas setlistener dirty_set: ",dirty_set);
        setLivery(target_module_id);
    }

}, 1, 1);


setlistener("sim/G91/liveries/active/normalmap_enabled", func {

    if(inExecution == 0 and isMultiPlayer == 0) {
        normalmap_enabled = props.globals.getNode("sim/G91/liveries/active/normalmap_enabled",1).getValue();
        print("set_livery.nas setlistener normalmap_enabled: ",normalmap_enabled);
        setLivery(target_module_id);
    }

}, 1, 1);


var livery_multiplayer = maketimer(1, func() {
    if (isMultiPlayer > 0) {
        var id = getprop("/ai/models/multiplayer/sim/G91/liveries/active/id");
        print("set_livery.nas pilot_imp_timerLog id: ",id," idPrec: ",id_prec);
        if (id != id_prec) {
            getActiveData();
        }
        dirty_set = getprop("/ai/models/multiplayer/sim/G91/liveries/active/dirty_set");
        if (dirty_set != dirty_prec) {
            setLivery();
        }
    }
});
livery_multiplayer.start();
