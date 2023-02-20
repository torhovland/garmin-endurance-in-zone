import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

const StateKeyPrefix = "AppState_";

class EnduranceInZoneApp extends Application.AppBase {
    private var view as EnduranceInZoneView;

    public function initialize() {
        AppBase.initialize();
        view = new EnduranceInZoneView(readSettings());
    }

    public function onStart(state) {
        if (state != null && state.get(:resume) != null) {
            view.setState(loadState());
        } else {
            var info = Activity.getActivityInfo();

            if (info != null) {
                var time = info.timerTime;

                if (time != null && time > 0) {
                    // We've been restarted during an activity. Reload saved state.
                    view.setState(loadState());
                }
            }            
        }
    }

    public function onStop(state) {
        // Save state in case we're being restarted during an activity.
        saveState(view.getState());
    }

    public function getInitialView() as Array<Views or InputDelegates>? {
        return [ view ] as Array<Views or InputDelegates>;
    }

    public function onSettingsChanged() as Void {
        view.setSettings(readSettings());
    }
}

function readSettings() as Array<ZoneSettings> {
    return [ readZoneSettings("A"), readZoneSettings("B"), readZoneSettings("C") ] as Array<ZoneSettings>;
}

function readZoneSettings(zone as String) as ZoneSettings {
    var settings = new ZoneSettings();
    
    settings.include = true;
    settings.type = getPropertyCompat("type") as Number;
    settings.duration = getPropertyCompat("duration" + zone) as Number;
    settings.power = getPropertyCompat("power" + zone) as Number;
    settings.heartRate = getPropertyCompat("heartRate" + zone) as Number;
    
    if (!zone.equals("A")) {
        settings.include = getPropertyCompat("include" + zone) as Boolean;
    }

    return settings;
}

function loadState() as Array<Number> {
    var state = new Array<Number>[MaxNumberOfZones];

    for (var zone=0; zone<MaxNumberOfZones; zone++) {   
        var key = StateKeyPrefix + "zone_" + zone;
        var value = getPropertyCompat(key) as Number?;

        if (value) {
            state[zone] = value;
        } else {
            state[zone] = 0;
        }
    }

    return state;
}

function saveState(state as Array<Number>) as Void {
    for (var zone=0; zone<MaxNumberOfZones; zone++) {   
        var key = StateKeyPrefix + "zone_" + zone;
        var value = state[zone];
        setPropertyCompat(key, value);
    }
}

function getPropertyCompat(key as String) as PropertyValueType {
    if (Application has :Properties) {
        return Properties.getValue(key);
    } else {
        return AppBase.getProperty(key);
    }
}

function setPropertyCompat(key as String, state as PropertyValueType) as Void {
    if (Application has :Properties) {
        Properties.setValue(key, state);
    } else {
        AppBase.setProperty(key, state);
    }
}

// function log(s as String) as Void {
//     var now = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
//     var logString = Lang.format(
//         "$1$:$2$:$3$: $4$",
//         [
//             now.hour,
//             now.min,
//             now.sec,
//             s
//         ]
//     );
//     System.println(logString);
// }
