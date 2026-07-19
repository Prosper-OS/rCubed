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
    public static var instance(get, never)                              : Dynamic;
    public var data(get, never)                              : Dynamic;
    public var externalNoteskins(get, never)                              : Dynamic;

    private static var note_asset_names                              : Dynamic= ["blue", "red", "yellow", "green", "purple", "pink", "orange", "cyan", "white"];
    private static var note_direction_names                              : Dynamic= ["D", "U", "L", "R"];
    private static inline var TYPE_SWF                              : Dynamic= 0;
    private static inline var TYPE_BITMAP                              : Dynamic= 1;
    
    public static inline var CUSTOM_NOTESKIN_DATA                              : Dynamic= "custom_noteskin";
    public static inline var CUSTOM_NOTESKIN_IMPORT                              : Dynamic= "custom_noteskin_import";
    public static inline var CUSTOM_NOTESKIN_FILE                              : Dynamic= "custom_noteskin_filename";
    
    public static inline var JSON_LOAD                              : Dynamic= "json_load";
    public static inline var JSON_ERROR                              : Dynamic= "json_error";
    
    ///- Singleton Instance
    private static var _instance                              : Dynamic= null;
    private static var _externalNoteskins                              : Dynamic;
    
    ///- Private Locals
    private var _gvars                              : Dynamic= GlobalVariables.instance;
    private var _isLoaded                              : Dynamic= false;
    private var _isLoading                              : Dynamic= false;
    private var _loadError                              : Dynamic= false;
    
    private var _data                              : Dynamic;
    public var lastCustomNoteskin                              : Dynamic;
    
    public var totalNoteskins                              : Dynamic= 0;
    public var totalLoaded                              : Dynamic= 0;
    
    //******************************************************************************************//
    // Core Class Functions
    //******************************************************************************************//
    
    public function new(en                              : Dynamic)
    {
        super();
        if (as3hx.Compat.truthy(en == null))
        {
            throw cast(("Multi-Instance Blocked"), Error);
        }
    }
    
    private static function get_instance() : Noteskins
    {
        if (as3hx.Compat.truthy(_instance == null))
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
        
        if (as3hx.Compat.truthy(totalNoteskins == totalLoaded && totalNoteskins > 0))
        {
            _isLoaded = true;
            this.dispatchEvent(new Event(GlobalVariables.LOAD_COMPLETE));
        }
        // No Loaded Noteskins
        else if (as3hx.Compat.truthy(totalNoteskins == 0))
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
        
        var embeddedNoteskins                              : Dynamic= [new EmbedNoteskin1(), 
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
        
        for (embedNoteskin in as3hx.Compat.iter(embeddedNoteskins))
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
    public function getInfo(noteskin                              : Dynamic) : Dynamic
    {
        if (as3hx.Compat.truthy(as3hx.Compat.field(_data, noteskin) != null))
        {
            return as3hx.Compat.field(_data, noteskin);
        }
        return as3hx.Compat.field(_data, 1);
    }
    
    /**
     * Gets the Note Sprite from the noteskin.
     * @param noteskin
     * @param color
     * @param direction
     * @return
     */
    public function getNote(noteskin                              : Dynamic, color                              : Dynamic, direction                              : Dynamic) : Sprite
    {
        try {
if (as3hx.Compat.truthy(as3hx.Compat.field(_data, noteskin) == null))
            {
                noteskin = 1;
            }
            
            if (as3hx.Compat.truthy(RenderQuality.useHiResDefaultNotes(noteskin)))
            {
                return new HiResArrowNote(color, Reflect.field(as3hx.Compat.field(_data, noteskin), "width"), Reflect.field(as3hx.Compat.field(_data, noteskin), "height"));
            }
            
            if (as3hx.Compat.truthy(Reflect.field(as3hx.Compat.field(_data, noteskin), "type") == TYPE_BITMAP))
            {
                return drawBitmapNote(Reflect.field(Reflect.field(Reflect.field(as3hx.Compat.field(_data, noteskin), "notes"), color), direction));
            }
            
            var note                              : Dynamic= Type.createInstance(Reflect.field(Reflect.field(Reflect.field(as3hx.Compat.field(_data, noteskin), "notes"), color), direction), []);
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
    public function getReceptor(noteskin                              : Dynamic, direction                              : Dynamic) : MovieClip
    {
        try {
if (as3hx.Compat.truthy(as3hx.Compat.field(_data, noteskin) == null))
            {
                noteskin = 1;
            }
            
            if (as3hx.Compat.truthy(RenderQuality.useHiResDefaultNotes(noteskin)))
            {
                return new HiResGameReceptor(direction, Reflect.field(as3hx.Compat.field(_data, noteskin), "width"), Reflect.field(as3hx.Compat.field(_data, noteskin), "height"));
            }
            
            if (as3hx.Compat.truthy(Reflect.field(as3hx.Compat.field(_data, noteskin), "type") == TYPE_BITMAP))
            {
                return new GameReceptor(direction, Reflect.field(Reflect.field(as3hx.Compat.field(_data, noteskin), "receptor"), direction));
            }
            
            var receptor                              : Dynamic= Type.createInstance(Reflect.field(Reflect.field(as3hx.Compat.field(_data, noteskin), "receptor"), direction), []);
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
    private function drawBitmapNote(bmd                              : Dynamic) : Sprite
    {
        var n                              : Dynamic= new Sprite();
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
    public function isValid(noteskin                              : Dynamic) : Bool
    {
        return as3hx.Compat.field(_data, noteskin) != null;
    }
    
    //******************************************************************************************//
    // SWF Noteskins
    //******************************************************************************************//
    
    /**
     * Begin loading of a SWF noteskin and marks the type for this noteskin as TYPE_SWF.
     * @param noteID
     */
    private function loadNoteskinSWF(noteID                              : Dynamic, bytes                              : Dynamic) : Void
    {
        var _swfloader                              : Dynamic= new DynamicLoader();
        _swfloader.contentLoaderInfo.addEventListener(Event.COMPLETE, noteskinSWFLoadComplete);
        _swfloader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, noteskinSWFLoadError);
        _swfloader.loadBytes(bytes, AirContext.getLoaderContext());
        _swfloader.ID = noteID;
        Reflect.setField(as3hx.Compat.field(_data, noteID), "type", TYPE_SWF);
        totalNoteskins++;
    }
    
    /**
     * Event.COMPLETE for SWF loading complete.
     * @param e
     */
    private function noteskinSWFLoadComplete(e                              : Dynamic= null) : Void
    {
        var loader                              : Dynamic= e.target.loader;
        var noteID                              : Dynamic= loader.ID;
        
        // Remove Listeners
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, noteskinSWFLoadComplete);
        loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, noteskinSWFLoadError);
        
        // Create Objects
        for (asset_name in as3hx.Compat.iter(note_asset_names))
        {
            Reflect.setField(Reflect.field(Reflect.field(_data, noteID), "notes"), Std.string(asset_name), getAssetFromTarget(e.target, "assets.noteskin::note_" + asset_name));
        }
        Reflect.setField(Reflect.field(_data, noteID), "receptor", getAssetFromTarget(e.target, "assets.noteskin::receptor"));
        
        // Verify or Remove
        if (as3hx.Compat.truthy(verifyNoteSkin(noteID)))
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
    private function noteskinSWFLoadError(e                              : Dynamic= null) : Void
    {
        var loader                              : Dynamic= e.target.loader;
        
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
    private function getAssetFromTarget(loader                              : Dynamic, assetName                              : Dynamic) : Dynamic
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
    private function loadNoteskinBitmap(noteID                              : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(Reflect.field(Reflect.field(_data, noteID), "data") == null))
        {
            return;
        }
        
        Reflect.setField(Reflect.field(_data, noteID), "type", TYPE_BITMAP);
        
        var mbpString                              : Dynamic= Reflect.field(Reflect.field(_data, noteID), "data");
        var imgLoader                              : Dynamic= new DynamicLoader();
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
    private function e_bitmapLoad(e                              : Dynamic) : Void
    {
        var loader                              : Dynamic= e.currentTarget.loader;
        loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, e_bitmapFail);
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, e_bitmapLoad);
        
        var noteID                              : Dynamic= loader.ID;
        var noteskin_struct                              : Dynamic= null;
        
        // Get Noteskin Structure
        if (as3hx.Compat.truthy(Reflect.field(Reflect.field(_data, noteID), "rects") != null))
        {
            if (as3hx.Compat.truthy(Std.is(Reflect.field(Reflect.field(_data, noteID), "rects"), String)))
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
        var bmp                              : Dynamic= new BitmapData(loader.width, loader.height, true, 0);
        bmp.draw(loader);
        
        // Draw Sub-Images for Noteskin
        var arr                              : Dynamic= buildFromBitmapData(bmp, noteskin_struct);
        if (as3hx.Compat.truthy(arr == null))
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
        
        for (name in as3hx.Compat.iter(Reflect.fields(arr)))
        {
            if (as3hx.Compat.truthy(name == "receptor"))
            {
                Reflect.setField(Reflect.field(_data, noteID), "receptor", Reflect.field(arr, "receptor"));
            }
            else
            {
                Reflect.setField(Reflect.field(Reflect.field(_data, noteID), "notes"), name, Reflect.field(arr, name));
            }
        }
        
        // Verify or Remove
        if (as3hx.Compat.truthy(verifyNoteSkin(noteID)))
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
    private function e_bitmapFail(e                              : Dynamic) : Void
    {
        var loader                              : Dynamic= e.currentTarget.loader;
        loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, e_bitmapFail);
        loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, e_bitmapLoad);
        
        var noteID                              : Dynamic= loader.ID;
        
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
    public static function buildFromBitmapData(bmd                              : Dynamic, import_struct                              : Dynamic) : Dynamic
    {
        var struct                              : Dynamic= NoteskinsStruct.getDefaultStruct();
        var out                              : Dynamic= { };
        var cuts                              : Dynamic= { };
        ObjectUtil.merge(struct, import_struct);
        
        if (as3hx.Compat.truthy(import_struct == null || Reflect.field(struct, "options") == null || Reflect.field(Reflect.field(struct, "options"), "grid_dim") == null || Reflect.field(struct, "blue") == null || Reflect.field(Reflect.field(struct, "blue"), "D") == null || Reflect.field(Reflect.field(Reflect.field(struct, "blue"), "D"), "c") == null))
        {
            return null;
        }
        
        var parsedCell                              : Dynamic= NoteskinsStruct.parseCellInput(Reflect.field(Reflect.field(struct, "options"), "grid_dim"), 1, 1, 20, 20);
        var img_w                              : Dynamic= bmd.width;
        var img_h                              : Dynamic= bmd.height;
        var dim_w                              : Dynamic= parsedCell[0];
        var dim_h                              : Dynamic= parsedCell[1];
        var cell_width                              : Dynamic= img_w / dim_w;
        var cell_height                              : Dynamic= img_h / dim_h;
        var cell_rotate                              : Dynamic= NoteskinsStruct.textToRotation(Reflect.field(Reflect.field(struct, "options"), "rotate"), 90);
        
        Reflect.setField(out, "_cell", [cell_width, cell_height, cell_rotate]);
        
        for (color in as3hx.Compat.iter(Reflect.fields(struct)))
        {
            if (as3hx.Compat.truthy(color == "options"))
            {
                continue;
            }
            
            for (dir in as3hx.Compat.iter(Reflect.fields(Reflect.field(struct, color))))
            {
                if (as3hx.Compat.truthy(Reflect.field(Reflect.field(Reflect.field(struct, color), dir), "c") == ""))
                {
                    continue;
                }
                
                var note_pos                              : Dynamic= NoteskinsStruct.parseCellInput(Reflect.field(Reflect.field(Reflect.field(struct, color), dir), "c"));
                
                if (as3hx.Compat.truthy(Reflect.field(out, color) == null))
                {
                    Reflect.setField(out, color, { });
                }
                
                // Position outside grid.
                if (as3hx.Compat.truthy(as3hx.Compat.parseFloat(note_pos[0]) > as3hx.Compat.parseFloat(dim_w) || as3hx.Compat.parseFloat(note_pos[1]) > as3hx.Compat.parseFloat(dim_h)))
                {
                    continue;
                }
                // Get Existing Bitmap if Cords already used.
                else if (as3hx.Compat.truthy(as3hx.Compat.field(cuts, note_pos[0] + "x" + note_pos[1]) != null))
                {
                    Reflect.setField(Reflect.field(out, color), dir, as3hx.Compat.field(cuts, note_pos[0] + "x" + note_pos[1]));
                }
                else
                {
                    var scale                              : Dynamic= RenderQuality.SUPERSAMPLE_SCALE;
                    var note_canvas                            : Dynamic= new BitmapData(Std.int(cell_width * scale), Std.int(cell_height * scale), true, 0);
                    var note_matrix                              : Dynamic= new Matrix(scale, 0, 0, scale, -note_pos[0] * cell_width * scale, -note_pos[1] * cell_height * scale);
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
    private function verifyNoteSkin(noteID                              : Dynamic) : Bool
    // Check if this noteskin has the bare minimum requirements.
    {
        
        if (as3hx.Compat.truthy(Reflect.field(_data, noteID) == null))
        {
            return false;
        }
        
        // Check Receptor
        if (as3hx.Compat.truthy(Reflect.field(Reflect.field(_data, noteID), "receptor") == null || Reflect.field(Reflect.field(Reflect.field(_data, noteID), "receptor"), "D") == null))
        {
            return false;
        }
        
        // Check Blue Note
        if (as3hx.Compat.truthy(Reflect.field(Reflect.field(Reflect.field(_data, noteID), "notes"), "blue") == null || Reflect.field(Reflect.field(Reflect.field(Reflect.field(_data, noteID), "notes"), "blue"), "D") == null))
        {
            return false;
        }
        
        // Check Missing Notes and fill from Blue
        for (asset_name in as3hx.Compat.iter(note_asset_names))
        {
            if (as3hx.Compat.truthy(Reflect.field(Reflect.field(Reflect.field(_data, noteID), "notes"), Std.string(asset_name)) == null))
            {
                Reflect.setField(Reflect.field(Reflect.field(_data, noteID), "notes"), Std.string(asset_name), Reflect.field(Reflect.field(Reflect.field(_data, noteID), "notes"), "blue"));
            }
            
            // Check Missing Directions and fill from Down
            for (direction_name in as3hx.Compat.iter(note_direction_names)) {
if (as3hx.Compat.truthy(Reflect.field(Reflect.field(Reflect.field(Reflect.field(_data, noteID), "notes"), Std.string(asset_name)), Std.string(direction_name)) == null && Reflect.field(Reflect.field(Reflect.field(Reflect.field(_data, noteID), "notes"), Std.string(asset_name)), "D") != null))
                {
                    Reflect.setField(Reflect.field(Reflect.field(Reflect.field(_data, noteID), "notes"), Std.string(asset_name)), Std.string(direction_name), Reflect.field(Reflect.field(Reflect.field(Reflect.field(_data, noteID), "notes"), Std.string(asset_name)), "D"));
                }
                
                // Fill from blue.
                if (as3hx.Compat.truthy(Reflect.field(Reflect.field(Reflect.field(Reflect.field(_data, noteID), "notes"), Std.string(asset_name)), Std.string(direction_name)) == null && Reflect.field(Reflect.field(Reflect.field(Reflect.field(_data, noteID), "notes"), "blue"), "D") != null))
                {
                    Reflect.setField(Reflect.field(Reflect.field(Reflect.field(_data, noteID), "notes"), Std.string(asset_name)), Std.string(direction_name), Reflect.field(Reflect.field(Reflect.field(Reflect.field(_data, noteID), "notes"), "blue"), "D"));
                }
            }
        }
        
        // Check Missing Receptor Directions and fill from Down
        for (receptor_direction in as3hx.Compat.iter(note_direction_names))
        {
            if (as3hx.Compat.truthy(Reflect.field(Reflect.field(Reflect.field(_data, noteID), "receptor"), Std.string(receptor_direction)) == null))
            {
                Reflect.setField(Reflect.field(Reflect.field(_data, noteID), "receptor"), Std.string(receptor_direction), Reflect.field(Reflect.field(Reflect.field(_data, noteID), "receptor"), "D"));
            }
        }
        return true;
    }
    
    public function loadCustomNoteskin() : Void
    {
        var noteskinData                              : Dynamic= LocalStore.getVariable(CUSTOM_NOTESKIN_DATA, null);
        var noteskinImport                              : Dynamic= LocalStore.getVariable(CUSTOM_NOTESKIN_IMPORT, null);
        var noteskinFilename                              : Dynamic= LocalStore.getVariable(CUSTOM_NOTESKIN_FILE, null);
        
        // Copy Data into Import Slot if coming from old version.
        if (as3hx.Compat.truthy(noteskinData != null && noteskinImport == null))
        {
            Logger.debug(this, "Storing Internal Noteskin");
            LocalStore.setVariable(CUSTOM_NOTESKIN_IMPORT, noteskinData);
        }
        
        // No Data, no Custom Noteskin
        if (as3hx.Compat.truthy(noteskinData == null))
        {
            Logger.debug(this, "No Noteskin Data");
            return;
        }
        
        // Reload External Noteskin if exist
        if (as3hx.Compat.truthy(noteskinFilename != null))
        {
            Logger.debug(this, "Reloading External Noteskin: " + noteskinFilename);
            var noteskinJSON                              : Dynamic= AirContext.readTextFile(AirContext.getAppFile(Constant.NOTESKIN_PATH).resolvePath(noteskinFilename));
            
            if (as3hx.Compat.truthy(noteskinJSON == null))
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
    
    public function loadCustomNoteskinJSON(data                              : Dynamic, noteskinID                              : Dynamic= "0") : Void
    {
        if (as3hx.Compat.truthy(data != null))
        {
            if (as3hx.Compat.truthy(noteskinID == "0"))
            {
                lastCustomNoteskin = data;
            }
            
            var obj                              : Dynamic= haxe.Json.parse(data);
            Reflect.setField(obj, "id", noteskinID);
            Reflect.setField(obj, "_hidden", true);
            Reflect.setField(obj, "notes", { });
            Reflect.setField(_data, Std.string(Reflect.field(obj, "id")), obj);
            loadNoteskinBitmap(noteskinID);
        }
        else if (as3hx.Compat.truthy(Reflect.field(_data, noteskinID) != null))
        {
            Reflect.deleteField(_data, noteskinID);
        }
    }
    
    private function get_externalNoteskins() : Array<ExternalNoteskin>
    {
        if (as3hx.Compat.truthy(_externalNoteskins == null))
        {
            loadExternalNoteskins();
        }
        
        return _externalNoteskins;
    }
    
    public function loadExternalNoteskins() : Bool
    {
        _externalNoteskins = [];
        
        var noteskinFolder                              : Dynamic= AirContext.getAppFile(Constant.NOTESKIN_PATH);
        if (as3hx.Compat.truthy(!noteskinFolder.exists || !noteskinFolder.isDirectory || noteskinFolder.isHidden))
        {
            return false;
        }
        
        var file                              : Dynamic= null;
        var fileDataJSON                              : Dynamic= null;
        var fileData                              : Dynamic= null;
        var files                              : Dynamic= noteskinFolder.getDirectoryListing();
        for (i in 0...files.length)
        {
            file = files[i];
            try
            {
                if (as3hx.Compat.truthy(file.extension != "txt"))
                {
                    continue;
                }
                
                fileDataJSON = AirContext.readTextFile(file);
                fileData = haxe.Json.parse(fileDataJSON);
                
                var extNoteskin                              : Dynamic= new ExternalNoteskin();
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
