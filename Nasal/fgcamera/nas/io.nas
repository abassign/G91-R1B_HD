#==================================================
#	Data Input/Output
#==================================================
var load_cameras = func {
	var aircraft  = getprop("/sim/aircraft");
	var path      = getprop("/sim/fg-home") ~ "/aircraft-data/FGCamera/" ~ aircraft;
	var file      = aircraft ~ ".xml";
	var dir       = directory(path);
	var cameraN   = props.Node.new();
	var setF      = 0;

	if (dir == nil) { # FIX! (use more appropriate assumption)
		##path = getprop("/sim/fg-root") ~ "/Nasal/fgcamera";
        path = getprop("/sim/fg-aircraft") ~ "/G91-R1B_HD" ~ "/Nasal/fgcamera";
		file = "default-cameras.xml";

		setF = 1;
	}

	print("fgcamera : io.nas path: ",path," FIle: ",file);
	props.copy(io.read_properties(path ~ "/" ~ file), cameraN);

	var vec = cameraN.getChildren("camera");
	forindex (var i; vec) {
		append( cameras, vec[i].getValues() );
	}

	if ( setF )
		set_default_offsets();

	var cam_version = cameraN.getChild("version", 0, 1).getValue() or "v1.0";
	print("cameras version: " ~ cam_version);
	if (cam_version != my_version)
		update_cam_version(cam_version);

	var spring_loaded_mouse = cameraN.getChild("spring-loaded-mouse", 0, 1).getValue() or "0";
	setprop("/sim/fgcamera/mouse/spring-loaded", spring_loaded_mouse);

	cameraN.remove();
	return size(cameras);
}

var set_default_offsets = func {
	forindex (var i; manager._list)
		cameras[0].offsets[i] = num(getprop( "/sim/view/config/" ~ manager._list[i] )) or 0;
}
#--------------------------------------------------
var save_cameras = func {
	var aircraft = getprop("/sim/aircraft");
	var path     = getprop("/sim/fg-home") ~ "/aircraft-data/FGCamera/" ~ aircraft;
	var file     = aircraft ~ ".xml";
	var node     = props.Node.new();
	var sl_mouse = getprop("/sim/fgcamera/mouse/spring-loaded");

	forindex (var i; cameras) {
		foreach (var a; keys(cameras[i]) ) {
			var data = {};
			data[a]  = cameras[i][a];

			node.getChild("camera", i, 1).setValues(data);
		}
	}

	node.getChild("version", 0, 1).setValue(my_version);
	node.getChild("spring-loaded-mouse", 0, 1).setValue(sl_mouse);

	io.write_properties(path ~ "/" ~ file, node);
	node.remove();
}

print("fgcamera : io.nas script loaded");
