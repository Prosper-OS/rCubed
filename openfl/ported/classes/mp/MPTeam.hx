package classes.mp;

import classes.mp.room.MPRoom;

class MPTeam
{
    public var userCount(get, never) : Float;

    public var isStale : Bool = false;
    
    public var room : MPRoom;
    
    public var uid : Int;
    public var name : String = "Default Team Name";
    public var id : Int = 0;
    public var maxUsers : Float = 0;
    public var spectator : Bool = false;
    public var canJoin : Bool = true;
    
    public var users : Array<MPUser> = [];
    public var captain : MPUser;
    
    public function new(room : MPRoom)
    {
        this.room = room;
    }
    
    public function update(data : Dynamic) : Void
    {
        var temp_user : MPUser;
        
        if (data.uid != null)
        {
            this.uid = data.uid;
        }
        
        if (data.id != null)
        {
            this.id = data.id;
        }
        
        if (data.name != null)
        {
            this.name = data.name;
        }
        
        if (data.maxUsers != null)
        {
            this.maxUsers = data.maxUsers;
        }
        
        if (data.spectator != null)
        {
            this.spectator = data.spectator;
        }
        
        if (data.canJoin != null)
        {
            this.canJoin = data.canJoin;
        }
        
        if (data.usersUID != null)
        {
            this.users.length = 0;
            for (user_uid/* AS3HX WARNING could not determine type for var: user_uid exp: EField(EIdent(data),usersUID) type: null */ in data.usersUID)
            {
                temp_user = room.getUser(user_uid);
                if (temp_user != null)
                {
                    this.users.push(temp_user);
                }
            }
            _userSort();
        }
        
        if (data.captainUID != null)
        {
            temp_user = room.getUser(data.captainUID);
            if (temp_user != null)
            {
                this.captain = temp_user;
            }
            else
            {
                this.captain = null;
            }
        }
        
        this.isStale = false;
    }
    
    public function clear() : Void
    {
        this.isStale = true;
        this.room = null;
        this.users = null;
        this.captain = null;
        this.name = null;
    }
    
    private function get_userCount() : Float
    {
        return users.length;
    }
    
    public function addUser(user : MPUser) : Void
    {
        var idx : Int = this.users.indexOf(user);
        if (idx == -1)
        {
            this.users.push(user);
        }
        _userSort();
    }
    
    public function removeUser(user : MPUser) : Void
    {
        var idx : Int = this.users.indexOf(user);
        if (idx != -1)
        {
            this.users.splice(idx, 1);
        }
        _userSort();
    }
    
    public function setCaptain(user : MPUser) : Void
    {
        this.captain = user;
    }
    
    public function contains(user : MPUser) : Bool
    {
        return this.users.indexOf(user) != -1;
    }
    
    private function _userSort() : Void
    {
        users.sort(MPUser.sort);
    }
    
    /**
     * Sort Teams compare function based on id. Spectator should always be the lowest.
     */
    public static function sort(a : MPTeam, b : MPTeam) : Int
    {
        if (a.spectator && !b.spectator)
        {
            return 1;
        }
        
        if (!a.spectator && b.spectator)
        {
            return -1;
        }
        
        if (a.id > b.id)
        {
            return 1;
        }
        
        return -1;
    }
}

