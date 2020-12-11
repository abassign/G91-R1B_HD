
#==================================================
#	Offsets manager
#==================================================
var manager = {
	initialized : 0,

	handlers    : [ adjustment_handler, movement_handler, mouse_look_handler, DHM_handler, RND_handler, HeadTracker ],

	_list       : ["x-offset-m", "y-offset-m", "z-offset-m", "heading-offset-deg", "pitch-offset-deg", "roll-offset-deg"],
#--------------------------------------------------
	init : func {
		if ( me.initialized ) return;

		foreach (var h; me.handlers)
			if ( hasmember(h, "init") ) h.init();

		me.initialized = 1;
	},
#--------------------------------------------------
	start : func {
		setprop("/sim/fgcamera/fgcamera-enabled", 1);
		foreach (var h; me.handlers)
			if ( hasmember(h, "start") )
				h.start();
	},
#--------------------------------------------------
	update : func (dt = nil) {
		if (dt == nil)
			dt = getprop ("/sim/time/delta-sec");

		var updateF   = 0;
		var _offsets  = zeros(6);
		var _offsets2 = zeros(6);

		foreach (var h; me.handlers) {
			if ( h._updateF )
				updateF = 1;

			h.update(dt);
			if (h._effect)
				forindex (var i; h.offsets) _offsets2[i] += h.offsets[i];
			else
				forindex (var i; h.offsets) _offsets[i] += h.offsets[i];
		}

		offsets  = _offsets;
		offsets2 = _offsets2;
		if ( updateF )
			me._apply_offsets();

		return 0;
	},
#--------------------------------------------------
	reset : func {
		foreach (var h; me.handlers)
			if ( hasmember(h, "reset") )
				h.reset();
	},
#--------------------------------------------------
	stop : func {
		setprop("/sim/fgcamera/fgcamera-enabled", 0);
		foreach (var h; me.handlers)
			if ( hasmember(h, "stop") )
				h.stop();
	},
#--------------------------------------------------
	_reset : func {
		foreach (var h; me.handlers)
			if ( hasmember(h, "_reset") )
				h._reset();
			elsif ( !h.free )
				forindex (var i; h.offsets)
					h.offsets[i] = 0;
	},
#--------------------------------------------------
	_apply_offsets : func {
		forindex (var i; me._list)
			setprop ( "/sim/current-view/" ~ me._list[i], offsets[i] + offsets2[i] );
	},
#--------------------------------------------------
	_save_offsets : func {
		forindex (var i; cameras[current[1]].offsets)
			cameras[current[1]].offsets[i] = offsets[i];
	},
};