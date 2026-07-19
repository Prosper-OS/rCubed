package classes.chart;

import classes.chart.Note;
import classes.chart.Song;
import game.GameOptions;

class NoteMod
{
    private var song : Song;
    private var notes : Array<Note>;
    private var shuffle : Array<Dynamic>;
    private var lastChord : Dynamic;
    
    private var DIRECTIONS(default, never) : Array<Dynamic> = ["L", "D", "U", "R"];
    private var HALF_COLOR(default, never) : Dynamic = {
            red : "red",
            blue : "red",
            purple : "purple",
            yellow : "blue",
            pink : "purple",
            orange : "yellow",
            cyan : "pink",
            green : "orange",
            white : "white"
        };
    private var COLUMN_COLOR(default, never) : Array<Dynamic> = ["red", "blue", "yellow", "green"];
    
    public var options : GameOptions;
    
    public var modDark : Bool;
    public var modHidden : Bool;
    public var modMirror : Bool;
    public var modRandom : Bool;
    public var modScramble : Bool;
    public var modShuffle : Bool;
    public var modReverse : Bool;
    public var modColumnColor : Bool;
    public var modHalfTime : Bool;
    public var modNoBackground : Bool;
    public var modIsolation : Bool;
    public var modOffset : Bool;
    public var modRate : Bool;
    public var modJudgeWindow : Bool;
    
    private var reverseLastFrame : Int;
    private var reverseLastPos : Float;
    
    public function new(song : Song, options : GameOptions)
    {
        super();
        this.song = song;
        this.options = options;
        
        updateMods();
    }
    
    public function updateMods() : Void
    {
        modDark = options.modEnabled("dark");
        modHidden = options.modEnabled("hidden");
        modMirror = options.modEnabled("mirror");
        modRandom = options.modEnabled("random");
        modScramble = options.modEnabled("scramble");
        modShuffle = options.modEnabled("shuffle");
        modReverse = options.modEnabled("reverse");
        modColumnColor = options.modEnabled("columncolour");
        modHalfTime = options.modEnabled("halftime");
        modNoBackground = options.modEnabled("nobackground");
        modIsolation = options.isolation;
        modOffset = options.chartOffset != 0;
        modRate = options.songRate != 1;
        modJudgeWindow = cast(options.judgeWindow, Bool);
        
        reverseLastFrame = -1;
        reverseLastPos = -1;
    }
    
    public function start(options : GameOptions) : Void
    {
        this.options = options;
        
        updateMods();
        
        if (modShuffle)
        {
            shuffle = new Array<Dynamic>();
            for (i in 0...4)
            {
                var map : Int;
                while (Lambda.indexOf(shuffle, map = as3hx.Compat.parseInt(Math.random() * 4)) >= 0)
                {
                }
                shuffle.push(map);
            }
        }
        
        notes = song.chart.Notes;
        
        lastChord = {
                    frame : 0,
                    values : [],
                    previousValues : [],
                    notes : []
                };
    }
    
    private function valueOfDirection(direction : String) : Int
    {
        return Lambda.indexOf(DIRECTIONS, direction.charAt(0));
    }
    
    private function directionOfValue(value : Int) : String
    {
        return Std.string(DIRECTIONS[value]);
    }
    
    public static function noteModRequired(options : GameOptions) : Bool
    {
        var mod : NoteMod = new NoteMod(null, options);
        return mod.required();
    }
    
    public function required() : Bool
    {
        return modIsolation || modRandom || modScramble || modShuffle || modColumnColor || modHalfTime || modMirror || modOffset || modRate;
    }
    
    public function transformNote(index : Int) : Note
    {
        if (modIsolation)
        {
            index += options.isolationOffset;
        }
        
        if (modReverse)
        {
            index = as3hx.Compat.parseInt(notes.length - 1 - index);
            if (reverseLastFrame < 0)
            {
                reverseLastFrame = as3hx.Compat.parseInt(notes[notes.length - 1].frame - song.musicStartFrames * 2);
                reverseLastPos = notes[notes.length - 1].time - ((song.musicStartFrames * 2) / 30);
            }
        }
        
        var note : Note = notes[index];
        if (note == null)
        {
            return null;
        }
        
        var pos : Float = note.time;
        var color : String = note.color;
        var frame : Float = note.frame;
        var dir : Int = valueOfDirection(note.direction);
        
        frame -= song.musicStartFrames;
        pos -= (song.musicStartFrames / 30);
        
        if (modReverse)
        {
            frame = reverseLastFrame - frame + song.mp3Frame + 60;
            pos = reverseLastPos - pos + (song.mp3Frame + 60) / 30;
        }
        
        if (modRate)
        {
            pos /= options.songRate;
            frame /= options.songRate;
        }
        
        if (modOffset)
        {
            var goffset : Int = Math.round(options.chartOffset);
            frame += goffset;
            pos += goffset / 30;
        }
        
        if (modMirror)
        {
            dir = as3hx.Compat.parseInt(-dir + 3);
        }
        
        if (modShuffle)
        {
            dir = shuffle[dir];
        }
        
        if (modRandom || modScramble)
        {
            if (lastChord.frame != as3hx.Compat.parseInt(frame))
            {
                lastChord.frame = as3hx.Compat.parseInt(frame);
                lastChord.previousValues = lastChord.values;
                lastChord.values = [];
                lastChord.notes = [];
            }
            var value : Dynamic = lastChord.values[lastChord.notes.indexOf(note)];
            if (value != null)
            {
                dir = as3hx.Compat.parseInt(value);
            }
            else
            {
                while (lastChord.values.indexOf(dir = as3hx.Compat.parseInt(Math.random() * 4)) != -1)
                {
                }
                var i : Int = 0;
                while (i < 3 && modScramble && lastChord.previousValues.indexOf(dir) != -1)
                {
                    while (lastChord.values.indexOf(dir = as3hx.Compat.parseInt(Math.random() * 4)) != -1)
                    {
                    }
                    i++;
                }
                lastChord.values.push(dir);
                lastChord.notes.push(note);
            }
        }
        
        if (modColumnColor)
        {
            color = COLUMN_COLOR[dir % 4];
        }
        
        if (modHalfTime)
        {
            color = Reflect.field(HALF_COLOR, color) || color;
        }
        
        return new Note(directionOfValue(dir), pos, color, as3hx.Compat.parseInt(frame));
    }
    
    public function transformTotalNotes() : Int
    {
        if (notes == null)
        {
            return 0;
        }
        
        if (modIsolation)
        {
            if (options.isolationLength > 0)
            {
                return Math.min(options.isolationLength, Math.max(1, notes.length - options.isolationOffset));
            }
            else
            {
                return Math.max(1, notes.length - options.isolationOffset);
            }
        }
        return notes.length;
    }
    
    public function transformSongLength() : Float
    {
        if (notes == null || notes.length <= 0)
        {
            return 0;
        }
        
        var firstNote : Note;
        var lastNote : Note = notes[notes.length - 1];
        var time : Float = lastNote.time;
        
        if (modIsolation)
        {
            if (options.isolationLength > 0)
            {
                firstNote = notes[Math.min(notes.length - 1, options.isolationOffset)];
                lastNote = notes[Math.min(notes.length - 1, options.isolationOffset + options.isolationLength)];
                time = lastNote.time - firstNote.time;
            }
            else
            {
                firstNote = notes[Math.min(notes.length - 1, options.isolationOffset)];
                time = lastNote.time - firstNote.time;
            }
        }
        
        // Rates after everything.
        if (modRate)
        {
            time /= options.songRate;
        }
        
        return time + 1;
    }
}

