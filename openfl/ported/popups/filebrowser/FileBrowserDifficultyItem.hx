package popups.filebrowser;

import assets.menu.ChartDifficultyLargeItem;
import classes.ui.Text;

class FileBrowserDifficultyItem extends DifficultyItem
{
    public var cache_info                       : Dynamic;
    
    public function new(index                       : Dynamic, cache_info                       : Dynamic)
    {
        super(index, Reflect.field(Reflect.field(cache_info, "info"), "chart")[as3hx.Compat.parseInt(index)]);
        this.cache_info = cache_info;
    }
    
    override public function drawUI() : Void
    {
        addChild(new ChartDifficultyLargeItem());
        
        var diff                       : Dynamic= new Text(this, -1, 0, Reflect.field(chart, "difficulty"));
        diff.setAreaParams(24, 25, "center");
        
        var name                       : Dynamic= new Text(this, 27, 0, Reflect.field(chart, "class"));
        name.setAreaParams(169, 25);
        
        var type                       : Dynamic= new Text(this, 184, 0, getChartType(Reflect.field(chart, "type")));
        type.setAreaParams(30, 25, "right");
        
        this.graphics.lineStyle(0, 0, 0);
        this.graphics.beginFill(DIFFICULTY_COLORS[getChartColorIndex(Reflect.field(chart, "class_color"))], 1);
        this.graphics.drawRect(1, 1, 24, 22);
        this.graphics.endFill();
    }
}

