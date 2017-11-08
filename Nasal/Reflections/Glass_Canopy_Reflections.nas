# Calculate Canopy reflection

var prop = props.globals.initNode("sim/G91/glass_canopy_reflections", 0, "DOUBLE");

var timerGlass_canopy_reflections = maketimer(1, func() {
    var ambientRedLight = props.globals.getNode("/rendering/scene/ambient/red",1);
    var reflection = ambientRedLight.getValue() * 0.1;
    setprop("sim/G91/glass_canopy_reflections",reflection);
});
timerGlass_canopy_reflections.start();

