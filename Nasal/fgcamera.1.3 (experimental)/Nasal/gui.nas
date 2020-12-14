#==================================================
#	GUI
#==================================================
var load_gui = func {
	var dialogs   = ["fgcamera-main", "create-new-camera", "current-camera",  "fgcamera-options", "DHM-settings", "RND-mixer", "RND-generator", "RND-curves", "vibration-curves", "RND-import", "power-plant-vibration", "timestamps-import"];
	var filenames = ["main",          "create_camera",     "camera_settings", "fgcamera_options", "DHM_settings", "RND_mixer", "RND_generator", "RND_curves", "vibration_curves", "RND_import", "power_plant_vibration", "timestamps_import"];

	forindex (var i; dialogs)
		gui.Dialog.new("/sim/gui/dialogs/" ~ dialogs[i] ~ "/dialog", "Nasal/fgcamera/GUI/" ~ filenames[i] ~ ".xml");

	#reset handling
	foreach(var item; props.getNode("/sim/menubar/default/menu[1]").getChildren("item"))
		if (item.getValue("name") == "fgcamera")
			return;
	#//reset handling

	var data = {
		label   : "FGCamera (experimental)",
		name    : "fgcamera",
		binding : { command : "dialog-show", "dialog-name" : "fgcamera-main" },
		enabled : { property : "/sim/fgcamera/fgcamera-enabled" },#??? FIX
	};

	props.globals.getNode("/sim/menubar/default/menu[1]").addChild("item").setValues(data);

	fgcommand("gui-redraw");
}

var x_size = getprop("/sim/startup/xsize");
var y_size = getprop("/sim/startup/ysize");

var calc_screen_xsize = func x_size = getprop("/sim/startup/xsize");
var calc_screen_ysize = func y_size = getprop("/sim/startup/ysize");

setlistener("/sim/startup/xsize", func calc_screen_xsize());
setlistener("/sim/startup/ysize", func calc_screen_ysize());

#var fgcamera_dlg = gui.Dialog.new("/sim/gui/dialogs/fgcamera-mini-dialog/dialog", "Nasal/fgcamera/GUI/mini_dialog.xml");
var fgcamera_dlg2 = gui.Dialog.new("/sim/gui/dialogs/fgcamera-mini-dialog-slots/dialog", "Nasal/fgcamera/GUI/mini_dialog_slots.xml");

var __mouse = {
	x: func getprop("/devices/status/mice/mouse/x") or 0,
	y: func getprop("/devices/status/mice/mouse/y") or 0,
};

var fgcamera_dlg_visible = 0;
setlistener("/devices/status/mice/mouse/y", func {
	if ( (__mouse.y() > (y_size-120)) and (__mouse.x() < 200) ) {
		if (!fgcamera_dlg_visible) {
#			fgcamera_dlg.open();
			fgcamera_dlg2.open();
			fgcamera_dlg_visible = 1;
		}
	} elsif (fgcamera_dlg_visible) {
#		fgcamera_dlg.close();
		fgcamera_dlg2.close();
		fgcamera_dlg_visible = 0;
	}
}, 1, 0);


load_gui();

var show_dialog = func (show = 0) {
	#if (cameras[current[1]]["dialog-show"] or show)
		gui.showDialog( getprop("/sim/fgcamera/current-camera/config/dialog-name") );
		setprop("/sim/fgcamera/current-camera/dialog-opened", 1);
}


var close_dialog = func (close = 0) {
	#if (cameras[current[1]]["dialog-show"] or close)
	var h = {"dialog-name" : getprop("/sim/fgcamera/current-camera/config/dialog-name") or return};
		fgcommand ( "dialog-close", {"dialog-name" : getprop("/sim/fgcamera/current-camera/config/dialog-name")} );
	setprop("/sim/fgcamera/current-camera/dialog-opened", 0);
}

print("FGCamera: GUI script loaded");
