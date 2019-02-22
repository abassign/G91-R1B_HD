var prop = props.globals.initNode("sim/G91/smoke/acrobatic/tank", 0, "DOUBLE");

#
# Acrobatic configuration
#

setlistener("sim/G91/smoke/acrobatic/tank", func {

    var acrobaticTank = props.globals.getNode("sim/G91/smoke/acrobatic/tank",1).getValue();
    
    var stationSxInternalTypeLoad = props.globals.getNode("sim/G91/stores/stationSxInternalTypeLoad",1).getValue();
    var stationDxInternalTypeLoad = props.globals.getNode("sim/G91/stores/stationDxInternalTypeLoad",1).getValue();
    
    print("Configurator: acrobaticTank = ", acrobaticTank);

    if (acrobaticTank > 0) {
        if (stationSxInternalTypeLoad == 0)  {
            setprop("sim/G91/stores/handleRequestToLoadType", 11);
            setprop("sim/G91/stores/handleRequestToLoadStation", 2);
            print("Configurator: acrobaticTank insert stationSxInternalTypeLoad = 11 handleRequestToLoadStation = 2");
        }
        if (stationDxInternalTypeLoad == 0)  {
            setprop("sim/G91/stores/handleRequestToLoadType", 11);
            setprop("sim/G91/stores/handleRequestToLoadStation", 3);
            print("Configurator: acrobaticTank insert stationSxInternalTypeLoad = 11 handleRequestToLoadStation = 3");
        }
    } else {
        if (stationSxInternalTypeLoad == 11)  {
            setprop("sim/G91/stores/handleRequestToLoadStation", -2);
            print("Configurator: acrobaticTank remove stationSxInternalTypeLoad = 11 handleRequestToLoadStation = 2");
        }
        if (stationDxInternalTypeLoad == 11)  {
            setprop("sim/G91/stores/handleRequestToLoadStation", -3);
            print("Configurator: acrobaticTank remove stationSxInternalTypeLoad = 11 handleRequestToLoadStation = 3");
        }
    }

}, 1, 0);

