# Calculate Positional light emission by ambient lux

var prop = props.globals.initNode("sim/G91/frontal_gear_lights_emission", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/frontal_gear_light_glass_emission", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/frontal_gear_lights_emission_effect", 0, "DOUBLE");

var timerFrontal_gear_lights = maketimer(1, func() {
    var engineIsRunning = props.globals.getNode("/engines/engine/running",1);
    var ambientRedLight = props.globals.getNode("/rendering/scene/ambient/red",1);

    if (engineIsRunning.getValue()) {
        var pl_emission = 0.0;
        pl_emission = -29.7 * math.pow(ambientRedLight.getValue(),3) + 6.7 * math.pow(ambientRedLight.getValue(),2) - 1.29 * ambientRedLight.getValue() + 0.97;
        if (pl_emission >= 1.0) {
            pl_emission = 1.0;
        } else if (pl_emission <= 0.01) {
            pl_emission = 0.01;
        }
        setprop("sim/G91/frontal_gear_lights_emission",pl_emission);
        setprop("sim/G91/frontal_gear_light_glass_emission",pl_emission * 0.8);
        setprop("sim/G91/frontal_gear_lights_emission_effect",pl_emission * 0.64);
    } else {
        setprop("sim/G91/frontal_gear_lights_emission",0);
        setprop("sim/G91/frontal_gear_light_glass_emission",0);
        setprop("sim/G91/frontal_gear_lights_emission_effect",0);
    }
});
timerFrontal_gear_lights.start(); 
