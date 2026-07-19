package com.flashfla.utils;


class RollingAverage
{
    public var value(get, never) : Int;

    private var size : Int;
    private var data : Array<Int>;
    private var dataValue : Int;
    
    public function new(size : Int, value : Int = 0)
    {
        this.size = size;
        this.dataValue = value * size;
        
        data = new Array<Int>();
        
        for (i in 0...size)
        {
            data[i] = value;
        }
    }
    
    public function addValue(value : Int) : Void
    {
        dataValue += as3hx.Compat.parseInt(value - data.pop());
        data.unshift(value);
    }
    
    public function reset(value : Int = 0) : Void
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

