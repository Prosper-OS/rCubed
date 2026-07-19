package classes.chart.parse;

import openfl.utils.ByteArray;

class ChartBase
{
    public var ignoreValidation                             : Dynamic= false;
    
    public var validColumnCounts                             : Dynamic= [4];  //, 5, 6, 7, 8, 9, 10];  
    
    public var COLUMNS                             : Dynamic= {
            "4" : ["L", "D", "U", "R"],
            "5" : ["L", "D", "C", "U", "R"],
            "6" : ["L", "Q", "D", "U", "W", "R"],
            "7" : ["L", "Q", "D", "C", "U", "W", "R"],
            "8" : ["L", "D", "U", "R", "Q", "W", "T", "Y"],
            "9" : ["L", "D", "U", "R", "C", "Q", "W", "T", "Y"],
            "10" : ["L", "D", "C", "U", "R", "Q", "W", "V", "T", "Y"]
        };
    
    public var data                             : Dynamic= {
            notes : []
        };
    public var charts                             : Dynamic= [];
    
    public var loaded                             : Dynamic= false;
    public var parsed                             : Dynamic= false;
    
    public function parse() : Void
    {
    }
    
    public function load(fileData                             : Dynamic, fileName                             : Dynamic= null) : Bool
    {
        return false;
    }
    
    public function getChartTimeFast(chart_index                             : Dynamic= null) : Float
    {
        return 0;
    }

    public function new()
    {
    }
}

