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
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-vor",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-vor-str","  VOR","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/select-vor-description","","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-ndb",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-ndb-str","  NDB","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/select-ndb-description","","STRING");

var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/search-max-dist",100.0,"DOUBLE");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/search-max-bearing",30.0,"DOUBLE");

var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/radials-selected-correct-deg",0,"DOUBLE");


var delta_time_standard = 3;
var delta_time = delta_time_standard;

var mode = 0;
var airplane = nil;
var radios = nil;
var radioDisplay = nil;

var testing_log_active = 0;
var landing_activate_status = 0;


var quickSortValueId = func(list, beg, end) {
    
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
            type: nil,
            range_nm: 0.0,
            frequency: nil,
            radial: nil,
            pos_nav: nil,
            difference_deg: nil,
            value: nil,
            value_previusOutput: 0.0,
            value_previusInput: 0.0,
            select: 0,
        };
        me.value = 0.0;
        me.value_previusOutput = 0.0;
        me.value_previusInput = 0.0;
        return {parents: [RadioDataClass]};
    },
    
    init: func(nav) {
        me.id = nav.id;
        me.name = nav.name;
        me.pos_nav = geo.Coord.new();
        me.pos_nav.set_latlon(nav.lat,nav.lon);
        me.set_type(nav.type);
        me.range_nm = nav.range_nm;
        me.frequency = nav.frequency / 100;
        me.radial = nil;
    },
    
    distance_nm: func(airplane) {
        return airplane.distance_to(me.pos_nav) * 0.000539957;
    },
    
    bearing: func(airplane) {
        return airplane.course_to(me.pos_nav);
    },
    
    washout_filter: func(input, c1, delta_time) {
        var output = 0.0;
        var denom = 2.0 + delta_time * c1;
        var ca = 2.0 / denom;
        var cb = (2.0 - delta_time * c1) / denom;
        output = input * ca - me.value_previusInput * ca + me.value_previusOutput * cb;
        value_previusInput = input;
        value_previusOutput = output;
        return output;
    },
    
    set_value: func(input, delta_time) {
        me.value = me.washout_filter(input,0.02,delta_time);
    },
    
    set_type: func(type) {
        var aType = string.uc(string.trim(type));
        if (aType == "GLIDESLOPE") aType = "ILS";
        me.type = aType;
    },
    
    sintonize: func(radial = nil) {
        if (me.type != nil) {
            if (me.type == "NDB") {
                setprop("/instrumentation/adf/frequencies/selected-khz",me.frequency);
                setprop("/instrumentation/adf/frequencies/standby-khz",0.0);
                setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/select-ndb-description",me.description(airplane));
            } elsif(me.type == "VOR" or me.type == "ILS") {
                setprop("/instrumentation/nav/frequencies/selected-mhz",me.frequency);
                setprop("/instrumentation/nav/frequencies/standby-mhz",0.0);
                setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/select-vor-description",me.description(airplane));
                if (radial != nil) me.radial = radial;
                if (me.radial != nil) setprop("/instrumentation/nav/radials/selected-deg",me.radial);
            };
        };
    },
    
    description: func(airplane) {
        var str = me.name ~ sprintf(" | Dist: %.0f",me.distance_nm(airplane)) ~ sprintf(" | Bearing: %.0f",me.bearing(airplane)) ~ sprintf(" ( %.1f )",me.difference_deg) ~ " | Range: " ~ me.range_nm ~ sprintf(" | Freq: %.3f",me.frequency);
        return str;
    },
    
    to_string_format: func(airplane) {
        var str = me.name ~ " | ID: " ~ me.id ~ sprintf(" | Dist: %.0f",me.distance_nm(airplane)) ~ sprintf(" | Bearing: %.1f",me.bearing(airplane)) ~ sprintf(" ( %.1f )",me.difference_deg) ~ " | Type: " ~ me.type ~ " | Range: " ~ me.range_nm ~ sprintf(" | Freq: %.3f",me.frequency) ~ sprintf(" | Value: %.3f",me.value);
        return str;
    },
    
};


var RadiosDataClass = {
    class_name: "RadiosDataClass",
    
    new: func() {
        var obj = {
            radios_set: nil,
            num_radios: 0,
            distance_max: 0.0,
            distanceSort: nil,
            bearing_Max: 0.0,
            bearingSort: nil,
            delta_time: 0.0,
            valueSort: nil,
            listNode: nil,
        };
        me.radios_set = {};
        me.num_radios = 0;
        me.listNode = props.globals.initNode("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/list");
        return {parents: [RadiosDataClass]};
    },
    
    set_step: func(airplane, navs, distance_max, bearing_max, delta_time) {
        me.distanceSort = {};
        me.bearingSort = {};
        me.valueSort = {};
        me.num_radios = 0;
        me.distance_max = distance_max;
        me.bearing_max = bearing_max;
        me.delta_time = delta_time;
        var heading_true_deg = getprop("fdm/jsbsim/systems/autopilot/heading-true-deg");
        #// Set all radio select 0
        foreach(var radio_key; keys(me.radios_set)) {
            me.radios_set[radio_key].select = 0;
        };
        foreach(var nav; navs) {
            var id = nav.id;
            if (me.radios_set[id] == nil) {
                me.radios_set[id] = RadioDataClass.new();
                me.radios_set[id].init(nav);
            };
            me.radios_set[id].difference_deg = math.abs(geo.normdeg180(heading_true_deg - me.radios_set[id].bearing(airplane)));
            if (me.radios_set[id].distance_nm(airplane) <= me.radios_set[id].range_nm and (bearing_max == 0.0 or math.abs(me.radios_set[id].difference_deg) <= bearing_max)) {
                me.radios_set[id].select = 2;
                var v = 10 + math.abs(me.radios_set[id].difference_deg);
                var d = 10 + me.radios_set[id].distance_nm(airplane);
                me.radios_set[id].set_value(delta_time / (math.log10(v) + math.log10(d)), delta_time);
                me.num_radios += 1;
                me.distanceSort[me.num_radios - 1] = [me.radios_set[id].distance_nm(airplane),id];
                me.bearingSort[me.num_radios - 1] = [me.radios_set[id].difference_deg,id];
                me.valueSort[me.num_radios - 1] = [me.radios_set[id].value,id];
            } else {
                me.radios_set[id].select = 1;
                var d = 10 + me.radios_set[id].distance_nm(airplane);
                me.radios_set[id].set_value(delta_time / (math.log10(d)), delta_time);
            };
        };
        #// Remove the radio select = 0
        foreach(var radio_key; keys(me.radios_set)) {
            if (me.radios_set[radio_key].select == 0) {
                delete(me.radios_set,me.radios_set[radio_key].id);
            };
        };
        if (me.num_radios > 1) {
            quickSortValueId(me.distanceSort,0,me.num_radios - 1);
            quickSortValueId(me.bearingSort,0,me.num_radios - 1);
            quickSortValueId(me.valueSort,0,me.num_radios - 1);
        };
    },
    
    search_id: func(search_id, type) {
        for (var i = 0; i < me.num_radios; i += 1) {
            #// Normalize search id values
            var radio = me.radios_set[me.distanceSort[i][1]];
            var search_id_str = string.uc(string.trim(search_id));
            var radio_id_str = string.uc(string.trim(radio.id));
            if (size(radio_id_str) > size(search_id_str)) {
                radio_id_str = substr(radio_id_str,0,size(search_id_str));
            } elsif (size(radio_id_str) < size(search_id_str)) {
                search_id_str = substr(search_id_str,0,size(radio_id_str));
            };
            #// Search id in the radios
            if (search_id_str == radio_id_str) {
                print("pilot_radio_assistant search_id ",search_id_str," i: ",i," type: ",radio.type," vs ",type);
                if (radio.type == type) {
                    print("pilot_radio_assistant search_id set freq: ",radio.frequency);
                    return radio;
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
    
    match_type: func(type) {
        for (var i = (me.num_radios - 1); i >= 0; i -= 1) {
            var radio = me.radios_set[me.valueSort[i][1]];
            if (radio.type == type) {
                return radio;
            };
        };
        return nil;
    },
    
    #// TOGLIERE DOPO
    list_radios: func(airplane) {
        me.listNode.removeAllChildren();
        me.listNode.initNode("num-radios",me.num_radios,"INT");
        var j = -1;
        for (var i = (me.num_radios - 1); i >= 0; i -= 1) {
            j += 1;
            var radio = me.radios_set[me.valueSort[i][1]];
            var record = radio.description(airplane);
            rv = "radio[" ~ j ~ "]";
            me.listNode.setValue(rv ~ "/type",radio.type);
            me.listNode.setValue(rv ~ "/record",record);
            me.listNode.setValue(rv ~ "/value",radio.value);
        };
    },
    
    print_debug: func(airplane) {
        if (testing_log_active >= 2) {
            print("----- Find ",me.num_radios," navaids bearing +/- ",me.bearing_max,sprintf(" deg within range from: %.0f",me.radios_set[me.distanceSort[0][1]].distance_nm(airplane)),sprintf(" to: %.0f nm",me.radios_set[me.distanceSort[me.num_radios - 1][1]].distance_nm(airplane)));
            for (var i = (me.num_radios - 1); i >= 0; i -= 1) {
                var radio = me.radios_set[me.valueSort[i][1]];
                print(radio.to_string_format(airplane));
            };
        };
    },
    
};


var RadioDisplayNodeClass = {
    class_name: "RadioDisplayNodeClass",
    
    new: func() {
        var obj = {
            radio: nil,
            isSelect: nil,
        };
        return {parents: [RadioDisplayNodeClass]};
    },
    
    add: func(radio,isSelect) {
        me.radio = radio;
        me.isSelect = isSelect;
    },
    
    setIsSelect: func(isSelect) {
        me.isSelect = isSelect;
    },
    
    getDescription: func(airplane) {
        return str = me.radio.id ~ " : " ~ me.radio.name ~ sprintf(" | Dist: %.0f",me.distance_nm(airplane)) ~ sprintf(" | Bearing: %.0f",me.bearing(airplane)) ~ sprintf(" ( %.1f )",me.radio.difference_deg) ~ " | Range: " ~ me.radio.range_nm ~ sprintf(" | Freq: %.3f",me.radio.frequency);
    },
    
    getIsSelect: func() {
        return me.isSelect;
    },
    
};


var RadiosDisplayClass = {
    class_name: "RadiosDisplayClass",
    
    new: func() {
        var obj = {
            window: nil,
            myCanvas: nil,
            aRoot: nil,
            myHBox: nil,
            keypad: nil,
            isWindowCreate: 0,
        };
        me.isWindowCreate = 0;
        return {parents: [RadiosDisplayClass]};
    },
    
    createButton: func(aRoot, label, clickAction, width) {
        var button = canvas.gui.widgets.Button.new(aRoot, canvas.style, {} )
        .setFixedSize(width, 25)
        .setText(label);
        button.listen("clicked",clickAction);
        return button;
    },
    
    show: func(radios, airplane) {
        if (me.isWindowCreate == 0) {
            #// create a new window, using the dialog decoration (i.e. titlebar)
            me.window = canvas.Window.new([750,250],"dialog").set("title","Select radio assistence");
            #// adding a canvas to the new window and setting up background colors/transparency
            me.myCanvas = me.window.createCanvas().setColorBackground(1,1,1,0.8);
            #// creating the top-level/root group which will contain all other elements/group
            me.aRoot = me.myCanvas.createGroup();
            me.isWindowCreate = 1;
        };
        
        #// See: http://wiki.flightgear.org/Howto:Creating_a_Canvas_GUI_dialog_file
        #// create a new layout for the keypad:
        me.myHBox = canvas.HBoxLayout.new();
        #// assign the layout to the Canvas, is nested canvas
        me.myCanvas.setLayout(me.myHBox);
        me.keypad = canvas.HBoxLayout.new();
        me.myHBox.addItem(me.keypad);
        
        #// For a pictures ad right
        #// this could also be another Canvas: 
        #// http://wiki.flightgear.org/Howto:Using_raster_images_and_nested_canvases#Example:_Loading_a_Canvas_dynamically
        #// var mfd = canvas.gui.widgets.Label.new(aRoot, canvas.style, {} ).setImage("Textures/Splash1.png");
        #// myHBox.addItem(mfd);
        
        var widthCol = [60,600,60];
        for(var col = 0; col < 3; col += 1) {
            #// set up a new vertical box
            var vbox = canvas.VBoxLayout.new();
            #// add it to the top-level hbox
            me.keypad.addItem(vbox);
            for (var row = 0; row < 8; row += 1) {
                (func() {
                    var btn = "";
                    var vbox = vbox;
                    var action = "";
                    if (row < radios.num_radios) {
                        var rowOrd = radios.num_radios - row - 1;
                        var radio = radios.radios_set[radios.valueSort[rowOrd][1]];
                        var action = radios.valueSort[rowOrd][1];
                        if (col == 0) btn = radio.id;
                        if (col == 1) btn = radio.description(airplane);
                        if (col == 2) btn = sprintf("%.3f",radio.value);
                    }
                    var button = me.createButton(aRoot:me.aRoot, label:btn, clickAction:func{print("button clicked:",action);},width:widthCol[col]);
                    #// add the button to the vbox
                    vbox.addItem(button);		
                })(); #// invoke anonymous function (closure)
            }
        }
    },
    
};


var radio_assistant = func() {
    
    search_max_dist = getprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/search-max-dist");
    search_max_bearing = getprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/search-max-bearing");
    
    if (radios == nil) {
        radios = RadiosDataClass.new();
        radioDisplay = RadiosDisplayClass.new();
    };
    
    #// Test for mode == 3 or Landing phase for search ILS
    landing_activate_status = getprop("fdm/jsbsim/systems/autopilot/gui/landing-activate-status");
    if (landing_activate_status > 0) {
        if (getprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_distance") < 20.0) {
            if (mode == 2) {
                mode = 3;
                setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/mode",3);
            };
        } else {
            if (mode == 3) {
                mode = 2;
                setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/mode",2);
            };
        };
    } else {
        if (mode == 3) {
            mode = 2;
            setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/mode",2);
        };
    };
    
    if (mode == 0) {
        #// pilot_radio_assistant not operative
        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-vor",0);
        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-ndb",0);
    } elsif (mode == 1) {
        #// pilot_radio_assistant linked to route manager
        var search_max_dist = 200.0;
        var search_max_bearing = 0.0;
        airplane = geo.aircraft_position();
        var navs = findNavaidsWithinRange(airplane, search_max_dist);
        radios.set_step(airplane,navs,search_max_dist,search_max_bearing,delta_time);
        radios.print_debug(airplane);
        radioDisplay.show(radios, airplane);
        var startPosition = getprop("/autopilot/route-manager/current-wp");
        if (startPosition >= 0) {
            var radio = radios.match_id_route("VOR",startPosition);
            if (radio != nil) {
                radio.sintonize(nil,airplane);
                setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-vor",1);
            } else {
                setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-vor",0);
            };
            radio = radios.match_id_route("NDB",startPosition);
            if (radio != nil) {
                radio.sintonize(nil,airplane);
                setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-ndb",1);
            } else {
                setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-ndb",0);
            };
        };
    } elsif (mode == 2) {
        #// pilot_radio_assistant search the nearest ad convenient VOR/ILS or NDB
        airplane = geo.aircraft_position();
        var navs = findNavaidsWithinRange(airplane, search_max_dist);
        radios.set_step(airplane,navs,search_max_dist,search_max_bearing,delta_time);
        radios.print_debug(airplane);
        radioDisplay.show(radios, airplane);
        var radio = radios.match_type("VOR");
        if (radio != nil) {
            radio.sintonize(nil,airplane);
            setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-vor",1);
        } else {
            setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-vor",0);
        };
        radio = radios.match_type("NDB");
        if (radio != nil) {
            radio.sintonize(nil,airplane);
            setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-ndb",1);
        } else {
            setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-ndb",0);
        };
    } elsif (mode == 3) {
        #// pilot_radio_assistant search the landing phase VOR/ILS or NDB
        airplane = geo.aircraft_position();
        var navs = findNavaidsWithinRange(airplane, 20.0);
        radios.set_step(airplane,navs,search_max_dist,search_max_bearing / 2.0,delta_time);
        radios.print_debug(airplane);
        radioDisplay.show(radios, airplane);
        var radio = radios.match_type("ILS");
        if (radio != nil) {
            radio.sintonize(getprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct"),airplane);
            setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-vor",2);
        } else {
            navs = findNavaidsWithinRange(airplane, 50.0);
            radios.set_step(airplane,navs,search_max_dist,search_max_bearing,delta_time);
            radio = radios.match_type("VOR");
            if (radio != nil) {
                radio.sintonize(getprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct"),airplane);
                setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-vor",1);
            };
        };
        if (radio == nil) {
            setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-vor",0);
        };
        radio = radios.match_type("NDB");
        if (radio != nil) {
            radio.sintonize(nil,airplane);
            setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-ndb",1);
        } else {
            setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-ndb",0);
        };
    };
    
    var radial_selected_deg = getprop("/instrumentation/nav/radials/selected-deg");
    if (radial_selected_deg < 0.0) {
        radial_selected_deg = 360.0 + radial_selected_deg;
    };
    setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/radials-selected-correct-deg",radial_selected_deg);
    
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
    } elsif (mode_trigger == 2) {
        var mode_get = getprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/mode");
        if (mode_get == 0) {
            mode_get = 2;
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
        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/mode-description","Active PHI");
    } elsif (mode == 2) {
        delta_time = delta_time_standard * 1.5;
        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/mode-description","Active search");
    } elsif (mode == 3) {
        delta_time = delta_time_standard;
        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/mode-description","Landing search");
    };
    
}, 0, 1);


setlistener("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-vor", func {
    
    if (getprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-vor") >= 1) {
        if (getprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-vor") == 2) {
            setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-vor-str","* ILS");
        } else {
            setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-vor-str","* VOR");
        };
    } else {
        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-vor-str","  VOR");
    };
    
}, 0, 1);


setlistener("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-ndb", func {
    
    if (getprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-ndb") == 1) {
        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-ndb-str","* NDB");
    } else {
        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-ndb-str","  NDB");
    };
    
}, 0, 1);


var radio_assistant_control = func() {
    
    testing_log_active = getprop("sim/G91/testing/log");
    if (testing_log_active == nil) testing_log_active = 0;
    
    radio_assistant();
    radio_assistant_controlTimer.restart(delta_time);
}


var radio_assistant_controlTimer = maketimer(delta_time, radio_assistant_control);
radio_assistant_controlTimer.singleShot = 1;
radio_assistant_controlTimer.start();
