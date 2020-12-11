var rate = 0.1; #150;
var rate2 = 5;
var scale = 1;

var DHM = {
	new : func (prop) {
		m = { parents : [ DHM ] };

		m.prop = prop;

		m.m = 0;
		m.c = 0;

		m.v0 = 0; m.v1 = 0;
		m.a0 = 0; m.a1 = 0;
		m.u0 = 0; m.u1 = 0;
		m.F0 = 0; m.F1 = 0;
		m.Fr = lowpass.new(0);

		m.output_filter = 0.1;
		m.output = lowpass.new(0);

		m.default_acc = 0;
		m.correction  = 0;

		m._bank   = 0;
		m._pitch  = 0;
		m.u_lim   = 0;

		m.constant_g = 0;
		m.impulse_g  = 0;

		m._offset = 0;

		return m;
	},

	offset : func (dt) {
		if ( dt > 0.04 ) dt = 0.03;

		me.a1 = ( getprop(me.prop) or me.default_acc ) * 0.3048 + me.correction;

		var Fi = me.m * (me.a1 * me.constant_g + (me.a1 - me.a0) * me.impulse_g);

		me.F1 = Fi - me.m * 10 * me.u0 / 1 - me.v0 * me.c - me.Fr.filter(Fi, rate);
		me.v1 = me.F1 / me.m * dt + me.v0;
		me.u1 = me.v1 * dt + me.u0;

		me.F0 = me.F1;
		me.v0 = me.v1;
		me.a0 = me.a1;
		me.u0 = me.u1;

		if ( math.abs(me.u0) >= me.u_lim )
			me._offset = math.sgn(me.u0) * me.u_lim;
		else me._offset = me.u0;

		me._offset = me.output.filter(me._offset, me.output_filter) * scale;
	},

	bank  : func { me._offset * me._bank  },
	pitch : func { me._offset * me._pitch },

	setMass        : func { me.m             = arg[0]; me },
	setDamping     : func { me.c             = arg[0]; me },
	setLimit       : func { me.u_lim         = arg[0]; me },
	setBank        : func { me._bank         = arg[0]; me },
	setPitch       : func { me._pitch        = arg[0]; me },
	setFilter      : func { me.output_filter = arg[0]; me },
	setDefault_acc : func { me.default_acc   = arg[0]; me },
	setCorrection  : func { me.correction    = arg[0]; me },
	setImpulseG    : func { me.impulse_g     = arg[0]; me },
	setConstantG   : func { me.constant_g    = arg[0]; me },
};

#==================================================
#	DHM effect handler
#==================================================
var DHM_handler = {
	parents : [ t_handler.new() ],

	free     : 1,

	_effect  : 1,
	_time    : 0,
	_updateF : 1,
#--------------------------------------------------
	init: func {
		me.dhm_y = DHM.new("/accelerations/pilot/z-accel-fps_sec");
		me.dhm_y.setMass(10)
		        .setDamping(30)
		        .setLimit(0.025)
		        .setDefault_acc(32.18516)
		        .setCorrection(9.81)
		        .setConstantG(0.05)
		        .setImpulseG(0.2)
		        .setPitch(50);

		me.dhm_x = DHM.new("/accelerations/pilot/y-accel-fps_sec");
		me.dhm_x.setMass(10)
		        .setDamping(30)
		        .setLimit(0.05)
		        .setBank(50)
		        .setImpulseG(0.4)
		        .setConstantG(0.5);

		me.dhm_z = DHM.new("/accelerations/pilot/x-accel-fps_sec");
		me.dhm_z.setMass(10)
		        .setDamping(30)
		        .setLimit(0.05)
		        .setImpulseG(0)
		        .setConstantG(0.25);
	},
#--------------------------------------------------
	_trigger: func {},
#--------------------------------------------------
	update: func (dt) {
		if ( !cameras[current[1]]["enable-DHM"] ) return;

		me.offsets[0] = me.dhm_x.offset(dt);
		me.offsets[1] = me.dhm_y.offset(dt);
		me.offsets[2] = me.dhm_z.offset(dt);
		me.offsets[4] = me.dhm_y.pitch();
		me.offsets[5] = me.dhm_x.bank();
	},
};