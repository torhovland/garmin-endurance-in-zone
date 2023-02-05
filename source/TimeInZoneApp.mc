import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class TimeInZoneApp extends Application.AppBase {
    private var view as TimeInZoneView;

    public function initialize() {
        AppBase.initialize();
        view = new TimeInZoneView(readSettings());
    }

    public function getInitialView() as Array<Views or InputDelegates>? {
        return [ view ] as Array<Views or InputDelegates>;
    }

    public function onSettingsChanged() as Void {
        view.setSettings(readSettings());
    }

    private function readSettings() as Array<ZoneSettings> {
        return [ readZoneSettings("A"), readZoneSettings("B"), readZoneSettings("C") ] as Array<ZoneSettings>;
    }

    private function readZoneSettings(zone as String) as ZoneSettings {
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
}

function getApp() as TimeInZoneApp {
    return Application.getApp() as TimeInZoneApp;
}