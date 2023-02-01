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
        var obscurityFlags = DataField.getObscurityFlags();

        // Top left quadrant so we'll use the top left layout
        if (obscurityFlags == (OBSCURE_TOP | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.TopLeftLayout(dc));

        // Top right quadrant so we'll use the top right layout
        } else if (obscurityFlags == (OBSCURE_TOP | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.TopRightLayout(dc));

        // Bottom left quadrant so we'll use the bottom left layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.BottomLeftLayout(dc));

        // Bottom right quadrant so we'll use the bottom right layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.BottomRightLayout(dc));

        // Use the generic, centered layout
        } else {
            View.setLayout(Rez.Layouts.MainLayout(dc));
            var labelView = View.findDrawableById("label");
            labelView.locY = labelView.locY - 16;
            var valueView = View.findDrawableById("value");
            valueView.locY = valueView.locY + 7;
        }
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Void {
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

        (View.findDrawableById("Background") as Text).setColor(backgroundColor);

        var label = View.findDrawableById("label") as Text;
        var value = View.findDrawableById("value") as Text;

        label.setColor(foregroundColor);
        value.setColor(foregroundColor);

        label.setText(settings.duration + "m @ " + settings.power + "W");
        value.setText(current.format("%.2f"));

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}
