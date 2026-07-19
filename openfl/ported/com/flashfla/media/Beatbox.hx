package com.flashfla.media;

import openfl.errors.Error;
import openfl.utils.ByteArray;

class Beatbox
{
    public static function parseBeatbox(data : ByteArray) : Array<Dynamic>
    {
        var header : Dynamic = SwfParser.readHeader(data);
        
        var done : Bool = false;
        while (data.bytesAvailable > 0 && !done)
        {
            var tag : Dynamic = SwfParser.readTag(data);
            var _sw0_ = (tag.tag);            

            switch (_sw0_)
            {
                case SwfParser.SWF_TAG_DOACTION:
                    try
                    {
                        var actionStack : Array<Dynamic> = new Array<Dynamic>();
                        var actionVariables : Dynamic = {};
                        var actionRegisters : Array<Dynamic> = new Array<Dynamic>(4);
                        var constantPool : Array<Dynamic> = [];
                        while (!done)
                        {
                            var action : Dynamic = SwfParser.readAction(data);
                            var _sw1_ = (action.action);                            

                            switch (_sw1_)
                            {
                                case SwfParser.SWF_ACTION_END:
                                    done = true;
                                case SwfParser.SWF_ACTION_CONSTANTPOOL:
                                    constantPool = new Array<Dynamic>();
                                    var constantCount : Int = data.readUnsignedShort();
                                    for (i in 0...constantCount)
                                    {
                                        constantPool.push(SwfParser.readString(data));
                                    }
                                case SwfParser.SWF_ACTION_PUSH:
                                    while (data.position < action.position + action.length)
                                    {
                                        var pushValue : Dynamic;
                                        switch (data.readUnsignedByte())
                                        {
                                            case SwfParser.SWF_TYPE_STRING_LITERAL:
                                                pushValue = SwfParser.readString(data);
                                            case SwfParser.SWF_TYPE_FLOAT_LITERAL:
                                                pushValue = data.readFloat();
                                            case SwfParser.SWF_TYPE_NULL:
                                                pushValue = null;
                                            case SwfParser.SWF_TYPE_UNDEFINED:
                                                pushValue = null;
                                            case SwfParser.SWF_TYPE_REGISTER:
                                                pushValue = actionRegisters[data.readUnsignedByte()];
                                            case SwfParser.SWF_TYPE_BOOLEAN:
                                                pushValue = cast(data.readUnsignedByte(), Bool);
                                            case SwfParser.SWF_TYPE_DOUBLE:
                                                pushValue = data.readDouble();
                                            case SwfParser.SWF_TYPE_INTEGER:
                                                pushValue = data.readInt();
                                            case SwfParser.SWF_TYPE_CONSTANT8:
                                                pushValue = constantPool[data.readUnsignedByte()];
                                            case SwfParser.SWF_TYPE_CONSTANT16:
                                                pushValue = constantPool[data.readUnsignedShort()];
                                            default:
                                        }
                                        actionStack.push(pushValue);
                                    }
                                case SwfParser.SWF_ACTION_POP:
                                    actionStack.pop();
                                case SwfParser.SWF_ACTION_DUPLICATE:
                                    actionStack.push(actionStack[actionStack.length - 1]);
                                case SwfParser.SWF_ACTION_STORE_REGISTER:
                                    actionRegisters[data.readUnsignedByte()] = actionStack[actionStack.length - 1];
                                case SwfParser.SWF_ACTION_GET_VARIABLE:
                                    var gvName : String = actionStack.pop();
                                    if (!(Lambda.has(actionVariables, gvName)))
                                    {
                                        Reflect.setField(actionVariables, gvName, {});
                                    }
                                    actionStack.push(Reflect.field(actionVariables, gvName));
                                case SwfParser.SWF_ACTION_SET_VARIABLE:
                                    var svValue : Dynamic = actionStack.pop();
                                    Reflect.setField(actionVariables, Std.string(actionStack.pop()), svValue);
                                case SwfParser.SWF_ACTION_INIT_ARRAY:
                                    var arraySize : Int = actionStack.pop();
                                    var array : Array<Dynamic> = new Array<Dynamic>();
                                    for (i in 0...arraySize)
                                    {
                                        array.push(actionStack.pop());
                                    }
                                    actionStack.push(array);
                                case SwfParser.SWF_ACTION_GET_MEMBER:
                                    var gmName : String = actionStack.pop();
                                    var gmObject : Dynamic = actionStack.pop();
                                    if (!(Lambda.has(gmObject, gmName)))
                                    {
                                        Reflect.setField(gmObject, gmName, {});
                                    }
                                    actionStack.push(Reflect.field(gmObject, gmName));
                                case SwfParser.SWF_ACTION_SET_MEMBER:
                                    var smValue : Dynamic = actionStack.pop();
                                    var smName : String = actionStack.pop();
                                    actionStack.pop()[smName] = smValue;
                                default:
                            }
                            data.position = action.position + action.length;
                        }
                        var _root : Dynamic = Reflect.field(actionVariables, "_root") || { };
                        var beatBox : Array<Dynamic> = Reflect.field(_root, "beatBox");
                        if (beatBox != null)
                        {
                            return beatBox;
                        }
                    }
                    catch (error : Error)
                    {
                    }
                    done = false;
                default:
            }
            
            data.position = tag.position + tag.length;
        }
        
        return null;
    }

    public function new()
    {
    }
}

