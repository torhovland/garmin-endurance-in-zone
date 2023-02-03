import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

var ZoneAColor = Graphics.COLOR_GREEN;
var ZoneBColor = Graphics.COLOR_GREEN;
var ZoneCColor = Graphics.COLOR_GREEN;

class TimeInZoneView extends WatchUi.DataField {

    hidden var settingsA as Settings;
    hidden var settingsB as Settings;
    hidden var settingsC as Settings;

    var current = 0;
    var time;
    var incrementMs;
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

            if (info has :timerTime && info.timerTime != null) {
                var previousTime = time;
                time = info.timerTime;

                if (previousTime > 0) {
                    incrementMs = time - previousTime;
                }
            }
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        var zoneAColor = Graphics.COLOR_GREEN;
        var zoneBColor = Graphics.COLOR_GREEN;
        var zoneCColor = Graphics.COLOR_GREEN;

        var foregroundColorA = Graphics.COLOR_BLACK;
        var foregroundColorB = Graphics.COLOR_BLACK;
        var foregroundColorC = Graphics.COLOR_BLACK;

        if (isBelowTargetA) {
            zoneAColor = Graphics.COLOR_RED;
            foregroundColorA = Graphics.COLOR_WHITE;
        }

        if (isBelowTargetB) {
            zoneBColor = Graphics.COLOR_RED;
            foregroundColorB = Graphics.COLOR_WHITE;
        }

        if (isBelowTargetC) {
            zoneCColor = Graphics.COLOR_RED;
            foregroundColorC = Graphics.COLOR_WHITE;
        }

        var labelA = View.findDrawableById("labelA") as Text;
        var labelB = View.findDrawableById("labelB") as Text;
        var labelC = View.findDrawableById("labelC") as Text;

        dc.setColor(zoneAColor, zoneAColor);
        dc.fillRectangle(0, 0, width, height / 3);
        dc.setColor(zoneBColor, zoneBColor);
        dc.fillRectangle(0, height / 3, width, height / 3);
        dc.setColor(zoneCColor, zoneCColor);
        dc.fillRectangle(0, height * 2 / 3, width, height / 3);

        dc.setColor(foregroundColorA, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, -3, Graphics.FONT_SMALL,
            settingsA.duration + "m @ " + settingsA.power + "W:" + current + ":" + incrementMs,
            Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(foregroundColorB, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, height / 3 - 3, Graphics.FONT_SMALL,
            settingsB.duration + "m @ " + settingsB.power + "W:" + current + ":" + incrementMs,
            Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(foregroundColorC, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, height * 2 / 3 - 3, Graphics.FONT_SMALL,
            settingsC.duration + "m @ " + settingsC.power + "W:" + current + ":" + incrementMs,
            Graphics.TEXT_JUSTIFY_CENTER);
    }

}
