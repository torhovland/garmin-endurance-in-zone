import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class TimeInZoneApp extends Application.AppBase {
    var view;
    var settings;

    function initialize() {
        AppBase.initialize();
        settings = readSettings();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    function onSettingsChanged() as Void {
        settings = readSettings();
        view.setSettings(settings);
    }

    function readSettings() as Settings {
        var type = AppBase.getProperty("type");
        var duration = AppBase.getProperty("duration");
        var power = AppBase.getProperty("power");
        var heartRate = AppBase.getProperty("heartRate");
        return new Settings(type, duration, power, heartRate);
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        view = new TimeInZoneView(settings);
        return [ view ] as Array<Views or InputDelegates>;
    }

}

function getApp() as TimeInZoneApp {
    return Application.getApp() as TimeInZoneApp;
}