import Toybox.Lang;

class ZoneSettings {
    public var include as Boolean;
    public var type as Number;
    public var duration as Number;
    public var power as Number;
    public var heartRate as Number;

    public function initialize() {
        include = false;
        type = 0;
        duration = 0;
        power = 0;
        heartRate = 0;        
    }
}
