#// Camera utility mobile views by abassign (Adriano Bassignana) Bergamo nov. 2021
#//
#// Input position to go format:
#// sim/current-view/ab-camera/to/set-position","0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0" type STRING
#// Fields of record:
#// 0,   - Activation flag if 0 is not operative, 1 is operative, 2 operational, but save the location first
#// 0,   - /sim/current-view/view-number - Id view 0 is internal view
#// 0.0, - /sim/current-view/field-of-view (Zoom factor)
#// 0.0, - /sim/current-view/heading-offset-deg
#// 0.0, - /sim/current-view/pitch-offset-deg
#// 0.0, - /sim/current-view/x-offset-m -> Airplane Y axis
#// 0.0, - /sim/current-view/y-offset-m -> Airplane Z axis
#// 0.0, - /sim/current-view/z-offset-m -> Airplane X axis
#// 0.0, - waiting time before starting (seconds)
#// 0,0, - time to travel the space between the starting point and the ending point
#// 0.0  - waiting time after finishing the route before sending the finish signal
#//
#// Status variable indicating the status: "sim/current-view/ab-camera/to/status"
#//
#// 0 - Not active
#// 1 - Initial wait
#// 2 - Path along the line that connects the start and end points
#// 3 - Final wait
#// 9 - End of the process, lasts 1 second then returns to zero
#//
#// Command variable:
#// 0 - nothing
#// 1 - start
#// 2 - pause
#// 3 - stop the process
#// 11 - save the current active view
#// 12 - restore the saved view


var prop = props.globals.initNode("sim/current-view/ab-camera/to/set-position","0,0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0", "STRING");
var prop = props.globals.initNode("sim/current-view/ab-camera/to/status","0", "INT");
var prop = props.globals.initNode("sim/current-view/ab-camera/to/status-time","0.0", "DOUBLE");
var prop = props.globals.initNode("sim/current-view/ab-camera/to/command","0", "INT");


var ViewCamDataClass = {
    class_name: "ViewCamDataClass",

    new: func() {
        var obj = {
            active: 0,
            view_number: 0,
            field_of_view: 0.0,
            heading_offset_deg: 0.0,
            pitch_offset_deg: 0.0,
            x_offset: 0.0,
            y_offset: 0.0,
            z_offset: 0.0,
            start_wait_time: 0.0,
            duration_path_time: 0.0,
            end_wait_time: 0.0,
            status_current: 0,
        };
        return {parents: [ViewCamDataClass]};
    },

    init: func(active,view_number,field_of_view,heading_offset,pitch_offset,x_offset,y_offset,z_offset,start_wait_time,duration_path_time,end_wait_time) {
        me.view_number = view_number;
        me.field_of_view = field_of_view;
        me.heading_offset_deg = heading_offset;
        me.pitch_offset_deg = pitch_offset;
        me.x_offset = x_offset;
        me.y_offset = y_offset;
        me.z_offset = z_offset;
        me.start_wait_time = start_wait_time;
        me.duration_path_time = duration_path_time;
        me.end_wait_time = end_wait_time;
    },

    difDegNorm: func(fromAng,toAng,stepRemain) {
        a1 = fromAng;
        a2 = toAng;
        fromAngRad = fromAng * 0.0174533;
        toAngRad = toAng * 0.0174533;
        difRad = math.asin(math.sin(toAngRad) * math.cos(fromAngRad) - math.cos(toAngRad) * math.sin(fromAngRad)) / stepRemain;
        value = math.asin(math.sin(toAngRad) * math.cos(difRad) + math.cos(toAngRad) * math.sin(difRad)) / 0.0174533;
        return value;
    },

    getView: func() {
        me.view_number = getprop("/sim/current-view/view-number");
        me.field_of_view = getprop("/sim/current-view/field-of-view");
        me.heading_offset_deg = getprop("/sim/current-view/heading-offset-deg");
        me.pitch_offset_deg = getprop("/sim/current-view/pitch-offset-deg");
        me.x_offset = getprop("/sim/current-view/x-offset-m");
        me.y_offset = getprop("/sim/current-view/y-offset-m");
        me.z_offset = getprop("/sim/current-view/z-offset-m");
    },

    setView: func() {
        setprop("/sim/current-view/view-number",me.view_number);
        setprop("/sim/current-view/field-of-view",me.field_of_view);
        setprop("/sim/current-view/heading-offset-deg",me.heading_offset_deg);
        setprop("/sim/current-view/pitch-offset-deg",me.pitch_offset_deg);
        setprop("/sim/current-view/x-offset-m",me.x_offset);
        setprop("/sim/current-view/y-offset-m",me.y_offset);
        setprop("/sim/current-view/z-offset-m",me.z_offset);
    },

    goViewTo: func(to,stepRemain) {
        me.getView();
        me.view_number = to.view_number;
        me.field_of_view = me.field_of_view + (to.field_of_view - me.field_of_view)/stepRemain;
        me.heading_offset_deg = me.difDegNorm(me.heading_offset_deg,to.heading_offset_deg,stepRemain);
        me.pitch_offset_deg = me.difDegNorm(me.pitch_offset_deg,to.pitch_offset_deg,stepRemain);
        me.x_offset = me.x_offset + (to.x_offset - me.x_offset)/stepRemain;
        me.y_offset = me.y_offset + (to.y_offset - me.y_offset)/stepRemain;
        me.z_offset = me.z_offset + (to.z_offset - me.z_offset)/stepRemain;
        me.setView();
    },

};


var statusCamera = 0;
var idCameraPlay = nil;
var isMouseButtonActive = 0;
var offsetFromMouseSensor = 0.0;
var statusCameraActiveTime = 0.0;
var actualDeltaTime = 0.0;
var stepCameraRemain = 0;
var camera_save = ViewCamDataClass.new();
var camera_position = ViewCamDataClass.new();
var camera_to_position = ViewCamDataClass.new();


var strToViewCamData = func(strViewCamData) {

    var numViewCamData = [0,0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0];
    var vValues = split(",",strViewCamData);
    var i = 0;
    foreach (var sValue; vValues) {
        numViewCamData[i] = sValue;
        if (i == 10) return numViewCamData;
        i += 1;
    };
    return numViewCamData;

};


#// Timer sync for camera play

var cameraPlay = func(steadyClockSec) {

    if (statusCamera > 0) {
        var deltaSec = getprop("sim/time/delta-sec");
        if (deltaSec > 0.0) {
            #// The mouse moviment check
            isMouseButtonActive = 0;
            if (getprop("devices/status/mice/mouse/button[0]") or getprop("devices/status/mice/mouse/button[1]") or getprop("devices/status/mice/mouse/button[2]")) isMouseButtonActive = 1;
            if (offsetFromMouseSensor < 0.0) offsetFromMouseSensor = 0.0;
            if (isMouseButtonActive > 0) {
                offsetFromMouseSensor += 1.2 * deltaSec;
            } else {
                offsetFromMouseSensor -= 2.0 * deltaSec;
            };
            #// Display active process
            if (statusCamera == 1) {
                actualDeltaTime = steadyClockSec.getValue() - (statusCameraActiveTime + deltaSec);
                if (actualDeltaTime >= (camera_to_position.start_wait_time + offsetFromMouseSensor)) {
                    offsetFromMouseSensor = 0.0;
                    setprop("sim/current-view/ab-camera/to/status",2);
                };
                setprop("sim/current-view/ab-camera/to/status-time",int(actualDeltaTime * 10.0) / 10.0);
                setprop("sim/current-view/ab-camera/to/status-time-remain-msg",
                        sprintf("Time remain (s): %4.1f",(actualDeltaTime - (camera_to_position.start_wait_time + offsetFromMouseSensor))) ~ sprintf(" [%2.2f]",offsetFromMouseSensor));
#//    print("*** 1 : ",deltaSec," | ",statusCameraActiveTime," | ",actualDeltaTime," | ",camera_to_position.start_wait_time," | ",getprop("sim/current-view/ab-camera/to/status-time"));
            } else if (statusCamera == 2) {
                actualDeltaTime = steadyClockSec.getValue() - statusCameraActiveTime;
                stepCameraRemain = int(((camera_to_position.duration_path_time + offsetFromMouseSensor) - actualDeltaTime) / deltaSec);
                if (stepCameraRemain <= 0) {
                    offsetFromMouseSensor = 0.0;
                    setprop("sim/current-view/ab-camera/to/status",3);
                } else {
                    if (offsetFromMouseSensor < 0.01) {
                        camera_position.goViewTo(camera_to_position,stepCameraRemain);
                    };
                };
                setprop("sim/current-view/ab-camera/to/status-time",int(actualDeltaTime * 10.0) / 10.0);
                setprop("sim/current-view/ab-camera/to/status-time-remain-msg",
                        sprintf("Time remain (s): %4.1f",(actualDeltaTime - (camera_to_position.start_wait_time + offsetFromMouseSensor))) ~ sprintf(" [%2.2f]",offsetFromMouseSensor));
#//    print("*** 2 : ",deltaSec," | ",statusCameraActiveTime," | ",actualDeltaTime," | ",camera_to_position.duration_path_time," | ",stepCameraRemain," | ",getprop("sim/current-view/ab-camera/to/status-time"));
            } else if (statusCamera == 3) {
                actualDeltaTime = steadyClockSec.getValue() - (statusCameraActiveTime + deltaSec);
                if (actualDeltaTime >= (camera_to_position.end_wait_time + offsetFromMouseSensor)) {
                    offsetFromMouseSensor = 0.0;
                    setprop("sim/current-view/ab-camera/to/status",9);
                };
                if (offsetFromMouseSensor < 0.01) {
                    camera_position.setView();
                };
                setprop("sim/current-view/ab-camera/to/status-time",int(actualDeltaTime * 10.0) / 10.0);
                setprop("sim/current-view/ab-camera/to/status-time-remain-msg",
                        sprintf("Time remain (s): %4.1f",(actualDeltaTime - (camera_to_position.start_wait_time + offsetFromMouseSensor))) ~ sprintf(" [%2.2f]",offsetFromMouseSensor));
#//    print("*** 3 : ",deltaSec," | ",statusCameraActiveTime," | ",actualDeltaTime," | ",camera_to_position.duration_path_time," | ",getprop("sim/current-view/ab-camera/to/status-time"));
            };
        };
    };

};


var removeListeners = func() {
    if (idCameraPlay != nil) {
        removelistener(idCameraPlay);
        idCameraPlay = nil;
    };
    setprop("sim/current-view/ab-camera/to/status",0);
    statusCamera = 0;
};


#// Set position data for new action

setlistener("sim/current-view/ab-camera/to/set-position", func {

    var setPosition = strToViewCamData(getprop("sim/current-view/ab-camera/to/set-position"));
    if (setPosition[0] > 0) {
        if (setPosition[0] == 2) camera_save.getView();
        camera_to_position.init(setPosition[0],setPosition[1],setPosition[2],setPosition[3],setPosition[4],setPosition[5],setPosition[6],setPosition[7],setPosition[8],setPosition[9],setPosition[10]);
        setprop("sim/current-view/ab-camera/to/status",1);
    };
    setprop("sim/current-view/ab-camera/to/set-position","0,0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0");

}, 0, 1);


setlistener("sim/current-view/ab-camera/to/status", func {

    statusCamera = getprop("sim/current-view/ab-camera/to/status");
    if (statusCamera > 0) {
        if (statusCamera == 1) {
            statusCameraActiveTime = getprop("sim/time/steady-clock-sec");
        } else if (statusCamera == 2) {
            statusCameraActiveTime = getprop("sim/time/steady-clock-sec");
        } else if (statusCamera == 3) {
            statusCameraActiveTime = getprop("sim/time/steady-clock-sec");
        } else if (statusCamera == 9) {
            print("ab-camera.nas remove listner: sim/time/steady-clock-sec id: ",idCameraPlay);
            removeListeners();
            setprop("sim/current-view/ab-camera/to/command",0);
        };
        if (idCameraPlay == nil and statusCamera > 0) {
            idCameraPlay = setlistener("sim/time/steady-clock-sec", cameraPlay);
            print("ab-camera.nas activate listner: sim/time/steady-clock-sec id: ",idCameraPlay);
        };
    };

}, 0, 1);


#// Command section

setlistener("sim/current-view/ab-camera/to/command", func {

    var command = getprop("sim/current-view/ab-camera/to/command");
    if (command == 1) {
        if (statusCamera == 0) {
            #// Start new process
            camera_position.getView();
            setprop("sim/current-view/ab-camera/to/status",1);
        };
    } else if (command == 2) {

    } else if (command == 3) {
        setprop("sim/current-view/ab-camera/to/status",9);
    } else if (command == 11) {
        camera_save.getView();
    } else if (command == 12) {
        removeListeners();
        camera_save.setView();
    };
    setprop("sim/current-view/ab-camera/to/command",0);

}, 0, 1);





