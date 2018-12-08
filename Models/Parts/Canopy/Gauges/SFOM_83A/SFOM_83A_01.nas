var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/button", 60, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/inclination", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/isLightActive", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/collimatorLight", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/alpha", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/collimator_red", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/collimator_green", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/collimator_blue", 0, "DOUBLE");

sfom83A_canvas = canvas.new({"name": "SFOM83A_canvas_Collimator_glass_TargetDOWN",
                    "size": [512,512], 
                    "view": [512,690],
                    "mipmapping": 1});
sfom83A_canvas.name = "SFOM83A_canvas_Collimator_glass_TargetDOWN";
sfom83A_canvas.addPlacement({"node": "Collimator_glass_TargetDOWN"});
sfom83A_canvas.setColorBackground(0.0, 0.1, 0.0, 0.2);
sfom83A_root = sfom83A_canvas.createGroup();
sfom83A_path = "Aircraft/G91-R1B_HD/Models/Parts/Canopy/Gauges/SFOM_83A/SFOM_83A_01_Cross.png";
sfom83A_child = sfom83A_root.createChild("image")
        .setFile(sfom83A_path)
        .setTranslation(0,0)
        .setSize(512,512);

setlistener("/sim/G91/gauge/SFOM_83A/button", func {
    var valButton = props.globals.getNode("/sim/G91/gauge/SFOM_83A/button",1).getValue();
    child.setTranslation(0,valButton);
}, 1, 0);

var color_cross_SFOM83A = maketimer(0.1, func() {
    var lightIntesity = props.globals.getNode("fdm/jsbsim/systems/electric/bus[1]/collimator-lighting/sw",1).getValue();
    var ambientRedLight = 0.0;
    var ambientGreenLight = 0.0;
    var ambientBlueLight = 0.0;
    var sun_angular_deg = props.globals.getNode("sim/G91/ambient-data/sun-angular-deg",1).getValue();
    var sun_direct_Light = 0.25 + math.pow((1 - sun_angular_deg * 0.01745 / 3.1428),2) * 0.75;
    ambientRedLight = props.globals.getNode("rendering/scene/chrome-light/red",1).getValue();
    ambientGreenLight = props.globals.getNode("rendering/scene/chrome-light/green",1).getValue();
    ambientBlueLight = props.globals.getNode("rendering/scene/chrome-light/blue",1).getValue() * 1.05;
    var collimatorLight = (ambientRedLight + ambientGreenLight + ambientBlueLight) / 3;
    whiteLight_sun = collimatorLight * (1 + sun_direct_Light) / 4.0;
    if (lightIntesity <= 0.01) {
        setprop("sim/G91/gauge/SFOM_83A/isLightActive", 0);
    } else {
        setprop("sim/G91/gauge/SFOM_83A/isLightActive", 1);
        var lightIntesityBattery = props.globals.getNode("fdm/jsbsim/systems/warning-lights/light-intensity-by-bus1-tension",1).getValue();
        var lightIntesityFuse = props.globals.getNode("fdm/jsbsim/systems/electric/bus[1]/collimator-lighting/fuse",1).getValue();
        setprop("fdm/jsbsim/systems/electric/bus[1]/collimator-lighting/I",0.2 * lightIntesityBattery * lightIntesityFuse * lightIntesity);
        lightIntesity = lightIntesity * 0.6 * lightIntesityBattery * lightIntesityFuse;
        ambientRedLight = 1.0;
        ambientGreenLight = 0.5;
        ambientBlueLight = 0.0;
        whiteLight_sun = lightIntesity - whiteLight_sun * 0.9;
    }
    setprop("sim/G91/gauge/SFOM_83A/alpha", whiteLight_sun);
    setprop("sim/G91/gauge/SFOM_83A/collimatorLight", collimatorLight);
    setprop("sim/G91/gauge/SFOM_83A/collimator_red",ambientRedLight);
    setprop("sim/G91/gauge/SFOM_83A/collimator_green",ambientGreenLight);
    setprop("sim/G91/gauge/SFOM_83A/collimator_blue",ambientBlueLight);

});
color_cross_SFOM83A.start();
