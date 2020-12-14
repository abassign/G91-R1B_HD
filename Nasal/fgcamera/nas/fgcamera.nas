var my_version   = "v1.2";
var my_node_path = "/sim/fgcamera";
var my_views     = ["FGCamera1", "FGCamera2", "FGCamera3", "FGCamera4", "FGCamera5"];
var my_settings  = {};

var cameras      = [];
var offsets      = [0, 0, 0, 0, 0, 0];
var offsets2     = [0, 0, 0, 0, 0, 0];
var current      = [0, 0]; # [view, camera]

var popupTipF    = 0;
var panelF       = 0;
var dialogF      = 0;
var timeF        = 0;
var helicopterF  = nil;

var mouse_enabled = 0;


#==================================================
#	"Shortcuts"
#==================================================
var sin       = math.sin;
var cos       = math.cos;
var hasmember = view.hasmember;

#==================================================
#	Generic functions:
#
#		lowpass()              -
#		zeros(n)               -
#		Bezier2(p1, x)         -
#		rotate3d(coord, angle) -
#==================================================
var lowpass = {
	new: func(coeff = 0) {
		var m = { parents: [lowpass] };

		m.coeff     = coeff >= 0 ? coeff : 0;
		m.tolerance = 0.0001;
		m.value     = nil;

		return m;
	},
#--------------------------------------------------
	filter: func(v, coeff = 0) {
		me.filter = me._filter_;
		me.value  = v;
	},
#--------------------------------------------------
	get: func {
		me.value;
	},
#--------------------------------------------------
	set: func(v) {
		me.value = v;
	},
#--------------------------------------------------
	_filter_: func(v, coeff = 0) {
		me.coeff = coeff;
		var dt   = getprop("/sim/time/delta-realtime-sec") * getprop("/sim/speed-up");
		var c    = dt / (me.coeff + dt);
		me.value = v * c + me.value * (1 - c);

		if (math.abs(me.value - v) <= me.tolerance)
			me.value = v;

		return me.value;
	},
};

var hi_pass = {
	new: func(coeff = 0) {
		var m = { parents: [hi_pass] };
		m.coeff = coeff >= 0 ? coeff : die("lowpass(): coefficient must be >= 0");
		m.value = 0;
		m.v1 = 0;
		return m;
	},
#--------------------------------------------------
	filter: func(v, coeff = 0) {
		me.coeff = coeff;
		var dt = getprop("/sim/time/delta-sec") * getprop("/sim/speed-up");
		var c = me.coeff / (me.coeff + dt);
		me.value = me.value * c + (v - me.v1) * c;
		me.v1 = v;
		return me.value;
	},
#--------------------------------------------------
	get: func {
		me.value;
	},
#--------------------------------------------------
	set: func(v) {
		me.value = v;
	},
};

#--------------------------------------------------
var zeros = func (n) {
	forindex (var i; setsize (var v = [], n))
		v[i] = 0;

	return v;
}
#--------------------------------------------------
var linterp = func (x0, y0, x1, y1, x) {
	return y0 + (y1 - y0) * (x - x0) / (x1 - x0); #linear interpolation
}
#--------------------------------------------------
var Bezier2 = func (p1, x) {
	var p0 = [0.0, 0.0];
	var p2 = [1.0, 1.0];

	var t = (-p1[0] + math.sqrt(p1[0] * p1[0] + (1 - 2 * p1[0]) * x)) / (1 - 2 * p1[0]);
	#var y = (1 - t) * (1 - t) * p0[1] + 2 * (1 - t) * t * p1[1] + t * t * p2[1];
	var y = 2 * (1 - t) * t * p1[1] + t * t;

	return y;
}

var Bezier3 = {
	_x  : zeros(31),
	_y  : zeros(31),
	_p0 : [0, 0],
	_p3 : [1, 1],

	generate: func (p1, p2) {
		var t = 0;
		for (var i = 0; i <= 30; i += 1) {
			t = i / 20;

			me._x[i] = math.pow( (1 - t), 3) * me._p0[0] + 3 * math.pow( (1 - t), 2) * t * p1[0] + 3 * (1 - t) * t * t * p2[0] + t * t * t * me._p3[0];
			me._y[i] = math.pow( (1 - t), 3) * me._p0[1] + 3 * math.pow( (1 - t), 2) * t * p1[1] + 3 * (1 - t) * t * t * p2[1] + t * t * t * me._p3[1];
		}
	},

	blend: func (x) {
		me._find_y(x);
	},

	_find_y: func (x) {
		if ( x < 0 ) return 0;
		if ( x > 1 ) return 1;

		for (var i = 0; i <= 30; i += 1)
			if ( x <= me._x[i] ) break;

		linterp(me._x[i-1], me._y[i-1], me._x[i], me._y[i], x);
	},
};
Bezier3.generate( [0.47, 0.01], [0.39, 0.98] ); #[0.52, 0.05], [0.27, 0.97]

var sin_blend = func (x) {
	return 0.5 * (sin((x - 0.5) * math.pi) + 1);
}
var s_blend = func (x) {
	x = 1 - x;
	return 1 + 2 * x * x * x - 3 * x * x;
}
#--------------------------------------------------
var rotate3d = func (coord, angle) {
	var s = [,,,];
	var c = [,,,];

	forindex (var i; angle) {
		var a = angle[i] * math.pi / 180;
		s[i]  = sin(a);
		c[i]  = cos(a);
	}

	var x =  coord[0] * c[0] + coord[2] * s[0];
	var y =  coord[1] * c[1] - coord[2] * s[1];
	var z = -coord[0] * s[0] + coord[2] * c[0];

	return coord = [x, y, z];
}
#--------------------------------------------------
var play_sound = func {
	var hash = {
		path   : getprop("/sim/fg-root") ~ "/Nasal/fgcamera/",
		file   : "start.wav",
		volume : 1.0
	};
	fgcommand ("play-audio-sample", props.Node.new(hash));
}
#--------------------------------------------------
var show_panel = func(path = "Nasal/fgcamera/Panels/generic-vfr-panel.xml") {
	if ( !cameras[current[1]]["panel-show"] )
		return;

	setprop("/sim/panel/path", path);
	setprop("/sim/panel/visibility", 1);
}
#--------------------------------------------------
var hide_panel = func { setprop("/sim/panel/visibility", 0) }

var check_helicopter = func props.globals.getNode("/rotors", 0, 0) != nil ? 1 : 0;

#==================================================
#	Template for handlers
#==================================================
var t_handler = {
	new: func {
		var m = { parents: [t_handler] };

		m.offsets      = zeros(6);

		m._offsets_raw = zeros(6);
		m._lp          = [];
		m._listeners   = [];
		m._free        = 0;
		m._effect      = 0;
		m._updateF     = 0;
		m._list        = ["x", "y", "z", "h", "p", "r"];

		forindex (var i; m.offsets) {
			append (m._lp, lowpass.new(0));

			m._lp[i].filter(0);
		}

		return m;
	},
#--------------------------------------------------
	stop: func {
		if ( size(me._listeners) ) {
			foreach (var l; me._listeners)
				removelistener(l);

			setsize(me._listeners, 0);
		}
	},

};

#==================================================
#	View adjustment handler
#==================================================
var adjustment_handler = {
	parents      : [ t_handler.new() ],

	_v           : zeros(6),
	_v_t         : zeros(6), # transformed
#--------------------------------------------------
	_reset : func {
		forindex (var i; me.offsets) {
			me.offsets[i] = me._offsets_raw[i] = 0;
			me._lp[i].set(0);
		}
	},
#--------------------------------------------------
	_trigger : func {
		forindex (var i; me._list) {
			var v     = nil;
			var v_cfg = cameras[current[1]].adjustment.v;

			if (i < 3)
				v = v_cfg[0];
			else
				v = v_cfg[1];

			me._v[i] = getprop(my_node_path ~ "/controls/adjust-" ~ me._list[i]) or 0;
			if ( (me._v[i] *= v) != 0 )
				me._updateF = 1;
		}
	},
#--------------------------------------------------
	start: func {
		foreach (var a; me._list) {
			var listener = setlistener( my_node_path ~ "/controls/adjust-" ~ a, func { me._trigger() }, 0, 0 );
			append (me._listeners, listener);
		}
	},
#--------------------------------------------------
	update: func (dt) {
		if (me._updateF) {
			me._updateF = 0;

			var filter  = cameras[current[1]].adjustment.filter;

			me._rotate();
#			forindex (var dof; me.offsets) {
#				me._offsets_raw[dof] += me._v_t[dof] * dt;
#				me.offsets[dof]       = me._lp[dof].filter(me._offsets_raw[dof], filter);

#				if ( (me.offsets[dof] != me._offsets_raw[dof]) or (me._v[dof] != 0) )
#					me._updateF = 1;
#			}

			forindex (var dof; me.offsets) {
				var v = me._lp[dof].filter(me._v_t[dof], filter);
				me.offsets[dof] += v * dt;
#				me.offsets[dof]       = me._lp[dof].filter(me._offsets_raw[dof], filter);

				if ( v != 0 )
					me._updateF = 1;
			}
		}
	},
	_rotate: func {
		var t = subvec(me._v, 0, 3);
		var r = subvec(offsets, 3);

		forindex (var i; var c = rotate3d(t, r)) {
			var _i      = [3, 4, 5][i];
			me._v_t[i]  = c[i];
			me._v_t[_i] = me._v[_i];
		}
	},
};
#==================================================
#	fgcamera.mouse
#
#		get_xy()      - ... returns [x, y],
#		get_dxdy()    - ... returns [dx, dy],
#		get_button(n) - ... returns 0 / 1.
#==================================================
var mouse = {
	_current   : zeros(6),
	_previous  : zeros(6),
	_delta     : zeros(6),
	_path      : "/devices/status/mice/mouse/",
	_path1     : "/sim/fgcamera/mouse/",
#--------------------------------------------------
	get_xy: func {
		foreach (var a; [[0, "x"], [1, "y"]] ) {
			var i   = a[0];
			var dof = a[1];

			me._previous[i] = me._current[i];
			me._current[i]  = getprop(me._path ~ dof);
			me._delta[i]    = me._current[i] - me._previous[i];
		}
		return me._current;
	},
#--------------------------------------------------
	get_delta: func {
		var i = 0;
		foreach (var a; ["x-offset", "y-offset", "z-offset", "heading-offset", "pitch-offset", "roll-offset"]) {
			me._previous[i] = me._current[i];
			me._current[i]  = getprop(me._path1 ~ a) or 0;

			me._delta[i]    = me._current[i] - me._previous[i];

			i += 1;
		}
		return me._delta;
	},
#--------------------------------------------------
	set_mode: func(mode) {
		setprop("/devices/status/mice/mouse/mode", mode);
	},
#--------------------------------------------------
	get_mode: func {
		getprop("/devices/status/mice/mouse/mode");
	},
#--------------------------------------------------
	get_button: func(n) {
		getprop(me._path ~ "button[" ~ n ~ "]") or 0;
	},
#--------------------------------------------------
	reset: func {
		var i = 0;
		foreach (var a; ["x-offset", "y-offset", "z-offset", "heading-offset", "pitch-offset", "roll-offset"]) {
			me._previous[i] = 0;
			me._current[i]  = 0;
			me._delta[i]    = 0;

			setprop(me._path1 ~ a, 0);
			i += 1;
		}
	},
};

#==================================================
#	"Mouse look" handler
#==================================================

var mouse_look_handler = {
	parents      : [ t_handler.new() ],

#	_mouse       : [[,,], [,,]],
	_delta       : zeros(6),
	_delta_t     : zeros(6),
	_path        : "/devices/status/mice/mouse/",
	_sensitivity : 1,
	_filter      : 0,
	_track_xy    : 0,
	_prev_mode   : 0,
	_mlook       : 0,
#--------------------------------------------------
	_reset : func {
		me.offsets      = zeros(6);
		me._offsets_raw = zeros(6);

		forindex (var i; me._lp)
			me._lp[i].set(me._offsets_raw[i]);
	},
#--------------------------------------------------
	_trigger : func {
		var m = mouse.get_mode();
		if ( (m == 2) or (m == 3) ) {
			me._mlook = 1;

			mouse.reset();

			var m = cameras[current[1]].mouse_look;
			me._sensitivity = m.sensitivity;
			me._filter      = m.filter;

			me._updateF = 1;
		} else
			me._mlook   = 0;
	},
#--------------------------------------------------
	start : func {
		var path     = me._path ~ "mode";
		var listener = setlistener ( path, func {me._trigger()} );

		append (me._listeners, listener);
	},
#--------------------------------------------------
	update : func {
		if (!me._updateF) return;

		me._updateF = me._mlook;

		me._delta = mouse.get_delta();
		me._rotate();

		var i = 0;
		forindex (var i; me._delta_t) {
			me._offsets_raw[i] += me._delta_t[i] * me._sensitivity;
			me.offsets[i]       = me._lp[i].filter(me._offsets_raw[i], me._filter);

			if ( me.offsets[i] != me._offsets_raw[i] )
				me._updateF = 1;

			i += 1;
		}
	},
	_rotate: func {
		var t = subvec(me._delta, 0, 3);
		var r = subvec(offsets, 3);

		forindex (var i; var c = rotate3d(t, r)) {
			var _i      = [3, 4, 5][i];
			me._delta_t[i]  = c[i];
			me._delta_t[_i] = me._delta[_i];
		}
	},
};

#==================================================
#	Start after load/reload
#==================================================

var _init_listener = setlistener("/sim/fgcamera/load-all-modules", func {
	
    if (getprop ("/sim/fgcamera/load-all-modules") >= 1) {
        
        var FGcycleMouseMode = nil;
        var configure_FG = func (mode = "start") {
            var path = "/sim/mouse/right-button-mode-cycle-enabled";
            if ( FGcycleMouseMode == nil ) FGcycleMouseMode = getprop(path);
            if ( mode == "start" ) {

                setprop(path, 1);
            } else
                setprop(path, FGcycleMouseMode);
        }

        var fgcamera_view_handler = {
            init   : func { manager.init() },
            start  : func { manager.start(); configure_FG("start") },
            update : func { return manager.update() },
            stop   : func { manager.stop(); configure_FG("stop") }
        };

        add_commands();
        load_cameras();
        load_gui();
        
        ## helicopterF = check_helicopter();

        foreach (var a; my_views)
            view.manager.register(a, fgcamera_view_handler);

        if ( getprop("/sim/fgcamera/enable") )
            setprop (my_node_path ~ "/current-camera/camera-id", 0);
            
    };
    
    print("fgcamera : fgcamera.nas script loaded");
    
});


