package classes.mp;


class MPUser
{
    public var nameHTML(get, never)                             : Dynamic;
    public var userLabel(get, never)                             : Dynamic;
    public var userLabelHTML(get, never)                             : Dynamic;

    private static var _gvars                             : Dynamic= GlobalVariables.instance;
    
    public var isStale                             : Dynamic= false;
    
    public var uid                             : Dynamic;
    public var variables                             : Dynamic= { };
    public var permissions                             : Dynamic= new MPUserPermissions();
    
    public var sid                             : Dynamic;
    public var name                             : Dynamic;
    public var avatarURL                             : Dynamic;
    public var skillRating                             : Dynamic= 0;
    
    // Private Variables
    public var blockList                             : Dynamic= [];
    
    private var _nameHTML                             : Dynamic;
    private var _userLabel                             : Dynamic;
    private var _userLabelHTML                             : Dynamic;
    
    
    public function update(data                             : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(data.uid != null))
        {
            this.uid = data.uid;
        }
        
        if (as3hx.Compat.truthy(data.sid != null))
        {
            this.sid = data.sid;
        }
        
        if (as3hx.Compat.truthy(data.permissions != null))
        {
            this.permissions.admin = data.permissions.admin;
            this.permissions.mod = data.permissions.mod;
        }
        
        if (as3hx.Compat.truthy(data.name != null))
        {
            this.name = data.name;
        }
        
        if (as3hx.Compat.truthy(data.avatar != null))
        {
            this.avatarURL = data.avatar;
        }
        
        if (as3hx.Compat.truthy(data.variables != null))
        {
            this.variables = data.variables;
        }
        
        if (as3hx.Compat.truthy(data.skillRating != null))
        {
            this.skillRating = data.skillRating;
        }
        
        if (as3hx.Compat.truthy(data.blockList != null))
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
        var prefixS                             : Dynamic= "";
        var prefixH                             : Dynamic= "";
        
        var suffixS                             : Dynamic= "";
        var suffixH                             : Dynamic= "";
        
        if (as3hx.Compat.truthy(skillRating >= 255))
        {
            prefixS += "[DEV] ";
            prefixH += "<font color=\"#d85454\">[DEV]</font> ";
        }
        else
        {
            prefixS += "[" + skillRating + "] ";
            prefixH += "<font color=\"" + _gvars.getDivisionColor(skillRating) + "\">[" + skillRating + "]</font> ";
        }
        
        if (as3hx.Compat.truthy(permissions.admin))
        {
            prefixH += "<font color=\"" + MPColors.NAME_ADMIN + "\">";
            suffixH += "</font>";
            _nameHTML = "<font color=\"" + MPColors.NAME_ADMIN + "\">" + name + "</font>";
        }
        else if (as3hx.Compat.truthy(permissions.mod))
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
    
    public function getVariable(key                             : Dynamic) : Dynamic
    {
        return Reflect.field(variables, key);
    }
    
    /**
     * Sort Users compare function based on permissions, skill ratings, then name.
     */
    public static function sort(a                             : Dynamic, b                             : Dynamic) : Int
    // Admins First
    {
        
        if (as3hx.Compat.truthy(a.permissions.admin && b.permissions.admin))
        {
            return as3hx.Compat.parseInt(b.skillRating - a.skillRating);
        }
        else if (as3hx.Compat.truthy(a.permissions.admin && !b.permissions.admin))
        {
            return -1;
        }
        else if (as3hx.Compat.truthy(!a.permissions.admin && b.permissions.admin))
        {
            return 1;
        }
        
        // Mod Second
        if (as3hx.Compat.truthy(a.permissions.mod && b.permissions.mod))
        {
            return as3hx.Compat.parseInt(b.skillRating - a.skillRating);
        }
        else if (as3hx.Compat.truthy(a.permissions.mod && !b.permissions.mod))
        {
            return -1;
        }
        else if (as3hx.Compat.truthy(!a.permissions.mod && b.permissions.mod))
        {
            return 1;
        }
        
        // User Third
        if (as3hx.Compat.truthy(b.skillRating == a.skillRating))
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

