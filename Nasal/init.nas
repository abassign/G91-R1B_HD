#// Mass inertia modifier default

var cg_x_weight = getprop("sim/G91/configuration/inertia/modifier/cg-x-weight-value-lib-default");
var cg_x_shift = getprop("sim/G91/configuration/inertia/modifier/cg-x-shift-percent-default");
setprop("/fdm/jsbsim/inertia/modifier/cg-x-weight-value-lib-default",cg_x_weight);
setprop("/fdm/jsbsim/inertia/modifier/cg-x-weight-value-lib",cg_x_weight);
setprop("/fdm/jsbsim/inertia/modifier/cg-x-shift-percent-default",cg_x_shift);
setprop("/fdm/jsbsim/inertia/modifier/cg-x-shift-percent",cg_x_shift);
if (cg_x_weight > 0.0 and cg_x_shift != 0.0) {
    setprop("fdm/jsbsim/inertia/modifier/cg-x-weight-active-default",1);
};
