# Setta il sistema gestione autopilot per i test, serve solo per verificare le utenze da gestire

var prop = props.globals.initNode("instrumentation/attitude-indicator/horizon-offset-deg", 0, "DOUBLE");

var autopilot_set = maketimer(1, func() {
    var horizon_offset_deg = props.globals.getNode("instrumentation/attitude-indicator/horizon-offset-deg",1);
    setprop("autopilot/settings/target-pitch-deg",horizon_offset_deg.getValue());
});
autopilot_set.start(); 
