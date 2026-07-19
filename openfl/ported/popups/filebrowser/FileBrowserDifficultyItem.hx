package popups.filebrowser;

import assets.menu.ChartDifficultyLargeItem;
import classes.ui.Text;

class FileBrowserDifficultyItem extends DifficultyItem
{
    public var cache_info : FileFolderItem;
    
    public function new(index : Int, cache_info : FileFolderItem)
    {
        this.cache_info = cache_info;
        
        super(index, Reflect.field(cache_info, "info")["chart"][index]);
    }
    
    override private function drawUI() : Void
    {
        addChild(new ChartDifficultyLargeItem());
        
        var diff : Text = new Text(this, -1, 0, Reflect.field(chart, "difficulty"));
        diff.setAreaParams(24, 25, "center");
        
        var name : Text = new Text(this, 27, 0, Reflect.field(chart, "class"));
        name.setAreaParams(169, 25);
        
        var type : Text = new Text(this, 184, 0, getChartType(Reflect.field(chart, "type")));
        type.setAreaParams(30, 25, "right");
        
        this.graphics.lineStyle(0, 0, 0);
        this.graphics.beginFill(DIFFICULTY_COLORS[getChartColorIndex(Reflect.field(chart, "class_color"))], 1);
        this.graphics.drawRect(1, 1, 24, 22);
        this.graphics.endFill();
    }
}

