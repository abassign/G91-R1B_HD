var timeStep = 0.0;
var timeStepDivisor = 1.0;
var timeStepSecond = 1;

var isModelCreate = 0;
var i_found = nil;


var StoreModelClass = {
    class_name: "StoreModelClass",
    
    new: func() {
        var obj = {
            prop_set_latitude_deg: nil,
            prop_set_longitude_deg: nil,
            prop_set_elevation_m: nil,
            prop_set_heading_deg: nil,
            prop_set_pitch_deg: nil,
            prop_set_roll_deg: nil,
            id: nil,
        };
        return {parents: [StoreModelClass]};
    },
    
    init: func() {
        
    },
};


var store = func() {
    
    var airplane = geo.aircraft_position();
    if (timeStepSecond == 1 and isModelCreate == 0) {
        if (getprop("fdm/jsbsim/systems/store/stations/dx/external/type") == 20) {
            var path = "Aircraft/G91-R1B_HD/Models/Parts/Stores/Bombs/Mk81-250lb_ext_dx.xml";
            # geo.put_model(path, airplane.lat(), airplane.lon(), airplane.alt() + 3.0);
            isModelCreate = 1;
            var list = props.globals.getNode("/models").getChildren("model");
            var total = size(list);
            print("store activate: total = ",total);
            for(var i = 0; i < total; i += 1) {
                var path_found = list[i].getNode("path").getValue();
                if (path_found == path) {
                    print("store activate: path_found = ",path_found);
                    i_found = i;
                }
            }
        }
    }
    if (isModelCreate == 1) {
        setprop("fdm/jsbsim/systems/store/stations/dx/external/lat",airplane.lat());
        setprop("fdm/jsbsim/systems/store/stations/dx/external/lon",airplane.lon());
        setprop("fdm/jsbsim/systems/store/stations/dx/external/elevation-ft",airplane.alt() * 3.28084 + 10.0);
        # setprop("fdm/jsbsim/systems/store/stations/dx/external/heading-deg",airplane.);
    }
    
}


var store_control = func() {
    
    pilot_assistantTimer.restart(timeStep / timeStepDivisor);

    #store();
    
    if (timeStepSecond == 1) timeStepSecond = 0;

}


var pilot_assistantTimer = maketimer(timeStep, store_control);
pilot_assistantTimer.singleShot = 1;
pilot_assistantTimer.start(); 

var pilot_imp_timerLog = maketimer(1, func() {timeStepSecond = 1;});
pilot_imp_timerLog.start();
