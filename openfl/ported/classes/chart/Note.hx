package classes.chart;


class Note
{
    public var direction                             : Dynamic;
    public var time                             : Dynamic;
    public var color                             : Dynamic;
    public var frame                             : Dynamic;
    
    /**
     * Defines a new Note object.
     * @param	direction
     * @param	time
     * @param	color
     * @param	frame
     */
    public function new(direction                             : Dynamic, time                             : Dynamic, color                             : Dynamic, frame                             : Dynamic= -1)
    {
        this.direction = direction;
        this.time = time;
        this.color = color;
        this.frame = frame;
    }
}

