package classes.filter;

import assets.GameBackgroundColor;
import classes.Alert;
import classes.Language;
import classes.filter.EngineLevelFilter;
import classes.ui.Box;
import classes.ui.BoxButton;
import classes.ui.BoxCheck;
import classes.ui.BoxIcon;
import classes.ui.IconUtil;
import classes.ui.Text;
import com.flashfla.utils.SystemUtil;
import com.flashfla.utils.VectorUtil;
import openfl.display.DisplayObjectContainer;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import popups.PopupFilterManager;

class SavedFilterButton extends Box
{
    private var _gvars                             : Dynamic= GlobalVariables.instance;
    private var _lang                             : Dynamic= Language.instance;
    private static var hover_message                             : Dynamic;
    
    private var updater                             : Dynamic;
    public var filter                             : Dynamic;
    public var filterName                             : Dynamic;
    public var editButton                             : Dynamic;
    public var exportButton                             : Dynamic;
    public var deleteButton                             : Dynamic;
    public var defaultCheckbox                             : Dynamic;
    
    public function new(parent                             : Dynamic, xpos                             : Dynamic, ypos                             : Dynamic, filter                             : Dynamic, updater                             : Dynamic)
    {
        this.filter = filter;
        this.updater = updater;
        super(parent, xpos, ypos, false, false);
        super.setSize(704, 35);
        
        init();
    }
    
    public function init() : Void
    {
        defaultCheckbox = new BoxCheck(this, 7, 11, e_defaultClick);
        defaultCheckbox.checked = filter.is_default;
        defaultCheckbox.addEventListener(MouseEvent.MOUSE_OVER, e_defaultMouseOver);
        
        filterName = new Text(this, 25, 0, filter.name);
        filterName.height = 35;
        
        deleteButton = new BoxIcon(this, width - 28, 5, 23, 23, IconUtil.getIcon("iconDelete"), e_deleteClick);
        deleteButton.setHoverText(_lang.string("filter_editor_delete"));
        exportButton = new BoxIcon(this, deleteButton.x - 28, 5, 23, 23, IconUtil.getIcon("iconCopy"), e_exportClick);
        exportButton.setHoverText(_lang.string("popup_filter_filter_single_export"));
        editButton = new BoxButton(this, exportButton.x - 105, 5, 100, 23, _lang.string("filter_editor_select_edit"), 12, e_editClick);
    }
    
    override public function dispose() : Void
    {
        defaultCheckbox.removeEventListener(MouseEvent.MOUSE_OVER, e_defaultMouseOver);
        defaultCheckbox.removeEventListener(MouseEvent.MOUSE_OUT, e_defaultMouseOut);
        defaultCheckbox.dispose();
        
        filterName.dispose();
        
        deleteButton.dispose();
        editButton.dispose();
        exportButton.dispose();
        
        super.dispose();
    }
    
    private function e_defaultMouseOver(e                             : Dynamic) : Void
    {
        defaultCheckbox.addEventListener(MouseEvent.MOUSE_OUT, e_defaultMouseOut);
        if (as3hx.Compat.truthy(hover_message == null))
        {
            hover_message = new Sprite();
            var msg                             : Dynamic= new Text(null, 5, 0, _lang.string("popup_filter_default_filter"));
            msg.height = 23;
            hover_message.graphics.lineStyle(1, 0xffffff, 0.75);
            hover_message.graphics.beginFill(GameBackgroundColor.BG_POPUP, 1);
            hover_message.graphics.drawRect(0, 0, msg.width + 10, 23);
            hover_message.graphics.endFill();
            hover_message.addChild(msg);
        }
        
        hover_message.x = defaultCheckbox.x + 19;
        hover_message.y = 5;
        
        addChild(hover_message);
    }
    
    private function e_defaultMouseOut(e                             : Dynamic) : Void
    {
        defaultCheckbox.removeEventListener(MouseEvent.MOUSE_OUT, e_defaultMouseOut);
        removeChild(hover_message);
    }
    
    private function e_defaultClick(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(!filter.is_default))
        {
            for (item/* AS3HX WARNING could not determine type for var: item exp: EField(EField(EIdent(_gvars),activeUser),filters) type: null */ in as3hx.Compat.iter(_gvars.activeUser.filters))
            {
                item.is_default = false;
            }
        }
        
        filter.is_default = !filter.is_default;
        defaultCheckbox.checked = filter.is_default;
        updater.draw();
    }
    
    private function e_editClick(e                             : Dynamic) : Void
    {
        _gvars.activeFilter = filter;
        updater.DRAW_TAB = PopupFilterManager.TAB_FILTER;
        updater.draw();
    }
    
    private function e_deleteClick(e                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(VectorUtil.removeFirst(filter, _gvars.activeUser.filters)))
        {
            updater.draw();
        }
    }
    
    private function e_exportClick(e                             : Dynamic) : Void
    {
        var filterString                             : Dynamic= haxe.Json.stringify(filter.export());
        var success                             : Dynamic= SystemUtil.setClipboard(filterString);
        if (as3hx.Compat.truthy(success))
        {
            Alert.add(_lang.string("clipboard_success"), 120, Alert.GREEN);
        }
        else
        {
            Alert.add(_lang.string("clipboard_failure"), 120, Alert.RED);
        }
    }
}

