var prop = props.globals.initNode("/sim/fgcamera/load-all-modules",0,"INT");

var modules_loaded = 0;
var modules_obj = {};
var modules_list = ["fgcamera","version","gui","commands","io","view_movement","DHM","RND_","headtracker","offsets_manager"];

var load_nasal = func (debugLevel) {
    var path = getprop("/sim/fg-aircraft") ~ "/G91-R1B_HD";
    ## print(debug.dump(modules_obj));
	foreach (var script; modules_list) {
        if (modules_loaded == 0) {
            modules_obj[script] = modules.Module.new(script);
            modules_obj[script].setNamespace("fgcamera");
            modules_obj[script].setDebug(debugLevel - 1);
            modules_obj[script].setFilePath(getprop("/sim/aircraft-dir")~"/Nasal/fgcamera/nas");
            modules_obj[script].setMainFile(script ~ ".nas");
            modules_obj[script].load();
        } else {
            ## modules_obj[script].reload();
        };
        ## print("fgcamera.nas load_nasal script: ",getprop("/sim/aircraft-dir")~"/Nasal/fgcamera/nas/" ~ script ~ ".nas");
		
        ## io.load_nasal( path ~ "/Nasal/fgcamera/nas/" ~ script ~ ".nas", "fgcamera" );
    };
    modules_loaded = 1;
    ## print(debug.dump(modules_obj));
}

#--------------------------------------------------
var _init_listener = setlistener("/sim/fgcamera/load-modules", func {
	
    if (getprop ("/sim/fgcamera/load-modules") >= 1) {

        setprop ("/sim/fgcamera/load-all-modules", 0);
        
        load_nasal(getprop("/sim/fgcamera/load-modules"));
        
        setprop ("/sim/fgcamera/load-all-modules", 1);
        setprop ("/sim/fgcamera/load-modules", 0);
    };
});


var reinit_listener = setlistener("/sim/signals/reinit", func {
	fgcommand("gui-redraw");
	fgcommand("fgcamera-reset-view");
	helicopterF = check_helicopter();
});

