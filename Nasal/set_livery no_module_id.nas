# From: http://wiki.flightgear.org/Howto:Dynamic_Liveries_via_Canvas

setprop("sim/G91/liveries/active/name_short","");
setprop("sim/G91/liveries/active/name_long","");
setprop("sim/G91/liveries/active/livery_001","");
setprop("sim/G91/liveries/active/livery_002","");
setprop("sim/G91/liveries/active/dirty_001","");
setprop("sim/G91/liveries/active/dirty_002","");
setprop("sim/G91/liveries/active/anti_reflective","");
setprop("sim/G91/liveries/active/luminosity",0.0);
setprop("sim/G91/liveries/active/reflective",0.0);
setprop("sim/G91/liveries/active/PANR1",0);
setprop("sim/G91/liveries/active/diffuse",0.0);
setprop("sim/G91/liveries/active/specular",0.0);
setprop("sim/G91/liveries/active/dirty",0.0);
setprop("sim/G91/liveries/active/normalmap_enabled",0);
setprop("sim/G91/liveries/active/version",0);
setprop("sim/G91/liveries/active/ID","");

var inExecution = 0;
var isMultiPlayer = 0; # The value, is different to 0, set the reselution

var resolutionSet = 0;
var resolutionSetPrec = -1;
var resolutionSetChanged = 0;
var canvasSetChanged = -1;

var id_prec = 0;
var resolution = 0;
var ca_size = 0;
var cw_size = 0;

var layers_001 = {};
var ca_root = nil;
var layers_002 = {};
var cw_root = nil;

var anti_reflective_area = {};
var ar_root = nil;

var dirtySet = 0;
var normalMapEnable = 0;

var livery_001 = "";
var livery_002 = "";
var dirty_001 = "";
var dirty_002 = "";
var anti_reflective = "";


var setCanvas = func() {

    if (canvasSetChanged == 0) {
        print("set_livery.nas setCanvas, the canvas is not changed, nothing to do");
        return;
    }

    print("set_livery.nas setCanvas: ca_size = ",ca_size," cw_size = ",cw_size);

    ca = canvas.new({"name": "Fuselage",
                        "size": [ca_size,ca_size],
                        "view": [ca_size,ca_size],
                        "mipmapping": 1});

    # Fuselage
    ca.addPlacement({"node": "A__G91_fuselage_int.weapon.door.001"});
    ca.addPlacement({"node": "m00_door_01.1"});
    ca.addPlacement({"node": "m00_door_02"});
    ca.addPlacement({"node": "m00_door_dx01"});
    ca.addPlacement({"node": "m00_door_dx03"});
    ca.addPlacement({"node": "m00_door_sx01"});
    ca.addPlacement({"node": "m00_door_sx03"});
    ca.addPlacement({"node": "m00_platelight"});
    ca.addPlacement({"node": "m00_door_sx03.001"});
    ca.addPlacement({"node": "m00_door_dx03.001"});
    ca.addPlacement({"node": "F__door_02"});
    ca.addPlacement({"node": "F__door_03"});
    ca.addPlacement({"node": "F__door_02.001"});
    ca.addPlacement({"node": "F__door_03"});
    ca.addPlacement({"node": "F__door_03.002"});
    ca.addPlacement({"node": "F__door_em_canopy01"});
    ca.addPlacement({"node": "F__door_em_canopy01.002"});
    ca.addPlacement({"node": "F_door_em_canopyDX.000"});
    ca.addPlacement({"node": "F_door_em_canopyDX.001"});
    ca.addPlacement({"node": "F_door_em_canopyDX.002"});
    ca.addPlacement({"node": "F_door_em_canopyDX.004"});
    ca.addPlacement({"node": "F_door_em_canopyDX.004a"});
    ca.addPlacement({"node": "F_door_em_canopyDX.004a.001"});
    ca.addPlacement({"node": "F_door_em_canopyDX.005"});
    ca.addPlacement({"node": "F_door_em_canopySX.000"});
    ca.addPlacement({"node": "F_door_em_canopySX.001"});
    ca.addPlacement({"node": "F_door_em_canopySX.002"});
    ca.addPlacement({"node": "F_door_em_canopySX.004"});
    ca.addPlacement({"node": "F_door_em_canopySX.004a"});
    ca.addPlacement({"node": "F_door_em_canopySX.005"});
    ca.addPlacement({"node": "F_handle_armydoorDX"});
    ca.addPlacement({"node": "F_handle_armydoorSX"});
    ca.addPlacement({"node": "B00_sx_door_01.001"});
    ca.addPlacement({"node": "B00_dx_door_01.000"});
    ca.addPlacement({"node": "B00_Asse_dx_door_bis"});
    ca.addPlacement({"node": "B00_sx_door_bis.002"});
    ca.addPlacement({"node": "A__G91_fuselage_int.weapon.door.007"});
    ca.addPlacement({"node": "A__G91_fuselage_int.weapon.door.008"});
    ca.addPlacement({"node": "m00_door_01.2"});
    ca.addPlacement({"node": "m00_door_dx03.002"});
    ca.addPlacement({"node": "tank_cap1"});
    ca.addPlacement({"node": "tank_cap"});

    # Tail
    ca.addPlacement({"node": "A__G91_fuselage_coda.002"});
    ca.addPlacement({"node": "A__G91_fuselage_coda.005"});
    ca.addPlacement({"node": "A__G91_fuselage_coda.006"});
    ca.addPlacement({"node": "A__G91_door_sx_coda.000"});
    ca.addPlacement({"node": "A__G91_door_dx_coda.001"});
    ca.addPlacement({"node": "A__G91_fuselage_coda.007"});
    ca.addPlacement({"node": "A__G91_fuselage_coda.009"});
    ca.addPlacement({"node": "A__G91_fuselage_coda.010"});
    ca.addPlacement({"node": "exit_smoke_001_cover"});
    ca.addPlacement({"node": "exit_smoke_001"});
    ca.addPlacement({"node": "exit_smoke"});
    ca.addPlacement({"node": "fin_small.001"});
    ca.addPlacement({"node": "fin_small.002"});
    ca.addPlacement({"node": "fin_small.003"});
    ca.addPlacement({"node": "fin_small.004"});
    ca.addPlacement({"node": "fin_small.005"});
    ca.addPlacement({"node": "fin_small.006"});
    ca.addPlacement({"node": "fin_small.007"});
    ca.addPlacement({"node": "fin_small.008"});
    ca.addPlacement({"node": "fin_small.009"});
    ca.addPlacement({"node": "fin_small.010"});
    ca.addPlacement({"node": "D_timone_coda"});
    ca.addPlacement({"node": "D_timone_coda.001"});
    ca.addPlacement({"node": "D_timone_coda.002"});
    ca.addPlacement({"node": "D_timone_coda.003"});
    ca.addPlacement({"node": "D_aletta_correttrice"});
    ca.addPlacement({"node": "M_tail_component_01"});
    ca.addPlacement({"node": "vent_tail"});

    # Canopy
    ca.addPlacement({"node": "A__G91_fuselage_canopy"});
    ca.addPlacement({"node": "F_canopY_ant"});
    ca.addPlacement({"node": "F_CANPOPY.005"});

    # Fuselage A0
    ca.addPlacement({"node": "A__G91_fuselage_muso_1.001"});
    ca.addPlacement({"node": "A__G91_fuselage_muso_1.000"});
    ca.addPlacement({"node": "A__G91_fuselage_muso_1.008"});
    ca.addPlacement({"node": "A__G91_fuselage_muso_1.009"});
    ca.addPlacement({"node": "A_antenna_cover"});
    ca.addPlacement({"node": "panR1b__G91_fuselage_muso_1.000"});
    ca.addPlacement({"node": "panR1b__G91_fuselage_muso_1.024"});

    # Fuselage B0
    ca.addPlacement({"node": "A__G91_fuselage_weapon_door_dx.003"});
    ca.addPlacement({"node": "A__G91_fuselage_weapon_door_sx.003"});
    ca.addPlacement({"node": "A__G91r3_fuselage_weapon_door_sx."});
    ca.addPlacement({"node": "A__G91r3_fuselage_weapon_door_dx"});

    # Airbrake
    ca.addPlacement({"node": "C00_dx_airbrake_door.002"});
    ca.addPlacement({"node": "C00_sx_airbrake_door.004"});

    # Landing gear frontal
    ca.addPlacement({"node": "PlanLight.front.001"});
    ca.addPlacement({"node": "gear_door_sx.000"});
    ca.addPlacement({"node": "gear_door_dx.001"});

    ca_root = ca.createGroup();

    cw = canvas.new({"name": "Wing",
                        "size": [cw_size,cw_size],
                        "view": [cw_size,cw_size],
                        "mipmapping": 1});

    # Wing
    var target_module_id = 0;
    
    cw.addPlacement({"node": "A_wing_dx.000"});
    cw.addPlacement({"node": "A_wing_sx.000"});
    cw.addPlacement({"node": "A_wing_dx.001"});
    cw.addPlacement({"node": "A_wing_sx.001"});
    cw.addPlacement({"node": "A_wing_dx.002"});
    cw.addPlacement({"node": "A_wing_sx.002"});
    cw.addPlacement({"node": "A_wing_dx.004"});
    cw.addPlacement({"node": "A_wing_sx.004"});
    cw.addPlacement({"node": "A_wing_dx.005"});
    cw.addPlacement({"node": "A_wing_sx.005"});
    cw.addPlacement({"node": "A_wing_dx.006"});
    cw.addPlacement({"node": "A00_wing_dx_part.001"});
    cw.addPlacement({"node": "A00_wing_dx_part.002"});
    cw.addPlacement({"node": "A00_wing_dx_part.003"});
    cw.addPlacement({"node": "A_flap_dx"});
    cw.addPlacement({"node": "A_flap_sx"});
    cw.addPlacement({"node": "A_alettone_sx.001"});
    cw.addPlacement({"node": "A_alettone_dx.002"});
    cw.addPlacement({"node": "A_alettone_sx"});
    cw.addPlacement({"node": "A_alettone_dx"});
    cw.addPlacement({"node": "A_wing_border_sx"});
    cw.addPlacement({"node": "A_wing_border_dx.001"});
    cw.addPlacement({"node": "A_door_wing_dx.001"});
    cw.addPlacement({"node": "A_door_wing_dx.004"});
    cw.addPlacement({"node": "A_door_wing_dx.005"});
    cw.addPlacement({"node": "A_door_wing_sx.000"});
    cw.addPlacement({"node": "A_door_wing_sx.002"});
    cw.addPlacement({"node": "A_door_wing_sx.003"});
    cw.addPlacement({"node": "B00_dx_door_02.002"});
    cw.addPlacement({"node": "B00_dx_door_02"});
    cw.addPlacement({"node": "A00_pitot_dx"});
    cw.addPlacement({"node": "A00_pitot_dx.001"});

    # Tail
    
    cw.addPlacement({"module-id": target_module_id, type: "scenery-object","node": "D_wing_sx_.001"});
    cw.addPlacement({"module-id": target_module_id, type: "scenery-object","node": "D_wing_sx.000"});
    cw.addPlacement({"module-id": target_module_id, type: "scenery-object","node": "D_wing_dx_.000"});
    cw.addPlacement({"module-id": target_module_id, type: "scenery-object","node": "D_wing_dx.007"});
    
    # cw.addPlacement({"node": "D_wing_sx_.001"});
    # cw.addPlacement({"node": "D_wing_sx.000"});
    # cw.addPlacement({"node": "D_wing_dx_.000"});
    # cw.addPlacement({"node": "D_wing_dx.007"});
    cw.addPlacement({"node": "D_equilibratore_dx"});
    cw.addPlacement({"node": "D_equilibratore_sx.002"});

    # Hard points
    cw.addPlacement({"node": "hp_dx_int_01_external"});
    cw.addPlacement({"node": "hp_dx_int_PAN_external"});
    cw.addPlacement({"node": "hp_sx_int_01_external"});
    cw.addPlacement({"node": "hp_sx_int_PAN_external"});

    # Stores
    cw.addPlacement({"node": "tank_260lb_sub_01"});
    cw.addPlacement({"node": "tank_260lb_sup_01"});
    cw.addPlacement({"node": "tank_260lb_tail_01"});
    cw.addPlacement({"node": "PAN_tank_sx.004"});
    cw.addPlacement({"node": "PAN_tank_sx_003"});
    # Tank 900lb
    cw.addPlacement({"node": "tank_cover_top"});
    cw.addPlacement({"node": "tank_cover_downa"});
    cw.addPlacement({"node": "orizontal-pin (Meshed)"});
    cw.addPlacement({"node": "vertical-pin-dx (Meshed)"});
    cw.addPlacement({"node": "vertical-pin-sx (Meshed)"});

    # Fuselage extra
    cw.addPlacement({"node": "A__G91r3_fuselage_weapon.door"});

    cw_root = cw.createGroup();

    # Anti-reflective

    ar = canvas.new({"name": "Anti-reflective-area",
                        "size": [128,128],
                        "view": [128,128],
                        "mipmapping": 1});

    ar.addPlacement({"node": "panR1b__G91_fuselage_muso_1.000"});
    ar.addPlacement({"node": "A__G91_fuselage_muso_1.008"});
    ar.addPlacement({"node": "A__G91_fuselage_muso_1.009"});
    ar.addPlacement({"node": "A__G91_fuselage_int.weapon.door.004"});
    ar.addPlacement({"node": "A__G91_fuselage_canopy.004"});

    ar_root = ar.createGroup();

    canvasSetChanged = 0;

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
        if (dirtySet == 0) {
            setprop("sim/G91/liveries/active/dirtyMsg","Dirty inactive");
            print("set_livery.nas setLivery, Dirty inactive");
        } else {
            setprop("sim/G91/liveries/active/dirtyMsg","Dirty active");
            print("set_livery.nas setLivery, Dirty active");
        }
    }

    if (normalMapEnable == 0) {
        setprop("sim/G91/liveries/active/normalmap_enabled_Msg","No normal map");
        print("set_livery.nas setLivery, normalMapEnable inactive");
    } else {
        setprop("sim/G91/liveries/active/normalmap_enabled_Msg","Yes Normal map");
        print("set_livery.nas setLivery, normalMapEnable active");
    }

    if (ca_root != nil) {
        foreach(var image; [livery_001, dirty_001]) {
            print("set_livery.nas setLivery, ca_root show image: ",image," (",size(image),")");
            # Insert the layer
            if (size(image) > 0 and resolutionSet > 0) {
                layers_001[image] = ca_root.createChild("image")
                    .setFile(image)
                    .setSize(ca_size,ca_size);
                if (image == dirty_001) {
                    if (dirtySet == 1) {
                        print("set_livery.nas setLivery, dirty show: ",dirty_001);
                        layers_001[image].show();
                    } else {
                        print("set_livery.nas setLivery, dirty hide: ",dirty_001);
                        layers_001[image].hide();
                    }
                }
            }
        }
    }

    if (cw_root != nil) {
        foreach(var image; [livery_002, dirty_002]) {
            print("set_livery.nas setLivery, cw_root show image: ",image," (",size(image),")");
            # Insert the layer
            if (size(image) > 0 and resolutionSet > 0) {
                layers_002[image] = cw_root.createChild("image")
                    .setFile(image)
                    .setSize(cw_size,cw_size);
                if (image == dirty_002) {
                    if (dirtySet == 1) {
                        print("set_livery.nas setLivery, dirty show: ",dirty_002);
                        layers_002[image].show();
                    } else {
                        print("set_livery.nas setLivery, dirty hide: ",dirty_002);
                        layers_002[image].hide();
                    }
                }
            }
        }
    }

    if (ar_root != nil) {
        foreach(var image; [anti_reflective]) {
            print("set_livery.nas setLivery, anti-reflective: ",image," (",size(image),")");
            # Insert the layer
            if (size(image) > 0 and resolutionSet > 0) {
                anti_reflective_area[image] = ar_root.createChild("image")
                    .setFile(image)
                    .setSize(128,128);
            }
        }
    }

    inExecution = 0;
};


var getActiveData = func() {

    var name_short = "";
    var name_long = "";
    var luminosity = "";
    var reflective = "";
    var PANR1 = 0;
    var diffuse = 0.0;
    var specular = 0.0;
    var dirty = 0;
    var normalmap_enabled = 0;
    var version = 0;

    isMultiPlayer = getprop("sim/G91/liveries/active/isMultiPlayer");
    if (isMultiPlayer == nil) {
        print("set_livery.nas getActiveData isMultiPlayer set to 0");
        setprop("sim/G91/liveries/active/isMultiPlayer",0);
        isMultiPlayer = 0;
    }

    if (isMultiPlayer > 0) {
        resolutionSet = isMultiPlayer;
    } else {
        resolutionSet = getprop("sim/G91/liveries/active/setResolution");
    }

    if (resolutionSet == 1) {
        resolution = 1024; }
    else if (resolutionSet == 2) {
        resolution = 2048; }
    else if (resolutionSet == 3) {
        resolution = 4096; }
    else {
        print("set_livery.nas changeResolution resolutionSet error but change in 1 (",resolutionSet,")");
        resolutionSet = 1;
        resolution = 1024;
    }

    print("set_livery.nas getActiveData resolution id: ",resolutionSet," pixel: ",resolution);
    setprop("sim/G91/liveries/active/resolution",resolution);

    ca_size = resolution;
    cw_size = resolution;

    resolutionSetPrec = resolutionSet;

    if (isMultiPlayer == 0) {
        
        print("set_livery.nas getActiveData, read data from G91_Params.xml");

        var idSelect = getprop("sim/G91/liveries/active/ID");
        if (idSelect == nil) {
            print("set_livery.nas getActiveData, error read idSelect");
            idSelect = 0;
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
            if (liverys[i].getNode("ID").getValue() == idSelect) {
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
        luminosity = liverys[id].getNode("luminosity").getValue();
        reflective = liverys[id].getNode("reflective").getValue();
        PANR1 = liverys[id].getNode("PANR1").getValue();
        diffuse = liverys[id].getNode("diffuse").getValue();
        specular = liverys[id].getNode("specular").getValue();
        dirty = liverys[id].getNode("dirty").getValue();
        normalmap_enabled = liverys[id].getNode("normalmap_enabled").getValue();
        version = liverys[id].getNode("version").getValue();

    } else {

        # Is in multiplayer mode
        
        print("set_livery.nas getActiveData, read data from multiplayer");

        isMultiPlayer_StartPhase = 1;

        # Read data from multiplayer

        idSelect = 5;
        name_short = "Silver R1B";
        name_long = "Silver version R1B with recognition nose (R1B)";
        livery_001 = "Aircraft/G91-R1B_HD/Models/Liveries/dds/ITA_prot_001.dds";
        livery_002 = "Aircraft/G91-R1B_HD/Models/Liveries/dds/ITA_prot_002.dds";
        dirty_001 = "Aircraft/G91-R1B_HD/Models/Liveries/dirty_01_4k.png";
        dirty_002 = "Aircraft/G91-R1B_HD/Models/Liveries/dirty_02_4k.png";
        anti_reflective = "Aircraft/G91-R1B_HD/Models/Liveries/G91_Dark_Grey_128.png";
        luminosity = 0.15;
        reflective = -0.60;
        PANR1 = 0;
        diffuse = 0.89;
        specular = 0.2;
        dirty = 0.0;
        normalmap_enabled = 0;
        version = 2;

    }

    setprop("sim/G91/liveries/active/ID",idSelect);
    setprop("sim/G91/liveries/active/name_short",name_short);
    setprop("sim/G91/liveries/active/name_long",name_long);
    setprop("sim/G91/liveries/active/livery_001",livery_001);
    setprop("sim/G91/liveries/active/livery_002",livery_002);
    setprop("sim/G91/liveries/active/dirty_001",dirty_001);
    setprop("sim/G91/liveries/active/dirty_002",dirty_002);
    setprop("sim/G91/liveries/active/anti_reflective",anti_reflective);
    setprop("sim/G91/liveries/active/luminosity",luminosity);
    setprop("sim/G91/liveries/active/reflective",reflective);
    setprop("sim/G91/liveries/active/PANR1",PANR1);
    setprop("sim/G91/liveries/active/diffuse",diffuse);
    setprop("sim/G91/liveries/active/specular",specular);
    setprop("sim/G91/liveries/active/dirty",dirty);
    setprop("sim/G91/liveries/active/normalmap_enabled",normalMapEnable);
    setprop("sim/G91/liveries/active/version",version);

    print("set_livery.nas getActiveData setLivery  ID: ",idSelect);
    print("set_livery.nas getActiveData setLivery  name_short: ",name_short);
    print("set_livery.nas getActiveData setLivery  name_long: ",name_long);
    print("set_livery.nas getActiveData setLivery  livery_001: ",livery_001);
    print("set_livery.nas getActiveData setLivery  livery_002: ",livery_002);
    print("set_livery.nas getActiveData setLivery  dirty_001: ",dirty_001);
    print("set_livery.nas getActiveData setLivery  dirty_002: ",dirty_002);
    print("set_livery.nas getActiveData setLivery  luminosity: ",luminosity);
    print("set_livery.nas getActiveData setLivery  reflective: ",reflective);
    print("set_livery.nas getActiveData setLivery  PANR1: ",PANR1);
    print("set_livery.nas getActiveData setLivery  diffuse: ",diffuse);
    print("set_livery.nas getActiveData setLivery  specular: ",specular);
    print("set_livery.nas getActiveData setLivery  dirty: ",dirty);
    print("set_livery.nas getActiveData setLivery  normalmap_enabled: ",normalmap_enabled);
    print("set_livery.nas getActiveData setLivery  version: ",version);

    id_prec = idSelect;

    call(setCanvas,[]);
    call(setLivery,[]);

}


setlistener("sim/G91/liveries/active/ID", func {
    var id = props.globals.getNode("sim/G91/liveries/active/ID",1).getValue();
    if (id != nil and id != 0 and id_prec != id and isMultiPlayer == 0) {
        if(inExecution == 0) {
            print("set_livery.nas setlistener ID: ",id," (idprec: ",id_prec,")");
            call(getActiveData,[]);
        }
    }
}, 1, 1);


setlistener("sim/G91/liveries/active/dirtySet", func {

    if(inExecution == 0 and isMultiPlayer == 0) {
        dirtySet = props.globals.getNode("sim/G91/liveries/active/dirtySet",1).getValue();
        print("set_livery.nas setlistener dirtySet: ",dirtySet);
        call(setLivery,[]);
    }

}, 1, 1);


setlistener("sim/G91/liveries/active/normalmap_enabled", func {

    if(inExecution == 0 and isMultiPlayer == 0) {
        normalMapEnable = props.globals.getNode("sim/G91/liveries/active/normalmap_enabled",1).getValue();
        print("set_livery.nas setlistener normalmap_enabled: ",normalMapEnable);
        call(setLivery,[]);
    }

}, 1, 1);
