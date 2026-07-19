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
    private static var e_changeHandler                    : Dynamic;
    public var type(never, set)                       : Dynamic;
    public var show_labels(never, set)                       : Dynamic;

    public var scores                       : Dynamic;
    private var labels                       : Dynamic;
    
    private var options                       : Dynamic;
    
    public function new(options                       : Dynamic, parent                       : Dynamic)
    {
        super();
        if (as3hx.Compat.truthy(parent != null))
        {
            parent.addChild(this);
        }
        
        this.options = options;
        
        labels = new Array<Dynamic>();
        scores = new Array<Dynamic>();
        
        var scoreSize                       : Dynamic= 36;
        
        var labelDesc                       : Dynamic= [{
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
        
        if (as3hx.Compat.truthy(!options.displayAmazing))
        {
            labelDesc.splice(0, 1);
        }
        
        for (label in as3hx.Compat.iter(labelDesc))
        {
            var field                       : Dynamic= new TextField();
            field.defaultTextFormat = new TextFormat(_lang.font(), 13, label.color, true);
            field.antiAliasType = AntiAliasType.ADVANCED;
            field.embedFonts = true;
            field.selectable = false;
            field.autoSize = TextFieldAutoSize.LEFT;
            field.text = label.title;
            addChild(field);
            labels.push(field);
            
            field = new TextField();
            field.defaultTextFormat = new TextFormat(_lang.font(), as3hx.Compat.parseInt(scoreSize--), label.color, true);
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
    
    public function update(amazing                       : Dynamic, perfect                       : Dynamic, good                       : Dynamic, average                       : Dynamic, miss                       : Dynamic, boo                       : Dynamic) : Void
    {
        var offset                       : Dynamic= 0;
        if (as3hx.Compat.truthy(options.displayAmazing))
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
    
    public function updateScore(field                       : Dynamic, score                       : Dynamic) : Void
    {
        scores[field].text = Std.string(score);
    }
    
    private function set_type(val                       : Dynamic) : Float
    {
        var xpos                       : Dynamic= 50;
        var ypos                       : Dynamic= 0;
        var scoreSize                       : Dynamic= 36;
        
        var label                       : Dynamic= null;
        var score                       : Dynamic= null;
        
        // --- / ---
        if (as3hx.Compat.truthy(val == 1))
        {
            scoreSize = 0;
        }
        // - / - / - / - / - / -
        else
        {
            
            {
                if (as3hx.Compat.truthy(!options.displayAmazing))
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
            if (as3hx.Compat.truthy(val == 1))
            {
                label.x = xpos - label.textWidth;
                label.y = ypos;
                
                score.x = xpos + 5;
                score.y = ypos - 22 + scoreSize++;
                
                xpos += 166;
                
                if (as3hx.Compat.truthy(((i + 1) % 3) == 0))
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
    
    private function set_show_labels(val                       : Dynamic) : Bool
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
        var self                       : Dynamic= this;
        
        var out                       : Dynamic= super.getEditorInterface();
        
        new Text(out, 10, out.cy, _lang.string("editor_component_show_labels"));
        var checkLabels                       : Dynamic= new BoxCheck(out, 10 + 3, out.cy + 22, e_changeHandler);
        checkLabels.checked = editorLayout.show_labels == null || as3hx.Compat.truthy(editorLayout.show_labels);
        
        out.cy += 42;
        
        new Text(out, 10, out.cy, _lang.string("editor_component_alt_layout"));
        var checkLayout                       : Dynamic= new BoxCheck(out, 10 + 3, out.cy + 22, e_changeHandler);
        checkLayout.checked = (editorLayout.type == 1);
        
        out.cy += 42;
        
        e_changeHandler = function(e                       : Dynamic) : Void
        {
            if (as3hx.Compat.truthy(e.target == checkLabels))
            {
                checkLabels.checked = !checkLabels.checked;
                Reflect.setField(editorLayout, "show_labels", checkLabels.checked);
                self.show_labels = Reflect.field(editorLayout, "show_labels");
            }
            else if (as3hx.Compat.truthy(e.target == checkLayout))
            {
                checkLayout.checked = !checkLayout.checked;
                Reflect.setField(editorLayout, "type", (checkLayout.checked) ? 1 : 0);
                self.type = Reflect.field(editorLayout, "type");
            }
        }
        
        return out;
    }
}
