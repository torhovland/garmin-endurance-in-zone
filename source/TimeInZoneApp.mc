import Toybox.Application;
import Toybox.Lang;
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
        return [ readZoneSettings("A"), readZoneSettings("B"), readZoneSettings("C") ];
    }

    private function readZoneSettings(zone as String) as ZoneSettings {
        var settings = new ZoneSettings();
        
        settings.type = AppBase.getProperty("type");
        settings.duration = AppBase.getProperty("duration" + zone);
        settings.power = AppBase.getProperty("power" + zone);
        settings.heartRate = AppBase.getProperty("heartRate" + zone);
        
        return settings;
    }
}

function getApp() as TimeInZoneApp {
    return Application.getApp() as TimeInZoneApp;
}