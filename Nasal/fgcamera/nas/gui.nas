#==================================================
#	GUI
#==================================================
var load_gui = func {
	var dialogs   = ["fgcamera-main", "create-new-camera", "current-camera",  "fgcamera-options", "DHM-settings", "RND-mixer", "RND-generator", "RND-curves", "RND-import"];
	var filenames = ["main",          "create_camera",     "camera_settings", "fgcamera_options", "DHM_settings", "RND_mixer", "RND_generator", "RND_curves", "RND_import"];

	forindex (var i; dialogs)
		gui.Dialog.new("/sim/gui/dialogs/" ~ dialogs[i] ~ "/dialog", "Nasal/fgcamera/GUI/" ~ filenames[i] ~ ".xml");

	var data = {
		label   : "FGCamera (experimental)",
		name    : "fgcamera",
		binding : { command : "dialog-show", "dialog-name" : "fgcamera-main" }
	};

	#// Insert FG Camera in the G91R1B Menu
	props.globals.getNode("/sim/menubar/default/menu[13]").addChild("item").setValues(data);

	fgcommand("gui-redraw");
}


var show_dialog = func (show = 0) {
	if (cameras[current[1]]["dialog-show"] or show)
		gui.showDialog(cameras[current[1]]["dialog-name"]);
}


var close_dialog = func (close = 0) {
	if (cameras[current[1]]["dialog-show"] or close)
		fgcommand ( "dialog-close", props.Node.new({ "dialog-name" : cameras[current[1]]["dialog-name"] }) );
}

print("GUI loaded");
