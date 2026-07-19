package game.controls;

import classes.GameNote;
import classes.GameReceptor;
import classes.HiResGameReceptor;
import classes.Noteskins;
import classes.chart.Note;
import classes.chart.Song;
import classes.ui.BoxButton;
import classes.ui.BoxSlider;
import classes.ui.Text;
import com.flashfla.utils.GameNotePool;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.MovieClip;
import openfl.events.Event;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import game.GameOptions;

class NoteBox extends GameControl
{
    public var nextNote(get, never) : Note;

    public static inline var VERTEX_X : Float = 0;
    public static inline var VERTEX_Y : Float = 1;
    
    public static inline var P_CENTER : Int = 0;
    public static var P_TOP : Int = 1 << 0;
    public static var P_LEFT : Int = 1 << 1;
    public static var P_RIGHT : Int = 1 << 2;
    public static var P_BOTTOM : Int = 1 << 3;
    private static inline var DEPTH_POSITION_FACTOR : Float = 0.30;
    private static inline var DEPTH_SCALE_FACTOR : Float = 0.16;
    
    private var _gvars : GlobalVariables = GlobalVariables.instance;
    private var _noteskins : Noteskins = Noteskins.instance;
    public var options : GameOptions;
    public var song : Song;
    
    public var scrollSpeed : Float;
    public var readahead : Float;
    public var totalNotes : Int;
    public var noteCount : Int;
    public var notePool : Dynamic;
    public var notes : Array<GameNote>;
    
    public var leftReceptor : MovieClip;
    public var downReceptor : MovieClip;
    public var upReceptor : MovieClip;
    public var rightReceptor : MovieClip;
    public var receptorArray : Array<Dynamic>;
    public var receptorTable : Dynamic = { };
    
    public var positionOffsetMax : Dynamic;
    public var receptorAlpha : Float;
    
    public var recp_colors : Array<Float>;
    public var recp_colors_enabled : Array<Bool>;
    
    public var anchorPoints : Array<Point>;
    
    public function new(song : Song, options : GameOptions, parent : DisplayObjectContainer)
    {
        super();
        if (parent != null)
        {
            parent.addChild(this);
        }
        
        this.options = options;
        this.song = song;
        
        // Create Object Pools
        if (_noteskins.data[options.noteskin] == null)
        {
            options.noteskin = 1;
        }
        
        notePool = {
                    L : { },
                    D : { },
                    U : { },
                    R : { }
                };
        
        var i : Int = 0;
        var preLoadCount : Int = 8;
        for (direction/* AS3HX WARNING could not determine type for var: direction exp: EField(EIdent(options),noteDirections) type: null */ in options.noteDirections)
        {
            for (color/* AS3HX WARNING could not determine type for var: color exp: EField(EIdent(options),noteColors) type: null */ in options.noteColors)
            {
                var pool : GameNotePool = new GameNotePool();
                
                for (i in 0...preLoadCount)
                {
                    var gameNote : GameNote = pool.addObject(new GameNote(0, direction, color, 1 * 1000, 0, options.noteskin));
                    gameNote.visible = false;
                    pool.unmarkObject(gameNote);
                    addChild(gameNote);
                }
                
                Reflect.setField(Reflect.field(notePool, Std.string(direction)), Std.string(color), pool);
            }
        }
        
        // Setup Receptors
        leftReceptor = _noteskins.getReceptor(options.noteskin, "L");
        downReceptor = _noteskins.getReceptor(options.noteskin, "D");
        upReceptor = _noteskins.getReceptor(options.noteskin, "U");
        rightReceptor = _noteskins.getReceptor(options.noteskin, "R");
        
        if (Std.is(leftReceptor, GameReceptor))
        {
            (try cast(leftReceptor, GameReceptor) catch(e:Dynamic) null).animationSpeed = options.receptorSpeed;
            (try cast(downReceptor, GameReceptor) catch(e:Dynamic) null).animationSpeed = options.receptorSpeed;
            (try cast(upReceptor, GameReceptor) catch(e:Dynamic) null).animationSpeed = options.receptorSpeed;
            (try cast(rightReceptor, GameReceptor) catch(e:Dynamic) null).animationSpeed = options.receptorSpeed;
        }
        
        addChildAt(leftReceptor, 0);
        addChildAt(downReceptor, 0);
        addChildAt(upReceptor, 0);
        addChildAt(rightReceptor, 0);
        
        // Other Stuff
        scrollSpeed = options.scrollSpeed;
        readahead = (Main.GAME_WIDTH / 300 * 1000 / scrollSpeed);
        receptorAlpha = 1.0;
        notes = [];
        noteCount = 0;
        totalNotes = song.totalNotes;
        
        // Copy Receptor Colors
        recp_colors = new Array<Float>();
        for (i in 0...options.receptorColors.length)
        {
            recp_colors[i] = options.receptorColors[i];
        }
        
        // Copy Enabled Colors
        recp_colors_enabled = new Array<Bool>();
        for (i in 0...options.enableReceptorColors.length)
        {
            recp_colors_enabled[i] = options.enableReceptorColors[i];
        }
        
        // Anchor Points
        anchorPoints = [new Point(0, 0),   // P_CENTER,  
                        new Point(0, -150),   //P_TOP  
                        new Point(-300, 0),   //P_LEFT  
                        new Point(-300, -150),   //P_TOP|P_LEFT  
                        new Point(300, 0),   //P_RIGHT  
                        new Point(300, -150),   //P_TOP|P_RIGHT  
                        new Point(0, 0),   //P_LEFT|P_RIGHT  
                        new Point(0, -150),   //P_TOP|P_LEFT|P_RIGHT  
                        new Point(0, 150),   //P_BOTTOM  
                        new Point(0, 0),   //P_TOP|P_BOTTOM  
                        new Point(-300, 150),   //P_LEFT|P_BOTTOM  
                        new Point(-300, 0),   //P_TOP|P_LEFT|P_BOTTOM  
                        new Point(300, 150),   //P_RIGHT|P_BOTTOM  
                        new Point(300, 0),   //P_TOP|P_RIGHT|P_BOTTOM  
                        new Point(0, 150),   //P_LEFT|P_RIGHT|P_BOTTOM  
                        new Point(0, 0)  //P_TOP|P_LEFT|P_RIGHT|P_BOTTOM  
            ];
    }
    
    public function spawnArrow(note : Note, current_position : Int = 0) : GameNote
    {
        var direction : String = note.direction;
        var color : String = options.getNewNoteColor(note.color);
        
        var spawnPoolRef : GameNotePool = Reflect.field(Reflect.field(notePool, direction), color);
        var gameNote : GameNote;
        
        gameNote = spawnPoolRef.getObject();
        if (gameNote != null)
        {
            gameNote.ID = noteCount++;
            gameNote.DIR = direction;
            gameNote.POSITION = (note.time + 0.5 / 30) * 1000;
            gameNote.FRAME = note.frame;
            gameNote.alpha = 1;
        }
        else
        {
            gameNote = spawnPoolRef.addObject(new GameNote(noteCount++, direction, color, (note.time + 0.5 / 30) * 1000, note.frame, options.noteskin));
            addChild(gameNote);
        }
        
        gameNote.SPAWN_PROGRESS = gameNote.POSITION - 1000;  // readahead;  
        gameNote.rotation = getReceptor(direction).rotation;
        
        if (options.noteScale != 1.0)
        {
            gameNote.scaleX = gameNote.scaleY = options.noteScale;
        }
        else if (options.modEnabled("mini") && !options.modEnabled("mini_resize") && options.noteScale == 1.0)
        {
            gameNote.scaleX = gameNote.scaleY = 0.75;
        }
        else
        {
            gameNote.scaleX = gameNote.scaleY = 1;
        }
        
        if (options.modEnabled("note_dark"))
        {
            gameNote.alpha = 0.2;
        }
        
        gameNote.visible = true;
        notes.push(gameNote);
        
        updateNotePosition(gameNote, current_position);
        
        return gameNote;
    }
    
    public function getReceptor(dir : String) : MovieClip
    {
        switch (dir)
        {
            case "L":
                return leftReceptor;
            case "D":
                return downReceptor;
            case "U":
                return upReceptor;
            case "R":
                return rightReceptor;
        }
        return null;
    }
    
    public function receptorFeedback(dir : String, score : Int) : Void
    {
        if (!options.displayReceptorAnimations)
        {
            return;
        }
        
        var receptor : MovieClip = getReceptor(dir);
        var isCustom : Bool = Std.is(receptor, GameReceptor);
        var isHiRes : Bool = Std.is(receptor, HiResGameReceptor);
        var f : Int = 2;
        var c : Int = 0;
        var e : Bool = false;
        
        switch (score)
        {
            case 100:
                f = 2;
                c = recp_colors[0];
                e = recp_colors_enabled[0];
            case 50:
                f = 2;
                c = recp_colors[1];
                e = recp_colors_enabled[1];
            case 25:
                f = 7;
                c = recp_colors[2];
                e = recp_colors_enabled[2];
            case 5:
                f = 12;
                c = recp_colors[3];
                e = recp_colors_enabled[3];
            case -5:
                f = 12;
                c = recp_colors[4];
                e = recp_colors_enabled[4];
            case -10:
                f = 12;
                c = recp_colors[5];
                e = recp_colors_enabled[5];
                
                if (!isCustom)
                {
                    e = false;
                }
            default:
                return;
        }
        
        if (isHiRes)
        {
            e = true;
        }
        
        if (!e)
        {
            return;
        }
        
        if (isHiRes)
        {
            (try cast(receptor, HiResGameReceptor) catch(e:Dynamic) null).playScoreAnimation(score, c);
        }
        else if (isCustom)
        {
            (try cast(receptor, GameReceptor) catch(e:Dynamic) null).playAnimation(c);
        }
        else
        {
            receptor.gotoAndPlay(f);
        }
    }
    
    private function get_nextNote() : Note
    {
        return (noteCount < totalNotes) ? song.getNote(noteCount) : null;
    }
    
    public function spawnNextNote(current_position : Int = 0) : GameNote
    {
        if (nextNote != null)
        {
            return spawnArrow(nextNote, current_position);
        }
        
        return null;
    }
    
    public function update(position : Int) : Void
    {
        var nextRef : Note = nextNote;
        while (nextRef && (nextRef.time + 0.5 / 30) * 1000 - position < readahead)
        {
            spawnArrow(nextRef, position);
            nextRef = nextNote;
        }
        
        if (options.modEnabled("wave"))
        {
            var waveOffset : Int = 0;
            for (receptor in receptorArray)
            {
                if (receptor.VERTEX == VERTEX_X)
                {
                    receptor.y = receptor.ORIG_Y + (Math.sin((Math.round(haxe.Timer.stamp() * 1000) + waveOffset) / 1000) * 35);
                }
                else if (receptor.VERTEX == VERTEX_Y)
                {
                    receptor.x = receptor.ORIG_X + (Math.sin((Math.round(haxe.Timer.stamp() * 1000) + waveOffset) / 1000) * 35);
                }
                waveOffset += 165;
            }
        }
        
        if (options.modEnabled("drunk"))
        {
            var drunkOffset : Int = 0;
            for (receptor in receptorArray)
            {
                receptor.rotation = receptor.ORIG_ROT + (Math.sin((Math.round(haxe.Timer.stamp() * 1000) + drunkOffset) / 1387) * 25);
                drunkOffset += 165;
            }
        }
        
        if (options.modEnabled("dizzy"))
        {
            for (receptor in receptorArray)
            {
                receptor.rotation += 12;
            }
        }
        
        if (options.modEnabled("hide"))
        {
            leftReceptor.alpha = ((leftReceptor.currentFrame == 1)) ? 0.0 : receptorAlpha;
            downReceptor.alpha = ((downReceptor.currentFrame == 1)) ? 0.0 : receptorAlpha;
            upReceptor.alpha = ((upReceptor.currentFrame == 1)) ? 0.0 : receptorAlpha;
            rightReceptor.alpha = ((rightReceptor.currentFrame == 1)) ? 0.0 : receptorAlpha;
        }
        
        for (note in notes)
        {
            updateNotePosition(note, position);
        }
    }
    
    public var updateReceptorRef : MovieClip;
    public var updateOffsetRef : Float;
    public var updateBaseOffsetRef : Float;
    public var updateDepthRef : Float;
    
    public function updateNotePosition(note : GameNote, position : Int) : Void
    {
        updateReceptorRef = getReceptor(note.DIR);
        updateOffsetRef = (note.POSITION - position) / 1000 * 300 * scrollSpeed;
        updateBaseOffsetRef = (position - note.SPAWN_PROGRESS) / (note.POSITION - note.SPAWN_PROGRESS);
        updateDepthRef = Math.max(0, Math.min(1, updateBaseOffsetRef));
        var depthEase : Float = updateDepthRef * updateDepthRef;
        
        var laneDepthScale : Float = (1 - DEPTH_POSITION_FACTOR) + (depthEase * DEPTH_POSITION_FACTOR);
        var noteDepthScale : Float = (1 - DEPTH_SCALE_FACTOR) + (depthEase * DEPTH_SCALE_FACTOR);
        var baseNoteScale : Float = 1;
        
        if (options.noteScale != 1.0)
        {
            baseNoteScale = options.noteScale;
        }
        else if (options.modEnabled("mini") && !options.modEnabled("mini_resize"))
        {
            baseNoteScale = 0.75;
        }
        
        if (updateReceptorRef.VERTEX == VERTEX_X)
        {
            note.x = updateReceptorRef.x - updateOffsetRef * updateReceptorRef.DIRECTION;
            note.y = updateReceptorRef.y * laneDepthScale;
        }
        else if (updateReceptorRef.VERTEX == VERTEX_Y)
        {
            note.y = updateReceptorRef.y - updateOffsetRef * updateReceptorRef.DIRECTION;
            note.x = updateReceptorRef.x * laneDepthScale;
        }
        
        note.scaleX = note.scaleY = baseNoteScale * noteDepthScale;
        note.alpha = 1;
        
        // Position Mods
        if (options.modEnabled("tornado"))
        {
            var tornadoOffset : Float = Math.sin(updateBaseOffsetRef * Math.PI) * (options.receptorSpacing / 2);
            if (updateReceptorRef.VERTEX == VERTEX_X)
            {
                note.y += tornadoOffset;
            }
            if (updateReceptorRef.VERTEX == VERTEX_Y)
            {
                note.x += tornadoOffset;
            }
        }
        
        // Rotation Mods
        if (options.modEnabled("rotating"))
        {
            note.rotation = (updateBaseOffsetRef * 6 * 90) + updateReceptorRef.rotation;
        }
        
        if (options.modEnabled("dizzy"))
        {
            note.rotation += 18;
        }
        
        // Alpha Mods
        // switched hidden and sudden, mods were reversed!
        if (options.modEnabled("hidden"))
        {
            note.alpha = 1 - updateBaseOffsetRef;
        }
        
        if (options.modEnabled("sudden"))
        {
            note.alpha = updateBaseOffsetRef;
        }
        
        if (options.modEnabled("blink"))
        {
            var blink_offset : Float = (1 - updateBaseOffsetRef) % 0.4;
            var blink_hidden : Bool = (blink_offset > 0.2);
            note.alpha = ((blink_hidden) ? 0 : ((note.alpha != 1 && note.alpha != 0) ? note.alpha : 1));
        }
        
        // Scale Mods
        if (options.noteScale == 1 && options.modEnabled("mini_resize") && !options.modEnabled("mini"))
        {
            note.scaleX = note.scaleY = noteDepthScale * (1 - (updateBaseOffsetRef * 0.65));
        }
    }
    
    public var removeNoteIndex : Int = 0;
    public var removeNoteRef : GameNote;
    
    public function removeNote(id : Int) : Void
    {
        var len : Float = notes.length;
        for (removeNoteIndex in 0...len)
        {
            removeNoteRef = notes[removeNoteIndex];
            if (removeNoteRef.ID == id)
            {
                Reflect.field(Reflect.field(notePool, Std.string(removeNoteRef.DIR)), Std.string(removeNoteRef.COLOR)).unmarkObject(removeNoteRef);
                removeNoteRef.visible = false;
                notes.splice(removeNoteIndex, 1);
                break;
            }
        }
    }
    
    public function reset() : Void
    {
        for (note in notes)
        {
            Reflect.field(Reflect.field(notePool, Std.string(note.DIR)), Std.string(note.COLOR)).unmarkObject(note);
            note.visible = false;
        }
        
        as3hx.Compat.setArrayLength(notes, 0);
        noteCount = 0;
    }
    
    public function resetNoteCount(value : Int) : Void
    {
        noteCount = value;
    }
    
    public function getLaneGuideRect(targetSpace : DisplayObject, output : Rectangle = null) : Rectangle
    {
        var target : DisplayObject = (targetSpace != null) ? targetSpace : this;
        var leftBounds : Rectangle = leftReceptor.getBounds(target);
        var downBounds : Rectangle = downReceptor.getBounds(target);
        var upBounds : Rectangle = upReceptor.getBounds(target);
        var rightBounds : Rectangle = rightReceptor.getBounds(target);
        var bounds : Rectangle = leftBounds.union(downBounds).union(upBounds).union(rightBounds);
        
        var leftCenter : Float = leftBounds.x + leftBounds.width / 2;
        var downCenter : Float = downBounds.x + downBounds.width / 2;
        var upCenter : Float = upBounds.x + upBounds.width / 2;
        var rightCenter : Float = rightBounds.x + rightBounds.width / 2;
        var firstCenter : Float = Math.min(Math.min(Math.min(leftCenter, downCenter), upCenter), rightCenter);
        var lastCenter : Float = Math.max(Math.max(Math.max(leftCenter, downCenter), upCenter), rightCenter);
        var laneSpacing : Float = Math.max(1, Math.abs(lastCenter - firstCenter) / 3);
        if (laneSpacing <= 1)
        {
            laneSpacing = Math.max(1, options.receptorSpacing * Math.abs(scaleX));
        }
        
        var rectX : Float = (firstCenter + lastCenter) / 2 - (laneSpacing * 2);
        var rectWidth : Float = Math.max(64, laneSpacing * 4);
        rectX = Math.min(rectX, bounds.x);
        rectWidth = Math.max(rectWidth, bounds.right - rectX);
        
        if (output == null)
        {
            output = new Rectangle();
        }
        
        output.x = rectX;
        output.y = 0;
        output.width = rectWidth;
        output.height = Main.GAME_HEIGHT;
        return output;
    }
    
    public function getLaneGuideEdges(targetSpace : DisplayObject, output : Array<Float> = null) : Array<Float>
    {
        var target : DisplayObject = (targetSpace != null) ? targetSpace : this;
        var leftBounds : Rectangle = leftReceptor.getBounds(target);
        var downBounds : Rectangle = downReceptor.getBounds(target);
        var upBounds : Rectangle = upReceptor.getBounds(target);
        var rightBounds : Rectangle = rightReceptor.getBounds(target);
        
        var c0 : Float = leftBounds.x + leftBounds.width / 2;
        var c1 : Float = downBounds.x + downBounds.width / 2;
        var c2 : Float = upBounds.x + upBounds.width / 2;
        var c3 : Float = rightBounds.x + rightBounds.width / 2;
        var tmp : Float;
        
        if (c0 > c1)
        {
            tmp = c0;c0 = c1;c1 = tmp;
        }
        if (c2 > c3)
        {
            tmp = c2;c2 = c3;c3 = tmp;
        }
        if (c0 > c2)
        {
            tmp = c0;c0 = c2;c2 = tmp;
        }
        if (c1 > c3)
        {
            tmp = c1;c1 = c3;c3 = tmp;
        }
        if (c1 > c2)
        {
            tmp = c1;c1 = c2;c2 = tmp;
        }
        
        var laneSpacing : Float = Math.max(1, (c3 - c0) / 3);
        if (laneSpacing <= 1)
        {
            laneSpacing = Math.max(1, options.receptorSpacing * Math.abs(scaleX));
        }
        
        if (output == null || output.length != 5)
        {
            output = new Array<Float>();
        }
        
        output[0] = c0 - laneSpacing * 0.5;
        output[1] = (c0 + c1) * 0.5;
        output[2] = (c1 + c2) * 0.5;
        output[3] = (c2 + c3) * 0.5;
        output[4] = c3 + laneSpacing * 0.5;
        return output;
    }
    
    public function position() : Void
    {
        var anchor : Point;
        var data : Dynamic = _noteskins.getInfo(options.noteskin);
        var rotation : Float = data.rotation;
        var gap : Int = options.receptorSpacing;
        var noteScale : Float = options.noteScale;
        
        // User-defined note scale
        if (noteScale != 1)
        {
            if (noteScale < 0.1)
            {
                noteScale = 0.1;
            }
            // min
            else if (noteScale > 3.0)
            {
                noteScale = 3.0;
            }  // max  
            gap *= as3hx.Compat.parseInt(noteScale);
        }
        else if (options.modEnabled("mini") && !options.modEnabled("mini_resize"))
        {
            gap *= 0.75;
        }
        
        var _sw0_ = (options.scrollDirection);        

        switch (_sw0_)
        {
            case "down":
                anchor = anchorPoints[P_BOTTOM];
                
                leftReceptor.x = gap * -1.5;
                leftReceptor.y = anchor.y;
                leftReceptor.rotation = rotation;
                leftReceptor.VERTEX = VERTEX_Y;
                leftReceptor.DIRECTION = 1;
                
                downReceptor.x = gap * -0.5;
                downReceptor.y = anchor.y;
                downReceptor.rotation = 0;
                downReceptor.VERTEX = VERTEX_Y;
                downReceptor.DIRECTION = 1;
                
                upReceptor.x = gap * 0.5;
                upReceptor.y = anchor.y;
                upReceptor.rotation = rotation * 2;
                upReceptor.VERTEX = VERTEX_Y;
                upReceptor.DIRECTION = 1;
                
                rightReceptor.x = gap * 1.5;
                rightReceptor.y = anchor.y;
                rightReceptor.rotation = rotation * -1;
                rightReceptor.VERTEX = VERTEX_Y;
                rightReceptor.DIRECTION = 1;
                
                receptorArray = [leftReceptor, downReceptor, upReceptor, rightReceptor];
                positionOffsetMax = {
                            min_x : -150,
                            max_x : 150,
                            min_y : -150,
                            max_y : 50
                        };
            
            case "right":
                anchor = anchorPoints[P_RIGHT];
                
                leftReceptor.x = anchor.x;
                leftReceptor.y = gap * 1.5;
                leftReceptor.rotation = rotation;
                leftReceptor.VERTEX = VERTEX_X;
                leftReceptor.DIRECTION = 1;
                
                downReceptor.x = anchor.x;
                downReceptor.y = gap * 0.5;
                downReceptor.rotation = 0;
                downReceptor.VERTEX = VERTEX_X;
                downReceptor.DIRECTION = 1;
                
                upReceptor.x = anchor.x;
                upReceptor.y = gap * -0.5;
                upReceptor.rotation = rotation * 2;
                upReceptor.VERTEX = VERTEX_X;
                upReceptor.DIRECTION = 1;
                
                rightReceptor.x = anchor.x;
                rightReceptor.y = gap * -1.5;
                rightReceptor.rotation = rotation * -1;
                rightReceptor.VERTEX = VERTEX_X;
                rightReceptor.DIRECTION = 1;
                
                receptorArray = [upReceptor, rightReceptor, leftReceptor, downReceptor];
                positionOffsetMax = {
                            min_x : -150,
                            max_x : 50,
                            min_y : -120,
                            max_y : 120
                        };
            
            case "left":
                anchor = anchorPoints[P_LEFT];
                
                leftReceptor.x = anchor.x;
                leftReceptor.y = gap * 1.5;
                leftReceptor.rotation = rotation;
                leftReceptor.VERTEX = VERTEX_X;
                leftReceptor.DIRECTION = -1;
                
                downReceptor.x = anchor.x;
                downReceptor.y = gap * 0.5;
                downReceptor.rotation = 0;
                downReceptor.VERTEX = VERTEX_X;
                downReceptor.DIRECTION = -1;
                
                upReceptor.x = anchor.x;
                upReceptor.y = gap * -0.5;
                upReceptor.rotation = rotation * 2;
                upReceptor.VERTEX = VERTEX_X;
                upReceptor.DIRECTION = -1;
                
                rightReceptor.x = anchor.x;
                rightReceptor.y = gap * -1.5;
                rightReceptor.rotation = rotation * -1;
                rightReceptor.VERTEX = VERTEX_X;
                rightReceptor.DIRECTION = -1;
                
                receptorArray = [upReceptor, rightReceptor, leftReceptor, downReceptor];
                positionOffsetMax = {
                            min_x : -50,
                            max_x : 150,
                            min_y : -120,
                            max_y : 120
                        };
            
            case "split":
                anchor = anchorPoints[P_BOTTOM];
                
                downReceptor.x = gap * -0.5;
                downReceptor.y = anchor.y;
                downReceptor.rotation = 0;
                downReceptor.VERTEX = VERTEX_Y;
                downReceptor.DIRECTION = 1;
                
                upReceptor.x = gap * 0.5;
                upReceptor.y = anchor.y;
                upReceptor.rotation = rotation * 2;
                upReceptor.VERTEX = VERTEX_Y;
                upReceptor.DIRECTION = 1;
                
                anchor = anchorPoints[P_TOP];
                
                leftReceptor.x = gap * -1.5;
                leftReceptor.y = anchor.y;
                leftReceptor.rotation = rotation;
                leftReceptor.VERTEX = VERTEX_Y;
                leftReceptor.DIRECTION = -1;
                
                rightReceptor.x = gap * 1.5;
                rightReceptor.y = anchor.y;
                rightReceptor.rotation = rotation * -1;
                rightReceptor.VERTEX = VERTEX_Y;
                rightReceptor.DIRECTION = -1;
                
                receptorArray = [leftReceptor, downReceptor, upReceptor, rightReceptor];
                positionOffsetMax = {
                            min_x : -150,
                            max_x : 150,
                            min_y : -50,
                            max_y : 50
                        };
            
            case "split_down":
                anchor = anchorPoints[P_TOP];
                
                downReceptor.x = gap * -0.5;
                downReceptor.y = anchor.y;
                downReceptor.rotation = 0;
                downReceptor.VERTEX = VERTEX_Y;
                downReceptor.DIRECTION = -1;
                
                upReceptor.x = gap * 0.5;
                upReceptor.y = anchor.y;
                upReceptor.rotation = rotation * 2;
                upReceptor.VERTEX = VERTEX_Y;
                upReceptor.DIRECTION = -1;
                
                anchor = anchorPoints[P_BOTTOM];
                
                leftReceptor.x = gap * -1.5;
                leftReceptor.y = anchor.y;
                leftReceptor.rotation = rotation;
                leftReceptor.VERTEX = VERTEX_Y;
                leftReceptor.DIRECTION = 1;
                
                rightReceptor.x = gap * 1.5;
                rightReceptor.y = anchor.y;
                rightReceptor.rotation = rotation * -1;
                rightReceptor.VERTEX = VERTEX_Y;
                rightReceptor.DIRECTION = 1;
                
                receptorArray = [leftReceptor, downReceptor, upReceptor, rightReceptor];
                positionOffsetMax = {
                            min_x : -150,
                            max_x : 150,
                            min_y : -50,
                            max_y : 50
                        };
            
            case "plus":
                anchor = anchorPoints[P_CENTER];
                
                leftReceptor.x = gap * -0.5;
                leftReceptor.y = anchor.y;
                leftReceptor.rotation = rotation;
                leftReceptor.VERTEX = VERTEX_X;
                leftReceptor.DIRECTION = 1;
                
                downReceptor.x = anchor.x;
                downReceptor.y = gap * 0.5;
                downReceptor.rotation = 0;
                downReceptor.VERTEX = VERTEX_Y;
                downReceptor.DIRECTION = -1;
                
                upReceptor.x = anchor.x;
                upReceptor.y = gap * -0.5;
                upReceptor.rotation = rotation * 2;
                upReceptor.VERTEX = VERTEX_Y;
                upReceptor.DIRECTION = 1;
                
                rightReceptor.x = gap * 0.5;
                rightReceptor.y = anchor.y;
                rightReceptor.rotation = rotation * -1;
                rightReceptor.VERTEX = VERTEX_X;
                rightReceptor.DIRECTION = -1;
                
                receptorArray = [upReceptor, rightReceptor, downReceptor, leftReceptor];
                positionOffsetMax = {
                            min_x : -150,
                            max_x : 150,
                            min_y : -150,
                            max_y : 150
                        };
            default:
                anchor = anchorPoints[P_TOP];
                
                leftReceptor.x = gap * -1.5;
                leftReceptor.y = anchor.y;
                leftReceptor.rotation = rotation;
                leftReceptor.VERTEX = VERTEX_Y;
                leftReceptor.DIRECTION = -1;
                
                downReceptor.x = gap * -0.5;
                downReceptor.y = anchor.y;
                downReceptor.rotation = 0;
                downReceptor.VERTEX = VERTEX_Y;
                downReceptor.DIRECTION = -1;
                
                upReceptor.x = gap * 0.5;
                upReceptor.y = anchor.y;
                upReceptor.rotation = rotation * 2;
                upReceptor.VERTEX = VERTEX_Y;
                upReceptor.DIRECTION = -1;
                
                rightReceptor.x = gap * 1.5;
                rightReceptor.y = anchor.y;
                rightReceptor.rotation = rotation * -1;
                rightReceptor.VERTEX = VERTEX_Y;
                rightReceptor.DIRECTION = -1;
                
                receptorArray = [leftReceptor, downReceptor, upReceptor, rightReceptor];
                positionOffsetMax = {
                            min_x : -150,
                            max_x : 150,
                            min_y : -50,
                            max_y : 150
                        };
        }
        
        for (item in receptorArray)
        {
            item.ORIG_X = item.x;
            item.ORIG_Y = item.y;
            item.ORIG_ROT = item.rotation;
        }
        
        if (options.modEnabled("rotate_cw"))
        {
            leftReceptor.rotation += 90;
            downReceptor.rotation += 90;
            upReceptor.rotation += 90;
            rightReceptor.rotation += 90;
        }
        if (options.modEnabled("rotate_ccw"))
        {
            leftReceptor.rotation -= 90;
            downReceptor.rotation -= 90;
            upReceptor.rotation -= 90;
            rightReceptor.rotation -= 90;
        }
        
        if (options.noteScale != 1.0)
        {
            downReceptor.scaleX = downReceptor.scaleY = leftReceptor.scaleX = leftReceptor.scaleY = upReceptor.scaleX = upReceptor.scaleY = rightReceptor.scaleX = rightReceptor.scaleY = options.noteScale;
        }
        
        if (options.modEnabled("mini") && !options.modEnabled("mini_resize") && options.noteScale == 1.0)
        {
            downReceptor.scaleX = downReceptor.scaleY = leftReceptor.scaleX = leftReceptor.scaleY = upReceptor.scaleX = upReceptor.scaleY = rightReceptor.scaleX = rightReceptor.scaleY = 0.75;
        }
        
        if (options.modEnabled("mini_resize") && !options.modEnabled("mini") && options.noteScale == 1.0)
        {
            downReceptor.scaleX = downReceptor.scaleY = leftReceptor.scaleX = leftReceptor.scaleY = upReceptor.scaleX = upReceptor.scaleY = rightReceptor.scaleX = rightReceptor.scaleY = 0.5;
        }
        
        if (options.modEnabled("dark"))
        {
            receptorAlpha = 0.3;
        }
        
        leftReceptor.alpha = downReceptor.alpha = upReceptor.alpha = rightReceptor.alpha = receptorAlpha;
    }
    
    override private function get_id() : String
    {
        return GameLayoutManager.LAYOUT_RECEPTORS;
    }
    
    override private function get_editorFlags() : Int
    {
        return as3hx.Compat.parseInt(FLAG_POSITION | FLAG_ROTATE | FLAG_SCALE);
    }
    
    override public function getEditorInterface() : GameControlEditor
    {
        var self : NoteBox = this;
        
        var out : GameControlEditor = super.getEditorInterface();
        
        new Text(out, 10, out.cy, _lang.string("editor_component_rotation_x"));
        var sliderRotate : BoxSlider = new BoxSlider(out, 10 + 3, out.cy + 20, editorWidth - 56, 10, e_changeHandler);
        sliderRotate.minValue = -180;
        sliderRotate.maxValue = 180;
        
        var sliderRotateDisplay : Text = new Text(out, 10, out.cy, "0?");
        sliderRotateDisplay.setAreaParams(editorWidth - 52, 22, "right");
        var sliderRotateReset : BoxButton = new BoxButton(out, editorWidth - 36, out.cy + 5, 22, 22, "R", 12, e_changeHandler);
        
        sliderRotate.slideValue = this.rotationX;
        sliderRotateDisplay.text = Math.round(sliderRotate.slideValue) + "?";
        
        out.cy += 42;
        
        var e_changeHandler : Event->Void = function(e : Event) : Void
        {
            if (e.target == sliderRotate)
            {
                var rotateSnap : Int = as3hx.Compat.parseInt(Math.round(sliderRotate.slideValue / 5) * 5);
                sliderRotateDisplay.text = Math.round(rotateSnap) + "?";
                Reflect.setField(editorLayout, "rotationX", Math.round(rotateSnap));
                self.rotationX = Reflect.field(editorLayout, "rotationX");
            }
            else if (e.target == sliderRotateReset)
            {
                sliderRotate.slideValue = 0;
                sliderRotateDisplay.text = Math.round(sliderRotate.slideValue) + "?";
                Reflect.setField(editorLayout, "rotationX", 0);
                self.rotationX = Reflect.field(editorLayout, "rotationX");
            }
        }
        
        return out;
    }
}

