package classes.chart;


class Note
{
    public var direction : String;
    public var time : Float;
    public var color : String;
    public var frame : Float;
    
    /**
     * Defines a new Note object.
     * @param	direction
     * @param	time
     * @param	color
     * @param	frame
     */
    public function new(direction : String, time : Float, color : String, frame : Float = -1)
    {
        this.direction = direction;
        this.time = time;
        this.color = color;
        this.frame = frame;
    }
}

