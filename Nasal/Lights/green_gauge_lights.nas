# Calculate Positional light emission by ambient lux

var prop = props.globals.initNode("sim/G91/gauge_green_light_emission", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge_UV_light_spot_lamp_emission", 0, "DOUBLE");

var timerGgauge_green_light_emission = maketimer(0.5, func() {
    var ambientRedLight = props.globals.getNode("/rendering/scene/ambient/red",1);
    var pl_emission = 0.0;
    var pl_glass_emission = 0.0;
    var pl_transparent = 0.8;
    pl_emission = -29.7 * math.pow(ambientRedLight.getValue(),3) + 6.7 * math.pow(ambientRedLight.getValue(),2) - 1.29 * ambientRedLight.getValue() + 0.97;
    pl_emission = pl_emission * (getprop("sim/G91/gauge_UV_light_spot_lamp_emission"));
    if (pl_emission <= 0.1) {
        pl_emission = 0.1;
    }
    pl_glass_emission = pl_emission * 0.9;
    setprop("sim/G91/gauge_green_light_emission",pl_emission);
});
timerGgauge_green_light_emission.start();

