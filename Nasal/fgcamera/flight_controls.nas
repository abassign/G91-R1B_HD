var rudder   = 0;
var throttle = 0;

var inc_rudder   = func (d) { rudder   = d }
var inc_throttle = func (d) { throttle = d }

var ctrl_loop = func {
	if (rudder != 0) controls.slewProp("/controls/flight/rudder", rudder);

	if (throttle != 0) {
		var t = controls.slewProp("controls/engines/engine[0]/throttle", throttle);
		setprop("controls/engines/engine[0]/throttle", t);
		setprop("controls/engines/engine[1]/throttle", t);
		setprop("controls/engines/engine[2]/throttle", t);
		setprop("controls/engines/engine[3]/throttle", t);
	}

	settimer(func { ctrl_loop() }, 0);
}

#ctrl_loop();