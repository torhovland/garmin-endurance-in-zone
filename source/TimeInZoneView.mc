import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class TimeInZoneView extends WatchUi.DataField {
    private const MaxNumberOfZones = 3;
    private const NumberOfReadings = 30;

    private var settings as Array<ZoneSettings>;
    private var readings = new Array<Number>[NumberOfReadings];
    private var isBelowTarget = new Array<Boolean>[MaxNumberOfZones];
    private var zoneMs = new Array<Number>[MaxNumberOfZones];
    private var readingIndex = 0;
    private var time;

    public function initialize(settings as Array<ZoneSettings>) {
        DataField.initialize();
        self.settings = settings;
    }

    public function setSettings(settings as Array<ZoneSettings>) as Void {
        self.settings = settings;
    }

    public function onTimerReset() as Void {
        readings = new Array<Number>[NumberOfReadings];
        zoneMs = new Array<Number>[MaxNumberOfZones];
        time = null;
    }

    public function compute(info as Activity.Info) as Void {
        readingIndex++;
        
        if (readingIndex >= NumberOfReadings) {
            readingIndex = 0;
        }

        readings[readingIndex] = 0;
        isBelowTarget = [ true, true, true ];

        if (info has :currentPower && info.currentPower != null) {
            readings[readingIndex] = info.currentPower as Number;

            if (info has :timerTime && info.timerTime != null) {
                var previousTime = time;
                time = info.timerTime;

                if (previousTime == null || time <= previousTime) {
                    return;
                }

                var incrementMs = time - previousTime;
                var average = calculateAverage();

                for (var zone=0; zone<MaxNumberOfZones; zone++) {                    
                    if (average < settings[zone].power) {
                        continue;
                    }

                    isBelowTarget[zone] = false;

                    if (zoneMs[zone] == null) {
                        zoneMs[zone] = incrementMs;
                    } else {
                        zoneMs[zone] += incrementMs;
                    }
                }
            }
        }
    }

    public function onUpdate(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        var zoneColor = [ Graphics.COLOR_GREEN, Graphics.COLOR_GREEN, Graphics.COLOR_GREEN ];
        var foregroundColor = [ Graphics.COLOR_BLACK, Graphics.COLOR_BLACK, Graphics.COLOR_BLACK ];
        var zonePercentage = new Array<Float>[MaxNumberOfZones];
        var average = calculateAverage();

        for (var zone=0; zone<MaxNumberOfZones; zone++) {
            if (isBelowTarget[zone]) {
                zoneColor[zone] = Graphics.COLOR_RED;
                foregroundColor[zone] = Graphics.COLOR_WHITE;
            }

            var ms = zoneMs[zone];

            if (ms == null) {
                zonePercentage[zone] = .0;
            } else {
                zonePercentage[zone] = ms * 100.0 / settings[zone].duration / 60.0 / 1000.0;
            }

            dc.setColor(zoneColor[zone], zoneColor[zone]);
            dc.fillRectangle(0, height * zone / MaxNumberOfZones, width, height / MaxNumberOfZones);

            dc.setColor(foregroundColor[zone], Graphics.COLOR_TRANSPARENT);
            dc.drawText(width / 2, height * zone / MaxNumberOfZones, Graphics.FONT_SMALL,
                settings[zone].duration + "m > " + settings[zone].power + "W: " + zonePercentage[zone].format("%.1f") + "% (" + readings[readingIndex] + ":" + average.format("%.1f") ,
                Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    private function calculateAverage() as Float {
        var sum = 0;

        for (var i=0; i<NumberOfReadings; i++) {
            var reading = readings[i];

            if (reading != null) {
                sum += reading;
            }
        }

        return sum / NumberOfReadings.toFloat();
    }
}
