package com.flashfla.utils;


class ArrayUtil
{
    
    public static function in_array(inAr : Array<Dynamic>, items : Array<Dynamic>) : Bool
    {
        for (y in 0...items.length)
        {
            for (x in 0...inAr.length)
            {
                if (inAr[x] == items[y])
                {
                    return true;
                }
            }
        }
        return false;
    }
    
    /**
     *	Remove first of the specified value from the array,
     *
     * 	@param arr The array from which the value will be removed
     *
     *	@param value The object that will be removed from the array.
     *
     * 	@langversion ActionScript 3.0
     *	@playerversion Flash 9.0
     *	@tiptext
     */
    public static function remove(value : Dynamic, arr : Array<Dynamic>) : Bool
    {
        if (arr == null || arr.length == 0)
        {
            return false;
        }
        
        var ind : Int;
        if ((ind = Lambda.indexOf(arr, value)) != -1)
        {
            arr.splice(ind, 1);
            return true;
        }
        return false;
    }
    
    /**
     *	Remove all instances of the specified value from the array,
     *
     * 	@param arr The array from which the value will be removed
     *
     *	@param value The object that will be removed from the array.
     *
     * 	@langversion ActionScript 3.0
     *	@playerversion Flash 9.0
     *	@tiptext
     */
    public static function removeValue(value : Dynamic, arr : Array<Dynamic>) : Void
    {
        var len : Int = arr.length;
        
        var i : Float = len;
        while (i > -1)
        {
            if (Reflect.field(arr, Std.string(i)) == value)
            {
                arr.splice(i, 1);
            }
            i--;
        }
    }
    
    public static function randomize(ar : Array<Dynamic>) : Array<Dynamic>
    {
        var newarr : Array<Dynamic> = new Array<Dynamic>(ar.length);
        
        var randomPos : Float = 0;
        for (i in 0...newarr.length)
        {
            randomPos = as3hx.Compat.parseInt(Math.random() * ar.length);
            newarr[i] = ar.splice(randomPos, 1)[0];
        }
        
        return newarr;
    }

    public function new()
    {
    }
}

