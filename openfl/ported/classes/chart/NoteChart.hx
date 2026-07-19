package classes.chart;

import classes.SongInfo;
import classes.chart.parse.*;

class NoteChart
{
    /** Legacy Mode */
    public static inline var FFR_LEGACY                             : Dynamic= "ChartFFRSWF";
    
    /** SWF MP3 + Beatbox Extraction */
    public static inline var FFR_MP3                             : Dynamic= "ChartFFRMP3";
    
    public var type                             : Dynamic;
    public var Notes                             : Dynamic= [];
    public var chartData                             : Dynamic;
    public var framerate                             : Dynamic= 60;
    
    public function new(inData                             : Dynamic= null, framerate                             : Dynamic= 60)
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
    
    public static function parseChart(type                             : Dynamic, songInfo                             : Dynamic, inData                             : Dynamic, framerate                             : Dynamic= 60) : NoteChart
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
    public function toString(type                             : Dynamic= null) : String
    {
        if (as3hx.Compat.truthy(Notes.length == 0))
        {
            return "No Notes...";
        }
        
        var returnVal                             : Dynamic= "";
        var note                             : Dynamic= Notes[0];
        
        // Build Output
        for (i in 0...Notes.length)
        {
            note = Notes[i];
            returnVal += ((i + 1) + "\t\tF: " + (note.frame) + "\t\tD: " + note.direction + "\t\tC: " + note.color + "\r");
        }
        return returnVal;
    }
}

