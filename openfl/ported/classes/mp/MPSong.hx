package classes.mp;


class MPSong
{
    public var id                             : Dynamic;
    public var level_id                             : Dynamic;
    
    public var name                             : Dynamic;
    public var author                             : Dynamic;
    public var time                             : Dynamic;
    public var note_count                             : Dynamic;
    public var difficulty                             : Dynamic;
    
    public var engine                             : Dynamic;
    
    public var selected                             : Dynamic= false;
    
    public function update(data                             : Dynamic) : Void
    {
        selected = data.selected;
        name = data.name;
        author = data.author;
        time = data.time;
        note_count = data.note_count;
        difficulty = data.difficulty;
        engine = data.engine;
        id = data.id;
        level_id = data.level_id;
    }

    public function new()
    {
    }
}

