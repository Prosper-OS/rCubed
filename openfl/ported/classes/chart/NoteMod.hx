package classes.chart;

import classes.chart.Note;
import classes.chart.Song;
import game.GameOptions;

class NoteMod
{
    private var song                             : Dynamic;
    private var notes                             : Dynamic;
    private var shuffle                             : Dynamic;
    private var lastChord                             : Dynamic;
    
    private var DIRECTIONS(default, never)                             : Dynamic= ["L", "D", "U", "R"];
    private var HALF_COLOR(default, never)                             : Dynamic= {
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
    private var COLUMN_COLOR(default, never)                             : Dynamic= ["red", "blue", "yellow", "green"];
    
    public var options                             : Dynamic;
    
    public var modDark                             : Dynamic;
    public var modHidden                             : Dynamic;
    public var modMirror                             : Dynamic;
    public var modRandom                             : Dynamic;
    public var modScramble                             : Dynamic;
    public var modShuffle                             : Dynamic;
    public var modReverse                             : Dynamic;
    public var modColumnColor                             : Dynamic;
    public var modHalfTime                             : Dynamic;
    public var modNoBackground                             : Dynamic;
    public var modIsolation                             : Dynamic;
    public var modOffset                             : Dynamic;
    public var modRate                             : Dynamic;
    public var modJudgeWindow                             : Dynamic;
    
    private var reverseLastFrame                             : Dynamic;
    private var reverseLastPos                             : Dynamic;
    
    public function new(song                             : Dynamic, options                             : Dynamic)
    {
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
    
    public function start(options                             : Dynamic) : Void
    {
        this.options = options;
        
        updateMods();
        
        if (as3hx.Compat.truthy(modShuffle))
        {
            shuffle = new Array<Dynamic>();
            for (i in 0...4)
            {
                var map                             : Dynamic= null;
                while (as3hx.Compat.truthy(Lambda.indexOf(shuffle, map = as3hx.Compat.parseInt(Math.random() * 4)) >= 0))
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
    
    private function valueOfDirection(direction                             : Dynamic) : Int
    {
        return Lambda.indexOf(DIRECTIONS, direction.charAt(0));
    }
    
    private function directionOfValue(value                             : Dynamic) : String
    {
        return Std.string(DIRECTIONS[value]);
    }
    
    public static function noteModRequired(options                             : Dynamic) : Bool
    {
        var mod                             : Dynamic= new NoteMod(null, options);
        return mod.required();
    }
    
    public function required() : Bool
    {
        return modIsolation || modRandom || modScramble || modShuffle || modColumnColor || modHalfTime || modMirror || modOffset || modRate;
    }
    
    public function transformNote(index                             : Dynamic) : Note
    {
        if (as3hx.Compat.truthy(modIsolation))
        {
            index += options.isolationOffset;
        }
        
        if (as3hx.Compat.truthy(modReverse))
        {
            index = as3hx.Compat.parseInt(notes.length - 1 - index);
            if (as3hx.Compat.truthy(reverseLastFrame < 0))
            {
                reverseLastFrame = as3hx.Compat.parseInt(notes[as3hx.Compat.parseInt(notes.length - 1)].frame - song.musicStartFrames * 2);
                reverseLastPos = notes[as3hx.Compat.parseInt(notes.length - 1)].time - ((song.musicStartFrames * 2) / 30);
            }
        }
        
        var note                           : Dynamic= notes[as3hx.Compat.parseInt(index)];
        if (as3hx.Compat.truthy(note == null))
        {
            return null;
        }
        
        var pos                             : Dynamic= note.time;
        var color                             : Dynamic= note.color;
        var frame                             : Dynamic= note.frame;
        var dir                             : Dynamic= valueOfDirection(note.direction);
        
        frame -= song.musicStartFrames;
        pos -= (song.musicStartFrames / 30);
        
        if (as3hx.Compat.truthy(modReverse))
        {
            frame = reverseLastFrame - frame + song.mp3Frame + 60;
            pos = reverseLastPos - pos + (song.mp3Frame + 60) / 30;
        }
        
        if (as3hx.Compat.truthy(modRate))
        {
            pos /= options.songRate;
            frame /= options.songRate;
        }
        
        if (as3hx.Compat.truthy(modOffset))
        {
            var goffset                             : Dynamic= Math.round(options.chartOffset);
            frame += goffset;
            pos += goffset / 30;
        }
        
        if (as3hx.Compat.truthy(modMirror))
        {
            dir = as3hx.Compat.parseInt(-dir + 3);
        }
        
        if (as3hx.Compat.truthy(modShuffle))
        {
            dir = shuffle[dir];
        }
        
        if (as3hx.Compat.truthy(modRandom || modScramble))
        {
            if (as3hx.Compat.truthy(lastChord.frame != as3hx.Compat.parseInt(frame)))
            {
                lastChord.frame = as3hx.Compat.parseInt(frame);
                lastChord.previousValues = lastChord.values;
                lastChord.values = [];
                lastChord.notes = [];
            }
            var value                             : Dynamic= lastChord.values[lastChord.notes.indexOf(note)];
            if (as3hx.Compat.truthy(value != null))
            {
                dir = as3hx.Compat.parseInt(value);
            }
            else
            {
                while (as3hx.Compat.truthy(lastChord.values.indexOf(dir = as3hx.Compat.parseInt(Math.random() * 4)) != -1))
                {
                }
                var i                             : Dynamic= 0;
                while (as3hx.Compat.truthy(i < 3 && modScramble && lastChord.previousValues.indexOf(dir) != -1))
                {
                    while (as3hx.Compat.truthy(lastChord.values.indexOf(dir = as3hx.Compat.parseInt(Math.random() * 4)) != -1))
                    {
                    }
                    i++;
                }
                lastChord.values.push(dir);
                lastChord.notes.push(note);
            }
        }
        
        if (as3hx.Compat.truthy(modColumnColor))
        {
            color = COLUMN_COLOR[as3hx.Compat.parseInt(dir % 4)];
        }
        
        if (as3hx.Compat.truthy(modHalfTime))
        {
            color = as3hx.Compat.orValue(Reflect.field(HALF_COLOR, color), color);
        }
        
        return new Note(directionOfValue(dir), pos, color, as3hx.Compat.parseInt(frame));
    }
    
    public function transformTotalNotes() : Int
    {
        if (as3hx.Compat.truthy(notes == null))
        {
            return 0;
        }
        
        if (as3hx.Compat.truthy(modIsolation))
        {
            if (as3hx.Compat.truthy(options.isolationLength > 0))
            {
                return as3hx.Compat.parseInt(Math.min(options.isolationLength, Math.max(1, notes.length - options.isolationOffset)));
            }
            else
            {
                return as3hx.Compat.parseInt(Math.max(1, notes.length - options.isolationOffset));
            }
        }
        return notes.length;
    }
    
    public function transformSongLength() : Float
    {
        if (as3hx.Compat.truthy(notes == null || notes.length <= 0))
        {
            return 0;
        }
        
        var firstNote                             : Dynamic= null;
        var lastNote                             : Dynamic= notes[as3hx.Compat.parseInt(notes.length - 1)];
        var time                             : Dynamic= lastNote.time;
        
        if (as3hx.Compat.truthy(modIsolation))
        {
            if (as3hx.Compat.truthy(options.isolationLength > 0))
            {
                firstNote = notes[as3hx.Compat.parseInt(Math.min(notes.length - 1, options.isolationOffset))];
                lastNote = notes[as3hx.Compat.parseInt(Math.min(notes.length - 1, options.isolationOffset + options.isolationLength))];
                time = lastNote.time - firstNote.time;
            }
            else
            {
                firstNote = notes[as3hx.Compat.parseInt(Math.min(notes.length - 1, options.isolationOffset))];
                time = lastNote.time - firstNote.time;
            }
        }
        
        // Rates after everything.
        if (as3hx.Compat.truthy(modRate))
        {
            time /= options.songRate;
        }
        
        return time + 1;
    }
}

