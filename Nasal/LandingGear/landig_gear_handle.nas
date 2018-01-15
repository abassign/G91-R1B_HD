var prop = props.globals.initNode("sim/G91/landingGear/landingGear_0_deg", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/landingGear/landingGear_1_deg", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/landingGear/landingGear_2_deg", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/landingGear/landingGear_0_status", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/landingGear/landingGear_1_status", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/landingGear/landingGear_2_status", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/landingGear/landingGearHandle_deg", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/landingGear/landingGearHandle_deg_Z", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/landingGear/landingGearHandle_Start", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/landingGear/landingGearHandle_Direction", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/landingGear/landingGearHandle_light", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/landingGear/landingGearHandle_light_transparent", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/landingGear/landingGearHandle_light_blow", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/landingGear/landingGearHandle_shell_transparent", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/landingGear/landingGearHandle_sound", 0, "DOUBLE");

setlistener("sim/G91/landingGear/landingGearHandle_Start", func {
    var direction = props.globals.getNode("sim/G91/landingGear/landingGearHandle_Direction",1).getValue();
    if (direction == 0) {
        var landingGearHandle_deg = props.globals.getNode("sim/G91/landingGear/landingGearHandle_deg",1).getValue();
        if (landingGearHandle_deg >= 1.0) {
            direction = -1;
        } else {
            direction = 1;
        }
        setprop("sim/G91/landingGear/landingGearHandle_Direction", direction);
    }
    setprop("sim/G91/landingGear/landingGearHandle_Start", 0);
}, 1, 0);

var landingGearFunctions = maketimer(0.1, func() {
    var speedHandle = 0.02;
    var lenghtHarm = 0.15;
    var offsetLight = 0.06;
    var landingGearHandle_deg = props.globals.getNode("sim/G91/landingGear/landingGearHandle_deg",1).getValue();
    var direction = props.globals.getNode("sim/G91/landingGear/landingGearHandle_Direction",1).getValue();
    var lightOn = 0;

    if (direction == 1) {
        lightOn = 1;
        landingGearHandle_deg = landingGearHandle_deg + speedHandle;
        if (landingGearHandle_deg >= 1.0) {
            landingGearHandle_deg = 1.0;
            setprop("sim/G91/landingGear/landingGearHandle_Direction", 0);
        }
        setprop("sim/G91/landingGear/landingGearHandle_deg", landingGearHandle_deg);
        setprop("sim/G91/landingGear/landingGearHandle_deg_Z", offsetLight - math.sin(landingGearHandle_deg) * lenghtHarm);
    } else if (direction == -1) {
        lightOn = 1;
        landingGearHandle_deg = landingGearHandle_deg - speedHandle;
        if (landingGearHandle_deg <= 0.0) {
            landingGearHandle_deg = 0.0;
            setprop("sim/G91/landingGear/landingGearHandle_Direction", 0);
        }
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
        setprop("sim/G91/landingGear/landingGearHandle_shell_transparent",0);
    }
    
    # Gear_lever light light_emission
    if (direction == 0) {
        var lightEmission = props.globals.getNode("sim/G91/re_emit/gauge_red_light",1).getValue();
        setprop("sim/G91/landingGear/landingGearHandle_light", lightEmission * 0.2);
        setprop("sim/G91/landingGear/landingGearHandle_light_transparent", 0.95);
    } else {
        var lightEmission = props.globals.getNode("sim/G91/gauge_button_lights/light_emission",1).getValue();
        setprop("sim/G91/landingGear/landingGearHandle_light", 1);
        setprop("sim/G91/landingGear/landingGearHandle_light_transparent", 0.7);
    }
});

landingGearFunctions.start();
