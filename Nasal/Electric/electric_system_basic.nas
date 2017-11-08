# Setta il sistema elettrico per i test, serve solo per verificare le utenze da gestire

var prop = props.globals.initNode("sim/G91/electric_system_basic", 1, "DOUBLE");

var electric_system_basic = maketimer(1, func() {
    var engineIsRunning = props.globals.getNode("/engines/engine/running",1);
    if (engineIsRunning.getValue()) {
        setprop("sim/G91/electric_system_basic",1);
        setprop("instrumentation/attitude-indicator/spin",1);
        setprop("instrumentation/heading-indicator/spin",1);
    } else {
        setprop("sim/G91/electric_system_basic",0);
    }
});
electric_system_basic.start(); 
