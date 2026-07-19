package com.flashfla.utils;


class RollingAverage
{
    public var value(get, never)                           : Dynamic;

    private var size                           : Dynamic;
    private var data                           : Dynamic;
    private var dataValue                           : Dynamic;
    
    public function new(size                           : Dynamic, value                           : Dynamic= 0)
    {
        this.size = size;
        this.dataValue = value * size;
        
        data = new Array<Int>();
        
        for (i in 0...size)
        {
            data[i] = value;
        }
    }
    
    public function addValue(value                           : Dynamic) : Void
    {
        dataValue += as3hx.Compat.parseInt(value - data.pop());
        data.unshift(value);
    }
    
    public function reset(value                           : Dynamic= 0) : Void
    {
        dataValue = as3hx.Compat.parseInt(value * size);
        for (i in 0...size)
        {
            data[i] = value;
        }
    }
    
    private function get_value() : Int
    {
        return as3hx.Compat.parseInt(dataValue / size);
    }
}

