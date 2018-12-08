# From: http://wiki.flightgear.org/Howto:Dynamic_Liveries_via_Canvas

var id_prec = 0;

ca = canvas.new({"name": "Fuselage",
                    "size": [6144,6144], 
                    "view": [6144,6144],
                    "mipmapping": 1});
                    
# Wing
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
ca.addPlacement({"node": "A_antenna_cover"});
ca.addPlacement({"node": "panR1b__G91_fuselage_muso_1.024"});
ca.addPlacement({"node": "A_antenna_cover"});

# Fuselage B0
ca.addPlacement({"node": "A__G91_fuselage_weapon_door_dx.003"});
ca.addPlacement({"node": "A__G91_fuselage_weapon_door_sx.003"});

# Airbrake
ca.addPlacement({"node": "C00_dx_airbrake_door.002"});
ca.addPlacement({"node": "C00_sx_airbrake_door.004"});

# Landing gear frontal
ca.addPlacement({"node": "PlanLight.front.001"});
ca.addPlacement({"node": "gear_door_sx.000"});
ca.addPlacement({"node": "gear_door_dx.001"});

ca_root = ca.createGroup();

var layers_001 = {};

cw = canvas.new({"name": "Wing",
                    "size": [6144,6144], 
                    "view": [6144,6144],
                    "mipmapping": 1});

# Wing                    
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

# Tail
cw.addPlacement({"node": "D_wing_sx_.001"});
cw.addPlacement({"node": "D_wing_sx.000"});
cw.addPlacement({"node": "D_wing_dx_.000"});
cw.addPlacement({"node": "D_wing_dx.007"});
cw.addPlacement({"node": "D_equilibratore_dx"});
cw.addPlacement({"node": "D_equilibratore_sx.002"});

cw_root = cw.createGroup();

var layers_002 = {};

setlistener("sim/G91/liveries/active/ID", func {

    var idSelect = props.globals.getNode("sim/G91/liveries/active/ID",1).getValue();
    var isPushed = props.globals.getNode("sim/G91/liveries/active/pushed",1).getValue();
    var liverys = props.globals.getNode("sim/G91/liveries").getChildren("livery");
    
    if (isPushed == nil) {
        isPushed = 0;
    }
    
    if (isPushed > 0 and id_prec > 0) {
        forindex(i; liverys) {
            if (liverys[i].getNode("ID").getValue() == id_prec) {
                print("*1 isPushed: ", i," v: ",debug.dump(liverys[i].getNode("luminosity")));
                liverys[i].getNode("luminosity").setValue(props.globals.getNode("sim/G91/liveries/active/luminosity",1).getValue());
                liverys[i].getNode("reflective").setValue(props.globals.getNode("sim/G91/liveries/active/reflective",1).getValue());
                liverys[i].getNode("diffuse").setValue(props.globals.getNode("sim/G91/liveries/active/diffuse",1).getValue());
                liverys[i].getNode("specular").setValue(props.globals.getNode("sim/G91/liveries/active/specular",1).getValue());
                liverys[i].getNode("dirty").setValue(props.globals.getNode("sim/G91/liveries/active/dirty",1).getValue());
                ## print("*2 isPushed: ", i," v: ",debug.dump(liverys[i].getNode("luminosity")));
                break;
            }
        }
    }
    
    var id = -1;
    forindex(i; liverys) {
        if (liverys[i].getNode("ID").getValue() == idSelect) {
            id = i;
            break;
        }
    }
    if (id == -1) {
        id = 0;
        print("G91:ERROR: set_livery.nas id not found, set default id=0");
    }
    
    var livery_001 = liverys[id].getNode("livery_001").getValue();
    var livery_002 = liverys[id].getNode("livery_002").getValue();
    var dirty_001 = liverys[id].getNode("dirty_001").getValue();
    var dirty_002 = liverys[id].getNode("dirty_002",).getValue();
    var name_short = liverys[id].getNode("name_short").getValue();
    var name_long = liverys[id].getNode("name_long").getValue();
    var luminosity = liverys[id].getNode("luminosity").getValue();
    var reflective = liverys[id].getNode("reflective").getValue();
    var PANR1 = liverys[id].getNode("PANR1").getValue();
    var diffuse = liverys[id].getNode("diffuse").getValue();
    var specular = liverys[id].getNode("specular").getValue();
    var dirty = liverys[id].getNode("dirty").getValue();
    
    print("set_livery.nas id: ",id," livery_001: ",livery_001," livery_002: ",livery_002);
    
    setprop("sim/G91/liveries/active/name_short",name_short);
    setprop("sim/G91/liveries/active/name_long",name_long);
    setprop("sim/G91/liveries/active/livery_001",livery_001);
    setprop("sim/G91/liveries/active/livery_002",livery_002);
    setprop("sim/G91/liveries/active/dirty_001",dirty_001);
    setprop("sim/G91/liveries/active/dirty_002",dirty_002);
    setprop("sim/G91/liveries/active/luminosity",luminosity);
    setprop("sim/G91/liveries/active/reflective",reflective);
    setprop("sim/G91/liveries/active/PANR1",PANR1);
    setprop("sim/G91/liveries/active/ambient",diffuse);
    setprop("sim/G91/liveries/active/specular",specular);
    setprop("sim/G91/liveries/active/dirty",dirty);
    setprop("sim/G91/liveries/active/ID",idSelect);
    setprop("sim/G91/liveries/active/pushed",0.0);
    
    foreach(var image; [livery_001, dirty_001]) {
        print("set_livery.nas image: ",image," (",size(image),")");
        # Insert the layer
        if (size(image) > 0) {
            layers_001[image] = ca_root.createChild("image")
                .setFile(image)
                .setSize(6144,6144);
            if(image == dirty_001) {
                if (dirty > 0.1) {
                    print("set_livery.nas dirty show: ",dirty_001);
                    layers_001[image].show();
                } else {
                    print("set_livery.nas dirty hide: ",dirty_001);
                    layers_001[image].hide();
                }
            }
        }
    }

    print("set_livery.nas livery_002: ",livery_002);
    
    foreach(var image; [livery_002, dirty_002]) {
        print("set_livery.nas image: ",image," (",size(image),")");
        # Insert the layer
        if (size(image) > 0) {
            layers_002[image] = cw_root.createChild("image")
                .setFile(image)
                .setSize(6144,6144);
            if(image == dirty_002) {
                if (dirty > 0.1) {
                    print("set_livery.nas dirty show: ",dirty_002);
                    layers_002[image].show();
                } else {
                    print("set_livery.nas dirty hide: ",dirty_002);
                    layers_002[image].hide();
                }
            }
        }
    }
    
    id_prec = idSelect;
    
}, 1, 1);

