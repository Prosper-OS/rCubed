package game.graph;

import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import game.GameScoreResult;
import game.results.GameResultSingleView;

class GraphBase
{
    private static var JUDGE_WINDOW_COLORS : Dynamic = {
            "100" : 0x97f658,
            "50" : 0x12e006,
            "25" : 0x01aa0f,
            "5" : 0xf99800,
            "0" : 0x000000,
            "-5" : 0xB06100
        };
    
    private static var JUDGE_WINDOW_CROSS_COLORS : Dynamic = {
            "100" : 0xffffff,
            "50" : 0xd0ffd4,
            "25" : 0x76dd7e,
            "5" : 0xf99800,
            "0" : 0xff0000,
            "-5" : 0xB06100
        };
    
    private static var JUDGE_WINDOW_TEXT : Dynamic = {
            "100" : "game_amazing",
            "50" : "game_perfect",
            "25" : "game_good",
            "5" : "game_average",
            "0" : "game_miss",
            "-5" : "game_boo"
        };
    
    private var graphWidth : Float = GameResultSingleView.GRAPH_WIDTH;
    private var graphHeight : Float = GameResultSingleView.GRAPH_HEIGHT;
    
    private var result : GameScoreResult;
    private var graph : Sprite;
    private var overlay : Sprite;
    
    public function new(target : Sprite, overlay : Sprite, result : GameScoreResult)
    {
        this.graph = target;
        this.overlay = overlay;
        this.result = result;
    }
    
    /**
     * Abstract Stage Addition Function
     * @param container
     */
    public function onStage(container : DisplayObjectContainer) : Void
    {
        if (graph != null)
        {
            graph.graphics.clear();
        }
        if (overlay != null)
        {
            overlay.graphics.clear();
        }
    }
    
    /**
     * Abstract Stage Remove Function
     */
    public function onStageRemove() : Void
    {
    }
    
    /**
     * Abstract Init Function
     */
    public function init() : Void
    {
    }
    
    /**
     * Abstract Draw Function
     */
    public function draw() : Void
    {
    }
    
    /**
     * Abstract Draw Ovarlay Function
     */
    public function drawOverlay(mx : Float, my : Float) : Void
    {
    }
    
    /**
     * Check mouse position is within the graph
     * @param mx Mouse X
     * @param my Mouse Y
     * @return
     */
    public function validHover(mx : Float, my : Float, tolerance : Float = 0) : Bool
    {
        return mx >= -tolerance && my >= -tolerance && mx <= graphWidth + tolerance && my <= graphHeight + tolerance;
    }
}

