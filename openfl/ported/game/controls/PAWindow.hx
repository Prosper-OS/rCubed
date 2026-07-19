package game.controls;

import classes.ui.BoxCheck;
import classes.ui.Text;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.text.AntiAliasType;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import game.GameOptions;

class PAWindow extends GameControl
{
    public var type(never, set) : Float;
    public var show_labels(never, set) : Bool;

    public var scores : Array<Dynamic>;
    private var labels : Array<Dynamic>;
    
    private var options : GameOptions;
    
    public function new(options : GameOptions, parent : DisplayObjectContainer)
    {
        super();
        if (parent != null)
        {
            parent.addChild(this);
        }
        
        this.options = options;
        
        labels = new Array<Dynamic>();
        scores = new Array<Dynamic>();
        
        var scoreSize : Int = 36;
        
        var labelDesc : Array<Dynamic> = [{
            color : options.judgeColors[0],
            title : _lang.stringSimple("game_amazing")
        }, 
        {
            color : options.judgeColors[1],
            title : _lang.stringSimple("game_perfect")
        }, 
        {
            color : options.judgeColors[2],
            title : _lang.stringSimple("game_good")
        }, 
        {
            color : options.judgeColors[3],
            title : _lang.stringSimple("game_average")
        }, 
        {
            color : options.judgeColors[4],
            title : _lang.stringSimple("game_miss")
        }, 
        {
            color : options.judgeColors[5],
            title : _lang.stringSimple("game_boo")
        }
    ];
        
        if (!options.displayAmazing)
        {
            labelDesc.splice(0, 1);
        }
        
        for (label in labelDesc)
        {
            var field : TextField = new TextField();
            field.defaultTextFormat = new TextFormat(_lang.font(), 13, label.color, true);
            field.antiAliasType = AntiAliasType.ADVANCED;
            field.embedFonts = true;
            field.selectable = false;
            field.autoSize = TextFieldAutoSize.LEFT;
            field.text = label.title;
            addChild(field);
            labels.push(field);
            
            field = new TextField();
            field.defaultTextFormat = new TextFormat(_lang.font(), scoreSize--, label.color, true);
            field.antiAliasType = AntiAliasType.ADVANCED;
            field.embedFonts = true;
            field.selectable = false;
            field.autoSize = TextFieldAutoSize.LEFT;
            field.text = "0";
            addChild(field);
            scores.push(field);
        }
    }
    
    public function reset() : Void
    {
        update(0, 0, 0, 0, 0, 0);
    }
    
    public function update(amazing : Int, perfect : Int, good : Int, average : Int, miss : Int, boo : Int) : Void
    {
        var offset : Int = 0;
        if (options.displayAmazing)
        {
            updateScore(0, amazing);
            updateScore(1, perfect);
            offset = 1;
        }
        else
        {
            updateScore(0, amazing + perfect);
        }
        
        updateScore(offset + 1, good);
        updateScore(offset + 2, average);
        updateScore(offset + 3, miss);
        updateScore(offset + 4, boo);
    }
    
    public function updateScore(field : Int, score : Int) : Void
    {
        scores[field].text = Std.string(score);
    }
    
    private function set_type(val : Float) : Float
    {
        var xpos : Int = 50;
        var ypos : Int = 0;
        var scoreSize : Int = 36;
        
        var label : TextField;
        var score : TextField;
        
        // --- / ---
        if (val == 1)
        {
            scoreSize = 0;
        }
        // - / - / - / - / - / -
        else
        {
            
            {
                if (!options.displayAmazing)
                {
                    ypos = 49;
                }
            }
        }
        
        for (i in 0...labels.length)
        {
            label = labels[i];
            score = scores[i];
            
            // LEFT/RIGHT - 2 Lines
            if (val == 1)
            {
                label.x = xpos - label.textWidth;
                label.y = ypos;
                
                score.x = xpos + 5;
                score.y = ypos - 22 + scoreSize++;
                
                xpos += 166;
                
                if (!((i + 1) % 3))
                {
                    xpos = 50;
                    ypos += 42;
                }
            }
            // Normal - 6 Lines
            else
            {
                
                {
                    label.x = xpos - label.textWidth;
                    label.y = ypos;
                    
                    score.x = xpos + 5;
                    score.y = ypos - 22 + (36 - scoreSize--);
                    
                    ypos += 49;
                }
            }
        }
        return val;
    }
    
    private function set_show_labels(val : Bool) : Bool
    {
        for (i in 0...labels.length)
        {
            labels[i].visible = val;
        }
        return val;
    }
    
    override private function get_id() : String
    {
        return GameLayoutManager.LAYOUT_PA;
    }
    
    override public function getEditorInterface() : GameControlEditor
    {
        var self : PAWindow = this;
        
        var out : GameControlEditor = super.getEditorInterface();
        
        new Text(out, 10, out.cy, _lang.string("editor_component_show_labels"));
        var checkLabels : BoxCheck = new BoxCheck(out, 10 + 3, out.cy + 22, e_changeHandler);
        checkLabels.checked = (editorLayout.show_labels == null || editorLayout.show_labels);
        
        out.cy += 42;
        
        new Text(out, 10, out.cy, _lang.string("editor_component_alt_layout"));
        var checkLayout : BoxCheck = new BoxCheck(out, 10 + 3, out.cy + 22, e_changeHandler);
        checkLayout.checked = (editorLayout.type == 1);
        
        out.cy += 42;
        
        var e_changeHandler : Event->Void = function(e : Event) : Void
        {
            if (e.target == checkLabels)
            {
                checkLabels.checked = !checkLabels.checked;
                Reflect.setField(editorLayout, "show_labels", checkLabels.checked);
                self.show_labels = Reflect.field(editorLayout, "show_labels");
            }
            else if (e.target == checkLayout)
            {
                checkLayout.checked = !checkLayout.checked;
                Reflect.setField(editorLayout, "type", (checkLayout.checked) ? 1 : 0);
                self.type = Reflect.field(editorLayout, "type");
            }
        }
        
        return out;
    }
}

