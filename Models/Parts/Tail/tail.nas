# From: http://wiki.flightgear.org/Howto:Dynamic_Liveries_via_Canvas

var path="Aircraft/G91-R1B_HD/Models/Liveries/";

ca = canvas.new({"name": "Tail_A__G91_fuselage_coda",
                    "size": [1024,1024], 
                    "view": [1024,1024],
                    "mipmapping": 1});
ca.addPlacement({"node": "A__G91_fuselage_coda.002"});
ca.addPlacement({"node": "A__G91_fuselage_coda.006"});
ca_root = ca.createGroup();
ca_child = ca_root.createChild("image")
    .setFile(path~'Livery_PAN_01.png')
    .setSize(1024,1024);
    

    

