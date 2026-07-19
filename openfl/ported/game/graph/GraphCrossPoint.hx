package game.graph;


class GraphCrossPoint
{
    public var index : Int;
    public var x : Float;
    public var y : Float;
    public var timing : Float;
    public var color : Int;
    public var score : Int;
    public var column : String;
    
    public function new(index : Int, pos_x : Float, pos_y : Float, timing : Float, color : Int, score : Int, column : String)
    {
        this.index = index;
        this.x = pos_x;
        this.y = pos_y;
        this.timing = timing;
        this.color = color;
        this.score = score;
        this.column = column;
    }
}

