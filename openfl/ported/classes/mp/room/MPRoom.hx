package classes.mp.room;

import classes.mp.MPSocketDataRaw;
import classes.mp.MPSocketDataText;
import classes.mp.MPTeam;
import classes.mp.MPUser;
import classes.mp.Multiplayer;
import openfl.utils.Dictionary;

class MPRoom
{
    public var playerCount(get, never) : Float;
    public var playerCountMax(get, never) : Float;

    private static var _mp : Multiplayer = Multiplayer.instance;
    
    public var isStale : Bool = false;
    
    public var uid : Int;
    public var name : String = "Default Room Name";
    public var persist : Bool = false;
    public var type : String = "lobby";
    public var joinCode : String = "--------";
    
    public var hasPassword : Bool = false;
    public var password : String;
    
    public var owner : MPUser;
    public var ownerName : String = "";
    
    public var isGame : Bool = false;
    public var maxPlayers : Int = 2;
    
    public var users : Array<MPUser> = [];
    public var userCount : Int = 0;
    public var spectatorCount : Int = 0;
    
    public var skillMin : Float = -1;
    public var skillMax : Float = -1;
    
    public var variables : Dynamic = { };
    public var teamCount : Float = 0;
    public var teams : Array<MPTeam> = [];
    public var teams_map : Dictionary<Dynamic, Dynamic> = new Dictionary<Dynamic, Dynamic>(true);
    
    public var teamSpectator : MPTeam;
    
    public function new()
    {
    }
    
    public function update(data : Dynamic) : Void
    {
        this.isStale = false;
        
        // Room List
        if (data.uid != null)
        {
            this.uid = data.uid;
        }
        
        if (data.name != null)
        {
            this.name = data.name;
        }
        
        if (data.persist != null)
        {
            this.persist = data.persist;
        }
        
        if (data.ownerName != null)
        {
            this.ownerName = data.ownerName;
        }
        
        if (data.hasPassword != null)
        {
            this.hasPassword = data.hasPassword;
        }
        
        if (data.password != null)
        {
            this.password = data.password;
        }
        
        if (data.joinCode != null)
        {
            this.joinCode = data.joinCode;
        }
        
        if (data.type != null)
        {
            this.type = data.type;
        }
        
        if (data.isGame != null)
        {
            this.isGame = data.isGame;
        }
        
        if (data.maxPlayers != null)
        {
            this.maxPlayers = data.maxPlayers;
        }
        
        if (data.teamCount != null)
        {
            this.teamCount = data.teamCount;
        }
        
        if (data.userCount != null)
        {
            this.userCount = data.userCount;
        }
        
        if (data.spectatorCount != null)
        {
            this.spectatorCount = data.spectatorCount;
        }
        
        if (data.skillMin != null)
        {
            this.skillMin = data.skillMin;
        }
        
        if (data.skillMax != null)
        {
            this.skillMax = data.skillMax;
        }
        
        if (data.vars != null)
        {
            this.variables = data.vars;
        }
        
        // Room Data
        if (data.users != null)
        {
            this.users.length = 0;
            
            for (temp_user/* AS3HX WARNING could not determine type for var: temp_user exp: EField(EIdent(data),users) type: null */ in data.users)
            {
                var mp_user : MPUser = _mp.getUser(temp_user.uid);
                
                if (mp_user == null)
                {
                    mp_user = new MPUser();
                    mp_user.update(temp_user);
                    _mp.setUser(mp_user);
                }
                
                this.users.push(mp_user);
            }
            
            this.userCount = this.users.length;
        }
        
        if (data.owner != null)
        {
            if (data.owner > 0)
            {
                var owner_user : MPUser = _mp.getUser(data.owner);
                
                if (owner_user != null)
                {
                    owner = owner_user;
                }
            }
            else
            {
                owner = null;
            }
        }
        
        if (data.teams != null)
        {
            _teamBatchUpdate(data.teams);
        }
        
        if (data.teamSpectator != null)
        {
            this.teamSpectator = teams_map[data.teamSpectator];
            this.spectatorCount = teamSpectator.users.length;
        }
    }
    
    private function _teamBatchUpdate(temp_teams : Array<Dynamic>) : Void
    {
        var i : Int;
        
        // Mark all Rooms as Stale
        i = as3hx.Compat.parseInt(teams.length - 1);
        while (i >= 0)
        {
            teams[i].isStale = true;
            i--;
        }
        
        // Add / Update Existing Rooms
        i = as3hx.Compat.parseInt(temp_teams.length - 1);
        while (i >= 0)
        {
            _teamUpdateDirect(temp_teams[i]);
            i--;
        }
        
        // Delete Stale Teams
        i = as3hx.Compat.parseInt(teams.length - 1);
        while (i >= 0)
        {
            if (teams[i].isStale)
            {
                Reflect.deleteField(teams_map, Std.string(null));
                teams.splice(i, 1);
            }
            i--;
        }
        
        teamCount = teams.length;
        
        _teamSort();
    }
    
    private function _teamUpdateDirect(team : Dynamic) : Void
    {
        var temp_team : MPTeam = teams_map[team.uid];
        
        // Existing
        if (temp_team != null)
        {
            temp_team.update(team);
        }
        // New
        else
        {
            
            {
                temp_team = new MPTeam(this);
                temp_team.update(team);
                this.teams.push(temp_team);
                this.teams_map[temp_team.uid] = temp_team;
            }
        }
    }
    
    private function _teamSort() : Void
    {
        teams.sort(MPTeam.sort);
    }
    
    /**
     * Sort Rooms compare function based on uid. uid starts at 0 for the Lobby and increases for every room created.
     * uid are unique and can't be the same.
     * Used in `_roomSort`.
     */
    public static function sort(a : MPRoom, b : MPRoom) : Int
    {
        if (a.uid > b.uid)
        {
            return 1;
        }
        
        return -1;
    }
    
    public function onJoin() : Void
    {
    }
    
    public function onLeave() : Void
    {
    }
    
    public function getUser(uid : Int) : MPUser
    {
        return _mp.getUser(uid);
    }
    
    private function get_playerCount() : Float
    {
        var cnt : Float = 0;
        var i : Float = teams.length - 1;
        while (i >= 0)
        {
            if (!Reflect.field(teams, Std.string(i)).spectator)
            {
                cnt += Reflect.field(teams, Std.string(i)).users.length;
            }
            i--;
        }
        return cnt;
    }
    
    private function get_playerCountMax() : Float
    {
        return maxPlayers * (teams.length - 1);
    }
    
    public function clear() : Void
    {
        this.clearExtra();
        this.teams_map = null;
        this.teams = null;
        this.users = null;
    }
    
    /**
     * Clear extra data not required for the room list view.
     */
    public function clearExtra() : Void
    {
        this.variables = null;
        this.users.length = 0;
        
        // Clear Teams
        for (team in teams)
        {
            team.clear();
            Reflect.deleteField(teams_map, Std.string(null));
        }
        this.teams.length = 0;
        this.teamSpectator = null;
    }
    
    public function userJoin(user : MPUser) : Void
    {
        var idx : Int = this.users.indexOf(user);
        if (idx == -1)
        {
            this.users.push(user);
            this.userCount = this.users.length;
        }
    }
    
    public function userJoinTeam(user : MPUser, teamUID : Int, vars : Dynamic = null) : Void
    {
        var team : MPTeam = teams_map[teamUID];
        if (team != null)
        {
            team.addUser(user);
            
            if (team == teamSpectator)
            {
                this.spectatorCount = teamSpectator.users.length;
            }
        }
    }
    
    public function userLeave(user : MPUser) : Void
    {
        var idx : Int = this.users.indexOf(user);
        if (idx != -1)
        {
            for (team/* AS3HX WARNING could not determine type for var: team exp: EField(EIdent(this),teams) type: null */ in this.teams)
            {
                if (team.contains(user))
                {
                    team.removeUser(user);
                    if (team == teamSpectator)
                    {
                        this.spectatorCount = teamSpectator.users.length;
                    }
                }
            }
            
            this.users.splice(idx, 1);
            this.userCount = this.users.length;
        }
    }
    
    public function userLeaveTeam(user : MPUser, teamUID : Int) : Void
    {
        var team : MPTeam = teams_map[teamUID];
        if (team != null)
        {
            team.removeUser(user);
            
            if (team == teamSpectator)
            {
                this.spectatorCount = teamSpectator.users.length;
            }
        }
    }
    
    public function userTeamCaptain(user : MPUser, teamUID : Int) : Void
    {
        var team : MPTeam = teams_map[teamUID];
        if (team != null)
        {
            team.setCaptain(user);
        }
    }
    
    public function modeCommand(cmd : MPSocketDataText, user : MPUser) : Void
    {
    }
    
    public function modeRawCommand(cmd : MPSocketDataRaw, user : MPUser) : Void
    {
    }
    
    ///////////////////////////////////////////////////////////////////////
    
    public function isPlayer(user : MPUser) : Bool
    {
        if (user == null || teams.length == 1 || Lambda.indexOf(users, user) == -1)
        {
            return false;
        }
        
        return !teamSpectator.contains(user);
    }
    
    public function isPlayerReady(user : MPUser) : Bool
    {
        return false;
    }
    
    public function canUserPlaySong(user : MPUser) : Bool
    {
        return true;
    }
    
    ///////////////////////////////////////////////////////////////////////
    
    public function toString() : String
    {
        return "[MPRoom uid=" + uid + ", name=" + name + "]";
    }
}

