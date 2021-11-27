#// Starter utility for effect and autostart engine
#// Adriano Bassignana  (abassign) nov. 2021

#// Camera position:
#// Handle brake: setprop("sim/current-view/ab-camera/to/set-position","2,0,41.71,346.0,-18.93,0.0,0.815,-2.6,1.0,2.0,2.0");
#// Electric panel: setprop("sim/current-view/ab-camera/to/set-position","1,0,38.28,354.6,-29.75,0.25,0.55,-2.9,1.0,2.0,2.0");
#// Throttle area: setprop("sim/current-view/ab-camera/to/set-position","1,0,24.29,55.65,-49.0,0.118,0.930,-2.6,1.0,2.0,2.0");
#// Starter panel: setprop("sim/current-view/ab-camera/to/set-position","1,0,23.48,37.48,-45.56,-0.019,0.7890,-2.6,1.0,2.0,2.0");
#// Motor gauges control panel: setprop("sim/current-view/ab-camera/to/set-position","1,0,30.77,330.04,-19.98,-0.202,0.659,-2.6,1.0,2.0,2.0");
#// Close the canopy: setprop("sim/current-view/ab-camera/to/set-position","1,0,56.49,21.86,-28.22,0.0,0.815,-2.6,1.0,2.0,3.0");

var prop = props.globals.initNode("fdm/jsbsim/systems/starter/gui/autostart-activate",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/starter/gui/autostart-activate-stop",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/starter/gui/autostart-stop",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/starter/gui/autostart-is-active",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/starter/gui/autostart-status-is-ok",0,"INT");
var prop = props.globals.initNode("fdm/jsbsim/systems/starter/gui/autostart-message","", "STRING");


var isStartingProcedureActive = 0;
var isStartingProcedureActiveStopped = 0;
var isStopProcedureActive = 0;
var timerEngine_starterTimer = nil;
var timeStepEffective = 1.0;
var msgOutput = "";
var cameraStatus = 0;
var cameraStatusTime = 0.0;
var actualPhaseActive = 0;
var phaseIsActive = 0;
var pushTogleSignal = 0;

var engineN1 = 0.0;
var engineN2 = 0.0;
var bus0V = 0.0;
var bus1V = 0.0;
var bus2V = 0.0;
var inverterPrimaryV = 0.0;
var inverterSecondaryV = 0.0;
var autostart_status_is_ok = 0;


var messageOutputStatus = func() {
    setprop("fdm/jsbsim/systems/starter/gui/autostart-message","Engine starter: #" ~ actualPhaseActive ~ " -> " ~ msgOutput);
};


var start_PrepareTheAirplane = func(nextActualPhaseActive = 100) {
    if (cameraStatus == 0 and phaseIsActive == 0) {
        setprop("sim/current-view/ab-camera/to/set-position","2,0,41.71,346.0,-18.93,0.0,0.815,-2.6,0.0,1.5,2.5");
        phaseIsActive = 1;
    } else {
        if (cameraStatus == 3 and phaseIsActive > 0) {
            msgOutput = "prepare the airplane";
            if (cameraStatusTime < 1.0) {
                if (getprop("fdm/jsbsim/systems/wow")) {
                    setprop("fdm/jsbsim/systems/autopilot/handle-brake-activate",1);
                    setprop("fdm/jsbsim/systems/canopy/lever-trigger",0);
                } else {
                    setprop("fdm/jsbsim/systems/autopilot/handle-brake-activate",0);
                }
            } else if (cameraStatusTime > 1.0 and cameraStatusTime < 2.0) {
                if (getprop("fdm/jsbsim/systems/canopy/position") > 0.01 and cameraStatusTime > 1.5 and cameraStatusTime < 2.0) {
                    setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-canopy-trigger",-1);
                };
            } else if (cameraStatusTime > 2.0) {
                setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-canopy-trigger",0);
                setprop("controls/engines/engine/throttle",0.0);
            };
        };
        if (cameraStatus == 0 and phaseIsActive > 0) {
            actualPhaseActive = nextActualPhaseActive;
            phaseIsActive = 0;
        };
    };
};


var start_PrepareElectricPanel = func(nextActualPhaseActive = 100) {
    if (cameraStatus == 0 and phaseIsActive == 0) {
        setprop("sim/current-view/ab-camera/to/set-position","1,0,38.28,354.6,-29.75,0.25,0.55,-2.9,1.0,2.0,2.0");
        phaseIsActive = 1;
    } else {
        if (cameraStatus == 3 and phaseIsActive > 0) {
            if (cameraStatusTime < 1.0) {
                msgOutput = "set electric primary panel";
                setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-internal-power-generator",0);
                setprop("fdm/jsbsim/systems/electric/bus[2]/primary-inverter/sw",0);
                setprop("fdm/jsbsim/systems/electric/bus[1]/secondary-inverter/sw",0);
                setprop("fdm/jsbsim/systems/lightning/light-uv-instrument-bright",0);
                setprop("fdm/jsbsim/systems/lightning/light-red-emer-instrument-bright",0);
                setprop("fdm/jsbsim/systems/lightning/light-red-console-bright",0);
                setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-bus0-bus1-battery",1);
            } else if (cameraStatusTime > 1.0 and cameraStatusTime < 1.5) {
                setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-bus0-bus1-battery-trigger",0);
            };
        };
        if (cameraStatus == 0 and phaseIsActive > 0) {
            actualPhaseActive = nextActualPhaseActive;
            phaseIsActive = 0;
        };
    };
};


var start_PrepareLightPanel = func(nextActualPhaseActive = 100,nextAlternateActualPhaseActive = 100) {
    if (getprop("fdm/jsbsim/systems/lightning/ambient-light") < 0.18) {
        if (cameraStatus == 0 and phaseIsActive == 0) {
            setprop("sim/current-view/ab-camera/to/set-position","1,0,44.628,311.114,-53.637,0.000,0.815,-2.600,0.0,2.0,4.0");
            phaseIsActive = 1;
        } else {
            msgOutput = "configure the interior lighting";
            if (cameraStatus == 3 and phaseIsActive > 0) {
                if (cameraStatusTime < 1.0) {
                    var l = 1.0 - cameraStatusTime;
                    if (l < 0.15) l = 0.0;
                    setprop("fdm/jsbsim/systems/lightning/light-uv-instrument-bright",l);
                } else if (cameraStatusTime > 1.0 and cameraStatusTime < 2.0) {
                    var l = cameraStatusTime - 1;
                    if (l > 1.0) l = 1.0;
                    setprop("fdm/jsbsim/systems/lightning/light-red-emer-instrument-bright",l);
                } else if (cameraStatusTime > 2.0) {
                    var l = cameraStatusTime - 2;
                    if (l > 1.0) l = 1.0;
                    setprop("fdm/jsbsim/systems/lightning/light-red-console-bright",l);
                };
            };
            if (cameraStatus == 0 and phaseIsActive > 0) {
                actualPhaseActive = nextActualPhaseActive;
                phaseIsActive = 0;
            };
        };
    } else {
        actualPhaseActive = nextAlternateActualPhaseActive;
        phaseIsActive = 0;
    };
};


var start_ShowLightingRed = func(nextActualPhaseActive = 100) {
    if (cameraStatus == 0 and phaseIsActive == 0) {
        setprop("sim/current-view/ab-camera/to/set-position","1,0,76.971,358.576,-39.119,0.000,0.815,-2.600,0.0,2,0,2.0");
        phaseIsActive = 1;
    } else {
        if (cameraStatus == 0 and phaseIsActive > 0) {
            actualPhaseActive = nextActualPhaseActive;
            phaseIsActive = 0;
        };
    };
};


var start_PrepareStarterPanel = func(nextActualPhaseActive = 100) {
    if (cameraStatus == 0 and phaseIsActive == 0) {
        setprop("sim/current-view/ab-camera/to/set-position","1,0,23.48,37.48,-45.56,-0.019,0.789,-2.6,1.0,2.0,3.0");
        phaseIsActive = 1;
    } else {
        if (cameraStatus == 3 and phaseIsActive > 0) {
            msgOutput = "set left starter panel";
            if (cameraStatusTime < 0.5) {
                setprop("fdm/jsbsim/systems/starter/emerg-engine",0);
                setprop("fdm/jsbsim/systems/starter/drop-tank-press",0);
                setprop("fdm/jsbsim/systems/starter/fuel-shut-off-valve-lock",1);
            } else if (cameraStatusTime > 0.5 and cameraStatusTime < 1.0) {
                setprop("fdm/jsbsim/systems/starter/fuel-shut-off-valve",0);
            } else if (cameraStatusTime > 1.2) {
                setprop("fdm/jsbsim/systems/starter/fuel-shut-off-valve-lock",0);
            };
        };
        if (cameraStatus == 0 and phaseIsActive > 0) {
            actualPhaseActive = nextActualPhaseActive;
            phaseIsActive = 0;
        };
    };
};


var start_PrepareStarterPanelBoosterPump = func(nextActualPhaseActive = 100) {
    if (cameraStatus == 0 and phaseIsActive == 0) {
        setprop("sim/current-view/ab-camera/to/set-position","1,0,23.48,37.48,-45.56,-0.019,0.789,-2.6,1.0,2.0,3.0");
        phaseIsActive = 1;
    } else {
        if (cameraStatus == 3 and phaseIsActive > 0) {
            msgOutput = "set left starter panel";
            if (cameraStatusTime < 0.5) {
                msgOutput = "set left starter panel fuel - Booster pump on";
                setprop("fdm/jsbsim/systems/starter/fuel-booster-pump",1);
            } else if (cameraStatusTime > 1.0 and cameraStatusTime < 1.5) {
                msgOutput = "set left starter panel fuel - Engine JPTL on";
                setprop("fdm/jsbsim/systems/starter/engine-JPTL",1);
            } else if (cameraStatusTime > 2.0) {
                setprop("fdm/jsbsim/systems/starter/NE",1);
            };
        };
        if (cameraStatus == 0 and phaseIsActive > 0) {
            actualPhaseActive = nextActualPhaseActive;
            phaseIsActive = 0;
        };
    };
};


var start_SetThrottle = func(nextActualPhaseActive = 100,setPosition = nil) {
    if (cameraStatus == 0 and phaseIsActive == 0) {
        if (setPosition == nil) {
            setprop("sim/current-view/ab-camera/to/set-position","1,0,24.29,55.65,-49.0,0.118,0.930,-2.6,0.1,0.5,1.0");
        } else {
            setprop("sim/current-view/ab-camera/to/set-position",setPosition);
        };
        phaseIsActive = 1;
    } else {
        if (cameraStatus == 3 and phaseIsActive > 0) {
            if (cameraStatusTime < 0.5) {
                msgOutput = "set throttle - Ignition push starter on throttle";
                setprop("fdm/jsbsim/systems/starter/ignition-on-throttle-togle",1);
            };
        };
        if (cameraStatus == 0 and phaseIsActive > 0) {
            actualPhaseActive = nextActualPhaseActive;
            phaseIsActive = 0;
        };
    };
};


var start_StarterPanelPushIgnition = func(nextActualPhaseActive = 100,setPosition = nil,activeCamera = 1) {
    if (cameraStatus == 0 and phaseIsActive == 0) {
        if (setPosition == nil) {
            setprop("sim/current-view/ab-camera/to/set-position","1,0,23.48,37.48,-45.56,-0.019,0.789,-2.6,0.1,0.5,3.0");
        } else {
            setprop("sim/current-view/ab-camera/to/set-position",setPosition);
        };
        phaseIsActive = 1;
        pushTogleSignal = 0;
    } else {
        if (cameraStatus == 3 and phaseIsActive > 0) {
            if (cameraStatusTime < 1.0) {
                msgOutput = "set left starter panel - Ignition remove fire button cover";
                if (pushTogleSignal == 0) {
                    var swCoverTogle = getprop("fdm/jsbsim/systems/starter/sw-cover-togle");
                    if (swCoverTogle == 0) {
                        setprop("fdm/jsbsim/systems/starter/sw-cover-togle",1);
                    } else {
                        setprop("fdm/jsbsim/systems/starter/sw-cover-togle",0);
                    };
                    pushTogleSignal = 1;
                };
            } else if (cameraStatusTime > 1.5 and cameraStatusTime < 2.0) {
                if (pushTogleSignal == 1) {
                    msgOutput = "set left starter panel - push ignition button";
                    var pt = getprop("fdm/jsbsim/systems/starter/sw-push-togle");
                    if (pt == 0) {
                        setprop("fdm/jsbsim/systems/starter/sw-push-togle",1);
                    } else {
                        setprop("fdm/jsbsim/systems/starter/sw-push-togle",0);
                    };
                    pushTogleSignal = 2;
                };
            };
        };
        if (cameraStatus == 0 and phaseIsActive > 0 and autostart_status_is_ok > 0) {
            actualPhaseActive = nextActualPhaseActive;
            phaseIsActive = 0;
        };
    };
};


var start_RPMGaugeAfterPushIgnition = func(nextActualPhaseActive = 100,isFastMode = 0) {
    if (cameraStatus == 0 and phaseIsActive == 0) {
        if (isFastMode) {
            setprop("sim/current-view/ab-camera/to/set-position","1,0,30.77,330.04,-19.98,-0.202,0.659,-2.6,0.1,0.5,3.0");
        } else {
            setprop("sim/current-view/ab-camera/to/set-position","1,0,30.77,330.04,-19.98,-0.202,0.659,-2.6,1.0,2.0,8.0");
        };
        phaseIsActive = 1;
    } else {
        if (cameraStatus == 3 and phaseIsActive > 0) {
            msgOutput = "Motor gauges control panel, look the RPM";
        };
        if (cameraStatus == 0 and phaseIsActive > 0 and engineN1 > 0.40) {
            actualPhaseActive = nextActualPhaseActive;
            phaseIsActive = 0;
        };
    };
};


var start_ActivateElectricPanel = func(nextActualPhaseActive = 100) {
    msgOutput = "set electric - Internal power generator is on";
    if (cameraStatus == 0 and phaseIsActive == 0) {
        setprop("sim/current-view/ab-camera/to/set-position","1,0,38.28,354.6,-29.75,0.25,0.55,-2.9,1.0,2.0,2.0");
        phaseIsActive = 1;
    } else {
        if (cameraStatus == 3 and phaseIsActive > 0) {
            msgOutput = "set left starter panel";
            setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-internal-power-generator-trigger",1);
            setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-internal-power-generator",1);
        };
        if (cameraStatus == 0 and phaseIsActive > 0 and bus2V > 18.0) {
            actualPhaseActive = nextActualPhaseActive;
            phaseIsActive = 0;
        };
    };
};


var start_StarterPanelAfterPushIgnition = func(nextActualPhaseActive = 100) {
    if (cameraStatus == 0 and phaseIsActive == 0) {
        setprop("sim/current-view/ab-camera/to/set-position","1,0,23.48,37.48,-45.56,-0.019,0.789,-2.6,1.0,1.0,3.0");
        phaseIsActive = 1;
    } else {
        if (cameraStatus == 3 and phaseIsActive > 0) {
            if (cameraStatusTime < 0.5) {
                msgOutput = "set left starter panel - stop fuel booster pump";
                setprop("fdm/jsbsim/systems/starter/fuel-booster-pump",0);
            } else if (cameraStatusTime >= 0.5 and cameraStatusTime < 1.0) {
                setprop("fdm/jsbsim/systems/starter/NE",0);
            } else if (cameraStatusTime >= 1.5 and cameraStatusTime < 2.0) {
                setprop("fdm/jsbsim/systems/starter/engine-JPTL",0);
            };
        };
        if (cameraStatus == 0 and phaseIsActive > 0) {
            actualPhaseActive = nextActualPhaseActive;
            phaseIsActive = 0;
        };
    };
};


var start_ActivateElectricPanelInverters = func(nextActualPhaseActive = 100) {
    if (cameraStatus == 0 and phaseIsActive == 0) {
        setprop("sim/current-view/ab-camera/to/set-position","1,0,38.28,354.6,-29.75,0.25,0.55,-2.9,1.0,1.0,6.0");
        phaseIsActive = 1;
    } else {
        if (cameraStatus == 3 and phaseIsActive > 0) {
            if (cameraStatusTime < 0.5) {
                msgOutput = "set electric - primary inverter on";
                setprop("fdm/jsbsim/systems/electric/bus[2]/primary-inverter/sw",1);
            } else if (cameraStatusTime > 1.5 and cameraStatusTime < 2.0) {
                msgOutput = "set electric - secondary inverter on";
                setprop("fdm/jsbsim/systems/electric/bus[1]/secondary-inverter/sw",1);
            };
        };
        if (cameraStatus == 0 and phaseIsActive > 0 and inverterPrimaryV > 100.0 and inverterSecondaryV > 100.0) {
            actualPhaseActive = nextActualPhaseActive;
            phaseIsActive = 0;
        };
    };
};


var start_CloseTheCanopy = func(nextActualPhaseActive = 100) {
    if (cameraStatus == 0 and phaseIsActive == 0) {
        setprop("sim/current-view/ab-camera/to/set-position","1,0,56.49,21.86,-28.22,0.0,0.815,-2.6,1.0,2.0,3.0");
        phaseIsActive = 1;
    } else {
        if (cameraStatus == 3 and phaseIsActive > 0) {
            if (cameraStatusTime < 0.5) {
                msgOutput = "Close the canopy";
                setprop("fdm/jsbsim/systems/canopy/lever-trigger",1);
            };
        };
        if (cameraStatus == 0 and phaseIsActive > 0) {
            actualPhaseActive = nextActualPhaseActive;
            phaseIsActive = 0;
        };
    };
};


var start_SetLightPanel = func(nextActualPhaseActive = 100, nextAlternateActualPhaseActive = 100) {
    if (getprop("fdm/jsbsim/systems/lightning/ambient-light") < 0.18) {
        if (cameraStatus == 0 and phaseIsActive == 0) {
            setprop("sim/current-view/ab-camera/to/set-position","1,0,44.628,311.114,-53.637,0.000,0.815,-2.600,0.0,2.0,4.0");
            phaseIsActive = 1;
        } else {
            if (cameraStatus == 3 and phaseIsActive > 0) {
                if (cameraStatusTime < 1.0) {
                    var l = cameraStatusTime;
                    if (l > 0.8) l = 0.8;
                    setprop("fdm/jsbsim/systems/lightning/light-uv-instrument-bright",l);
                } else if (cameraStatusTime > 1.0 and cameraStatusTime < 2.0) {
                    var l = 1 - (cameraStatusTime - 1);
                    if (l < 0.15) l = 0.0;
                    setprop("fdm/jsbsim/systems/lightning/light-red-emer-instrument-bright",l);
                } else if (cameraStatusTime > 2.0 and cameraStatusTime < 3.0) {
                    var l = 1 - (cameraStatusTime - 2);
                    if (l < 0.4) l = 0.4;
                    setprop("fdm/jsbsim/systems/lightning/light-red-console-bright",l);
                } else if (cameraStatusTime > 3.0 and cameraStatusTime < 3.5) {
                    setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-landing-light",1);
                    setprop("fdm/jsbsim/systems/manual-switches/lateral_panel_right/lightning/sw-position-intensity-togle",1);
                    setprop("fdm/jsbsim/systems/manual-switches/lateral_panel_right/lightning/sw-anticollision-togle",1);
                    setprop("fdm/jsbsim/systems/manual-switches/lateral_panel_right/lightning/sw-flasher-togle",1);
                };
            };
            if (cameraStatus == 0 and phaseIsActive > 0) {
                actualPhaseActive = nextActualPhaseActive;
                phaseIsActive = 0;
            };
        };
    } else {
        actualPhaseActive = nextAlternateActualPhaseActive;
        phaseIsActive = 0;
    };
};


var start_TestLights = func(nextActualPhaseActive = 100) {
    if (cameraStatus == 0 and phaseIsActive == 0) {
        setprop("sim/current-view/ab-camera/to/set-position","1,0,93.0,0.0,-21.0,0.000,0.815,-2.600,0.0,1.0,4.0");
        phaseIsActive = 1;
    } else {
        if (cameraStatus == 3 and phaseIsActive > 0) {
            if (cameraStatusTime < 1.0) {
                setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-landing-light",1);
            } else if (cameraStatusTime > 2.0 and cameraStatusTime < 2.5) {
                setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-landing-light-test-trigger",1);
            } else if (cameraStatusTime > 3.0 and (getprop("fdm/jsbsim/systems/lightning/ambient-light") > 0.18) and cameraStatusTime < 3.5) {
                setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-landing-light",0);
            };
        };
        if (cameraStatus == 0 and phaseIsActive > 0) {
            actualPhaseActive = nextActualPhaseActive;
            phaseIsActive = 0;
        };
    };
};


var stop_PrepareTheAirplane = func(nextActualPhaseActive = 100) {
    if (cameraStatus == 0 and phaseIsActive == 0) {
        setprop("sim/current-view/ab-camera/to/set-position","1,0,26.0,55.65,-49.0,0.118,0.930,-2.6,1.0,2.0,3.0");
        phaseIsActive = 1;
    } else {
        if (cameraStatus == 3 and phaseIsActive > 0) {
            msgOutput = "prepare the airplane";
            if (getprop("fdm/jsbsim/gear/wow")) {
                setprop("fdm/jsbsim/systems/autopilot/handle-brake-activate",1);
            } else {
                setprop("fdm/jsbsim/systems/autopilot/handle-brake-activate",0);
            }
        };
        if (cameraStatus == 0 and phaseIsActive > 0) {
            actualPhaseActive = nextActualPhaseActive;
            phaseIsActive = 0;
        };
    };
};


var stop_StopACElectricPanel = func(nextActualPhaseActive = 100) {
    if (cameraStatus == 0 and phaseIsActive == 0) {
        setprop("sim/current-view/ab-camera/to/set-position","1,0,38.28,354.6,-29.75,0.25,0.55,-2.9,1.0,1.5,3.0");
        phaseIsActive = 1;
    } else {
        if (cameraStatus == 3 and phaseIsActive > 0) {
            msgOutput = "set electric primary panel";
            if (cameraStatusTime < 1.0) {
                setprop("fdm/jsbsim/systems/electric/bus[2]/primary-inverter/sw",0);
            } else if (cameraStatusTime > 1.0 and cameraStatusTime < 2.0) {
                setprop("fdm/jsbsim/systems/electric/bus[1]/secondary-inverter/sw",0);
            } else if (cameraStatusTime > 2.0) {
                setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-landing-light",0);
                setprop("fdm/jsbsim/systems/manual-switches/lateral_panel_right/lightning/sw-position-intensity-togle",0);
                setprop("fdm/jsbsim/systems/manual-switches/lateral_panel_right/lightning/sw-anticollision-togle",0);
                setprop("fdm/jsbsim/systems/manual-switches/lateral_panel_right/lightning/sw-flasher-togle",0);
            };
        };
        if (cameraStatus == 0 and phaseIsActive > 0) {
            actualPhaseActive = nextActualPhaseActive;
            phaseIsActive = 0;
        };
    };
};


var stop_PrepareStarterPanel = func(nextActualPhaseActive = 100) {
    if (cameraStatus == 0 and phaseIsActive == 0) {
        setprop("sim/current-view/ab-camera/to/set-position","1,0,23.48,37.48,-45.56,-0.019,0.789,-2.6,1.0,2.0,5.0");
        phaseIsActive = 1;
    } else {
        if (cameraStatus == 3 and phaseIsActive > 0) {
            msgOutput = "set left starter panel stop motor procedure";
            if (cameraStatusTime < 0.5) {
                setprop("fdm/jsbsim/systems/starter/emerg-engine",0);
                setprop("fdm/jsbsim/systems/starter/drop-tank-press",0);
            } else if (cameraStatusTime > 0.5 and cameraStatusTime < 1.0) {
                setprop("fdm/jsbsim/systems/starter/fuel-booster-pump",0);
            } else if (cameraStatusTime > 1.0 and cameraStatusTime < 1.5) {
                setprop("fdm/jsbsim/systems/starter/engine-JPTL",0);
            } else if (cameraStatusTime > 1.5 and cameraStatusTime < 2.0) {
                setprop("fdm/jsbsim/systems/starter/NE",1);
            } else if (cameraStatusTime > 2.0 and cameraStatusTime < 2.5) {
                setprop("fdm/jsbsim/systems/starter/fuel-shut-off-valve-lock",1);
            } else if (cameraStatusTime > 3.0 and cameraStatusTime < 4.0) {
                setprop("fdm/jsbsim/systems/starter/fuel-shut-off-valve",1);
            } else if (cameraStatusTime > 4.0) {
                setprop("controls/engines/engine/throttle",0.8);
            };
        };
        if (cameraStatus == 0 and phaseIsActive > 0) {
            actualPhaseActive = nextActualPhaseActive;
            phaseIsActive = 0;
        };
    };
};


var stop_RPMGaugeAfterPushIgnition = func(nextActualPhaseActive = 100) {
    if (cameraStatus == 0 and phaseIsActive == 0) {
        setprop("sim/current-view/ab-camera/to/set-position","1,0,30.77,330.04,-19.98,-0.202,0.659,-2.6,1.0,2.0,3.0");
        phaseIsActive = 1;
    } else {
        if (cameraStatus == 3 and phaseIsActive > 0) {
            msgOutput = "Motor gauges control panel, look the RPM";
        };
        if (cameraStatus == 0 and phaseIsActive > 0 and engineN1 < 0.01) {
            actualPhaseActive = nextActualPhaseActive;
            phaseIsActive = 0;
        };
    };
};


var stop_AfterStopStarterPanel = func(nextActualPhaseActive = 100,nextAlternateActualPhaseActive = 100) {
    if (cameraStatus == 0 and phaseIsActive == 0) {
        setprop("sim/current-view/ab-camera/to/set-position","1,0,23.48,37.48,-45.56,-0.019,0.789,-2.6,1.0,1.5,2.0");
        phaseIsActive = 1;
    } else {
        if (cameraStatus == 3 and phaseIsActive > 0) {
            msgOutput = "set left starter panel after stop procedure";
            setprop("fdm/jsbsim/systems/starter/fuel-shut-off-valve-lock",0);
        };
        if (cameraStatus == 0 and phaseIsActive > 0) {
            if (getprop("fdm/jsbsim/gear/wow")) {
                actualPhaseActive = nextActualPhaseActive;
            } else {
                actualPhaseActive = nextAlternateActualPhaseActive; #//30
            };
            phaseIsActive = 0;
        };
    };
};


var stop_OpenTheCanopy = func(nextActualPhaseActive = 100) {
    if (cameraStatus == 0 and phaseIsActive == 0) {
        setprop("sim/current-view/ab-camera/to/set-position","1,0,39.89,12.88,-12.31,-0.179,0.553,-2.6,1.0,2.0,3.0");
        phaseIsActive = 1;
    } else {
        if (cameraStatus == 3 and phaseIsActive > 0) {
            msgOutput = "open the canopy";
            if (cameraStatusTime < 0.5) {
                setprop("fdm/jsbsim/systems/canopy/lever-trigger",0);
            } else if (cameraStatusTime > 2.0 and cameraStatusTime < 2.5) {
                setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-canopy-trigger",1);
            } else {
                setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-canopy-trigger",0);
            };
        };
        if (cameraStatus == 0 and phaseIsActive > 0) {
            actualPhaseActive = nextActualPhaseActive;
            phaseIsActive = 0;
        };
    };
};


var stop_OpenTheCanopyPursuit = func(nextActualPhaseActive = 100) {
    if (cameraStatus == 0 and phaseIsActive == 0) {
        setprop("sim/current-view/ab-camera/to/set-position","1,0,73.376,358.169,68.362,0.003,0.815,-2.600,0.0,5.0,1.0");
        phaseIsActive = 1;
    } else {
        if (cameraStatus == 3 and phaseIsActive > 0) {
            msgOutput = "opening the canopy";
        };
        if (cameraStatus == 0 and phaseIsActive > 0) {
            actualPhaseActive = nextActualPhaseActive;
            phaseIsActive = 0;
        };
    };
};


var stop_AfterStopElectricPanel = func(nextActualPhaseActive = 100) {
    if (cameraStatus == 0 and phaseIsActive == 0) {
        setprop("sim/current-view/ab-camera/to/set-position","1,0,38.28,354.6,-29.75,0.25,0.55,-2.9,1.0,1.5,3.0");
        phaseIsActive = 1;
    } else {
        if (cameraStatus == 3 and phaseIsActive > 0) {
            setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-bus0-bus1-battery",0);
        };
        if (cameraStatus == 0 and phaseIsActive > 0) {
            actualPhaseActive = nextActualPhaseActive;
            phaseIsActive = 0;
        };
    };
};


#// Fast start section functions

var start_FastPreamble = func(nextActualPhaseActive = 100) {
    if (cameraStatus == 0 and phaseIsActive == 0) {
        setprop("sim/current-view/ab-camera/to/set-position","2,0,93.0,0.0,-21.0,0.000,0.815,-2.600,0.0,1.0,2.5");
        phaseIsActive = 1;
    } else {
        if (cameraStatus == 3 and phaseIsActive > 0) {
            if (cameraStatusTime < 1.0) {
                msgOutput = "prepare the electric system";
                setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-canopy-trigger",0);
                setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-internal-power-generator",0);
                setprop("fdm/jsbsim/systems/electric/bus[2]/primary-inverter/sw",0);
                setprop("fdm/jsbsim/systems/electric/bus[1]/secondary-inverter/sw",0);
                setprop("fdm/jsbsim/systems/lightning/light-uv-instrument-bright",0);
                setprop("fdm/jsbsim/systems/lightning/light-red-emer-instrument-bright",0);
                setprop("fdm/jsbsim/systems/lightning/light-red-console-bright",0);
                setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-bus0-bus1-battery",1);
                setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-bus0-bus1-battery-trigger",0);
                setprop("fdm/jsbsim/systems/canopy/lever-trigger",0);
                if (getprop("fdm/jsbsim/systems/lightning/ambient-light") < 0.18) {
                    setprop("fdm/jsbsim/systems/lightning/light-uv-instrument-bright",0);
                    setprop("fdm/jsbsim/systems/lightning/light-red-emer-instrument-bright",1.0);
                    setprop("fdm/jsbsim/systems/lightning/light-red-console-bright",1.0);
                };
            } else if (cameraStatusTime > 1.0) {
                msgOutput = "prepare the engine system";
                setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-canopy-trigger",-1);
                setprop("fdm/jsbsim/systems/starter/emerg-engine",0);
                setprop("fdm/jsbsim/systems/starter/drop-tank-press",0);
                setprop("fdm/jsbsim/systems/starter/fuel-shut-off-valve",0);
                setprop("fdm/jsbsim/systems/starter/fuel-booster-pump",1);
                setprop("fdm/jsbsim/systems/starter/engine-JPTL",1);
                setprop("fdm/jsbsim/systems/starter/NE",1);
            } else if (cameraStatusTime > 1.5) {
                setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-canopy-trigger",0);
            };
        };
        if (cameraStatus == 0 and phaseIsActive > 0) {
            actualPhaseActive = nextActualPhaseActive;
            phaseIsActive = 0;
            setprop("sim/current-view/ab-camera/to/setViewActive",1);
        };
    };
};


var start_FastClosure = func(nextActualPhaseActive = 100) {
    if (cameraStatus == 0 and phaseIsActive == 0) {
        setprop("sim/current-view/ab-camera/to/set-position","1,0,93.0,0.0,-21.0,0.000,0.815,-2.600,0.0,1.0,5.0");
        phaseIsActive = 1;
    } else {
        if (cameraStatus == 3 and phaseIsActive > 0) {
            if (cameraStatusTime < 1.0) {
                msgOutput = "setup operative electric system and lights";
                setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-internal-power-generator-trigger",1);
                setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-internal-power-generator",1);
                setprop("fdm/jsbsim/systems/starter/fuel-booster-pump",0);
                setprop("fdm/jsbsim/systems/starter/NE",0);
                setprop("fdm/jsbsim/systems/starter/engine-JPTL",0);
                setprop("fdm/jsbsim/systems/electric/bus[2]/primary-inverter/sw",1);
                setprop("fdm/jsbsim/systems/electric/bus[1]/secondary-inverter/sw",1);
            } else if (cameraStatusTime > 1.0 and cameraStatusTime < 4.0) {
                if (getprop("fdm/jsbsim/systems/lightning/ambient-light") < 0.18) {
                    setprop("fdm/jsbsim/systems/lightning/light-uv-instrument-bright",0.8);
                    setprop("fdm/jsbsim/systems/lightning/light-red-emer-instrument-bright",0.0);
                    setprop("fdm/jsbsim/systems/lightning/light-red-console-bright",0.4);
                    setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-landing-light",1);
                    setprop("fdm/jsbsim/systems/manual-switches/cockpit/sw-landing-light-test-trigger",1);
                    setprop("fdm/jsbsim/systems/manual-switches/lateral_panel_right/lightning/sw-position-intensity-togle",1);
                    setprop("fdm/jsbsim/systems/manual-switches/lateral_panel_right/lightning/sw-anticollision-togle",1);
                    setprop("fdm/jsbsim/systems/manual-switches/lateral_panel_right/lightning/sw-flasher-togle",1);
                };
            } else if (cameraStatusTime > 4.0) {
                setprop("fdm/jsbsim/systems/canopy/lever-trigger",1);
            };
        };
        if (cameraStatus == 0 and phaseIsActive > 0) {
            actualPhaseActive = nextActualPhaseActive;
            phaseIsActive = 0;
            setprop("sim/current-view/ab-camera/to/setViewActive",1);
        };
    };
};


var timerEngine_starter = func() {

    engineN1 = getprop("fdm/jsbsim/propulsion/engine[0]/n1");
    engineN2 = getprop("fdm/jsbsim/propulsion/engine[0]/n2");
    bus0V = getprop("fdm/jsbsim/systems/electric/bus[0]/V");
    bus1V = getprop("fdm/jsbsim/systems/electric/bus[1]/V");
    bus2V = getprop("fdm/jsbsim/systems/electric/bus[2]/V");
    inverterPrimaryV = getprop("fdm/jsbsim/systems/electric/inv-primary/V");
    inverterSecondaryV = getprop("fdm/jsbsim/systems/electric/inv-secondary/V");
    autostart_status_is_ok = 0;
    
    if (engineN1 >= 0.38 and engineN2 >= 0.38) {
        setprop("fdm/jsbsim/systems/starter/gui/autostart-status-is-ok",1);
        autostart_status_is_ok = 1;
    } else {
        setprop("fdm/jsbsim/systems/starter/gui/autostart-status-is-ok",0);
        autostart_status_is_ok = 0;
    }

    var guiAutostartActivate = getprop("fdm/jsbsim/systems/starter/gui/autostart-activate");

    if (guiAutostartActivate == 1 and (autostart_status_is_ok == 0 or actualPhaseActive > 0)) {
        cameraStatus = getprop("sim/current-view/ab-camera/to/status");
        cameraStatusTime = getprop("sim/current-view/ab-camera/to/status-time");
        if (actualPhaseActive == 0) {
            msgOutput = "start procedure";
            actualPhaseActive = 1;
            phaseIsActive = 0;
            setprop("sim/G91/accessories/illuminators/isParkingStartStop",1);
        } else if (actualPhaseActive == 1) {
            start_PrepareTheAirplane(2);
        } else if (actualPhaseActive == 2) {
            start_PrepareElectricPanel(3);
        } else if (actualPhaseActive == 3) {
            start_PrepareLightPanel(4,5);
        } else if (actualPhaseActive == 4) {
            start_ShowLightingRed(5);
        } else if (actualPhaseActive == 5) {
            start_PrepareStarterPanel(6);
        } else if (actualPhaseActive == 6) {
            start_PrepareStarterPanelBoosterPump(7);
        } else if (actualPhaseActive == 7) {
            start_SetThrottle(8);
        } else if (actualPhaseActive == 8) {
            start_StarterPanelPushIgnition(9);
        } else if (actualPhaseActive == 9) {
            start_RPMGaugeAfterPushIgnition(10);
        } else if (actualPhaseActive == 10) {
            start_ActivateElectricPanel(11);
        } else if (actualPhaseActive == 11) {
            start_StarterPanelAfterPushIgnition(12);
        } else if (actualPhaseActive == 12) {
            start_ActivateElectricPanelInverters(13);
        } else if (actualPhaseActive == 13) {
            start_CloseTheCanopy(14);
        } else if (actualPhaseActive == 14) {
            start_SetLightPanel(15,100);
        } else if (actualPhaseActive == 15) {
            start_TestLights();
        } else {
            #// End cycle
            msgOutput = "terminate the start procedure";
            setprop("fdm/jsbsim/systems/starter/gui/autostart-activate",0);
            setprop("sim/current-view/ab-camera/to/command",12);
            setprop("fdm/jsbsim/systems/starter/gui/autostart-activate-stop",1);
            #// Setup radios
            setprop("fdm/jsbsim/systems/gauges/radio/ptr175/knob-function-set",1);
            setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/mode-trigger",2);
            setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-active-trigger",1);
        };
        messageOutputStatus();
    } else if (guiAutostartActivate == 2 and (autostart_status_is_ok == 0 or actualPhaseActive > 0)) {
        cameraStatus = getprop("sim/current-view/ab-camera/to/status");
        cameraStatusTime = getprop("sim/current-view/ab-camera/to/status-time");
        if (actualPhaseActive == 0) {
            msgOutput = "start fast procedure";
            actualPhaseActive = 1;
            phaseIsActive = 0;
            setprop("sim/G91/accessories/illuminators/isParkingStartStop",1);
        } else if (actualPhaseActive == 1) {
            start_FastPreamble(2);
        } else if (actualPhaseActive == 2) {
            start_SetThrottle(3,"2,0,93.0,0.0,-21.0,0.000,0.815,-2.600,0.0,1.0,2.5");
        } else if (actualPhaseActive == 3) {
            start_StarterPanelPushIgnition(4,"2,0,93.0,0.0,-21.0,0.000,0.815,-2.600,0.0,1.0,2.5");
        } else if (actualPhaseActive == 4) {
            start_FastClosure();
        } else {
            #// End cycle
            msgOutput = "terminate the start procedure";
            setprop("fdm/jsbsim/systems/starter/gui/autostart-activate",0);
            setprop("sim/current-view/ab-camera/to/command",12);
            setprop("fdm/jsbsim/systems/starter/gui/autostart-activate-stop",1);
            #// Setup radios
            setprop("fdm/jsbsim/systems/gauges/radio/ptr175/knob-function-set",1);
            setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/mode-trigger",2);
            setprop("fdm/jsbsim/systems/autopilot/pilot-radio-assistant/automatic-to-radial-active-trigger",1);
        };
        messageOutputStatus();
    } else {
        var guiAutostartStop = getprop("fdm/jsbsim/systems/starter/gui/autostart-stop");
        if (guiAutostartStop >= 1 and (autostart_status_is_ok > 0 or actualPhaseActive > 0)) {
            cameraStatus = getprop("sim/current-view/ab-camera/to/status");
            cameraStatusTime = getprop("sim/current-view/ab-camera/to/status-time");
            if (actualPhaseActive == 0) {
                msgOutput = "stop procedure";
                actualPhaseActive = 20;
                phaseIsActive = 0;
                setprop("sim/G91/accessories/illuminators/isParkingStartStop",1);
            } else if (actualPhaseActive == 20) {
                stop_PrepareTheAirplane(21);
            } else if (actualPhaseActive == 21) {
                stop_StopACElectricPanel(22);
            } else if (actualPhaseActive == 22) {
                stop_PrepareStarterPanel(23);
            } else if (actualPhaseActive == 23) {
                stop_RPMGaugeAfterPushIgnition(24);
            } else if (actualPhaseActive == 24) {
                stop_AfterStopStarterPanel(25,30);
            }  else if (actualPhaseActive == 25) {
                stop_OpenTheCanopy(26);
            }else if (actualPhaseActive == 26) {
                stop_OpenTheCanopyPursuit(30);
            } else if (actualPhaseActive == 30) {
                stop_AfterStopElectricPanel();
            } else {
                #// End cycle
                msgOutput = "terminate the start procedure";
                setprop("sim/current-view/ab-camera/to/command",12);
                setprop("fdm/jsbsim/systems/starter/gui/autostart-stop",0);
                 #// Setup radios
                setprop("fdm/jsbsim/systems/gauges/radio/ptr175/knob-function-set",0);
            };
            messageOutputStatus();
        };
    };

    ##// print("** timerEngine_starter: ",actualPhaseActive," | ",cameraStatusTime," | ",cameraStatusTime);

};


setlistener("fdm/jsbsim/systems/starter/gui/autostart-activate", func {

    isStartingProcedureActive = getprop("fdm/jsbsim/systems/starter/gui/autostart-activate");
    if (isStartingProcedureActive > 0 and timerEngine_starterTimer == nil) {
        setprop("fdm/jsbsim/systems/starter/gui/autostart-activate-stop",0);
        setprop("fdm/jsbsim/systems/starter/gui/autostart-stop",0);
        timerEngine_starterTimer = maketimer(0.1, timerEngine_starter);
        timerEngine_starterTimer.singleShot = 0;
        #// timerEngine_starterTimer.simulatedTime = 1;
        timerEngine_starterTimer.start();
    } else if (isStartingProcedureActive > 0) {
        setprop("fdm/jsbsim/systems/starter/gui/autostart-activate-stop",0);
        setprop("fdm/jsbsim/systems/starter/gui/autostart-stop",0);
        timerEngine_starterTimer.restart(0.1);
    };

}, 0, 1);


setlistener("fdm/jsbsim/systems/starter/gui/autostart-activate-stop", func {

    isStartingProcedureActiveStopped = getprop("fdm/jsbsim/systems/starter/gui/autostart-activate-stop");
    if (isStartingProcedureActiveStopped == 1) {
        actualPhaseActive = 0;
        isStartingProcedureActive = 0;
        setprop("fdm/jsbsim/systems/starter/gui/autostart-activate",0);
        isStartingProcedureActiveStopped = 0;
        getprop("fdm/jsbsim/systems/starter/gui/autostart-activate-stop",0);
        timerEngine_starterTimer.stop();
        msgOutput = "procedure terminate";
        messageOutputStatus();
    };

}, 0, 1);


setlistener("fdm/jsbsim/systems/starter/gui/autostart-stop", func {

    isStopProcedureActive = getprop("fdm/jsbsim/systems/starter/gui/autostart-stop");
    if (isStopProcedureActive > 0 and timerEngine_starterTimer == nil) {
        setprop("fdm/jsbsim/systems/starter/gui/autostart-activate-stop",0);
        setprop("fdm/jsbsim/systems/starter/gui/autostart-activate",0);
        timerEngine_starterTimer = maketimer(0.1, timerEngine_starter);
        timerEngine_starterTimer.singleShot = 0;
        #//timerEngine_starterTimer.simulatedTime = 1;
        timerEngine_starterTimer.start();
    } else if (isStopProcedureActive > 0) {
        setprop("fdm/jsbsim/systems/starter/gui/autostart-activate-stop",0);
        setprop("fdm/jsbsim/systems/starter/gui/autostart-activate",0);
        timerEngine_starterTimer.restart(0.1);
    };

}, 0, 1);

