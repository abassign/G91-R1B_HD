# Calculate internal riemissive light re-emit by ambient lux

var prop = props.globals.initNode("sim/G91/ambient-data/irradiance_light_red", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/ambient-data/irradiance_light_green", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/ambient-data/irradiance_light_blue", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/ambient-data/irradiance_factor_prop", 0.3, "DOUBLE");

var timer_ambient_light = maketimer(0.5, func() {

    var ambientRedLight = props.globals.getNode("rendering/scene/ambient/red",1).getValue();
    var ambientGreenLight = props.globals.getNode("rendering/scene/ambient/green",1).getValue();
    var ambientBlueLight = props.globals.getNode("rendering/scene/ambient/blue",1).getValue();
    var irradiance_factor_prop = props.globals.getNode("sim/G91/ambient-data/irradiance_factor_prop",1).getValue();
    var irradiance_light_red = 0.0;
    var irradiance_light_green = 0.0;
    var irradiance_light_blue = 0.0;
    irradiance_light_red = 1-(-29.7 * math.pow(ambientRedLight,3) + 6.7 * math.pow(ambientRedLight,2) - 1.29 * ambientRedLight + 0.97);
    irradiance_light_green = 1-(-29.7 * math.pow(ambientGreenLight,3) + 6.7 * math.pow(ambientGreenLight,2) - 1.29 * ambientGreenLight + 0.97);
    irradiance_light_blue = 1-(-29.7 * math.pow(ambientBlueLight,3) + 6.7 * math.pow(ambientBlueLight,2) - 1.29 * ambientBlueLight + 0.97);
    setprop("sim/G91/ambient-data/irradiance_light_red",irradiance_light_red * irradiance_factor_prop);
    setprop("sim/G91/ambient-data/irradiance_light_green",irradiance_light_green * irradiance_factor_prop);
    setprop("sim/G91/ambient-data/irradiance_light_blue",irradiance_light_blue * irradiance_factor_prop);
    
});
timer_ambient_light.start();

