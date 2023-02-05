import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class TimeInZoneView extends WatchUi.DataField {
    hidden var settings as Array<ZoneSettings>;

    var current = 0;
    var time;
    var isBelowTarget = [ true, true, true ];
    var zoneMs = [ 0, 0, 0 ];

    function initialize(settings as Array<ZoneSettings>) {
        DataField.initialize();
        self.settings = settings;
    }

    function onTimerReset() as Void {
        time = null;
        zoneMs = [ 0, 0, 0 ];
    }

    function setSettings(settings as Array<ZoneSettings>) as Void {
        self.settings = settings;
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Void {
        current = 0;
        isBelowTarget = [ true, true, true ];

        if (info has :currentPower && info.currentPower != null) {
            current = info.currentPower as Number;

            if (info has :timerTime && info.timerTime != null) {
                var previousTime = time;
                time = info.timerTime;

                if (previousTime != null && time > previousTime) {
                    var incrementMs = time - previousTime;

                    if (current >= settings[0].power) {
                        isBelowTarget[0] = false;
                        zoneMs[0] += incrementMs;
                    }
                    if (current >= settings[1].power) {
                        isBelowTarget[1] = false;
                        zoneMs[1] += incrementMs;
                    }
                    if (current >= settings[2].power) {
                        isBelowTarget[2] = false;
                        zoneMs[2] += incrementMs;
                    }
                }
            }
        }
    }

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        var zoneColor = [ Graphics.COLOR_GREEN, Graphics.COLOR_GREEN, Graphics.COLOR_GREEN ];
        var foregroundColor = [ Graphics.COLOR_BLACK, Graphics.COLOR_BLACK, Graphics.COLOR_BLACK ];

        if (isBelowTarget[0]) {
            zoneColor[0] = Graphics.COLOR_RED;
            foregroundColor[0] = Graphics.COLOR_WHITE;
        }

        if (isBelowTarget[1]) {
            zoneColor[1] = Graphics.COLOR_RED;
            foregroundColor[1] = Graphics.COLOR_WHITE;
        }

        if (isBelowTarget[2]) {
            zoneColor[2] = Graphics.COLOR_RED;
            foregroundColor[2] = Graphics.COLOR_WHITE;
        }

        var labelA = View.findDrawableById("labelA") as Text;
        var labelB = View.findDrawableById("labelB") as Text;
        var labelC = View.findDrawableById("labelC") as Text;

        dc.setColor(zoneColor[0], zoneColor[0]);
        dc.fillRectangle(0, 0, width, height / 3);
        dc.setColor(zoneColor[1], zoneColor[1]);
        dc.fillRectangle(0, height / 3, width, height / 3);
        dc.setColor(zoneColor[2], zoneColor[2]);
        dc.fillRectangle(0, height * 2 / 3, width, height / 3);

        var zoneAPercentage = zoneMs[0] * 100.0 / settings[0].duration / 60.0 / 1000.0;
        var zoneBPercentage = zoneMs[1] * 100.0 / settings[1].duration / 60.0 / 1000.0;
        var zoneCPercentage = zoneMs[2] * 100.0 / settings[2].duration / 60.0 / 1000.0;

        dc.setColor(foregroundColor[0], Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, 0, Graphics.FONT_SMALL,
            settings[0].duration + "m > " + settings[0].power + "W: " + zoneAPercentage.format("%.1f") + "%",
            Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(foregroundColor[1], Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, height / 3, Graphics.FONT_SMALL,
            settings[1].duration + "m > " + settings[1].power + "W: " + zoneBPercentage.format("%.1f") + "%",
            Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(foregroundColor[2], Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2, height * 2 / 3, Graphics.FONT_SMALL,
            settings[2].duration + "m > " + settings[2].power + "W: " + zoneCPercentage.format("%.1f") + "%",
            Graphics.TEXT_JUSTIFY_CENTER);
    }

}
