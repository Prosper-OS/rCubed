package com.flashfla.utils;


class Average
{
    public var deviation(get, never)                            : Dynamic;

    private var size                            : Dynamic;
    public var value                            : Dynamic;
    public var valueDeviation                            : Dynamic;
    
    public function new()
    {
        value = 0;
        valueDeviation = 0;
        size = 0;
    }
    
    public function addValue(value                            : Dynamic) : Void
    {
        this.value = (this.value * size + value) / (size + 1);
        value -= this.value;
        valueDeviation = (valueDeviation * size + value * value) / (size + 1);
        size++;
    }
    
    private function get_deviation() : Float
    {
        return Math.sqrt(valueDeviation);
    }
}

