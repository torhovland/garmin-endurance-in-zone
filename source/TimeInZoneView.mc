import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class TimeInZoneView extends WatchUi.DataField {

    hidden var settings as Settings;
    var current = 0;
    var isBelowTarget = true;

    function initialize(settings) {
        DataField.initialize();
        self.settings = settings;
    }

    function setSettings(settings) {
        self.settings = settings;
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc as Dc) as Void {
        View.setLayout(Rez.Layouts.MainLayout(dc));

        var labelAView = View.findDrawableById("labelA");
        labelAView.locY = labelAView.locY - 19;
        var labelBView = View.findDrawableById("labelB");
        labelBView.locY = labelBView.locY - 2;
        var labelCView = View.findDrawableById("labelC");
        labelCView.locY = labelCView.locY + 15;
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Void {
        current = 0;
        isBelowTarget = true;

        if (info has :currentPower && info.currentPower != null) {
            current = info.currentPower as Number;

            if (current >= settings.power) {
                isBelowTarget = false;
            }
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        var backgroundColor = Graphics.COLOR_GREEN;
        var foregroundColor = Graphics.COLOR_BLACK;

        if (isBelowTarget) {
            backgroundColor = Graphics.COLOR_RED;
            foregroundColor = Graphics.COLOR_WHITE;
        }

        var background = View.findDrawableById("Background") as Text;
        background.setColor(Graphics.COLOR_WHITE);

        var zoneA = View.findDrawableById("zoneA") as Drawable;
        var zoneB = View.findDrawableById("zoneB") as Drawable;
        var zoneC = View.findDrawableById("zoneC") as Drawable;
        
        var labelA = View.findDrawableById("labelA") as Text;
        var labelB = View.findDrawableById("labelB") as Text;
        var labelC = View.findDrawableById("labelC") as Text;

        labelA.setColor(foregroundColor);
        labelB.setColor(foregroundColor);
        labelC.setColor(foregroundColor);

        labelA.setText(settings.duration + "m @ " + settings.power + "W:" + current + ":" + current);
        labelB.setText(settings.duration + "m @ " + settings.power + "W:" + current + ":" + current);
        labelC.setText(settings.duration + "m @ " + settings.power + "W:" + current + ":" + current);

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}
