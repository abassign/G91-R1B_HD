#// Radio assistant
#//
#// Adriano Bassignana - Bergamo 2020
#//
#// this framework allows to determine the nearest
#// radios (VOPR, TACAN, NDB) and to program them automatically.

#// ..pilot-radio-assistant/mode = 0  : inactive
#// ..pilot-radio-assistant/mode = 1  : active linked to route_manager

#// https://www.pilotnav.com/browse/Navaids/continent/Europe/country/ITALY


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

var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-active",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-active-description","No link active","STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-trigger",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-by-vor",1,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-by-vor-to-from",1,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-by-ndb",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-by-ndb-to-from",0,"INT");


var delta_time_standard = 3;
var delta_time = delta_time_standard;
var delta_time_delay = 0;

var mode = 0;
var airplane = nil;
var radios = nil;
var radioDisplay = nil;

var activate_new_scan = 0;

var testing_log_active = 0;
var landing_activate_status = 0;

var to_radial_vor_old_dist = nil;
var to_radial_vor_to_from_ctrl = 0;
var to_radial_ndb_old_dist = nil;
var to_radial_ndb_to_from_ctrl = 0;
var radials_selected_correct_deg_mod = 0;

var configuration_gauges_nav_active = 0;
var configuration_gauges_tacan_active = 0;


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
            frequency: 0.0,
            radial: nil,
            pos_nav: nil,
            difference_deg: nil,
            value: nil,
            value_previusOutput: 0.0,
            value_previusInput: 0.0,
            select: 0,
        };
        me.value = 0.0;
        me.range_nm = 0.0;
        me.frequency = 0.0;
        me.value_previusOutput = 0.0;
        me.value_previusInput = 0.0;
        me.select = 0;
        return {parents: [RadioDataClass]};
    },
    
    init: func(nav, airplane) {
        me.id = nav.id;
        me.name = nav.name;
        me.pos_nav = geo.Coord.new();
        me.pos_nav.set_latlon(nav.lat,nav.lon);
        me.set_type(nav.type, airplane);
        me.range_nm = nav.range_nm;
        me.frequency = nav.frequency / 100;
        me.radial = nil;
    },
    
    init_tacan: func(airplane) {
        me.id = getprop("/instrumentation/tacan/ident") ~ ":T";
        me.name = getprop("/instrumentation/tacan/name");
        #//print("**** TACAN : ", me.id, " | ", me.name);
        me.pos_nav = geo.aircraft_position();
        var indicated_distance_m = getprop("/instrumentation/tacan/indicated-distance-nm") * 1852.0;
        var indicated_bearing_true_deg = getprop("/instrumentation/tacan/indicated-bearing-true-deg");
        me.pos_nav.apply_course_distance(indicated_bearing_true_deg, indicated_distance_m);
        me.set_type("TACAN", airplane);
        me.range_nm = 200;
        me.frequency = getprop("/instrumentation/tacan/frequencies/selected-mhz");
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
    
    norm_type: func(type) {
        var aType = string.uc(string.trim(type));
        if (aType == "GLIDESLOPE") aType = "ILS";
        if (aType == "LOCALIZER") aType = "LOC";
        if (aType == "TACAN") aType = "TAC";
        return aType;
    },
    
    set_type: func(type, airplane) {
        me.type = me.norm_type(type);
        if (testing_log_active >= 2) {
            print ("pilot_radio_assistant.nas RadioDataClass.set_type: ",me.to_string_format(airplane));
        };
    },
    
    sintonize: func(radial, airplane) {
        if (me.type != nil) {
            if (me.type == "NDB") {
                setprop("/instrumentation/adf/frequencies/selected-khz",me.frequency);
                setprop("/instrumentation/adf/frequencies/standby-khz",0.0);
                setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/select-ndb-description",me.description(airplane));
            } elsif(me.type == "VOR" or me.type == "ILS" or me.type == "LOC" or me.type == "TAC") {
                setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/select-vor-description",me.description(airplane));
                if (me.type == "TAC") {
                    radial = 0.0;
                    setprop("/instrumentation/tacan/frequencies/selected-mhz",me.frequency);
                } else {
                    if (radial != nil) me.radial = radial;
                    setprop("/instrumentation/nav/frequencies/selected-mhz",me.frequency);
                };
                if (me.radial != nil) setprop("/instrumentation/nav/radials/selected-deg",me.radial);
            };
        };
    },
    
    description: func(airplane) {
        var str = me.name ~ sprintf(" | Dist: %.0f",me.distance_nm(airplane)) ~ sprintf(" | Bearing: %.0f",me.bearing(airplane)) ~ sprintf(" ( %.1f )",me.difference_deg) ~ " | Range: " ~ me.range_nm ~ sprintf(" | Freq: %.3f",me.frequency);
        return str;
    },
    
    to_string_format: func(airplane) {
        var heading_true_deg = getprop("fdm/jsbsim/systems/autopilot/heading-true-deg");
        var difference_deg = math.abs(geo.normdeg180(heading_true_deg - me.bearing(airplane)));
        var str = me.name ~ " | ID: " ~ me.id ~ sprintf(" | Dist: %.0f",me.distance_nm(airplane)) ~ sprintf(" | Bearing: %.1f",me.bearing(airplane)) ~ sprintf(" ( %.1f )",difference_deg) ~ " | Type: " ~ me.type ~ " | Range: " ~ me.range_nm ~ sprintf(" | Freq: %.3f",me.frequency) ~ sprintf(" | Value: %.3f",me.value);
        return str;
    },
    
};


var RadiosDataClass = {
    class_name: "RadiosDataClass",
    
    new: func() {
        var obj = {
            radios_set: nil,
            num_radios: 0,
            select_vor_id: nil,
            select_ndb_id: nil,
            distance_max: 0.0,
            distanceSort: nil,
            bearing_Max: 0.0,
            bearingSort: nil,
            delta_time: 0.0,
            valueSort: nil,
            id_NumRadio: nil,
            listNode: nil,
            lastFindNav: nil,
            lastFindNavPosition: nil,
            lastFindNavDistanceNm: 0.0,
            lastFindNavDistanceMax: 0.0,
            lastFindNavActive: 0,
            lastFindNavHeading: 0.0,
            lastFindNavBearingMax: 0.0,
            lastFindNavDeltaTime: 0.0,
            manual_select_vor_id: nil,
            manual_select_ndb_id: nil,
        };
        me.radios_set = {};
        me.num_radios = 0;
        me.select_vor_id = nil;
        me.manual_select_vor_id = nil;
        me.select_ndb_id = nil;
        me.manual_select_ndb_id = nil;
        me.lastFindNavPosition = nil;
        me.lastFindNavDistanceNm = 0.0;
        me.lastFindNavDistanceMax = 0.0;
        me.lastFindNavHeading = 0.0;
        me.lastFindNavBearingMax = 0.0;
        me.lastFindNavDeltaTime = 0.0;
        me.lastFindNavActive = 0;
        me.listNode = props.globals.initNode("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/list");
        return {parents: [RadiosDataClass]};
    },
    
    checkNavVsRange: func(airplane, distance_max, tollerance, bearing_max, delta_time) {
        var fristStep = 0;
        var minOffsetDistance = distance_max * tollerance;
        me.lastFindNavActive = 0;
        if (me.lastFindNavPosition == nil) {
            #// Is the frist time that position is insert
            me.lastFindNavPosition = geo.Coord.new();
            me.lastFindNavPosition.set_latlon(airplane.lat(),airplane.lon());
            me.lastFindNavHeading = getprop("/orientation/heading-deg");
            me.lastFindNavDistanceMax = distance_max;
            me.delta_time = delta_time;
            fristStep = 1;
        };
        me.lastFindNavDistanceNm = airplane.distance_to(me.lastFindNavPosition) * 0.000539957;
        if (me.lastFindNavDistanceNm > minOffsetDistance or me.lastFindNavDistanceMax != distance_max or fristStep == 1 or activate_new_scan == 1) {
            me.lastFindNavPosition.set_latlon(airplane.lat(),airplane.lon());
            me.lastFindNavHeading = getprop("/orientation/heading-deg");
            me.lastFindNavDistanceMax = distance_max;
            me.lastFindNavBearingMax = bearing_max;
            me.lastFindNavActive = 1;
            #// print("pilot_radio_assistant checkNavVsRange - lastFindNavActive: ",me.lastFindNavActive);
        } else {
            if (math.abs(getprop("/orientation/heading-deg") - me.lastFindNavHeading) > 5.0 or me.lastFindNavBearingMax != bearing_max) {
                me.lastFindNavHeading = getprop("/orientation/heading-deg");
                me.lastFindNavBearingMax = bearing_max;
                me.lastFindNavActive = 2;
                #// print("pilot_radio_assistant checkNavVsRange - lastFindNavActive: ",me.lastFindNavActive);
            };
        };
        if (me.lastFindNavActive > 0) {
            me.delta_time = delta_time;
        } else {
            me.delta_time = me.delta_time + delta_time;
        };
        activate_new_scan = 0;
    },
    
    set_step: func(airplane, distance_max, bearing_max, delta_time) {
        var heading_true_deg = getprop("fdm/jsbsim/systems/autopilot/heading-true-deg");
        me.bearing_max = bearing_max;
        me.checkNavVsRange(airplane, distance_max, 0.1, bearing_max, delta_time);
        if (me.lastFindNavActive >= 1) {
            foreach(var radio_key; keys(me.radios_set)) me.radios_set[radio_key].select = 0;
            me.distance_max = distance_max;
            if (me.lastFindNavActive == 1) {
                me.lastFindNav = findNavaidsWithinRange(airplane, me.distance_max);
            };
            me.distanceSort = {};
            me.bearingSort = {};
            me.valueSort = {};
            me.id_NumRadio = {};
            me.num_radios = 0;
            #// Insert TACAN section
            if (configuration_gauges_tacan_active == 1) {
                if (getprop("/instrumentation/tacan/in-range") == 1) {
                    #// Insert TACAN defineted in the "Radio frequencies" system tab
                    var id = string.uc(string.trim(getprop("/instrumentation/tacan/ident"))) ~ ":T";
                    if (me.id_NumRadio[id] == nil) {
                        me.radios_set[id] = RadioDataClass.new();
                        me.radios_set[id].init_tacan(airplane);
                    };
                    me.radios_set[id].difference_deg = math.abs(geo.normdeg180(heading_true_deg - me.radios_set[id].bearing(airplane)));
                    if (me.radios_set[id].distance_nm(airplane) <= me.radios_set[id].range_nm and (bearing_max == 0.0 or math.abs(me.radios_set[id].difference_deg) <= bearing_max)) {
                        me.radios_set[id].select = 2;
                        var v = 10 + math.abs(me.radios_set[id].difference_deg);
                        var d = 10 + me.radios_set[id].distance_nm(airplane);
                        me.radios_set[id].set_value(delta_time / (math.log10(v) + math.log10(d)), delta_time);
                        me.num_radios += 1;
                        me.id_NumRadio[id] = me.num_radios;
                        me.distanceSort[me.num_radios - 1] = [me.radios_set[id].distance_nm(airplane),id];
                        me.bearingSort[me.num_radios - 1] = [me.radios_set[id].difference_deg,id];
                        me.valueSort[me.num_radios - 1] = [me.radios_set[id].value,id];
                    } else {
                        me.radios_set[id].select = 1;
                        var d = 10 + me.radios_set[id].distance_nm(airplane);
                        me.radios_set[id].set_value(delta_time / (math.log10(d)), delta_time);
                    };
                };
            };
            #// Insert VOR and NDB section
            foreach(var nav; me.lastFindNav) {
                var id = string.uc(string.trim(nav.id));
                if (me.id_NumRadio[id] == nil) {
                    if (me.radios_set[id] == nil) {
                        me.radios_set[id] = RadioDataClass.new();
                        me.radios_set[id].init(nav, airplane);
                    };
                    if ((configuration_gauges_nav_active == 1 and me.radios_set[id].type != "TAC") 
                        or (configuration_gauges_tacan_active == 1 and (me.radios_set[id].type != "VOR" and me.radios_set[id].type != "LOC" and me.radios_set[id].type != "ILS"))
                        or (configuration_gauges_nav_active == 0 and configuration_gauges_tacan_active == 0 and me.radios_set[id].type == "NDB")) {
                        me.radios_set[id].difference_deg = math.abs(geo.normdeg180(heading_true_deg - me.radios_set[id].bearing(airplane)));
                        if (me.radios_set[id].distance_nm(airplane) <= me.radios_set[id].range_nm and (bearing_max == 0.0 or math.abs(me.radios_set[id].difference_deg) <= bearing_max)) {
                            me.radios_set[id].select = 2;
                            var v = 10 + math.abs(me.radios_set[id].difference_deg);
                            var d = 10 + me.radios_set[id].distance_nm(airplane);
                            me.radios_set[id].set_value(delta_time / (math.log10(v) + math.log10(d)), delta_time);
                            me.num_radios += 1;
                            me.id_NumRadio[id] = me.num_radios;
                            me.distanceSort[me.num_radios - 1] = [me.radios_set[id].distance_nm(airplane),id];
                            me.bearingSort[me.num_radios - 1] = [me.radios_set[id].difference_deg,id];
                            me.valueSort[me.num_radios - 1] = [me.radios_set[id].value,id];
                        } else {
                            me.radios_set[id].select = 1;
                            var d = 10 + me.radios_set[id].distance_nm(airplane);
                            me.radios_set[id].set_value(delta_time / (math.log10(d)), delta_time);
                        };
                    };
                };
            };
            #// Remove the radio select = 0
            foreach(var radio_key; keys(me.radios_set)) {
                if (me.radios_set[radio_key].select == 0) {
                    #// Only for testing
                    # delete(me.radios_set,me.radios_set[radio_key].id);
                };
            };
            if (me.num_radios > 1) {
                quickSortValueId(me.distanceSort,0,me.num_radios - 1);
                quickSortValueId(me.bearingSort,0,me.num_radios - 1);
                quickSortValueId(me.valueSort,0,me.num_radios - 1);
            };
        };
    },
    
    search_id: func(search_id) {
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
                ## print("pilot_radio_assistant search_id ",search_id_str," i: ",i," type: ",radio.type);
                return radio;
            };
        };
        return nil;
    },
    
    match_id_route: func(type, startPosition) {
        if (type == "LOC") type = "VOR";
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
        if (type == "LOC") type = "VOR";
        for (var i = (me.num_radios - 1); i >= 0; i -= 1) {
            var radio = me.radios_set[me.valueSort[i][1]];
            if (radio.type == type) {
                return radio;
            };
        };
        return nil;
    },
    
    search_manual_select: func() {
        me.manual_select_vor_id = nil;
        me.manual_select_ndb_id = nil;
        for (var i = 0; i < 8; i += 1) {
            var isSelect = me.listNode.getValue("row[" ~ i ~ "]/select");
            if (isSelect == 1) {
                var idSelect = me.listNode.getValue("row[" ~ i ~ "]/id");
                var type = me.listNode.getValue("row[" ~ i ~ "]/type");
                if ((type == "VOR" or type == "ILS" or type == "LOC" or type == "TAC") and idSelect != me.select_vor_id) {
                    me.manual_select_vor_id = idSelect;
                    print("***** search_manual_select idSelect : ",idSelect," type: ",type," me.select_vor_id: ",me.select_vor_id);
                    me.select_vor_id = nil;
                } elsif ((type == "NDB") and idSelect != me.select_ndb_id) {
                    me.manual_select_ndb_id = idSelect;
                    me.select_ndb_id = nil;
                };
            };
        };
    },
    
    display: func(airplane) {
        me.search_manual_select();
        var row = -1;
        me.listNode.setValue("num-radios",me.num_radios);
        for (var i = (me.num_radios - 1); (i >= 0 and row < 8); i -= 1) {
            row += 1;
            var radio = me.radios_set[me.valueSort[i][1]];
            var isSelect = 0;
            var manual_selected_sign = "  ";
            if (me.select_vor_id != nil and radio.id == me.select_vor_id) isSelect = 1;
            if (me.manual_select_vor_id != nil and radio.id == me.manual_select_vor_id) {
                isSelect = 1;
                manual_selected_sign = "* ";
            };
            if (me.select_ndb_id != nil and radio.id == me.select_ndb_id) isSelect = 1;
            if (me.manual_select_ndb_id != nil and radio.id == me.manual_select_ndb_id) {
                isSelect = 1;
                manual_selected_sign = "* ";
            };
            me.listNode.setValue("row[" ~ row ~ "]/select",isSelect);
            me.listNode.setValue("row[" ~ row ~ "]/id",radio.id);
            me.listNode.setValue("row[" ~ row ~ "]/type",radio.type);
            me.listNode.setValue("row[" ~ row ~ "]/name",manual_selected_sign ~ radio.name);
            me.listNode.setValue("row[" ~ row ~ "]/distance",radio.distance_nm(airplane));
            me.listNode.setValue("row[" ~ row ~ "]/bearing",radio.bearing(airplane));
            me.listNode.setValue("row[" ~ row ~ "]/difference",radio.difference_deg);
            me.listNode.setValue("row[" ~ row ~ "]/range",radio.range_nm);
            me.listNode.setValue("row[" ~ row ~ "]/frequency",radio.frequency);
        };
        if (row < 7) {
            for (var i = row + 1; i < 8; i += 1) {
                me.listNode.setValue("row[" ~ i ~ "]/select",0);
                me.listNode.setValue("row[" ~ i ~ "]/id","");
                me.listNode.setValue("row[" ~ i ~ "]/type","");
                me.listNode.setValue("row[" ~ i ~ "]/name","");
                me.listNode.setValue("row[" ~ i ~ "]/distance",0.0);
                me.listNode.setValue("row[" ~ i ~ "]/bearing",0.0);
                me.listNode.setValue("row[" ~ i ~ "]/difference",0.0);
                me.listNode.setValue("row[" ~ i ~ "]/range",0.0);
                me.listNode.setValue("row[" ~ i ~ "]/frequency",0.0);
            };
        };
    },
    
    vor_radio_selected: func() {
        var vor_radio = nil;
        if (me.manual_select_vor_id != nil) {
            vor_radio = me.search_id(me.manual_select_vor_id);
        } elsif (me.select_vor_id != nil) {
            vor_radio = me.search_id(me.select_vor_id);
        };
        return vor_radio;
    },
    
    ndb_radio_selected: func() {
        var ndb_radio = nil;
        if (me.manual_select_ndb_id != nil) {
            ndb_radio = me.search_id(me.manual_select_ndb_id);
        } elsif (me.select_ndb_id != nil) {
            ndb_radio = me.search_id(me.select_ndb_id);
        };
        return ndb_radio;
    },
    
    sintonize: func(airplane, mode) {
        var vor_radio = me.vor_radio_selected();
        var ndb_radio = me.ndb_radio_selected();
        if (vor_radio != nil) { 
            if (vor_radio.type == "ILS") {
                vor_radio.sintonize(getprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct"),airplane);
                setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-vor",2);
                setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-vor-str","ILS (" ~ vor_radio.id ~ ")");
            } else {
                if (mode == 3) {
                    vor_radio.sintonize(getprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct"),airplane);
                } else {
                    if (mode == 1) {
                        vor_radio.sintonize(vor_radio.bearing(airplane),airplane);
                    } else {
                        vor_radio.sintonize(nil,airplane);
                    }
                };
                vor_radio.sintonize(getprop("fdm/jsbsim/systems/autopilot/gui/airport_runway_airplane_heading_correct"),airplane);
                setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-vor",1);
                if (vor_radio.type == "LOC") {      
                    setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-vor-str","LOC (" ~ vor_radio.id ~ ")");
                } elsif (vor_radio.type == "VOR") {
                    setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-vor-str","VOR (" ~ vor_radio.id ~ ")");
                } elsif (vor_radio.type == "TAC") {
                    setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-vor-str","TAC (" ~ vor_radio.id ~ ")");
                };
            };
        } else {
            setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-vor",0);
            setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-vor-str","---");
        };
        if (ndb_radio != nil) {
            ndb_radio.sintonize(nil,airplane);
            setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-ndb",1);
            setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-ndb-str","ADF (" ~ ndb_radio.id ~ ")");
        } else {
            setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-ndb",0);
            setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-ndb-str","---");
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


var radio_assistant = func() {
    
    search_max_dist = getprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/search-max-dist");
    search_max_bearing = getprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/search-max-bearing");
    
    configuration_gauges_nav_active = getprop("sim/G91/configuration/gauges/nav-active");
    configuration_gauges_tacan_active = getprop("sim/G91/configuration/gauges/tacan-active");
    
    if (radios == nil) {
        radios = RadiosDataClass.new();
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
        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-vor-str","  ---");
        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-ndb",0);
        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/find-vor-str","  ---");
    } elsif (mode == 1) {
        #// pilot_radio_assistant linked to route manager
        var search_max_dist = 200.0;
        var search_max_bearing = 0.0;
        airplane = geo.aircraft_position();
        radios.set_step(airplane,search_max_dist,search_max_bearing,delta_time);
        radios.print_debug(airplane);
        var startPosition = getprop("/autopilot/route-manager/current-wp");
        if (startPosition >= 0) {
            var radio = radios.match_id_route("VOR",startPosition);
            if (radio != nil) {
                radios.select_vor_id = radio.id;
            } else {
                radios.select_vor_id = nil;
            };
            radio = radios.match_id_route("NDB",startPosition);
            if (radio != nil) {
                radios.select_ndb_id = radio.id;
            } else {
                radios.select_ndb_id = nil;
            };
        };
        radios.display(airplane);
        radios.sintonize(airplane,mode);
    } elsif (mode == 2) {
        #// pilot_radio_assistant search the nearest ad convenient VOR/ILS or NDB
        airplane = geo.aircraft_position();
        radios.set_step(airplane,search_max_dist,search_max_bearing,delta_time);
        radios.print_debug(airplane);
        var radio = nil;
        if (configuration_gauges_nav_active == 1) {
            radio = radios.match_type("VOR");
        } elsif (configuration_gauges_tacan_active == 1) {
            radio = radios.match_type("TAC");
        };
        if (radio != nil) {
            radios.select_vor_id = radio.id;
        } else {
            radios.select_vor_id = nil;
        };
        radio = radios.match_type("NDB");
        if (radio != nil) {
            radios.select_ndb_id = radio.id;
        } else {
            radios.select_ndb_id = nil;
        };
        radios.display(airplane);
        radios.sintonize(airplane,mode);
    } elsif (mode == 3) {
        #// pilot_radio_assistant search the landing phase VOR/ILS or NDB
        airplane = geo.aircraft_position();
        var search_max_dist = 30.0;
        radios.set_step(airplane,search_max_dist,search_max_bearing / 2.0,delta_time,mode);
        radios.print_debug(airplane);
        var radio = radios.match_type("ILS");
        if (radio != nil) {
            radios.select_vor_id = radio.id;
        } else {
            radios.set_step(airplane,search_max_dist,search_max_bearing / 2.0,delta_time,mode);
            radio = radios.match_type("VOR");
            if (radio != nil) {
                radios.select_vor_id = radio.id;
            } else {
                radios.select_vor_id = nil;
            };
        };
        radio = radios.match_type("NDB");
        if (radio != nil) {
            radios.select_ndb_id = radio.id;
        } else {
            radios.select_ndb_id = nil;
        };
        radios.display(airplane);
        radios.sintonize(airplane,mode);
    };
    
    if (getprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-active") == 1 and radios != nil) {
        if (getprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-by-vor") == 1) {
            var vor_radio = radios.vor_radio_selected();
            if (vor_radio != nil) {
                var distance = vor_radio.distance_nm(airplane);
                if (to_radial_vor_old_dist != nil) {
                    var status_to_from = 0;
                    var versus = to_radial_vor_old_dist - distance;
                    if (radials_selected_correct_deg_mod == 1 and distance > 2.0) to_radial_vor_to_from_ctrl = 1;
                    if ((versus > 0.0 and distance > 1.0) or (to_radial_vor_to_from_ctrl == 1 and distance > 1.0)) {
                        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-by-vor-to-from",1);
                        status_to_from = 1;
                    } elsif (versus < 0.0 and distance > 1.0 and to_radial_vor_to_from_ctrl == 0) {
                        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-by-vor-to-from",-1);
                        status_to_from = -1;
                    } else {
                        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-by-vor-to-from",0);
                        to_radial_vor_to_from_ctrl = 0;
                    };
                    if (status_to_from == 1) {
                        setprop("/instrumentation/nav/radials/selected-deg",vor_radio.bearing(airplane))
                    } elsif (status_to_from == -1) {
                        var b = 180.0 + vor_radio.bearing(airplane);
                        if (b > 360) b = b - 360;
                        setprop("/instrumentation/nav/radials/selected-deg",b);
                    };
                    #//print("***** correct_deg_mod: ",radials_selected_correct_deg_mod," from_ctrl: ",to_radial_vor_to_from_ctrl," status_to_from: ",status_to_from," distance: ",distance);
                };
                to_radial_vor_old_dist = distance;
            };
        } else {
            var ndb_radio = radios.ndb_radio_selected();
            if (ndb_radio != nil) {
                var distance = ndb_radio.distance_nm(airplane);
                if (to_radial_ndb_old_dist != nil) {
                    var status_to_from = 0;
                    var versus = to_radial_ndb_old_dist - distance;
                    if (radials_selected_correct_deg_mod == 1 and distance > 2.0) to_radial_ndb_to_from_ctrl = 1;
                    if ((versus > 0.0 and distance > 1.0) or (to_radial_ndb_to_from_ctrl == 1 and distance > 1.0)) {
                        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-by-ndb-to-from",1);
                        status_to_from = 1;
                    } elsif (versus < 0.0 and distance > 1.0 and to_radial_ndb_to_from_ctrl == 0) {
                        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-by-ndb-to-from",-1);
                        status_to_from = -1;
                    } else {
                        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-by-ndb-to-from",0);
                        to_radial_ndb_to_from_ctrl = 0;
                    };
                    if (status_to_from == 1) {
                        setprop("/instrumentation/nav/radials/selected-deg",ndb_radio.bearing(airplane))
                    } elsif (status_to_from == -1) {
                        var b = 180.0 + ndb_radio.bearing(airplane);
                        if (b > 360) b = b - 360;
                        setprop("/instrumentation/nav/radials/selected-deg",b);
                    };
                    #//print("***** correct_deg_mod: ",radials_selected_correct_deg_mod," from_ctrl: ",to_radial_ndb_to_from_ctrl," status_to_from: ",status_to_from," distance: ",distance);
                };
                to_radial_ndb_old_dist = distance;
            };
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
        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-active-trigger",9);
    } elsif (mode == 2) {
        delta_time = delta_time_standard * 1.5;
        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/mode-description","Active search");
    } elsif (mode == 3) {
        delta_time = delta_time_standard;
        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/mode-description","Landing search");
        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-active-trigger",9);
    };
    
}, 0, 1);


setlistener("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-active-trigger", func {
    
    if (getprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-active-trigger") == 9) {
        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-active",0);
        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-active-description","No link active");
    } else {
        if (getprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-active") == 0) {
            setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-active",1);
            setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-active-description","Link is active");
        } else {
            setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-active",0);
            setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-active-description","No link active");
        };
    };
    setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-active-trigger",0);
    
}, 0, 1);


setlistener("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-trigger", func {
    
    if (getprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-by-vor") == 1) {
        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-by-vor",0);
        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-by-ndb",1);
    } else {
        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-by-vor",1);
        setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-by-ndb",0);
    };
    setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-trigger",0);
    
}, 0, 1);


setlistener("/instrumentation/tacan/frequencies/selected-mhz", func {
    
    activate_new_scan = 1;
    
}, 0, 1);


setlistener("sim/G91/configuration/gauges/nav-active", func {
    
    configuration_gauges_nav_active = getprop("sim/G91/configuration/gauges/nav-active");
    activate_new_scan = 1;

}, 0, 1);


setlistener("sim/G91/configuration/gauges/tacan-active", func {
    
    configuration_gauges_tacan_active = getprop("sim/G91/configuration/gauges/tacan-active");
    activate_new_scan = 1;

}, 0, 1);


var radio_assistant_control = func() {
    
    delta_time_delay -= 1;
    
    var mod = getprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/radials-selected-correct-deg-mod");
    if (mod > 0) radials_selected_correct_deg_mod = 1;
    
    if (delta_time_delay <= 0) {
        testing_log_active = getprop("sim/G91/testing/log");
        if (testing_log_active == nil) testing_log_active = 0;
        if (radials_selected_correct_deg_mod > 0) print("***** radials_selected_correct_deg_mod: ",radials_selected_correct_deg_mod);
        
        radio_assistant();
        
        delta_time_delay = delta_time;
        radials_selected_correct_deg_mod = 0;
    };
    radio_assistant_controlTimer.restart(1);
}


var radio_assistant_controlTimer = maketimer(1, radio_assistant_control);
radio_assistant_controlTimer.singleShot = 1;
radio_assistant_controlTimer.start();
