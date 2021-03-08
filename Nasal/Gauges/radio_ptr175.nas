#// Radio ptr175
#//
#// Adriano Bassignana - Bergamo 2021
#//
#// Advanced configuration ptr175 radio

var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/radio/ptr175/knob-function-desc", "OFF", "STRING");

var delta_time_standard = 1;
var delta_time = delta_time_standard;
var delta_time_delay = 0;
var testing_log_active = 0;
var start_status = 0;

var knob_function_desc = "OFF";
var chan_selector = nil;
var radio_status = "";
var last_frequencies_selected_mhz = nil;


var radio_normal_freq = func(freq) {
    
    if (freq >= 117.5 and freq <= 135.95) {
        var s05 = num(sprintf("%3.2f",math.round(freq * 100.0, 5) / 100.0));
        #//print("+++ s5 radio_normal_freq freq: ",freq," | ",s05," | ",s05 == 126.5);
        return s05;
    } else if (freq >= 225.0 and freq <= 399.9) {
        var s10 = num(sprintf("%3.1f",math.round(freq * 100.0, 10) / 100.0));
        #//print("+++ s 10 radio_normal_freq freq: ",freq," | ",s10," | ",s10 == 126.5);
        return s10;
    };
    return 0.0;
    
};


var radio_set_chan_freq = func(chan, freq) {
    
    freq = radio_normal_freq(freq);
    if (freq >= 117.5) {
        var list = props.globals.getNode("fdm/jsbsim/systems/gauges/radio/com1/chann").getChildren("data");
        if (chan != nil and chan > 0 and chan <= 20) {
            list[chan].setDoubleValue("freq",freq);
            return chan;
        } else {
            var chan_found = 0;
            var frist_chan_zero = 0;
            for (var i = 1; i < 19; i += 1) {
                var chan_freq = radio_normal_freq(list[i].getNode("freq").getValue());
                if (chan_freq == 0.0 and frist_chan_zero == 0) frist_chan_zero = i;
                if (freq == chan_freq) return nil;
            };
            if (chan_found == 0 and frist_chan_zero > 0) {
                list[frist_chan_zero].setDoubleValue("freq",freq);
            };
            return chan_found;
        };
    };
    return 0;
    
};


var radio_ptr175 = func() {
    
    if (chan_selector == nil) {
        start_status = 1;
        chan_selector = getprop("fdm/jsbsim/systems/gauges/radio/ptr175/chan-selector");
        
        var list = props.globals.initNode("fdm/jsbsim/systems/gauges/radio/com1/chann");
        list.removeAllChildren();
        list.addChildren("data", 22);
        list = props.globals.getNode("fdm/jsbsim/systems/gauges/radio/com1/chann").getChildren("data");
        for (var i = 1; i < 21; i += 1) {
            list[i].setIntValue("active",0);
            list[i].setDoubleValue("freq",0.0);
            list[i].setValue("description","");
        };
        
        setprop("fdm/jsbsim/systems/gauges/radio/com1/chann/data[20]/freq",243.0);
        setprop("fdm/jsbsim/systems/gauges/radio/com1/chann/data[20]/description","Emergency");
        
        print("radio_ptr175.nas - radio_ptr175 - load module complete");
        start_status = 2;
    };
    
    if (start_status == 2) {
        #// Chan 19 status ad freq, in the start set the chan 19 (M as manual)
        var freq = radio_normal_freq(getprop("/instrumentation/comm/frequencies/selected-mhz"));
        last_frequencies_selected_mhz = radio_set_chan_freq(19,freq);
        setprop("fdm/jsbsim/systems/gauges/radio/ptr175/chan-selector",19);
        start_status = 9;
    } else {
        var freq = radio_normal_freq(getprop("/instrumentation/comm/frequencies/selected-mhz"));
        if (last_frequencies_selected_mhz != nil and last_frequencies_selected_mhz > 0.0 and last_frequencies_selected_mhz != freq) {
            var chan = radio_set_chan_freq(nil,freq);
            if (chan != nil and chan > 0) {
                setprop("fdm/jsbsim/systems/gauges/radio/ptr175/chan-selector",chan);
            } else {
                #// Is full load freq return to manual insert freq
                radio_set_chan_freq(19,freq);
                setprop("fdm/jsbsim/systems/gauges/radio/ptr175/chan-selector",19);
            };
            last_frequencies_selected_mhz = freq;
        };
    };
    
    var operative_start_stop = getprop("fdm/jsbsim/systems/gauges/radio/ptr175/operative-start-stop");
    var operative_heating = getprop("fdm/jsbsim/systems/gauges/radio/ptr175/operative-heating");
    var operative_serviceable = getprop("/instrumentation/comm/serviceable");
    
    radio_status = "no tension";
    if (operative_start_stop > 0) {
        radio_status = "switch on";
        if (operative_heating > 0.0) {
            radio_status = "heating " ~ sprintf("%.0f %%",operative_heating * 100.0);
            if (operative_serviceable > 0) {
                radio_status = "serviceable";
            };
        };
    };
    
    setprop("fdm/jsbsim/systems/gauges/radio/ptr175/knob-function-desc",knob_function_desc ~ " | " ~ radio_status);
    
};


setlistener("fdm/jsbsim/systems/gauges/radio/ptr175/chan-selector", func {
    
    chan_selector = getprop("fdm/jsbsim/systems/gauges/radio/ptr175/chan-selector");
    if (chan_selector > 0) {
        setprop("fdm/jsbsim/systems/gauges/radio/ptr175/chan-selector-gui",chan_selector);
    };
    
}, 0, 1);


setlistener("fdm/jsbsim/systems/gauges/radio/ptr175/chan-selector-gui", func {
    
    var chan_selector_gui = getprop("fdm/jsbsim/systems/gauges/radio/ptr175/chan-selector-gui");
    
    if (chan_selector_gui > 0) {
        var list = props.globals.getNode("fdm/jsbsim/systems/gauges/radio/com1/chann").getChildren("data");
        for(var i = 1; i <= 20; i += 1) {
            if (chan_selector_gui != i) {
                list[i].getNode("active").setValue(0);
            } else {
                list[i].getNode("active").setValue(1);
                setprop("fdm/jsbsim/systems/gauges/radio/ptr175/chan-selector",chan_selector_gui);
            };
            #//print("*** active i: ",i," ",list[i].getNode("active").getValue()," ",list[i].getNode("freq").getValue());
        };
        if (chan_selector_gui != 19 or (chan_selector_gui == 19 and list[chan_selector_gui].getNode("active").getValue() >= 1)) {
            var chan_selector_gui_freq = list[chan_selector_gui].getNode("freq").getValue();
            setprop("/instrumentation/comm/frequencies/selected-mhz",chan_selector_gui_freq);
        } else {
            var frequencies_selected_mhz = getprop("/instrumentation/comm/frequencies/selected-mhz");
            setprop("fdm/jsbsim/systems/gauges/radio/com1/chann/data[19]/freq",frequencies_selected_mhz);
        };
    };
    
    setprop("fdm/jsbsim/systems/gauges/radio/ptr175/chan-selector-gui",0);
    
}, 0, 1);


setlistener("fdm/jsbsim/systems/gauges/radio/ptr175/chan-freq-gui", func {
    
    var chan_freq_gui = getprop("fdm/jsbsim/systems/gauges/radio/ptr175/chan-freq-gui");
    
    if (chan_freq_gui > 0) {
        var list = props.globals.getNode("fdm/jsbsim/systems/gauges/radio/com1/chann").getChildren("data");
        if (list[chan_freq_gui].getNode("active").getValue() == chan_freq_gui) {
            var chan_selector_gui_freq = list[chan_freq_gui].getNode("freq").getValue();
            setprop("/instrumentation/comm/frequencies/selected-mhz",chan_selector_gui_freq);
        };
    };
    
    setprop("fdm/jsbsim/systems/gauges/radio/ptr175/chan-freq-gui",0);
    
}, 0, 1);


setlistener("fdm/jsbsim/systems/gauges/radio/ptr175/knob-function-set", func {
    
    var function_set = getprop("fdm/jsbsim/systems/gauges/radio/ptr175/knob-function-set");
    knob_function_desc = "OFF";
    
    if(function_set == 1) {
        knob_function_desc = "ON - T/R";
    } elsif (function_set == 2) {
        knob_function_desc = "ON - T/R + G";
    } elsif (function_set == 3) {
        knob_function_desc = "ON - ADF";
    } elsif (function_set == 4) {
        knob_function_desc = "ON - DL";
    } elsif (function_set == 5) {
        knob_function_desc = "ON - DL + T";
    } elsif (function_set == 6) {
        knob_function_desc = "ON - T/R On D/L Off";
    }
    
    setprop("fdm/jsbsim/systems/gauges/radio/ptr175/knob-function-desc",knob_function_desc ~ " | " ~ radio_status);
    
}, 0, 1);


var radio_ptr175_control = func() {
    
    delta_time_delay -= 1;
    
    if (delta_time_delay <= 0) {
        testing_log_active = getprop("sim/G91/testing/log");
        if (testing_log_active == nil) testing_log_active = 0;
        
        radio_ptr175();
        
        delta_time_delay = delta_time;
    };
    radio_ptr175_controlTimer.restart(1);
}


var radio_ptr175_controlTimer = maketimer(1, radio_ptr175_control);
radio_ptr175_controlTimer.singleShot = 1;
radio_ptr175_controlTimer.start();
