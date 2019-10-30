# Pilot Impact control system for advert and resolv collision situations
#
# 2019-10-25 Adriano Bassignana
# GPL 2.0+

var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-control-active", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-control-allert", 0, "INT");

var timeStep = 1.0;
var timeStepDivisor = 1.0;
var delayCycleGeneral = 0;

var impact_control_active = 0;
var impact_allert = 0;

var impactTime_delayed_coefficient = 0.0;
var impactTime_0_time_delayed = 0.0;
var impactTime_0_time_delayed_factor = 2.0;


var calculate_impact_time = func(aircraftPosition, speed_fps, heading, speed_horz_fps, speed_down_fps) {
    var end = geo.Coord.new(aircraftPosition);
    end.apply_course_distance(heading, speed_horz_fps*FT2M);
    end.set_alt(end.alt()-speed_down_fps*FT2M);

    var dir_x = end.x()-aircraftPosition.x();
    var dir_y = end.y()-aircraftPosition.y();
    var dir_z = end.z()-aircraftPosition.z();
    var xyz = {"x":aircraftPosition.x(),"y":aircraftPosition.y(),"z":aircraftPosition.z()};
    var dir = {"x":dir_x,"y":dir_y,"z":dir_z};

    var geod = get_cart_ground_intersection(xyz, dir);
    if (geod != nil) {
        end.set_latlon(geod.lat, geod.lon, geod.elevation);
        var dist = aircraftPosition.direct_distance_to(end)*M2FT;
        var time = dist / speed_fps;
        return time;
    } else {
        return -1;
    }
}


var pilot_impact_control = func {
    
    # Application step timing
    
    impact_control_active = getprop("fdm/jsbsim/systems/autopilot/gui/impact-control-active");
    var impact_control_medium_time = getprop("fdm/jsbsim/systems/autopilot/gui/impact-medium-time");
    
    if (impact_control_active == 0) {
        timeStepDivisor = 10;
    } else {
        if (impact_allert <= 1) {
            timeStepDivisor = 5;
        } else {
            timeStepDivisor = 10;
        }
    }
    pilot_impact_controlTimer.restart(timeStep / timeStepDivisor);
    impactTime_delayed_coefficient = timeStep / timeStepDivisor;
    
    # Calculate aircraft position and velocity vector
    
    var aircraftPosition = geo.aircraft_position();
    var speed_down_fps  = getprop("velocities/speed-down-fps");
    var speed_east_fps  = getprop("velocities/speed-east-fps");
    var speed_north_fps = getprop("velocities/speed-north-fps");
    var speed_horz_fps  = math.sqrt((speed_east_fps*speed_east_fps)+(speed_north_fps*speed_north_fps));
    var speed_fps       = math.sqrt((speed_horz_fps*speed_horz_fps)+(speed_down_fps*speed_down_fps));
    var heading = 0;
    if (speed_north_fps >= 0) {
        heading -= math.acos(speed_east_fps/speed_horz_fps)*R2D - 90;
    } else {
        heading -= -math.acos(speed_east_fps/speed_horz_fps)*R2D - 90;
    }
    heading = geo.normdeg(heading);
    
    # Situation analisys
    
    if (impactTime_0_time_delayed > 1) {
        impactTime_0_time_delayed = impactTime_0_time_delayed - impactTime_0_time_delayed_factor * impactTime_delayed_coefficient;
    }
    
    var impactTime_0 = calculate_impact_time(aircraftPosition, speed_fps, heading, speed_horz_fps, speed_down_fps);
    if (impactTime_0 != nil) {
        if (impactTime_0 < impact_control_medium_time and impactTime_0 > -1) {
            impact_allert = 1;
            impactTime_0_time_delayed = impact_control_medium_time;
        } else if (impactTime_0 > impact_control_medium_time and impactTime_0 < (impact_control_medium_time * 2)) {
            impact_allert = 2;
            impactTime_0_time_delayed = impact_control_medium_time;
        } else if (impactTime_0_time_delayed <= 1.0) {
            impact_allert = 0;
        }
    } else {
        impact_allert = 0;
    }
    
    # Report the response
    
    setprop("fdm/jsbsim/systems/autopilot/gui/impact-control-allert",impact_allert);
    
    #### print("#### Pilot Impact Control",sprintf(" time 0 (s): %3.1f",impactTime_0),sprintf(" Allert: %1.0f",impact_allert),sprintf(" Delay: %3.1f",impactTime_0_time_delayed));
    
}

pilot_impact_controlTimer = maketimer(timeStep, pilot_impact_control);
pilot_impact_controlTimer.simulatedTime = 1;
pilot_impact_controlTimer.start();
