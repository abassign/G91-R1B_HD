var prop = props.globals.initNode("sim/G91/menu/command",0,"INT");
var prop = props.globals.initNode("sim/G91/menu/menuActive","nil","STRING");

var commandMemory = nil;
var doublePushActive = 0;
var lastMenuActive = "F1Menu";

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
dialogsMenu["Militar-Pilot-Assistant"] = ["sim/gui/dialogs/G91/MilitarPilotAssistant/dialog","Aircraft/G91-R1B_HD/Dialogs/G91-Militar-Pilot-Assistant.xml",nil];
dialogsMenu["TestSystemsPlane"] = ["sim/gui/dialogs/G91/TestSystemsPlane/dialog","Aircraft/G91-R1B_HD/Dialogs/G91-test.xml",nil];


#// Menu listners


var closeMenuActive = func(menuActive) {
    if (menuActive != nil and dialogsMenu[menuActive][2] != nil) {
        dialogsMenu[menuActive][2].close();
        dialogsMenu[menuActive][2] = nil;
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
        return 1
    } else {
        return 0;
    };
};


var commandSet = func() {
    if (commandMemory != nil) {
        var command = commandMemory;
        if (command == 0) {
            var menuActive = getprop("sim/G91/menu/menuActive");
            if (doublePushActive > 1) {
                lastMenuActive = menuActive;
            };
            closeMenuActive(menuActive);
        } else {
            if (command == 1) {
                var menuActive = getprop("sim/G91/menu/menuActive");
                if (menuActive == "nil") {
                    if (doublePushActive > 1) {
                        menuActive = lastMenuActive;
                    } else {
                        menuActive = "F1Menu";
                    };
                    setprop("sim/G91/menu/menuActive",menuActive);
                } else {
                    if (menuActive == "F1Menu") {
                        command = 2;
                    } else {
                        closeMenuActive(menuActive);
                    };
                };
                menuActive = getprop("sim/G91/menu/menuActive");
                if (command == 1) {
                    if (menuActive == "nil") {
                        if (doublePushActive < 2) {
                            menuActive = "F1Menu";
                            openMenuActive(menuActive);
                        };
                    } else {
                        lastMenuActive = menuActive;
                        openMenuActive(menuActive);
                    };
                };
            };
            if (command == 2) {
                var menuActive = getprop("sim/G91/menu/menuActive");
                closeMenuActive(menuActive);
            };
        };
    };
    commandMemory = nil;
    doublePushActive = 0;
};


var delayTimer = maketimer(0.5, commandSet);
delayTimer.singleShot = 1;


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

    if (command == 1) {
        if (doublePushActive > 0) {
            doublePushActive += 1;
        } else {
            commandMemory = command;
            doublePushActive = 1;
            delayTimer.start();
        };
    } else {
        commandMemory = command;
        commandSet();
    };

#//print("**** 2 sim/G91/menu/command : ",command, " | ",commandMemory," sim/G91/menu/menuActive: ",getprop("sim/G91/menu/menuActive")," doublePushActive: ",doublePushActive," lastMenuActive: ",lastMenuActive);

},1,1);



