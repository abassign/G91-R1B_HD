# var is_night = props.globals.getNode("/sim/time/sun-angle-rad",1);
var strobe_switch = props.globals.getNode("controls/switches/strobe", 2);
var strobe = aircraft.light.new( "/sim/model/lights/strobe", [0, 3], "/controls/lighting/strobe" );
