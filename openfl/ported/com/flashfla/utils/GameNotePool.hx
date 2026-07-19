package com.flashfla.utils;

import classes.GameNote;


class GameNotePool
{
    public var pool : Array<PoolObject>;
    
    public function new()
    {
        pool = new Array<PoolObject>();
    }
    
    public function addObject(object : GameNote, mark : Bool = true) : GameNote
    {
        pool.push(new PoolObject(mark, object));
        return object;
    }
    
    public function unmarkObject(object : GameNote, mark : Bool = false) : Void
    {
        for (item in pool)
        {
            if (item.value == object)
            {
                item.mark = mark;
            }
        }
    }
    
    public function unmarkAll(mark : Bool = false) : Void
    {
        for (item in pool)
        {
            item.mark = mark;
        }
    }
    
    public function getObject() : GameNote
    {
        for (item in pool)
        {
            if (!item.mark)
            {
                item.mark = true;
                return item.value;
            }
        }
        return null;
    }
}



class PoolObject
{
    public var mark : Bool;
    public var value : GameNote;
    
    @:allow(com.flashfla.utils)
    private function new(mark : Bool, value : GameNote)
    {
        this.mark = mark;
        this.value = value;
    }
}
