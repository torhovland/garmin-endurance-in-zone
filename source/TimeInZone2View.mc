import Toybox.Activity;
import Toybox.Lang;
import Toybox.Time;
import Toybox.WatchUi;

class TimeInZoneView extends WatchUi.SimpleDataField {
    var foo;

    // Set the label of the data field here.
    function initialize(foo) {
        SimpleDataField.initialize();
        label = "My Label";
        self.foo = foo;
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        // See Activity.Info in the documentation for available information.
        return foo;
    }

}