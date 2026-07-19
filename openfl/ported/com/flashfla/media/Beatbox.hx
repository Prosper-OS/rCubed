package com.flashfla.media;

import openfl.errors.Error;
import openfl.utils.ByteArray;

class Beatbox
{
    public static function parseBeatbox(data                            : Dynamic) : Array<Dynamic>
    {
        var header                            : Dynamic= SwfParser.readHeader(data);
        
        var done                            : Dynamic= false;
        while (as3hx.Compat.truthy(data.bytesAvailable > 0 && !done))
        {
            var tag                            : Dynamic= SwfParser.readTag(data);
            var _sw0_ = (tag.tag);            

            switch (_sw0_)
            {
                case SwfParser.SWF_TAG_DOACTION:
                    try
                    {
                        var actionStack                            : Dynamic= new Array<Dynamic>();
                        var actionVariables                            : Dynamic= {};
                        var actionRegisters                          : Dynamic= []; as3hx.Compat.setArrayLength(actionRegisters, 4);
                        var constantPool                            : Dynamic= [];
                        while (as3hx.Compat.truthy(!done))
                        {
                            var action                            : Dynamic= SwfParser.readAction(data);
                            var _sw1_ = (action.action);                            

                            switch (_sw1_)
                            {
                                case SwfParser.SWF_ACTION_END:
                                    done = true;
                                case SwfParser.SWF_ACTION_CONSTANTPOOL:
                                    constantPool = new Array<Dynamic>();
                                    var constantCount                            : Dynamic= data.readUnsignedShort();
                                    for (i in 0...constantCount)
                                    {
                                        constantPool.push(SwfParser.readString(data));
                                    }
                                case SwfParser.SWF_ACTION_PUSH:
                                    while (as3hx.Compat.truthy(data.position < action.position + action.length))
                                    {
                                        var pushValue                            : Dynamic= null;
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
                                    actionStack.push(actionStack[as3hx.Compat.parseInt(actionStack.length - 1)]);
                                case SwfParser.SWF_ACTION_STORE_REGISTER:
                                    actionRegisters[data.readUnsignedByte()] = actionStack[as3hx.Compat.parseInt(actionStack.length - 1)];
                                case SwfParser.SWF_ACTION_GET_VARIABLE:
                                    var gvName                            : Dynamic= actionStack.pop();
                                    if (as3hx.Compat.truthy(!(Lambda.has(actionVariables, gvName))))
                                    {
                                        Reflect.setField(actionVariables, gvName, {});
                                    }
                                    actionStack.push(Reflect.field(actionVariables, gvName));
                                case SwfParser.SWF_ACTION_SET_VARIABLE:
                                    var svValue                            : Dynamic= actionStack.pop();
                                    Reflect.setField(actionVariables, Std.string(actionStack.pop()), svValue);
                                case SwfParser.SWF_ACTION_INIT_ARRAY:
                                    var arraySize                            : Dynamic= actionStack.pop();
                                    var array                            : Dynamic= new Array<Dynamic>();
                                    for (i in 0...arraySize)
                                    {
                                        array.push(actionStack.pop());
                                    }
                                    actionStack.push(array);
                                case SwfParser.SWF_ACTION_GET_MEMBER:
                                    var gmName                            : Dynamic= actionStack.pop();
                                    var gmObject                            : Dynamic= actionStack.pop();
                                    if (as3hx.Compat.truthy(!(Lambda.has(gmObject, gmName))))
                                    {
                                        Reflect.setField(gmObject, gmName, {});
                                    }
                                    actionStack.push(Reflect.field(gmObject, gmName));
                                case SwfParser.SWF_ACTION_SET_MEMBER:
                                    var smValue                            : Dynamic= actionStack.pop();
                                    var smName                            : Dynamic= actionStack.pop();
                                    actionStack.pop()[smName] = smValue;
                                default:
                            }
                            data.position = action.position + action.length;
                        }
                        var _root                          : Dynamic= as3hx.Compat.orValue(Reflect.field(actionVariables, "_root"), { });
                        var beatBox                            : Dynamic= Reflect.field(_root, "beatBox");
                        if (as3hx.Compat.truthy(beatBox != null))
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

