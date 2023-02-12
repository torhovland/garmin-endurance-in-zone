import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

const StateKey = "AppState";

class EnduranceInZoneApp extends Application.AppBase {
    private var view as EnduranceInZoneView;

    public function initialize() {
        AppBase.initialize();
        view = new EnduranceInZoneView(readSettings());
    }

    public function onStart(state) {
        if (state != null && state.get(:resume) != null) {
            view.setState(loadState());
        }
    }

    public function onStop(state) {
        if (state != null && state.get(:suspend) != null) {
            saveState(view.getState());
        }
    }

    public function getInitialView() as Array<Views or InputDelegates>? {
        return [ view ] as Array<Views or InputDelegates>;
    }

    public function onSettingsChanged() as Void {
        view.setSettings(readSettings());
    }
}

function getApp() as EnduranceInZoneApp {
    return Application.getApp() as EnduranceInZoneApp;
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
    var state = getPropertyCompat(StateKey) as Array<Number>;
    return state;
}

function saveState(state as Array<Number>) as Void {
    setPropertyCompat(StateKey, state);
}

function getPropertyCompat(key as String) as PropertyValueType {
    if (Application has :Properties) {
        return Properties.getValue(key);
    } else {
        return AppBase.getProperty(key);
    }
}

function setPropertyCompat(key as String, state as Array<Number>) as Void {
    if (Application has :Properties) {
        Properties.setValue(key, state);
    } else {
        AppBase.setProperty(key, state);
    }
}