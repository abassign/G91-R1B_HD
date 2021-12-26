var prop = props.globals.initNode("sim/G91/menu/command",0,"INT");
var prop = props.globals.initNode("sim/G91/menu/menuActive","nil","STRING");


#// Setup dialogs menu

var dialogsMenu = {};

dialogsMenu["nil"] = [nil,nil,nil];
dialogsMenu["F1Menu"] = ["sim/gui/dialogs/G91/F1Menu/dialog","Aircraft/G91-R1B_HD/Dialogs/G91-F1Menu.xml",nil];
dialogsMenu["Pilot-Assistant"] = ["sim/gui/dialogs/G91/Autopilot/dialog","Aircraft/G91-R1B_HD/Dialogs/G91-Pilot-Assistant.xml",nil];
dialogsMenu["Configuration"] = ["sim/gui/dialogs/G91/Configuration/dialog","Aircraft/G91-R1B_HD/Dialogs/G91-Configuration.xml",nil];
dialogsMenu["Engine"] = ["sim/gui/dialogs/G91/Engine/dialog","Aircraft/G91-R1B_HD/Dialogs/G91-Engine.xml",nil];
dialogsMenu["Electric"] = ["sim/gui/dialogs/G91/Electric/dialog","Aircraft/G91-R1B_HD/Dialogs/G91-Electric.xml",nil];
dialogsMenu["Radio-Near-Selector"] = ["sim/gui/dialogs/G91/Radio/dialog","Aircraft/G91-R1B_HD/Dialogs/G91-Radio-Near-Selector.xml",nil];
dialogsMenu["PHI"] =["sim/gui/dialogs/G91/PHI/dialog","Aircraft/G91-R1B_HD/Dialogs/G91-PHI.xml",nil];
dialogsMenu["radio_ptr175"] = ["sim/gui/dialogs/G91/ptr175/dialog","Aircraft/G91-R1B_HD/Dialogs/G91-radio_ptr175.xml",nil];
dialogsMenu["Livery"] = ["sim/gui/dialogs/G91/Livery/dialog","Aircraft/G91-R1B_HD/Dialogs/G91-Livery.xml",nil];
dialogsMenu["JATO"] = ["sim/gui/dialogs/G91/JATO/dialog","Aircraft/G91-R1B_HD/Dialogs/G91-JATO.xml",nil];
dialogsMenu["Acro"] = ["sim/gui/dialogs/G91/Acro/dialog","Aircraft/G91-R1B_HD/Dialogs/G91-Acro.xml",nil];
dialogsMenu["Accessories"] = ["sim/gui/dialogs/G91/Accessories/dialog","Aircraft/G91-R1B_HD/Dialogs/G91-Accessories.xml",nil];
dialogsMenu["Effects"] = ["sim/gui/dialogs/G91/Effects/dialog","Aircraft/G91-R1B_HD/Dialogs/G91-Effects.xml",nil];
dialogsMenu["TestSystemsPlane"] = ["sim/gui/dialogs/G91/TestSystemsPlane/dialog","Aircraft/G91-R1B_HD/Dialogs/G91-test.xml",nil];


#// Menu listners


var closeMenuActive = func(menuActive) {
    if (menuActive != nil and dialogsMenu[menuActive][2] != nil) {
        dialogsMenu[menuActive][2].close();
        dialogsMenu[menuActive][2] = nil;
print("**** 3 sim/G91/menu/menuActive : ",menuActive," -> close");
        setprop("sim/G91/menu/menuActive","nil");
        return 1;
    };
    return 0;
};


var openMenuActive = func(menuActive) {
    #// Close all open menu
    if (menuActive != nil) {
        foreach(dialogMenuIndex; keys(dialogsMenu)) {
            if (dialogsMenu[dialogMenuIndex][2] != nil) {
                closeMenuActive(dialogMenuIndex);
            };
        };
        #// Open menuActive
        dialogsMenu[menuActive][2] = gui.Dialog.new(dialogsMenu[menuActive][0],dialogsMenu[menuActive][1]);
        dialogsMenu[menuActive][2].open();
        setprop("sim/G91/menu/menuActive",menuActive);
print("**** 6 sim/G91/menu/menuActive : ",menuActive," -> open");
        return 1
    } else {
        return 0;
    };
};


setlistener("sim/G91/menu/menuActive", func {

    var menuActive = getprop("sim/G91/menu/menuActive");
    if (menuActive != "nil" and dialogsMenu[menuActive] != nil and dialogsMenu[menuActive][0] != nil) {
        setprop("sim/G91/menu/command",1);
    } else {
        setprop("sim/G91/menu/menuActive","nil");
    };

},1,1);


setlistener("sim/G91/menu/command", func {

    var command = getprop("sim/G91/menu/command");
print("**** 2 sim/G91/menu/command : ",command," sim/G91/menu/menuActive: ",getprop("sim/G91/menu/menuActive"));
    if (command == 0) {
        var menuActive = getprop("sim/G91/menu/menuActive");
        closeMenuActive(menuActive);
    } else {
        if (command == 1) {
            var menuActive = getprop("sim/G91/menu/menuActive");
            if (menuActive == "nil") {
                menuActive = "F1Menu";
                setprop("sim/G91/menu/menuActive",menuActive);
            } else {
                if (menuActive == "F1Menu") {
                    command = 2;
                } else {
                    closeMenuActive(menuActive);
                };
            };
            menuActive = getprop("sim/G91/menu/menuActive");
print("**** 4 sim/G91/menu/menuActive : ",menuActive);
            if (command == 1) {
                if (menuActive == "nil") menuActive = "F1Menu";
                openMenuActive(menuActive);
            };
        };
        if (command == 2) {
            var menuActive = getprop("sim/G91/menu/menuActive");
            closeMenuActive(menuActive);
        };
    };

    setprop("sim/G91/menu/command",0);

},0,1);


