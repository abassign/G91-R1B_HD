var prop = props.globals.initNode("sim/G91/ambient-data/sun-angular-deg", 0, "DOUBLE");

var ambient_data = maketimer(0.1, func() {
    var heading_deg = props.globals.getNode("orientation/heading-deg",1).getValue();
    var local_day_deg = props.globals.getNode("sim/time/local-day-seconds",1).getValue();
    local_day_deg = local_day_deg / 240;
    var sun_angle_deg = props.globals.getNode("sim/time/sun-angle-rad",1).getValue();
    sun_angle_deg = sun_angle_deg * 57.3;
    var pitch_deg = props.globals.getNode("orientation/pitch-deg",1).getValue();
    pitch_deg = 90 - pitch_deg;
    var deg_distance_deg = math.pow(math.pow(local_day_deg - heading_deg,2)+math.pow(sun_angle_deg - pitch_deg,2),0.5);
    setprop("sim/G91/ambient-data/sun-angular-deg",deg_distance_deg);
    });
ambient_data.start();
