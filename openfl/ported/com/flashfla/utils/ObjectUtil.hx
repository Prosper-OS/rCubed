package com.flashfla.utils;

import openfl.utils.ByteArray;

class ObjectUtil
{
    public static function clone(o                           : Dynamic) : Dynamic
    {
        var bytes                           : Dynamic= new ByteArray();
        bytes.writeObject(o);
        bytes.position = 0;
        return bytes.readObject();
    }
    
    /**
     * An equivalent of PHP's recursive print function print_r, which displays objects and arrays in a way that's readable by humans
     * @param obj    Object to be printed
     * @param level  (Optional) Current recursivity level, used for recursive calls
     * @param output (Optional) The output, used for recursive calls
     */
    public static function print_r(obj                           : Dynamic, level                           : Dynamic= 0, output                           : Dynamic= "") : Dynamic
    {
        if (as3hx.Compat.truthy(level == 0))
        {
            output = "(" + ObjectUtil.typeOf(obj) + ") {\n";
        }
        else if (as3hx.Compat.truthy(level == 10))
        {
            return output;
        }
        
        var tabs                           : Dynamic= "    ";
        for (i in 0...level)
        {
            tabs += "    ";
        }
        
        if (as3hx.Compat.truthy(level == 0 && ObjectUtil.count(obj) == 0))
        {
            if (as3hx.Compat.truthy(ObjectUtil.typeOf(obj) == "string"))
            {
                output += "\"" + obj + "\"";
            }
            else if (as3hx.Compat.truthy(ObjectUtil.typeOf(obj) == "number"))
            {
                output += obj + " [0x" + Std.string(as3hx.Compat.parseFloat(obj)) + "]";
            }
            else
            {
                output += obj;
            }
            
            output += "\n";
        }
        else
        {
            for (child in as3hx.Compat.iter(Reflect.fields(obj)))
            {
                output += tabs + "[" + child + "] => (" + ObjectUtil.typeOf(Reflect.field(obj, child)) + ") ";
                //output += tabs +'['+ child +'] => ';
                
                if (as3hx.Compat.truthy(ObjectUtil.count(Reflect.field(obj, child)) == 0))
                {
                    if (as3hx.Compat.truthy(ObjectUtil.typeOf(Reflect.field(obj, child)) == "string"))
                    {
                        output += "\"" + Reflect.field(obj, child) + "\"";
                    }
                    else if (as3hx.Compat.truthy(ObjectUtil.typeOf(Reflect.field(obj, child)) == "number"))
                    {
                        output += Reflect.field(obj, child) + " [0x" + Std.string(as3hx.Compat.parseFloat(Reflect.field(obj, child))) + "]";
                    }
                    else
                    {
                        output += Reflect.field(obj, child);
                    }
                }
                
                var childOutput                           : Dynamic= "";
                if (as3hx.Compat.truthy(as3hx.Compat.typeof(Reflect.field(obj, child)) != "xml"))
                {
                    childOutput = ObjectUtil.print_r(Reflect.field(obj, child), level + 1);
                }
                
                if (as3hx.Compat.truthy(childOutput != "")) {
output += "{\n" + childOutput + tabs + "}";
                }
                output += "\n";
            }
        }
        
        if (as3hx.Compat.truthy(level == 0))
        {
            return output + "}\n";
        }
        else
        {
            return output;
        }
    }
    
    /**
     * An extended version of the 'typeof' function
     * @param 	variable
     * @return	Returns the type of the variable
     */
    public static function typeOf(variable                           : Dynamic) : String
    {
        if (as3hx.Compat.truthy(Std.is(variable, Array)))
        {
            return "array";
        }
        else if (as3hx.Compat.truthy(Std.is(variable, Date)))
        {
            return "date";
        }
        else
        {
            return as3hx.Compat.typeof(variable);
        }
    }
    
    
    public static function getClass(obj                           : Dynamic) : Class<Dynamic>
    {
        return obj;
    }
    
    /**
     * Returns the size of an object
     * @param obj Object to be counted
     */
    public static function count(obj                           : Dynamic) : Int
    {
        if (as3hx.Compat.truthy(ObjectUtil.typeOf(obj) == "array"))
        {
            return obj.length;
        }
        else
        {
            var len                           : Dynamic= 0;
            for (item in as3hx.Compat.iter(Reflect.fields(obj)))
            {
                if (as3hx.Compat.truthy(item != "mx_internal_uid"))
                {
                    len++;
                }
            }
            return len;
        }
    }
    
    
    public static function merge(main                           : Dynamic, json                           : Dynamic) : Void
    {
        if (as3hx.Compat.truthy(json == null))
        {
            return;
        }
        if (as3hx.Compat.truthy(main == null))
        {
            main = json;
            return;
        }
        for (item in as3hx.Compat.iter(Reflect.fields(json)))
        {
            if (as3hx.Compat.truthy(Reflect.field(main, item) == null))
            {
                continue;
            }
            if (as3hx.Compat.truthy(Std.is(Reflect.field(json, item), String) || Std.is(Reflect.field(json, item), Float)))
            {
                Reflect.setField(main, item, Reflect.field(json, item));
            }
            else if (as3hx.Compat.truthy(Std.is(Reflect.field(main, item), Dynamic)))
            {
                merge(Reflect.field(main, item), Reflect.field(json, item));
            }
        }
    }
    
    public static function differences(main                           : Dynamic, changed                           : Dynamic) : Dynamic
    {
        var out                           : Dynamic= null;
        
        for (item in as3hx.Compat.iter(Reflect.fields(main)))
        {
            if (as3hx.Compat.truthy(Reflect.field(changed, item) == null))
            {
                continue;
            }
            
            if (as3hx.Compat.truthy(Std.is(Reflect.field(main, item), String) || Std.is(Reflect.field(main, item), Float)))
            {
                if (as3hx.Compat.truthy(Reflect.field(main, item) != Reflect.field(changed, item)))
                {
                    if (as3hx.Compat.truthy(out == null))
                    {
                        out = { };
                    }
                    Reflect.setField(out, item, Reflect.field(changed, item));
                }
            }
            else if (as3hx.Compat.truthy(Std.is(Reflect.field(main, item), Dynamic)))
            {
                var diffs                           : Dynamic= differences(Reflect.field(main, item), Reflect.field(changed, item));
                if (as3hx.Compat.truthy(diffs != null))
                {
                    if (as3hx.Compat.truthy(out == null))
                    {
                        out = { };
                    }
                    Reflect.setField(out, item, diffs);
                }
            }
        }
        return out;
    }

    public function new()
    {
    }
}

