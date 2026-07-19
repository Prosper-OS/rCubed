package com.flashfla.utils;


class VectorUtil
{
    
    public static function fromArr(arr : Array<Dynamic>) : Array<Dynamic>
    {
        var vec : Array<Dynamic> = [];
        for (value in arr)
        {
            vec.push(value);
        }
        return vec;
    }
    
    public static function inVector(vec : Dynamic, items : Dynamic) : Bool
    {
        var _vec : Array<Dynamic> = vec;
        var _items : Array<Dynamic> = items;
        
        if (!(vec.length) || !(items.length) || vec.length < items.length)
        {
            return false;
        }
        
        for (y in 0..._items.length)
        {
            for (x in 0..._vec.length)
            {
                if (_vec[x] == _items[y])
                {
                    return true;
                }
            }
        }
        return false;
    }
    
    
    public static function removeFirst(value : Dynamic, vec : Dynamic) : Bool
    {
        if (!(Std.is(vec, Array/*Vector.<T> call?*/)))
        {
            return false;
        }
        
        var _vec : Array<Dynamic> = try cast(vec, Array/*Vector.<T> call?*/) catch(e:Dynamic) null;
        
        if (_vec.length == 0)
        {
            return false;
        }
        
        var ind : Int;
        if ((ind = Lambda.indexOf(_vec, value)) != -1)
        {
            _vec.splice(ind, 1)[0];
            return true;
        }
        return false;
    }
    
    // Returns element index closest to target
    public static function binarySearch(vec : Dynamic, target : Float, prop : String) : Int
    {
        if (!(Std.is(vec, Array/*Vector.<T> call?*/)))
        {
            return -1;
        }
        
        var _vec : Array<Dynamic> = try cast(vec, Array/*Vector.<T> call?*/) catch(e:Dynamic) null;
        
        var n : Int = _vec.length;
        var i : Int = 0;
        var j : Int = n;
        var mid : Int = 0;
        
        // Corner cases
        if (n == 0)
        {
            return -1;
        }
        if (target <= Reflect.field(_vec[0], prop))
        {
            return 0;
        }
        if (target >= Reflect.field(_vec[n - 1], prop))
        {
            return as3hx.Compat.parseInt(n - 1);
        }
        
        // Doing binary search
        while (i < j)
        {
            mid = as3hx.Compat.parseInt((i + j) / 2);
            
            if (Reflect.field(_vec[mid], prop) == target)
            {
                return mid;
            }
            
            // If target is less than array
            // element,then search in left
            if (target < Reflect.field(_vec[mid], prop)) {
// to mid, return closest of two
                if (mid > 0 && target > Reflect.field(_vec[mid - 1], prop))
                {
                    return (getClosest(Reflect.field(_vec[mid - 1], prop), Reflect.field(_vec[mid], prop), target) == Reflect.field(_vec[mid - 1], prop)) ? mid - 1 : mid;
                }
                
                // Repeat for left half
                j = mid;
            }
            // If target is greater than mid
            else
            {
                
                {
                    if (mid < n - 1 && target < Reflect.field(_vec[mid + 1], prop))
                    {
                        return (getClosest(Reflect.field(_vec[mid], prop), Reflect.field(_vec[mid + 1], prop), target) == Reflect.field(_vec[mid], prop)) ? mid : mid + 1;
                    }
                    i = as3hx.Compat.parseInt(mid + 1);
                }
            }
        }
        
        // Only single element left after search
        return mid;
    }
    
    // Method to compare which one is the more close
    // We find the closest by taking the difference
    // between the target and both values. It assumes
    // that val2 is greater than val1 and target lies
    // between these two.
    private static function getClosest(val1 : Float, val2 : Float, target : Float) : Float
    {
        return (target - val1 >= val2 - target) ? val2 : val1;
    }

    public function new()
    {
    }
}

