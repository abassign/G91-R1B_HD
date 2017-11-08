# Calculate Glass reflection

var prop = props.globals.initNode("sim/G91/glass_camera_reflections", 0, "DOUBLE");

var timerGlass_camera_reflections = maketimer(1, func() {
    var ambientRedLight = props.globals.getNode("/rendering/scene/ambient/red",1);
    var reflection = ambientRedLight.getValue();
    setprop("sim/G91/glass_camera_reflections",reflection);
});
timerGlass_camera_reflections.start();

