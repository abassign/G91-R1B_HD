#// Radio ptr175
#//
#// Adriano Bassignana - Bergamo (Italy) 2021
#//
#// Advanced configuration ptr175 radio
#// Documentation: https://en.wikipedia.org/wiki/Airband
#//
#// The airband, for this type radio is 5KHz interval (for compatibility with actual system), but the apparatus
#// permit only 10 KHz channels step

var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/radio/ptr175/knob-function-desc", "OFF", "STRING");
var prop = props.globals.initNode("fdm/jsbsim/systems/gauges/radio/ptr175/chan-freq-gui-desc", "", "STRING");

var delta_time_standard = 1;
var delta_time_delay = 0;
var delta_time = delta_time_standard;
var testing_log_active = 0;
var start_status = 0;

var comm_function_set = 0;
var knob_function_desc = "OFF";
var chan_selector = nil;
var chan_selector_old = nil;

var frequencies_selected_mhz_only = 0;

var radio_status = "";
var radio_gui_error = 0;

var com2_old_freq_value = nil;


var radio_normal_freq = func(freq) {

    if (freq != nil) {
        if (freq >= 117.5 and freq <= 135.95) {
            var s05 = num(sprintf("%3.2f",math.round(freq * 100.0, 1) / 100.0));
            return s05;
        } else if (freq >= 225.0 and freq <= 399.9) {
            var s10 = num(sprintf("%3.2f",math.round(freq * 100.0, 1) / 100.0));
            return s10;
        };
    };
    return 0.0;

};


var radio_gui_error_msg = func(code = nil) {

    if (code == nil and radio_gui_error > 0) {
        if (radio_gui_error > 0) radio_gui_error -= 1;
        if (radio_gui_error <= 0) setprop("fdm/jsbsim/systems/gauges/radio/ptr175/chan-freq-gui-desc","");
    } else {
      var error_msg = "";
      radio_gui_error = 0;
      if (code == 1) {
          radio_gui_error = 5;
          error_msg = "The frequency must be 117.5:135.95 and 225.0:399.9";
      };
      setprop("fdm/jsbsim/systems/gauges/radio/ptr175/chan-freq-gui-desc",error_msg);
    };

};


var radio_set_chan_freq = func(chan, freq) {

    freq = radio_normal_freq(freq);
    if (freq >= 117.5) {
        var list = props.globals.getNode("fdm/jsbsim/systems/gauges/radio/com1/chann").getChildren("data");
        if (chan != nil and chan >= 1 and chan <= 18) {
            list[chan].setDoubleValue("freq",freq);
            return chan;
        } else {
            var chan_found = 0;
            var frist_chan_zero = 0;
            for (var i = 1; i <= 20; i += 1) {
                var chan_freq = radio_normal_freq(list[i].getNode("freq").getValue());
                if (chan_freq == 0.0 and frist_chan_zero == 0) frist_chan_zero = i;
                if (freq == chan_freq) {
                    return i;
                };
            };
            if (chan_found == 0 and frist_chan_zero > 0) {
                list[frist_chan_zero].setDoubleValue("freq",freq);
                chan_found = frist_chan_zero;
            };
            return chan_found;
        };
    };
    return 0;

};


var radio_ptr175 = func() {

    # System initialization
    if (chan_selector == nil) {
        start_status = 1;
        var list = props.globals.initNode("fdm/jsbsim/systems/gauges/radio/com1/chann");
        list.removeAllChildren();
        #// This command give an system error, is strange, but not work from 20210525
        #// list.addChildren("data", 22);
        for (var i = 1; i <= 22; i += 1) {
            list.addChild("data");
        }
        list = props.globals.getNode("fdm/jsbsim/systems/gauges/radio/com1/chann").getChildren("data");
        for (var i = 1; i <= 20; i += 1) {
            list[i].setIntValue("active",0);
            list[i].setDoubleValue("freq",0.0);
            list[i].setValue("description","");
        };
        setprop("fdm/jsbsim/systems/gauges/radio/ptr175/chan-selector",19);
        chan_selector = 19;
        var freq = radio_normal_freq(getprop("instrumentation/comm/frequencies/selected-mhz"));
        if (freq == 0.0) freq = 117.5;
        setprop("fdm/jsbsim/systems/gauges/radio/ptr175/input-freq-mhz",freq);
        setprop("fdm/jsbsim/systems/gauges/radio/com1/chann/data[19]/description","Manual");
        setprop("fdm/jsbsim/systems/gauges/radio/com1/chann/data[19]/active",1);

        setprop("fdm/jsbsim/systems/gauges/radio/com1/chann/data[20]/freq",getprop("fdm/jsbsim/systems/gauges/radio/ptr175/freq-guard"));
        setprop("fdm/jsbsim/systems/gauges/radio/com1/chann/data[20]/description","Emergency");

        setprop("/instrumentation/comm[1]/power-bin",0);

        print("radio_ptr175.nas - radio_ptr175 - load module complete");
        start_status = 2;
    };

    # Set the radio status on knob-function-desc
    var operative_start_stop = getprop("fdm/jsbsim/systems/gauges/radio/ptr175/operative-start-stop");
    var operative_heating = getprop("fdm/jsbsim/systems/gauges/radio/ptr175/operative-heating");
    var operative_serviceable = getprop("/instrumentation/comm/serviceable");
    # Display the radio status in the gui
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


setlistener("fdm/jsbsim/systems/gauges/radio/ptr175/output-freq-mhz", func {

    # Manual frequency entry from the pilot control panel
    var freq = getprop("fdm/jsbsim/systems/gauges/radio/ptr175/output-freq-mhz");
    if (freq > 0.0 and freq != getprop("fdm/jsbsim/systems/gauges/radio/com1/chann/data[19]/freq")) {
        setprop("fdm/jsbsim/systems/gauges/radio/com1/chann/data[19]/freq",freq);
        setprop("fdm/jsbsim/systems/gauges/radio/com1/chann/data[19]/active",1);
        if (getprop("instrumentation/comm/frequencies/selected-mhz") != freq) {
            frequencies_selected_mhz_only = 1;
            setprop("instrumentation/comm/frequencies/selected-mhz",freq);
        };
    };

}, 0, 1);


setlistener("instrumentation/comm/frequencies/selected-mhz", func {
    if (frequencies_selected_mhz_only == 0) {
          # The frequence data cames from from Radio com1 equipment
          var freq = getprop("instrumentation/comm/frequencies/selected-mhz");
          var chan = radio_set_chan_freq(nil,freq);
          if (chan > 0) {
              # The frequence is found in the tableData
              setprop("fdm/jsbsim/systems/gauges/radio/ptr175/input-freq-mhz",freq);
              setprop("fdm/jsbsim/systems/gauges/radio/ptr175/chan-selector",chan);
          };
    } else {
        frequencies_selected_mhz_only = 0;
    };

}, 0, 1);


setlistener("fdm/jsbsim/systems/gauges/radio/ptr175/chan-selector", func {

    chan_selector = getprop("fdm/jsbsim/systems/gauges/radio/ptr175/chan-selector");
    if (chan_selector_old == nil) chan_selector_old = chan_selector;
    if (chan_selector > 0 and chan_selector_old != chan_selector) {
        setprop("fdm/jsbsim/systems/gauges/radio/ptr175/chan-selector-gui",chan_selector);
        chan_selector_old = chan_selector;
    };

}, 0, 1);


setlistener("fdm/jsbsim/systems/gauges/radio/ptr175/chan-selector-gui", func {

    # chan-selector-gui It is activated when the command from the chain selector
    # of the pre-stored frequency table is set
    var chan_selector_gui = getprop("fdm/jsbsim/systems/gauges/radio/ptr175/chan-selector-gui");
    var freq = radio_normal_freq(getprop("fdm/jsbsim/systems/gauges/radio/com1/chann/data[" ~ chan_selector_gui ~ "]/freq"));
    if (freq > 0) {
        # Clear all checkbox
        list = props.globals.getNode("fdm/jsbsim/systems/gauges/radio/com1/chann").getChildren("data");
        for (var i = 1; i < 21; i += 1) {
            if (chan_selector_gui != i) {
                list[i].setIntValue("active",0);
            } else {
                list[i].setIntValue("active",1);
                list[i].setDoubleValue("freq",freq);
            }
        };
        setprop("fdm/jsbsim/systems/gauges/radio/ptr175/chan-selector",chan_selector_gui);
        setprop("fdm/jsbsim/systems/gauges/radio/ptr175/input-freq-mhz",freq);
    };

}, 0, 1);


setlistener("fdm/jsbsim/systems/gauges/radio/ptr175/chan-freq-gui", func {

    var chan_freq_gui = getprop("fdm/jsbsim/systems/gauges/radio/ptr175/chan-freq-gui");
    if (chan_freq_gui > 0.0) {
        var list = props.globals.getNode("fdm/jsbsim/systems/gauges/radio/com1/chann").getChildren("data");
        var chan_selector_gui_freq = radio_normal_freq(list[chan_freq_gui].getNode("freq").getValue());
        if (chan_selector_gui_freq > 0.0) {
            setprop("instrumentation/comm/frequencies/selected-mhz",chan_selector_gui_freq);
            setprop("fdm/jsbsim/systems/gauges/radio/ptr175/chan-selector",chan_freq_gui);
            radio_gui_error_msg(0);
        } else {
            if (list[chan_freq_gui].getNode("freq").getValue() > 0.0) {
                # Error in the frequency value
                list[chan_freq_gui].setDoubleValue("freq",0.0);
                radio_gui_error_msg(1);
            }
            list[chan_freq_gui].setIntValue("active",0);
        }
    };

    setprop("fdm/jsbsim/systems/gauges/radio/ptr175/chan-freq-gui",0);

}, 0, 1);


setlistener("fdm/jsbsim/systems/gauges/radio/ptr175/knob-function-set", func {

    knob_function_desc = "OFF";

    comm_function_set = getprop("fdm/jsbsim/systems/gauges/radio/ptr175/knob-function-set");

    if(comm_function_set == 1) {
        knob_function_desc = "ON - T/R";
    } elsif (comm_function_set == 2) {
        knob_function_desc = "ON - T/R + G";
    } elsif (comm_function_set == 3) {
        knob_function_desc = "ON - ADF";
    } elsif (comm_function_set == 4) {
        knob_function_desc = "ON - DL";
    } elsif (comm_function_set == 5) {
        knob_function_desc = "ON - DL + T";
    } elsif (comm_function_set == 6) {
        knob_function_desc = "ON - T/R On D/L Off";
    }

    setprop("fdm/jsbsim/systems/gauges/radio/ptr175/knob-function-desc",knob_function_desc ~ " | " ~ radio_status);

    #// Emerg (Guard) chan only rec.
    if (comm_function_set == 2) {
        var com2_freq = getprop("/instrumentation/comm[1]/frequencies/selected-mhz");
        var freq_guard = getprop("fdm/jsbsim/systems/gauges/radio/ptr175/freq-guard");
        if (com2_old_freq_value == nil) {
            com2_old_freq_value = com2_freq;
        } else {
            if (com2_old_freq_value != freq_guard) {
                com2_old_freq_value = com2_freq;
            };
        };
        setprop("/instrumentation/comm[1]/frequencies/selected-mhz",freq_guard);
        setprop("/instrumentation/comm[1]/power-bin",1);
    } else {
        if (com2_old_freq_value != nil) {
            setprop("/instrumentation/comm[1]/frequencies/selected-mhz",com2_old_freq_value);
            setprop("/instrumentation/comm[1]/power-bin",0);
            com2_old_freq_value = nil;
        };
    };

}, 0, 1);


var radio_ptr175_control = func() {

    delta_time_delay -= 1;

    if (delta_time_delay <= 0) {
        testing_log_active = getprop("sim/G91/testing/log");
        if (testing_log_active == nil) testing_log_active = 0;

        radio_ptr175();
        radio_gui_error_msg();

        delta_time_delay = delta_time;
    };
    radio_ptr175_controlTimer.restart(1);
}


var radio_ptr175_controlTimer = maketimer(1, radio_ptr175_control);
radio_ptr175_controlTimer.singleShot = 1;
radio_ptr175_controlTimer.start();
