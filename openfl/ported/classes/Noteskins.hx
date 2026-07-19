package classes;

import openfl.errors.Error;
import by.blooddy.crypto.Base64;
import com.flashfla.utils.ObjectUtil;
import openfl.display.BitmapData;
import openfl.display.MovieClip;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IOErrorEvent;
import r3.air.filesystem.File;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.utils.ByteArray;
import game.noteskins.*;

class Noteskins extends EventDispatcher
{
    public static var instance(get, never) : Noteskins;
    public var data(get, never) : Dynamic;
    public var externalNoteskins(get, never) : Array<ExternalNoteskin>;

    private static var note_asset_names : Array<Dynamic> = ["blue", "red", "yellow", "green", "purple", "pink", "orange", "cyan", "white"];
    private static var note_direction_names : Array<Dynamic> = ["D", "U", "L", "R"];
    private static inline var TYPE_SWF : Int = 0;
    private static inline var TYPE_BITMAP : Int = 1;
    
    public static inline var CUSTOM_NOTESKIN_DATA : String = "custom_noteskin";
    public static inline var CUSTOM_NOTESKIN_IMPORT : String = "custom_noteskin_import";
    public static inline var CUSTOM_NOTESKIN_FILE : String = "custom_noteskin_filename";
    
    public static inline var JSON_LOAD : String = "json_load";
    public static inline var JSON_ERROR : String = "json_error";
    
    ///- Singleton Instance
    private static var _instance : Noteskins = null;
    private static var _externalNoteskins : Array<ExternalNoteskin>;
    
    ///- Private Locals
    private var _gvars : GlobalVariables = GlobalVariables.instance;
    private var _isLoaded : Bool = false;
    private var _isLoading : Bool = false;
    private var _loadError : Bool = false;
    
    private var _data : Dynamic;
    public var lastCustomNoteskin : String;
    
    public var totalNoteskins : Int = 0;
    public var totalLoaded : Int = 0;
    
    //******************************************************************************************//
    // Core Class Functions
    //******************************************************************************************//
    
    public function new(en : NoteskinsSingletonEnforcer)
    {
        super();
        if (en == null)
        {
            throw cast(("Multi-Instance Blocked"), Error);
        }
    }
    
    private static function get_instance() : Noteskins
    {
        if (_instance == null)
        {
            _instance = new Noteskins(new NoteskinsSingletonEnforcer());
        }
        return _instance;
    }
    
    /**
     * Gets the loaded status.
     * @return Is loaded & No Load Errors
     */
    public function isLoaded() : Bool
    {
        return _isLoaded && !_loadError;
    }
    
    /**
     * Is there a load error.
     * @return
     */
    public function isError() : Bool
    {
        return _loadError;
    }
    
    /**
     * Called when a a noteskin is loaded.
     * Triggers a LOAD_COMPLETE when the total noteskins matchs the loaded noteskins.
     */
    private function loadComplete() : Void
    // All Noteskins loaded.
    {
        
        if (totalNoteskins == totalLoaded && totalNoteskins > 0)
        {
            _isLoaded = true;
            this.dispatchEvent(new Event(GlobalVariables.LOAD_COMPLETE));
        }
        // No Loaded Noteskins
        else if (totalNoteskins == 0)
        {
            _loadError = true;
            this.dispatchEvent(new Event(GlobalVariables.LOAD_ERROR));
        }
    }
    
    /**
     * Load the Noteskins data.
     */
    public function load() : Void
    // Load New
    {
        
        _isLoading = true;
        _isLoaded = false;
        _loadError = false;
        _data = { };
        
        var embeddedNoteskins : Array<EmbedNoteskinBase> = [new EmbedNoteskin1(), 
                new EmbedNoteskin2(), 
                new EmbedNoteskin3(), 
                new EmbedNoteskin4(), 
                new EmbedNoteskin5(), 
                new EmbedNoteskin6(), 
                new EmbedNoteskin7(), 
                new EmbedNoteskin8(), 
                new EmbedNoteskin9(), 
                new EmbedNoteskin10()
        ];
        
        for (embedNoteskin in embeddedNoteskins)
        {
            Reflect.setField(_data, Std.string(embedNoteskin.getID()), embedNoteskin.getData());
            Reflect.setField(Reflect.field(_data, Std.string(embedNoteskin.getID())), "notes", { });
            loadNoteskinSWF(embedNoteskin.getID(), embedNoteskin.getBytes());
        }
        
        loadCustomNoteskin();
    }
    
    //******************************************************************************************//
    // Providers
    //******************************************************************************************//
    
    /**
     * Gets all loaded noteskin data.
     * @return
     */
    private function get_data() : Dynamic
    {
        return _data;
    }
    
    /**
     * Gets a single noteskin data, or the default noteskin if the requested
     * noteskin is null.
     * @param noteskin
     * @return
     */
    public function getInfo(noteskin : Int) : Dynamic
    {
        if (Reflect.field(_data, Std.string(noteskin)) != null)
        {
            return Reflect.field(_data, Std.string(noteskin));
        }
        return Reflect.field(_data, Std.string(1));
    }
    
    /**
     * Gets the Note Sprite from the noteskin.
     * @param noteskin
     * @param color
     * @param direction
     * @return
     */
    public function getNote(noteskin : Int, color : String, direction : String) : Sprite
    {
        try {
if (Reflect.field(_data, Std.string(noteskin)) == null)
            {
                noteskin = 1;
            }
            
            if (RenderQuality.useHiResDefaultNotes(noteskin))
            {
                return new HiResArrowNote(color, Reflect.field(Reflect.field(_data, Std.string(noteskin)), "width"), Reflect.field(Reflect.field(_data, Std.string(noteskin)), "height"));
            }
            
            if (Reflect.field(Reflect.field(_data, Std.string(noteskin)), "type") == TYPE_BITMAP)
            {
                return drawBitmapNote(Reflect.field(Reflect.field(Reflect.field(Reflect.field(_data, Std.string(noteskin)), "notes"), color), direction));
            }
            
            var note : Sprite = new Data()[noteskin]["notes"][color][direction];
            RenderQuality.cacheDisplayObject(note);
            return note;
        }
        catch (e : Error)
        {
        }
        return new Sprite();
    }
    
    /**
     * Gets the Receptor Movieclip from the noteskin.
     * This is slower and shouldn't be used for gameplay, only UI
     * to prevent crashes on corrupted noteskins. A blank movieclip will
     * be return if a error occurs.
     * @param noteskin
     * @param color
     * @param direction
     * @return
     */
    public function getReceptor(noteskin : Int, direction : String) : MovieClip
    {
        try {
if (Reflect.field(_data, Std.string(noteskin)) == null)
            {
                noteskin = 1;
            }
            
            if (RenderQuality.useHiResDefaultNotes(noteskin))
            {
                return new HiResGameReceptor(direction, Reflect.field(Reflect.field(_data, Std.string(noteskin)), "width"), Reflect.field(Reflect.field(_data, Std.string(noteskin)), "height"));
            }
            
            if (Reflect.field(Reflect.field(_data, Std.string(noteskin)), "type") == TYPE_BITMAP)
            {
                return new GameReceptor(direction, Reflect.field(Reflect.field(Reflect.field(_data, Std.string(noteskin)), "receptor"), direction));
            }
            
            var receptor : MovieClip = new Data()[noteskin]["receptor"][direction];
            RenderQuality.cacheDisplayObject(receptor);
            return receptor;
        }
        catch (e : Error)
        {
        }
        return new MovieClip();
    }
    
    /**
     * Draws a Notes BitmapData into a new sprite.
     * @param bmd BitmapData
     * @return
     */
    private function drawBitmapNote(bmd : BitmapData) : Sprite
    {
        var n : Sprite = new Sprite();
        n.graphics.beginBitmapFill(bmd, RenderQuality.bitmapFillMatrix(), false, true);
        n.graphics.drawRect(0, 0, bmd.width / RenderQuality.SUPERSAMPLE_SCALE, bmd.height / RenderQuality.SUPERSAMPLE_SCALE);
        n.graphics.endFill();
        RenderQuality.cacheDisplayObject(n);
        n.mouseEnabled = false;
        n.doubleClickEnabled = false;
        n.tabEnabled = false;
        return n;
    }
    
    /**
     * Checks if noteskin ID is valid.
     * @param noteskin
     * @return
     */
    public function isValid(noteskin : Int) : Bool
    {
        return Reflect.field(_data, Std.string(noteskin)) != null;
    }
    
    //******************************************************************************************//
    // SWF Noteskins
    //******************************************************************************************//
    
    /**
     * Begin loading of a SWF noteskin and marks the type for this noteskin as TYPE_SWF.
     * @param noteID
     */
    private function loadNoteskinSWF(noteID : Int, bytes : ByteArray) : Void
    {
        var _swfloader : DynamicLoader = new DynamicLoader();
        _swfloader.contentLoaderInfo.addEventListener(Event.COMPLETE, noteskinSWFLoadComplete);
        _swfloader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, noteskinSWFLoadError);
        _swfloader.loadBytes(bytes, AirContext.getLoaderContext());
        _swfloader.ID = noteID;
        Reflect.setField(Reflect.field(_data, Std.string(noteID)), "type", TYPE_SWF);
        totalNoteskins++;
    }
    
    /**
     * Event.COMPLETE for SWF loading complete.
     * @param e
     */
    private function noteskinSWFLoadComplete(e : Event = null) : Void
    {
        var loader : DynamicLoader = e.target.loader;
        var noteID : String = loader.ID;
        
        // Remove Listeners
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, noteskinSWFLoadComplete);
        loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, noteskinSWFLoadError);
        
        // Create Objects
        for (asset_name in note_asset_names)
        {
            Reflect.setField(Reflect.field(Reflect.field(_data, noteID), "notes"), Std.string(asset_name), getAssetFromTarget(e.target, "assets.noteskin::note_" + asset_name));
        }
        Reflect.setField(Reflect.field(_data, noteID), "receptor", getAssetFromTarget(e.target, "assets.noteskin::receptor"));
        
        // Verify or Remove
        if (verifyNoteSkin(noteID))
        {
            totalLoaded++;
        }
        else
        {
            totalNoteskins--;
            Reflect.deleteField(_data, noteID);
        }
        
        loadComplete();
    }
    
    /**
     * IOErrorEvent.IO_ERROR for SWF loading failure.
     * @param e
     */
    private function noteskinSWFLoadError(e : Event = null) : Void
    {
        var loader : DynamicLoader = e.target.loader;
        
        // Remove Listeners
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, noteskinSWFLoadComplete);
        loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, noteskinSWFLoadError);
        
        // Remove From List
        totalNoteskins--;
        Reflect.deleteField(_data, loader.ID);
        
        loadComplete();
    }
    
    /**
     * Attempts to retrieve a class definition from the given object.
     * Used to retrieve the notes and receptors from loaded swfs.
     * @param loader
     * @param assetName
     * @return
     */
    private function getAssetFromTarget(loader : Dynamic, assetName : String) : Dynamic
    {
        try
        {
            return {
                D : Type.getClass(loader.applicationDomain.getDefinition(assetName))
            };
        }
        catch (e : Error)
        {
        }
        return null;
    }
    
    //******************************************************************************************//
    // Bitmap Noteskin
    //******************************************************************************************//
    
    /**
     * Begin loading of a bitmap noteskin and marks the type for this noteskin as TYPE_BITMAP.
     * @param noteID
     */
    private function loadNoteskinBitmap(noteID : String) : Void
    {
        if (Reflect.field(Reflect.field(_data, noteID), "data") == null)
        {
            return;
        }
        
        Reflect.setField(Reflect.field(_data, noteID), "type", TYPE_BITMAP);
        
        var mbpString : String = Reflect.field(Reflect.field(_data, noteID), "data");
        var imgLoader : DynamicLoader = new DynamicLoader();
        imgLoader.ID = noteID;
        totalNoteskins++;
        
        imgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, e_bitmapFail);
        imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, e_bitmapLoad);
        
        try
        {
            imgLoader.loadBytes(Base64.decode(mbpString), AirContext.getLoaderContext());
        }
        catch (e : Error) {
totalNoteskins--;
            Reflect.deleteField(_data, noteID);
        }
    }
    
    /**
     * Event.COMPLETE for bitmap loading complete.
     * @param e
     */
    private function e_bitmapLoad(e : Event) : Void
    {
        var loader : DynamicLoader = e.currentTarget.loader;
        loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, e_bitmapFail);
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, e_bitmapLoad);
        
        var noteID : String = loader.ID;
        var noteskin_struct : Dynamic = null;
        
        // Get Noteskin Structure
        if (Reflect.field(Reflect.field(_data, noteID), "rects") != null)
        {
            if (Std.is(Reflect.field(Reflect.field(_data, noteID), "rects"), String))
            {
                try
                {
                    noteskin_struct = haxe.Json.parse(Reflect.field(Reflect.field(_data, noteID), "rects"));
                }
                catch (e : Error)
                {
                }
            }
            else
            {
                noteskin_struct = Reflect.field(Reflect.field(_data, noteID), "rects");
            }
        }
        
        // Draw Source Bitmap
        var bmp : BitmapData = new BitmapData(loader.width, loader.height, true, 0);
        bmp.draw(loader);
        
        // Draw Sub-Images for Noteskin
        var arr : Dynamic = buildFromBitmapData(bmp, noteskin_struct);
        if (arr == null)
        {
            dispatchEvent(new Event(JSON_ERROR));
            
            totalNoteskins--;
            Reflect.deleteField(_data, noteID);
            loadComplete();
            return;
        }
        
        // Set parameters from structure.
        Reflect.setField(Reflect.field(_data, noteID), "width", Reflect.field(Reflect.field(arr, "_cell"), Std.string(0)));
        Reflect.setField(Reflect.field(_data, noteID), "height", Reflect.field(Reflect.field(arr, "_cell"), Std.string(1)));
        Reflect.setField(Reflect.field(_data, noteID), "rotation", Reflect.field(Reflect.field(arr, "_cell"), Std.string(2)));
        
        for (name in Reflect.fields(arr))
        {
            if (name == "receptor")
            {
                Reflect.setField(Reflect.field(_data, noteID), "receptor", Reflect.field(arr, "receptor"));
            }
            else
            {
                Reflect.setField(Reflect.field(Reflect.field(_data, noteID), "notes"), name, Reflect.field(arr, name));
            }
        }
        
        // Verify or Remove
        if (verifyNoteSkin(noteID))
        {
            dispatchEvent(new Event(JSON_LOAD));
            
            totalLoaded++;
            Reflect.deleteField(Reflect.field(_data, noteID), "data");
            Reflect.deleteField(Reflect.field(_data, noteID), "rects");
        }
        else
        {
            dispatchEvent(new Event(JSON_ERROR));
            
            totalNoteskins--;
            Reflect.deleteField(_data, noteID);
        }
        
        loadComplete();
    }
    
    /**
     * IOErrorEvent.IO_ERROR for bitmap loading failure.
     * @param e
     */
    private function e_bitmapFail(e : Event) : Void
    {
        var loader : DynamicLoader = e.currentTarget.loader;
        loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, e_bitmapFail);
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, e_bitmapLoad);
        
        var noteID : String = loader.ID;
        
        //- Remove From List
        totalNoteskins--;
        Reflect.deleteField(_data, noteID);
        
        dispatchEvent(new Event(JSON_ERROR));
        
        loadComplete();
    }
    
    /**
     * Builds a group of noteskin bitmaps from the source BitmapData
     * following the cell structure
     * @param bmd Source Bitmap Data
     * @param import_struct
     * @return
     */
    public static function buildFromBitmapData(bmd : BitmapData, import_struct : Dynamic) : Dynamic
    {
        var struct : Dynamic = NoteskinsStruct.getDefaultStruct();
        var out : Dynamic = { };
        var cuts : Dynamic = { };
        ObjectUtil.merge(struct, import_struct);
        
        if (import_struct == null || Reflect.field(struct, "options") == null || Reflect.field(Reflect.field(struct, "options"), "grid_dim") == null || Reflect.field(struct, "blue") == null || Reflect.field(Reflect.field(struct, "blue"), "D") == null || Reflect.field(Reflect.field(Reflect.field(struct, "blue"), "D"), "c") == null)
        {
            return null;
        }
        
        var parsedCell : Array<Dynamic> = NoteskinsStruct.parseCellInput(Reflect.field(Reflect.field(struct, "options"), "grid_dim"), 1, 1, 20, 20);
        var img_w : Int = bmd.width;
        var img_h : Int = bmd.height;
        var dim_w : Int = parsedCell[0];
        var dim_h : Int = parsedCell[1];
        var cell_width : Float = img_w / dim_w;
        var cell_height : Float = img_h / dim_h;
        var cell_rotate : Float = NoteskinsStruct.textToRotation(Reflect.field(Reflect.field(struct, "options"), "rotate"), 90);
        
        Reflect.setField(out, "_cell", [cell_width, cell_height, cell_rotate]);
        
        for (color in Reflect.fields(struct))
        {
            if (color == "options")
            {
                continue;
            }
            
            for (dir in Reflect.fields(Reflect.field(struct, color)))
            {
                if (Reflect.field(Reflect.field(Reflect.field(struct, color), dir), "c") == "")
                {
                    continue;
                }
                
                var note_pos : Array<Dynamic> = NoteskinsStruct.parseCellInput(Reflect.field(Reflect.field(Reflect.field(struct, color), dir), "c"));
                
                if (Reflect.field(out, color) == null)
                {
                    Reflect.setField(out, color, { });
                }
                
                // Position outside grid.
                if (note_pos[0] > dim_w || note_pos[1] > dim_h)
                {
                    continue;
                }
                // Get Existing Bitmap if Cords already used.
                else if (Reflect.field(cuts, Std.string(note_pos[0] + "x" + note_pos[1])) != null)
                {
                    Reflect.setField(Reflect.field(out, color), dir, Reflect.field(cuts, Std.string(note_pos[0] + "x" + note_pos[1])));
                }
                else
                {
                    var scale : Int = RenderQuality.SUPERSAMPLE_SCALE;
                    var note_canvas : BitmapData = new BitmapData(cell_width * scale, cell_height * scale, true, 0);
                    var note_matrix : Matrix = new Matrix(scale, 0, 0, scale, -note_pos[0] * cell_width * scale, -note_pos[1] * cell_height * scale);
                    note_canvas.draw(bmd, note_matrix, null, null, new Rectangle(0, 0, note_canvas.width, note_canvas.height), true);
                    Reflect.setField(Reflect.field(out, color), dir, note_canvas);
                    Reflect.setField(cuts, Std.string(note_pos[0] + "x" + note_pos[1]), "x");
                }
            }
        }
        
        return out;
    }
    
    /**
     * Verfies all required data is a part of a noteskin such as the Receptor and Blue note.
     * Once that is verified, it fill in any gaps for the other colors and direction that
     * might appear with filler data from the Blue note to prevent null errors.
     * @param noteID Note ID to check.
     * @return boolean If Valid Noteskin
     */
    private function verifyNoteSkin(noteID : String) : Bool
    // Check if this noteskin has the bare minimum requirements.
    {
        
        if (Reflect.field(_data, noteID) == null)
        {
            return false;
        }
        
        // Check Receptor
        if (Reflect.field(Reflect.field(_data, noteID), "receptor") == null || Reflect.field(Reflect.field(Reflect.field(_data, noteID), "receptor"), "D") == null)
        {
            return false;
        }
        
        // Check Blue Note
        if (Reflect.field(Reflect.field(Reflect.field(_data, noteID), "notes"), "blue") == null || Reflect.field(Reflect.field(Reflect.field(Reflect.field(_data, noteID), "notes"), "blue"), "D") == null)
        {
            return false;
        }
        
        // Check Missing Notes and fill from Blue
        for (asset_name in note_asset_names)
        {
            if (Reflect.field(Reflect.field(Reflect.field(_data, noteID), "notes"), Std.string(asset_name)) == null)
            {
                Reflect.setField(Reflect.field(Reflect.field(_data, noteID), "notes"), Std.string(asset_name), Reflect.field(Reflect.field(Reflect.field(_data, noteID), "notes"), "blue"));
            }
            
            // Check Missing Directions and fill from Down
            for (direction_name in note_direction_names) {
if (Reflect.field(Reflect.field(Reflect.field(Reflect.field(_data, noteID), "notes"), Std.string(asset_name)), Std.string(direction_name)) == null && Reflect.field(Reflect.field(Reflect.field(Reflect.field(_data, noteID), "notes"), Std.string(asset_name)), "D") != null)
                {
                    Reflect.setField(Reflect.field(Reflect.field(Reflect.field(_data, noteID), "notes"), Std.string(asset_name)), Std.string(direction_name), Reflect.field(Reflect.field(Reflect.field(Reflect.field(_data, noteID), "notes"), Std.string(asset_name)), "D"));
                }
                
                // Fill from blue.
                if (Reflect.field(Reflect.field(Reflect.field(Reflect.field(_data, noteID), "notes"), Std.string(asset_name)), Std.string(direction_name)) == null && Reflect.field(Reflect.field(Reflect.field(Reflect.field(_data, noteID), "notes"), "blue"), "D") != null)
                {
                    Reflect.setField(Reflect.field(Reflect.field(Reflect.field(_data, noteID), "notes"), Std.string(asset_name)), Std.string(direction_name), Reflect.field(Reflect.field(Reflect.field(Reflect.field(_data, noteID), "notes"), "blue"), "D"));
                }
            }
        }
        
        // Check Missing Receptor Directions and fill from Down
        for (receptor_direction in note_direction_names)
        {
            if (Reflect.field(Reflect.field(Reflect.field(_data, noteID), "receptor"), Std.string(receptor_direction)) == null)
            {
                Reflect.setField(Reflect.field(Reflect.field(_data, noteID), "receptor"), Std.string(receptor_direction), Reflect.field(Reflect.field(Reflect.field(_data, noteID), "receptor"), "D"));
            }
        }
        return true;
    }
    
    public function loadCustomNoteskin() : Void
    {
        var noteskinData : String = LocalStore.getVariable(CUSTOM_NOTESKIN_DATA, null);
        var noteskinImport : String = LocalStore.getVariable(CUSTOM_NOTESKIN_IMPORT, null);
        var noteskinFilename : String = LocalStore.getVariable(CUSTOM_NOTESKIN_FILE, null);
        
        // Copy Data into Import Slot if coming from old version.
        if (noteskinData != null && noteskinImport == null)
        {
            Logger.debug(this, "Storing Internal Noteskin");
            LocalStore.setVariable(CUSTOM_NOTESKIN_IMPORT, noteskinData);
        }
        
        // No Data, no Custom Noteskin
        if (noteskinData == null)
        {
            Logger.debug(this, "No Noteskin Data");
            return;
        }
        
        // Reload External Noteskin if exist
        if (noteskinFilename != null)
        {
            Logger.debug(this, "Reloading External Noteskin: " + noteskinFilename);
            var noteskinJSON : String = AirContext.readTextFile(AirContext.getAppFile(Constant.NOTESKIN_PATH).resolvePath(noteskinFilename));
            
            if (noteskinJSON == null)
            {
                LocalStore.deleteVariable(CUSTOM_NOTESKIN_FILE);
            }
            else
            {
                noteskinData = noteskinJSON;
            }
        }
        
        loadCustomNoteskinJSON(noteskinData);
    }
    
    public function loadCustomNoteskinJSON(data : String, noteskinID : String = "0") : Void
    {
        if (data != null)
        {
            if (noteskinID == "0")
            {
                lastCustomNoteskin = data;
            }
            
            var obj : Dynamic = haxe.Json.parse(data);
            Reflect.setField(obj, "id", noteskinID);
            Reflect.setField(obj, "_hidden", true);
            Reflect.setField(obj, "notes", { });
            Reflect.setField(_data, Std.string(Reflect.field(obj, "id")), obj);
            loadNoteskinBitmap(noteskinID);
        }
        else if (Reflect.field(_data, noteskinID) != null)
        {
            Reflect.deleteField(_data, noteskinID);
        }
    }
    
    private function get_externalNoteskins() : Array<ExternalNoteskin>
    {
        if (_externalNoteskins == null)
        {
            loadExternalNoteskins();
        }
        
        return _externalNoteskins;
    }
    
    public function loadExternalNoteskins() : Bool
    {
        _externalNoteskins = [];
        
        var noteskinFolder : File = AirContext.getAppFile(Constant.NOTESKIN_PATH);
        if (!noteskinFolder.exists || !noteskinFolder.isDirectory || noteskinFolder.isHidden)
        {
            return false;
        }
        
        var file : File;
        var fileDataJSON : String;
        var fileData : Dynamic;
        var files : Array<Dynamic> = noteskinFolder.getDirectoryListing();
        for (i in 0...files.length)
        {
            file = files[i];
            try
            {
                if (file.extension != "txt")
                {
                    continue;
                }
                
                fileDataJSON = AirContext.readTextFile(file);
                fileData = haxe.Json.parse(fileDataJSON);
                
                var extNoteskin : ExternalNoteskin = new ExternalNoteskin();
                extNoteskin.file = file.name;
                extNoteskin.data = fileData;
                extNoteskin.json = fileDataJSON;
                _externalNoteskins.push(extNoteskin);
            }
            catch (error : Error)
            {
            }
        }
        
        return true;
    }
}


class NoteskinsSingletonEnforcer
{

    public function new()
    {
    }
}
