# used to the animation of the canopy switch and the canopy move
# toggle keystroke or 2 position switch

var cnpy = aircraft.door.new("/controls/canopy", 5);
var switch = props.globals.getNode("/controls/switches/canopy-open", 1);
var pos = props.globals.getNode("/controls/canopy/position-norm", 1);

var canopy_switch = func(v) {
  var p = pos.getValue();
  if (v == 2 ) {
    if ( p < 1 ) {
      v = 1;
    } elsif ( p >= 1 ) {
      v = -1;
    }
  }
  if (v < 0) {
    switch.setValue(0);
    cnpy.close();
  } elsif (v > 0) {
    switch.setValue(1);
    cnpy.open();
  }
}

# fixes cockpit when use of ac_state.nas #####
var cockpit_state = func {
	var switch = getprop("/controls/switches/canopy-open");
	if ( switch == 1 ) {
		setprop("/controls/canopy/position-norm", 0);
	}
}

