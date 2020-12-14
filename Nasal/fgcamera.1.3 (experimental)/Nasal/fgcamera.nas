#var listeners = [];
var FGCamera_listener = nil;
var rnd_effectN = props.Node.new();

setprop("/DHM/landing-x-level", 20);
setprop("/DHM/landing-y-level", 100);
setprop("sim/fgcamera/current-camera/movement-time", 5.0);
setprop("/DHM/LFO1/intensity", 1);
var path = "sim/fgcamera/";
var list = [
	"x-offset-m",
	"y-offset-m",
	"z-offset-m",
	"heading-offset-deg",
	"pitch-offset-deg",
	"roll-offset-deg",
];


var send_signal = func {
	if ( !size(arg) ) return;

	var h = func (s) setprop ("/sim/fgcamera/signals/" ~ s, 1);

	foreach (var a; arg)
		if ( a == "update" ) h(a);
}

var set_fgcursor_group = func (i) {
	props.getNode("/sim/fgcamera")
		.getChild("camera", i)
		.getNode("previous-cursor-group", 1)
		.setValue( fgcursor.current_group );
	setprop("/sim/fgcamera/current-camera/cursor-group-selected", 0);
}

var select_fgcursor_group = func {
	fgcursor.select_group(
		props.getNode("/sim/fgcamera").getChild("camera", getprop("/sim/fgcamera/current-camera/camera-index")).getValue("previous-cursor-group")
		or
		getprop("/sim/fgcamera/current-camera/config/fgcursor-group")
	);
	setprop("/sim/fgcamera/current-camera/cursor-group-selected", 1);
}

#==================================================================================================
#
#==================================================================================================
var panel = {
	"new": func (n)
		return {
			parents: [ panel ],
			path: n.getValue("path"),
			name: n.getValue("name"),
		},

	"show": func {
		setprop("/sim/panel/path", me.path);
		setprop("/sim/panel/visibility", 1);
	},

	"hide": func setprop("/sim/panel/visibility", 0),
};
#--------------------------------------------------------------------------------------------------
var panels = [];
foreach (var a; props.getNode("sim/fgcamera").getChildren("panel"))
	append(panels, panel.new(a));
#--------------------------------------------------------------------------------------------------
var show_panel = func {
	setprop("/sim/fgcamera/current-camera/panel-opened", 1);

	var name = getprop("/sim/fgcamera/current-camera/config/panel-name");
	foreach (var a; panels)
		if (a.name == name)
			return a.show();

	print("FGCamera: panel not found");
}
#--------------------------------------------------------------------------------------------------
var hide_panel = func {
	setprop("/sim/panel/visibility", 0);
	setprop("/sim/fgcamera/current-camera/panel-opened", 0);
}
#==================================================================================================

var select_camera = func(i, popupTip = nil) {
	close_dialog();
	hide_panel();
#	set_fgcursor_group( getprop("/sim/fgcamera/current-camera/camera-index") );

	var sourceN = props.getNode("sim/fgcamera", 1).getChild("camera", i);
	if (sourceN == nil) {
		sourceN = props.getNode("sim/fgcamera", 1).getChild("camera", i = 0);
	}

	var destN = props.getNode("sim/fgcamera/current-camera");
	props.copy(sourceN, destN);

#change view
	#setprop("/sim/fgcamera/view-movement/snap", 0);
	var n = view.indexof("FGCamera0");
	var type = getprop("/sim/fgcamera/current-camera/config/camera-type");
	setprop("/sim/fgcamera/current-camera/view-number", n + type);
#/change view

	setprop("/sim/fgcamera/current-camera/camera-index", i);

	setprop("/sim/fgcamera/view-movement/time", 0);
	setprop("/sim/fgcamera/view-movement/moving", 1);
	setprop("/sim/fgcamera/view-movement/start-moving", 1);

#	select_fgcursor_group();
}


var is_current = func (i) getprop("/sim/fgcamera/current-camera/camera-index") == i;

var save_cameras = func {
	var aircraft = getprop("/sim/aircraft");
	var path     = getprop("/sim/fg-home") ~ "/aircraft-data/FGCamera/" ~ aircraft;
	var file     = aircraft ~ ".xml";
	var file2    = aircraft ~ "-effects.xml";
	var node     = props.Node.new();
	var cameras  = props.getNode("sim/fgcamera").getChildren("camera");

	forindex (var i; cameras)
		if (i != 0)
			props.copy (cameras[i], node.getChild("camera", i, 1));

	foreach (var n; node.getChildren("camera"))
		n.removeChild("previous-cursor-group", 0);

	io.write_properties(path ~ "/" ~ file, node);

	node.removeAllChildren();
	props.copy(props.getNode("/sim/fgcamera/effects/power-plant-vibration"), node.getChild("power-plant-vibration", 0, 1));
	props.copy(props.getNode("/sim/fgcamera/effects/DHM"), node.getChild("DHM", 0, 1));

	io.write_properties(path ~ "/" ~ file2, node);

	node.remove();
}


var copy = func(src, dest) {
	foreach(var c; src.getChildren()) {
		var name = c.getName() ~ "[" ~ c.getIndex() ~ "]";
		copy(src.getNode(name), dest.getNode(name, 1));
	}
	var type = src.getType();
	var val = src.getValue();

	if(type == "ALIAS" or type == "NONE") return;

	if (dest.getValue() == nil) {
		if(type == "BOOL")
			dest.setBoolValue(val);
		elsif (type == "INT" or type == "LONG")
			dest.setIntValue(val);
		elsif (type == "FLOAT" or type == "DOUBLE")
			dest.setDoubleValue(val);
		else dest.setValue(val);
	}
}


var load_cameras = func {
	var aircraft  = getprop("/sim/aircraft");
	var path      = getprop("/sim/fg-home") ~ "/aircraft-data/FGCamera/" ~ aircraft;
	var file      = aircraft ~ ".xml";
	var file2     = aircraft ~ "-effects.xml";
	var dir       = directory(path);
	var cameraN   = props.Node.new();
	var destN     = props.getNode("sim/fgcamera", 1);

	if (dir == nil) { # FIX! (use more appropriate assumption)
		return;
		path = getprop("/sim/fg-root") ~ "/Nasal/fgcamera";
		file = "default-cameras.xml";
	}

	var srcN = io.read_properties(path ~ "/" ~ file);
	if (srcN == nil)
		return;

	props.copy(srcN, cameraN); #?
	foreach (var c; cameraN.getChildren("camera")) {
		if ( c.getIndex() > 0 ) {
			props.copy ( c, var node = destN.addChild("camera") );

			copy(props.getNode("/sim/fgcamera/camera"), node);
		}
	}

	io.read_properties(path ~ "/" ~ file2, "/sim/fgcamera/effects");
	cameraN.remove();
}
#########################################################################
# Prototyping
#
#var blade_length       = 6;
#var blade_position_deg = nil;

#var mounted_camera = func {
#	var coordinates = [0, 0, 0, 0, 0, 0];
#	var blade_position_deg = getprop("/rotors/main/blade");
#	coordinates[4] = getprop;


#	setprop("/cam/x", coordinates[0]);
#	setprop("/cam/y", coordinates[1]);
#	setprop("/cam/z", coordinates[2]);
#	setprop("/cam/h", coordinates[3]);
#	setprop("/cam/p", coordinates[4]);
#	setprop("/cam/r", coordinates[5]);
#}

#########################################################################


print("FGCamera: main script loaded");
