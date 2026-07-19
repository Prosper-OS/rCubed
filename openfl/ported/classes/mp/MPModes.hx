package classes.mp;

import classes.Language;

class MPModes
{
    private static var _lang                             : Dynamic= Language.instance;
    
    public static function getTeamModes() : Array<Dynamic>
    {
        return [{
            data : "ffa",
            label : _lang.stringSimple("mp_room_team_type_ffa")
        }, 
        {
            data : "team",
            label : _lang.stringSimple("mp_room_team_type_team")
        }
    ];
    }
    
    public static function getMaxPlayers() : Array<Dynamic>
    {
        var out                             : Dynamic= [];
        for (i in 1...10)
        {
            out[out.length] = i;
        }
        return out;
    }
    
    public static function getTeams() : Array<Dynamic>
    {
        var out                             : Dynamic= [];
        for (i in 2...5)
        {
            out[out.length] = i;
        }
        return out;
    }
    
    public static function getTeamMaxPlayers() : Array<Dynamic>
    {
        var out                             : Dynamic= [];
        for (i in 1...5)
        {
            out[out.length] = i;
        }
        return out;
    }

    public function new()
    {
    }
}

