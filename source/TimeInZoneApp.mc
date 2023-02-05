import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class TimeInZoneApp extends Application.AppBase {
    var view;
    var settingsA;
    var settingsB;
    var settingsC;

    function initialize() {
        AppBase.initialize();
        readSettings();
        view = new TimeInZoneView(settingsA, settingsB, settingsC);
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    function onSettingsChanged() as Void {
        readSettings();
        view.setSettingsA(settingsA);
        view.setSettingsB(settingsB);
        view.setSettingsC(settingsC);
    }

    function readSettings() as Void {
        var type = AppBase.getProperty("type");
        var durationA = AppBase.getProperty("durationA");
        var powerA = AppBase.getProperty("powerA");
        var heartRateA = AppBase.getProperty("heartRateA");
        var durationB = AppBase.getProperty("durationB");
        var powerB = AppBase.getProperty("powerB");
        var heartRateB = AppBase.getProperty("heartRateB");
        var durationC = AppBase.getProperty("durationC");
        var powerC = AppBase.getProperty("powerC");
        var heartRateC = AppBase.getProperty("heartRateC");

        settingsA = new Settings(type, durationA, powerA, heartRateA);
        settingsB = new Settings(type, durationB, powerB, heartRateB);
        settingsC = new Settings(type, durationC, powerC, heartRateC);
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ view ] as Array<Views or InputDelegates>;
    }

}

function getApp() as TimeInZoneApp {
    return Application.getApp() as TimeInZoneApp;
}