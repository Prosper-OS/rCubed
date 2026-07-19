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
    private static var e_changeHandler                    : Dynamic;
    public var nextNote(get, never)                       : Dynamic;

    public static inline var VERTEX_X                       : Dynamic= 0;
    public static inline var VERTEX_Y                       : Dynamic= 1;
    
    public static inline var P_CENTER                       : Dynamic= 0;
    public static var P_TOP                       : Dynamic= 1 << 0;
    public static var P_LEFT                       : Dynamic= 1 << 1;
    public static var P_RIGHT                       : Dynamic= 1 << 2;
    public static var P_BOTTOM                       : Dynamic= 1 << 3;
    private static inline var DEPTH_POSITION_FACTOR                       : Dynamic= 0.30;
    private static inline var DEPTH_SCALE_FACTOR                       : Dynamic= 0.16;
    
    private var _gvars                       : Dynamic= GlobalVariables.instance;
    private var _noteskins                       : Dynamic= Noteskins.instance;
    public var options                       : Dynamic;
    public var song                       : Dynamic;
    
    public var scrollSpeed                       : Dynamic;
    public var readahead                       : Dynamic;
    public var totalNotes                       : Dynamic;
    public var noteCount                       : Dynamic;
    public var notePool                       : Dynamic;
    public var notes                       : Dynamic;
    
    public var leftReceptor                       : Dynamic;
    public var downReceptor                       : Dynamic;
    public var upReceptor                       : Dynamic;
    public var rightReceptor                       : Dynamic;
    public var receptorArray                       : Dynamic;
    public var receptorTable                       : Dynamic= { };
    
    public var positionOffsetMax                       : Dynamic;
    public var receptorAlpha                       : Dynamic;
    
    public var recp_colors                       : Dynamic;
    public var recp_colors_enabled                       : Dynamic;
    
    public var anchorPoints                       : Dynamic;
    
    public function new(song                       : Dynamic, options                       : Dynamic, parent                       : Dynamic)
    {
        super();
        if (as3hx.Compat.truthy(parent != null))
        {
            parent.addChild(this);
        }
        
        this.options = options;
        this.song = song;
        
        // Create Object Pools
        if (as3hx.Compat.truthy(_noteskins.data[options.noteskin] == null))
        {
            options.noteskin = 1;
        }
        
        notePool = {
                    L : { },
                    D : { },
                    U : { },
                    R : { }
                };
        
        var i                       : Dynamic= 0;
        var preLoadCount                       : Dynamic= 8;
        for (direction/* AS3HX WARNING could not determine type for var: direction exp: EField(EIdent(options),noteDirections) type: null */ in as3hx.Compat.iter(options.noteDirections))
        {
            for (color/* AS3HX WARNING could not determine type for var: color exp: EField(EIdent(options),noteColors) type: null */ in as3hx.Compat.iter(options.noteColors))
            {
                var pool                       : Dynamic= new GameNotePool();
                
                for (i in 0...preLoadCount)
                {
                    var gameNote                       : Dynamic= pool.addObject(new GameNote(0, direction, color, 1 * 1000, 0, options.noteskin));
                    gameNote.visible = false;
                    pool.unmarkObject(gameNote);
                    addChild(gameNote);
                }
                
                Reflect.setField(as3hx.Compat.field(notePool, direction), Std.string(color), pool);
            }
        }
        
        // Setup Receptors
        leftReceptor = _noteskins.getReceptor(options.noteskin, "L");
        downReceptor = _noteskins.getReceptor(options.noteskin, "D");
        upReceptor = _noteskins.getReceptor(options.noteskin, "U");
        rightReceptor = _noteskins.getReceptor(options.noteskin, "R");
        
        if (as3hx.Compat.truthy(Std.is(leftReceptor, GameReceptor)))
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
    
    public function spawnArrow(note                       : Dynamic, current_position                       : Dynamic= 0) : GameNote
    {
        var direction                       : Dynamic= note.direction;
        var color                       : Dynamic= options.getNewNoteColor(note.color);
        
        var spawnPoolRef                       : Dynamic= Reflect.field(Reflect.field(notePool, direction), color);
        var gameNote                       : Dynamic= null;
        
        gameNote = spawnPoolRef.getObject();
        if (as3hx.Compat.truthy(gameNote != null))
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
        
        if (as3hx.Compat.truthy(options.noteScale != 1.0))
        {
            gameNote.scaleX = gameNote.scaleY = options.noteScale;
        }
        else if (as3hx.Compat.truthy(options.modEnabled("mini") && !options.modEnabled("mini_resize") && options.noteScale == 1.0))
        {
            gameNote.scaleX = gameNote.scaleY = 0.75;
        }
        else
        {
            gameNote.scaleX = gameNote.scaleY = 1;
        }
        
        if (as3hx.Compat.truthy(options.modEnabled("note_dark")))
        {
            gameNote.alpha = 0.2;
        }
        
        gameNote.visible = true;
        notes.push(gameNote);
        
        updateNotePosition(gameNote, current_position);
        
        return gameNote;
    }
    
    public function getReceptor(dir                       : Dynamic) : MovieClip
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
    
    public function receptorFeedback(dir                       : Dynamic, score                       : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(!options.displayReceptorAnimations))
        {
            return;
        }
        
        var receptor                       : Dynamic= getReceptor(dir);
        var isCustom                       : Dynamic= Std.is(receptor, GameReceptor);
        var isHiRes                       : Dynamic= Std.is(receptor, HiResGameReceptor);
        var f                       : Dynamic= 2;
        var c                       : Dynamic= 0;
        var e                       : Dynamic= false;
        
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
                
                if (as3hx.Compat.truthy(!isCustom))
                {
                    e = false;
                }
            default:
                return;
        }
        
        if (as3hx.Compat.truthy(isHiRes))
        {
            e = true;
        }
        
        if (as3hx.Compat.truthy(!e))
        {
            return;
        }
        
        if (as3hx.Compat.truthy(isHiRes))
        {
            (try cast(receptor, HiResGameReceptor) catch(e:Dynamic) null).playScoreAnimation(score, c);
        }
        else if (as3hx.Compat.truthy(isCustom))
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
    
    public function spawnNextNote(current_position                       : Dynamic= 0) : GameNote
    {
        if (as3hx.Compat.truthy(nextNote != null))
        {
            return spawnArrow(nextNote, current_position);
        }
        
        return null;
    }
    
    public function update(position                       : Dynamic) : Void
    {
        var nextRef                       : Dynamic= nextNote;
        while (as3hx.Compat.truthy(nextRef && (nextRef.time + 0.5 / 30) * 1000 - position < readahead))
        {
            spawnArrow(nextRef, position);
            nextRef = nextNote;
        }
        
        if (as3hx.Compat.truthy(options.modEnabled("wave")))
        {
            var waveOffset                       : Dynamic= 0;
            for (receptor in as3hx.Compat.iter(receptorArray))
            {
                if (as3hx.Compat.truthy(receptor.VERTEX == VERTEX_X))
                {
                    receptor.y = receptor.ORIG_Y + (Math.sin((Math.round(haxe.Timer.stamp() * 1000) + waveOffset) / 1000) * 35);
                }
                else if (as3hx.Compat.truthy(receptor.VERTEX == VERTEX_Y))
                {
                    receptor.x = receptor.ORIG_X + (Math.sin((Math.round(haxe.Timer.stamp() * 1000) + waveOffset) / 1000) * 35);
                }
                waveOffset += 165;
            }
        }
        
        if (as3hx.Compat.truthy(options.modEnabled("drunk")))
        {
            var drunkOffset                       : Dynamic= 0;
            for (receptor in as3hx.Compat.iter(receptorArray))
            {
                receptor.rotation = receptor.ORIG_ROT + (Math.sin((Math.round(haxe.Timer.stamp() * 1000) + drunkOffset) / 1387) * 25);
                drunkOffset += 165;
            }
        }
        
        if (as3hx.Compat.truthy(options.modEnabled("dizzy")))
        {
            for (receptor in as3hx.Compat.iter(receptorArray))
            {
                receptor.rotation += 12;
            }
        }
        
        if (as3hx.Compat.truthy(options.modEnabled("hide")))
        {
            leftReceptor.alpha = ((leftReceptor.currentFrame == 1)) ? 0.0 : receptorAlpha;
            downReceptor.alpha = ((downReceptor.currentFrame == 1)) ? 0.0 : receptorAlpha;
            upReceptor.alpha = ((upReceptor.currentFrame == 1)) ? 0.0 : receptorAlpha;
            rightReceptor.alpha = ((rightReceptor.currentFrame == 1)) ? 0.0 : receptorAlpha;
        }
        
        for (note in as3hx.Compat.iter(notes))
        {
            updateNotePosition(note, position);
        }
    }
    
    public var updateReceptorRef                       : Dynamic;
    public var updateOffsetRef                       : Dynamic;
    public var updateBaseOffsetRef                       : Dynamic;
    public var updateDepthRef                       : Dynamic;
    
    public function updateNotePosition(note                       : Dynamic, position                       : Dynamic) : Void
    {
        updateReceptorRef = getReceptor(note.DIR);
        updateOffsetRef = (note.POSITION - position) / 1000 * 300 * scrollSpeed;
        updateBaseOffsetRef = (position - note.SPAWN_PROGRESS) / (note.POSITION - note.SPAWN_PROGRESS);
        updateDepthRef = Math.max(0, Math.min(1, updateBaseOffsetRef));
        var depthEase                       : Dynamic= updateDepthRef * updateDepthRef;
        
        var laneDepthScale                       : Dynamic= (1 - DEPTH_POSITION_FACTOR) + (depthEase * DEPTH_POSITION_FACTOR);
        var noteDepthScale                       : Dynamic= (1 - DEPTH_SCALE_FACTOR) + (depthEase * DEPTH_SCALE_FACTOR);
        var baseNoteScale                       : Dynamic= 1;
        
        if (as3hx.Compat.truthy(options.noteScale != 1.0))
        {
            baseNoteScale = options.noteScale;
        }
        else if (as3hx.Compat.truthy(options.modEnabled("mini") && !options.modEnabled("mini_resize")))
        {
            baseNoteScale = 0.75;
        }
        
        if (as3hx.Compat.truthy(updateReceptorRef.VERTEX == VERTEX_X))
        {
            note.x = updateReceptorRef.x - updateOffsetRef * updateReceptorRef.DIRECTION;
            note.y = updateReceptorRef.y * laneDepthScale;
        }
        else if (as3hx.Compat.truthy(updateReceptorRef.VERTEX == VERTEX_Y))
        {
            note.y = updateReceptorRef.y - updateOffsetRef * updateReceptorRef.DIRECTION;
            note.x = updateReceptorRef.x * laneDepthScale;
        }
        
        note.scaleX = note.scaleY = baseNoteScale * noteDepthScale;
        note.alpha = 1;
        
        // Position Mods
        if (as3hx.Compat.truthy(options.modEnabled("tornado")))
        {
            var tornadoOffset                       : Dynamic= Math.sin(updateBaseOffsetRef * Math.PI) * (options.receptorSpacing / 2);
            if (as3hx.Compat.truthy(updateReceptorRef.VERTEX == VERTEX_X))
            {
                note.y += tornadoOffset;
            }
            if (as3hx.Compat.truthy(updateReceptorRef.VERTEX == VERTEX_Y))
            {
                note.x += tornadoOffset;
            }
        }
        
        // Rotation Mods
        if (as3hx.Compat.truthy(options.modEnabled("rotating")))
        {
            note.rotation = (updateBaseOffsetRef * 6 * 90) + updateReceptorRef.rotation;
        }
        
        if (as3hx.Compat.truthy(options.modEnabled("dizzy")))
        {
            note.rotation += 18;
        }
        
        // Alpha Mods
        // switched hidden and sudden, mods were reversed!
        if (as3hx.Compat.truthy(options.modEnabled("hidden")))
        {
            note.alpha = 1 - updateBaseOffsetRef;
        }
        
        if (as3hx.Compat.truthy(options.modEnabled("sudden")))
        {
            note.alpha = updateBaseOffsetRef;
        }
        
        if (as3hx.Compat.truthy(options.modEnabled("blink")))
        {
            var blink_offset                       : Dynamic= (1 - updateBaseOffsetRef) % 0.4;
            var blink_hidden                       : Dynamic= (blink_offset > 0.2);
            note.alpha = ((blink_hidden) ? 0 : ((note.alpha != 1 && note.alpha != 0) ? note.alpha : 1));
        }
        
        // Scale Mods
        if (as3hx.Compat.truthy(options.noteScale == 1 && options.modEnabled("mini_resize") && !options.modEnabled("mini")))
        {
            note.scaleX = note.scaleY = noteDepthScale * (1 - (updateBaseOffsetRef * 0.65));
        }
    }
    
    public var removeNoteIndex                       : Dynamic= 0;
    public var removeNoteRef                       : Dynamic;
    
    public function removeNote(id                       : Dynamic) : Void
    {
        var len                       : Dynamic= notes.length;
        for (removeNoteIndex in 0...len)
        {
            removeNoteRef = notes[removeNoteIndex];
            if (as3hx.Compat.truthy(removeNoteRef.ID == id))
            {
                Reflect.field(as3hx.Compat.field(notePool, removeNoteRef.DIR), Std.string(removeNoteRef.COLOR)).unmarkObject(removeNoteRef);
                removeNoteRef.visible = false;
                notes.splice(removeNoteIndex, 1);
                break;
            }
        }
    }
    
    public function reset() : Void
    {
        for (note in as3hx.Compat.iter(notes))
        {
            Reflect.field(as3hx.Compat.field(notePool, note.DIR), Std.string(note.COLOR)).unmarkObject(note);
            note.visible = false;
        }
        
        as3hx.Compat.setArrayLength(notes, 0);
        noteCount = 0;
    }
    
    public function resetNoteCount(value                       : Dynamic) : Void
    {
        noteCount = value;
    }
    
    public function getLaneGuideRect(targetSpace                       : Dynamic, output                       : Dynamic= null) : Rectangle
    {
        var target                       : Dynamic= (targetSpace != null) ? targetSpace : this;
        var leftBounds                       : Dynamic= leftReceptor.getBounds(target);
        var downBounds                       : Dynamic= downReceptor.getBounds(target);
        var upBounds                       : Dynamic= upReceptor.getBounds(target);
        var rightBounds                       : Dynamic= rightReceptor.getBounds(target);
        var bounds                       : Dynamic= leftBounds.union(downBounds).union(upBounds).union(rightBounds);
        
        var leftCenter                       : Dynamic= leftBounds.x + leftBounds.width / 2;
        var downCenter                       : Dynamic= downBounds.x + downBounds.width / 2;
        var upCenter                       : Dynamic= upBounds.x + upBounds.width / 2;
        var rightCenter                       : Dynamic= rightBounds.x + rightBounds.width / 2;
        var firstCenter                       : Dynamic= Math.min(Math.min(Math.min(leftCenter, downCenter), upCenter), rightCenter);
        var lastCenter                       : Dynamic= Math.max(Math.max(Math.max(leftCenter, downCenter), upCenter), rightCenter);
        var laneSpacing                       : Dynamic= Math.max(1, Math.abs(lastCenter - firstCenter) / 3);
        if (as3hx.Compat.truthy(laneSpacing <= 1))
        {
            laneSpacing = Math.max(1, options.receptorSpacing * Math.abs(scaleX));
        }
        
        var rectX                       : Dynamic= (firstCenter + lastCenter) / 2 - (laneSpacing * 2);
        var rectWidth                       : Dynamic= Math.max(64, laneSpacing * 4);
        rectX = Math.min(rectX, bounds.x);
        rectWidth = Math.max(rectWidth, bounds.right - rectX);
        
        if (as3hx.Compat.truthy(output == null))
        {
            output = new Rectangle();
        }
        
        output.x = rectX;
        output.y = 0;
        output.width = rectWidth;
        output.height = Main.GAME_HEIGHT;
        return output;
    }
    
    public function getLaneGuideEdges(targetSpace                       : Dynamic, output                       : Dynamic= null) : Array<Float>
    {
        var target                       : Dynamic= (targetSpace != null) ? targetSpace : this;
        var leftBounds                       : Dynamic= leftReceptor.getBounds(target);
        var downBounds                       : Dynamic= downReceptor.getBounds(target);
        var upBounds                       : Dynamic= upReceptor.getBounds(target);
        var rightBounds                       : Dynamic= rightReceptor.getBounds(target);
        
        var c0                       : Dynamic= leftBounds.x + leftBounds.width / 2;
        var c1                       : Dynamic= downBounds.x + downBounds.width / 2;
        var c2                       : Dynamic= upBounds.x + upBounds.width / 2;
        var c3                       : Dynamic= rightBounds.x + rightBounds.width / 2;
        var tmp                       : Dynamic= null;
        
        if (as3hx.Compat.truthy(c0 > c1))
        {
            tmp = c0;c0 = c1;c1 = tmp;
        }
        if (as3hx.Compat.truthy(c2 > c3))
        {
            tmp = c2;c2 = c3;c3 = tmp;
        }
        if (as3hx.Compat.truthy(c0 > c2))
        {
            tmp = c0;c0 = c2;c2 = tmp;
        }
        if (as3hx.Compat.truthy(c1 > c3))
        {
            tmp = c1;c1 = c3;c3 = tmp;
        }
        if (as3hx.Compat.truthy(c1 > c2))
        {
            tmp = c1;c1 = c2;c2 = tmp;
        }
        
        var laneSpacing                       : Dynamic= Math.max(1, (c3 - c0) / 3);
        if (as3hx.Compat.truthy(laneSpacing <= 1))
        {
            laneSpacing = Math.max(1, options.receptorSpacing * Math.abs(scaleX));
        }
        
        if (as3hx.Compat.truthy(output == null || output.length != 5))
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
        var anchor                       : Dynamic= null;
        var data                       : Dynamic= _noteskins.getInfo(options.noteskin);
        var rotation                       : Dynamic= data.rotation;
        var gap                       : Dynamic= options.receptorSpacing;
        var noteScale                       : Dynamic= options.noteScale;
        
        // User-defined note scale
        if (as3hx.Compat.truthy(noteScale != 1))
        {
            if (as3hx.Compat.truthy(noteScale < 0.1))
            {
                noteScale = 0.1;
            }
            // min
            else if (as3hx.Compat.truthy(noteScale > 3.0))
            {
                noteScale = 3.0;
            }  // max  
            gap *= as3hx.Compat.parseInt(noteScale);
        }
        else if (as3hx.Compat.truthy(options.modEnabled("mini") && !options.modEnabled("mini_resize")))
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
        
        for (item in as3hx.Compat.iter(receptorArray))
        {
            item.ORIG_X = item.x;
            item.ORIG_Y = item.y;
            item.ORIG_ROT = item.rotation;
        }
        
        if (as3hx.Compat.truthy(options.modEnabled("rotate_cw")))
        {
            leftReceptor.rotation += 90;
            downReceptor.rotation += 90;
            upReceptor.rotation += 90;
            rightReceptor.rotation += 90;
        }
        if (as3hx.Compat.truthy(options.modEnabled("rotate_ccw")))
        {
            leftReceptor.rotation -= 90;
            downReceptor.rotation -= 90;
            upReceptor.rotation -= 90;
            rightReceptor.rotation -= 90;
        }
        
        if (as3hx.Compat.truthy(options.noteScale != 1.0))
        {
            downReceptor.scaleX = downReceptor.scaleY = leftReceptor.scaleX = leftReceptor.scaleY = upReceptor.scaleX = upReceptor.scaleY = rightReceptor.scaleX = rightReceptor.scaleY = options.noteScale;
        }
        
        if (as3hx.Compat.truthy(options.modEnabled("mini") && !options.modEnabled("mini_resize") && options.noteScale == 1.0))
        {
            downReceptor.scaleX = downReceptor.scaleY = leftReceptor.scaleX = leftReceptor.scaleY = upReceptor.scaleX = upReceptor.scaleY = rightReceptor.scaleX = rightReceptor.scaleY = 0.75;
        }
        
        if (as3hx.Compat.truthy(options.modEnabled("mini_resize") && !options.modEnabled("mini") && options.noteScale == 1.0))
        {
            downReceptor.scaleX = downReceptor.scaleY = leftReceptor.scaleX = leftReceptor.scaleY = upReceptor.scaleX = upReceptor.scaleY = rightReceptor.scaleX = rightReceptor.scaleY = 0.5;
        }
        
        if (as3hx.Compat.truthy(options.modEnabled("dark")))
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
        return as3hx.Compat.parseInt(GameControl.FLAG_POSITION | GameControl.FLAG_ROTATE | GameControl.FLAG_SCALE);
    }
    
    override public function getEditorInterface() : GameControlEditor
    {
        var self                       : Dynamic= this;
        
        var out                       : Dynamic= super.getEditorInterface();
        
        new Text(out, 10, out.cy, _lang.string("editor_component_rotation_x"));
        var sliderRotate                       : Dynamic= new BoxSlider(out, 10 + 3, out.cy + 20, editorWidth - 56, 10, e_changeHandler);
        sliderRotate.minValue = -180;
        sliderRotate.maxValue = 180;
        
        var sliderRotateDisplay                       : Dynamic= new Text(out, 10, out.cy, "0?");
        sliderRotateDisplay.setAreaParams(editorWidth - 52, 22, "right");
        var sliderRotateReset                       : Dynamic= new BoxButton(out, editorWidth - 36, out.cy + 5, 22, 22, "R", 12, e_changeHandler);
        
        sliderRotate.slideValue = as3hx.Compat.parseFloat(as3hx.Compat.orValue(Reflect.field(this, "rotationX"), 0));
        sliderRotateDisplay.text = Math.round(sliderRotate.slideValue) + "?";
        
        out.cy += 42;
        
        e_changeHandler = function(e                       : Dynamic) : Void
        {
            if (as3hx.Compat.truthy(e.target == sliderRotate))
            {
                var rotateSnap                       : Dynamic= as3hx.Compat.parseInt(Math.round(sliderRotate.slideValue / 5) * 5);
                sliderRotateDisplay.text = Math.round(rotateSnap) + "?";
                Reflect.setField(editorLayout, "rotationX", Math.round(rotateSnap));
                Reflect.setField(self, "rotationX", Reflect.field(editorLayout, "rotationX"));
            }
            else if (as3hx.Compat.truthy(e.target == sliderRotateReset))
            {
                sliderRotate.slideValue = 0;
                sliderRotateDisplay.text = Math.round(sliderRotate.slideValue) + "?";
                Reflect.setField(editorLayout, "rotationX", 0);
                Reflect.setField(self, "rotationX", Reflect.field(editorLayout, "rotationX"));
            }
        }
        
        return out;
    }
}

