var camera_ID = [];
var camera_limit = 50;

var _API = {
	"1.0-devel": {
		"CameraList": func return _API["1.0-devel"]._list,

#		"CameraByID": func,

		_list: {
			"CameraCount": func _camera_count(),

			"camera": func(i) _camera.new(i),

			"CurrentCamera": func _current_camera.new(),

			"CameraByID": func (id) {
				var i = 0;
				var node = props.getNode("sim/fgcamera", 1);
				var cameras = node.getChildren("camera");
				#print (cameras[0].getNode("config/camera-id", 0).getValue()   );
				foreach(var c; cameras) {
					if ( c != nil )
						if ( c.getValue("config/camera-id") == id ) return _camera.new( c.getIndex() );
					i += 1;
				}
				return nil
			},
		},
	}, # 1.0-devel
};

var _camera_count = func {
	var node = props.getNode("sim/fgcamera", 1);
	var cameras = node.getChildren("camera");
	return size(cameras);
}

var _camera = {
	new: func(i) {
		var camera = props.getNode("sim/fgcamera", 1).getChild("camera", i);
		if (camera == nil) return nil;
		return {
			parents: [ _camera ],
			_node: camera,
			_id: camera.getNode("config/camera-id", 0).getValue(),
			_index: i,
		};
	},

	"select": func return select_camera(me._index),

	"name": func (name = nil) {
		var name_N = me._node.getNode("config/camera-name", 0, 1);
		if (name == nil) return name_N.getValue();
		name_N.setValue(name);
		send_signal("update");
		me;
	},

	"category": func (c = nil) {
		var category_N = me._node.getNode("config/category", 0, 1);
		if (c == nil) return category_N.getValue();
		category_N.setValue(c);
		send_signal("update");
		me;
	},

	"id": func (id = nil) {
		if (id == nil) return me._id;

		if (me._index == 0) return me;
		if (id == me._id) return me;

		#truncate:
		if ( id < 1 ) id = 1;
		if ( id > (var n = _camera_count() ) ) id = n;

		var d = 1; #direction
		if ( id < me._id )
			d = -1;

		var L = math.abs(id - me._id); #length
		var c = _camera_count();
		var cameras = props.getNode("sim/fgcamera", 1).getChildren("camera");

		for (var i = 1; i <= L; i += 1)
			forindex (var j; cameras)
				if (cameras[j] != nil)
					if (cameras[j].getChild("camera-id", 0).getValue() == (me._id + d * i)) #revise!!!
						cameras[j].getChild("camera-id", 0).setValue(cameras[j].getChild("camera-id", 0).getValue() - d);

		cameras[me._index].getChild("camera-id", 0).setValue(me._id = id);
		send_signal("update");
		return me;

	},

	"settings": func (group) {
		foreach (var a; ["view movement", "view adjustment", "mouse look"])
			if (group == a)
				return {
					parents: [ _camera_settings[a].new(me._index) ],
					_set_value: func (prop, value) {
						var path = "/sim/fgcamera/camera[" ~ me._index ~ "]/" ~ prop;
						setprop(path, value);
						if (is_current(me._index)) {
							path = "/sim/fgcamera/current-camera/" ~ prop;
							setprop(path, prop);
						}
					},
					_setting: func (prop, value) {
						if (value == nil) return getprop(me._path ~ prop);
						me._set_value(prop, value);
						me
					},
				};
		return nil;
	},
}; # _camera


_current_camera = {
	new: func {
		return {
			parents: [
				_current_camera,
				_camera.new(getprop("/sim/fgcamera/current-camera/camera-index")),
			],
		};
	},
#----------------------------------------------------------------------------------------------------
	storeOffsets: func {
		
	},
#----------------------------------------------------------------------------------------------------
	moveTo: func (vec) {
		var prefix = "/sim/fgcamera/current-camera/config/";
		var suffix = [
			"x-offset-m",
			"y-offset-m",
			"z-offset-m",
			"heading-offset-deg",
			"pitch-offset-deg",
			"roll-offset-deg",
		];
		forindex(var i; vec)
			setprop(prefix ~ suffix[i], vec[i]);

		setprop("/sim/fgcamera/view-movement/time", 0);          # revise: move to dedicated function
		setprop("/sim/fgcamera/view-movement/moving", 1);
		setprop("/sim/fgcamera/view-movement/start-moving", 1);
	},
}; # _current_camera

#====================================================================================================
#
#====================================================================================================
var _camera_settings = {
	"view adjustment": {
		new: func (i) {
			return {
				parents : [ _camera_settings["view adjustment"] ],
				_index  : i,
				_path   : "/sim/fgcamera/camera[" ~ i ~ "]/",
			}
		},
#----------------------------------------------------------------------------------------------------
		FOV: func (fov = nil) {
			if (fov == nil) return "60"; #cameras[me._index].fov;

			cameras[me._index].fov = fov;
			me
		},
#----------------------------------------------------------------------------------------------------
		LinearVelocity: func (v = nil) me._setting("config/view-adjustment/linear-velocity", v),
#----------------------------------------------------------------------------------------------------
		AngularVelocity: func (v = nil) me._setting("config/view-adjustment/angular-velocity", v),
#----------------------------------------------------------------------------------------------------
		filter: func (coeff = nil) me._setting("config/view-adjustment/filter-time", coeff),
	},
#====================================================================================================
	"view movement": {
		new: func (i) {
			return {
				parents : [ _camera_settings["view movement"] ],
				_index  : i,
				_path   : "/sim/fgcamera/camera[" ~ i ~ "]/",
			}
		},
#----------------------------------------------------------------------------------------------------
		chained: func (f = nil) me._setting("config/view-movement/chained", f == nil ? nil : (f > 0 ? 1 : 0) ),
#----------------------------------------------------------------------------------------------------
		popupTip: func (f = nil) me._setting("config/popupTip", f == nil ? nil : (f > 0 ? 1 : 0) ),
#----------------------------------------------------------------------------------------------------
		time: func (t = nil) me._setting("config/view-movement/movement-time", t),
#----------------------------------------------------------------------------------------------------
		linear: func (f = nil) {
			if (f == nil) return getprop(me._path ~ "config/view-movement/linear-interpolation");
			me._set_value("config/view-movement/linear-interpolation", f > 0 ? 1 : 0);
			me
		},
#----------------------------------------------------------------------------------------------------
		filter: func (coeff = nil) {
			if (coeff == nil) return getprop(me._path ~ "config/view-movement/filter-time");
			me._set_value("config/view-movement/filter-time", coeff);
			me
		},
	},
#====================================================================================================
	"mouse look": {
		new: func (i) {
			return {
				parents : [ _camera_settings["mouse look"] ],
				_index  : i,
			}
		},
#----------------------------------------------------------------------------------------------------
		"sensitivity": func (v = nil) {
			if (v == nil) return cameras[me._index].mouse_look.sensitivity;

			cameras[me._index].mouse_look.sensitivity = v;
			me
		},
#----------------------------------------------------------------------------------------------------
		filter: func (coeff = nil) {
			if (coeff == nil) return cameras[me._index].mouse_look.filter;

			cameras[me._index].mouse_look.filter = coeff;
			me
		},
	}, # mouse look
};


var API = func(v = "1.0-devel") return _API[v];

print("FGCamera: API script loaded");
