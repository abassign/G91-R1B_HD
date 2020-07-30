# Calculate engine_red_emission for hot engine effect

var prop = props.globals.initNode("sim/G91/engine_internal_light", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/engine_internal_light_hight", 0, "DOUBLE");
var prop = props.globals.initNode("sim/G91/engine_internal_light_low", 0, "DOUBLE");

var timerEngengine_internal_light = maketimer(1.0, func() {
    var internal_light = 0.0;
    var internal_light_hight = 0.0;
    var internal_light_low = 0.0;
    var ambientRedLight = props.globals.getNode("rendering/scene/ambient/red",1);
    if (props.globals.getNode("sim/G91/models/active/tail",1).getValue() == 1) {
        if (ambientRedLight.getValue() != nil) {
            if (ambientRedLight.getValue() > 0.0) {
                internal_light =  math.pow(1.0 / (math.log10(0.01 + ambientRedLight.getValue()) + 3.0),1.5);
                if (internal_light < 0.0) internal_light = 0.0;
            } else {
                internal_light = 0.0;
            }
            setprop("sim/G91/engine_internal_light",internal_light);
            internal_light_hight = internal_light * 2.0;
            if (internal_light_hight > 1.0) internal_light_hight = 1.0;
            internal_light_low = internal_light / 2.0;
            setprop("sim/G91/engine_internal_light",internal_light_hight);
        } else {
            setprop("sim/G91/engine_internal_light",0.1);
        }
    } else {
        setprop("sim/G91/engine_internal_light",1.0);
    }
});
timerEngengine_internal_light.start();

