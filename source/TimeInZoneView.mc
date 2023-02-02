import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class TimeInZoneView extends WatchUi.DataField {

    hidden var settingsA as Settings;
    hidden var settingsB as Settings;
    hidden var settingsC as Settings;

    var current = 0;
    var isBelowTargetA = true;
    var isBelowTargetB = true;
    var isBelowTargetC = true;

    function initialize(settingsA, settingsB, settingsC) {
        DataField.initialize();
        self.settingsA = settingsA;
        self.settingsB = settingsB;
        self.settingsC = settingsC;
    }

    function setSettingsA(settings) {
        self.settingsA = settings;
    }

    function setSettingsB(settings) {
        self.settingsB = settings;
    }

    function setSettingsC(settings) {
        self.settingsC = settings;
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
        isBelowTargetA = true;
        isBelowTargetB = true;
        isBelowTargetC = true;

        if (info has :currentPower && info.currentPower != null) {
            current = info.currentPower as Number;

            if (current >= settingsA.power) {
                isBelowTargetA = false;
            }
            if (current >= settingsB.power) {
                isBelowTargetB = false;
            }
            if (current >= settingsC.power) {
                isBelowTargetC = false;
            }
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        var backgroundColorA = Graphics.COLOR_GREEN;
        var backgroundColorB = Graphics.COLOR_GREEN;
        var backgroundColorC = Graphics.COLOR_GREEN;

        var foregroundColorA = Graphics.COLOR_BLACK;
        var foregroundColorB = Graphics.COLOR_BLACK;
        var foregroundColorC = Graphics.COLOR_BLACK;

        if (isBelowTargetA) {
            backgroundColorA = Graphics.COLOR_RED;
            foregroundColorA = Graphics.COLOR_WHITE;
        }

        if (isBelowTargetB) {
            backgroundColorB = Graphics.COLOR_RED;
            foregroundColorB = Graphics.COLOR_WHITE;
        }

        if (isBelowTargetC) {
            backgroundColorC = Graphics.COLOR_RED;
            foregroundColorC = Graphics.COLOR_WHITE;
        }

        var background = View.findDrawableById("Background") as Text;
        background.setColor(Graphics.COLOR_WHITE);

        var zoneA = View.findDrawableById("zoneA") as Drawable;
        var zoneB = View.findDrawableById("zoneB") as Drawable;
        var zoneC = View.findDrawableById("zoneC") as Drawable;
        
        var labelA = View.findDrawableById("labelA") as Text;
        var labelB = View.findDrawableById("labelB") as Text;
        var labelC = View.findDrawableById("labelC") as Text;

        labelA.setColor(foregroundColorA);
        labelB.setColor(foregroundColorB);
        labelC.setColor(foregroundColorC);

        labelA.setText(settingsA.duration + "m @ " + settingsA.power + "W:" + current + ":" + current);
        labelB.setText(settingsB.duration + "m @ " + settingsB.power + "W:" + current + ":" + current);
        labelC.setText(settingsC.duration + "m @ " + settingsC.power + "W:" + current + ":" + current);

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}
