package classes.mp.room;

import classes.mp.MPSocketDataRaw;
import classes.mp.MPSocketDataText;
import classes.mp.MPTeam;
import classes.mp.MPUser;
import classes.mp.Multiplayer;
import openfl.utils.Dictionary;

class MPRoom
{
    public var playerCount(get, never)                             : Dynamic;
    public var playerCountMax(get, never)                             : Dynamic;

    public var _mp                             : Dynamic= Multiplayer.instance;
    
    public var isStale                             : Dynamic= false;
    
    public var uid                             : Dynamic;
    public var name                             : Dynamic= "Default Room Name";
    public var persist                             : Dynamic= false;
    public var type                             : Dynamic= "lobby";
    public var joinCode                             : Dynamic= "--------";
    
    public var hasPassword                             : Dynamic= false;
    public var password                             : Dynamic;
    
    public var owner                             : Dynamic;
    public var ownerName                             : Dynamic= "";
    
    public var isGame                             : Dynamic= false;
    public var maxPlayers                             : Dynamic= 2;
    
    public var users                             : Dynamic= [];
    public var userCount                             : Dynamic= 0;
    public var spectatorCount                             : Dynamic= 0;
    
    public var skillMin                             : Dynamic= -1;
    public var skillMax                             : Dynamic= -1;
    
    public var variables                             : Dynamic= { };
    public var teamCount                             : Dynamic= 0;
    public var teams                             : Dynamic= [];
    public var teams_map                             : Dynamic= new Dictionary<Dynamic, Dynamic>(true);
    
    public var teamSpectator                             : Dynamic;
    
    public function new()
    {
    }
    
    public function update(data                             : Dynamic) : Void
    {
        this.isStale = false;
        
        // Room List
        if (as3hx.Compat.truthy(data.uid != null))
        {
            this.uid = data.uid;
        }
        
        if (as3hx.Compat.truthy(data.name != null))
        {
            this.name = data.name;
        }
        
        if (as3hx.Compat.truthy(data.persist != null))
        {
            this.persist = data.persist;
        }
        
        if (as3hx.Compat.truthy(data.ownerName != null))
        {
            this.ownerName = data.ownerName;
        }
        
        if (as3hx.Compat.truthy(data.hasPassword != null))
        {
            this.hasPassword = data.hasPassword;
        }
        
        if (as3hx.Compat.truthy(data.password != null))
        {
            this.password = data.password;
        }
        
        if (as3hx.Compat.truthy(data.joinCode != null))
        {
            this.joinCode = data.joinCode;
        }
        
        if (as3hx.Compat.truthy(data.type != null))
        {
            this.type = data.type;
        }
        
        if (as3hx.Compat.truthy(data.isGame != null))
        {
            this.isGame = data.isGame;
        }
        
        if (as3hx.Compat.truthy(data.maxPlayers != null))
        {
            this.maxPlayers = data.maxPlayers;
        }
        
        if (as3hx.Compat.truthy(data.teamCount != null))
        {
            this.teamCount = data.teamCount;
        }
        
        if (as3hx.Compat.truthy(data.userCount != null))
        {
            this.userCount = data.userCount;
        }
        
        if (as3hx.Compat.truthy(data.spectatorCount != null))
        {
            this.spectatorCount = data.spectatorCount;
        }
        
        if (as3hx.Compat.truthy(data.skillMin != null))
        {
            this.skillMin = data.skillMin;
        }
        
        if (as3hx.Compat.truthy(data.skillMax != null))
        {
            this.skillMax = data.skillMax;
        }
        
        if (as3hx.Compat.truthy(data.vars != null))
        {
            this.variables = data.vars;
        }
        
        // Room Data
        if (as3hx.Compat.truthy(data.users != null))
        {
            this.users.length = 0;
            
            for (temp_user/* AS3HX WARNING could not determine type for var: temp_user exp: EField(EIdent(data),users) type: null */ in as3hx.Compat.iter(data.users))
            {
                var mp_user                             : Dynamic= _mp.getUser(temp_user.uid);
                
                if (as3hx.Compat.truthy(mp_user == null))
                {
                    mp_user = new MPUser();
                    mp_user.update(temp_user);
                    _mp.setUser(mp_user);
                }
                
                this.users.push(mp_user);
            }
            
            this.userCount = this.users.length;
        }
        
        if (as3hx.Compat.truthy(data.owner != null))
        {
            if (as3hx.Compat.truthy(data.owner > 0))
            {
                var owner_user                             : Dynamic= _mp.getUser(data.owner);
                
                if (as3hx.Compat.truthy(owner_user != null))
                {
                    owner = owner_user;
                }
            }
            else
            {
                owner = null;
            }
        }
        
        if (as3hx.Compat.truthy(data.teams != null))
        {
            _teamBatchUpdate(data.teams);
        }
        
        if (as3hx.Compat.truthy(data.teamSpectator != null))
        {
            this.teamSpectator = teams_map[data.teamSpectator];
            this.spectatorCount = teamSpectator.users.length;
        }
    }
    
    private function _teamBatchUpdate(temp_teams                             : Dynamic) : Void
    {
        var i                             : Dynamic= null;
        
        // Mark all Rooms as Stale
        i = as3hx.Compat.parseInt(teams.length - 1);
        while (as3hx.Compat.truthy(i >= 0))
        {
            teams[i].isStale = true;
            i--;
        }
        
        // Add / Update Existing Rooms
        i = as3hx.Compat.parseInt(temp_teams.length - 1);
        while (as3hx.Compat.truthy(i >= 0))
        {
            _teamUpdateDirect(temp_teams[i]);
            i--;
        }
        
        // Delete Stale Teams
        i = as3hx.Compat.parseInt(teams.length - 1);
        while (as3hx.Compat.truthy(i >= 0))
        {
            if (as3hx.Compat.truthy(teams[i].isStale))
            {
                Reflect.deleteField(teams_map, Std.string(null));
                teams.splice(i, 1);
            }
            i--;
        }
        
        teamCount = teams.length;
        
        _teamSort();
    }
    
    private function _teamUpdateDirect(team                             : Dynamic) : Void
    {
        var temp_team                             : Dynamic= teams_map[team.uid];
        
        // Existing
        if (as3hx.Compat.truthy(temp_team != null))
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
    public static function sort(a                             : Dynamic, b                             : Dynamic) : Int
    {
        if (as3hx.Compat.truthy(a.uid > b.uid))
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
    
    public function getUser(uid                             : Dynamic) : MPUser
    {
        return _mp.getUser(uid);
    }
    
    private function get_playerCount() : Float
    {
        var cnt                             : Dynamic= 0;
        var i                             : Dynamic= teams.length - 1;
        while (as3hx.Compat.truthy(i >= 0))
        {
            if (as3hx.Compat.truthy(!as3hx.Compat.field(teams, i).spectator))
            {
                cnt += as3hx.Compat.field(teams, i).users.length;
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
        for (team in as3hx.Compat.iter(teams))
        {
            team.clear();
            Reflect.deleteField(teams_map, Std.string(null));
        }
        this.teams.length = 0;
        this.teamSpectator = null;
    }
    
    public function userJoin(user                             : Dynamic) : Void
    {
        var idx                             : Dynamic= this.users.indexOf(user);
        if (as3hx.Compat.truthy(idx == -1))
        {
            this.users.push(user);
            this.userCount = this.users.length;
        }
    }
    
    public function userJoinTeam(user                             : Dynamic, teamUID                             : Dynamic, vars                             : Dynamic= null) : Void
    {
        var team                             : Dynamic= teams_map[teamUID];
        if (as3hx.Compat.truthy(team != null))
        {
            team.addUser(user);
            
            if (as3hx.Compat.truthy(team == teamSpectator))
            {
                this.spectatorCount = teamSpectator.users.length;
            }
        }
    }
    
    public function userLeave(user                             : Dynamic) : Void
    {
        var idx                             : Dynamic= this.users.indexOf(user);
        if (as3hx.Compat.truthy(idx != -1))
        {
            for (team/* AS3HX WARNING could not determine type for var: team exp: EField(EIdent(this),teams) type: null */ in as3hx.Compat.iter(this.teams))
            {
                if (as3hx.Compat.truthy(team.contains(user)))
                {
                    team.removeUser(user);
                    if (as3hx.Compat.truthy(team == teamSpectator))
                    {
                        this.spectatorCount = teamSpectator.users.length;
                    }
                }
            }
            
            this.users.splice(idx, 1);
            this.userCount = this.users.length;
        }
    }
    
    public function userLeaveTeam(user                             : Dynamic, teamUID                             : Dynamic) : Void
    {
        var team                             : Dynamic= teams_map[teamUID];
        if (as3hx.Compat.truthy(team != null))
        {
            team.removeUser(user);
            
            if (as3hx.Compat.truthy(team == teamSpectator))
            {
                this.spectatorCount = teamSpectator.users.length;
            }
        }
    }
    
    public function userTeamCaptain(user                             : Dynamic, teamUID                             : Dynamic) : Void
    {
        var team                             : Dynamic= teams_map[teamUID];
        if (as3hx.Compat.truthy(team != null))
        {
            team.setCaptain(user);
        }
    }
    
    public function modeCommand(cmd                             : Dynamic, user                             : Dynamic) : Void
    {
    }
    
    public function modeRawCommand(cmd                             : Dynamic, user                             : Dynamic) : Void
    {
    }
    
    ///////////////////////////////////////////////////////////////////////
    
    public function isPlayer(user                             : Dynamic) : Bool
    {
        if (as3hx.Compat.truthy(user == null || teams.length == 1 || Lambda.indexOf(users, user) == -1))
        {
            return false;
        }
        
        return !teamSpectator.contains(user);
    }
    
    public function isPlayerReady(user                             : Dynamic) : Bool
    {
        return false;
    }
    
    public function canUserPlaySong(user                             : Dynamic) : Bool
    {
        return true;
    }
    
    ///////////////////////////////////////////////////////////////////////
    
    public function toString() : String
    {
        return "[MPRoom uid=" + uid + ", name=" + name + "]";
    }
}

