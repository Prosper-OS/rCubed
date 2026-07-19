package classes.mp;


class MPUser
{
    public var nameHTML(get, never) : String;
    public var userLabel(get, never) : String;
    public var userLabelHTML(get, never) : String;

    private static var _gvars : GlobalVariables = GlobalVariables.instance;
    
    public var isStale : Bool = false;
    
    public var uid : Int;
    public var variables : Dynamic = { };
    public var permissions : MPUserPermissions = new MPUserPermissions();
    
    public var sid : Int;
    public var name : String;
    public var avatarURL : String;
    public var skillRating : Float = 0;
    
    // Private Variables
    public var blockList : Array<Dynamic> = [];
    
    private var _nameHTML : String;
    private var _userLabel : String;
    private var _userLabelHTML : String;
    
    
    public function update(data : Dynamic) : Void
    {
        if (data.uid != null)
        {
            this.uid = data.uid;
        }
        
        if (data.sid != null)
        {
            this.sid = data.sid;
        }
        
        if (data.permissions != null)
        {
            this.permissions.admin = data.permissions.admin;
            this.permissions.mod = data.permissions.mod;
        }
        
        if (data.name != null)
        {
            this.name = data.name;
        }
        
        if (data.avatar != null)
        {
            this.avatarURL = data.avatar;
        }
        
        if (data.variables != null)
        {
            this.variables = data.variables;
        }
        
        if (data.skillRating != null)
        {
            this.skillRating = data.skillRating;
        }
        
        if (data.blockList != null)
        {
            this.blockList = data.blockList;
        }
        
        buildUserLabels();
        
        this.isStale = false;
    }
    
    /**
     * Messy, but works.
     */
    private function buildUserLabels() : Void
    {
        var prefixS : String = "";
        var prefixH : String = "";
        
        var suffixS : String = "";
        var suffixH : String = "";
        
        if (skillRating >= 255)
        {
            prefixS += "[DEV] ";
            prefixH += "<font color=\"#d85454\">[DEV]</font> ";
        }
        else
        {
            prefixS += "[" + skillRating + "] ";
            prefixH += "<font color=\"" + _gvars.getDivisionColor(skillRating) + "\">[" + skillRating + "]</font> ";
        }
        
        if (permissions.admin)
        {
            prefixH += "<font color=\"" + MPColors.NAME_ADMIN + "\">";
            suffixH += "</font>";
            _nameHTML = "<font color=\"" + MPColors.NAME_ADMIN + "\">" + name + "</font>";
        }
        else if (permissions.mod)
        {
            prefixH += "<font color=\"" + MPColors.NAME_MOD + "\">";
            suffixH += "</font>";
            _nameHTML = "<font color=\"" + MPColors.NAME_MOD + "\">" + name + "</font>";
        }
        else
        {
            _nameHTML = "<font color=\"" + MPColors.NAME_USER + "\">" + name + "</font>";
        }
        
        // suffixS += " [" + uid + "]";
        // suffixH += " [" + uid + "]";
        
        _userLabel = prefixS + name + suffixS;
        _userLabelHTML = prefixH + name + suffixH;
    }
    
    
    private function get_nameHTML() : String
    {
        return _nameHTML;
    }
    
    private function get_userLabel() : String
    {
        return _userLabel;
    }
    
    private function get_userLabelHTML() : String
    {
        return _userLabelHTML;
    }
    
    public function getVariable(key : String) : Dynamic
    {
        return Reflect.field(variables, key);
    }
    
    /**
     * Sort Users compare function based on permissions, skill ratings, then name.
     */
    public static function sort(a : MPUser, b : MPUser) : Int
    // Admins First
    {
        
        if (a.permissions.admin && b.permissions.admin)
        {
            return as3hx.Compat.parseInt(b.skillRating - a.skillRating);
        }
        else if (a.permissions.admin && !b.permissions.admin)
        {
            return -1;
        }
        else if (!a.permissions.admin && b.permissions.admin)
        {
            return 1;
        }
        
        // Mod Second
        if (a.permissions.mod && b.permissions.mod)
        {
            return as3hx.Compat.parseInt(b.skillRating - a.skillRating);
        }
        else if (a.permissions.mod && !b.permissions.mod)
        {
            return -1;
        }
        else if (!a.permissions.mod && b.permissions.mod)
        {
            return 1;
        }
        
        // User Third
        if (b.skillRating == a.skillRating)
        {
            return b.name.localeCompare(a.name);
        }
        
        return as3hx.Compat.parseInt(b.skillRating - a.skillRating);
    }
    
    public function toString() : String
    {
        return "[MPUser uid=" + uid + ", name=" + name + ", _userLabel=" + _userLabel + "]";
    }

    public function new()
    {
    }
}

