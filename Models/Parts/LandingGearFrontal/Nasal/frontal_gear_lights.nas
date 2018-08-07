# Calculate Positional light emission by ambient lux

var prop = props.globals.initNode("sim/G91/lightning/taxiing-light/intensity", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/lightning/landing-light/intensity", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/lightning/taxiing-light/intensity_effect", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/lightning/landing-light/intensity_effect", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/lightning/taxiing-light/intensity_bulb", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/lightning/landing-light/intensity_bulb", 0, "DOUBLE");

var timerFrontal_gear_lights = maketimer(0.1, func() {
    var taxiing_light = props.globals.getNode("fdm/jsbsim/systems/lightning/taxiing-light/intensity-norm",1).getValue();
    var landing_light = props.globals.getNode("fdm/jsbsim/systems/lightning/landing-light/intensity-norm",1).getValue();
    var ambientRedLight = props.globals.getNode("/rendering/scene/ambient/red",1).getValue();
    var pl_emission = 0.0;
    if (taxiing_light > 0.001) {
        pl_emission = -29.7 * math.pow(ambientRedLight,3) + 6.7 * math.pow(ambientRedLight,2) - 1.29 * ambientRedLight + 0.97;
        if (pl_emission >= 1.0) {
            pl_emission = 1.0;
        } else if (pl_emission <= 0.01) {
            pl_emission = 0.01;
        }
        setprop("sim/G91/lightning/taxiing-light/intensity",pl_emission * taxiing_light);
        setprop("sim/G91/lightning/taxiing-light/intensity_effect",pl_emission * 0.8 * taxiing_light);
        setprop("sim/G91/lightning/taxiing-light/intensity_bulb",0.3 + pl_emission * taxiing_light * 3.0);
        setprop("controls/lighting/taxi-light",1);
        setprop("controls/switches/taxi-lights",1);
    } else {
        setprop("sim/G91/lightning/taxiing-light/intensity",0);
        setprop("sim/G91/lightning/taxiing-light/intensity_effect",0);
        setprop("sim/G91/lightning/taxiing-light/intensity_bulb",0);
        setprop("controls/lighting/taxi-light",0);
        setprop("controls/switches/taxi-lights",0);
    }
    if (landing_light > 0.001) {
        pl_emission = -29.7 * math.pow(ambientRedLight,3) + 6.7 * math.pow(ambientRedLight,2) - 1.29 * ambientRedLight + 0.97;
        if (pl_emission >= 1.0) {
            pl_emission = 1.0;
        } else if (pl_emission <= 0.01) {
            pl_emission = 0.01;
        }
        setprop("sim/G91/lightning/landing-light/intensity",pl_emission * landing_light);
        setprop("sim/G91/lightning/landing-light/intensity_effect",pl_emission * 1.0 * landing_light);
        setprop("sim/G91/lightning/landing-light/intensity_bulb",0.3 + pl_emission * landing_light * 3.0);
        setprop("controls/lighting/landing-lights",1);
        setprop("controls/switches/landing-lights",1);
    } else {
        setprop("sim/G91/lightning/landing-light/intensity",0);
        setprop("sim/G91/lightning/landing-light/intensity_effect",0);
        setprop("sim/G91/lightning/landing-light/intensity_bulb",0);
        setprop("controls/lighting/landing-lights",0);
        setprop("controls/switches/landing-lights",0);
    }
});
timerFrontal_gear_lights.start(); 
