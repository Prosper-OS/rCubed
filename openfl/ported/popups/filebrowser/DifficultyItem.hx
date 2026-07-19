package popups.filebrowser;

import assets.menu.ChartDifficultyItem;
import classes.ui.Text;
import openfl.display.Sprite;

class DifficultyItem extends Sprite
{
    public var DIFFICULTY_COLORS(default, never)                       : Dynamic= [0x349a2b, 0xecd433, 0xd58d10, 0xba3b22, 0x8d0e0e, 0x444444];
    public var CHART_TYPE_COLORS(default, never)                       : Dynamic= [null, null, null, null, "ffffff", "00c7ff", "a0ffb9", "ffb600", "ffaaaa", "ac00e5", "000000"];
    
    public var chart                       : Dynamic;
    public var chart_id                       : Dynamic;
    public var chart_type                       : Dynamic;
    public var chart_difficulty                       : Dynamic;
    public var chart_difficulty_value                       : Dynamic;
    
    public var index                       : Dynamic;
    public var sorting_key                       : Dynamic= 0;
    
    public function new(index                       : Dynamic, chart                       : Dynamic)
    {
        super();
        this.buttonMode = true;
        this.useHandCursor = true;
        this.mouseChildren = false;
        
        this.chart = chart;
        this.chart_id = index;
        this.chart_type = Reflect.field(chart, "type");
        this.chart_difficulty = Reflect.field(chart, "class_color");
        this.chart_difficulty_value = as3hx.Compat.parseFloat(Reflect.field(chart, "difficulty"));
        
        updateSortingValue();
        
        drawUI();
    }
    
    public function drawUI() : Void
    {
        addChild(new ChartDifficultyItem());
        
        var diff                       : Dynamic= new Text(this, -1, 0, Reflect.field(chart, "difficulty"));
        diff.setAreaParams(24, 25, "center");
        
        var name                       : Dynamic= new Text(this, 27, 0, Reflect.field(chart, "class"));
        name.setAreaParams(89, 25);
        
        var type                       : Dynamic= new Text(this, 105, 0, getChartType(Reflect.field(chart, "type")));
        type.setAreaParams(30, 25, "right");
        
        this.graphics.lineStyle(0, 0, 0);
        this.graphics.beginFill(DIFFICULTY_COLORS[getChartColorIndex(Reflect.field(chart, "class_color"))], 1);
        this.graphics.drawRect(1, 1, 24, 22);
        this.graphics.endFill();
    }
    
    public function getChartType(type                       : Dynamic) : String
    {
        if (as3hx.Compat.truthy(CHART_TYPE_COLORS[type] != null))
        {
            return "<font color=\"#" + CHART_TYPE_COLORS[type] + "\">" + type + "K</font>";
        }
        
        return "??";
    }
    
    public function getChartColorIndex(type                       : Dynamic) : Int
    {
        switch (type)
        {
            case "Beginner":
                return 0;
            case "Easy":
                return 1;
            case "Medium":
                return 2;
            case "Hard":
                return 3;
            case "Challenge":
                return 4;
            case "Edit":
                return 5;
        }
        return 0;
    }
    
    public function updateSortingValue() : Void
    {
        var val                       : Dynamic= 1;
        
        val += (chart_type - 4) * 10000;
        val += getChartColorIndex(chart_difficulty) * 10;
        val += chart_difficulty_value;
        
        this.sorting_key = val;
    }
}

