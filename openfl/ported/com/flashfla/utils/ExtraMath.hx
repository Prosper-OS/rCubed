package com.flashfla.utils;

import openfl.utils.Dictionary;

class ExtraMath
{
    //-------------------------------------------------------------------------------------------------------------------------//
    //Function Name:getRandomFraction
    //Function Nature: Returns a random fraction in decimal format with specifed number of decimal places
    //Argument Description: <startValue>,<endValue>,<number of decimal places to be retained(optional)>,<except some fractions(optional)>
    //-------------------------------------------------------------------------------------------------------------------------//
    //Example 1: trace(SuperMath.getRandomFraction(10,12,3));
    //Output:11.345
    //-------------------------------------------------------------------------------------------------------------------------//
    //Example 2: trace(SuperMath.getRandomFraction(10,12,2,[11.34,10.87]));
    //Output:10.76(will not include 11.34,10.87);
    //-------------------------------------------------------------------------------------------------------------------------//
    public static function getRandomFraction(__DOLLAR__min : Float, __DOLLAR__max : Float, roundOff : Int = 2, exceptArray : Array<Dynamic> = null) : Float
    {
        var ran : Float = Math.floor((Math.random() * (__DOLLAR__max - __DOLLAR__min) + __DOLLAR__min) * Math.pow(10, roundOff)) / Math.pow(10, roundOff);
        if (exceptArray != null)
        {
            var isInExceptArray : Bool = true;
            var len : Int = exceptArray.length;
            while (isInExceptArray)
            {
                isInExceptArray = false;
                for (i in ...len)
                {
                    if (ran == exceptArray[i])
                    {
                        isInExceptArray = true;
                        break;
                    }
                }
                if (isInExceptArray)
                {
                    ran = Math.floor((Math.random() * (__DOLLAR__max - __DOLLAR__min) + __DOLLAR__min) * Math.pow(10, roundOff)) / Math.pow(10, roundOff);
                }
            }
        }
        return ran;
    }
    
    //-------------------------------------------------------------------------------------------------------------------------//
    //Function Name:getRandom
    //Function Nature: Returns a random integer
    //Argument Description: <startValue>,<endValue>,<except some integers(optional)>
    //-------------------------------------------------------------------------------------------------------------------------//
    //Example 1: trace(SuperMath.getRandom(1,10));
    //Output:5
    //-------------------------------------------------------------------------------------------------------------------------//
    //Example 2: trace(SuperMath.getRandom(1,10,[3,4,5]));
    //Output:7(will not include 3,4,5);
    //-------------------------------------------------------------------------------------------------------------------------//
    public static function getRandom(__DOLLAR__min : Int, __DOLLAR__max : Int, exceptArray : Array<Dynamic> = null) : Int
    {
        var series : Array<Dynamic> = new Array<Dynamic>();
        var dontInclude : Dictionary<Dynamic, Dynamic> = new Dictionary<Dynamic, Dynamic>(true);
        if (exceptArray != null)
        {
            var len : Int = exceptArray.length;
            for (i in ...len)
            {
                Reflect.setField(dontInclude, Std.string(exceptArray[i]), true);
            }
        }
        for (i in __DOLLAR__min...__DOLLAR__max + 1)
        {
            if (dontInclude[i] != true)
            {
                series.push(i);
            }
        }
        var ran : Float = Math.floor(Math.random() * series.length);
        var number : Dynamic = series.splice(ran, 1);
        if (number.length == 0)
        {
            return __DOLLAR__min;
        }
        else
        {
            return Reflect.field(number, Std.string(0));
        }
    }
    
    //-------------------------------------------------------------------------------------------------------------------------//
    //Function Name:getRandomSeries
    //Function Nature: Returns a random series of integer
    //Argument Description: <startValue>,<endValue>,<except some integers(optional)>
    //-------------------------------------------------------------------------------------------------------------------------//
    //Example 1: trace(SuperMath.getRandom(1,10));
    //Output:5
    //-------------------------------------------------------------------------------------------------------------------------//
    //Example 2: trace(SuperMath.getRandom(1,10,[3,4,5]));
    //Output:7(will not include 3,4,5);
    //-------------------------------------------------------------------------------------------------------------------------//
    public static function getRandomSeries(__DOLLAR__min : Int, __DOLLAR__max : Int, __DOLLAR__count : Int = -1, exceptArray : Array<Dynamic> = null) : Array<Dynamic>
    {
        var series : Array<Dynamic> = new Array<Dynamic>();
        var dontInclude : Dictionary<Dynamic, Dynamic> = new Dictionary<Dynamic, Dynamic>(true);
        if (exceptArray != null)
        {
            var len : Int = exceptArray.length;
            for (i in ...len)
            {
                Reflect.setField(dontInclude, Std.string(exceptArray[i]), true);
            }
        }
        for (i in __DOLLAR__min...__DOLLAR__max + 1)
        {
            if (dontInclude[i] != true)
            {
                series.push(i);
            }
        }
        if (__DOLLAR__count != -1)
        {
            var filteredSeries : Array<Dynamic> = new Array<Dynamic>();
            for (i in 0...__DOLLAR__count)
            {
                var ran : Float = Math.floor(Math.random() * series.length);
                var num : Float = series.splice(ran, 1);
                filteredSeries.push(num[0]);
            }
            return filteredSeries;
        }
        else
        {
            return series;
        }
    }
    
    //-------------------------------------------------------------------------------------------------------------------------//
    //Function Name:getSeries
    //Function Nature: Returns a arithmetic series between the given limits
    //Argument Description: <startValue>,<endValue>,<difference(optional)>
    //-------------------------------------------------------------------------------------------------------------------------//
    //Example 1: trace(SuperMath.getSeries(5,10));
    //Output:5,6,7,8,9,10
    //-------------------------------------------------------------------------------------------------------------------------//
    //Example 2: trace(SuperMath.getSeries(5,10,2));
    //Output:5,7,9
    //-------------------------------------------------------------------------------------------------------------------------//
    public static function getSeries(__DOLLAR__min : Float, __DOLLAR__max : Float, __DOLLAR__dif : Float = 1) : Array<Dynamic>
    {
        var series : Array<Dynamic> = new Array<Dynamic>();
        var i : Int = as3hx.Compat.parseInt(__DOLLAR__min);
        while (i <= __DOLLAR__max)
        {
            series.push(i);
            i = as3hx.Compat.parseInt(i + __DOLLAR__dif);
        }
        return series;
    }
    
    //-------------------------------------------------------------------------------------------------------------------------//
    //Function Name:getRandomElement
    //Function Nature: Returns a random element from an array
    //Argument Description: <array>,<remove(whether to remove that element or not)(optional)>
    //-------------------------------------------------------------------------------------------------------------------------//
    //Example 1:
    //var numArray:Array=[2,5,8,9,1]
    //trace(SuperMath.getRandomElement(numArray));
    //Output:8
    //trace(numArray)
    //Output:2,5,8,9,1
    //-------------------------------------------------------------------------------------------------------------------------//
    //var numArray:Array=[2,5,8,9,1]
    //trace(SuperMath.getRandomElement(numArray,true));
    //Output:8
    //trace(numArray)
    //Output:2,5,9,1(8 will be removed);
    //-------------------------------------------------------------------------------------------------------------------------//
    private static function getRandomElement(arr : Array<Dynamic>, remove : Bool = false) : Dynamic
    {
        var len : Int = arr.length;
        var ran : Int = Math.floor(Math.random() * len);
        var element : Dynamic = arr[ran];
        if (remove)
        {
            arr.splice(ran, 1);
        }
        return element;
    }
    
    //-------------------------------------------------------------------------------------------------------------------------//
    //Function Name:getPrimeList
    //Function Nature: Returns a prime series between the given limits
    //Argument Description: <startValue>,<endValue>,<number of primes you needed>,<randomised series or not(optional)>
    //-------------------------------------------------------------------------------------------------------------------------//
    //Example 1: trace(SuperMath.getPrimeList(5,20));
    //Output:5,7,11,13,17,19
    //-------------------------------------------------------------------------------------------------------------------------//
    //Example 2: trace(SuperMath.getPrimeList(5,20,2));
    //Output:5,7(first two)
    //-------------------------------------------------------------------------------------------------------------------------//
    //Example 3: trace(SuperMath.getPrimeList(5,20,2,true));
    //Output:13,7(any two)
    //-------------------------------------------------------------------------------------------------------------------------//
    public static function getPrimeList(__DOLLAR__min : Int, __DOLLAR__max : Int, __DOLLAR__count : Int = -1, randomised : Bool = false) : Array<Dynamic>
    {
        var series : Array<Dynamic> = [];
        for (i in __DOLLAR__min...__DOLLAR__max + 1)
        {
            if (isPrime(i))
            {
                series.push(i);
            }
        }
        if (__DOLLAR__count != -1)
        {
            var filteredSeries : Array<Dynamic> = new Array<Dynamic>();
            var ran : Int;
            for (i in 0...__DOLLAR__count)
            {
                if (randomised)
                {
                    ran = Math.floor(Math.random() * series.length);
                }
                else
                {
                    ran = i;
                }
                var num : Dynamic = series.splice(ran, 1);
                filteredSeries.push(Reflect.field(num, Std.string(0)));
            }
            return filteredSeries;
        }
        else
        {
            return series;
        }
    }
    
    //-------------------------------------------------------------------------------------------------------------------------//
    //Function Name:getCompositeList
    //Function Nature: Returns a composite series between the given limits
    //Argument Description: <startValue>,<endValue>,<number of composites you needed>,<randomised series or not(optional)>
    //-------------------------------------------------------------------------------------------------------------------------//
    //Example 1: trace(SuperMath.getCompositeList(5,20));
    //Output:6,8,10,12,14,15,16,18.20
    //-------------------------------------------------------------------------------------------------------------------------//
    //Example 2: trace(SuperMath.getCompositeList(5,20,3));
    //Output:6,8,10(first three)
    //-------------------------------------------------------------------------------------------------------------------------//
    //Example 3: trace(SuperMath.getCompositeList(5,20,3,true));
    //Output:14,7,8(any three)
    //-------------------------------------------------------------------------------------------------------------------------//
    public static function getCompositeList(__DOLLAR__min : Int, __DOLLAR__max : Int, __DOLLAR__count : Int = -1, randomised : Bool = false) : Array<Dynamic>
    {
        var series : Array<Dynamic> = [];
        for (i in __DOLLAR__min...__DOLLAR__max + 1)
        {
            if (!isPrime(i))
            {
                series.push(i);
            }
        }
        if (__DOLLAR__count != -1)
        {
            var filteredSeries : Array<Dynamic> = new Array<Dynamic>();
            var ran : Int;
            for (i in 0...__DOLLAR__count)
            {
                if (randomised)
                {
                    ran = Math.floor(Math.random() * series.length);
                }
                else
                {
                    ran = i;
                }
                var num : Dynamic = series.splice(ran, 1);
                filteredSeries.push(Reflect.field(num, Std.string(0)));
            }
            return filteredSeries;
        }
        else
        {
            return series;
        }
    }
    
    //-------------------------------------------------------------------------------------------------------------------------//
    //Function Name:getPrimeFactors
    //Function Nature: Returns a prime factors of a given number
    //Argument Description: <number>
    //-------------------------------------------------------------------------------------------------------------------------//
    //Example 1: trace(SuperMath.getPrimeFactors(36));
    //Output:2,3
    //-------------------------------------------------------------------------------------------------------------------------//
    //Example 2: trace(SuperMath.getPrimeFactors(100));
    //Output:2,5
    //-------------------------------------------------------------------------------------------------------------------------//
    public static function getPrimeFactors(__DOLLAR__num : Float) : Array<Dynamic>
    {
        var factorArray : Array<Dynamic> = [];
        if (__DOLLAR__num == 2)
        {
            factorArray = [2];
            return factorArray;
        }
        else if (__DOLLAR__num == 1)
        {
            return factorArray;
        }
        else
        {
            for (i in 2...__DOLLAR__num + 1)
            {
                if (__DOLLAR__num % i == 0 && isPrime(i))
                {
                    factorArray.push(i);
                }
            }
            return factorArray;
        }
    }
    
    //-------------------------------------------------------------------------------------------------------------------------//
    //Function Name:getFactors
    //Function Nature: Returns a all factors of a given number
    //Argument Description: <number>
    //-------------------------------------------------------------------------------------------------------------------------//
    //Example 1: trace(SuperMath.getFactors(36));
    //Output:1,2,3,6,12,18,36
    //-------------------------------------------------------------------------------------------------------------------------//
    public static function getFactors(__DOLLAR__num : Float) : Array<Dynamic>
    {
        var factorArray : Array<Dynamic> = [];
        
        for (i in 1...__DOLLAR__num + 1)
        {
            if (__DOLLAR__num % i == 0)
            {
                factorArray.push(i);
            }
        }
        return factorArray;
    }
    
    //-------------------------------------------------------------------------------------------------------------------------//
    //Function Name:getGCD
    //Function Nature: Returns GCD of two given numbers
    //Argument Description: <number1>,<number2>
    //-------------------------------------------------------------------------------------------------------------------------//
    //Example 1: trace(SuperMath.getGCD(10,15));
    //Output:5
    //-------------------------------------------------------------------------------------------------------------------------//
    public static function getGCD(a : Int, b : Int) : Int
    {
        if ((a < 0) || (b < 0))
        {
            return getGCD(Math.abs(a), Math.abs(b));
        }
        if (a < b)
        {
            return getGCD(b, a);
        }
        if (b == 0)
        {
            return a;
        }
        return getGCD(b, a % b);
    }
    
    //-------------------------------------------------------------------------------------------------------------------------//
    //Function Name:getLCM
    //Function Nature: Returns LCM of two given numbers
    //Argument Description: <number1>,<number2>
    //-------------------------------------------------------------------------------------------------------------------------//
    //Example 1: trace(SuperMath.getLCM(10,15));
    //Output:30
    //-------------------------------------------------------------------------------------------------------------------------//
    public static function getLCM(a : Int, b : Int) : Int
    {
        return as3hx.Compat.parseInt((a * b) / getGCD(a, b));
    }
    
    //-------------------------------------------------------------------------------------------------------------------------//
    //Function Name:getCommonMultiples
    //Function Nature: Returns series of commmon multiples of two given numbers
    //Argument Description: <number1>,<number2>,<number of multiples(optional)>
    //-------------------------------------------------------------------------------------------------------------------------//
    //Example 1: trace(SuperMath.getCommonMultiples(10,15,7));
    //Output:30,60,90,120,150,180,210
    //-------------------------------------------------------------------------------------------------------------------------//
    public static function getCommonMultiples(a : Int, b : Int, cnt : Int = 1) : Array<Dynamic>
    {
        return getSeries(getLCM(a, b), getLCM(a, b) * (cnt - 1), getLCM(a, b));
    }
    
    //-------------------------------------------------------------------------------------------------------------------------//
    //Function Name:isPrime
    //Function Nature: Checks whether the given number is prime or not.
    //Argument Description: <number>
    //-------------------------------------------------------------------------------------------------------------------------//
    //Example 1: trace(SuperMath.isPrime(10));
    //Output:false
    //-------------------------------------------------------------------------------------------------------------------------//
    //Example 2: trace(SuperMath.isPrime(23));
    //Output:true
    //-------------------------------------------------------------------------------------------------------------------------//
    public static function isPrime(__DOLLAR__num : Float) : Bool
    {
        if (__DOLLAR__num == 2)
        {
            return true;
        }
        else if (__DOLLAR__num == 1)
        {
            return false;
        }
        else
        {
            for (i in 2...__DOLLAR__num)
            {
                if (__DOLLAR__num % i == 0)
                {
                    return false;
                }
            }
            return true;
        }
    }

    public function new()
    {
    }
}

