package classes.chart;

import classes.SongInfo;
import classes.chart.parse.*;

class NoteChart
{
    /** Legacy Mode */
    public static inline var FFR_LEGACY : String = "ChartFFRSWF";
    
    /** SWF MP3 + Beatbox Extraction */
    public static inline var FFR_MP3 : String = "ChartFFRMP3";
    
    public var type : String;
    public var Notes : Array<Note> = [];
    public var chartData : Dynamic;
    public var framerate : Int = 60;
    
    public function new(inData : Dynamic = null, framerate : Int = 60)
    {
        this.chartData = inData;
        this.framerate = framerate;
    }
    
    /**
     * Provides a static interface to access the correct parsing engine needed for the chart.
     *
     * @param	type		Chart Type
     * @param	inData		Chart Data
     * @param	framerate	(Optional) Frame rate to use.
     *
     * @return	NoteChart of the type expected.
     */
    
    public static function parseChart(type : String, songInfo : SongInfo, inData : Dynamic, framerate : Int = 60) : NoteChart
    {
        switch (type)
        {
            case FFR_LEGACY:
                return new ChartFFRLegacy(songInfo, inData, 30);
        }
        
        return null;
    }
    
    /**
     * Basic toString method.
     *
     * @return String representation of the notechart.
     */
    public function toString(type : String = null) : String
    {
        if (Notes.length == 0)
        {
            return "No Notes...";
        }
        
        var returnVal : String = "";
        var note : Note = Notes[0];
        
        // Build Output
        for (i in 0...Notes.length)
        {
            note = Notes[i];
            returnVal += ((i + 1) + "\t\tF: " + (note.frame) + "\t\tD: " + note.direction + "\t\tC: " + note.color + "\r");
        }
        return returnVal;
    }
}

