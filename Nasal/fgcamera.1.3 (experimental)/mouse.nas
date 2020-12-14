var mouse = {
	_path: "/devices/status/mice/mouse/",

	mode: func(mode = nil) {
		if (mode != nil)
			return setprop("/devices/status/mice/mouse/mode", mode);
		getprop("/devices/status/mice/mouse/mode");
	},

	button: func(n) (getprop(me._path ~ "button[" ~ n ~ "]") or 0),
};


var mouse_mode = 0; #  0 - mouse; 1 - yoke; 2 - rudder/throttle

var toggleYoke = func {
	if (mouse_mode == 0) {
		mouse_mode = 1;
	} else {
		mouse_mode = 0;
	}
	setprop("/devices/status/mice/mouse/mode", mouse_mode);
	setprop("/sim/fgcamera/mouse/mouse-yoke", mouse_mode);
}
#-------------------------------------------------
var prev_mode = 0;

var switch_to_mouse = func {
	if ( !getprop("/sim/fgcamera/mouse/spring-loaded") or !getprop("/sim/fgcamera/fgcamera-enabled") ) return;
	var b2 = mouse.button(2);
	if (b2) {
		prev_mode = mouse.mode();
		mouse.mode(2);
	} else mouse.mode(prev_mode);
}
#-------------------------------------------------
#var mYokeListener = setlistener("/devices/status/mice/mouse/button[2]", func { switch_to_mouse() } );