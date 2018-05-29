# Calculate engine_red_emission for hot engine effect

var prop = props.globals.initNode("sim/G91/engengine_red_emission", 0, "DOUBLE");

var timerEngine_red_emission = maketimer(0.5, func() {
    var engineRotation = props.globals.getNode("engines/engine/n1",1);
    var engineIsRunning = props.globals.getNode("engines/engine/running",1);
    var ambientRedLight = props.globals.getNode("rendering/scene/ambient/red",1);

    if (engineIsRunning.getValue() and (ambientRedLight.getValue() != nil and ambientRedLight.getValue() != nil) and engineRotation.getValue() != nil) {
        var red_emission = 0.0;
        if (ambientRedLight.getValue() > 0.0) {
            red_emission = engineRotation.getValue() / (-350.0 / math.ln(ambientRedLight.getValue()));
        } else {
            red_emission = 0.0;
        }
        setprop("sim/G91/engengine_red_emission",red_emission);
    } else {
        setprop("sim/G91/engengine_red_emission",1);
    }
});
timerEngine_red_emission.start();

