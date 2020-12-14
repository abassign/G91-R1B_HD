#==================================================
#	fgcommands:
#
#		fgcamera-select (<camera-id>)
#		fgcamera-adjust (<dof>, <velocity>)
#		fgcamera-save   ()
#==================================================
var _old_select_camera = func (i) { #del?
	var data = cmdarg().getValues();
	if ( cameras[i] == nil ) i = 0;

	popupTipF = 1;

	var prev = getprop (my_node_path ~ "/current-camera/camera-index");
	snapF = ( cameras[prev].category == cameras[i].category ? 0 : 1 );
	setprop (my_node_path ~ "/current-camera/previous-camera-index", prev);
	setprop (my_node_path ~ "/current-camera/camera-index", i);
}

var commands = {
	"fgcamera-select": func {
		var data = cmdarg().getValues();

		if ( !getprop("/sim/fgcamera/fgcamera-enabled") ) return;

		if ( contains(data, "slot") )
			API().CameraList().CameraBySlot(data["slot"]).select();
		elsif ( contains(data, "camera-id") )
			API().CameraList().CameraByID(data["camera-id"]).select();

		#select_camera(data["camera-id"]); # revise; check if contains "name", "camera-id", or "camera-index"
	},
#--------------------------------------------------
	"fgcamera-adjust": func {
		var data = cmdarg().getValues();

		setprop ("/sim/fgcamera/view-adjustment/raw/" ~ data.dof ~ "-velocity", data.velocity); #//sim/fgcamera/view-adjustment/raw/fov-velocity
	},
#--------------------------------------------------
#	"fgcamera-save": func {
#		setprop (my_node_path ~ "/save-cameras", 1);
#	},
#--------------------------------------------------
#	"fgcamera-reset-view": func {
#		popupTipF = 0;
#		setprop (my_node_path ~ "/current-camera/camera-index", current[1]);
#	},
#--------------------------------------------------
	"fgcamera-next-category": func {
		cycle_category(1);
	},
#--------------------------------------------------
	"fgcamera-prev-category": func {
		cycle_category(-1);
	},
#--------------------------------------------------
	"fgcamera-next-in-category": func {
		cycle_category(1, 1);
	},
#--------------------------------------------------
	"fgcamera-prev-in-category": func {
		cycle_category(-1, 1);
	},
#--------------------------------------------------
#	"fgcamera-next-ai-object": func {
#		AI_object.cycle_ai_object(1);
#	},
#--------------------------------------------------
#	"fgcamera-prev-ai-object": func {
#		AI_object.cycle_ai_object(-1);
#	},
};

var cycle_category = func(dir, mode = nil) {
	var current_category = getprop("/sim/fgcamera/current-camera/config/category");
	var camera_id        = getprop("/sim/fgcamera/current-camera/config/camera-id");

	var num_cameras = _camera_count();

	var registry = [];
	var cameras = props.getNode("sim/fgcamera").getChildren("camera");
	var i = 0;
	foreach (var c; cameras) {
		append( registry, {"index": nil, "id": nil, "category": nil, "name": nil} ); #?

		registry[i].index    = c.getIndex();
		registry[i].id       = c.getValue("config/camera-id");
		registry[i].category = c.getValue("config/category");
		registry[i].name     = c.getValue("config/camera-name");

		i += 1;
	}

	var camera_by_ID = func(id) {
		foreach (var c; registry)
			if (c.id == id) return c;
		return registry[0];
	}

	var current_index = camera_by_ID(camera_id).index;
	var br = 0;
	while (!br) {
		if (dir < 0)
			camera_id -= 1;
		else
			camera_id += 1;

		if (camera_id < 0)
			camera_id += num_cameras;
		elsif (camera_id > (num_cameras - 1))
			camera_id = 0;


		var category = camera_by_ID(camera_id).category;
		if (category != 0) {
			if (mode == nil) {
				if (current_category != category) {
					camera_id = 0;
					for (; 1; camera_id += 1)
						if (camera_by_ID(camera_id).category == category)
							break;
					#setprop(my_node_path ~ "/current-camera/camera-id", index_by_ID(camera_id));
					select_camera(camera_by_ID(camera_id).index);
					br = 1;
				}
			} elsif (current_category == category) {
				#setprop(my_node_path ~ "/current-camera/camera-id", index_by_ID(camera_id));
				select_camera(camera_by_ID(camera_id).index);
				br = 1;
			}
		}

		if (camera_by_ID(camera_id).index == current_index)
			br = 1;
	}
}


var add_commands = func {
	foreach (var name; keys(commands))
		addcommand(name, commands[name]);
}

add_commands();

print("FGCamera: commands loaded");
