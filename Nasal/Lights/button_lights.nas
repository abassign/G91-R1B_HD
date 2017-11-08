# Calculate Positional light emission by ambient lux for button lights

var prop = props.globals.initNode("sim/G91/gauge_button_lights/transparent_alpha", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge_button_lights/light_emission", 0, "DOUBLE");

var timerGgauge_button_lights = maketimer(0.5, func() {
    var ambientRedLight = props.globals.getNode("/rendering/scene/ambient/red",1);
    var pl_emission = 0.0;
    var pl_transparent = 0.0;
    pl_emission = -29.7 * math.pow(ambientRedLight.getValue(),3) + 6.7 * math.pow(ambientRedLight.getValue(),2) - 1.29 * ambientRedLight.getValue() + 0.97;
    pl_emission = pl_emission * (getprop("sim/G91/re_emit/gauge_red_light"));
    if (pl_emission <= 0.01) {
        pl_emission = 0.01;
    } else if (pl_emission > 1) {
        pl_emission = 1;
    }
    pl_transparent = ambientRedLight.getValue() * 5;
    setprop("sim/G91/gauge_button_lights/light_emission",pl_emission);
    setprop("sim/G91/gauge_button_lights/transparent_alpha",pl_transparent);
});
timerGgauge_button_lights.start();

