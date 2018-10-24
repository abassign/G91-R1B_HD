# Calculate internal riemissive light re-emit by ambient lux

# ATTENZIONE: da togliere solo per compatibilita
var prop = props.globals.initNode("sim/G91/gauge_green_light_emission", 0, "DOUBLE");

# ATTENZIONE: da risistemare nell'impiantoelettrico illuminazione
var prop = props.globals.initNode("sim/G91/gauge_UV_light_spot_lamp_emission", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge_red_spot_lamp_emission", 0, "DOUBLE");


var prop = props.globals.initNode("sim/G91/re_emit/gauge_phosphorescent_light", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_light", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_spot_internal_red_light", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/light/lg_base", 0, "DOUBLE");

var timer_re_emit_green_red_gauges = maketimer(0.5, func() {

    var ambientBlueLight = props.globals.getNode("rendering/scene/ambient/blue",1).getValue();
    var bus_primary_V = props.globals.getNode("fdm/jsbsim/systems/electric/bus[1]/V",1).getValue();
    var light_by_tension_bus = bus_primary_V / 24.0;
    var pl_emission = -29.7 * math.pow(ambientBlueLight,3) + 6.7 * math.pow(ambientBlueLight,2) - 1.29 * ambientBlueLight + 0.97;
    
    # Use for controlled light for example cabin advisor lights
    setprop("sim/G91/light/lg_base",pl_emission * 0.15 * light_by_tension_bus);
    
    pl_emission = pl_emission * (getprop("sim/G91/gauge_red_spot_lamp_emission")) * 1.2;
    if (pl_emission <= 0.01) {
        pl_emission = 0.01;
    } else if (pl_emission > 1.0) {
        pl_emission = 1.0;
    }
    setprop("sim/G91/re_emit/gauge_red_light",pl_emission * light_by_tension_bus);
    setprop("sim/G91/re_emit/gauge_spot_internal_red_light",pl_emission * 0.05 * light_by_tension_bus);
    
    var ambientBlueLight = props.globals.getNode("rendering/scene/ambient/blue",1).getValue();
    var pl_phosphorescent_emission = 0.0;
    pl_phosphorescent_emission = -29.7 * math.pow(ambientBlueLight,3) + 6.7 * math.pow(ambientBlueLight,2) - 1.29 * ambientBlueLight + 0.97;
    pl_phosphorescent_emission = pl_phosphorescent_emission * (getprop("sim/G91/gauge_UV_light_spot_lamp_emission")) * 1.2;
    if (pl_phosphorescent_emission <= 0.1) {
        pl_phosphorescent_emission = 0.1;
    } else if (pl_phosphorescent_emission > 1.0) {
        pl_phosphorescent_emission = 1.0;
    }
    setprop("sim/G91/re_emit/gauge_phosphorescent_light",pl_phosphorescent_emission * light_by_tension_bus);
   
});
timer_re_emit_green_red_gauges.start();

