# From: http://wiki.flightgear.org/Howto:Dynamic_Liveries_via_Canvas

var prop = props.globals.initNode("sim/G91/liveries/active/symbol_id", 1, "INT");
var prop = props.globals.initNode("sim/G91/liveries/active/symbol_id_mod", 0, "INT");
var prop = props.globals.initNode("sim/G91/liveries/active/symbol_scale", 0.0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/liveries/active/symbol_x_dx", 0.0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/liveries/active/symbol_y_dx", 0.0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/liveries/active/symbol_mirror_dx", 0, "INT");
var prop = props.globals.initNode("sim/G91/liveries/active/symbol_x_sx", 0.0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/liveries/active/symbol_y_sx", 0.0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/liveries/active/symbol_mirror_sx", 0, "INT");
var prop = props.globals.initNode("sim/G91/liveries/active/symbol_scale", 0.0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/liveries/active/symbol_rotation", 0.0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/liveries/active/symbol_layer", 1, "INT");
var prop = props.globals.initNode("sim/G91/liveries/active/symbol_input_set", "", "STRING");
var prop = props.globals.initNode("sim/G91/liveries/active/symbol_input_set_mod", 0, "INT");

var setLivery_InExecution = 0;

var targets_module_id = {};
var targets_path = {};

var resolutionSetChanged = 0;

var id_prec = nil;
var printLog = nil;

setprop("sim/G91/liveries/active/set-livery-loaded",1);
print("set_livery.nas is loaded");


var LiverySymbolDataClass = {
    class_name: "LiverySymbolDataClass",
    
    new: func() {
        var obj = {
            record: nil,
            canvas: nil,
            s_symbol_id: nil,
            type: 0,
            x_dx: 0.0,
            y_dx: 0.0,
            mirror_dx: 0,
            s_symbol_id_dx: nil,
            x_sx: 0.0,
            y_sx: 0.0,
            mirror_sx: 0,
            s_symbol_id_sx: nil,
            scale: 0.0,
            file: nil,
            rotation: 0.0,
            reduction: 16.0,
            layer: nil,
            isShow: 1,
            targetModule: nil,
            resolution: 0,
        };
        return {parents: [LiverySymbolDataClass]};
    },
    
    init: func(s_symbol_id, aRecord) {
        me.s_symbol_id = s_symbol_id;
        me.s_symbol_id_dx = s_symbol_id ~ "_dx";
        me.s_symbol_id_sx = s_symbol_id ~ "_sx";
        me.record = string.trim(aRecord);
        var r = string.scanf(aRecord,"%f|%f,%f,%f|%f,%f,%f|%f,%f,%f|%f|%s", var result = []);
        ### print("***** 01 record: ", aRecord," dim: ",size(result)," : ",debug.dump(result));
        if (size(result) >= 9) {
            var i = 0;
            foreach(var value; result) {
                if (i == 0) me.type = value;
                if (i == 1) me.x_dx = value;
                if (i == 2) me.y_dx = value;
                if (i == 3) me.mirror_dx = value;
                if (i == 4) me.x_sx = value;
                if (i == 5) me.y_sx = value;
                if (i == 6) me.mirror_sx = value;
                if (i == 7) me.scale = value;
                if (i == 8) me.rotation = value;
                if (i == 9) me.reduction = value;
                if (i == 10) me.layer = value;
                if (i == 11) me.file = value;
                i += 1;
            };
            if (me.mirror_dx > 0) {
                me.mirror_dx = -1;
            } else {
                me.mirror_dx = 1;
            }
            if (me.mirror_sx > 0) {
                me.mirror_sx = -1;
            } else {
                me.mirror_sx = 1;
            }
            print("set_livery.nas LiverySymbolDataClass s_symbol_id: ",me.s_symbol_id," "
                ,sprintf("%1.0f",me.type)
                ,sprintf("|%1.3f",me.x_dx)
                ,sprintf(" %1.3f",me.y_dx)
                ,sprintf(" %1.3f",me.mirror_dx)
                ,sprintf("|%1.3f",me.x_sx)
                ,sprintf(" %1.3f",me.y_sx)
                ,sprintf(" %1.3f",me.mirror_sx)
                ,sprintf("|%1.3f",me.scale)
                ,sprintf(" %1.3f",me.rotation)
                ,sprintf(" %2.0f",me.reduction)
                ,sprintf("|%1.0f",me.layer)
                ,sprintf("|%s",me.file));
        } else {
            print("set_livery.nas LiverySymbolDataClass Error in the data id: ",me.s_symbol_id," with record: ",me.record);
            me.record = nil;
        };
        return;
    },
};


var LiverySymbolClass = {
    class_name: "LiverySymbolClass",
    
    new: func(aPath) {
        var obj = {
            path: nil,
            data: nil,
        };
        me.path = aPath;
        me.data = {};
        return {parents: [LiverySymbolClass]};
    },
    
    add: func(s_symbol_id, aRecord) {
        if (aRecord != nil and (size(string.trim(aRecord)) > 0)) {
            me.data[s_symbol_id] = LiverySymbolDataClass.new();
            me.data[s_symbol_id].init(s_symbol_id, aRecord);
        }
    },
    
    set_canvasGroup: func(aCanvas) {
        me.canvas = aCanvas;
        return;
    },
    
    set_values: func(s_symbol_id,x_dx,y_dx,mirror_dx,x_sx,y_sx,mirror_sx,scale,rotation,layer) {
        if (x_dx > 0.01) me.data[s_symbol_id].x_dx = x_dx;
        if (y_dx > 0.01) me.data[s_symbol_id].y_dx = y_dx;
        me.data[s_symbol_id].mirror_dx = mirror_dx;
        if (x_sx > 0.01) me.data[s_symbol_id].x_sx = x_sx;
        if (y_sx > 0.01) me.data[s_symbol_id].y_sx = y_sx;
        me.data[s_symbol_id].mirror_sx = mirror_sx;
        if (scale >= 0.01) me.data[s_symbol_id].scale = scale;
        if (me.data[s_symbol_id].targetModule != nil) {
            me.set_targetModule(s_symbol_id);
        }
        me.layer = layer;
        return;
    },
    
    input_set_values: func() {
        var symbol_id = getprop("sim/G91/liveries/active/symbol_id");
        var s_symbol_id = "symbol_" ~ sprintf("%02d",symbol_id + 1);
        var x_dx = getprop("sim/G91/liveries/active/symbol_x_dx");
        var y_dx = getprop("sim/G91/liveries/active/symbol_y_dx");
        var mirror_dx = getprop("sim/G91/liveries/active/symbol_mirror_dx");
        var x_sx = getprop("sim/G91/liveries/active/symbol_x_sx");
        var y_sx = getprop("sim/G91/liveries/active/symbol_y_sx");
        var mirror_sx = getprop("sim/G91/liveries/active/symbol_mirror_sx");
        var scale = getprop("sim/G91/liveries/active/symbol_scale");
        var rotation = getprop("sim/G91/liveries/active/symbol_rotation");
        var layer = getprop("sim/G91/liveries/active/symbol_layer");
        me.set_values(s_symbol_id,x_dx,y_dx,mirror_dx,x_sx,y_sx,mirror_sx,scale,rotation,layer);
        return;
    },
    
    input_set_symbol_id: func() {
        var symbol_id = getprop("sim/G91/liveries/active/symbol_id");
        var s_symbol_id = "symbol_" ~ sprintf("%02d",symbol_id + 1);
        foreach(var s_symbol_id_data; keys(me.data)) {
            if (s_symbol_id == s_symbol_id_data) {
                setprop("sim/G91/liveries/active/symbol_x_dx",me.data[s_symbol_id].x_dx);
                setprop("sim/G91/liveries/active/symbol_y_dx",me.data[s_symbol_id].x_dx);
                setprop("sim/G91/liveries/active/symbol_mirror_dx",me.data[s_symbol_id].mirror_dx);
                setprop("sim/G91/liveries/active/symbol_x_sx",me.data[s_symbol_id].x_sx);
                setprop("sim/G91/liveries/active/symbol_y_sx",me.data[s_symbol_id].x_sx);
                setprop("sim/G91/liveries/active/symbol_mirror_sx",me.data[s_symbol_id].mirror_sx);
                setprop("sim/G91/liveries/active/symbol_scale",me.data[s_symbol_id].scale);
                setprop("sim/G91/liveries/active/symbol_rotation",me.data[s_symbol_id].rotation);
                setprop("sim/G91/liveries/active/symbol_layer",me.data[s_symbol_id].layer);
                me.set_values(s_symbol_id,x_dx,y_dx,mirror_dx,x_sx,y_sx,mirror_sx,scale,rotation);
                return;
            }
        }
        return;
    },
    
    set_targetModule: func(s_symbol_id) {
        var data = me.data[s_symbol_id];
        var resolution = me.data[s_symbol_id].resolution;
        if (data.record != nil) {
            if (data.type == 1) {
                data.targetModule[data.s_symbol_id_dx]
                    .setTranslation(data.x_dx * resolution,data.y_dx * resolution)
                    .setScale(data.mirror_dx * 1.2 * data.scale,data.scale);
                data.targetModule[data.s_symbol_id_sx]
                    .setTranslation(data.x_sx * resolution,data.y_sx * resolution)
                    .setScale(data.mirror_sx * 1.2 * data.scale,data.scale);
            }
        }
    },
    
    new_targetModule: func(aLayer,aTargetModule,resolution,aRoot) {
        foreach(var s_symbol_id; keys(me.data)) {
            var data = me.data[s_symbol_id];
            if (data.record != nil) {
                if (data.layer == aLayer) {
                    data.targetModule = aTargetModule;
                    data.resolution = resolution;
                    var fileWithPath = me.path ~ "/" ~ data.file;
                    print("set_livery.nas LiverySymbolClass new_targetModule s_symbol_id: ",s_symbol_id," fileWithPath: ",fileWithPath, "resolution: ",resolution," scale: ",data.scale);
                    if (data.type == 1) {
                        data.targetModule[data.s_symbol_id_dx] = aRoot.createChild("image")
                            .setFile(fileWithPath)
                            .setTranslation(data.x_dx * resolution,data.y_dx * resolution)
                            .setScale(data.mirror_dx * 1.2 * data.scale,data.scale)
                            .setSize(resolution / data.reduction,resolution / data.reduction);
                        data.targetModule[data.s_symbol_id_sx] = aRoot.createChild("image")
                            .setFile(fileWithPath)
                            .setTranslation(data.x_sx * resolution,data.y_sx * resolution)
                            .setScale(data.mirror_sx * 1.2 * data.scale,data.scale)
                            .setSize(resolution / data.reduction,resolution / data.reduction);
                    }
                }
            }
        }
        return;
    },
    
    show: func(s_symbol_id) {
        return;
    },
};


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
"A__G91_fuselage_int.weapon.door.004",
"A__G91_fuselage_canopy.004",

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
"hp_dx_int_01_internal",
"hp_sx_int_01_external",
"hp_sx_int_PAN_external",
"hp_sx_int_01_internal",
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


var get_resolution = func(aResolutionSet) {
    var resolution = 512;
    if (aResolutionSet == 1) {
        resolution = 512; }
        elsif (aResolutionSet == 2) {
            resolution = 1024; }
            elsif (aResolutionSet == 3) {
                resolution = 2048; }
                elsif (aResolutionSet == 4) {
                    resolution = 4096; }
                    else {
                        print("set_livery.nas changeResolution resolutionSet error but change in 1 (",aResolutionSet,")");
                        aResolutionSet = 2;
                        resolution = 1024;
                        setprop("sim/G91/liveries/active/resolution-set",aResolutionSet);
                        setprop("sim/G91/liveries/active/resolution-set-pixel",resolution);
                    }
                    return resolution;
};


var setNumberPosition = func(target_module_id, scale, x, y) {
    
    var resolution = get_resolution(targets_module_id[target_module_id]["resolution_set"]);
    if (x == nil) x = 0.0;
    if (y == nil) y = 0.0;
    if (scale == nil or scale < 0.1) scale = 0.1;
    print("***** setNumberPosition target_module_id: ",target_module_id," x: ",x," y: ",y," resolution: ",resolution);
    targets_module_id[target_module_id]["layers_001"]["number"]
        .setTranslation(x * resolution,y * resolution)
        .setScale(1.2 * scale,scale);
    
}


var createCanvas = func(target_module_id) {
    
    # see: http://wiki.flightgear.org/Howto:Creating_fullscreen_Canvas_applications
    # see: http://wiki.flightgear.org/Canvas_Nasal_API
    
    var resolution = get_resolution(targets_module_id[target_module_id]["resolution_set"]);
 
    print("set_livery.nas createCanvas: ca_size = ",resolution," cw_size = ",resolution, " module target_module_id: ",target_module_id);
    
    if (targets_module_id[target_module_id]["ca"] == nil) {
        targets_module_id[target_module_id]["ca"] = canvas.new({"name": "Fuselage",
            "size": [resolution,resolution],
            "view": [resolution,resolution],
            "mipmapping": 0});
        
        targets_module_id[target_module_id]["cw"] = canvas.new({"name": "Wing",
            "size": [resolution,resolution],
            "view": [resolution,resolution],
            "mipmapping": 0});
        
        targets_module_id[target_module_id]["ca_root"] = targets_module_id[target_module_id]["ca"].createGroup();
        targets_module_id[target_module_id]["cw_root"] = targets_module_id[target_module_id]["cw"].createGroup();
        
        print("set_livery.nas createCanvas: execute canvas.new(...) and createGroup() with target_module_id: ",target_module_id);
        ### print(debug.dump(targets_module_id[target_module_id]["ca"]));
    
        if (target_module_id == 0) {
            print("set_livery.nas createCanvas, single player");
            foreach(var node; objectsNodes_ca) { targets_module_id[target_module_id]["ca"].addPlacement({"node": node}) };
            foreach(var node; objectsNodes_cw) { targets_module_id[target_module_id]["cw"].addPlacement({"node": node}) };
        } else {
            print("set_livery.nas createCanvas, multi player with module-id: ",target_module_id);
            foreach(var node; objectsNodes_ca) { targets_module_id[target_module_id]["ca"].addPlacement({"module-id": target_module_id-1, type: "scenery-object","node": node}) };
            foreach(var node; objectsNodes_cw) { targets_module_id[target_module_id]["cw"].addPlacement({"module-id": target_module_id-1, type: "scenery-object","node": node}) };
        }
        
    }
  
};


var setLivery = func(target_module_id) {
    
    setLivery_InExecution = 1;

    var livery_001 = targets_module_id[target_module_id]["livery_001"];
    var livery_002 = targets_module_id[target_module_id]["livery_002"];
    var dirty_001 = targets_module_id[target_module_id]["dirty_001"];
    var dirty_002 = targets_module_id[target_module_id]["dirty_002"];
    var dirty_set = targets_module_id[target_module_id]["dirty_set"];
    var resolution = get_resolution(targets_module_id[target_module_id]["resolution_set"]);
    
    if (targets_module_id[target_module_id]["ca_root"] != nil) {
        var id = 0;
        targets_module_id[target_module_id]["layers_001"] = {};
        foreach(var image; [livery_001, dirty_001]) {
            id += 1;
            var insertLivery = 0;
            print("set_livery.nas setLivery ca_root image: ",image," (",size(image),") resolution: ",resolution," target_module_id: ",target_module_id);
            # Insert the layer
            if (size(image) > 0) {
                if (id == 1 and contains(targets_module_id[target_module_id]["layers_001"], image) == 0) insertLivery = 1;
                if (id == 2 and dirty_set == 1 and contains(targets_module_id[target_module_id]["layers_001"], image) == 0) insertLivery = 1;
                if (insertLivery == 1) {
                    targets_module_id[target_module_id]["layers_001"][image] = targets_module_id[target_module_id]["ca_root"].createChild("image")
                        .setFile(image)
                        .setSize(resolution,resolution);
                    print("set_livery.nas setLivery ca_root inserted target_module_id: ",target_module_id, " image: ",image," id = ",id);
                } else {
                    print("set_livery.nas setLivery ca_root not inserted target_module_id: ",target_module_id, " image: ",image," id = ",id);
                }
                if (id == 2 and contains(targets_module_id[target_module_id]["layers_001"], image)) {
                    if (dirty_set == 1) {
                        print("set_livery.nas dirty show: ",dirty_001);
                        targets_module_id[target_module_id]["layers_001"][image].show();
                    } else {
                        print("set_livery.nas dirty hide: ",dirty_001);
                        targets_module_id[target_module_id]["layers_001"][image].hide();
                    }
                }
            }
            
        }
        
        if (targets_module_id[target_module_id]["lsc"] != nil) {
            ### print("***** 10: ",debug.dump(targets_module_id[target_module_id]["lsc"]));
            targets_module_id[target_module_id]["lsc"].new_targetModule(1,targets_module_id[target_module_id]["layers_001"],resolution,targets_module_id[target_module_id]["ca_root"]);
        };

    }
    
    if (targets_module_id[target_module_id]["cw_root"] != nil) {
        var id = 0;
        targets_module_id[target_module_id]["layers_002"] = {};
        foreach(var image; [livery_002, dirty_002]) {
            id += 1;
            var insertLivery = 0;
            print("set_livery.nas setLivery cw_root image: ",image," (",size(image),") resolution: ",resolution," target_module_id: ",target_module_id);
            # Insert the layer
            if (size(image) > 0) {
                if (id == 1 and contains(targets_module_id[target_module_id]["layers_002"], image) == 0) insertLivery = 1;
                if (id == 2 and dirty_set == 1 and contains(targets_module_id[target_module_id]["layers_002"], image) == 0) insertLivery = 1;
                if (insertLivery == 1) {
                    targets_module_id[target_module_id]["layers_002"][image] = targets_module_id[target_module_id]["cw_root"].createChild("image")
                        .setFile(image)
                        .setSize(resolution,resolution);
                    print("set_livery.nas setLivery cw_root inserted target_module_id: ",target_module_id, " image: ",image," id = ",id);
                } else {
                    print("set_livery.nas setLivery cw_root not inserted target_module_id: ",target_module_id, " image: ",image," id = ",id);
                }
                if (id == 2 and contains(targets_module_id[target_module_id]["layers_002"], image)) {
                    if (dirty_set == 1) {
                        print("set_livery.nas dirty show: ",dirty_002);
                        targets_module_id[target_module_id]["layers_002"][image].show();
                    } else {
                        print("set_livery.nas dirty hide: ",dirty_002);
                        targets_module_id[target_module_id]["layers_002"][image].hide();
                    }
                }
            }
        }
        if (targets_module_id[target_module_id]["lsc"] != nil) {
            ### print("***** 10: ",debug.dump(targets_module_id[target_module_id]["lsc"]));
            targets_module_id[target_module_id]["lsc"].new_targetModule(2,targets_module_id[target_module_id]["layers_002"],resolution,targets_module_id[target_module_id]["cw_root"]);
        };
    }
    
    setLivery_InExecution = 0;
};


var getActiveData = func(target_module_id, dirty_set) {
    
    var idLivery = 0;
    var resolutionSet = 2;
    
    if (target_module_id == 0) {
        resolutionSet = getprop("sim/G91/liveries/active/resolution-set");
        if (resolutionSet == nil) {
            resolutionSet = 2;
            setprop("sim/G91/liveries/active/resolution-set",2);
        }
        print("set_livery.nas getActiveData is single palyer mode id_MultiPlayer: ",target_module_id,"resolution-set: ",resolutionSet);
    } else {
        resolutionSet = 2;
        print("set_livery.nas getActiveData is multiplayer mode id_MultiPlayer: ",target_module_id,"resolution-set: ",resolutionSet);
    }
    
    if (target_module_id == 0) {
        
        #// Single player mode
        
        print("set_livery.nas getActiveData, read data from G91_Params.xml");
        
        idLivery = getprop("sim/G91/liveries/active/id");
        if (idLivery == nil) {
            print("set_livery.nas getActiveData, error read ID, set ID to 1");
            setprop("sim/G91/liveries/active/id",1);
            idLivery = 1;
        } else {
            print("set_livery.nas getActiveData, idLivery: ",idLivery);
        }
        
        if (idLivery == 0) {
            print("set_livery.nas getActiveData, error file liveries/active not found");
            return;
        }
        
        var liveries = props.globals.getNode("sim/G91/liveries").getChildren("livery");
        
        var id = -1;
        forindex(i; liveries) {
            if (liveries[i].getNode("id").getValue() == idLivery) {
                print("set_livery.nas getActiveData, id select: ", idLivery, "(",i,")");
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
        
        if (!contains(targets_module_id,target_module_id)) {
            targets_module_id[target_module_id] = {};
            print("set_livery.nas getActiveData, create an empy targets_module_id[target_module_id], with target_module_id: ",target_module_id);
        }
        
        if (dirty_set != nil) {
            liveries[id].getNode("dirty_set").setIntValue(dirty_set);
        }
        
        targets_module_id[target_module_id]["target_module_id"] = target_module_id;
        targets_module_id[target_module_id]["idLivery"] = idLivery;
        targets_module_id[target_module_id]["PANR1"] = liveries[id].getNode("PANR1").getValue();
        targets_module_id[target_module_id]["version"] = liveries[id].getNode("version").getValue();
        targets_module_id[target_module_id]["name_short"] = liveries[id].getNode("name_short").getValue();
        targets_module_id[target_module_id]["name_long"] = liveries[id].getNode("name_long").getValue();
        targets_module_id[target_module_id]["livery_001"] = liveries[id].getNode("livery_001").getValue();
        targets_module_id[target_module_id]["livery_002"] = liveries[id].getNode("livery_002").getValue();
        targets_module_id[target_module_id]["dirty_001"] = liveries[id].getNode("dirty_001").getValue();
        targets_module_id[target_module_id]["dirty_002"] = liveries[id].getNode("dirty_002").getValue();
        targets_module_id[target_module_id]["diffuse"] = liveries[id].getNode("diffuse").getValue();
        targets_module_id[target_module_id]["specular"] = liveries[id].getNode("specular").getValue();
        targets_module_id[target_module_id]["dirty_set"] = liveries[id].getNode("dirty_set").getValue();
        targets_module_id[target_module_id]["normalmap_enabled"] = liveries[id].getNode("normalmap_enabled").getValue();
        targets_module_id[target_module_id]["symbols_path"] = liveries[id].getNode("symbols_path").getValue();
        targets_module_id[target_module_id]["symbol_01"] = liveries[id].getNode("symbol_01").getValue();
        targets_module_id[target_module_id]["symbol_02"] = liveries[id].getNode("symbol_02").getValue();
        targets_module_id[target_module_id]["symbol_03"] = liveries[id].getNode("symbol_03").getValue();
        targets_module_id[target_module_id]["symbol_04"] = liveries[id].getNode("symbol_04").getValue();
        targets_module_id[target_module_id]["symbol_05"] = liveries[id].getNode("symbol_05").getValue();
        targets_module_id[target_module_id]["tacan_nav_active_state"] = liveries[id].getNode("tacan_nav_active_state").getValue();
        targets_module_id[target_module_id]["recognition_gauges"] = liveries[id].getNode("recognition_gauges").getValue();
        targets_module_id[target_module_id]["resolution_set"] = resolutionSet;

        #// Set the active livery section
        
        setprop("sim/G91/liveries/active/id",idLivery);
        setprop("sim/G91/liveries/active/version",liveries[id].getNode("version").getValue());
        setprop("sim/G91/liveries/active/name_short",liveries[id].getNode("name_short").getValue());
        setprop("sim/G91/liveries/active/name_long",liveries[id].getNode("name_long").getValue());
        setprop("sim/G91/liveries/active/livery_001",liveries[id].getNode("livery_001").getValue());
        setprop("sim/G91/liveries/active/livery_002",liveries[id].getNode("livery_002").getValue());
        setprop("sim/G91/liveries/active/dirty_001",liveries[id].getNode("dirty_001").getValue());
        setprop("sim/G91/liveries/active/dirty_002",liveries[id].getNode("dirty_002").getValue());
        setprop("sim/G91/liveries/active/PANR1",liveries[id].getNode("PANR1").getValue());
        setprop("sim/G91/liveries/active/diffuse",liveries[id].getNode("diffuse").getValue());
        setprop("sim/G91/liveries/active/specular",liveries[id].getNode("specular").getValue());
        setprop("sim/G91/liveries/active/dirty_set",liveries[id].getNode("dirty_set").getValue());
        setprop("sim/G91/liveries/active/normalmap_enabled",liveries[id].getNode("normalmap_enabled").getValue());
        setprop("sim/G91/liveries/active/symbols_path",liveries[id].getNode("symbols_path").getValue());
        setprop("sim/G91/liveries/active/symbol_01",liveries[id].getNode("symbol_01").getValue());
        setprop("sim/G91/liveries/active/symbol_02",liveries[id].getNode("symbol_02").getValue());
        setprop("sim/G91/liveries/active/symbol_03",liveries[id].getNode("symbol_03").getValue());
        setprop("sim/G91/liveries/active/symbol_04",liveries[id].getNode("symbol_04").getValue());
        setprop("sim/G91/liveries/active/symbol_05",liveries[id].getNode("symbol_05").getValue());
        setprop("sim/G91/liveries/active/tacan_nav_active_state",liveries[id].getNode("tacan_nav_active_state").getValue());
        setprop("sim/G91/liveries/active/recognition_gauges",liveries[id].getNode("recognition_gauges").getValue());
        
        #// Symbol section
        
        var symbol_path_node = liveries[id].getNode("symbols_path");
        var symbol_id = 0;
        if (symbol_path_node != nil) {
            var symbol_path = symbol_path_node.getValue();
            var search = 1;
            targets_module_id[target_module_id]["lsc"] = LiverySymbolClass.new(symbol_path);
            # there is a list of symbols, the list is explored
            while (search == 1) {
                var s_symbol_id = "symbol_" ~ sprintf("%02d",symbol_id + 1);
                print("set_livery.nas getActiveData s_symbol_id: ",s_symbol_id);
                var s = liveries[id].getNode(s_symbol_id);
                if (s != nil) {
                    targets_module_id[target_module_id]["lsc"].add(s_symbol_id,s.getValue());
                    print("set_livery.nas getActiveData get symbols, id: ",symbol_id," record: ",targets_module_id[target_module_id]["lsc"]);
                    setprop("sim/G91/liveries/active/" ~ s_symbol_id,s.getValue());
                    symbol_id += 1;
                } else {
                    print("set_livery.nas getActiveData get symbols, last id: ",s_symbol_id);
                    search = 0;
                }
            }
            targets_module_id[target_module_id]["symbols_path"] = symbol_path;
        } else {
            targets_module_id[target_module_id]["symbols_path"] = nil;
        }
        targets_module_id[target_module_id]["symbols_size"] = symbol_id - 1;
        
    } else {
        
        #// Is in multiplayer mode
        
        print("set_livery.nas getActiveData, read data from multiplayer id: ",target_module_id);
        
        if (size(targets_module_id) > 0) {
            idLivery = targets_module_id[target_module_id]["idLivery"];
            targets_module_id[target_module_id]["resolution_set"] = resolutionSet;
        }

    }

    print("set_livery.nas getActiveData setLivery  idLivery: ",targets_module_id[target_module_id]["idLivery"]);
    print("set_livery.nas getActiveData setLivery  target_module_id: ",targets_module_id[target_module_id]["target_module_id"]);
    print("set_livery.nas getActiveData setLivery  version: ",targets_module_id[target_module_id]["version"]);
    print("set_livery.nas getActiveData setLivery  name_short: ",targets_module_id[target_module_id]["name_short"]);
    print("set_livery.nas getActiveData setLivery  name_long: ",targets_module_id[target_module_id]["name_long"]);
    print("set_livery.nas getActiveData setLivery  livery_001: ",targets_module_id[target_module_id]["livery_001"]);
    print("set_livery.nas getActiveData setLivery  livery_002: ",targets_module_id[target_module_id]["livery_002"]);
    print("set_livery.nas getActiveData setLivery  dirty_001: ",targets_module_id[target_module_id]["dirty_001"]);
    print("set_livery.nas getActiveData setLivery  dirty_002: ",targets_module_id[target_module_id]["dirty_002"]);
    print("set_livery.nas getActiveData setLivery  PANR1: ",targets_module_id[target_module_id]["PANR1"]);
    print("set_livery.nas getActiveData setLivery  diffuse: ",targets_module_id[target_module_id]["diffuse"]);
    print("set_livery.nas getActiveData setLivery  specular: ",targets_module_id[target_module_id]["specular"]);
    print("set_livery.nas getActiveData setLivery  dirty_set: ",targets_module_id[target_module_id]["dirty_set"]);
    print("set_livery.nas getActiveData setLivery  normalmap_enabled: ",targets_module_id[target_module_id]["normalmap_enabled"]);
    print("set_livery.nas getActiveData setLivery  target_module_id: ",target_module_id);
    print("set_livery.nas getActiveData setLivery  resolutionSet: ",targets_module_id[target_module_id]["resolution_set"]);
    
    resolutionSetPrec = resolutionSet;
    id_prec = idLivery;
    
    createCanvas(target_module_id);
    setLivery(target_module_id);
    
};


setlistener("sim/G91/liveries/active/id", func() {
    var id = getprop("sim/G91/liveries/active/id");
    if (id == 0) {
        print("set_livery.nas setlistener error ID: ",id," MP: 0 the ID is forced to 1");
        setprop("sim/G91/liveries/active/id",1);
        id = 1;
    } elsif (id_prec != nil and id_prec != id) {
        if(setLivery_InExecution == 0) {
            print("set_livery.nas setlistener ID: ",id," is singleplayer mode");
            getActiveData(0, nil);
        } else {
            print("set_livery.nas setlistener ID: ",id," is singleplayer mode but stopped because setLivery_InExecution = 1");
        }
    }
}, 1, 1);


setlistener("sim/G91/liveries/active/dirty-set", func() {
    if (setLivery_InExecution == 0) {
        dirty_set = getprop("sim/G91/liveries/active/dirty-set");
        print("set_livery.nas setlistener dirty-set: ",dirty_set);
        if (dirty_set == 0) {
            setprop("sim/G91/liveries/active/dirty-set","0");
            setprop("sim/G91/liveries/active/dirty-Msg","Dirty inactive");
        } else {
            setprop("sim/G91/liveries/active/dirty-set","1");
            setprop("sim/G91/liveries/active/dirty-Msg","Dirty active");
        }
        getActiveData(0, dirty_set);
    }
}, 1, 1);


setlistener("sim/G91/liveries/active/normalmap_enabled", func() {
    if (setLivery_InExecution == 0) {
        normalmap_enabled = props.globals.getNode("sim/G91/liveries/active/normalmap_enabled",1).getValue();
        if (normalmap_enabled == 0) {
            setprop("sim/G91/liveries/active/normalmap_enabled-Msg","No normal map");
            print("set_livery.nas setLivery, normalmap_enabled-Msg: No normal map");
        } else {
            setprop("sim/G91/liveries/active/normalmap_enabled-Msg","Yes Normal map");
            print("set_livery.nas setLivery, normalmap_enabled-Msg: Yes Normal map");
        }
        print("set_livery.nas setlistener normalmap_enabled: ",normalmap_enabled);
    }
}, 1, 1);


setlistener("sim/G91/liveries/active/symbol_input_set_mod", func() {
    if (getprop("sim/G91/liveries/active/symbol_input_set_mod") > 0) {
        setprop("sim/G91/liveries/active/symbol_input_set_mod",0);
        targets_module_id[0]["lsc"].input_set_values();
    }
}, 1, 1);


setlistener("sim/G91/liveries/active/symbol_id_mod", func() {
    if (getprop("sim/G91/liveries/active/symbol_id_mod") > 0) {
        setprop("sim/G91/liveries/active/symbol_id_mod",0);
        targets_module_id[0]["lsc"].input_set_symbol_id();
    }
}, 1, 1);


var livery_multiplayer = maketimer(1, func() {
    target_module_id = getprop("sim/G91/liveries/active/set-target-module-id");
    if ((target_module_id != nil and isint(target_module_id)) or (target_module_id != nil and target_module_id == -1)) {
        var num_players = getprop("ai/models/num-players");
        if (num_players != nil) {
            if (num_players > 0) {
                setprop("sim/aircraft-is-singleplayer",0);
                var insert_targets_module_id = 0;
                if (target_module_id == -1) {
                    #// Is and update target_module_id
                    foreach(var tmId; keys(targets_module_id)) {
                        if (tmId > 0) {
                            var idLivery = targets_module_id[tmId]["idLivery"];
                            var node = props.globals.getNode(targets_path[tmId]);
                            var idNew = node.getNode("sim/G91/liveries/active/id").getValue();
                            if (idLivery != idNew) {
                                print("set_livery.nas livery_multiplayer timer update id: ",idNew, " is different old id: ",idLivery, " list dim: ",num_players);
                                target_module_id = tmId;
                                insert_targets_module_id = 2;
                            }
                        }
                    }
                } elsif (target_module_id > 0) {
                    targets_path[target_module_id] = getprop("sim/G91/liveries/active/set-target-path");
                    insert_targets_module_id = 1;
                    print("set_livery.nas livery_multiplayer timer insert new target_module_id: ",target_module_id, " list dim: ",num_players);
                }
                if (insert_targets_module_id >= 1 and target_module_id > 0) {
                    print("set_livery.nas livery_multiplayer timer insert data in targets_module_id with target_module_id: ",target_module_id);
                    var node = props.globals.getNode(targets_path[target_module_id]);
                    if (insert_targets_module_id == 1) {
                        targets_module_id[target_module_id] = {};
                        print("set_livery.nas livery_multiplayer timer insert data clear targets_module_id with target_module_id: ",target_module_id);
                    } else {
                        print("set_livery.nas livery_multiplayer timer insert data in targets_module_id with target_module_id: ",target_module_id);
                    }
                    targets_module_id[target_module_id]["target_module_id"] = target_module_id;
                    targets_module_id[target_module_id]["idLivery"] = node.getNode("sim/G91/liveries/active/id").getValue();
                    targets_module_id[target_module_id]["PANR1"] = node.getNode("sim/G91/liveries/active/PANR1").getValue();
                    targets_module_id[target_module_id]["version"] = node.getNode("sim/G91/liveries/active/version").getValue();
                    targets_module_id[target_module_id]["livery_001"] = node.getNode("sim/G91/liveries/active/livery_001").getValue();
                    targets_module_id[target_module_id]["livery_002"] = node.getNode("sim/G91/liveries/active/livery_002").getValue();
                    targets_module_id[target_module_id]["dirty_001"] = node.getNode("sim/G91/liveries/active/dirty_001").getValue();
                    targets_module_id[target_module_id]["dirty_002"] = node.getNode("sim/G91/liveries/active/dirty_002").getValue();
                    targets_module_id[target_module_id]["diffuse"] = node.getNode("sim/G91/liveries/active/diffuse").getValue();
                    targets_module_id[target_module_id]["specular"] = node.getNode("sim/G91/liveries/active/specular").getValue();
                    targets_module_id[target_module_id]["dirty_set"] = node.getNode("sim/G91/liveries/active/dirty_set").getValue();
                    targets_module_id[target_module_id]["normalmap_enabled"] = node.getNode("sim/G91/liveries/active/normalmap_enabled").getValue();
                    targets_module_id[target_module_id]["symbols_path"] = node.getNode("sim/G91/liveries/active/symbols_path").getValue();
                    targets_module_id[target_module_id]["symbol_01"] = node.getNode("sim/G91/liveries/active/symbol_01").getValue();
                    targets_module_id[target_module_id]["symbol_02"] = node.getNode("sim/G91/liveries/active/symbol_02").getValue();
                    targets_module_id[target_module_id]["symbol_03"] = node.getNode("sim/G91/liveries/active/symbol_03").getValue();
                    targets_module_id[target_module_id]["symbol_04"] = node.getNode("sim/G91/liveries/active/symbol_04").getValue();
                    targets_module_id[target_module_id]["symbol_05"] = node.getNode("sim/G91/liveries/active/symbol_05").getValue();
                    targets_module_id[target_module_id]["tacan_nav_active_state"] = node.getNode("sim/G91/liveries/active/tacan_nav_active_state").getValue();
                    targets_module_id[target_module_id]["recognition_gauges"] = node.getNode("sim/G91/liveries/active/recognition_gauges").getValue();
                    getActiveData(target_module_id, nil);
                }
            } else {
                setprop("sim/aircraft-is-singleplayer",1);
            }
        }
        setprop("sim/G91/liveries/active/set-target-module-id",-1);
    }
    var del_target_module_id = getprop("sim/G91/liveries/active/del-target-module-id");
    if (del_target_module_id != nil and isint(del_target_module_id) and del_target_module_id >= 0) {
        target_module_id = nil;
        delete(targets_module_id, del_target_module_id);
        delete(targets_path,del_target_module_id);
        print("set_livery.nas livery_multiplayer timer delete target_module_id: ",del_target_module_id," targets_module_id dim: ",size(targets_module_id));
        setprop("sim/G91/liveries/active/del-target-module-id",-1);
        var num_players = getprop("ai/models/num-players");
        if (num_players > 0) {
            setprop("sim/aircraft-is-singleplayer",0);
        } else {
            setprop("sim/aircraft-is-singleplayer",1);
        }
    }
});
livery_multiplayer.start();
