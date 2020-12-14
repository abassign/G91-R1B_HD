

var _API = {
	"1.0-devel": {
		"CameraList": func return _API["1.0-devel"]._list,

		_list: {
			"CameraCount": func size( props.getNode("sim/fgcamera", 1).getChildren("camera") ),

			"camera": func(i) _camera.new(i),

			"CurrentCamera": func _current_camera.new(),

			"CameraByID": func (id) {
				foreach(var c; props.getNode("sim/fgcamera", 1).getChildren("camera"))
					if ( c != nil )
						if ( c.getValue("config/camera-id") == id ) return _camera.new( c.getIndex() );

				return nil
			},

			"CameraBySlot": func (slot) {
				foreach(var c; props.getNode("sim/fgcamera", 1).getChildren("camera"))
					if ( c != nil )
						if ( c.getValue("config/slot") == slot ) return _camera.new( c.getIndex() );

				return _camera.new(0)
			},

			"newCamera": func (name = nil, type = nil) {
				if (name == nil) name = "new camera";
				if (type == nil) type = 0;

				var path  = "sim/fgcamera";
				var id    = _camera_count();
				var src   = props.getNode(path, 0).getChild("camera", 0);
				var dest  = _free_node(props.getNode(path), "camera");
				var index = dest.getIndex();

				props.copy(src, dest);

				path = path ~ "/camera[" ~ index ~ "]/config/";
				forindex (var i; var vec = [["camera-id", id], ["camera-name", name], ["camera-type", type]])
					setprop(path ~ vec[i][0], vec[i][1]);

				var chase_dist = getprop("/sim/chase-distance-m");
				if (chase_dist != nil)
					chase_dist = math.abs(chase_dist);
				else chase_dist = 0;

				if (type == 1) {
					setprop ( path ~ "z-offset-m", chase_dist );
					setprop ( path ~ "pitch-offset-deg", -10 );
					setprop ( path ~ "y-offset-m", math.sin(D2R * 10) * chase_dist );
				} elsif (type == 2) {
					var p = geo.aircraft_position().latlon();
					setprop ( path ~ "latitude-deg", p[0] );
					setprop ( path ~ "longitude-deg", p[1] );
					setprop ( path ~ "altitude-ft", p[2] * M2FT + chase_dist );
				}

				send_signal("update");
				return _camera.new(index);
			},

			"saveToXML": func save_cameras(),

			"loadFromXML": func {
				load_cameras();
				send_signal("update");
			},
		},
	}, # 1.0-devel
};
var _camera_count = func size( props.getNode("sim/fgcamera", 1).getChildren("camera") );

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

	"select": func {
		if ( me._node.getValue("config/view-movement/popupTip") )
			gui.popupTip(me._node.getValue("config/camera-name"), 1);

		select_camera(me._index);
	},


	"delete": func {                                # revise. Don't select default camera if we are deleting non-active camera;
		if (me._index == 0) return;

		select_camera(0);

		var node = props.getNode("sim/fgcamera");
		node.removeChild("camera", me._index, 0);
		var cameras = node.getChildren("camera");


		foreach (var c; cameras)                    # e.g. deleted ID = 3; [1, 2, nil, 4, 5] -> [1, 2, 3, 4]
			if (c != nil)
				if ( (var v = c.getValue("config/camera-id")) > me._id )
					c.getNode("config/camera-id").setIntValue(v - 1);

		send_signal("update");
		nil
	},

	"copy": func {
		var path  = "sim/fgcamera";
		var id    = _camera_count();
		var src   = props.getNode(path, 0).getChild("camera", me._index);
		var dest  = _free_node(props.getNode(path), "camera");
		var index = dest.getIndex();

		props.copy(src, dest);

		path = path ~ "/camera[" ~ index ~ "]/config/";
		setprop ( path ~ "camera-id", id );
		setprop ( path ~ "camera-name", getprop(path ~ "camera-name") ~ "-copy" );

		send_signal("update");
		return _camera.new(index);
	},

	"lookat": func(v = nil) {
		var c = me._node.getNode("config/look-at", 1);

		if ( v == nil )
			return ( c.getValue() or 0 );
		elsif ( v > 0 )
			v = 1;
		else v = 0;

		c.setBoolValue(v);

		if ( is_current(me._index) )
			setprop("/sim/fgcamera/current-camera/config/look-at", v);
	},



	"name": func (name = nil) {
		var name_N = me._node.getNode("config/camera-name", 0, 1);

		if (name == nil)
			return name_N.getValue();

		name_N.setValue(name);
		send_signal("update");
		me;
	},

	"dialog": func (show = nil, name = nil) {
		if (show != nil)
			me._node.setValue("config/dialog-show", show > 0 ? 1 : 0);

		if (name != nil)
			me._node.setValue("config/dialog-name", name);

		send_signal("update");
		me;
	},

	"panel": func (show = nil, name = nil) {
		if (show != nil)
			me._node.setValue("config/panel-show", show > 0 ? 1 : 0);

		if (name != nil)
			me._node.setValue("config/panel-name", name);

		send_signal("update");
		me;
	},

	"fgcursor": func (show = nil, group = nil) {
		if (show != nil)
			me._node.setValue("config/fgcursor-show", show > 0 ? 1 : 0);

		if (group != nil)
			me._node.setValue("config/fgcursor-group", group);

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

	"slot": func (slot = nil) {
		var n = me._node.getNode("config/slot", 1);
		if (slot == nil) return n.getValue();
		n.setValue(slot);
		send_signal("update");
		me;
	},

	"id": func (id = nil) {
		if (id == nil) return me._id;

		if (me._index == 0) return me;
		if (id == me._id)  return me;

		#truncate:
		if ( id < 1 ) id = 1;
		if ( id > (var n = _camera_count() - 1 ) ) id = n;

		var d = 1; #direction
		if ( id < me._id )
			d = -1;

		var L = math.abs(id - me._id); #length
		#var c = _camera_count();
		var cameras = props.getNode("sim/fgcamera", 1).getChildren("camera");
		var c_id = nil; #camera_id
		var v = nil;    #value

		for (var i = 1; i <= L; i += 1)
			forindex (var j; cameras)
				if (cameras[j] != nil) {
					c_id = cameras[j].getNode("config/camera-id");
					v = c_id.getValue();
					if ( v == (me._id + d * i) )
						c_id.setValue(v - d);
				}

		setprop("/sim/fgcamera/camera[" ~ me._index ~ "]/config/camera-id", me._id = id);
		send_signal("update");
		return me;

	},

	"settings": func (group) {
		foreach (var a; ["view movement", "view adjustment", "mouse look", "head tracker"])
			if (group == a)
				return {
					parents: [ _camera_settings[a].new(me._index) ],
					_set_value: func (prop, value) {
						var path = "/sim/fgcamera/camera[" ~ me._index ~ "]/" ~ prop;
						setprop(path, value);
						if (is_current(me._index)) {
							path = "/sim/fgcamera/current-camera/" ~ prop;
							setprop(path, value);
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

	effect: func (group) {
		foreach (var a; ["DHM", "RND", "Power-plant vibration"])
			if (group == a)
				return {
					parents: [_effects[a].new(me._index)],
				};
		return nil;
	},
}; # _camera

var _effects = {
	"DHM": {
		new: func (i) {
			return {
				parents: [ _effects.DHM ],
				_index: i,
				_path: "/sim/fgcamera/effects/DHM/",
			}
		},

		"HeadMass": func (m = nil) {
			var prop = me._path ~ "head-mass-kg";
			if (m == nil) return getprop(prop);
			setprop(prop, m);
			if ( is_current(me._index) )
				send_signal("update");
			me
		},

		"scale": func (s = nil) {
			var prop = "/sim/fgcamera/camera[" ~ me._index ~ "]/effects/DHM/global-scale";
			if (s == nil) return getprop(prop);
			setprop(prop, s);
			if ( is_current(me._index) ) {
				setprop("/sim/fgcamera/current-camera/effects/DHM/global-scale", s);
				send_signal("update");
			}
			me
		},

		"LoadRelease": func (v = nil) {
			var prop = me._path ~ "load-release-filter";
			if (v == nil) return getprop(prop);
			setprop(prop, v);
			if ( is_current(me._index) )
				send_signal("update");
			me
		},

		"ConstantG": func (dof, v = nil) {
			#FIX: validate dof
			var prop = me._path ~ dof ~ "-constant-g-scale";
			if (v == nil) return getprop(prop);
			setprop(prop, v);
			if ( is_current(me._index) )
				send_signal("update");
			me
		},

		"ImpulseG": func (dof, v = nil) {
			#FIX: validate dof
			var prop = me._path ~ dof ~ "-impulse-g-scale";
			if (v == nil) return getprop(prop);
			setprop(prop, v);
			if ( is_current(me._index) )
				send_signal("update");
			me
		},

		"HeadBank": func (v = nil) {
			var prop = me._path ~ "x-roll-factor";
			if (v == nil) return getprop(prop);
			setprop(prop, v);
			if ( is_current(me._index) )
				send_signal("update");
			me
		},

		"HeadPitch": func (v = nil) {
			var prop = me._path ~ "y-pitch-factor";
			if (v == nil) return getprop(prop);
			setprop(prop, v);
			if ( is_current(me._index) )
				send_signal("update");
			me
		},

		"HeadX": func (v = nil) {
			var prop = me._path ~ "r-x-factor";
			if (v == nil) return getprop(prop);
			setprop(prop, v);
			if ( is_current(me._index) )
				send_signal("update");
			me
		},

		"damping": func (dof, v = nil) {
			#FIX: validate dof
			var prop = me._path ~ dof ~ "-damping";
			if (v == nil) return getprop(prop);
			setprop(prop, v);
			if ( is_current(me._index) )
				send_signal("update");
			me
		},

		"limit": func (dof, v = nil) {
			#FIX: validate dof
			var prop = me._path ~ dof ~ "-limit";
			if (v == nil) return getprop(prop);
			setprop(prop, v);
			if ( is_current(me._index) )
				send_signal("update");
			me
		},

	},
};

_effects["RND"] = {
	new: func (i) {
		return {
			parents: [ _effects["RND"] ],
			_index: i,
			cN: props.getNode("/sim/fgcamera/camera[" ~ i ~ "]/effects", 1),
			ccN: props.getNode("/sim/fgcamera/current-camera/effects", 1)
		}
	},

	"generator": func (i, mode) return me._generator.new(i, mode, me._index, me.cN, me.ccN),

	_generator: {
		new: func (i, mode, _index, cN, ccN) {
			return {
				parents: [ me ],
				_index: _index,
				cN: cN.getChild("RND", mode, 1).getChild("GEN", i, 1),
				ccN: ccN.getChild("RND", mode, 1).getChild("GEN", i, 1),
				mode: mode,

				_setting: func(gen, param, value = nil) {
					var h = {
						sine:      ["enable", "frequency", "level"],
						resonance: ["enable", "frequency", "intensity", "attack", "release", "level"],
						noise:     ["enable", "frequency", "level"],
						LFO1:      ["enable", "level", "intensity", "filter"],
						LFO2:      ["enable", "level", "intensity", "filter"],
					};
					foreach (var k; keys(h))
						if (k == gen)
							foreach (var p; h[gen])
								if (param == p) {
									var path = gen ~ "/" ~ param;
									if (value == nil) return me.cN.getValue(path);
									me.cN.setValue(path, value);
									if (is_current(me._index)) {
										me.ccN.setValue(path, value);
										send_signal("update");
									}
								}
				},
			}
		},

		"sine": func(param, v = nil) me._setting("sine", param, v),

		"resonance": func(param, v = nil) me._setting("resonance", param, v),

		"noise": func(param, v = nil) me._setting("noise", param, v),

		"LFO1": func(param, v = nil) me._setting("LFO1", param, v),

		"LFO2": func(param, v = nil) me._setting("LFO2", param, v),

	},


	"mixer": func (mode) return me._mixer.new(mode, me._index, me.cN, me.ccN),

	_mixer: {
		new: func (mode, _index, cN, ccN) {
			return {
				parents: [ me ],
				_index: _index,
				cN: cN.getChild("RND", mode, 1).getNode("mixer", 1),
				ccN: ccN.getChild("RND", mode, 1).getNode("mixer", 1),
				mode: mode
			}
		},

#		"generator": func (dof, i, v = nil) {
#			foreach (var a; ["x", "y", "z", "h", "p", "r"])
#				if (a == dof) {
#					
#				}
#		},

		"scale": func (dof, v = nil) {
			foreach (var a; ["x", "y", "z", "h", "p", "r", "output"])
				if (a == dof) {
					if (v == nil) {
						v = [];
						foreach(var c; me.cN.getChildren(dof))
							append(v, c.getValue());
						return v;
					}
					var cr = is_current(me._index);
					forindex(var i; v) {
						if ( (var value = v[i]) != nil) {
							me.cN.getChild(dof, i, 1).setValue(value);
							if (cr) me.ccN.getChild(dof, i, 1).setValue(value);
						}
					}
					if (cr) send_signal("update");
				}
			me;
		},
	},
};




_effects["Power-plant vibration"] = {
	new: func (i) {
		return {
			parents: [ _effects["Power-plant vibration"] ],
			_index: i,
			_path: "/sim/fgcamera/camera[" ~ i ~ "]/effects/power-plant-vibration/",
			_mode: "global",
			camera_node: props.getNode("/sim/fgcamera/camera[" ~ i ~ "]/effects/power-plant-vibration", 1),
			current_camera_node: props.getNode("/sim/fgcamera/current-camera/effects/power-plant-vibration", 1)
		}
	},

	_hlp: func (mode, n)
		return {
			parents: [ _effects["Power-plant vibration"].new(me._index) ],
			number: n,
			_mode: "local",
			camera_node: props.getNode("/sim/fgcamera/camera[" ~ me._index ~ "]/effects/power-plant-vibration", 1).getChild(mode, n, 1),
			effect_node: props.getNode("/sim/fgcamera/effects/power-plant-vibration", 1).getChild(mode, n, 1),
			current_camera_node: props.getNode("/sim/fgcamera/current-camera/effects/power-plant-vibration", 1).getChild(mode, n, 1),
		},

	"engine": func (n) me._hlp("engine", n),

	"rotor": func (n) me._hlp("rotor", n),

	"enable": func (f = nil) { #FIX
		if ( f == nil ) {
			if (me._mode == "local")
				return me.effect_node.getValue("enabled") or 0;
			else
				return me.camera_node.getValue("enabled") or 0;
		} elsif ( f > 0 )
			f = 1;
		else f = 0;


		if (me._mode == "global")
			me.camera_node.setValue("enabled", f);
		else {
			me.effect_node.setValue("enabled", f);
			send_signal("update");
			return me;
		}

		if ( is_current(me._index) ) {
			me.current_camera_node.setValue("enabled", f);
			send_signal("update");
		}

		me
	},

	"scale": func (dof = nil, s = nil) {
		if ( dof == nil )
			dof = "global";

		if ( s == nil ) {
			if ( dof == "global" )
				return me.camera_node.getNode(dof ~ "-scale", 1).getValue() or 0;
			else return me.effect_node.getNode(dof ~ "-scale", 1).getValue() or 0;
		}

		if ( dof != "global" ) {
			me.effect_node.setValue(dof ~ "-scale", s);
			send_signal("update");
			return me;
		}

		me.camera_node.setValue("global-scale", s);

		if ( is_current(me._index) ) {
			me.current_camera_node.setValue("global-scale", s);
			send_signal("update");
		}

		me
	},
};

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
		var path = "/sim/fgcamera";

		var offsets = [
			"x-offset-m",
			"y-offset-m",
			"z-offset-m",
			"heading-offset-deg",
			"pitch-offset-deg",
			"roll-offset-deg",
		];

		var type = me._node.getValue("config/camera-type");
		var value = nil;

		if (type == 2)
			forindex ( var i; var vec = ["latitude-deg", "altitude-ft", "longitude-deg"] )
				offsets[i] = vec[i];

		forindex (var i; offsets) {                                              #fix: exclude effects/headtracker offsets
			if ( (type == 2) and (i < 3) )
				value = getprop("/sim/fgcamera/current-camera/" ~ offsets[i]);
			else value = getprop("/sim/current-view/" ~ offsets[i]);

			setprop(path ~ "/current-camera/config/" ~ offsets[i], value);
			setprop(path ~ "/camera[" ~ me._index ~ "]/config/" ~ offsets[i], value);
		}
		me
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
		FOV: func (fov = nil) me._setting("config/fov", fov),
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
		popupTip: func (f = nil) me._setting("config/view-movement/popupTip", f == nil ? nil : (f > 0 ? 1 : 0) ),
#----------------------------------------------------------------------------------------------------
		time: func (t = nil) me._setting("config/view-movement/movement-time", t),
#----------------------------------------------------------------------------------------------------
		linear: func (f = nil) me._setting("config/view-movement/linear-interpolation", f == nil ? nil : (f > 0 ? 1 : 0) ),
#----------------------------------------------------------------------------------------------------
		filter: func (coeff = nil) me._setting("config/view-movement/filter-time", coeff),
	},
#====================================================================================================
	"mouse look": {
		new: func (i) {
			return {
				parents : [ _camera_settings["mouse look"] ],
				_index  : i,
				_path   : "/sim/fgcamera/camera[" ~ i ~ "]/",
			}
		},
#----------------------------------------------------------------------------------------------------
		sensitivity: func (v = nil) me._setting("config/mouse-look/sensitivity", v),
#----------------------------------------------------------------------------------------------------
		filter: func (coeff = nil) me._setting("config/mouse-look/filter-time", coeff),

	}, # mouse look
#====================================================================================================
	"head tracker": {
		new: func (i) {
			return {
				parents : [ _camera_settings["head tracker"] ],
				_index  : i,
				_path   : "/sim/fgcamera/camera[" ~ i ~ "]/",
			}
		},
#----------------------------------------------------------------------------------------------------
		enabled: func (f = nil) me._setting("config/head-tracker/enabled", f == nil ? nil : (f > 0 ? 1 : 0) ),
#----------------------------------------------------------------------------------------------------
		filter: func (coeff = nil) me._setting("config/head-tracker/filter-time", coeff),

	}, # head tracker
};

var _free_node = func (node, child) {
	var vec = node.getChildren(child);
	if (size(vec) == 0) return node.getNode(child, 1); #?
	for (var i = 0; 1; i += 1)
		if (node.getChild(child, i, 0) == nil) break;
	return node.getChild(child, i, 1);
}

var API = func(v = "1.0-devel") return _API[v];

print("FGCamera: API script loaded");
