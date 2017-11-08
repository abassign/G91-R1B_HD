var prop = props.globals.initNode("/sim/G91/gauge/SFOM_83A/button", 512, "DOUBLE");
var prop = props.globals.initNode("/sim/G91/gauge/SFOM_83A/isLightActive", 0, "DOUBLE");
var prop = props.globals.initNode("/sim/G91/gauge/SFOM_83A/lightValue", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/whiteLight", 0, "DOUBLE");

sfom83A_canvas = canvas.new({"name": "SFOM83A_canvas_Collimator_glass_TargetDOWN",
                    "size": [1024,1024], 
                    "view": [1024,1380],
                    "mipmapping": 1});
sfom83A_canvas.name = "SFOM83A_canvas_Collimator_glass_TargetDOWN";
sfom83A_canvas.addPlacement({"node": "Collimator_glass_TargetDOWN"});
sfom83A_canvas.setColorBackground(0.0, 0.0, 0.0, 0.0);
var root = sfom83A_canvas.createGroup();
var path = "Aircraft/G91/Models/Parts/Canopy/Gauges/SFOM_83A/SFOM_83A_01_512.png";
var child = root.createChild("image")
        .setFile( path )
        .setTranslation(256,512)
        .setSize(512,512);

setlistener("/sim/G91/gauge/SFOM_83A/button", func {
    var valButton = props.globals.getNode("/sim/G91/gauge/SFOM_83A/button",1).getValue();
    child.setTranslation(256,valButton);
}, 1, 0);

var color_cross_SFOM83A = maketimer(0.1, func() {
    var ambientBlueLight = props.globals.getNode("rendering/scene/ambient/blue",1).getValue();
    setprop("sim/G91/gauge/SFOM_83A/whiteLight",ambientBlueLight * 0.7);
});
color_cross_SFOM83A.start();
