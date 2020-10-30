#// Load/Unload the autopilot modules
#// This procedure allows you to load / unload the functions related to the autopilot management

#// Fore load NASAL modules look this: Difference between revisions of "Modules.nas"
#// http://wiki.flightgear.org/index.php?title=Modules.nas&diff=121661&oldid=121650

var prop = props.globals.initNode("sim/G91/nasal/modules/autopilot-active",0,"INT");
var prop = props.globals.initNode("sim/G91/nasal/modules/autopilot-active-mod",0,"INT");

var module_pilot_assistant = modules.Module.new("pilot_assistant"); # Module name
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
