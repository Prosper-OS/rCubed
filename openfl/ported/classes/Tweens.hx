package classes;


class Tweens
{
    public static function linear(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        return change * elapsed_time / duration + begin;
    }
    
    public static function inQuad(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        elapsed_time = elapsed_time / duration;
        return change * Math.pow(elapsed_time, 2) + begin;
    }
    
    public static function outQuad(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        elapsed_time = elapsed_time / duration;
        return -change * elapsed_time * (elapsed_time - 2) + begin;
    }
    
    public static function inOutQuad(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        elapsed_time = elapsed_time / duration * 2;
        if (elapsed_time < 1)
        {
            return change / 2 * Math.pow(elapsed_time, 2) + begin;
        }
        else
        {
            return -change / 2 * ((elapsed_time - 1) * (elapsed_time - 3) - 1) + begin;
        }
    }
    
    public static function outInQuad(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        if (elapsed_time < duration / 2)
        {
            return outQuad(elapsed_time * 2, begin, change / 2, duration);
        }
        else
        {
            return inQuad((elapsed_time * 2) - duration, begin + change / 2, change / 2, duration);
        }
    }
    
    public static function inCubic(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        elapsed_time = elapsed_time / duration;
        return change * Math.pow(elapsed_time, 3) + begin;
    }
    
    public static function outCubic(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        elapsed_time = elapsed_time / duration - 1;
        return change * (Math.pow(elapsed_time, 3) + 1) + begin;
    }
    
    public static function inOutCubic(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        elapsed_time = elapsed_time / duration * 2;
        if (elapsed_time < 1)
        {
            return change / 2 * elapsed_time * elapsed_time * elapsed_time + begin;
        }
        else
        {
            elapsed_time = elapsed_time - 2;
            return change / 2 * (elapsed_time * elapsed_time * elapsed_time + 2) + begin;
        }
    }
    
    public static function outInCubic(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        if (elapsed_time < duration / 2)
        {
            return outCubic(elapsed_time * 2, begin, change / 2, duration);
        }
        else
        {
            return inCubic((elapsed_time * 2) - duration, begin + change / 2, change / 2, duration);
        }
    }
    
    public static function inQuart(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        elapsed_time = elapsed_time / duration;
        return change * Math.pow(elapsed_time, 4) + begin;
    }
    
    public static function outQuart(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        elapsed_time = elapsed_time / duration - 1;
        return -change * (Math.pow(elapsed_time, 4) - 1) + begin;
    }
    
    public static function inOutQuart(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        elapsed_time = elapsed_time / duration * 2;
        if (elapsed_time < 1)
        {
            return change / 2 * Math.pow(elapsed_time, 4) + begin;
        }
        else
        {
            elapsed_time = elapsed_time - 2;
            return -change / 2 * (Math.pow(elapsed_time, 4) - 2) + begin;
        }
    }
    
    public static function outInQuart(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        if (elapsed_time < duration / 2)
        {
            return outQuart(elapsed_time * 2, begin, change / 2, duration);
        }
        else
        {
            return inQuart((elapsed_time * 2) - duration, begin + change / 2, change / 2, duration);
        }
    }
    
    public static function inQuint(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        elapsed_time = elapsed_time / duration;
        return change * Math.pow(elapsed_time, 5) + begin;
    }
    
    public static function outQuint(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        elapsed_time = elapsed_time / duration - 1;
        return change * (Math.pow(elapsed_time, 5) + 1) + begin;
    }
    
    public static function inOutQuint(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        elapsed_time = elapsed_time / duration * 2;
        if (elapsed_time < 1)
        {
            return change / 2 * Math.pow(elapsed_time, 5) + begin;
        }
        else
        {
            elapsed_time = elapsed_time - 2;
            return change / 2 * (Math.pow(elapsed_time, 5) + 2) + begin;
        }
    }
    
    public static function outInQuint(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        if (elapsed_time < duration / 2)
        {
            return outQuint(elapsed_time * 2, begin, change / 2, duration);
        }
        else
        {
            return inQuint((elapsed_time * 2) - duration, begin + change / 2, change / 2, duration);
        }
    }
    
    public static function inSine(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        return -change * Math.cos(elapsed_time / duration * (Math.PI / 2)) + change + begin;
    }
    
    public static function outSine(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        return change * Math.sin(elapsed_time / duration * (Math.PI / 2)) + begin;
    }
    
    public static function inOutSine(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        return -change / 2 * (Math.cos(Math.PI * elapsed_time / duration) - 1) + begin;
    }
    
    public static function outInSine(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        if (elapsed_time < duration / 2)
        {
            return outSine(elapsed_time * 2, begin, change / 2, duration);
        }
        else
        {
            return inSine((elapsed_time * 2) - duration, begin + change / 2, change / 2, duration);
        }
    }
    
    public static function inExpo(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        if (elapsed_time == 0)
        {
            return begin;
        }
        else
        {
            return change * Math.pow(2, 10 * (elapsed_time / duration - 1)) + begin - change * 0.001;
        }
    }
    
    public static function outExpo(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        if (elapsed_time == duration)
        {
            return begin + change;
        }
        else
        {
            return change * 1.001 * (-Math.pow(2, -10 * elapsed_time / duration) + 1) + begin;
        }
    }
    
    public static function inOutExpo(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        if (elapsed_time == 0)
        {
            return begin;
        }
        if (elapsed_time == duration)
        {
            return begin + change;
        }
        elapsed_time = elapsed_time / duration * 2;
        if (elapsed_time < 1)
        {
            return change / 2 * Math.pow(2, 10 * (elapsed_time - 1)) + begin - change * 0.0005;
        }
        else
        {
            elapsed_time = elapsed_time - 1;
            return change / 2 * 1.0005 * (-Math.pow(2, -10 * elapsed_time) + 2) + begin;
        }
    }
    
    public static function outInExpo(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        if (elapsed_time < duration / 2)
        {
            return outExpo(elapsed_time * 2, begin, change / 2, duration);
        }
        else
        {
            return inExpo((elapsed_time * 2) - duration, begin + change / 2, change / 2, duration);
        }
    }
    
    public static function inCirc(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        elapsed_time = elapsed_time / duration;
        return (-change * (Math.sqrt(1 - Math.pow(elapsed_time, 2)) - 1) + begin);
    }
    
    public static function outCirc(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        elapsed_time = elapsed_time / duration - 1;
        return (change * Math.sqrt(1 - Math.pow(elapsed_time, 2)) + begin);
    }
    
    public static function inOutCirc(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        elapsed_time = elapsed_time / duration * 2;
        if (elapsed_time < 1)
        {
            return -change / 2 * (Math.sqrt(1 - elapsed_time * elapsed_time) - 1) + begin;
        }
        else
        {
            elapsed_time = elapsed_time - 2;
            return change / 2 * (Math.sqrt(1 - elapsed_time * elapsed_time) + 1) + begin;
        }
    }
    
    public static function outInCirc(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        if (elapsed_time < duration / 2)
        {
            return outCirc(elapsed_time * 2, begin, change / 2, duration);
        }
        else
        {
            return inCirc((elapsed_time * 2) - duration, begin + change / 2, change / 2, duration);
        }
    }
    
    public static function inElastic(elapsed_time : Float, begin : Float, change : Float, duration : Float, a : Float, p : Float = Math.NaN) : Float
    {
        if (elapsed_time == 0)
        {
            return begin;
        }
        
        elapsed_time = elapsed_time / duration;
        
        if (elapsed_time == 1)
        {
            return begin + change;
        }
        
        if (Math.isNaN(p))
        {
            p = duration * 0.3;
        }
        
        var s : Float;
        
        if (!a || a < Math.abs(change))
        {
            a = change;
            s = p / 4;
        }
        else
        {
            s = p / (2 * Math.PI) * Math.asin(change / a);
        }
        
        elapsed_time = elapsed_time - 1;
        
        return -(a * Math.pow(2, 10 * elapsed_time) * Math.sin((elapsed_time * duration - s) * (2 * Math.PI) / p)) + begin;
    }
    
    public static function outElastic(elapsed_time : Float, begin : Float, change : Float, duration : Float, amplitude : Float = Math.NaN, period : Float = Math.NaN) : Float
    {
        if (elapsed_time == 0)
        {
            return begin;
        }
        
        elapsed_time = elapsed_time / duration;
        
        if (elapsed_time == 1)
        {
            return begin + change;
        }
        
        if (Math.isNaN(period))
        {
            period = duration * 0.3;
        }
        
        var s : Float;
        
        if (Math.isNaN(amplitude) || amplitude < Math.abs(change))
        {
            amplitude = change;
            s = period / 4;
        }
        else
        {
            s = period / (2 * Math.PI) * Math.asin(change / amplitude);
        }
        
        return amplitude * Math.pow(2, -10 * elapsed_time) * Math.sin((elapsed_time * duration - s) * (2 * Math.PI) / period) + change + begin;
    }
    
    public static function inOutElastic(elapsed_time : Float, begin : Float, change : Float, duration : Float, amplitude : Float = Math.NaN, period : Float = Math.NaN) : Float
    {
        if (elapsed_time == 0)
        {
            return begin;
        }
        
        elapsed_time = elapsed_time / duration * 2;
        
        if (elapsed_time == 2)
        {
            return begin + change;
        }
        
        if (Math.isNaN(period))
        {
            period = duration * (0.3 * 1.5);
        }
        if (Math.isNaN(amplitude))
        {
            amplitude = 0;
        }
        
        var s : Float;
        
        if (Math.isNaN(amplitude) || amplitude < Math.abs(change))
        {
            amplitude = change;
            s = period / 4;
        }
        else
        {
            s = period / (2 * Math.PI) * Math.asin(change / amplitude);
        }
        
        if (elapsed_time < 1)
        {
            elapsed_time = elapsed_time - 1;
            return -0.5 * (amplitude * Math.pow(2, 10 * elapsed_time) * Math.sin((elapsed_time * duration - s) * (2 * Math.PI) / period)) + begin;
        }
        else
        {
            elapsed_time = elapsed_time - 1;
            return amplitude * Math.pow(2, -10 * elapsed_time) * Math.sin((elapsed_time * duration - s) * (2 * Math.PI) / period) * 0.5 + change + begin;
        }
    }
    
    public static function outInElastic(elapsed_time : Float, begin : Float, change : Float, duration : Float, amplitude : Float = Math.NaN, period : Float = Math.NaN) : Float
    {
        if (elapsed_time < duration / 2)
        {
            return outElastic(elapsed_time * 2, begin, change / 2, duration, amplitude, period);
        }
        else
        {
            return inElastic((elapsed_time * 2) - duration, begin + change / 2, change / 2, duration, amplitude, period);
        }
    }
    
    public static function inBack(elapsed_time : Float, begin : Float, change : Float, duration : Float, s : Float = 1.70158) : Float
    {
        elapsed_time = elapsed_time / duration;
        return change * elapsed_time * elapsed_time * ((s + 1) * elapsed_time - s) + begin;
    }
    
    public static function outBack(elapsed_time : Float, begin : Float, change : Float, duration : Float, s : Float = 1.70158) : Float
    {
        elapsed_time = elapsed_time / duration - 1;
        return change * (elapsed_time * elapsed_time * ((s + 1) * elapsed_time + s) + 1) + begin;
    }
    
    public static function inOutBack(elapsed_time : Float, begin : Float, change : Float, duration : Float, s : Float = 1.70158) : Float
    {
        s = s * 1.525;
        elapsed_time = elapsed_time / duration * 2;
        if (elapsed_time < 1)
        {
            return change / 2 * (elapsed_time * elapsed_time * ((s + 1) * elapsed_time - s)) + begin;
        }
        else
        {
            elapsed_time = elapsed_time - 2;
            return change / 2 * (elapsed_time * elapsed_time * ((s + 1) * elapsed_time + s) + 2) + begin;
        }
    }
    
    public static function outInBack(elapsed_time : Float, begin : Float, change : Float, duration : Float, s : Float = 1.70158) : Float
    {
        if (elapsed_time < duration / 2)
        {
            return outBack(elapsed_time * 2, begin, change / 2, duration, s);
        }
        else
        {
            return inBack((elapsed_time * 2) - duration, begin + change / 2, change / 2, duration, s);
        }
    }
    
    public static function outBounce(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        elapsed_time = elapsed_time / duration;
        if (elapsed_time < 1 / 2.75)
        {
            return change * (7.5625 * elapsed_time * elapsed_time) + begin;
        }
        else if (elapsed_time < 2 / 2.75)
        {
            elapsed_time = elapsed_time - (1.5 / 2.75);
            return change * (7.5625 * elapsed_time * elapsed_time + 0.75) + begin;
        }
        else if (elapsed_time < 2.5 / 2.75)
        {
            elapsed_time = elapsed_time - (2.25 / 2.75);
            return change * (7.5625 * elapsed_time * elapsed_time + 0.9375) + begin;
        }
        else
        {
            elapsed_time = elapsed_time - (2.625 / 2.75);
            return change * (7.5625 * elapsed_time * elapsed_time + 0.984375) + begin;
        }
    }
    
    public static function inBounce(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        return change - outBounce(duration - elapsed_time, 0, change, duration) + begin;
    }
    
    public static function inOutBounce(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        if (elapsed_time < duration / 2)
        {
            return inBounce(elapsed_time * 2, 0, change, duration) * 0.5 + begin;
        }
        else
        {
            return outBounce(elapsed_time * 2 - duration, 0, change, duration) * 0.5 + change * 0.5 + begin;
        }
    }
    
    public static function outInBounce(elapsed_time : Float, begin : Float, change : Float, duration : Float) : Float
    {
        if (elapsed_time < duration / 2)
        {
            return outBounce(elapsed_time * 2, begin, change / 2, duration);
        }
        else
        {
            return inBounce((elapsed_time * 2) - duration, begin + change / 2, change / 2, duration);
        }
    }

    public function new()
    {
    }
}

