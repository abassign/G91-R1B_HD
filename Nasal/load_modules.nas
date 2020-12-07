#// Load/Unload the autopilot modules
#// This procedure allows you to load / unload the functions related to the autopilot management

#// Fore load NASAL modules look this: Difference between revisions of "Modules.nas"
#// http://wiki.flightgear.org/index.php?title=Modules.nas&diff=121661&oldid=121650

#// Global variables must be activated before running the XML applications that manage them,
#// otherwise they call them and do not see the coincidence of the type. For this they are declared here.

#// Loading pilot_assistant parameters
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/engage-pilot-assistant",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/engage-pilot-assistant-trigger",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/engage-pilot-assistant-value",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/engage-pilot-assistant-msg","not operative","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_name", "", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_id", "", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_runway_id", "", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_landing_scan",0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_radar",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_name_direct","","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_name_direct_old","","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/pilot-ass-status-id", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/airport_select_id_direct_status",0,"INT");
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
var prop = props.globals.initNode("fdm/jsbsim/systems/dragchute/active-view", 0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/true-heading-radial-str","", "STRING");

#// Loading impact-control parameters
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-control-active", 0, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-control-freeze", 1, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-min-z-ft-mod", 200.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/impact-medium-time", 15.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/pilot-impact-control-t0", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/pilot-impact-control-t1", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/pilot-impact-control-t2", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/pilot-impact-control-t3", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/pilot-impact-control-t4", 0.0, "DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/altitude-QFE-set-active-text", 0.0, "STRING");

#// Loading pilot_intercept parameters
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-ai-mp",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-ai-mp-mod",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-ai-mp-msg","Type AI","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-control-mod",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-control-active-level",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-control-msg","Idle","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-distance",100, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-id-select",-1, "INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-id-mod",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-callsign-select","","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-callsign-mod",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-speed-mph-coefficient",32.0,"DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-altitude-offset",200.0,"DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/gui/interception-target-min-dist",0.1,"DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/interception-target-dist-nm",0,"DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/interception-target-speed-mph",0,"DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/interception-target-speed-max-mph",520,"DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/interception-target-speed-dif-mph",0,"DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/interception-target-total-found",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/interception-target-total-select",0,"INT");

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


#// The load module modules activation properties
var prop = props.globals.initNode("sim/G91/nasal/modules/active-autopilot",0,"INT");
var prop = props.globals.initNode("sim/G91/nasal/modules/active-radio",0,"INT");

#// The load module params
var prop = props.globals.initNode("sim/G91/nasal/modules/delta-time",1,"INT");

var delta_time = 1;

var set_active_autopilot = 0;
var set_active_radio = 0;

#// Load autopilot module
var module_pilot_assistant = modules.Module.new("pilot_assistant");
#// Load autopilot correlate modules
var module_pilot_impact_control = modules.Module.new("pilot_impact_control");
var module_pilot_intercept = modules.Module.new("pilot_intercept");
#// Load ausiliary nmodules
var module_pilot_radio_assistant = modules.Module.new("pilot_radio_assistant");


var main = func() {
    print("load_modules.nas load module");
}


var unload = func() {
    print("load_modules.nas unload module");
}


#// The params:
#// sim/G91/nasal/modules/set-active-autopilot
#// sim/G91/nasal/modules/set-active-radio
#// are defined in the ..Models/G91_Params.xml module

var load_modules = func() {
    
    var active_autopilot = getprop("sim/G91/nasal/modules/active-autopilot");
    var active_radio = getprop("sim/G91/nasal/modules/active-radio");

    #// set_active_... define the debug level 1 -> 0 etc ... 
    #// 0=(mostly) silent; 1=print setlistener and maketimer calls to console; 2=print also each listener hit, be very careful with this! 
        
    if (set_active_autopilot >= 1) {
        if (active_autopilot == 0) {
            module_pilot_assistant.setDebug(set_active_autopilot - 1);
            module_pilot_assistant.setFilePath(getprop("/sim/aircraft-dir")~"/Nasal/autopilot");
            module_pilot_assistant.setMainFile("pilot_assistant.nas");
            module_pilot_assistant.load();
            print("load_modules.nas load module [pilot_assistant.nas]");
            module_pilot_impact_control.setDebug(set_active_autopilot - 1);
            module_pilot_impact_control.setFilePath(getprop("/sim/aircraft-dir")~"/Nasal/autopilot");
            module_pilot_impact_control.setMainFile("pilot_impact_control.nas");
            module_pilot_impact_control.load();
            print("load_modules.nas load module [pilot_impact_control.nas]");
            module_pilot_intercept.setDebug(set_active_autopilot - 1);
            module_pilot_intercept.setFilePath(getprop("/sim/aircraft-dir")~"/Nasal/autopilot");
            module_pilot_intercept.setMainFile("pilot_intercept.nas");
            module_pilot_intercept.load();
            print("load_modules.nas load module [pilot_intercept.nas]");
            setprop("sim/G91/nasal/modules/active-autopilot",1);
        } else {
            module_pilot_intercept.setDebug(set_active_autopilot - 1);
            module_pilot_intercept.reload();
            print("load_modules.nas reload module [pilot_intercept.nas]");
            module_pilot_impact_control.setDebug(set_active_autopilot - 1);
            module_pilot_impact_control.reload();
            print("load_modules.nas reload module [pilot_impact_control.nas]");
            module_pilot_assistant.setDebug(set_active_autopilot - 1);
            module_pilot_assistant.reload();
            print("load_modules.nas reload module [pilot_assistant.nas]");
        };
        setprop("fdm/jsbsim/systems/autopilot/gui/engage-pilot-assistant-trigger",2);
        setprop("sim/G91/nasal/modules/set-active-autopilot",0);
    };
    
    if (set_active_radio >= 1) {
        if (active_radio == 0) {
            module_pilot_radio_assistant.setDebug(set_active_radio - 1);
            module_pilot_radio_assistant.setFilePath(getprop("/sim/aircraft-dir")~"/Nasal/autopilot");
            module_pilot_radio_assistant.setMainFile("pilot_radio_assistant.nas");
            module_pilot_radio_assistant.load();
            setprop("sim/G91/nasal/modules/active-radio",1);
            print("load_modules.nas load module [pilot_radio_assistant.nas]");
        } else {
            module_pilot_radio_assistant.setDebug(set_active_radio - 1);
            module_pilot_radio_assistant.reload();
            print("load_modules.nas reload module [pilot_radio_assistant.nas]");
        };
        setprop("sim/G91/nasal/modules/set-active-radio",0);
    };
        
};


var load_modules_control = func() {
    
    delta_time = getprop("sim/G91/nasal/modules/delta-time");
    set_active_autopilot = getprop("sim/G91/nasal/modules/set-active-autopilot");
    set_active_radio = getprop("sim/G91/nasal/modules/set-active-radio");

    if (set_active_autopilot != nil and set_active_radio != nil) {
        set_active_autopilot = set_active_autopilot + 0;
        set_active_radio = set_active_radio + 0;
        if (set_active_autopilot > 0 or
            set_active_radio > 0) load_modules();
    };
    
    load_modules_timer.restart(delta_time);
};


var load_modules_timer = maketimer(delta_time, load_modules_control);
load_modules_timer.singleShot = 1;
load_modules_timer.start();

