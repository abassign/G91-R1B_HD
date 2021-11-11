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
    class_name: "StoreModelDataClass",
    
    new: func() {
        var obj = {
            callsign: nil,
            aiid: nil,
            latitude_deg: nil,
            longitude_deg: nil,
            altitude_ft: nil,
            heading_deg: nil,
            pitch_deg: nil,
            roll_deg: nil,
            true_airspeed_kt: nil,
            vertical_speed_fps: nil,
            idNode: -1,
            airplanePosition: nil,
            model: nil,
            modelPath: nil,
            ai: nil,
        };
        return {parents: [StoreModelDataClass]};
    },
    
    init: func(callsign,aiid,modelPath) {
        var n = props.globals.getNode("models", 1);
        #// Append aa empty model
        for (var i = 0; 1; i += 1) 
            if (n.getChild("model", i, 0) == nil) {
                #// m.model contiene un modello vuoto
                me.callsign = callsign;
                me.aiid = aiid;
                me.model = n.getChild("model", i, 1);
                me.idNode = i;
                me.modelPath = modelPath;
                me.model.getNode("path",1).setValue(modelPath);
                print("store.nas StoreModelDataClass,init create empty model idModel: ",me.idNode," dump: ",debug.dump(me.model));
                break;
            };
        #// Ai part to defined
        var n = props.globals.getNode("ai/models", 1);
        for (var i = 0; 1; i += 1) {
            var cn = n.getChild("submodel", i, 0);
            if (cn == nil)
                break;
            if (cn.getNode("id") == nil or cn.getNode("id").getValue() == nil)
                break;
        }
        me.ai = n.getChild("submodel", i, 1);
        me.ai.getNode("id", 1).setIntValue(me.aiid);
        me.ai.getNode("callsign", 1).setValue(me.callsign ~ "");
        me.ai.getNode("submodel", 1).setBoolValue(1);
        me.ai.getNode("valid", 1).setBoolValue(1);
        me.latitude_deg = me.ai.getNode("position/latitude-deg", 1);
        me.longitude_deg = me.ai.getNode("position/longitude-deg", 1);
        me.altitude_ft = me.ai.getNode("position/altitude-ft", 1);
        me.heading_deg = me.ai.getNode("orientation/true-heading-deg", 1);
        me.pitch_deg = me.ai.getNode("orientation/pitch-deg", 1);
        me.roll_deg = me.ai.getNode("orientation/roll-deg", 1);
        me.true_airspeed_kt = me.ai.getNode("velocities/true-airspeed-kt", 1);
        me.vertical_speed_fps = me.ai.getNode("velocities/vertical-speed-fps", 1);
        
        me.model.getNode("latitude-deg-prop", 1).setValue(me.latitude_deg.getPath());
        me.model.getNode("longitude-deg-prop", 1).setValue(me.longitude_deg.getPath());
        me.model.getNode("elevation-ft-prop", 1).setValue(me.altitude_ft.getPath());
        me.model.getNode("heading-deg-prop", 1).setValue(me.heading_deg.getPath());
        me.model.getNode("pitch-deg-prop", 1).setValue(me.pitch_deg.getPath());
        me.model.getNode("roll-deg-prop", 1).setValue(me.roll_deg.getPath());
        me.model.getNode("load", 1).remove();
    },
    
    setModelPosition: func(latitude_deg,longitude_deg,altitude_ft,heading_deg,pitch_deg,roll_deg,true_airspeed_kt = 0.0,vertical_speed_fps = 0.0) {
        # print("*****: ",latitude_deg," ",longitude_deg," ",altitude_ft," ",heading_deg," ",pitch_deg," ",roll_deg);
        print(debug.dump(me));
        me.latitude_deg.setDoubleValue(latitude_deg);
        me.longitude_deg.setDoubleValue(longitude_deg);
        me.altitude_ft.setDoubleValue(altitude_ft);
        me.heading_deg.setDoubleValue(heading_deg);
        me.pitch_deg.setDoubleValue(pitch_deg);
        me.roll_deg.setDoubleValue(roll_deg);
        me.true_airspeed_kt.setDoubleValue(me.ktas);
        me.vertical_speed_fps.setDoubleValue(0);
    },
    
    setToAirplanePosition: func() {
        me.airplanePosition = geo.aircraft_position();
        me.setModelPosition(me.airplanePosition.lat(),me.airplanePosition.lon(),me.airplanePosition.alt() * M2FT,
            getprop("orientation/heading-deg"),
            getprop("orientation/pitch-deg"),
            getprop("orientation/roll-deg"),
        );
    },
};


var store = func() {
            
    if (timeStepSecond == 1 and isModelCreate == 0) {
        if (getprop("fdm/jsbsim/systems/store/stations/dx/external/type") == 20) {
            var path = "Aircraft/G91-R1B_HD/Models/Parts/Stores/Bombs/Mk81-250lb_ext_dx.xml";
            isModelCreate = 1;
            submodel = StoreModelDataClass.new();
            submodel.init("abassign-Mk81-250lb_ext_dx",1,path);
            submodel.setToAirplanePosition();
print("***** store.nas - submodel: ",debug.dump(submodel));
        }
    }
    if (isModelCreate == 1) {
        submodel.setToAirplanePosition();
    }
    
}


var store_control = func() {
    
    pilot_assistantTimer.restart(timeStep / timeStepDivisor);

    ## store();
    
    if (timeStepSecond == 1) timeStepSecond = 0;

}


var pilot_assistantTimer = maketimer(timeStep, store_control);
pilot_assistantTimer.singleShot = 1;
pilot_assistantTimer.start(); 

var pilot_imp_timerLog = maketimer(1, func() {timeStepSecond = 1;});
pilot_imp_timerLog.start();
