var timeStep = 0.0;
var timeStepDivisor = 1.0;
var timeStepSecond = 1;

var isModelCreate = 0;

var submodel = nil;

#// Documentation
#//
#// http://wiki.flightgear.org/index.php?title=Scripted_AI_Objects&mobileaction=toggle_view_desktop
#//
#// https://github.com/NikolaiVChr/f16/blob/26930e822b41dc0009844974d68d59ec97236e7a/Nasal/missile-code.nas#L1340
#// https://github.com/l0k1/MiG-21bis/blob/4ba5367f83fe076bf76740d1bb8567bf11248a11/Nasal/payloads.nas#L1334



var StoreModelDataClass = {
    class_name: "StoreModelClass",
    
    new: func() {
        var obj = {
            latitude_deg: 0.0,
            longitude_deg: 0.0,
            elevation_ft: 0.0,
            heading_deg: 0.0,
            pitch_deg: 0.0,
            roll_deg: 0.0,
            idNode: -1,
            airplanePosition: nil;
        };
        return {parents: [StoreModelClass]};
    },
    
    init: func(idNode) {
        me.idNode = idNode;
    },
    
    setPosition: func(latitude_deg,longitude_deg,elevation_ft,heading_deg,pitch_deg,roll_deg) {
        me.latitude_deg = latitude_deg;
        me.longitude_deg = longitude_deg;
        me.elevation_ft = elevation_ft;
        me.heading_deg = heading_deg;
        me.pitch_deg = pitch_deg;
        me.roll_deg = roll_deg;
    },
    
    setToAirplanePosition: func() {
        me.airplanePosition = geo.aircraft_position();
        me.setPosition(me.airplane.lat(),me.airplane.lon(),me.airplane.alt() * M2F,
            getNode("orientation/heading-deg"),
            getNode("orientation/pitch-deg"),
            getNode("orientation/roll-deg")
        );
    },
};


var store = func() {
    
    var airplane = geo.aircraft_position();
    if (timeStepSecond == 1 and isModelCreate == 0) {
        if (getprop("fdm/jsbsim/systems/store/stations/dx/external/type") == 20) {
            var path = "Aircraft/G91-R1B_HD/Models/Parts/Stores/Bombs/Mk81-250lb_ext_dx.xml";
            geo.put_model(path, airplane.lat(), airplane.lon(), airplane.alt() + 3.0);
            isModelCreate = 1;
            var list = props.globals.getNode("/models").getChildren("model");
            var total = size(list);
            print("store activate: total = ",total);
            for(var i = 0; i < total; i += 1) {
                var path_found = list[i].getNode("path").getValue();
                if (path_found == path) {
                    print("store activate: path_found = ",path_found);
                    submodel = StoreModelDataClass.new().init(i).setToAirplanePosition();
                }
            }
        }
    }
    if (isModelCreate == 1) {
        setprop("fdm/jsbsim/systems/store/stations/dx/external/lat",airplane.lat());
        setprop("fdm/jsbsim/systems/store/stations/dx/external/lon",airplane.lon());
        setprop("fdm/jsbsim/systems/store/stations/dx/external/elevation-ft",airplane.alt() * M2F + 10.0);
        # setprop("fdm/jsbsim/systems/store/stations/dx/external/heading-deg",airplane.);
    }
    
}


var store_control = func() {
    
    pilot_assistantTimer.restart(timeStep / timeStepDivisor);

    store();
    
    if (timeStepSecond == 1) timeStepSecond = 0;

}


var pilot_assistantTimer = maketimer(timeStep, store_control);
pilot_assistantTimer.singleShot = 1;
pilot_assistantTimer.start(); 

var pilot_imp_timerLog = maketimer(1, func() {timeStepSecond = 1;});
pilot_imp_timerLog.start();
