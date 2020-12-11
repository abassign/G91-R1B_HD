#var rnd_effectN = props.Node.new();
var rnd         = [,,]; # [] - ?

var update_rnd_data = func { rnd = []; rnd = cameras[current[1]].RND }
#rnd[0] = {
#	GEN: [
#		{sine: [0, 0, 0], resonance: [0, 2, 6, 0.5, 3, 0.005], noise: [1, 2.39, 0.04], LFO1: [0, 2.0, 0.43, 0.06], LFO2: [1, 2.0, 0.43, 0.06]},
#		{sine: [0, 0, 0], resonance: [1, 2.0, 3.0, 0.2, 0.7, 0.06], noise: [1, 4.24, 0.05], LFO1: [0, 2.1, 0.3, 0.005], LFO2: [0, 2, 0.1, 0.02]},
#		{sine: [0, 0, 0], resonance: [1, 1.7, 1.9, 0.1, 0.4, 0.09], noise: [1, 3.28, 0.12], LFO1: [0, 5, 0.3, 0.005], LFO2: [0, 2, 0.1, 0.02]},
#	],
#	mixer: {x:[0.93, 0.0, 0.0, 0.43], y:[0.0, 0.53, 0.0, 0.32], z:[0.0, 0.11, 0.0, 0.37], h:[0,0,0,0], p:[0,0.9,0,0.1], r:[1.0, 0, 0.85, 0.25], s: 1.0},
#	curves: {
#		v2: [0, 1.62, 3.23, 5.4, 10.8, 16.2, 32.4, 48.6, 70.2, 110],
#		level: [0, 0.9, 0.98, 1.0, 0.99, 0.97, 0.91, 0.8, 0.6, 0.2],
#		filter:[0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.15, 0.05, 0.01, 0.0],
#	},
#};
#rnd[1] = {
#	GEN: [
#		{sine: [0, 0, 0], resonance: [0, 2, 6, 0.5, 3, 0.005], noise: [1, 2.39, 0.04], LFO1: [0, 2.0, 0.43, 0.06], LFO2: [1, 2.0, 0.43, 0.06]},
#		{sine: [0, 0, 0], resonance: [1, 2.0, 3.0, 0.2, 0.7, 0.06], noise: [1, 4.24, 0.05], LFO1: [0, 2.1, 0.3, 0.005], LFO2: [0, 2, 0.1, 0.02]},
#		{sine: [0, 0, 0], resonance: [1, 1.7, 1.9, 0.1, 0.4, 0.09], noise: [1, 3.28, 0.12], LFO1: [0, 5, 0.3, 0.005], LFO2: [0, 2, 0.1, 0.02]},
#	],
#	mixer: {x:[0.93, 0.0, 0.0, 0.43], y:[0.0, 0.53, 0.0, 0.32], z:[0.0, 0.11, 0.0, 0.37], h:[0,0,0,0], p:[0,0.9,0,0.1], r:[1.0, 0, 0.85, 0.25], s: 1.0},
#	curves: {
#		v2: [0, 1.62, 3.23, 5.4, 10.8, 16.2, 32.4, 48.6, 70.2, 110],
#		level: [0, 0.9, 0.98, 1.0, 0.99, 0.97, 0.91, 0.8, 0.6, 0.2],
#		filter:[1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
#	},
#};

#==================================================
#
#==================================================
var sine = {
	new: func {
		var m = { parents: [sine] };

		m.f       = 4;
		m.A       = 0.001;
		m.T       = 0;
		m.enabled = 0;
		m._offset = 0;
		m.output  = 0;

		return m;
	},
#--------------------------------------------------
	offset: func(dt) {
		if (!me.enabled) return me.output = 0;

		me.T += dt;
		me.output = sin(2 * math.pi * me.f * me.T);

		me._offset = me.output * me.A;
	},
#--------------------------------------------------
	set: func(v) {
		var i = 0;
		foreach(var a; ["enabled", "f", "A"]) {
			me[a] = v[i];
			i += 1;
		}
	},
};

#==================================================
#
#==================================================
var resonance = {
	new: func {
		var m = { parents: [resonance] };

		m.f              = 5.0;
		m.attack         = 0.25;
		m.release        = 0.5;
		m.intensity      = 3.0;
		m.A              = 0.002;
		m.A2             = 1;
		m.enabled        = 0;
		m._offset        = 0;
		m.output         = 0;
		m.output_raw     = 0;
		m.T              = 0;
		m.T2             = 0;
		m._bump_T        = 0;
		m.lp1            = lowpass.new();
		m.lp2            = lowpass.new();

		return m;
	},
#--------------------------------------------------
	offset: func(dt) {
		if ( !me.enabled ) return me.output = 0;

		if ( me.T >= me._bump_T ) {
			me._bump_T = me.intensity * rand();
			me.lp1.set(me.output_raw);
			me.lp2.set(0);
			me.T = 0;
		}

		var a = me.lp1.filter(1, me.attack);
		me.output_raw = a - me.lp2.filter(a, me.release);

		me.T  += dt;
		me.T2 += dt;

		me.output = me.output_raw * cos(2 * math.pi * me.f * me.T2);
		me._offset = me.output * me.A;
	},
#--------------------------------------------------
	set: func(v) {
		var i = 0;
		foreach(var a; ["enabled", "f", "intensity", "attack", "release", "A"]) {
			me[a] = v[i];
			i += 1;
		}
	},
};

#==================================================
#
#==================================================
var noise = {
	new: func {
		var m = { parents: [noise] };

		m.f       = 3.0;
		m.A       = 0.005;
		m.A2      = 0;
		m.dir     = 1;
		m.enabled = 1;
		m._offset = 0;
		m.output  = 0;
		m.T       = 0;
		m.lp      = lowpass.new();

		return m;
	},
#--------------------------------------------------
	offset: func(dt) {
		if ( !me.enabled ) return me.output = 0;

		if ( me.T >= (1 / me.f) ) {
			me.T = 0;
			#me.dir *= -1;
			me.A2 = rand() * me.f / 9; # * math.sgn(0.5 - rand());
		}

		me.output = me.lp.filter(me.A2, 0.1) * sin(2 * math.pi * me.f * me.T);
		#me.output = me.A2 * (cos(2 * math.pi * me.f * me.T) - 1) / 2;
		me.T += dt;

		me._offset = me.output * me.A;
	},
#--------------------------------------------------
	set: func(v) {
		var i = 0;
		foreach(var a; ["enabled", "f", "A"]) {
			me[a] = v[i];
			i += 1;
		}
	},
};

#==================================================
#
#==================================================
var LFO1 = {
	new: func {
		var m = { parents: [LFO1] };

		m.f              = 3; # actually 2 * f
		m.L              = 5.0;
		m.intensity      = 15.0;
		m.filter         = 0;
		m.A              = 0.005;
		m.A2             = 0;
		m.A3             = 0;
		m.dir            = 1; 
		m.enabled        = 1;
		m.output         = 0;
		m.output_raw     = 0;
		m.lp1            = lowpass.new();
		m.lp2            = lowpass.new();
		m.lp3            = lowpass.new();
		m._offset        = 0;
		m.T              = 0;
		m._bump_T        = 0;

		return m;
	},
#--------------------------------------------------
	offset: func(dt) {
		if ( !me.enabled ) return me.output = 0;

		if (me.T >= me._bump_T) {
			srand();
			me._bump_T = 0.4 + ( me.intensity - 0.4 ) * rand();

		var d = me.A3 - me.A2;
		if ( d >= 0 ) # moving up
			me.dir = ( me.A2 < 0 ? -1 : 1);
		else # moving down
			me.dir = ( me.A2 >= 0 ? 1 : -1);

			me.A2 = rand() * me.dir; #( me.A2 >= 0 ? 1 : -1 );

			#me.lp1.set(me.output);
			me.lp2.set(0);
			me.T = 0;
		}

		me.A3 = me.A2;
		me.A2 -= me.lp2.filter(me.A2, 0.5);
		me.output = me.lp1.filter(me.A2, me.filter);
		#if ( math.abs( var a = me.output - me.A2 ) < 0.1 )
		#	me.A2 = 0;

		#me.output = me.lp2.filter(me.output_raw, 0.1);

		me.T  += dt;

		me._offset = me.A * me.output;
	},
#--------------------------------------------------
	set: func(v) {
		var i = 0;
		foreach(var a; ["enabled", "intensity", "filter", "A"]) {
			me[a] = v[i];
			i += 1;
		}
	},
};

#==================================================
#
#==================================================
var LFO2 = {
	new: func {
		var m = { parents: [LFO2] };
		m.enabled        = 1;
		m.A              = 0.01;
		m.A2             = 0;
		m.T              = 0;
		m.intensity      = 1;
		m._dir           = 1;
		m._bump          = 1;
		m._bump_T        = 0;
		m._offset        = 0;
		m.output         = 0;
		m.output_raw     = 0;
		m._stored_offset = 0;
		m._t             = 0.4;
		m.lp             = lowpass.new();
		m.filter         = 0;
		return m;
	},
#--------------------------------------------------
	offset: func(dt) {
		if ( !me.enabled ) return me.output = 0;

		if (me.T >= me._bump_T) {
			srand();
			me._bump_T = me._t + (me.intensity - me._t) * rand();
			me._stored_offset = me.output_raw;
			me._dir *= -1;
			me.A2 = (1 - me._dir * me._stored_offset) * rand() * me._dir;

			me._bump = 1;
			me.T     = 0;
		}

		if (me._bump) {
			me.output_raw = me._stored_offset - me.A2 * ( cos (math.pi * me.T / me._t) - 1 ) / 2;
			if (me.T >= me._t) me._bump = 0;
		} else me.output_raw = me.A2 + me._stored_offset;

		me.T += dt;
		me.output = me.lp.filter(me.output_raw, me.filter);
		me._offset = me.A * me.output;
	},
#--------------------------------------------------
	set: func(v) {
		var i = 0;
		foreach(var a; ["enabled", "intensity", "filter", "A"]) {
			me[a] = v[i];
			i += 1;
		}
	},
};

#==================================================
#
#==================================================
var generator = {
	new: func {
		var m = { parents : [generator] };

		m._gen    = [];
		m._offset = 0;

		foreach (var a; [sine, resonance, noise, LFO1, LFO2])
			append(m._gen, a.new());

		return m;
	},
#--------------------------------------------------
	_update: func (dt) {
		me._offset = 0;

		forindex (var i; me._gen)
			me._offset += me._gen[i].offset(dt);

		return me._offset;
	},
#--------------------------------------------------
	set: func(data) {
		var i = 0;
		foreach(var a; ["sine", "resonance", "noise", "LFO1", "LFO2"]) {
			me._gen[i].set(data[a]);
			i += 1;
		}
	},
};

var hp_coeff = 0.5;
var hp = hi_pass.new();
#==================================================
#	RND effects handler
#==================================================
var RND_handler = {
	parents  : [ t_handler.new() ],

	free     : 1,
	GUI_edit : 0, # 0 / 1
	GUI_mode : 0, # 0 - ground; 1 - air;
	G_output : [,,,],
	_effect  : 1,
	_updateF : 1,
	_wow     : [1, 1, 1],
	_gnd     : 0,
	_mode    : 0, # 0 - ground; 1 - air;
	_GEN     : [],
#--------------------------------------------------
	init: func {
		update_rnd_data();

		for (var i = 0; i <= 2; i += 1)
			append(me._GEN, generator.new());

		me._set_generators();
	},
#--------------------------------------------------
	_set_generators: func {
		for (var i = 0; i <= 2; i += 1)
			me._GEN[i].set(rnd[me._mode].GEN[i]);

		setprop("/sim/fgcamera/current-camera/RND-updated", 1); #trigger GUI update
	},
#--------------------------------------------------
	start: func {
		var get_wow = func (i) me._wow[i] = getprop("/gear/gear[" ~ i ~ "]/wow");

		me._listeners = [
			setlistener( "/gear/gear/wow",    func { get_wow(0) }, 1, 0 ),
			setlistener( "/gear/gear[1]/wow", func { get_wow(1) }, 1, 0 ),
			setlistener( "/gear/gear[2]/wow", func { get_wow(2) }, 1, 0 ),
			setlistener( "/sim/fgcamera/current-camera/camera-id", func { update_rnd_data(); me._set_generators() } ),
		];
	},
#--------------------------------------------------
	update: func (dt) {
		if ( !cameras[current[1]]["enable-RND"] ) {
			me.offsets = zeros(6);
			return;
		}

		var prev_mode = me._mode;
#---
		if ( me.GUI_edit ) {
			hp_coeff  = 0;
			var level = 1;
			me._mode  = me.GUI_mode;
		} else {
			me._mode = me._check_mode();
			if ( !helicopterF )
				var v = getprop("/velocities/groundspeed-kt");
			else var v = getprop("/rotors/main/rpm");
			if ( v < 0 ) v = 0;

			hp_coeff  = me._find_value(rnd[me._mode].curves.v2, rnd[me._mode].curves.filter, v);
			var level = me._find_value(rnd[me._mode].curves.v2, rnd[me._mode].curves.level,  v);
		}
#---
		if ( prev_mode != me._mode ) me._set_generators();

		#var output = [,,,];
		#for (var i = 0; i <= 2; i += 1) #why not "forindex" ?
		forindex(var i; me.G_output)
			me.G_output[i] = me._GEN[i]._update(dt);

		var i = 0;
		foreach (var dof; me._list) {
			var offset = 0;

			for (var gen = 0; gen <= 2; gen += 1)
				offset += rnd[me._mode].mixer[dof][gen] * me.G_output[gen];

			var b = movement_handler.blend;
			me.offsets[i] = me._lp[i].filter(offset * rnd[me._mode].mixer[dof][3] * level * rnd[me._mode].mixer.s, hp_coeff) * b;
			if ( i > 2 ) me.offsets[i] *= 50;

			i += 1;
		}
	},
#--------------------------------------------------
	_find_value: func (x_vector, y_vector, x_value) {
		for ( var i = 0; 1; i += 1 )
			if ( x_value <= x_vector[i] )
				break;
			elsif ( i == 9 ) {
				x_value = x_vector[i];
				break;
			}

		linterp ( x_vector[i-1], y_vector[i-1], x_vector[i], y_vector[i], x_value );
	},
#--------------------------------------------------
	_check_mode: func { # 0 - ground; 1 - air
		foreach (var a; me._wow)
			if ( a ) return 0;

		return 1;
	},
};
#end