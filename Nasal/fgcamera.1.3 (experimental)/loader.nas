var listeners = [];

var add_listener = func (prop, fn) append ( listeners, setlistener(prop, fn) );

var load_nasal = func {
	var path = getprop("/sim/fg-aircraft") ~ "/G91-R1B_HD";
	foreach (var script; arg) {
		io.load_nasal ( path ~ "/Nasal/fgcamera/Nasal/" ~ script ~ ".nas", "fgcamera" );
        print("fgcamera loader.nas - load_nasal script: ",path ~ "/Nasal/fgcamera/Nasal/" ~ script ~ ".nas"," on name space: ","fgcamera");
    }
}


var reload = func {
	if (size(listeners)) {
		foreach(var l; listeners) removelistener(l);
		setsize(listeners, 0);
	}
	load_nasal("API","fgcamera","commands");
    print("fgcamera loader.nas - reload fgcamera");
}


#var next_camera_listener = nil;
var fdm_init_listener = _setlistener("/sim/signals/fdm-initialized", func {
	removelistener(fdm_init_listener);
	load_nasal("gui");
	reload();
	start_fgcamera();
	setlistener("/sim/fgcamera/fgcamera-enabled", func { #revise
		gui.menuEnable ( "fgcamera", start_fgcamera() or stop_fgcamera() );
	});
});


var reinit_listener = setlistener("/sim/signals/reinit", func {
	if ( getprop("/sim/signals/reinit") ) return; #don't reinit twice #??
	fgcommand("gui-redraw");
	#print("FGCamera: reinit");
});


var calc_default_view_offsets = func {
	var value = nil;
	foreach (var a; ["x-offset-m", "y-offset-m", "z-offset-m", "heading-offset-deg", "pitch-offset-deg", "roll-offset-deg"]) {
		value = getprop("/sim/view/config/" ~ a);
		if (value == nil)
			value = 0;
		setprop("/sim/fgcamera/camera/config/" ~ a, value);
	}
}


var start_fgcamera = func {
	if ( !getprop("/sim/fgcamera/fgcamera-enabled") ) return;

	calc_default_view_offsets();
	load_cameras();

	#Enable property rules:
	setprop("/sim/systems/property-rule[150]/serviceable", 1);
	setprop("/sim/systems/property-rule[149]/serviceable", 1);
	setprop("/sim/systems/property-rule[148]/serviceable", 1);
	setprop("/sim/systems/property-rule[147]/serviceable", 1);


	#Create listeners:
	add_listener ("/devices/status/mice/mouse/button[2]", func switch_to_mouse());
	add_listener ("/fgcam/next-in-category", func cycle_category(1, 1));
	add_listener ("/fgcam/dialog-show", func show_dialog());
	add_listener ("/fgcam/panel-show", func show_panel());
	#add_listener("/fgcam/select-cursor-group", func select_fgcursor_group());

	#Select default camera:
	API().CameraList().camera(0).select();
    
    print("fgcamera loader.nas - start_fgcamera 0");
    
	return 1;
}


var stop_fgcamera = func {
	setprop("/sim/systems/property-rule[150]/serviceable", 0);
	setprop("/sim/systems/property-rule[149]/serviceable", 0);
	setprop("/sim/systems/property-rule[148]/serviceable", 0);
	setprop("/sim/systems/property-rule[147]/serviceable", 0);


	forindex ( var i; var cameras = props.getNode("/sim/fgcamera").getChildren("camera") )
		if ( i != 0 )
			cameras[i].remove();

	if ( size(listeners) ) {
		foreach(var l; listeners) removelistener(l);
		setsize(listeners, 0);
	}
	
	print("fgcamera loader.nas - stop_fgcamera 0");

	return 0;
}

props.getNode("sim/fgcamera/mouse/spring-loaded", 1).setAttribute("userarchive", "y");
props.getNode("sim/fgcamera/enable-mini-dialog", 1).setAttribute("userarchive", "y");
props.getNode("sim/fgcamera/mini-dialog-autohide", 1).setAttribute("userarchive", "y");

print("fgcamera loader.nas - loaded");
