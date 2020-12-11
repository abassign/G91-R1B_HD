var ht_filter = 0.1;

#==================================================
#	Headtracker inputs handler
#==================================================
var HeadTracker = {
	parents  : [ t_handler.new() ],

	free     : 1,

	_updateF : 1,
	_effect  : 1,
#--------------------------------------------------
	init: func {
		var i = 0;
		foreach (var a; ["x-m", "y-m", "z-m", "heading-deg", "pitch-deg", "roll-deg"] ) {
			me._list[i] = "/sim/TrackIR/" ~ a;
			i += 1;
		}
	},
#--------------------------------------------------
	update: func (dt) {
		for (var i = 0; i <= 5; i += 1)
			me._offsets_raw[i] = getprop(me._list[i]) or 0;

		me._rotate();

		for (var i = 0; i <= 5; i += 1)
			me.offsets[i] = me._lp[i].filter(me._offsets_raw[i], ht_filter);
	},
#--------------------------------------------------
	_rotate: func {
		var a = offsets[3] * D2R; #math.pi / 180;
		var c = cos(a);
		var s = sin(a);

		var x =  me._offsets_raw[0] * c + me._offsets_raw[2] * s;
		var z = -me._offsets_raw[0] * s + me._offsets_raw[2] * c;

		me._offsets_raw[0] = x;
		me._offsets_raw[2] = z;
	},
};
