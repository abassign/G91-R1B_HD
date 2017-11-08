# Calculate Positional light emission by ambient lux

var prop = props.globals.initNode("sim/G91/position_light_emission", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/position_light_glass_emission", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/position_light_transparent", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/position_light_emission_effect", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/position_light_emission_effect_white", 0, "DOUBLE");

var timerPosition_light_emission = maketimer(1, func() {
    var engineIsRunning = props.globals.getNode("engines/engine/running",1);
    var ambientRedLight = props.globals.getNode("/rendering/scene/ambient/red",1);

    if (engineIsRunning.getValue()) {
        var pl_emission = 0.0;
        var pl_glass_emission = 0.0;
        var pl_transparent = 0.8;
        pl_emission = -29.7 * math.pow(ambientRedLight.getValue(),3) + 6.7 * math.pow(ambientRedLight.getValue(),2) - 1.29 * ambientRedLight.getValue() + 0.97;
        if (pl_emission >= 1) {
            pl_emission = 1;
        } else if (pl_emission <= 0.01) {
            pl_emission = 0.01;
        }
        pl_glass_emission = pl_emission * 0.9;
        setprop("sim/G91/position_light_emission",pl_emission);
        setprop("sim/G91/position_light_glass_emission",pl_glass_emission);
        setprop("sim/G91/position_light_transparent",pl_transparent);
        setprop("sim/G91/position_light_emission_effect",pl_glass_emission * 0.5);
        setprop("sim/G91/position_light_emission_effect_white",pl_glass_emission * 0.6);
    } else {
        setprop("sim/G91/position_light_emission",0);
        setprop("sim/G91/position_light_glass_emission",0);
        setprop("sim/G91/position_light_transparent",0);
        setprop("sim/G91/position_light_emission_effect",0);
        setprop("sim/G91/position_light_emission_effect_white",0);
    }
});
timerPosition_light_emission.start();

