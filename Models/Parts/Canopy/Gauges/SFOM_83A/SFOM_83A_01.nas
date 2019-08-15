var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/button", 126, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/inclination", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/isLightActive", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/collimatorLight", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/alpha", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/collimator_red", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/collimator_green", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge/SFOM_83A/collimator_blue", 0, "DOUBLE");

var viewInternal = 0;
var valButton = 0;
var xOffset0 = 0;
var xOffset = 0;
var xOffset_prec = 0;
var yOffset0 = 0;
var yOffset = 0;
var yOffset_prec = 0;

sfom83A_canvas = canvas.new({"name": "SFOM83A_canvas_Collimator_glass_TargetDOWN",
                    "size": [512,512], 
                    "view": [512,690],
                    "mipmapping": 1});
sfom83A_canvas.name = "SFOM83A_canvas_Collimator_glass_TargetDOWN";
sfom83A_canvas.addPlacement({"node": "Collimator_glass_TargetDOWN"});
sfom83A_canvas.setColorBackground(0.0, 0.1, 0.0, 0.2);
sfom83A_root = sfom83A_canvas.createGroup();
sfom83A_path = "Aircraft/G91-R1B_HD/Models/Parts/Canopy/Gauges/SFOM_83A/SFOM_83A_03_Cross_1024.png";
sfom83A_child = sfom83A_root.createChild("image")
        .setFile(sfom83A_path)
        .setTranslation(0,0)
        .setSize(384,384);

var setCross = func() {
    sfom83A_child.setTranslation(xOffset * 10000.0 + 67.0, (0.8 - yOffset) * 11000.0 + valButton);
}

var color_cross_SFOM83A = func() {
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

}

setlistener("sim/G91/gauge/SFOM_83A/button", func {
    if (viewInternal == 1) {
        valButton = props.globals.getNode("sim/G91/gauge/SFOM_83A/button",1).getValue();
        call(setCross,[]);
    }
}, 1, 1);

setlistener("sim/current-view/x-offset-m", func {
    if (viewInternal == 1) {
        xOffset = xOffset0 - props.globals.getNode("sim/current-view/x-offset-m",1).getValue();
        if (math.abs(xOffset - xOffset_prec) > 0.0001) {
            xOffset_prec = xOffset;
            valButton = props.globals.getNode("sim/G91/gauge/SFOM_83A/button",1).getValue();
            yOffset = yOffset0 - props.globals.getNode("sim/current-view/y-offset-m",1).getValue();
            call(setCross,[]);
        }
    }
}, 1, 1);

setlistener("sim/current-view/y-offset-m", func {
    if (viewInternal == 1) {
        yOffset = yOffset0 - props.globals.getNode("sim/current-view/y-offset-m",1).getValue();
        if (math.abs(yOffset - yOffset_prec) > 0.0001) {
            yOffset_prec = yOffset;
            valButton = props.globals.getNode("sim/G91/gauge/SFOM_83A/button",1).getValue();
            xOffset = xOffset0 - props.globals.getNode("sim/current-view/x-offset-m",1).getValue();
            call(setCross,[]);
        }
    }
}, 1, 1);

var display_SFOM83A = maketimer(0.3, func() {
    viewInternal = props.globals.getNode("sim/current-view/internal",1).getValue();
    if (viewInternal == 1) {
        xOffset0 = string.trim(props.globals.getNode("sim/view/config/x-offset-m",1).getValue());
        yOffset0 = string.trim(props.globals.getNode("sim/view/config/y-offset-m",1).getValue());
        valButton = props.globals.getNode("sim/G91/gauge/SFOM_83A/button",1).getValue();
        call(setCross,[]);
        call(color_cross_SFOM83A,[]);
    }
});
display_SFOM83A.start();
