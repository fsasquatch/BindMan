package cpp;

import cpp.Pointer;
import cpp.RawPointer;

import haxe.extern.AsVar;

extern abstract Float64Pointer(RawPointer<Float>) from RawPointer<Float> to RawPointer<Float>
{
    inline function new(ptr:RawPointer<Float>):Void
    {
        this = ptr;
    }

    @:arrayAccess
    inline function get(index:Int):Float
    {
        return this[index];
    }

    @:arrayAccess
    inline function set(index:Int, value:Float):Void
    {
        this[index] = value;
    }

    @:from
    overload static inline function fromValue(value:AsVar<Array<Float>>):Float64Pointer
    {
        return new Float64Pointer(Pointer.arrayElem(value, 0).raw);
    }

    @:from
    overload static inline function fromValue(value:AsVar<Float>):Float64Pointer
    {
        return new Float64Pointer(Pointer.addressOf(value).raw);
    }
}
