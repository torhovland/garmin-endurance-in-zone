import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class TimeInZoneView extends WatchUi.DataField {
    private const MaxNumberOfZones = 3;
    private const NumberOfReadings = 30;

    private var settings as Array<ZoneSettings>;
    private var numberOfZones as Number = MaxNumberOfZones;
    private var readings as Array<Number> = new Array<Number>[NumberOfReadings];
    private var isBelowTarget as Array<Boolean> = new Array<Boolean>[MaxNumberOfZones];
    private var zoneMs as Array<Number> = new Array<Number>[MaxNumberOfZones];
    private var readingIndex as Number = 0;
    private var time as Number?;
    private var font as FontDefinition = Graphics.FONT_LARGE;
    private var label as String = "";
    private var textDimensions as Array<Number> = new Array<Number>[2];

    public function initialize(settings as Array<ZoneSettings>) {
        DataField.initialize();
        self.settings = settings;
        self.numberOfZones = countNumberOfZones();
    }

    public function setSettings(settings as Array<ZoneSettings>) as Void {
        initialize(settings);
        onTimerReset();
    }

    public function getState() as Array<Number> {
        return zoneMs;
    }

    public function setState(zoneMs as Array<Number>) as Void {
        if (zoneMs == null) {
            self.zoneMs = new Array<Number>[MaxNumberOfZones];
        } else {
            self.zoneMs = zoneMs;
        }
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
        isBelowTarget = [ true, true, true ] as Array<Boolean>;

        if (settings[0].type == 0 && info has :currentPower && info.currentPower != null) {
            readings[readingIndex] = info.currentPower as Number;
        } else if (settings[0].type == 1 && info has :currentHeartRate && info.currentHeartRate != null) {
            readings[readingIndex] = info.currentHeartRate as Number;
        } else {
            return;
        }

        if (info has :timerTime && info.timerTime != null) {
            var previousTime = time;
            time = info.timerTime;

            if (previousTime == null || time == null || time <= previousTime) {
                return;
            }

            var incrementMs = (time as Number) - (previousTime as Number);
            var average = calculateAverage();
            System.println("Reading: " + readings[readingIndex] + ". Average: " + average);

            for (var zone=0; zone<MaxNumberOfZones; zone++) {   
                if (!settings[zone].include) {
                    continue;
                }            

                if (settings[zone].type == 0 && average < settings[zone].power) {
                    continue;
                }

                if (settings[zone].type == 1 && average < settings[zone].heartRate) {
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

    public function onUpdate(dc as Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var zoneProgressColor = [ Graphics.COLOR_GREEN, Graphics.COLOR_GREEN, Graphics.COLOR_GREEN ] as Array<ColorValue>;
        var zoneRemainingColor = [ Graphics.COLOR_DK_GREEN, Graphics.COLOR_DK_GREEN, Graphics.COLOR_DK_GREEN ] as Array<ColorValue>;
        var zonePercentage = new Array<Float>[MaxNumberOfZones];
        var average = calculateAverage();
        var zoneGuiSlot = 0;
        var obscurity = DataField.getObscurityFlags();

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);            
        dc.clear();

        for (var zone=0; zone<MaxNumberOfZones; zone++) {            
            if (!settings[zone].include) {
                continue;
            }            
                    
            if (isBelowTarget[zone]) {
                zoneProgressColor[zone] = Graphics.COLOR_RED;
                zoneRemainingColor[zone] = Graphics.COLOR_DK_RED;
            }

            var ms = zoneMs[zone];

            if (ms == null) {
                zonePercentage[zone] = .0;
            } else {
                zonePercentage[zone] = ms * 100.0 / settings[zone].duration / 60.0 / 1000.0;
            }

            var zoneGuiHeight = Math.round(height / numberOfZones.toFloat()).toNumber();

            var isFirstZone = zone == 0;
            var isLastZone = isLastZone(zone);
            fitText(dc, width, zoneGuiHeight, settings[zone], average, zonePercentage[zone], obscurity, isFirstZone, isLastZone);
            var verticalOffset = (height / numberOfZones - textDimensions[1]) / 2;

            var progressWidth = zonePercentage[zone] / 100 * width;
            
            if (progressWidth > width) {
                progressWidth = width;
            }

            dc.setColor(zoneProgressColor[zone], zoneProgressColor[zone]);
            dc.fillRectangle(0, height * zoneGuiSlot / numberOfZones, progressWidth, height / numberOfZones);

            if (progressWidth < width) {            
                dc.setColor(zoneRemainingColor[zone], zoneRemainingColor[zone]);
                dc.fillRectangle(progressWidth, height * zoneGuiSlot / numberOfZones, width - progressWidth, height / numberOfZones);
            }

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);            
            dc.drawText(width / 2, zoneGuiHeight * zoneGuiSlot + (verticalOffset as Number), font,
                label, Graphics.TEXT_JUSTIFY_CENTER);

            zoneGuiSlot++;
        }
    }

    private function calculateAverage() as Number {
        var sum = 0;

        for (var i=0; i<NumberOfReadings; i++) {
            var reading = readings[i];

            if (reading != null) {
                sum += reading;
            }
        }

        return Math.round(sum / NumberOfReadings.toFloat()).toNumber();
    }

    private function countNumberOfZones() as Number {
        var sum = 0;

        for (var zone=0; zone<MaxNumberOfZones; zone++) {
            if (settings[zone].include) {
                sum++;
            }
        }

        return sum;
    }

    private function isLastZone(i as Number) as Boolean {
        for (var zone=MaxNumberOfZones-1; zone>=0; zone--) {
            if (settings[zone].include) {
                return zone == i;
            }
        }

        return false;
    }

    private function fitText(dc as Dc, width as Number, height as Number, settings as ZoneSettings, average as Number, percentage as Float, obscurity as DataField.Obscurity, isFirstZone as Boolean, isLastZone as Boolean) as Void {
        var durationText = settings.duration + "m >";
        var percentageText = percentage.format("%.1f") + "%";
        var targetText = settings.power + "W (" + average + "):";

        if (settings.type == 1) {
            targetText = settings.heartRate + " bpm (" + average + "):";
        }

        System.println("First zone: " + isFirstZone + ". Last zone: " + isLastZone + ". Obscurity is " + obscurity + ". OBSCURE_TOP is " + OBSCURE_TOP + ". OBSCURE_BOTTOM is " + OBSCURE_BOTTOM + ".");

        if ((obscurity & OBSCURE_TOP) > 0 && (obscurity & OBSCURE_BOTTOM) > 0) {
            // Data field coveraging full height. Don't reduce.
        }
        else if (isFirstZone && (obscurity & OBSCURE_TOP) > 0) {
            System.println("First zone.");
            width = (width / 2.5).toNumber();
        } else if (isLastZone && (obscurity & OBSCURE_BOTTOM) > 0) {
            System.println("Last zone.");
            width = (width / 2.5).toNumber();
        } else if (!isFirstZone && !isLastZone && ((obscurity & OBSCURE_TOP) > 0 || (obscurity & OBSCURE_BOTTOM) > 0)) {
            System.println("Middle zone.");
            width = (width / 1.5).toNumber();
        }

        // Try to fit "999m > 999W (123): 100.0%".
        if (fitDurationTargetPercentageText(dc, width, height, durationText, targetText, percentageText)) {
            return;
        }

        // Try to fit "999m > 999W: 100.0%".
        targetText = settings.power + "W:";

        if (settings.type == 1) {
            targetText = settings.heartRate + " bpm:";
        }

        if (fitDurationTargetPercentageText(dc, width, height, durationText, targetText, percentageText)) {
            return;
        }

        // Try to fit "999W: 100.0%".
        if (fitDurationTargetPercentageText(dc, width, height, null, targetText, percentageText)) {
            return;
        }

        // Try to fit "999: 100.0%".
        targetText = settings.power + ":";

        if (settings.type == 1) {
            targetText = settings.heartRate + ":";
        }

        fitDurationTargetPercentageText(dc, width, height, null, targetText, percentageText);
    }
    
    private function fitDurationTargetPercentageText(dc as Dc, width as Number, height as Number, durationText as String?, targetText as String, percentageText as String) as Boolean {
        var fonts = [ Graphics.FONT_LARGE, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_TINY, Graphics.FONT_XTINY ] as Array<FontDefinition>;

        for (var i=0; i<fonts.size(); i++) {
            font = fonts[i];

            if (durationText != null) {
                label = durationText + " " + targetText + " " + percentageText;
            } else {
                label = targetText + " " + percentageText;
            }

            textDimensions = dc.getTextDimensions(label, font);
            
            if (textDimensions[0] > width) {
                if (durationText != null) {
                    label = durationText + " " + targetText + "\n" + percentageText;
                    textDimensions = dc.getTextDimensions(label, font);

                    if (textDimensions[0] > width) {
                        label = durationText + "\n" + targetText + "\n" + percentageText;
                        textDimensions = dc.getTextDimensions(label, font);
                    }
                } else {
                    label = targetText + "\n" + percentageText;
                    textDimensions = dc.getTextDimensions(label, font);
                }
            }

            if (textDimensions[0] <= width && textDimensions[1] <= height) {
                return true;
            }
        }

        return false;
    }
}
