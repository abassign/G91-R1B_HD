# Calculate Beacon light emission by ambient lux

var prop = props.globals.initNode("sim/G91/lightning/anticollision-light/intensity", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/lightning/anticollision-light/emission_cover", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/lightning/anticollision-light/intensity_effect", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/lightning/anticollision-light/intensity_mirror", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/lightning/anticollision-light/intensity_bulb", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/lightning/anticollision-light/transparent_cover", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/lightning/anticollision-light/transparent_glass", 0, "DOUBLE");

var anticollision_lights = maketimer(0.3, func() {
    var anticollision_light = props.globals.getNode("fdm/jsbsim/systems/lightning/anticollision/on",1).getValue();
    var ambientRedLight = props.globals.getNode("/rendering/scene/ambient/red",1).getValue();
    var pl_emission = 0.0;
    if (anticollision_light > 0.001) {
        pl_emission = -29.7 * math.pow(ambientRedLight,3) + 6.7 * math.pow(ambientRedLight,2) - 1.29 * ambientRedLight + 0.97;
        pl_emission_effect = 70 * math.pow(ambientRedLight,4) - 63 * math.pow(ambientRedLight,3) + 18 * math.pow(ambientRedLight,2) - 1.5 * ambientRedLight + 0.75;
        if (pl_emission >= 1.0) {
            pl_emission = 1.0;
        } else if (pl_emission <= 0.01) {
            pl_emission = 0.01;
        }
        setprop("sim/G91/lightning/anticollision-light/intensity",pl_emission * anticollision_light);
        setprop("sim/G91/lightning/anticollision-light/emission_cover",pl_emission * anticollision_light);
        setprop("sim/G91/lightning/anticollision-light/intensity_effect", pl_emission_effect * anticollision_light * 0.5);
        setprop("sim/G91/lightning/anticollision-light/intensity_mirror",0.3 + pl_emission * anticollision_light);
        setprop("sim/G91/lightning/anticollision-light/intensity_bulb",0.3 + pl_emission * anticollision_light * 3.0);
        setprop("sim/G91/lightning/anticollision-light/transparent_cover", 1 - pl_emission / 4);
        setprop("sim/G91/lightning/anticollision-light/transparent_glass", 1 - pl_emission);
    } else {
        setprop("sim/G91/lightning/anticollision-light/intensity",0);
        setprop("sim/G91/lightning/anticollision-light/emission_cover",0);
        setprop("sim/G91/lightning/anticollision-light/intensity_effect",0);
        setprop("sim/G91/lightning/anticollision-light/intensity_mirror",0);
        setprop("sim/G91/lightning/anticollision-light/intensity_bulb",0);
        setprop("sim/G91/lightning/anticollision-light/transparent_cover",1.0);
        setprop("sim/G91/lightning/anticollision-light/transparent_glass", 1);
    }
});
anticollision_lights.start(); 
