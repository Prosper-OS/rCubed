package classes.mp;

import classes.mp.room.MPRoom;

class MPTeam
{
    public var userCount(get, never)                             : Dynamic;

    public var isStale                             : Dynamic= false;
    
    public var room                             : Dynamic;
    
    public var uid                             : Dynamic;
    public var name                             : Dynamic= "Default Team Name";
    public var id                             : Dynamic= 0;
    public var maxUsers                             : Dynamic= 0;
    public var spectator                             : Dynamic= false;
    public var canJoin                             : Dynamic= true;
    
    public var users                             : Dynamic= [];
    public var captain                             : Dynamic;
    
    public function new(room                             : Dynamic)
    {
        this.room = room;
    }
    
    public function update(data                             : Dynamic) : Void
    {
        var temp_user                             : Dynamic= null;
        
        if (as3hx.Compat.truthy(data.uid != null))
        {
            this.uid = data.uid;
        }
        
        if (as3hx.Compat.truthy(data.id != null))
        {
            this.id = data.id;
        }
        
        if (as3hx.Compat.truthy(data.name != null))
        {
            this.name = data.name;
        }
        
        if (as3hx.Compat.truthy(data.maxUsers != null))
        {
            this.maxUsers = data.maxUsers;
        }
        
        if (as3hx.Compat.truthy(data.spectator != null))
        {
            this.spectator = data.spectator;
        }
        
        if (as3hx.Compat.truthy(data.canJoin != null))
        {
            this.canJoin = data.canJoin;
        }
        
        if (as3hx.Compat.truthy(data.usersUID != null))
        {
            this.users.length = 0;
            for (user_uid/* AS3HX WARNING could not determine type for var: user_uid exp: EField(EIdent(data),usersUID) type: null */ in as3hx.Compat.iter(data.usersUID))
            {
                temp_user = room.getUser(user_uid);
                if (as3hx.Compat.truthy(temp_user != null))
                {
                    this.users.push(temp_user);
                }
            }
            _userSort();
        }
        
        if (as3hx.Compat.truthy(data.captainUID != null))
        {
            temp_user = room.getUser(data.captainUID);
            if (as3hx.Compat.truthy(temp_user != null))
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
    
    public function addUser(user                             : Dynamic) : Void
    {
        var idx                             : Dynamic= this.users.indexOf(user);
        if (as3hx.Compat.truthy(idx == -1))
        {
            this.users.push(user);
        }
        _userSort();
    }
    
    public function removeUser(user                             : Dynamic) : Void
    {
        var idx                             : Dynamic= this.users.indexOf(user);
        if (as3hx.Compat.truthy(idx != -1))
        {
            this.users.splice(idx, 1);
        }
        _userSort();
    }
    
    public function setCaptain(user                             : Dynamic) : Void
    {
        this.captain = user;
    }
    
    public function contains(user                             : Dynamic) : Bool
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
    public static function sort(a                             : Dynamic, b                             : Dynamic) : Int
    {
        if (as3hx.Compat.truthy(a.spectator && !b.spectator))
        {
            return 1;
        }
        
        if (as3hx.Compat.truthy(!a.spectator && b.spectator))
        {
            return -1;
        }
        
        if (as3hx.Compat.truthy(a.id > b.id))
        {
            return 1;
        }
        
        return -1;
    }
}

