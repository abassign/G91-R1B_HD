#// Load/Unload the autopilot modules
#// This procedure allows you to load / unload the functions related to the autopilot management

#// Fore load NASAL modules look this: Difference between revisions of "Modules.nas"
#// http://wiki.flightgear.org/index.php?title=Modules.nas&diff=121661&oldid=121650

#// Global variables must be activated before running the XML applications that manage them,
#// otherwise they call them and do not see the coincidence of the type. For this they are declared here.

var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/engage-pilot-assistant",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/engage-pilot-assistant-value",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/engage-pilot-assistant-msg","not operative","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_name", "", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_id", "", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_id", "", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_landing_scan",0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_name_direct","","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_name_direct_old","","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/status",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/airport_select","","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/airport_select_num",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/airport_select_num_seq",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/airport_select_mod",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rws","", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw_select",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw_select_description","","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw_select_mod",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/rw_airport_select","", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/airport_id_names","","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct/airport_id_name_select",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct_max_distance",1300,"DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_name_direct_extended","", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_nearest", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_landing_status", "Autolanding inactive", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_landing_status_id", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/take-off-status", "Take off inactive", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/take-off-jato-active", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_distance", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_delta_altitude", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-control-geo-is-nil","");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-minimal-length-m", 1000, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/dragchute/active-view", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-dist-nm", 15, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-holding-point-h-ft", 5000, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-activate-prepare", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-activate", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-activate-status", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landig-status-id", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landig-sub-status-id", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-airport-search-max-heading", 75.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-rwy-search-distance-max", 100.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-short-profile", 1.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-max-lateral-wind", 10.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-holding-altitude-min", 10.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/take-off-activate", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/take-off-altitude-top", 15000.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/take-off-altitude-top-active", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/take-off-to-heading", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/take-off-to-heading-active", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/take-off-cruise-speed", 350.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/take-off-cruise-speed-active", 0.0, "DOUBLE");

#// Landig PID parameters
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-rwy-h-offset-nm", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/landing-rwy-v-offset-ft", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing-PID-kp", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing-PID-ki", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing-PID-kd", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing-PID-ku", 15.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing-PID-tu", 120.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing-PID-gain", 1.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing22-dif-dh-dt", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing-slope-target", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing-slope-error", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing-altitude_agl_ft", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_slope", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing22-pid-p", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing22-pid-i", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing22-pid-d", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing22-landing-slope", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/landing21-holding_point-dist", 0.0, "DOUBLE");

var prop = props.globals.initNode("sim/G91/nasal/modules/autopilot-active",0,"INT");
var prop = props.globals.initNode("sim/G91/nasal/modules/autopilot-active-mod",0,"INT");


#// Load module
var module_pilot_assistant = modules.Module.new("pilot_assistant");
#// Load correlate modules
var module_pilot_impact_control = modules.Module.new("pilot_impact_control");
var module_pilot_intercept = modules.Module.new("pilot_intercept");


setlistener("sim/G91/nasal/modules/autopilot-active-mod", func {

    if ((getprop("sim/G91/nasal/modules/autopilot-active-mod") == 1 or
        getprop("sim/G91/nasal/modules/autopilot-active-mod") == 2) and
        getprop("sim/G91/nasal/modules/autopilot-active") == 0) {
        
        #// 0=(mostly) silent; 1=print setlistener and maketimer calls to console; 2=print also each listener hit, be very careful with this! 
        module_pilot_assistant.setDebug(1);
        module_pilot_assistant.setFilePath(getprop("/sim/aircraft-dir")~"/Nasal/autopilot");
        module_pilot_assistant.setMainFile("pilot_assistant.nas");
        module_pilot_assistant.load();
        
        module_pilot_impact_control.setDebug(0);
        module_pilot_impact_control.setFilePath(getprop("/sim/aircraft-dir")~"/Nasal/autopilot");
        module_pilot_impact_control.setMainFile("pilot_impact_control.nas");
        module_pilot_impact_control.load();
        
        module_pilot_intercept.setDebug(0);
        module_pilot_intercept.setFilePath(getprop("/sim/aircraft-dir")~"/Nasal/autopilot");
        module_pilot_intercept.setMainFile("pilot_intercept.nas");
        module_pilot_intercept.load();
        
        setprop("sim/G91/nasal/modules/autopilot-active",1);
        
    } elsif (getprop("sim/G91/nasal/modules/autopilot-active-mod") == 2 and 
        getprop("sim/G91/nasal/modules/autopilot-active") == 1) {
        
        module_pilot_intercept.reload();
        module_pilot_impact_control.reload();
        module_pilot_assistant.reload();
        
    } elsif (getprop("sim/G91/nasal/modules/autopilot-active-mod") == 9 and
        getprop("sim/G91/nasal/modules/autopilot-active") == 1) {
        
        module_pilot_intercept.unload();
        module_pilot_impact_control.unload();
        module_pilot_assistant.unload();
        
        setprop("sim/G91/nasal/modules/autopilot-active",0);
        
    }
    
    setprop("sim/G91/nasal/modules/autopilot-active-mod",0);
    
}, 0, 1);
