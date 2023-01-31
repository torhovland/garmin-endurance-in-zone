import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class TimeInZoneApp extends Application.AppBase {
    var foo;

    function initialize() {
        AppBase.initialize();
        foo = AppBase.getProperty("myNumber");
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    function onSettingsChanged() as Void {
        foo = AppBase.getProperty("myNumber");
        WatchUi.requestUpdate();
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new TimeInZoneView() ] as Array<Views or InputDelegates>;
    }

}

function getApp() as TimeInZoneApp {
    return Application.getApp() as TimeInZoneApp;
}