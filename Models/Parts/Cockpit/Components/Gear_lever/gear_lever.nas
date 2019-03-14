var prop = props.globals.initNode("sim/G91/landingGear/landingGearHandle_deg_Z", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/landingGear/landingGearHandle_light", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/landingGear/landingGearHandle_light_transparent", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/landingGear/landingGearHandle_light_blow", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/landingGear/landingGearHandle_shell_transparent", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/landingGear/landingGearHandle_sound", 0, "DOUBLE");

var landingGearFunctions = maketimer(0.1, func() {
    var speedHandle = 0.02;
    var lenghtHarm = 0.15;
    var offsetLight = 0.06;
    var landingGearHandle_deg = props.globals.getNode("fdm/jsbsim/gear/gear-pos-norm",1).getValue();
    var direction = props.globals.getNode("fdm/jsbsim/gear/gear-direction",1).getValue();
    var lightOn = 0;

    if (direction == 1) {
        lightOn = 1;
        setprop("sim/G91/landingGear/landingGearHandle_deg", landingGearHandle_deg);
        setprop("sim/G91/landingGear/landingGearHandle_deg_Z", offsetLight - math.sin(landingGearHandle_deg) * lenghtHarm);
    } else if (direction == -1) {
        lightOn = 1;
        setprop("sim/G91/landingGear/landingGearHandle_deg", landingGearHandle_deg);
        setprop("sim/G91/landingGear/landingGearHandle_deg_Z", offsetLight - math.sin(landingGearHandle_deg) * lenghtHarm);
    }
    
    if (lightOn == 1) {
        var redLightBlowIntensity = props.globals.getNode("sim/G91/light/lg_base",1).getValue();
        redLightBlowIntensity = redLightBlowIntensity * 1.2;
        setprop("sim/G91/landingGear/landingGearHandle_light_blow", redLightBlowIntensity);
        setprop("sim/G91/landingGear/landingGearHandle_shell_transparent",1);
    } else {
        setprop("sim/G91/landingGear/landingGearHandle_light_blow", 0);
        setprop("sim/G91/landingGear/landingGearHandle_shell_transparent",0.2);
    }
    
    # Gear_lever light light_emission
    if (direction == 0) {
        var lightEmission = props.globals.getNode("sim/G91/re_emit/gauge_red_light",1).getValue();
        setprop("sim/G91/landingGear/landingGearHandle_light", lightEmission * 0.2);
        setprop("sim/G91/landingGear/landingGearHandle_light_transparent", 0.90);
    } else {
        var lightEmission = props.globals.getNode("sim/G91/gauge_button_lights/light_emission",1).getValue();
        setprop("sim/G91/landingGear/landingGearHandle_light", 1);
        setprop("sim/G91/landingGear/landingGearHandle_light_transparent", 0.90);
    }
});

landingGearFunctions.start();
