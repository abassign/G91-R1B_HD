# From: http://wiki.flightgear.org/Howto:Dynamic_Liveries_via_Canvas

var path="Aircraft/G91-R1B_HD/Models/Liveries/";

c1 = canvas.new({"name": "Fuselage_B__G91_fuselage_weapon_door_dx.001",
                    "size": [1024,1024], 
                    "view": [1024,1024],
                    "mipmapping": 1});
c1.addPlacement({"node": "A__G91_fuselage_weapon_door_dx.001"});
c1.addPlacement({"node": "A__G91_fuselage_weapon_door_sx.001"});
c1_root = c1.createGroup();
c1_child = c1_root.createChild("image")
    .setFile(path~'Livery_PAN_01.png')
    .setSize(1024,1024)
    .setTranslation(-2.5,-1);


