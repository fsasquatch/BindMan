package cpp;

import cpp.WChar;
import cpp.Pointer;
import cpp.RawPointer;

import haxe.extern.AsVar;

extern abstract WCharPointer(RawPointer<WChar>) from RawPointer<WChar> to RawPointer<WChar>
{
    inline function new(ptr:RawPointer<WChar>):Void
    {
        this = ptr;
    }

    @:arrayAccess
    inline function get(index:Int):WChar
    {
        return this[index];
    }

    @:arrayAccess
    inline function set(index:Int, value:WChar):Void
    {
        this[index] = value;
    }

    @:from
    overload static inline function fromValue(value:AsVar<Array<WChar>>):WCharPointer
    {
        return new WCharPointer(Pointer.arrayElem(value, 0).raw);
    }

    @:from
    overload static inline function fromValue(value:AsVar<WChar>):WCharPointer
    {
        return new WCharPointer(Pointer.addressOf(value).raw);
    }
}
