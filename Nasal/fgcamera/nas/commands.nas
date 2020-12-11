#==================================================
#	fgcommands:
#
#		fgcamera-select (<camera-id>)
#		fgcamera-adjust (<dof>, <velocity>)
#		fgcamera-save   ()
#==================================================
var commands = {
	"fgcamera-select": func {
		var data = cmdarg().getValues();

		popupTipF = 1;

		setprop (my_node_path ~ "/current-camera/camera-id", data["camera-id"]);
	},
#--------------------------------------------------
	"fgcamera-adjust": func {
		var data = cmdarg().getValues();

		setprop (my_node_path ~ "/controls/adjust-" ~ data.dof, data.velocity * 5.0);
	},
#--------------------------------------------------
	"fgcamera-save": func {
		setprop (my_node_path ~ "/save-cameras", 1);
	},
#--------------------------------------------------
	"fgcamera-reset-view": func {
		popupTipF = 0;
		setprop (my_node_path ~ "/current-camera/camera-id", current[1]);
	},
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
};

var cycle_category = func(dir, mode = nil) {
	var current_category = cameras[current[1]].category;
	var camera_id        = current[1];

	popupTipF = 1;

	var br = 0;
	while (!br) {
		if (dir < 0)
			camera_id -= 1;
		else
			camera_id += 1;

		if (camera_id < 0)
			camera_id += size(cameras);
		elsif (camera_id > (size(cameras) - 1))
			camera_id = 0;

		var category = cameras[camera_id].category;
		if (category != 0) {
			if (mode == nil) {
				if (current_category != category) {
					camera_id = 0;
					for (; 1; camera_id += 1)
						if (cameras[camera_id].category == category)
							break;
					setprop(my_node_path ~ "/current-camera/camera-id", camera_id);
					br = 1;
				}
			} elsif (current_category == category) {
				setprop(my_node_path ~ "/current-camera/camera-id", camera_id);
				br = 1;
			}
		}

		if (camera_id == current[1])
			br = 1;
	}
}

#// Is possible insert some commands for binding in poroperty tree by the addcommand function

var add_commands = func {
	foreach (var name; keys(commands))
		addcommand(name, commands[name]);
}


print("fgcamera : commands.nas script loaded");
