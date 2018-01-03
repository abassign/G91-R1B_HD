# Fuel System Collect_tank_2_all_tank

var prop = props.globals.initNode("sim/G91/fuel/fuel_pounds_display", 0.0, "DOUBLE");

var set_fuel_pounds_display = maketimer(0.5, func() {
    var collectTank_2_AllTank = props.globals.getNode("sim/G91/switchs/cockpit/sw_collect_tank_2_all_tank",1);
    if (collectTank_2_AllTank.getValue()) {
        var tank5Lbs = props.globals.getNode("fdm/jsbsim/propulsion/tank[5]/contents-lbs",1);
        setprop("sim/G91/fuel/fuel_pounds_display",tank5Lbs.getValue() * 2.7);
    } else {
        var tank_012 = props.globals.getNode("fdm/jsbsim/propulsion/tank[0]/contents-lbs",1).getValue();
        tank_012 = tank_012 + props.globals.getNode("fdm/jsbsim/propulsion/tank[1]/contents-lbs",1).getValue();
        tank_012 = tank_012 + props.globals.getNode("fdm/jsbsim/propulsion/tank[2]/contents-lbs",1).getValue();
        setprop("sim/G91/fuel/fuel_pounds_display",tank_012);
    }
});
set_fuel_pounds_display.start();
