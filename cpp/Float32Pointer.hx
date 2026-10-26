package cpp;

import cpp.Pointer;
import cpp.RawPointer;

import haxe.extern.AsVar;

extern abstract Float32Pointer(RawPointer<Single>) from RawPointer<Single> to RawPointer<Single>
{
    inline function new(ptr:RawPointer<Single>):Void
    {
        this = ptr;
    }

    @:arrayAccess
    inline function get(index:Int):Single
    {
        return this[index];
    }

    @:arrayAccess
    inline function set(index:Int, value:Single):Void
    {
        this[index] = value;
    }

    @:from
    overload static inline function fromValue(value:AsVar<Array<Single>>):Float32Pointer
    {
        return new Float32Pointer
    (Pointer.arrayElem(value, 0).raw);
    }

    @:from
    overload static inline function fromValue(value:AsVar<Single>):Float32Pointer
    {
        return new Float32Pointer
    (Pointer.addressOf(value).raw);
    }
}
