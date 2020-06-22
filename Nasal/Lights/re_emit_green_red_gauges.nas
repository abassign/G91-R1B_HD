# Calculate internal riemissive light re-emit by ambient lux

# ATTENZIONE: da togliere solo per compatibilita
var prop = props.globals.initNode("sim/G91/gauge_green_light_emission", 0, "DOUBLE");

# ATTENZIONE: da risistemare nell'impiantoelettrico illuminazione
var prop = props.globals.initNode("sim/G91/gauge_UV_light_spot_lamp_emission", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/gauge_red_spot_lamp_emission", 0, "DOUBLE");

var prop = props.globals.initNode("sim/G91/re_emit/gauge_phosphorescent_light", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_phosphorescent_light_10", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_phosphorescent_light_20", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_phosphorescent_light_30", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_phosphorescent_light_50", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_phosphorescent_light_70", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_phosphorescent_light_type_a", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_phosphorescent_light_type_b", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_phosphorescent_light_type_c", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_type_a_phosphorescent_light", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_type_b_phosphorescent_light", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_type_c_phosphorescent_light", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_10_phosphorescent_light", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_20_phosphorescent_light", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_30_phosphorescent_light", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_40_phosphorescent_light", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_50_phosphorescent_light", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_70_phosphorescent_light", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_100_phosphorescent_light", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_150_phosphorescent_light", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_emer_10_red_console", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_emer_20_red_console", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_emer_30_red_console", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_emer_40_red_console", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_emer_50_red_console", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_emer_70_red_console", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_emer_lamp_3200_console_red_05", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_emer_lamp_3200_console_green_05", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_emer_lamp_3200_console_blue_05", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_emer_lamp_3200_console_red_10", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_emer_lamp_3200_console_green_10", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_emer_lamp_3200_console_blue_10", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_emer_lamp_3200_console_red_20", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_emer_lamp_3200_console_green_20", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_emer_lamp_3200_console_blue_20", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_emer_lamp_3200_console_red_50", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_emer_lamp_3200_console_green_50", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_emer_lamp_3200_console_blue_50", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_console_3200_console_red_50", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_console_3200_console_green_50", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_console_3200_console_blue_50", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_light", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/light_red_console", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/light_panel", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_UV_light_on_red_light", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_red_light_on_UV_light", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/re_emit/gauge_spot_internal_red_light", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/light/lg_base", 0, "DOUBLE");

var timer_re_emit_green_red_gauges = maketimer(0.5, func() {

    var ambientBlueLight = props.globals.getNode("rendering/scene/ambient/blue",1).getValue();
    
    var correction_ambient = -29.7 * math.pow(ambientBlueLight,3) + 6.7 * math.pow(ambientBlueLight,2) - 1.29 * ambientBlueLight + 0.97;
    
    var red_type_a = props.globals.getNode("/sim/G91/lights/gauges/red_type_a",1).getValue();
    var green_type_a = props.globals.getNode("/sim/G91/lights/gauges/green_type_a",1).getValue();
    var yellow_type_a = props.globals.getNode("/sim/G91/lights/gauges/yellow_type_a",1).getValue();
    var red_type_b = props.globals.getNode("/sim/G91/lights/gauges/red_type_b",1).getValue();
    var green_type_b = props.globals.getNode("/sim/G91/lights/gauges/green_type_b",1).getValue();
    var yellow_type_b = props.globals.getNode("/sim/G91/lights/gauges/yellow_type_b",1).getValue();
    var red_type_c = props.globals.getNode("/sim/G91/lights/gauges/red_type_c",1).getValue();
    var green_type_c = props.globals.getNode("/sim/G91/lights/gauges/green_type_c",1).getValue();
    var yellow_type_c = props.globals.getNode("/sim/G91/lights/gauges/yellow_type_c",1).getValue();
    
    # Use for controlled light for example cabin advisor lights
    setprop("sim/G91/light/lg_base",correction_ambient * 0.15);
    
    var red_emer_instrument = correction_ambient * (getprop("/fdm/jsbsim/systems/lightning/light-red-emer-instrument")) * 1.2;
    if (red_emer_instrument <= 0.01) {
        red_emer_instrument = 0.01;
    } else if (red_emer_instrument > 1.0) {
        red_emer_instrument = 1.0;
    }
    
    setprop("sim/G91/re_emit/gauge_red_light",red_emer_instrument);
    setprop("sim/G91/re_emit/gauge_spot_internal_red_light",red_emer_instrument * 0.05);
    
    var light_red_console = correction_ambient * (getprop("/fdm/jsbsim/systems/lightning/light-red-console")) * 1.2;
    if (light_red_console <= 0.01) {
        light_red_console = 0.01;
    } else if (light_red_console > 1.0) {
        light_red_console = 1.0;
    }
    setprop("sim/G91/re_emit/light_red_console",light_red_console);

    pl_phosphorescent_emission = correction_ambient * (getprop("/fdm/jsbsim/systems/lightning/light-uv-instrument")) * 1.2;
    if (pl_phosphorescent_emission <= 0.1) {
        pl_phosphorescent_emission = 0.1;
    } else if (pl_phosphorescent_emission > 1.0) {
        pl_phosphorescent_emission = 1.0;
    }
    setprop("sim/G91/re_emit/gauge_phosphorescent_light",pl_phosphorescent_emission);
    
    setprop("sim/G91/re_emit/gauge_phosphorescent_light_10",pl_phosphorescent_emission * 0.1);
    setprop("sim/G91/re_emit/gauge_phosphorescent_light_20",pl_phosphorescent_emission * 0.2);
    setprop("sim/G91/re_emit/gauge_phosphorescent_light_30",pl_phosphorescent_emission * 0.3);
    setprop("sim/G91/re_emit/gauge_phosphorescent_light_50",pl_phosphorescent_emission * 0.5);
    setprop("sim/G91/re_emit/gauge_phosphorescent_light_70",pl_phosphorescent_emission * 0.7);
    setprop("sim/G91/re_emit/gauge_phosphorescent_light_type_a",pl_phosphorescent_emission * green_type_a);
    setprop("sim/G91/re_emit/gauge_phosphorescent_light_type_b",pl_phosphorescent_emission * green_type_b);
    setprop("sim/G91/re_emit/gauge_phosphorescent_light_type_c",pl_phosphorescent_emission * green_type_c);
    setprop("sim/G91/re_emit/gauge_UV_light_on_red_light",pl_phosphorescent_emission * 0.2);
    
    setprop("sim/G91/re_emit/gauge_red_20_phosphorescent_light",(red_emer_instrument * 0.2 * (1 - pl_phosphorescent_emission) + pl_phosphorescent_emission * 0.8));
    setprop("sim/G91/re_emit/gauge_red_30_phosphorescent_light",(red_emer_instrument * 0.3 * (1 - pl_phosphorescent_emission) + pl_phosphorescent_emission * 0.7));
    setprop("sim/G91/re_emit/gauge_red_40_phosphorescent_light",(red_emer_instrument * 0.4 * (1 - pl_phosphorescent_emission) + pl_phosphorescent_emission * 0.6));
    setprop("sim/G91/re_emit/gauge_red_50_phosphorescent_light",(red_emer_instrument * 0.5 * (1 - pl_phosphorescent_emission) + pl_phosphorescent_emission * 0.5));
    setprop("sim/G91/re_emit/gauge_red_70_phosphorescent_light",(red_emer_instrument * 0.7 * (1 - pl_phosphorescent_emission) + pl_phosphorescent_emission * 0.3));
    
    setprop("sim/G91/re_emit/gauge_red_emer_10_red_console",(red_emer_instrument * 0.1 * (1 - light_red_console * 0.5) + light_red_console));
    setprop("sim/G91/re_emit/gauge_red_emer_20_red_console",(red_emer_instrument * 0.2 * (1 - light_red_console * 0.5) + light_red_console));
    setprop("sim/G91/re_emit/gauge_red_emer_30_red_console",(red_emer_instrument * 0.3 * (1 - light_red_console * 0.5) + light_red_console));
    setprop("sim/G91/re_emit/gauge_red_emer_40_red_console",(red_emer_instrument * 0.4 * (1 - light_red_console * 0.5) + light_red_console));
    setprop("sim/G91/re_emit/gauge_red_emer_50_red_console",(red_emer_instrument * 0.5 * (1 - light_red_console * 0.5) + light_red_console));
    setprop("sim/G91/re_emit/gauge_red_emer_70_red_console",(red_emer_instrument * 0.7 * (1 - light_red_console * 0.5) + light_red_console));
    
    setprop("sim/G91/re_emit/gauge_red_emer_lamp_3200_console_red_05",(red_emer_instrument * (1 - light_red_console) * 0.05 + light_red_console * 0.5));
    setprop("sim/G91/re_emit/gauge_red_emer_lamp_3200_console_green_05",(red_emer_instrument * (1 - light_red_console) * 0.0125 + light_red_console * 0.4));
    setprop("sim/G91/re_emit/gauge_red_emer_lamp_3200_console_blue_05",(red_emer_instrument * (1 - light_red_console) * 0.0025 + light_red_console * 0.2));
    setprop("sim/G91/re_emit/gauge_red_emer_lamp_3200_console_red_10",(red_emer_instrument * (1 - light_red_console) * 0.1 + light_red_console * 0.5));
    setprop("sim/G91/re_emit/gauge_red_emer_lamp_3200_console_green_10",(red_emer_instrument * (1 - light_red_console) * 0.025 + light_red_console * 0.4));
    setprop("sim/G91/re_emit/gauge_red_emer_lamp_3200_console_blue_10",(red_emer_instrument * (1 - light_red_console) * 0.005 + light_red_console * 0.2));
    setprop("sim/G91/re_emit/gauge_red_emer_lamp_3200_console_red_20",(red_emer_instrument * (1 - light_red_console) * 0.2 + light_red_console * 0.5));
    setprop("sim/G91/re_emit/gauge_red_emer_lamp_3200_console_green_20",(red_emer_instrument * (1 - light_red_console) * 0.05 + light_red_console * 0.4));
    setprop("sim/G91/re_emit/gauge_red_emer_lamp_3200_console_blue_20",(red_emer_instrument * (1 - light_red_console) * 0.01 + light_red_console * 0.2));
    setprop("sim/G91/re_emit/gauge_red_emer_lamp_3200_console_red_50",(red_emer_instrument * (1 - light_red_console) * 0.5 + light_red_console * 0.5));
    setprop("sim/G91/re_emit/gauge_red_emer_lamp_3200_console_green_50",(red_emer_instrument * (1 - light_red_console) * 0.1 + light_red_console * 0.45));
    setprop("sim/G91/re_emit/gauge_red_emer_lamp_3200_console_blue_50",(red_emer_instrument * (1 - light_red_console) * 0.02 + light_red_console * 0.35));
    setprop("sim/G91/re_emit/gauge_console_lamp_3200_console_red_50",(light_red_console * (1 - light_red_console) * 0.5 + light_red_console * 0.5));
    setprop("sim/G91/re_emit/gauge_console_lamp_3200_console_green_50",(light_red_console * (1 - light_red_console) * 0.3 + light_red_console * 0.4));
    setprop("sim/G91/re_emit/gauge_console_lamp_3200_console_blue_50",(light_red_console * (1 - light_red_console) * 0.2 + light_red_console * 0.2));
    
    setprop("sim/G91/re_emit/gauge_red_100_phosphorescent_light",(red_emer_instrument + pl_phosphorescent_emission));
    setprop("sim/G91/re_emit/gauge_red_150_phosphorescent_light",(red_emer_instrument * 1.5 + pl_phosphorescent_emission));
    setprop("sim/G91/re_emit/gauge_red_type_a_phosphorescent_light",(red_emer_instrument * red_type_a + pl_phosphorescent_emission * yellow_type_a / ( 1 + red_emer_instrument)));
    setprop("sim/G91/re_emit/gauge_red_type_b_phosphorescent_light",(red_emer_instrument * red_type_b + pl_phosphorescent_emission * yellow_type_b / ( 1 + red_emer_instrument)));
    setprop("sim/G91/re_emit/gauge_red_type_c_phosphorescent_light",(red_emer_instrument * red_type_c + pl_phosphorescent_emission * yellow_type_c / ( 1 + red_emer_instrument)));
    setprop("sim/G91/re_emit/gauge_red_light_on_UV_light",red_emer_instrument * 0.2);
    
});
timer_re_emit_green_red_gauges.start();

