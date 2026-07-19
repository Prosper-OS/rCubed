package popups;

import arc.ArcGlobals;
import classes.Language;
import classes.filter.EngineLevelFilter;
import classes.ui.Box;
import classes.ui.BoxButton;
import classes.ui.BoxText;
import classes.ui.Text;
import classes.ui.ValidatedText;
import com.bit101.components.ComboBox;
import com.flashfla.utils.ArrayUtil;
import openfl.display.DisplayObjectContainer;
import openfl.events.Event;

class FilterItemButton extends Box
{
    private var _gvars                       : Dynamic= GlobalVariables.instance;
    private var _avars                       : Dynamic= ArcGlobals.instance;
    private var _lang                       : Dynamic= Language.instance;
    
    private var updater                       : Dynamic;
    private var filter                       : Dynamic;
    
    private var combo_stat                       : Dynamic;
    private var input_box                       : Dynamic;
    private var combo_compare                       : Dynamic;
    private var remove_button                       : Dynamic;
    
    public function new(parent                       : Dynamic, xpos                       : Dynamic, ypos                       : Dynamic, filter                       : Dynamic, updater                       : Dynamic)
    {
        this.filter = filter;
        this.updater = updater;
        super(parent, xpos + 23, ypos, false, false);
        super.setSize(parent.parent.width - xpos - 30, 33);
        
        init();
    }
    
    public function init() : Void
    {
        remove_button = new BoxButton(this, -23, 0, 23, height, "?", 10, e_clickRemovefilter);
        remove_button.color = 0xFF0000;
        remove_button.normalAlpha = 0.35;
        remove_button.activeAlpha = 0.45;
        
        var typeText                       : Dynamic= null;
        var xOff                       : Dynamic= 0;
        
        var _sw0_ = (filter.type);        

        switch (_sw0_)
        {
            case EngineLevelFilter.FILTER_STATS:
                combo_stat = new ComboBox(this, 8, 4, "", EngineLevelFilter.createOptions(EngineLevelFilter.FILTERS_STAT, "compare_stat"));
                
                combo_stat.addEventListener(Event.SELECT, e_valueStatChange);
                combo_stat.setSize(130, 26);
                combo_stat.selectedItemByData = filter.input_stat;
                combo_stat.fontSize = 11;
                
                xOff += combo_stat.x + combo_stat.width + 10;
                
                combo_compare = new ComboBox(this, xOff, 4, "", EngineLevelFilter.FILTERS_NUMBER);
                combo_compare.addEventListener(Event.SELECT, e_valueCompareChange);
                combo_compare.setSize(130, 26);
                combo_compare.selectedItemByData = filter.comparison;
                combo_compare.fontSize = 11;
                
                xOff += combo_compare.width + 10;
                
                input_box = new ValidatedText(this, xOff, 4, 107, 24, ValidatedText.R_FLOAT, e_valueNumberChange);
                input_box.text = Std.string(filter.input_number);
            
            case EngineLevelFilter.FILTER_SONG_FLAGS:
                typeText = new Text(this, 8, 8, _lang.string("filter_type_" + filter.type));
                
                xOff += typeText.x + typeText.width + 10;
                
                combo_compare = new ComboBox(this, xOff, 4, "", EngineLevelFilter.createOptions(EngineLevelFilter.FILTERS_FLAGS, "compare_flags"));
                combo_compare.addEventListener(Event.SELECT, e_valueCompareChange);
                combo_compare.setSize(130, 26);
                combo_compare.selectedItemByData = filter.comparison;
                combo_compare.fontSize = 11;
                
                xOff += combo_compare.width + 10;
                
                combo_stat = new ComboBox(this, xOff, 4, "", EngineLevelFilter.createSimpleOptions(GlobalVariables.SONG_ICON_TEXT_FLAG));
                combo_stat.addEventListener(Event.SELECT, e_valueComboNumberChange);
                combo_stat.setSize(130, 26);
                combo_stat.selectedItemByData = filter.input_number;
                combo_stat.fontSize = 11;
            
            case EngineLevelFilter.FILTER_SONG_ACCESS:
                typeText = new Text(this, 8, 8, _lang.string("filter_type_" + filter.type));
                
                xOff += typeText.x + typeText.width + 10;
                
                combo_compare = new ComboBox(this, xOff, 4, "", EngineLevelFilter.createIndexOptions(EngineLevelFilter.FILTERS_BOOLEAN, "compare_boolean"));
                combo_compare.addEventListener(Event.SELECT, e_valueBooleanCompareChange);
                combo_compare.setSize(130, 26);
                combo_compare.selectedItemByData = (filter.inverse) ? 1 : 0;
                combo_compare.fontSize = 11;
                
                xOff += combo_compare.width + 10;
                
                var playableText                       : Dynamic= new Text(this, xOff, 6, _lang.string("filter_setting_playable"));
            
            case EngineLevelFilter.FILTER_AAA_EQUIV:
                typeText = new Text(this, 8, 8, _lang.string("filter_type_" + filter.type));
                
                xOff += typeText.x + typeText.width + 10;
                
                combo_compare = new ComboBox(this, xOff, 4, "", EngineLevelFilter.createIndexOptions(EngineLevelFilter.FILTERS_BOOLEAN, "compare_boolean"));
                combo_compare.addEventListener(Event.SELECT, e_valueBooleanCompareChange);
                combo_compare.setSize(130, 26);
                combo_compare.selectedItemByData = (filter.inverse) ? 1 : 0;
                combo_compare.fontSize = 11;
                
                xOff += combo_compare.width + 10;
                
                var improvementText                       : Dynamic= new Text(this, xOff, 6, _lang.string("filter_setting_possible"));
                
                if (as3hx.Compat.truthy(_avars.configLegacy != null))
                {
                    this.alpha = 0.5;
                    this.color = 0xBBBBBB;
                    
                    var altEngineText                       : Dynamic= new Text(this, 0, 6, "altengine_setting_ignored");
                    altEngineText.x = this.width - altEngineText.width - 5;
                    altEngineText.fontColor = "#FF0000";
                    altEngineText.alpha = 2;
                }
            
            case EngineLevelFilter.FILTER_SONG_TYPE:
                typeText = new Text(this, 8, 8, _lang.string("filter_type_" + filter.type));
                
                xOff += typeText.x + typeText.width + 10;
                
                combo_compare = new ComboBox(this, xOff, 4, "", EngineLevelFilter.createIndexOptions(EngineLevelFilter.FILTERS_BOOLEAN, "compare_boolean"));
                combo_compare.addEventListener(Event.SELECT, e_valueBooleanCompareChange);
                combo_compare.setSize(130, 26);
                combo_compare.selectedItemByData = (filter.inverse) ? 1 : 0;
                combo_compare.fontSize = 11;
                
                xOff += combo_compare.width + 10;
                
                combo_stat = new ComboBox(this, xOff, 4, "", EngineLevelFilter.createIndexOptions(EngineLevelFilter.FILTERS_SONG_TYPES, "compare_types"));
                combo_stat.addEventListener(Event.SELECT, e_valueComboNumberChange);
                combo_stat.setSize(130, 26);
                combo_stat.selectedItemByData = filter.input_number;
                combo_stat.fontSize = 11;
            case EngineLevelFilter.FILTER_ARROWCOUNT, EngineLevelFilter.FILTER_BPM, EngineLevelFilter.FILTER_DIFFICULTY, EngineLevelFilter.FILTER_MAX_NPS, EngineLevelFilter.FILTER_MIN_NPS, EngineLevelFilter.FILTER_RANK, EngineLevelFilter.FILTER_SCORE, EngineLevelFilter.FILTER_COMBO_SCORE, EngineLevelFilter.FILTER_TIME, EngineLevelFilter.FILTER_SONG_RATING, EngineLevelFilter.FILTER_PERSONAL_SONG_RATING:
                typeText = new Text(this, 8, 8, _lang.string("filter_type_" + filter.type));
                
                xOff += typeText.x + typeText.width + 10;
                
                combo_compare = new ComboBox(this, xOff, 4, "", EngineLevelFilter.FILTERS_NUMBER);
                combo_compare.addEventListener(Event.SELECT, e_valueCompareChange);
                combo_compare.setSize(130, 26);
                combo_compare.selectedItemByData = filter.comparison;
                combo_compare.fontSize = 11;
                
                xOff += combo_compare.width + 10;
                
                input_box = new ValidatedText(this, xOff, 4, 107, 24, ValidatedText.R_FLOAT, e_valueNumberChange);
                input_box.text = Std.string(filter.input_number);
            case EngineLevelFilter.FILTER_ID, EngineLevelFilter.FILTER_NAME, EngineLevelFilter.FILTER_STYLE, EngineLevelFilter.FILTER_ARTIST, EngineLevelFilter.FILTER_STEPARTIST:
                typeText = new Text(this, 8, 8, _lang.string("filter_type_" + filter.type));
                
                xOff += typeText.x + typeText.width + 10;
                
                combo_compare = new ComboBox(this, xOff, 4, "", EngineLevelFilter.createOptions(EngineLevelFilter.FILTERS_STRING, "compare_string"));
                combo_compare.addEventListener(Event.SELECT, e_valueCompareChange);
                combo_compare.setSize(130, 26);
                combo_compare.selectedItemByData = filter.comparison;
                combo_compare.fontSize = 11;
                
                xOff += combo_compare.width + 10;
                
                input_box = new BoxText(this, xOff, 4, 107, 24);
                input_box.text = filter.input_string;
                input_box.addEventListener(Event.CHANGE, e_valueStringChange);
            
            case EngineLevelFilter.FILTER_SONG_GENRE:
                typeText = new Text(this, 8, 8, _lang.string("filter_type_" + filter.type));
                
                xOff += typeText.x + typeText.width + 10;
                
                combo_compare = new ComboBox(this, xOff, 4, "", EngineLevelFilter.createIndexOptions(EngineLevelFilter.FILTERS_BOOLEAN, "compare_boolean"));
                combo_compare.addEventListener(Event.SELECT, e_valueBooleanCompareChange);
                combo_compare.setSize(130, 26);
                combo_compare.selectedItemByData = (filter.inverse) ? 1 : 0;
                combo_compare.fontSize = 11;
                
                xOff += combo_compare.width + 10;
                
                combo_stat = new ComboBox(this, xOff, 4, "", EngineLevelFilter.createSimpleOptionsFromLanguage(_gvars.TOTAL_GENRES, "genre_"));
                combo_stat.addEventListener(Event.SELECT, e_valueComboNumberChange);
                combo_stat.setSize(130, 26);
                combo_stat.selectedItemByData = filter.input_number;
                combo_stat.fontSize = 11;
            
            case EngineLevelFilter.FILTER_FAVORITE:
                typeText = new Text(this, 8, 8, _lang.string("filter_type_" + filter.type));
                
                xOff += typeText.x + typeText.width + 10;
                
                combo_compare = new ComboBox(this, xOff, 4, "", EngineLevelFilter.createIndexOptions(EngineLevelFilter.FILTERS_BOOLEAN, "compare_boolean"));
                combo_compare.addEventListener(Event.SELECT, e_valueBooleanCompareChange);
                combo_compare.setSize(130, 26);
                combo_compare.selectedItemByData = (filter.inverse) ? 1 : 0;
                combo_compare.fontSize = 11;
            default:
                typeText = new Text(this, 8, 8, filter.type);
        }
    }
    
    private function e_valueBooleanCompareChange(e                       : Dynamic) : Void
    {
        var item                       : Dynamic= e.target.selectedItem;
        
        if (as3hx.Compat.truthy(item.exists("data")))
        {
            filter.inverse = as3hx.Compat.parseFloat(item.data) >= 1;
        }
        else
        {
            filter.inverse = as3hx.Compat.parseFloat(item) >= 1;
        }
    }
    
    private function e_valueComboNumberChange(e                       : Dynamic) : Void
    {
        var item                       : Dynamic= e.target.selectedItem;
        
        if (as3hx.Compat.truthy(item.exists("data")))
        {
            filter.input_number = as3hx.Compat.parseFloat(item.data);
        }
        else
        {
            filter.input_number = as3hx.Compat.parseFloat(item);
        }
    }
    
    private function e_valueStatChange(e                       : Dynamic) : Void
    {
        var item                       : Dynamic= e.target.selectedItem;
        
        if (as3hx.Compat.truthy(item.exists("data")))
        {
            filter.input_stat = item.data;
        }
        else
        {
            filter.input_stat = (Std.string(item));
        }
    }
    
    private function e_valueCompareChange(e                       : Dynamic) : Void
    {
        var item                       : Dynamic= e.target.selectedItem;
        
        if (as3hx.Compat.truthy(item.exists("data")))
        {
            filter.comparison = item.data;
        }
        else
        {
            filter.comparison = (Std.string(item));
        }
    }
    
    private function e_valueStringChange(e                       : Dynamic) : Void
    {
        filter.input_string = input_box.text;
    }
    
    private function e_valueNumberChange(e                       : Dynamic) : Void
    {
        filter.input_number = (try cast(input_box, ValidatedText) catch(e:Dynamic) null).validate(0);
    }
    
    private function e_clickRemovefilter(e                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(ArrayUtil.remove(filter, filter.parent_filter.filters)))
        {
            updater.draw();
        }
    }
}

