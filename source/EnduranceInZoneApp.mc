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
    settings.type = AppBase.getProperty("type") as Number;
    settings.duration = AppBase.getProperty("duration" + zone) as Number;
    settings.power = AppBase.getProperty("power" + zone) as Number;
    settings.heartRate = AppBase.getProperty("heartRate" + zone) as Number;
    
    if (!zone.equals("A")) {
        settings.include = AppBase.getProperty("include" + zone) as Boolean;
    }

    return settings;
}

function loadState() as Array<Number> {
    var state = AppBase.getProperty(StateKey) as Array<Number>;
    return state;
}

function saveState(state as Array<Number>) as Void {
    AppBase.setProperty(StateKey, state);
}
