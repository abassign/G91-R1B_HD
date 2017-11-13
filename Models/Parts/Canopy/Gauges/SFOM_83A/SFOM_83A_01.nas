var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/button", 60, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/isLightActive", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/lightValue", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/whiteLight", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/collimator_red", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/collimator_green", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/collimator_blue", 0, "DOUBLE");

sfom83A_canvas = canvas.new({"name": "SFOM83A_canvas_Collimator_glass_TargetDOWN",
                    "size": [512,512], 
                    "view": [512,690],
                    "mipmapping": 1});
sfom83A_canvas.name = "SFOM83A_canvas_Collimator_glass_TargetDOWN";
sfom83A_canvas.addPlacement({"node": "Collimator_glass_TargetDOWN"});
sfom83A_canvas.setColorBackground(0.0, 0.0, 0.0, 0.0);
var root = sfom83A_canvas.createGroup();
var path = "Aircraft/G91/Models/Parts/Canopy/Gauges/SFOM_83A/SFOM_83A_01_Cross.png";
var child = root.createChild("image")
        .setFile( path )
        .setTranslation(0,0)
        .setSize(512,512);

setlistener("/sim/G91/gauge/SFOM_83A/button", func {
    var valButton = props.globals.getNode("/sim/G91/gauge/SFOM_83A/button",1).getValue();
    child.setTranslation(0,valButton);
}, 1, 0);

var color_cross_SFOM83A = maketimer(0.1, func() {
    var ambientRedLight = props.globals.getNode("rendering/scene/ambient/red",1).getValue();
    var ambientGreenLight = props.globals.getNode("rendering/scene/ambient/green",1).getValue();
    var ambientBlueLight = props.globals.getNode("rendering/scene/ambient/blue",1).getValue();
    var internalRedLight = props.globals.getNode("sim/G91/re_emit/gauge_red_light",1).getValue();
    var orientationHeading = props.globals.getNode("orientation/heading-deg",1).getValue();
    ambientRedLight = ambientRedLight + internalRedLight;
    ambientGreenLight = ambientGreenLight + internalRedLight * 0.5;
    setprop("sim/G91/gauge/SFOM_83A/collimator_red",ambientRedLight);
    setprop("sim/G91/gauge/SFOM_83A/collimator_green",ambientGreenLight);
    setprop("sim/G91/gauge/SFOM_83A/collimator_blue",ambientBlueLight);
    var sun_angular_deg = props.globals.getNode("sim/G91/ambient-data/sun-angular-deg",1).getValue();
    var white_Light = 0.3 + (1 - sun_angular_deg * 0.005555);
    setprop("sim/G91/gauge/SFOM_83A/whiteLight",white_Light);
});
color_cross_SFOM83A.start();
