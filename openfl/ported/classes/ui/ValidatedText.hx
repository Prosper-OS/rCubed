package classes.ui;

import openfl.display.DisplayObjectContainer;
import openfl.events.Event;
import openfl.text.TextFormat;

class ValidatedText extends BoxText
{
    private static inline var PARSE_COLOR : Int = 2;
    private static inline var PARSE_FLOAT : Int = 1;
    private static inline var PARSE_INT : Int = 0;
    
    public static inline var R_FLOAT_P : Int = 0;
    public static inline var R_FLOAT : Int = 1;
    public static inline var R_INT_P : Int = 2;
    public static inline var R_INT : Int = 3;
    public static inline var R_COLOR : Int = 4;
    public static inline var R_ALL : Int = 5;
    
    private var m_parseMode : Int = PARSE_INT;
    private var m_validator : as3hx.Compat.Regex;
    
    private var _listener : Dynamic = null;
    
    /**
     * The ValidatedText constructor.
     * restrict_mode determines what characters could be entered into the textfield:
     * --> R_FLOAT_P: A positive decimal.
     * --> R_FLOAT: A decimal.
     * --> R_INT_P: A positive integer.
     * --> R_INT: An integer.
     * --> R_COLOR: A hex string, including the pound ('#') sign.
     * --> R_ALL: No restriction.
     * @param width Width of the textfield
     * @param height Height of the textfield
     * @param restrict_mode Which restricted character set to be used
     * @param textformat TextFormat of the textfield
     */
    public function new(parent : DisplayObjectContainer = null, xpos : Float = 0, ypos : Float = 0, width : Int = 0, height : Int = 0, restrict_mode : Int = 0, listener : Dynamic = null, textformat : TextFormat = null)
    {
        super(parent, xpos, ypos, width, height, textformat);
        switch (restrict_mode)
        {
            case R_FLOAT_P:
                this.restrict = "0-9.";
                m_parseMode = PARSE_FLOAT;
                m_validator = new as3hx.Compat.Regex('^\\d*\\.?\\d*$', "");
            case R_FLOAT:
                this.restrict = "\\-0-9.";
                m_parseMode = PARSE_FLOAT;
                m_validator = new as3hx.Compat.Regex('^-?\\d*\\.?\\d*$', "");
            case R_INT_P:
                this.restrict = "0-9";
                m_parseMode = PARSE_INT;
            case R_INT:
                this.restrict = "\\-0-9";
                m_parseMode = PARSE_INT;
                m_validator = new as3hx.Compat.Regex('^-?\\d+$', "");
            case R_COLOR:
                this.restrict = "#0-9a-f";
                m_parseMode = PARSE_COLOR;
                m_validator = new as3hx.Compat.Regex('^#[0-9a-f]{6}$', "");
        }
        
        if (listener != null)
        {
            this._listener = listener;
            this.addEventListener(Event.CHANGE, listener);
        }
    }
    
    override public function dispose() : Void
    {
        if (this._listener != null)
        {
            this.removeEventListener(Event.CHANGE, this._listener);
        }
        super.dispose();
    }
    
    private function renderValid() : Void
    {
        super.color = 0xFFFFFF;
        super.borderColor = 0xFFFFFF;
    }
    
    private function renderInvalid() : Void
    {
        super.color = 0xFF0000;
        super.borderColor = 0xFF0000;
    }
    
    /**
     * Called to validate the text of a ValidatedText according to the restricted character set.
     * First, the text is checked if it passes a regex test.
     * Then, the parsed number is checked to see if it's not NaN and it's within the bounds supplied by the users of this function.
     * If the text is valid:
     * --> The BoxText is rendered to display its default colors; otherwise, it turns red.
     * --> The parsed number is returned; otherwise, the default value is returned.
     * @param default_value Value returned if validation fails
     * @param lower_bound Lower bound of valid region
     * @param upper_bound Upper bound of valid region
     * @return Number The parsed number if validation succeeds; the default value if validation fails
     */
    public function validate(default_value : Float, lower_bound : Float = Math.NaN, upper_bound : Float = Math.NaN) : Float
    {
        var parse_color : Bool = (m_parseMode == PARSE_COLOR);
        var parse_float : Bool = (m_parseMode == PARSE_FLOAT);
        var radix : Int = (parse_color) ? 16 : 0;
        
        var testString : String = this.text;
        var regex_passed : Bool = ((m_validator != null)) ? m_validator.test(testString) : true;
        if (parse_color)
        {
            testString = "0x" + StringTools.replace(testString, "#", "");
        }
        
        var to_test : Float = ((parse_float)) ? as3hx.Compat.parseFloat(testString) : as3hx.Compat.parseInt(testString);
        var valid : Bool = !(!regex_passed || Math.isNaN(to_test) || (!Math.isNaN(lower_bound) && to_test < lower_bound) || (!Math.isNaN(upper_bound) && to_test > upper_bound));
        if (valid)
        {
            renderValid();
            return to_test;
        }
        else
        {
            renderInvalid();
            return default_value;
        }
    }
}

