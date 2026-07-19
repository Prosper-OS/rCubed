package popups.settings;


class SettingsTabDebug extends SettingsTabBase
{
    
    public function new(settingsWindow                       : Dynamic)
    {
        super(settingsWindow);
    }
    
    override private function get_name() : String
    {
        return "debug";
    }
    
    override public function openTab() : Void
    {
    }
    
    override public function setValues() : Void
    {
    }
}

