#// Radio assistant
#//
#// Adriano Bassignana - Bergamo 2020
#//
#// this framework allows to determine the nearest
#// radios (VOPR, TACAN, NDB) and to program them automatically.

#// ..pilot-radio-assistant/mode = 0  : inactive
#// ..pilot-radio-assistant/mode = 1  : active linked to route_manager


var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/mode",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/mode-description","Inactive","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/mode-trigger",0,"INT");


var delta_time_standard = 3;
var delta_time = delta_time_standard;
var timeStepSecond = 0;

var mode = 0;
var airplane = nil;


var quickSortValueId = func(list, beg, end) {
    
    ### print("***** quickSort dim list: ",size(list)," beg: ",beg," end: ",end);
    
    var piv = nil; 
    var tmp = nil;
    var l = 0; var r = 0; var p = 0;

    while (beg < end) {
        l = beg;
        p = math.round(0.5 + (beg + end) / 2);
        r = end;
        piv = list[p];
        while (1) {
            while ((l <= r) and (list[l][0] - piv[0] <= 0.0)) l += 1;
            while ((l <= r) and (list[r][0] - piv[0] > 0.0)) r -= 1;
            if (l > r) break;
            tmp = list[l];
            list[l] = list[r];
            list[r] = tmp;
            if (p == r) p = l;
            l += 1;
            r -= 1;
        };
        list[p] = list[r];
        list[r] = piv;
        r -= 1;
        #// Select the shorter side & call recursion. Modify input param. for loop
        if ((r - beg) < (end - l)) {
            quickSortValueId(list, beg, r);
            beg = l;
        } else {
            quickSortValueId(list, l, end);
            end = r;
        };
    };
};


var RadioDataClass = {
    class_name: "RadioDataClass",
    
    new: func() {
        var obj = {
            id: nil,
            name: nil,
            distance_nm: 0.0,
            bearing: 0.0,
            type: nil,
            range_nm: 0.0,
            frequency: nil,
            radial: nil,
            pos: nil,
            difference_deg: nil,
        };
        return {parents: [RadioDataClass]};
    },
    
    init: func(airplane,nav) {
        me.id = nav.id;
        me.name = nav.name;
        me.pos = geo.Coord.new();
        me.pos.set_latlon(nav.lat,nav.lon);
        me.distance_nm = airplane.distance_to(me.pos) * 0.000539957;
        me.bearing = airplane.course_to(me.pos);
        me.type = nav.type;
        me.range_nm = nav.range_nm;
        me.frequency = nav.frequency / 100;
        me.radial = nil;
    },
    
    sintonize: func(radial = nil) {
        if (me.type != nil) {
            if (me.type == "NDB") {
                setprop("/instrumentation/adf/frequencies/selected-khz",me.frequency);
                setprop("/instrumentation/adf/frequencies/standby-khz",0.0);
            } elsif(me.type == "VOR") {
                setprop("/instrumentation/nav/frequencies/selected-mhz",me.frequency);
                setprop("/instrumentation/nav/frequencies/standby-mhz",0.0);
                if (radial != nil) me.radial = radial;
                if (me.radial != nil) setprop("/instrumentation/nav/radials/selected-deg",me.radial);
            };
        };
    },
    
    to_string_format: func() {
        var str = me.name ~ " | ID: " ~ me.id ~ sprintf(" | Dist: %.3f",me.distance_nm) ~ sprintf(" | Bearing: %.3f",me.bearing) ~ " | Type: " ~ me.type ~ " | Range: " ~ me.range_nm ~ sprintf(" | Freq: %.3f",me.frequency);
        return str;
    },
    
};


var RadiosDataClass = {
    class_name: "RadiosDataClass",
    
    new: func() {
        var obj = {
            radios: nil,
            num_radios: 0,
            distance_max: 0.0,
            distanceSort: nil,
            bearing_Max: 0.0,
            bearingSort: nil,
        };
        return {parents: [RadiosDataClass]};
    },
    
    init: func(airplane, navs, distance_max, bearing_max) {
        me.radios = {};
        me.distanceSort = {};
        me.bearingSort = {};
        me.num_radios = 0;
        me.distance_max = distance_max;
        me.bearing_max = bearing_max;
        var heading_true_deg = getprop("fdm/jsbsim/systems/autopilot/heading-true-deg");
        foreach(var nav; navs) {
            var data = RadioDataClass.new();
            data.init(airplane,nav);
            data.difference_deg = math.abs(geo.normdeg180(heading_true_deg - data.bearing));
            if (data.distance_nm <= data.range_nm and (bearing_max == 0.0 or math.abs(data.difference_deg) <= bearing_max)) {
                me.num_radios += 1;
                me.radios[me.num_radios] = data;
                me.distanceSort[me.num_radios - 1] = [me.radios[me.num_radios].distance_nm,me.num_radios];
                me.bearingSort[me.num_radios - 1] = [me.radios[me.num_radios].difference_deg,me.num_radios];
            };
        };
        if (me.num_radios > 1) {
            quickSortValueId(me.distanceSort,0,me.num_radios - 1);
            quickSortValueId(me.bearingSort,0,me.num_radios - 1);
        };
    },
    
    search_id: func(search_id, type) {
        for (var i = 1; i <= me.num_radios; i += 1) {
            if (search_id == me.radios[i].id) {
                print("search_id ",search_id," i: ",i," type: ",me.radios[i].type," vs ",type);
                if (me.radios[i].type == type) {
                    print("search_id freq: ",me.radios[i].frequency);
                    return me.radios[i];
                };
            };
        };
        return nil;
    },
    
    match_id_route: func(type, startPosition) {
        var total = 0;
        var list = props.globals.getNode("/autopilot/route-manager/route").getChildren("wp");
        var total = getprop("/autopilot/route-manager/route/num");
        for(var i = startPosition; i < total; i += 1) {
            var radio = me.search_id(list[i].getNode("id").getValue(), type);
            if (radio != nil) print("match_id_route type: ",type," Total: ",total," Radio.id: ",radio.id);
            if (radio != nil) {
                radio.radial = list[i].getNode("leg-bearing-true-deg").getValue();
                return radio;
            };
        };
        return nil;
    },
    
    print: func() {
        print("----- Find ",me.num_radios," navaids bearing +/- ",me.bearing_max,sprintf(" deg within range from: %.0f",me.radios[me.distanceSort[0][1]].distance_nm),sprintf(" to: %.0f nm",me.radios[me.distanceSort[me.num_radios - 1][1]].distance_nm));
        for (var i = 1; i <= me.num_radios; i += 1) {
            print(me.radios[i].to_string_format());
        };
    },
    
};


var radio_assistant = func() {
    
    if (mode == 0) {
        #// pilot_radio_assistant not operative
    } elsif (mode == 1) {
        var search_max_dist = 200.0;
        var search_max_bearing = 0.0;
        airplane = geo.aircraft_position();
        var navs = findNavaidsWithinRange(airplane, search_max_dist);
        var airplane_bearing = getprop("");
        var radios = RadiosDataClass.new();
        radios.init(airplane,navs,search_max_dist,search_max_bearing);
        radios.print();
        var startPosition = getprop("/autopilot/route-manager/current-wp");
        if (startPosition >= 0) {
            var radio = radios.match_id_route("VOR",startPosition);
            if (radio != nil) radio.sintonize();
            radio = radios.match_id_route("NDB",startPosition);
            if (radio != nil) radio.sintonize();
        };
    };
}


setlistener("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/mode-trigger", func {

    var mode_trigger = getprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/mode-trigger");
    
    if (mode_trigger == 1) {
        var mode_get = getprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/mode");
        if (mode_get == 0) {
            mode_get = 1;
        } else {
            mode_get = 0;
        };
        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/mode",mode_get);
    };
    
    setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/mode-trigger",0);

}, 0, 1);


setlistener("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/mode", func {

    mode = getprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/mode");
    
    if (mode == 0) {
        delta_time = 2;
        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/mode-description","Inactive");
    } elsif (mode == 1) {
        delta_time = delta_time_standard;
        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/mode-description","Active");
    };

}, 0, 1);


var radio_assistant_control = func() {
    radio_assistant();
    radio_assistant_controlTimer.restart(delta_time);
    
    if (timeStepSecond == 1) timeStepSecond = 0;
}


var radio_assistant_controlTimer = maketimer(delta_time, radio_assistant_control);
radio_assistant_controlTimer.singleShot = 1;
radio_assistant_controlTimer.start();

var timer_second_clock = maketimer(1, func() {timeStepSecond = 1;});
timer_second_clock.start();
