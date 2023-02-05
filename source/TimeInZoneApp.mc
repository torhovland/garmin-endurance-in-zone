import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class TimeInZoneApp extends Application.AppBase {
    var view as TimeInZoneView;

    function initialize() {
        AppBase.initialize();
        view = new TimeInZoneView(readSettings());
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    function onSettingsChanged() as Void {
        view.setSettings(readSettings());
    }

    function readZoneSettings(zone as String) as ZoneSettings {
        var settings = new ZoneSettings();
        
        settings.type = AppBase.getProperty("type");
        settings.duration = AppBase.getProperty("duration" + zone);
        settings.power = AppBase.getProperty("power" + zone);
        settings.heartRate = AppBase.getProperty("heartRate" + zone);
        
        return settings;
    }

    function readSettings() as Array<ZoneSettings> {
        return [ readZoneSettings("A"), readZoneSettings("B"), readZoneSettings("C") ];
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ view ] as Array<Views or InputDelegates>;
    }

}

function getApp() as TimeInZoneApp {
    return Application.getApp() as TimeInZoneApp;
}